From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH] cxgb4:  Remove redundant memset before memcpy
Date: Sat, 14 Jan 2017 06:47:40 +0530
Message-ID: <1484356660-19082-1-git-send-email-mayhs11saini@gmail.com>
Cc: tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Shyam Saini <mayhs11saini@gmail.com>
To: hariprasad@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The region set by the call to memset, immediately overwritten by
the subsequent call to memcpy and thus makes the  memset redundant.

Also remove the memset((&info, 0, sizeof(info)) on line 398 because
info is memcpy()'ed to before being used in the loop and it isn't
used outside of the loop.

Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sched.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
index cbd68a8..c902635 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
@@ -397,9 +397,6 @@ static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
 		struct ch_sched_params info;
 		struct ch_sched_params tp;
 
-		memset(&info, 0, sizeof(info));
-		memset(&tp, 0, sizeof(tp));
-
 		memcpy(&tp, p, sizeof(tp));
 		/* Don't try to match class parameter */
 		tp.u.params.class = SCHED_CLS_NONE;
@@ -409,7 +406,6 @@ static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
 			if (e->state == SCHED_STATE_UNUSED)
 				continue;
 
-			memset(&info, 0, sizeof(info));
 			memcpy(&info, &e->info, sizeof(info));
 			/* Don't try to match class parameter */
 			info.u.params.class = SCHED_CLS_NONE;
@@ -458,7 +454,6 @@ static struct sched_class *t4_sched_class_alloc(struct port_info *pi,
 		if (!e)
 			goto out;
 
-		memset(&np, 0, sizeof(np));
 		memcpy(&np, p, sizeof(np));
 		np.u.params.class = e->idx;
 
-- 
2.7.4
