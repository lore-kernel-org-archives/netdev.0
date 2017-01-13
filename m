From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH] cxgb4: Remove redundant memset before memcpy
Date: Fri, 13 Jan 2017 15:22:49 +0530
Message-ID: <1484301169-11724-1-git-send-email-mayhs11saini@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shyam Saini <mayhs11saini@gmail.com>
To: hariprasad@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The region set by the call to memset, immediately overwritten by the
subsequent call to memcpy and thus makes the  memset redundant

Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sched.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sched.c b/drivers/net/ethernet/chelsio/cxgb4/sched.c
index cbd68a8..5725693 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sched.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sched.c
@@ -398,7 +398,6 @@ static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
 		struct ch_sched_params tp;
 
 		memset(&info, 0, sizeof(info));
-		memset(&tp, 0, sizeof(tp));
 
 		memcpy(&tp, p, sizeof(tp));
 		/* Don't try to match class parameter */
@@ -409,7 +408,6 @@ static struct sched_class *t4_sched_class_lookup(struct port_info *pi,
 			if (e->state == SCHED_STATE_UNUSED)
 				continue;
 
-			memset(&info, 0, sizeof(info));
 			memcpy(&info, &e->info, sizeof(info));
 			/* Don't try to match class parameter */
 			info.u.params.class = SCHED_CLS_NONE;
@@ -458,7 +456,6 @@ static struct sched_class *t4_sched_class_alloc(struct port_info *pi,
 		if (!e)
 			goto out;
 
-		memset(&np, 0, sizeof(np));
 		memcpy(&np, p, sizeof(np));
 		np.u.params.class = e->idx;
 
-- 
2.7.4
