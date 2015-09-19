From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 12/15] RDS: use already available pool handle from ibmr
Date: Sat, 19 Sep 2015 19:04:49 -0400
Message-ID: <1442703892-26692-13-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rds_ib_mr already keeps the pool handle which it associates
with. Lets use that instead of round about way of fetching
it from rds_ib_device.

No functional change.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
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
