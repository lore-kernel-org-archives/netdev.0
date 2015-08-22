From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 11/14] RDS: Don't destroy the rdma id until after we're done using it
Date: Sat, 22 Aug 2015 15:45:32 -0700
Message-ID: <1440283535-4800-12-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <ssantosh@kernel.org>

During connection resets, we are destroying the rdma id too soon. We can't
destroy it when it is still in use. So lets move rdma_destroy_id() after
we clear the rings.

Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_cm.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index cb78da1..0443af7 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -646,7 +646,6 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 			ib_destroy_cq(ic->i_send_cq);
 		if (ic->i_recv_cq)
 			ib_destroy_cq(ic->i_recv_cq);
-		rdma_destroy_id(ic->i_cm_id);
 
 		/* then free the resources that ib callbacks use */
 		if (ic->i_send_hdrs)
@@ -672,6 +671,8 @@ void rds_ib_conn_shutdown(struct rds_connection *conn)
 		if (ic->i_recvs)
 			rds_ib_recv_clear_ring(ic);
 
+		rdma_destroy_id(ic->i_cm_id);
+
 		/*
 		 * Move connection back to the nodev list.
 		 */
-- 
1.9.1
