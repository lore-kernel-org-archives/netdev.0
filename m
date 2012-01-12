From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] RDS: Remove some unused iWARP code
Date: Thu, 12 Jan 2012 10:57:56 -0800
Message-ID: <1326394676-28337-1-git-send-email-roland@kernel.org>
Cc: Jonathan Lallinger <jonathan-/Yg/VP3ZvrM@public.gmane.org>, Steve Wise <swise-/Yg/VP3ZvrM@public.gmane.org>,
	rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Venkat Venkatsubra <venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>

rds_iw_flush_goal() just returns a count, but it is only called in one
place and its return value is ignored there.  So delete all the dead code.

Signed-off-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
---
 net/rds/iw_rdma.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 4e1de17..a817705 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -477,17 +477,6 @@ void rds_iw_sync_mr(void *trans_private, int direction)
 	}
 }
 
-static inline unsigned int rds_iw_flush_goal(struct rds_iw_mr_pool *pool, int free_all)
-{
-	unsigned int item_count;
-
-	item_count = atomic_read(&pool->item_count);
-	if (free_all)
-		return item_count;
-
-	return 0;
-}
-
 /*
  * Flush our pool of MRs.
  * At a minimum, all currently unused MRs are unmapped.
@@ -500,7 +489,7 @@ static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
 	LIST_HEAD(unmap_list);
 	LIST_HEAD(kill_list);
 	unsigned long flags;
-	unsigned int nfreed = 0, ncleaned = 0, unpinned = 0, free_goal;
+	unsigned int nfreed = 0, ncleaned = 0, unpinned = 0;
 	int ret = 0;
 
 	rds_iw_stats_inc(s_iw_rdma_mr_pool_flush);
@@ -514,8 +503,6 @@ static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
 		list_splice_init(&pool->clean_list, &kill_list);
 	spin_unlock_irqrestore(&pool->list_lock, flags);
 
-	free_goal = rds_iw_flush_goal(pool, free_all);
-
 	/* Batched invalidate of dirty MRs.
 	 * For FMR based MRs, the mappings on the unmap list are
 	 * actually members of an ibmr (ibmr->mapping). They either
-- 
1.7.8.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
