From: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH] cfg80211: drop unlikely behind WARN_ON()
Date: Sun,  4 Oct 2015 15:09:27 +0800
Message-ID: <88184946efc981b4cba84cf21418954423ca11a4.1443942486.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

WARN_ON() already contain an unlikely compiler flag. Drop it.

Signed-off-by: Geliang Tang <geliangtang-9Onoh4P/yGk@public.gmane.org>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index a511ef3..fe38fc4 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -2217,7 +2217,7 @@ static int ath6kl_wow_suspend(struct ath6kl *ar, struct cfg80211_wowlan *wow)
 
 	/* enter / leave wow suspend on first vif always */
 	first_vif = ath6kl_vif_first(ar);
-	if (WARN_ON(unlikely(!first_vif)) ||
+	if (WARN_ON(!first_vif) ||
 	    !ath6kl_cfg80211_ready(first_vif))
 		return -EIO;
 
@@ -2297,7 +2297,7 @@ static int ath6kl_wow_resume(struct ath6kl *ar)
 	int ret;
 
 	vif = ath6kl_vif_first(ar);
-	if (WARN_ON(unlikely(!vif)) ||
+	if (WARN_ON(!vif) ||
 	    !ath6kl_cfg80211_ready(vif))
 		return -EIO;
 
-- 
2.5.0


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
