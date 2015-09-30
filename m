From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 11/14] RDS: IB: use already available pool handle from ibmr
Date: Wed, 30 Sep 2015 13:24:30 -0400
Message-ID: <1443633873-13359-12-git-send-email-santosh.shilimkar@oracle.com>
References: <1443633873-13359-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1443633873-13359-1-git-send-email-santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

rds_ib_mr already keeps the pool handle which it associates
with. Lets use that instead of round about way of fetching
it from rds_ib_device.

No functional change.

Signed-off-by: Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/ib_rdma.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index b6644fa..52d889a 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -522,8 +522,7 @@ static void rds_ib_teardown_mr(struct rds_ib_mr *ibmr)
 
 	__rds_ib_teardown_mr(ibmr);
 	if (pinned) {
-		struct rds_ib_device *rds_ibdev = ibmr->device;
-		struct rds_ib_mr_pool *pool = rds_ibdev->mr_pool;
+		struct rds_ib_mr_pool *pool = ibmr->pool;
 
 		atomic_sub(pinned, &pool->free_pinned);
 	}
@@ -717,8 +716,8 @@ static void rds_ib_mr_pool_flush_worker(struct work_struct *work)
 void rds_ib_free_mr(void *trans_private, int invalidate)
 {
 	struct rds_ib_mr *ibmr = trans_private;
+	struct rds_ib_mr_pool *pool = ibmr->pool;
 	struct rds_ib_device *rds_ibdev = ibmr->device;
-	struct rds_ib_mr_pool *pool = rds_ibdev->mr_pool;
 
 	rdsdebug("RDS/IB: free_mr nents %u\n", ibmr->sg_len);
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
