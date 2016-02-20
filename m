From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [net-next][PATCH 08/13] RDS: IB: add connection info to ibmr
Date: Sat, 20 Feb 2016 03:29:59 -0800
Message-ID: <1455967804-27644-9-git-send-email-santosh.shilimkar@oracle.com>
References: <1455967804-27644-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455967804-27644-1-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Preperatory patch for FRMR support. From connection info,
we can retrieve cm_id which contains qp handled needed for
work request posting.

We also need to drop the RDS connection on QP error states
where connection handle becomes useful.

Signed-off-by: Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
