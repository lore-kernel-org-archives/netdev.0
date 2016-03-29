From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 13/16] wcn36xx: Track association state
Date: Mon, 28 Mar 2016 23:06:30 -0700
Message-ID: <1459231593-360-14-git-send-email-bjorn.andersson@linaro.org>
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

Knowing the association state is needed for mc filtering.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c    | 2 ++
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index f9c77de94583..253cece1b660 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -655,6 +655,7 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 				     vif->addr,
 				     bss_conf->aid);
 
+			vif_priv->sta_assoc = true;
 			rcu_read_lock();
 			sta = ieee80211_find_sta(vif, bss_conf->bssid);
 			if (!sta) {
@@ -686,6 +687,7 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 				    bss_conf->bssid,
 				    vif->addr,
 				    bss_conf->aid);
+			vif_priv->sta_assoc = false;
 			wcn36xx_smd_set_link_st(wcn,
 						bss_conf->bssid,
 						vif->addr,
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 54000db0af1a..7433d67a5929 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -128,6 +128,7 @@ struct wcn36xx_vif {
 	u8 dtim_period;
 	enum ani_ed_type encrypt_type;
 	bool is_joining;
+	bool sta_assoc;
 	struct wcn36xx_hal_mac_ssid ssid;
 
 	/* Power management */
-- 
2.5.0
