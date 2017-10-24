From: =?UTF-8?q?H=C3=A5kon=20Bugge?= <Haakon.Bugge@oracle.com>
Subject: [PATCH] rds: Fix uninitialized variable
Date: Tue, 24 Oct 2017 18:07:19 +0200
Message-ID: <20171024160719.17726-1-Haakon.Bugge@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

send_flags needs to be initialized before calling
rds_ib_set_wr_signal_state().

Signed-off-by: Håkon Bugge <haakon.bugge@oracle.com>
---
 net/rds/ib_send.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 6ab39db..8f46755 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -792,6 +792,7 @@ int rds_ib_xmit_atomic(struct rds_connection *conn, struct rm_atomic_op *op)
 		send->s_atomic_wr.compare_add_mask = op->op_m_fadd.nocarry_mask;
 		send->s_atomic_wr.swap_mask = 0;
 	}
+	send->s_wr.send_flags = 0;
 	nr_sig = rds_ib_set_wr_signal_state(ic, send, op->op_notify);
 	send->s_atomic_wr.wr.num_sge = 1;
 	send->s_atomic_wr.wr.next = NULL;
-- 
1.8.3.1
