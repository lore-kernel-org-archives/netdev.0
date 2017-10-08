From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] wcn36xx: Remove unnecessary rcu_read_unlock in wcn36xx_bss_info_changed
Date: Sun,  8 Oct 2017 21:06:09 +0800
Message-ID: <1507467969-24016-1-git-send-email-baijiaju1990@163.com>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: k.eugene.e@gmail.com, kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No rcu_read_lock is called, but rcu_read_unlock is still called.
Thus rcu_read_unlock should be removed.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/ath/wcn36xx/main.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 35bd50b..b83f01d 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -812,7 +812,6 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 			if (!sta) {
 				wcn36xx_err("sta %pM is not found\n",
 					      bss_conf->bssid);
-				rcu_read_unlock();
 				goto out;
 			}
 			sta_priv = wcn36xx_sta_to_priv(sta);
-- 
1.7.9.5
