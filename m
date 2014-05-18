From: =?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
Subject: [PATCH] net: rds: Use time_after() for time comparison
Date: Sun, 18 May 2014 23:32:49 +0200
Message-ID: <1400448769-5945-1-git-send-email-manuel.schoelling@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	=?UTF-8?q?Manuel=20Sch=C3=B6lling?= <manuel.schoelling@gmx.de>
To: chien.yen@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be future-proof and for better readability the time comparisons are =
modified
to use time_after() instead of raw math.

Signed-off-by: Manuel Sch=C3=B6lling <manuel.schoelling@gmx.de>
---
 net/rds/ib_send.c |    4 ++--
 net/rds/iw_send.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 37be6e2..1dde91e 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -298,7 +298,7 @@ void rds_ib_send_cq_comp_handler(struct ib_cq *cq, =
void *context)
 		rds_ib_stats_inc(s_ib_tx_cq_event);
=20
 		if (wc.wr_id =3D=3D RDS_IB_ACK_WR_ID) {
-			if (ic->i_ack_queued + HZ/2 < jiffies)
+			if (time_after(jiffies, ic->i_ack_queued + HZ/2))
 				rds_ib_stats_inc(s_ib_tx_stalled);
 			rds_ib_ack_send_complete(ic);
 			continue;
@@ -315,7 +315,7 @@ void rds_ib_send_cq_comp_handler(struct ib_cq *cq, =
void *context)
=20
 			rm =3D rds_ib_send_unmap_op(ic, send, wc.status);
=20
-			if (send->s_queued + HZ/2 < jiffies)
+			if (time_after(jiffies, send->s_queued + HZ/2))
 				rds_ib_stats_inc(s_ib_tx_stalled);
=20
 			if (send->s_op) {
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index e40c3c5..9105ea0 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -232,7 +232,7 @@ void rds_iw_send_cq_comp_handler(struct ib_cq *cq, =
void *context)
 		}
=20
 		if (wc.wr_id =3D=3D RDS_IW_ACK_WR_ID) {
-			if (ic->i_ack_queued + HZ/2 < jiffies)
+			if (time_after(jiffies, ic->i_ack_queued + HZ/2))
 				rds_iw_stats_inc(s_iw_tx_stalled);
 			rds_iw_ack_send_complete(ic);
 			continue;
@@ -267,7 +267,7 @@ void rds_iw_send_cq_comp_handler(struct ib_cq *cq, =
void *context)
=20
 			send->s_wr.opcode =3D 0xdead;
 			send->s_wr.num_sge =3D 1;
-			if (send->s_queued + HZ/2 < jiffies)
+			if (time_after(jiffies, send->s_queued + HZ/2))
 				rds_iw_stats_inc(s_iw_tx_stalled);
=20
 			/* If a RDMA operation produced an error, signal this right
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
