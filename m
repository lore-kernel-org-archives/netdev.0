From: Avinash Repaka <avinash.repaka@oracle.com>
Subject: [PATCH net v2] RDS: IB: Initialize max_items based on underlying device attributes
Date: Wed,  4 Oct 2017 12:11:29 -0700
Message-ID: <1507144289-1690-1-git-send-email-avinash.repaka@oracle.com>
Cc: Avinash Repaka <avinash.repaka@oracle.com>
To: Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use max_1m_mrs/max_8k_mrs while setting max_items, as the former
variables are set based on the underlying device attributes.

Signed-off-by: Avinash Repaka <avinash.repaka@oracle.com>
Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
v1->v2
Fixed a typo in commit description

 net/rds/ib_rdma.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 9a3c54e..e678699 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -601,11 +601,11 @@ struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev,
 	if (pool_type == RDS_IB_MR_1M_POOL) {
 		/* +1 allows for unaligned MRs */
 		pool->fmr_attr.max_pages = RDS_MR_1M_MSG_SIZE + 1;
-		pool->max_items = RDS_MR_1M_POOL_SIZE;
+		pool->max_items = rds_ibdev->max_1m_mrs;
 	} else {
 		/* pool_type == RDS_IB_MR_8K_POOL */
 		pool->fmr_attr.max_pages = RDS_MR_8K_MSG_SIZE + 1;
-		pool->max_items = RDS_MR_8K_POOL_SIZE;
+		pool->max_items = rds_ibdev->max_8k_mrs;
 	}
 
 	pool->max_free_pinned = pool->max_items * pool->fmr_attr.max_pages / 4;
-- 
2.4.11
