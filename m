From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 1/6] cfg80211/mac80211: use to_delayed_work
Date: Fri,  1 Jan 2016 23:48:52 +0800
Message-ID: <5df0633bd7779dd21192f7a41c634efd78f8606c.1451661580.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/mac80211/mlme.c | 3 +--
 net/wireless/mlme.c | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 1c342e2..ea70917 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1638,8 +1638,7 @@ void ieee80211_dynamic_ps_timer(unsigned long data)
 
 void ieee80211_dfs_cac_timer_work(struct work_struct *work)
 {
-	struct delayed_work *delayed_work =
-		container_of(work, struct delayed_work, work);
+	struct delayed_work *delayed_work = to_delayed_work(work);
 	struct ieee80211_sub_if_data *sdata =
 		container_of(delayed_work, struct ieee80211_sub_if_data,
 			     dfs_cac_timer_work);
diff --git a/net/wireless/mlme.c b/net/wireless/mlme.c
index fb44fa3..4fccf52 100644
--- a/net/wireless/mlme.c
+++ b/net/wireless/mlme.c
@@ -721,7 +721,7 @@ void cfg80211_dfs_channels_update_work(struct work_struct *work)
 	unsigned long timeout, next_time = 0;
 	int bandid, i;
 
-	delayed_work = container_of(work, struct delayed_work, work);
+	delayed_work = to_delayed_work(work);
 	rdev = container_of(delayed_work, struct cfg80211_registered_device,
 			    dfs_update_channels_wk);
 	wiphy = &rdev->wiphy;
-- 
2.5.0
