From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 5/6] RDS: flush the FMR pool less often
Date: Tue, 25 Aug 2015 12:02:02 -0700
Message-ID: <1440529323-4171-6-git-send-email-santosh.shilimkar@oracle.com>
References: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FMR flush is an expensive and time consuming operation. Reduce the
frequency of FMR pool flush by 50% so that more FMR work gets accumulated
for more efficient flushing.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 2ac78c9..e596dfb 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -737,7 +737,7 @@ void rds_ib_free_mr(void *trans_private, int invalidate)
 
 	/* If we've pinned too many pages, request a flush */
 	if (atomic_read(&pool->free_pinned) >= pool->max_free_pinned ||
-	    atomic_read(&pool->dirty_count) >= pool->max_items / 10)
+	    atomic_read(&pool->dirty_count) >= pool->max_items / 5)
 		queue_delayed_work(rds_ib_fmr_wq, &pool->flush_worker, 10);
 
 	if (invalidate) {
-- 
1.9.1
