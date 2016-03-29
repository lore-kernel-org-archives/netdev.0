From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 05/16] wcn36xx: Use define for invalid index and fix typo
Date: Mon, 28 Mar 2016 23:06:22 -0700
Message-ID: <1459231593-360-6-git-send-email-bjorn.andersson@linaro.org>
References: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pontus Fuchs <pontus.fuchs@gmail.com>
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pontus Fuchs <pontus.fuchs@gmail.com>

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/hal.h  | 2 +-
 drivers/net/wireless/ath/wcn36xx/main.c | 4 ++--
 drivers/net/wireless/ath/wcn36xx/smd.c  | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index 6f99b6134e4e..67e778f9d29d 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -48,7 +48,7 @@
 
 #define WCN36XX_HAL_IPV4_ADDR_LEN       4
 
-#define WALN_HAL_STA_INVALID_IDX 0xFF
+#define WCN36XX_HAL_STA_INVALID_IDX 0xFF
 #define WCN36XX_HAL_BSS_INVALID_IDX 0xFF
 
 /* Default Beacon template size. */
diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 62cb9ffd854c..4781b5e8deb3 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -618,7 +618,7 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 
 		if (!is_zero_ether_addr(bss_conf->bssid)) {
 			vif_priv->is_joining = true;
-			vif_priv->bss_index = 0xff;
+			vif_priv->bss_index = WCN36XX_HAL_BSS_INVALID_IDX;
 			wcn36xx_smd_join(wcn, bss_conf->bssid,
 					 vif->addr, WCN36XX_HW_CHANNEL(wcn));
 			wcn36xx_smd_config_bss(wcn, vif, NULL,
@@ -711,7 +711,7 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 
 		if (bss_conf->enable_beacon) {
 			vif_priv->dtim_period = bss_conf->dtim_period;
-			vif_priv->bss_index = 0xff;
+			vif_priv->bss_index = WCN36XX_HAL_BSS_INVALID_IDX;
 			wcn36xx_smd_config_bss(wcn, vif, NULL,
 					       vif->addr, false);
 			skb = ieee80211_beacon_get_tim(hw, vif, &tim_off,
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 6baf54db6241..ca325323c802 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -197,7 +197,7 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 	    vif->type == NL80211_IFTYPE_AP ||
 	    vif->type == NL80211_IFTYPE_MESH_POINT) {
 		sta_params->type = 1;
-		sta_params->sta_index = 0xFF;
+		sta_params->sta_index = WCN36XX_HAL_STA_INVALID_IDX;
 	} else {
 		sta_params->type = 0;
 		sta_params->sta_index = 1;
-- 
2.5.0
