From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 04/15] wcn36xx: Use consistent name for private vif
Date: Sun,  3 Apr 2016 15:16:35 -0700
Message-ID: <1459721806-11817-4-git-send-email-bjorn.andersson@linaro.org>
References: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, wcn36xx-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1459721806-11817-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Some code used priv_vif and some used vif_priv. Convert all to vif_priv
for consistency.

Signed-off-by: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/smd.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index cc1b3b7a4ff9..170440ed5d85 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -191,7 +191,7 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 		struct ieee80211_sta *sta,
 		struct wcn36xx_hal_config_sta_params *sta_params)
 {
-	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	struct wcn36xx_sta *priv_sta = NULL;
 	if (vif->type == NL80211_IFTYPE_ADHOC ||
 	    vif->type == NL80211_IFTYPE_AP ||
@@ -215,7 +215,7 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 	else
 		memcpy(&sta_params->bssid, vif->addr, ETH_ALEN);
 
-	sta_params->encrypt_type = priv_vif->encrypt_type;
+	sta_params->encrypt_type = vif_priv->encrypt_type;
 	sta_params->short_preamble_supported = true;
 
 	sta_params->rifs_mode = 0;
@@ -224,7 +224,7 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 	sta_params->uapsd = 0;
 	sta_params->mimo_ps = WCN36XX_HAL_HT_MIMO_PS_STATIC;
 	sta_params->max_ampdu_duration = 0;
-	sta_params->bssid_index = priv_vif->bss_index;
+	sta_params->bssid_index = vif_priv->bss_index;
 	sta_params->p2p = 0;
 
 	if (sta) {
@@ -726,7 +726,7 @@ static int wcn36xx_smd_add_sta_self_rsp(struct wcn36xx *wcn,
 					size_t len)
 {
 	struct wcn36xx_hal_add_sta_self_rsp_msg *rsp;
-	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 
 	if (len < sizeof(*rsp))
 		return -EINVAL;
@@ -743,8 +743,8 @@ static int wcn36xx_smd_add_sta_self_rsp(struct wcn36xx *wcn,
 		    "hal add sta self status %d self_sta_index %d dpu_index %d\n",
 		    rsp->status, rsp->self_sta_index, rsp->dpu_index);
 
-	priv_vif->self_sta_index = rsp->self_sta_index;
-	priv_vif->self_dpu_desc_index = rsp->dpu_index;
+	vif_priv->self_sta_index = rsp->self_sta_index;
+	vif_priv->self_dpu_desc_index = rsp->dpu_index;
 
 	return 0;
 }
@@ -1175,7 +1175,7 @@ static int wcn36xx_smd_config_bss_rsp(struct wcn36xx *wcn,
 {
 	struct wcn36xx_hal_config_bss_rsp_msg *rsp;
 	struct wcn36xx_hal_config_bss_rsp_params *params;
-	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 
 	if (len < sizeof(*rsp))
 		return -EINVAL;
@@ -1198,14 +1198,14 @@ static int wcn36xx_smd_config_bss_rsp(struct wcn36xx *wcn,
 		    params->bss_bcast_sta_idx, params->mac,
 		    params->tx_mgmt_power, params->ucast_dpu_signature);
 
-	priv_vif->bss_index = params->bss_index;
+	vif_priv->bss_index = params->bss_index;
 
-	if (priv_vif->sta) {
-		priv_vif->sta->bss_sta_index =  params->bss_sta_index;
-		priv_vif->sta->bss_dpu_desc_index = params->dpu_desc_index;
+	if (vif_priv->sta) {
+		vif_priv->sta->bss_sta_index =  params->bss_sta_index;
+		vif_priv->sta->bss_dpu_desc_index = params->dpu_desc_index;
 	}
 
-	priv_vif->self_ucast_dpu_sign = params->ucast_dpu_signature;
+	vif_priv->self_ucast_dpu_sign = params->ucast_dpu_signature;
 
 	return 0;
 }
@@ -1343,13 +1343,13 @@ out:
 int wcn36xx_smd_delete_bss(struct wcn36xx *wcn, struct ieee80211_vif *vif)
 {
 	struct wcn36xx_hal_delete_bss_req_msg msg_body;
-	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	int ret = 0;
 
 	mutex_lock(&wcn->hal_mutex);
 	INIT_HAL_MSG(msg_body, WCN36XX_HAL_DELETE_BSS_REQ);
 
-	msg_body.bss_index = priv_vif->bss_index;
+	msg_body.bss_index = vif_priv->bss_index;
 
 	PREPARE_HAL_BUF(wcn->hal_buf, msg_body);
 
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
