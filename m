From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v4 10/14] RDS: IB: fix the rds_ib_fmr_wq kick call
Date: Wed,  7 Oct 2015 08:53:44 -0700
Message-ID: <1444233228-4481-11-git-send-email-santosh.shilimkar@oracle.com>
References: <1444233228-4481-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444233228-4481-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RDS IB mr pool has its own workqueue 'rds_ib_fmr_wq', so we need
to use queue_delayed_work() to kick the work. This was hurting
the performance since pool maintenance was less often triggered
from other path.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 872f523..b6644fa 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -319,7 +319,7 @@ static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev)
 	int err = 0, iter = 0;
 
 	if (atomic_read(&pool->dirty_count) >= pool->max_items / 10)
-		schedule_delayed_work(&pool->flush_worker, 10);
+		queue_delayed_work(rds_ib_fmr_wq, &pool->flush_worker, 10);
 
 	while (1) {
 		ibmr = rds_ib_reuse_fmr(pool);
-- 
1.9.1
