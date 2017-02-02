From: =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
Subject: [PATCH 1/3] ath10k: remove ath10k_vif_to_arvif()
Date: Thu,  2 Feb 2017 11:19:31 +0100
Message-ID: <1486030773-30600-1-git-send-email-amadeusz.slawinski@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Amadeusz=20S=C5=82awi=C5=84ski?=
        <amadeusz.slawinski@tieto.com>
To: ath10k@lists.infradead.org, Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

it adds unnecessary level of indirection, while we just access structure
field

Signed-off-by: Amadeusz Sławiński <amadeusz.slawinski@tieto.com>
---
 drivers/net/wireless/ath/ath10k/mac.c | 68 +++++++++++++++++------------------
 drivers/net/wireless/ath/ath10k/mac.h |  7 +---
 drivers/net/wireless/ath/ath10k/p2p.c |  2 +-
 drivers/net/wireless/ath/ath10k/wmi.c |  2 +-
 4 files changed, 37 insertions(+), 42 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index aa545a1..9cb96f6 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -1954,7 +1954,7 @@ static void ath10k_mac_handle_beacon_iter(void *data, u8 *mac,
 {
 	struct sk_buff *skb = data;
 	struct ieee80211_mgmt *mgmt = (void *)skb->data;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 
 	if (vif->type != NL80211_IFTYPE_STATION)
 		return;
@@ -1977,7 +1977,7 @@ static void ath10k_mac_handle_beacon_miss_iter(void *data, u8 *mac,
 					       struct ieee80211_vif *vif)
 {
 	u32 *vdev_id = data;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ath10k *ar = arvif->ar;
 	struct ieee80211_hw *hw = ar->hw;
 
@@ -2044,7 +2044,7 @@ static void ath10k_peer_assoc_h_basic(struct ath10k *ar,
 				      struct ieee80211_sta *sta,
 				      struct wmi_peer_assoc_complete_arg *arg)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	u32 aid;
 
 	lockdep_assert_held(&ar->conf_mutex);
@@ -2120,7 +2120,7 @@ static void ath10k_peer_assoc_h_rates(struct ath10k *ar,
 				      struct ieee80211_sta *sta,
 				      struct wmi_peer_assoc_complete_arg *arg)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct wmi_rate_set_arg *rateset = &arg->peer_legacy_rates;
 	struct cfg80211_chan_def def;
 	const struct ieee80211_supported_band *sband;
@@ -2183,7 +2183,7 @@ static void ath10k_peer_assoc_h_ht(struct ath10k *ar,
 				   struct wmi_peer_assoc_complete_arg *arg)
 {
 	const struct ieee80211_sta_ht_cap *ht_cap = &sta->ht_cap;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct cfg80211_chan_def def;
 	enum nl80211_band band;
 	const u8 *ht_mcs_mask;
@@ -2407,7 +2407,7 @@ static void ath10k_peer_assoc_h_vht(struct ath10k *ar,
 				    struct wmi_peer_assoc_complete_arg *arg)
 {
 	const struct ieee80211_sta_vht_cap *vht_cap = &sta->vht_cap;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct cfg80211_chan_def def;
 	enum nl80211_band band;
 	const u16 *vht_mcs_mask;
@@ -2465,7 +2465,7 @@ static void ath10k_peer_assoc_h_qos(struct ath10k *ar,
 				    struct ieee80211_sta *sta,
 				    struct wmi_peer_assoc_complete_arg *arg)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 
 	switch (arvif->vdev_type) {
 	case WMI_VDEV_TYPE_AP:
@@ -2505,7 +2505,7 @@ static void ath10k_peer_assoc_h_phymode(struct ath10k *ar,
 					struct ieee80211_sta *sta,
 					struct wmi_peer_assoc_complete_arg *arg)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct cfg80211_chan_def def;
 	enum nl80211_band band;
 	const u8 *ht_mcs_mask;
@@ -2625,7 +2625,7 @@ static int ath10k_mac_vif_recalc_txbf(struct ath10k *ar,
 				      struct ieee80211_vif *vif,
 				      struct ieee80211_sta_vht_cap vht_cap)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	int ret;
 	u32 param;
 	u32 value;
@@ -2692,7 +2692,7 @@ static void ath10k_bss_assoc(struct ieee80211_hw *hw,
 			     struct ieee80211_bss_conf *bss_conf)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ieee80211_sta_ht_cap ht_cap;
 	struct ieee80211_sta_vht_cap vht_cap;
 	struct wmi_peer_assoc_complete_arg peer_arg;
@@ -2785,7 +2785,7 @@ static void ath10k_bss_disassoc(struct ieee80211_hw *hw,
 				struct ieee80211_vif *vif)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ieee80211_sta_vht_cap vht_cap = {};
 	int ret;
 
@@ -2818,7 +2818,7 @@ static int ath10k_station_assoc(struct ath10k *ar,
 				struct ieee80211_sta *sta,
 				bool reassoc)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct wmi_peer_assoc_complete_arg peer_arg;
 	int ret = 0;
 
@@ -2885,7 +2885,7 @@ static int ath10k_station_disassoc(struct ath10k *ar,
 				   struct ieee80211_vif *vif,
 				   struct ieee80211_sta *sta)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	int ret = 0;
 
 	lockdep_assert_held(&ar->conf_mutex);
@@ -3111,7 +3111,7 @@ static void ath10k_mac_tx_unlock_iter(void *data, u8 *mac,
 				      struct ieee80211_vif *vif)
 {
 	struct ath10k *ar = data;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 
 	if (arvif->tx_paused)
 		return;
@@ -3198,7 +3198,7 @@ struct ath10k_mac_tx_pause {
 static void ath10k_mac_handle_tx_pause_iter(void *data, u8 *mac,
 					    struct ieee80211_vif *vif)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ath10k_mac_tx_pause *arg = data;
 
 	if (arvif->vdev_id != arg->vdev_id)
@@ -3294,7 +3294,7 @@ static bool ath10k_tx_h_use_hwcrypto(struct ieee80211_vif *vif,
 		return false;
 
 	if (vif)
-		return !ath10k_vif_to_arvif(vif)->nohwcrypt;
+		return !((struct ath10k_vif *)vif->drv_priv)->nohwcrypt;
 
 	return true;
 }
@@ -3359,7 +3359,7 @@ static void ath10k_tx_h_add_p2p_noa_ie(struct ath10k *ar,
 				       struct sk_buff *skb)
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 
 	/* This is case only for P2P_GO */
 	if (vif->type != NL80211_IFTYPE_AP || !vif->p2p)
@@ -4775,7 +4775,7 @@ static int ath10k_add_interface(struct ieee80211_hw *hw,
 				struct ieee80211_vif *vif)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ath10k_peer *peer;
 	enum wmi_sta_powersave_param param;
 	int ret = 0;
@@ -5111,7 +5111,7 @@ static void ath10k_remove_interface(struct ieee80211_hw *hw,
 				    struct ieee80211_vif *vif)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ath10k_peer *peer;
 	int ret;
 	int i;
@@ -5242,7 +5242,7 @@ static void ath10k_bss_info_changed(struct ieee80211_hw *hw,
 				    u32 changed)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	int ret = 0;
 	u32 vdev_param, pdev_param, slottime, preamble;
 
@@ -5436,7 +5436,7 @@ static int ath10k_hw_scan(struct ieee80211_hw *hw,
 			  struct ieee80211_scan_request *hw_req)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct cfg80211_scan_request *req = &hw_req->req;
 	struct wmi_start_scan_arg arg;
 	int ret = 0;
@@ -5568,7 +5568,7 @@ static int ath10k_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			  struct ieee80211_key_conf *key)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ath10k_peer *peer;
 	const u8 *peer_addr;
 	bool is_wep = key->cipher == WLAN_CIPHER_SUITE_WEP40 ||
@@ -5707,7 +5707,7 @@ static void ath10k_set_default_unicast_key(struct ieee80211_hw *hw,
 					   int keyidx)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	int ret;
 
 	mutex_lock(&arvif->ar->conf_mutex);
@@ -5888,7 +5888,7 @@ static int ath10k_mac_tdls_vif_stations_count(struct ieee80211_hw *hw,
 static void ath10k_mac_tdls_vifs_count_iter(void *data, u8 *mac,
 					    struct ieee80211_vif *vif)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	int *num_tdls_vifs = data;
 
 	if (vif->type != NL80211_IFTYPE_STATION)
@@ -5916,7 +5916,7 @@ static int ath10k_sta_state(struct ieee80211_hw *hw,
 			    enum ieee80211_sta_state new_state)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ath10k_sta *arsta = (struct ath10k_sta *)sta->drv_priv;
 	struct ath10k_peer *peer;
 	int ret = 0;
@@ -6151,7 +6151,7 @@ static int ath10k_sta_state(struct ieee80211_hw *hw,
 static int ath10k_conf_tx_uapsd(struct ath10k *ar, struct ieee80211_vif *vif,
 				u16 ac, bool enable)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct wmi_sta_uapsd_auto_trig_arg arg = {};
 	u32 prio = 0, acc = 0;
 	u32 value = 0;
@@ -6259,7 +6259,7 @@ static int ath10k_conf_tx(struct ieee80211_hw *hw,
 			  const struct ieee80211_tx_queue_params *params)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct wmi_wmm_params_arg *p = NULL;
 	int ret;
 
@@ -6333,7 +6333,7 @@ static int ath10k_remain_on_channel(struct ieee80211_hw *hw,
 				    enum ieee80211_roc_type type)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct wmi_start_scan_arg arg;
 	int ret = 0;
 	u32 scan_time_msec;
@@ -6833,7 +6833,7 @@ static int ath10k_mac_op_set_bitrate_mask(struct ieee80211_hw *hw,
 					  struct ieee80211_vif *vif,
 					  const struct cfg80211_bitrate_mask *mask)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct cfg80211_chan_def def;
 	struct ath10k *ar = arvif->ar;
 	enum nl80211_band band;
@@ -6981,7 +6981,7 @@ static void ath10k_offset_tsf(struct ieee80211_hw *hw,
 			      struct ieee80211_vif *vif, s64 tsf_offset)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	u32 offset, vdev_param;
 	int ret;
 
@@ -7006,7 +7006,7 @@ static int ath10k_ampdu_action(struct ieee80211_hw *hw,
 			       struct ieee80211_ampdu_params *params)
 {
 	struct ath10k *ar = hw->priv;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ieee80211_sta *sta = params->sta;
 	enum ieee80211_ampdu_mlme_action action = params->action;
 	u16 tid = params->tid;
@@ -7104,7 +7104,7 @@ static int ath10k_ampdu_action(struct ieee80211_hw *hw,
 		ath10k_monitor_stop(ar);
 
 	for (i = 0; i < n_vifs; i++) {
-		arvif = ath10k_vif_to_arvif(vifs[i].vif);
+		arvif = (void *)vifs[i].vif->drv_priv;
 
 		ath10k_dbg(ar, ATH10K_DBG_MAC,
 			   "mac chanctx switch vdev_id %i freq %hu->%hu width %d->%d\n",
@@ -7137,7 +7137,7 @@ static int ath10k_ampdu_action(struct ieee80211_hw *hw,
 	spin_unlock_bh(&ar->data_lock);
 
 	for (i = 0; i < n_vifs; i++) {
-		arvif = ath10k_vif_to_arvif(vifs[i].vif);
+		arvif = (void *)vifs[i].vif->drv_priv;
 
 		if (WARN_ON(!arvif->is_started))
 			continue;
@@ -7771,7 +7771,7 @@ static void ath10k_get_arvif_iter(void *data, u8 *mac,
 				  struct ieee80211_vif *vif)
 {
 	struct ath10k_vif_iter *arvif_iter = data;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 
 	if (arvif->vdev_id == arvif_iter->vdev_id)
 		arvif_iter->arvif = arvif;
diff --git a/drivers/net/wireless/ath/ath10k/mac.h b/drivers/net/wireless/ath/ath10k/mac.h
index 1bd29ec..553747b 100644
--- a/drivers/net/wireless/ath/ath10k/mac.h
+++ b/drivers/net/wireless/ath/ath10k/mac.h
@@ -83,17 +83,12 @@ struct ieee80211_txq *ath10k_mac_txq_lookup(struct ath10k *ar,
 					    u8 tid);
 int ath10k_mac_ext_resource_config(struct ath10k *ar, u32 val);
 
-static inline struct ath10k_vif *ath10k_vif_to_arvif(struct ieee80211_vif *vif)
-{
-	return (struct ath10k_vif *)vif->drv_priv;
-}
-
 static inline void ath10k_tx_h_seq_no(struct ieee80211_vif *vif,
 				      struct sk_buff *skb)
 {
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *)skb->data;
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 
 	if (info->flags  & IEEE80211_TX_CTL_ASSIGN_SEQ) {
 		if (arvif->tx_seq_no == 0)
diff --git a/drivers/net/wireless/ath/ath10k/p2p.c b/drivers/net/wireless/ath/ath10k/p2p.c
index c0b6ffa..7e621ee 100644
--- a/drivers/net/wireless/ath/ath10k/p2p.c
+++ b/drivers/net/wireless/ath/ath10k/p2p.c
@@ -132,7 +132,7 @@ struct ath10k_p2p_noa_arg {
 static void ath10k_p2p_noa_update_vdev_iter(void *data, u8 *mac,
 					    struct ieee80211_vif *vif)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 	struct ath10k_p2p_noa_arg *arg = data;
 
 	if (arvif->vdev_id != arg->vdev_id)
diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index 50d6ee6..f9fd9f0 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -1772,7 +1772,7 @@ static void ath10k_wmi_tx_beacon_nowait(struct ath10k_vif *arvif)
 static void ath10k_wmi_tx_beacons_iter(void *data, u8 *mac,
 				       struct ieee80211_vif *vif)
 {
-	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
+	struct ath10k_vif *arvif = (void *)vif->drv_priv;
 
 	ath10k_wmi_tx_beacon_nowait(arvif);
 }
-- 
1.9.1
