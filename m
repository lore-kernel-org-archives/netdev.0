From: Joe Perches <joe@perches.com>
Subject: [PATCH 14/24] rds: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:33 -0700
Message-ID: <e193b309f7be940bbe9d3aba393bb862a3502115.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andy Grover <andy.grover@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rds/ib_rdma.c |    1 -
 net/rds/iw_rdma.c |    8 +-------
 net/rds/iw_send.c |    8 ++------
 3 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 819c35a..3b76b74 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -355,7 +355,6 @@ static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev)
 	if (IS_ERR(ibmr->fmr)) {
 		err = PTR_ERR(ibmr->fmr);
 		ibmr->fmr = NULL;
-		printk(KERN_WARNING "RDS/IB: ib_alloc_fmr failed (err=%d)\n", err);
 		goto out_no_cigar;
 	}
 
diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 8b77edb..7b18283 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -339,10 +339,8 @@ struct rds_iw_mr_pool *rds_iw_create_mr_pool(struct rds_iw_device *rds_iwdev)
 	struct rds_iw_mr_pool *pool;
 
 	pool = kzalloc(sizeof(*pool), GFP_KERNEL);
-	if (!pool) {
-		printk(KERN_WARNING "RDS/IW: rds_iw_create_mr_pool alloc error\n");
+	if (!pool)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	pool->device = rds_iwdev;
 	INIT_LIST_HEAD(&pool->dirty_list);
@@ -676,8 +674,6 @@ static int rds_iw_init_fastreg(struct rds_iw_mr_pool *pool,
 	mr = ib_alloc_fast_reg_mr(rds_iwdev->pd, pool->max_message_size);
 	if (IS_ERR(mr)) {
 		err = PTR_ERR(mr);
-
-		printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_mr failed (err=%d)\n", err);
 		return err;
 	}
 
@@ -687,8 +683,6 @@ static int rds_iw_init_fastreg(struct rds_iw_mr_pool *pool,
 	page_list = ib_alloc_fast_reg_page_list(rds_iwdev->dev, pool->max_message_size);
 	if (IS_ERR(page_list)) {
 		err = PTR_ERR(page_list);
-
-		printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_page_list failed (err=%d)\n", err);
 		ib_dereg_mr(mr);
 		return err;
 	}
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index e40c3c5..debf586 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -154,17 +154,13 @@ void rds_iw_send_init_ring(struct rds_iw_connection *ic)
 		sge->lkey = 0;
 
 		send->s_mr = ib_alloc_fast_reg_mr(ic->i_pd, fastreg_message_size);
-		if (IS_ERR(send->s_mr)) {
-			printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_mr failed\n");
+		if (IS_ERR(send->s_mr))
 			break;
-		}
 
 		send->s_page_list = ib_alloc_fast_reg_page_list(
 			ic->i_cm_id->device, fastreg_message_size);
-		if (IS_ERR(send->s_page_list)) {
-			printk(KERN_WARNING "RDS/IW: ib_alloc_fast_reg_page_list failed\n");
+		if (IS_ERR(send->s_page_list))
 			break;
-		}
 	}
 }
 
-- 
1.7.6.405.gc1be0
