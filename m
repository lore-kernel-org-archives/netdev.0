From: Monam Agarwal <monamagarwal123@gmail.com>
Subject: [PATCH] net/mac80211: Use RCU_INIT_POINTER(x, NULL) in util.c
Date: Mon, 24 Mar 2014 00:51:43 +0530
Message-ID: <1395602503-14958-1-git-send-email-monamagarwal123@gmail.com>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x, NULL)

The rcu_assign_pointer() ensures that the initialization of a structure       
is carried out before storing a pointer to that structure. 
And in the case of the NULL pointer, there is no structure to initialize. 
So, rcu_assign_pointer(p, NULL) can be safely converted to RCU_INIT_POINTER(p, NULL)

Signed-off-by: Monam Agarwal <monamagarwal123@gmail.com>
---
 net/mac80211/util.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 275c94f..7601657 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1546,7 +1546,7 @@ int ieee80211_reconfig(struct ieee80211_local *local)
 		WARN_ON(local->resuming);
 		res = drv_add_interface(local, sdata);
 		if (WARN_ON(res)) {
-			rcu_assign_pointer(local->monitor_sdata, NULL);
+			RCU_INIT_POINTER(local->monitor_sdata, NULL);
 			synchronize_net();
 			kfree(sdata);
 		}
-- 
1.7.9.5
