From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v3 08/13] RDS: IB: add connection info to ibmr
Date: Tue,  1 Mar 2016 15:20:49 -0800
Message-ID: <1456874454-10355-9-git-send-email-santosh.shilimkar@oracle.com>
References: <1456874454-10355-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456874454-10355-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Preperatory patch for FRMR support. From connection info,
we can retrieve cm_id which contains qp handled needed for
work request posting.

We also need to drop the RDS connection on QP error states
where connection handle becomes useful.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_mr.h | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index f5c1fcb..add7725 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -50,18 +50,19 @@ struct rds_ib_fmr {
 
 /* This is stored as mr->r_trans_private. */
 struct rds_ib_mr {
-	struct rds_ib_device	*device;
-	struct rds_ib_mr_pool	*pool;
+	struct rds_ib_device		*device;
+	struct rds_ib_mr_pool		*pool;
+	struct rds_ib_connection	*ic;
 
-	struct llist_node	llnode;
+	struct llist_node		llnode;
 
 	/* unmap_list is for freeing */
-	struct list_head	unmap_list;
-	unsigned int		remap_count;
+	struct list_head		unmap_list;
+	unsigned int			remap_count;
 
-	struct scatterlist	*sg;
-	unsigned int		sg_len;
-	int			sg_dma_len;
+	struct scatterlist		*sg;
+	unsigned int			sg_len;
+	int				sg_dma_len;
 
 	union {
 		struct rds_ib_fmr	fmr;
-- 
1.9.1
