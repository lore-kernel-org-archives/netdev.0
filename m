From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 15/18] RDS: add stat for socket recv memory usage
Date: Tue,  6 Dec 2016 20:01:53 -0800
Message-ID: <1481083316-11648-16-git-send-email-santosh.shilimkar@oracle.com>
References: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, santosh.shilimkar@oracle.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481083316-11648-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>

Tracks the receive side memory added to scokets and removed from sockets.

Signed-off-by: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/rds.h  | 3 +++
 net/rds/recv.c | 4 ++++
 2 files changed, 7 insertions(+)

diff --git a/net/rds/rds.h b/net/rds/rds.h
index 0bb8213..8ccd5a9 100644
--- a/net/rds/rds.h
+++ b/net/rds/rds.h
@@ -631,6 +631,9 @@ struct rds_statistics {
 	uint64_t	s_cong_update_received;
 	uint64_t	s_cong_send_error;
 	uint64_t	s_cong_send_blocked;
+	uint64_t	s_recv_bytes_added_to_socket;
+	uint64_t	s_recv_bytes_removed_from_socket;
+
 };
 
 /* af_rds.c */
diff --git a/net/rds/recv.c b/net/rds/recv.c
index 9d0666e..ba19eee 100644
--- a/net/rds/recv.c
+++ b/net/rds/recv.c
@@ -94,6 +94,10 @@ static void rds_recv_rcvbuf_delta(struct rds_sock *rs, struct sock *sk,
 		return;
 
 	rs->rs_rcv_bytes += delta;
+	if (delta > 0)
+		rds_stats_add(s_recv_bytes_added_to_socket, delta);
+	else
+		rds_stats_add(s_recv_bytes_removed_from_socket, -delta);
 	now_congested = rs->rs_rcv_bytes > rds_sk_rcvbuf(rs);
 
 	rdsdebug("rs %p (%pI4:%u) recv bytes %d buf %d "
-- 
1.9.1
