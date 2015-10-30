From: Saurabh Sengar <saurabh.truth@gmail.com>
Subject: [PATCH v2] net: rds: changing the return type from int to void
Date: Fri, 30 Oct 2015 19:46:44 +0530
Message-ID: <1446214604-6437-1-git-send-email-saurabh.truth@gmail.com>
References: <saurabh.truth@gmail.com>
Cc: Saurabh Sengar <saurabh.truth@gmail.com>
To: sergei.shtylyov@cogentembedded.com, chien.yen@oracle.com,
	davem@davemloft.net, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <saurabh.truth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

as result of function rds_iw_flush_mr_pool is nowhere checked,
changing its return type from int to void.
also removing the unused variable rc as there is nothing to return

Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>
---
v2 :  modify patch description, as per the comments from Sergei Shtylyov

 net/rds/iw_rdma.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 6a8fbd6..d3d4454f 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -75,7 +75,7 @@ struct rds_iw_mr_pool {
 	int			max_pages;
 };
 
-static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all);
+static void rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all);
 static void rds_iw_mr_pool_flush_worker(struct work_struct *work);
 static int rds_iw_init_fastreg(struct rds_iw_mr_pool *pool, struct rds_iw_mr *ibmr);
 static int rds_iw_map_fastreg(struct rds_iw_mr_pool *pool,
@@ -479,14 +479,13 @@ void rds_iw_sync_mr(void *trans_private, int direction)
  * If the number of MRs allocated exceeds the limit, we also try
  * to free as many MRs as needed to get back to this limit.
  */
-static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
+static void rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
 {
 	struct rds_iw_mr *ibmr, *next;
 	LIST_HEAD(unmap_list);
 	LIST_HEAD(kill_list);
 	unsigned long flags;
 	unsigned int nfreed = 0, ncleaned = 0, unpinned = 0;
-	int ret = 0;
 
 	rds_iw_stats_inc(s_iw_rdma_mr_pool_flush);
 
@@ -538,7 +537,6 @@ static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
 	atomic_sub(nfreed, &pool->item_count);
 
 	mutex_unlock(&pool->flush_lock);
-	return ret;
 }
 
 static void rds_iw_mr_pool_flush_worker(struct work_struct *work)
-- 
1.9.1
