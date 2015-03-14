From: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
Subject: [PATCH] ath10k: debug: match wait_for_completion_timeout return type
Date: Sat, 14 Mar 2015 05:37:10 -0400
Message-ID: <1426325830-19740-1-git-send-email-hofrat@osadl.org>
Cc: ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
An appropriately named unsigned long is added and the assignments fixed up.
Missing spaces 1*HZ -> 1 * HZ were also added along the way.

Signed-off-by: Nicholas Mc Guire <hofrat-Q945KHDl0DbYtjvyW6yDsg@public.gmane.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150313)

 drivers/net/wireless/ath/ath10k/debug.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/debug.c b/drivers/net/wireless/ath/ath10k/debug.c
index 301081d..a252774 100644
--- a/drivers/net/wireless/ath/ath10k/debug.c
+++ b/drivers/net/wireless/ath/ath10k/debug.c
@@ -380,12 +380,12 @@ unlock:
 
 static int ath10k_debug_fw_stats_request(struct ath10k *ar)
 {
-	unsigned long timeout;
+	unsigned long timeout, time_left;
 	int ret;
 
 	lockdep_assert_held(&ar->conf_mutex);
 
-	timeout = jiffies + msecs_to_jiffies(1*HZ);
+	timeout = jiffies + msecs_to_jiffies(1 * HZ);
 
 	ath10k_debug_fw_stats_reset(ar);
 
@@ -404,9 +404,10 @@ static int ath10k_debug_fw_stats_request(struct ath10k *ar)
 			return ret;
 		}
 
-		ret = wait_for_completion_timeout(&ar->debug.fw_stats_complete,
-						  1*HZ);
-		if (ret == 0)
+		time_left =
+		wait_for_completion_timeout(&ar->debug.fw_stats_complete,
+					    1 * HZ);
+		if (!time_left)
 			return -ETIMEDOUT;
 
 		spin_lock_bh(&ar->data_lock);
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
