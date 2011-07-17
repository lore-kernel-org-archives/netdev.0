From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/2] ath6kl: Remove __func__ uses from ath6kl_dbg
Date: Sun, 17 Jul 2011 14:38:56 -0700
Message-ID: <989c61ba57d0ac984b09730f2a7a14a18dd2b97c.1310938421.git.joe@perches.com>
References: <4E2349D4.4000204@qca.qualcomm.com>
Cc: devel@linuxdriverproject.org, gregkh@suse.de, error27@gmail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Kalle Valo <kvalo@qca.qualcomm.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4094 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292Ab1GQVjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 17:39:08 -0400
In-Reply-To: <4E2349D4.4000204@qca.qualcomm.com>
In-Reply-To: <cover.1310938421.git.joe@perches.com>
References: <cover.1310938421.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the ath6kl_dbg uses consistly _not_ use __func__.
Add __func__ to #define ath6kl_dbg.

Remove __func__ from single ath6kl_err.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath6kl/bmi.c      |    4 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c |  101 ++++++++++++---------------
 drivers/net/wireless/ath/ath6kl/debug.c    |   20 +++---
 drivers/net/wireless/ath/ath6kl/debug.h    |   27 ++++----
 drivers/net/wireless/ath/ath6kl/htc.c      |   11 ++--
 drivers/net/wireless/ath/ath6kl/init.c     |    8 +-
 drivers/net/wireless/ath/ath6kl/main.c     |   13 ++--
 drivers/net/wireless/ath/ath6kl/sdio.c     |    8 +-
 drivers/net/wireless/ath/ath6kl/txrx.c     |   30 ++++-----
 drivers/net/wireless/ath/ath6kl/wmi.c      |    8 +--
 10 files changed, 105 insertions(+), 125 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/bmi.c b/drivers/net/wireless/ath/ath6kl/bmi.c
index 8467669..22dd247 100644
--- a/drivers/net/wireless/ath/ath6kl/bmi.c
+++ b/drivers/net/wireless/ath/ath6kl/bmi.c
@@ -407,7 +407,7 @@ int ath6kl_bmi_execute(struct ath6kl *ar, u32 addr, u32 *param)
 	}
 	memset(ar->bmi.cmd_buf, 0, size);
 
-	ath6kl_dbg(ATH6KL_DBG_BMI, "bmi execute: addr: 0x%x, param: %d)\n",
+	ath6kl_dbg(ATH6KL_DBG_BMI, "bmi execute: addr: 0x%x, param: %d\n",
 		   addr, *param);
 
 	offset = 0;
@@ -575,7 +575,7 @@ int ath6kl_bmi_lz_data(struct ath6kl *ar, u8 *buf, u32 len)
 	}
 	memset(ar->bmi.cmd_buf, 0, size);
 
-	ath6kl_dbg(ATH6KL_DBG_BMI, "bmi send LZ data: len: %d)\n",
+	ath6kl_dbg(ATH6KL_DBG_BMI, "bmi send LZ data: len: %d\n",
 		   len);
 
 	len_remain = len;
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 71515bb..6c7970f 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -118,7 +118,7 @@ static struct ieee80211_supported_band ath6kl_band_5ghz = {
 static int ath6kl_set_wpa_version(struct ath6kl *ar,
 				  enum nl80211_wpa_versions wpa_version)
 {
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: %u\n", __func__, wpa_version);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "wpa version: %u\n", wpa_version);
 
 	if (!wpa_version) {
 		ar->auth_mode = NONE_AUTH;
@@ -127,7 +127,7 @@ static int ath6kl_set_wpa_version(struct ath6kl *ar,
 	} else if (wpa_version & NL80211_WPA_VERSION_2) {
 		ar->auth_mode = WPA2_AUTH;
 	} else {
-		ath6kl_err("%s: %u not supported\n", __func__, wpa_version);
+		ath6kl_err("wpa version %u not supported\n", wpa_version);
 		return -ENOTSUPP;
 	}
 
@@ -138,7 +138,7 @@ static int ath6kl_set_auth_type(struct ath6kl *ar,
 				enum nl80211_auth_type auth_type)
 {
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: 0x%x\n", __func__, auth_type);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "auth type: 0x%x\n", auth_type);
 
 	switch (auth_type) {
 	case NL80211_AUTHTYPE_OPEN_SYSTEM:
@@ -158,7 +158,7 @@ static int ath6kl_set_auth_type(struct ath6kl *ar,
 
 	default:
 		ar->dot11_auth_mode = OPEN_AUTH;
-		ath6kl_err("%s: 0x%x not spported\n", __func__, auth_type);
+		ath6kl_err("auth type 0x%x not supported\n", auth_type);
 		return -ENOTSUPP;
 	}
 
@@ -170,8 +170,8 @@ static int ath6kl_set_cipher(struct ath6kl *ar, u32 cipher, bool ucast)
 	u8 *ar_cipher = ucast ? &ar->prwise_crypto : &ar->grp_crypto;
 	u8 *ar_cipher_len = ucast ? &ar->prwise_crypto_len : &ar->grp_crpto_len;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: cipher 0x%x, ucast %u\n",
-		   __func__, cipher, ucast);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "cipher 0x%x, ucast %u\n",
+		   cipher, ucast);
 
 	switch (cipher) {
 	case 0:
@@ -205,7 +205,7 @@ static int ath6kl_set_cipher(struct ath6kl *ar, u32 cipher, bool ucast)
 
 static void ath6kl_set_key_mgmt(struct ath6kl *ar, u32 key_mgmt)
 {
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: 0x%x\n", __func__, key_mgmt);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "set key: 0x%x\n", key_mgmt);
 
 	if (key_mgmt == WLAN_AKM_SUITE_PSK) {
 		if (ar->auth_mode == WPA_AUTH)
@@ -365,10 +365,9 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 	ar->nw_type = ar->next_mode;
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-		   "%s: connect called with authmode %d dot11 auth %d"
+		   "connect called with authmode %d dot11 auth %d"
 		   " PW crypto %d PW crypto len %d GRP crypto %d"
 		   " GRP crypto len %d channel hint %u\n",
-		   __func__,
 		   ar->auth_mode, ar->dot11_auth_mode, ar->prwise_crypto,
 		   ar->prwise_crypto_len, ar->grp_crypto,
 		   ar->grp_crpto_len, ar->ch_hint);
@@ -447,7 +446,7 @@ void ath6kl_cfg80211_connect_event(struct ath6kl *ar, u16 channel,
 	if (nw_type & ADHOC_NETWORK) {
 		if (ar->wdev->iftype != NL80211_IFTYPE_ADHOC) {
 			ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-				   "%s: ath6k not in ibss mode\n", __func__);
+				   "ath6k not in ibss mode\n");
 			return;
 		}
 	}
@@ -455,7 +454,7 @@ void ath6kl_cfg80211_connect_event(struct ath6kl *ar, u16 channel,
 	if (nw_type & INFRA_NETWORK) {
 		if (ar->wdev->iftype != NL80211_IFTYPE_STATION) {
 			ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-				   "%s: ath6k not in station mode\n", __func__);
+				   "ath6k not in station mode\n");
 			return;
 		}
 	}
@@ -545,9 +544,8 @@ void ath6kl_cfg80211_connect_event(struct ath6kl *ar, u16 channel,
 	ibss_ch = ieee80211_get_channel(ar->wdev->wiphy, (int)channel);
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-		   "%s: inform bss with bssid %pM channel %d beacon_intvl %d capability 0x%x\n",
-		   __func__, mgmt->bssid, ibss_ch->hw_value,
-		   beacon_intvl, capability);
+		   "inform bss with bssid %pM channel %d beacon_intvl %d capability 0x%x\n",
+		   mgmt->bssid, ibss_ch->hw_value, beacon_intvl, capability);
 
 	bss = cfg80211_inform_bss_frame(ar->wdev->wiphy,
 					ibss_ch, mgmt,
@@ -580,8 +578,7 @@ static int ath6kl_cfg80211_disconnect(struct wiphy *wiphy,
 {
 	struct ath6kl *ar = (struct ath6kl *)ath6kl_priv(dev);
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: reason=%u\n", __func__,
-		   reason_code);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "disconnect reason=%u\n", reason_code);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
@@ -624,7 +621,7 @@ void ath6kl_cfg80211_disconnect_event(struct ath6kl *ar, u8 reason,
 	if (ar->nw_type & ADHOC_NETWORK) {
 		if (ar->wdev->iftype != NL80211_IFTYPE_ADHOC) {
 			ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-				   "%s: ath6k not in ibss mode\n", __func__);
+				   "ath6k not in ibss mode\n");
 			return;
 		}
 		memset(bssid, 0, ETH_ALEN);
@@ -635,7 +632,7 @@ void ath6kl_cfg80211_disconnect_event(struct ath6kl *ar, u8 reason,
 	if (ar->nw_type & INFRA_NETWORK) {
 		if (ar->wdev->iftype != NL80211_IFTYPE_STATION) {
 			ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-				   "%s: ath6k not in station mode\n", __func__);
+				   "ath6k not in station mode\n");
 			return;
 		}
 	}
@@ -767,7 +764,7 @@ static void ath6kl_cfg80211_scan_node(void *arg, struct bss *ni)
 	signal = ni->ni_snr * 100;
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-		   "%s: bssid %pM ch %d freq %d size %d\n", __func__,
+		   "bssid %pM ch %d freq %d size %d\n",
 		   mgmt->bssid, channel->hw_value, freq, size);
 	cfg80211_inform_bss_frame(wiphy, channel, mgmt,
 				  size, signal, GFP_KERNEL);
@@ -825,7 +822,7 @@ static int ath6kl_cfg80211_scan(struct wiphy *wiphy, struct net_device *ndev,
 void ath6kl_cfg80211_scan_complete_event(struct ath6kl *ar, int status)
 {
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: status %d\n", __func__, status);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "scan complete status %d\n", status);
 
 	if (ar->scan_req) {
 		/* Translate data to cfg80211 mgmt format */
@@ -864,8 +861,7 @@ static int ath6kl_cfg80211_add_key(struct wiphy *wiphy, struct net_device *ndev,
 		return -EIO;
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-			   "%s: key index %d out of bounds\n", __func__,
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "key index %d out of bounds\n",
 			   key_index);
 		return -ENOENT;
 	}
@@ -914,9 +910,8 @@ static int ath6kl_cfg80211_add_key(struct wiphy *wiphy, struct net_device *ndev,
 		del_timer(&ar->disconnect_timer);
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-		   "%s: index %d, key_len %d, key_type 0x%x, key_usage 0x%x, seq_len %d\n",
-		   __func__, key_index, key->key_len, key_type,
-		   key_usage, key->seq_len);
+		   "index %d, key_len %d, key_type 0x%x, key_usage 0x%x, seq_len %d\n",
+		   key_index, key->key_len, key_type, key_usage, key->seq_len);
 
 	ar->def_txkey_index = key_index;
 	status = ath6kl_wmi_addkey_cmd(ar->wmi, ar->def_txkey_index,
@@ -936,21 +931,20 @@ static int ath6kl_cfg80211_del_key(struct wiphy *wiphy, struct net_device *ndev,
 {
 	struct ath6kl *ar = (struct ath6kl *)ath6kl_priv(ndev);
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "del key index %d\n", key_index);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-			   "%s: key index %d out of bounds\n", __func__,
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "key index %d out of bounds\n",
 			   key_index);
 		return -ENOENT;
 	}
 
 	if (!ar->keys[key_index].key_len) {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-			   "%s: index %d is empty\n", __func__, key_index);
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "key index %d is empty\n",
+			   key_index);
 		return 0;
 	}
 
@@ -969,14 +963,13 @@ static int ath6kl_cfg80211_get_key(struct wiphy *wiphy, struct net_device *ndev,
 	struct ath6kl_key *key = NULL;
 	struct key_params params;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "key index %d\n", key_index);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-			   "%s: key index %d out of bounds\n", __func__,
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "key index %d out of bounds\n",
 			   key_index);
 		return -ENOENT;
 	}
@@ -1004,21 +997,20 @@ static int ath6kl_cfg80211_set_default_key(struct wiphy *wiphy,
 	int status = 0;
 	u8 key_usage;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "default key index %d\n", key_index);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
 
 	if (key_index < WMI_MIN_KEY_INDEX || key_index > WMI_MAX_KEY_INDEX) {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-			   "%s: key index %d out of bounds\n",
-			   __func__, key_index);
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "key index %d out of bounds\n",
+			   key_index);
 		return -ENOENT;
 	}
 
 	if (!ar->keys[key_index].key_len) {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: invalid key index %d\n",
-			   __func__, key_index);
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "invalid key index %d\n",
+			   key_index);
 		return -EINVAL;
 	}
 
@@ -1045,20 +1037,20 @@ static int ath6kl_cfg80211_set_default_mgmt_key(struct wiphy *wiphy,
 {
 	struct ath6kl *ar = (struct ath6kl *)ath6kl_priv(ndev);
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "mgmt index %d\n", key_index);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: not supported\n", __func__);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "mgnt index not supported\n");
 	return -ENOTSUPP;
 }
 
 void ath6kl_cfg80211_tkip_micerr_event(struct ath6kl *ar, u8 keyid,
 				       bool ismcast)
 {
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-		   "%s: keyid %d, ismcast %d\n", __func__, keyid, ismcast);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "keyid %d, ismcast %d\n",
+		   keyid, ismcast);
 
 	cfg80211_michael_mic_failure(ar->net_dev, ar->bssid,
 				     (ismcast ? NL80211_KEYTYPE_GROUP :
@@ -1071,8 +1063,7 @@ static int ath6kl_cfg80211_set_wiphy_params(struct wiphy *wiphy, u32 changed)
 	struct ath6kl *ar = (struct ath6kl *)wiphy_priv(wiphy);
 	int ret;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: changed 0x%x\n", __func__,
-		   changed);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "wiphy changed 0x%x\n", changed);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
@@ -1099,8 +1090,7 @@ static int ath6kl_cfg80211_set_txpower(struct wiphy *wiphy,
 	struct ath6kl *ar = (struct ath6kl *)wiphy_priv(wiphy);
 	u8 ath6kl_dbm;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: type 0x%x, dbm %d\n", __func__,
-		   type, dbm);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "type 0x%x, dbm %d\n", type, dbm);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
@@ -1112,8 +1102,8 @@ static int ath6kl_cfg80211_set_txpower(struct wiphy *wiphy,
 		ar->tx_pwr = ath6kl_dbm = dbm;
 		break;
 	default:
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: type 0x%x not supported\n",
-			   __func__, type);
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "type 0x%x not supported\n",
+			   type);
 		return -EOPNOTSUPP;
 	}
 
@@ -1157,17 +1147,17 @@ static int ath6kl_cfg80211_set_power_mgmt(struct wiphy *wiphy,
 	struct ath6kl *ar = ath6kl_priv(dev);
 	struct wmi_power_mode_cmd mode;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: pmgmt %d, timeout %d\n",
-		   __func__, pmgmt, timeout);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "pmgmt %d, timeout %d\n",
+		   pmgmt, timeout);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
 
 	if (pmgmt) {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: max perf\n", __func__);
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "max perf\n");
 		mode.pwr_mode = REC_POWER;
 	} else {
-		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: rec power\n", __func__);
+		ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "rec power\n");
 		mode.pwr_mode = MAX_PERF_POWER;
 	}
 
@@ -1187,7 +1177,7 @@ static int ath6kl_cfg80211_change_iface(struct wiphy *wiphy,
 	struct ath6kl *ar = ath6kl_priv(ndev);
 	struct wireless_dev *wdev = ar->wdev;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: type %u\n", __func__, type);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "iface type %u\n", type);
 
 	if (!ath6kl_cfg80211_ready(ar))
 		return -EIO;
@@ -1258,10 +1248,9 @@ static int ath6kl_cfg80211_join_ibss(struct wiphy *wiphy,
 	ar->nw_type = ar->next_mode;
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-		   "%s: connect called with authmode %d dot11 auth %d"
+		   "connect called with authmode %d dot11 auth %d"
 		   " PW crypto %d PW crypto len %d GRP crypto %d"
 		   " GRP crypto len %d channel hint %u\n",
-		   __func__,
 		   ar->auth_mode, ar->dot11_auth_mode, ar->prwise_crypto,
 		   ar->prwise_crypto_len, ar->grp_crypto,
 		   ar->grp_crpto_len, ar->ch_hint);
diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index 316136c..b30d583 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -41,33 +41,33 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
 			   struct ath6kl_irq_enable_reg *irq_enable_reg)
 {
 
-	ath6kl_dbg(ATH6KL_DBG_ANY, ("<------- Register Table -------->\n"));
+	ath6kl_dbg(ATH6KL_DBG_ANY, "<------- Register Table -------->\n");
 
 	if (irq_proc_reg != NULL) {
 		ath6kl_dbg(ATH6KL_DBG_ANY,
-			"Host Int status:           0x%x\n",
-			irq_proc_reg->host_int_status);
+			   "Host Int status:           0x%x\n",
+			   irq_proc_reg->host_int_status);
 		ath6kl_dbg(ATH6KL_DBG_ANY,
 			   "CPU Int status:            0x%x\n",
-			irq_proc_reg->cpu_int_status);
+			   irq_proc_reg->cpu_int_status);
 		ath6kl_dbg(ATH6KL_DBG_ANY,
 			   "Error Int status:          0x%x\n",
-			irq_proc_reg->error_int_status);
+			   irq_proc_reg->error_int_status);
 		ath6kl_dbg(ATH6KL_DBG_ANY,
 			   "Counter Int status:        0x%x\n",
-			irq_proc_reg->counter_int_status);
+			   irq_proc_reg->counter_int_status);
 		ath6kl_dbg(ATH6KL_DBG_ANY,
 			   "Mbox Frame:                0x%x\n",
-			irq_proc_reg->mbox_frame);
+			   irq_proc_reg->mbox_frame);
 		ath6kl_dbg(ATH6KL_DBG_ANY,
 			   "Rx Lookahead Valid:        0x%x\n",
-			irq_proc_reg->rx_lkahd_valid);
+			   irq_proc_reg->rx_lkahd_valid);
 		ath6kl_dbg(ATH6KL_DBG_ANY,
 			   "Rx Lookahead 0:            0x%x\n",
-			irq_proc_reg->rx_lkahd[0]);
+			   irq_proc_reg->rx_lkahd[0]);
 		ath6kl_dbg(ATH6KL_DBG_ANY,
 			   "Rx Lookahead 1:            0x%x\n",
-			irq_proc_reg->rx_lkahd[1]);
+			   irq_proc_reg->rx_lkahd[1]);
 
 		if (dev->ar->mbox_info.gmbox_addr != 0) {
 			/*
diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
index 2e60588..ece20c9 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.h
+++ b/drivers/net/wireless/ath/ath6kl/debug.h
@@ -42,7 +42,7 @@ extern unsigned int debug_mask;
 extern int ath6kl_printk(const char *level, const char *fmt, ...)
 	__attribute__ ((format (printf, 2, 3)));
 
-#define ath6kl_info(fmt, ...)				\
+#define ath6kl_info(fmt, ...)					\
 	ath6kl_printk(KERN_INFO, fmt, ##__VA_ARGS__)
 #define ath6kl_err(fmt, ...)					\
 	ath6kl_printk(KERN_ERR, fmt, ##__VA_ARGS__)
@@ -52,16 +52,17 @@ extern int ath6kl_printk(const char *level, const char *fmt, ...)
 #define AR_DBG_LVL_CHECK(mask)	(debug_mask & mask)
 
 #ifdef CONFIG_ATH6KL_DEBUG
-#define ath6kl_dbg(mask, fmt, ...)					\
-	({								\
-	 int rtn;							\
-	 if (debug_mask & mask)						\
-		rtn = ath6kl_printk(KERN_DEBUG, fmt, ##__VA_ARGS__);	\
-	 else								\
-		rtn = 0;						\
-									\
-	 rtn;								\
-	 })
+#define ath6kl_dbg(mask, fmt, ...)				\
+({								\
+	 int rtn;						\
+	 if (debug_mask & mask)					\
+		 rtn = ath6kl_printk(KERN_DEBUG, "%s: " fmt,	\
+				     __func__, ##__VA_ARGS__);	\
+	 else							\
+		 rtn = 0;					\
+								\
+	 rtn;							\
+})
 
 static inline void ath6kl_dbg_dump(enum ATH6K_DEBUG_MASK mask,
 				   const char *msg, const void *buf,
@@ -78,8 +79,8 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
 			   struct ath6kl_irq_enable_reg *irq_en_reg);
 void dump_cred_dist_stats(struct htc_target *target);
 #else
-static inline int ath6kl_dbg(enum ATH6K_DEBUG_MASK dbg_mask,
-			     const char *fmt, ...)
+static inline __attribute__ ((format (printf, 2, 3)))
+int ath6kl_dbg(enum ATH6K_DEBUG_MASK dbg_mask, const char *fmt, ...)
 {
 	return 0;
 }
diff --git a/drivers/net/wireless/ath/ath6kl/htc.c b/drivers/net/wireless/ath/ath6kl/htc.c
index 95c47bb..ab651fb 100644
--- a/drivers/net/wireless/ath/ath6kl/htc.c
+++ b/drivers/net/wireless/ath/ath6kl/htc.c
@@ -175,16 +175,15 @@ static int htc_issue_send(struct htc_target *target, struct htc_packet *packet)
 
 	send_len = packet->act_len + HTC_HDR_LENGTH;
 
-	ath6kl_dbg(ATH6KL_DBG_HTC_SEND, "%s: transmit len : %d (%s)\n",
-		   __func__, send_len, sync ? "sync" : "async");
+	ath6kl_dbg(ATH6KL_DBG_HTC_SEND, "transmit len : %d (%s)\n",
+		   send_len, sync ? "sync" : "async");
 
 	padded_len = CALC_TXRX_PADDED_LEN(target->dev, send_len);
 
 	ath6kl_dbg(ATH6KL_DBG_HTC_SEND,
-		"DevSendPacket, padded len: %d mbox:0x%X (mode:%s)\n",
-		padded_len,
-		target->dev->ar->mbox_info.htc_addr,
-		sync ? "sync" : "async");
+		   "DevSendPacket, padded len: %d mbox:0x%X (mode:%s)\n",
+		   padded_len, target->dev->ar->mbox_info.htc_addr,
+		   sync ? "sync" : "async");
 
 	if (sync) {
 		status = hif_read_write_sync(target->dev->ar,
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index fe61871..a8f4452 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -1060,7 +1060,7 @@ static int ath6kl_init(struct net_device *dev)
 		goto ath6kl_init_done;
 	}
 
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: got wmi @ 0x%p.\n", __func__, ar->wmi);
+	ath6kl_dbg(ATH6KL_DBG_TRC, "got wmi @ 0x%p\n", ar->wmi);
 
 	/*
 	 * The reason we have to wait for the target here is that the
@@ -1122,7 +1122,7 @@ static int ath6kl_init(struct net_device *dev)
 		goto err_htc_stop;
 	}
 
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: wmi is ready\n", __func__);
+	ath6kl_dbg(ATH6KL_DBG_TRC, "wmi is ready\n");
 
 	/* communicate the wmi protocol verision to the target */
 	if ((ath6kl_set_host_app_area(ar)) != 0)
@@ -1208,8 +1208,8 @@ int ath6kl_core_init(struct ath6kl *ar)
 
 	set_bit(NETDEV_REGISTERED, &ar->flag);
 
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: name=%s dev=0x%p, ar=0x%p\n",
-			__func__, ar->net_dev->name, ar->net_dev, ar);
+	ath6kl_dbg(ATH6KL_DBG_TRC, "name=%s dev=0x%p, ar=0x%p\n",
+		   ar->net_dev->name, ar->net_dev, ar);
 
 	return ret;
 
diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index f325a23..6ef26a3 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -359,14 +359,12 @@ void ath6kl_stop_endpoint(struct net_device *dev, bool keep_profile,
 		ar->user_key_ctrl = 0;
 
 	} else {
-		ath6kl_dbg(ATH6KL_DBG_TRC,
-			   "%s: wmi is not ready 0x%p 0x%p\n",
-			   __func__, ar, ar->wmi);
+		ath6kl_dbg(ATH6KL_DBG_TRC, "wmi is not ready 0x%p 0x%p\n",
+			   ar, ar->wmi);
 
 		/* Shut down WMI if we have started it */
 		if (test_bit(WMI_ENABLED, &ar->flag)) {
-			ath6kl_dbg(ATH6KL_DBG_TRC,
-				   "%s: shut down wmi\n", __func__);
+			ath6kl_dbg(ATH6KL_DBG_TRC, "shut down wmi\n");
 			ath6kl_wmi_shutdown(ar->wmi);
 			clear_bit(WMI_ENABLED, &ar->flag);
 			ar->wmi = NULL;
@@ -374,7 +372,7 @@ void ath6kl_stop_endpoint(struct net_device *dev, bool keep_profile,
 	}
 
 	if (ar->htc_target) {
-		ath6kl_dbg(ATH6KL_DBG_TRC, "%s: shut down htc\n", __func__);
+		ath6kl_dbg(ATH6KL_DBG_TRC, "shut down htc\n");
 		htc_stop(ar->htc_target);
 	}
 
@@ -801,8 +799,7 @@ void ath6kl_ready_event(void *devt, u8 *datap, u32 sw_ver, u32 abi_ver)
 	struct net_device *dev = ar->net_dev;
 
 	memcpy(dev->dev_addr, datap, ETH_ALEN);
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: mac addr = %pM\n",
-		   __func__, dev->dev_addr);
+	ath6kl_dbg(ATH6KL_DBG_TRC, "mac addr = %pM\n", dev->dev_addr);
 
 	ar->version.wlan_ver = sw_ver;
 	ar->version.abi_ver = abi_ver;
diff --git a/drivers/net/wireless/ath/ath6kl/sdio.c b/drivers/net/wireless/ath/ath6kl/sdio.c
index b38732a..c58a107 100644
--- a/drivers/net/wireless/ath/ath6kl/sdio.c
+++ b/drivers/net/wireless/ath/ath6kl/sdio.c
@@ -145,7 +145,7 @@ static struct bus_request *ath6kl_sdio_alloc_busreq(struct ath6kl_sdio *ar_sdio)
 	list_del(&bus_req->list);
 
 	spin_unlock_irqrestore(&ar_sdio->lock, flag);
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: bus request 0x%p\n", __func__, bus_req);
+	ath6kl_dbg(ATH6KL_DBG_TRC, "bus request 0x%p\n", bus_req);
 
 	return bus_req;
 }
@@ -155,7 +155,7 @@ static void ath6kl_sdio_free_bus_req(struct ath6kl_sdio *ar_sdio,
 {
 	unsigned long flag;
 
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: bus request 0x%p\n", __func__, bus_req);
+	ath6kl_dbg(ATH6KL_DBG_TRC, "bus request 0x%p\n", bus_req);
 
 	spin_lock_irqsave(&ar_sdio->lock, flag);
 	list_add_tail(&bus_req->list, &ar_sdio->bus_req_freeq);
@@ -683,8 +683,8 @@ static int ath6kl_sdio_probe(struct sdio_func *func,
 	int count;
 
 	ath6kl_dbg(ATH6KL_DBG_TRC,
-		   "%s: func: 0x%X, vendor id: 0x%X, dev id: 0x%X, block size: 0x%X/0x%X\n",
-		   __func__, func->num, func->vendor,
+		   "func: 0x%X, vendor id: 0x%X, dev id: 0x%X, block size: 0x%X/0x%X\n",
+		   func->num, func->vendor,
 		   func->device, func->max_blksize, func->cur_blksize);
 
 	ar_sdio = kzalloc(sizeof(struct ath6kl_sdio), GFP_KERNEL);
diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index 615b46d..e2e3673 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -184,8 +184,7 @@ int ath6kl_control_tx(void *devt, struct sk_buff *skb,
 
 	spin_lock_bh(&ar->lock);
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
-		   "%s: skb=0x%p, len=0x%x eid =%d\n", __func__,
+	ath6kl_dbg(ATH6KL_DBG_WLAN_TX, "skb=0x%p, len=0x%x eid=%d\n",
 		   skb, skb->len, eid);
 
 	if (test_bit(WMI_CTRL_EP_FULL, &ar->flag) && (eid == ar->ctrl_ep)) {
@@ -242,8 +241,7 @@ int ath6kl_data_tx(struct sk_buff *skb, struct net_device *dev)
 	struct wmi_tx_meta_v2 meta_v2;
 	int ret;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
-		   "%s: skb=0x%p, data=0x%p, len=0x%x\n", __func__,
+	ath6kl_dbg(ATH6KL_DBG_WLAN_TX, "skb=0x%p, data=0x%p, len=0x%x\n",
 		   skb, skb->data, skb->len);
 
 	/* If target is not associated */
@@ -563,13 +561,13 @@ void ath6kl_tx_complete(void *context, struct list_head *packet_queue)
 			if (status != -ENOSPC)
 				ath6kl_err("tx error, status: 0x%x\n", status);
 			ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
-				   "%s: skb=0x%p data=0x%p len=0x%x eid=%d %s\n",
-				   __func__, skb, packet->buf, packet->act_len,
+				   "skb=0x%p data=0x%p len=0x%x eid=%d %s\n",
+				   skb, packet->buf, packet->act_len,
 				   eid, "error!");
 		} else {
 			ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
-				   "%s: skb=0x%p data=0x%p len=0x%x eid=%d %s\n",
-				   __func__, skb, packet->buf, packet->act_len,
+				   "skb=0x%p data=0x%p len=0x%x eid=%d %s\n",
+				   skb, packet->buf, packet->act_len,
 				   eid, "OK");
 
 			flushing = false;
@@ -680,8 +678,8 @@ void ath6kl_rx_refill(struct htc_target *target, enum htc_endpoint_id endpoint)
 	INIT_LIST_HEAD(&queue);
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_RX,
-		   "%s: providing htc with %d buffers at eid=%d\n",
-		   __func__, n_buf_refill, endpoint);
+		   "providing htc with %d buffers at eid=%d\n",
+		   n_buf_refill, endpoint);
 
 	for (rx_buf = 0; rx_buf < n_buf_refill; rx_buf++) {
 		skb = ath6kl_buf_alloc(ATH6KL_BUFFER_SIZE);
@@ -731,8 +729,7 @@ struct htc_packet *ath6kl_alloc_amsdu_rxbuf(struct htc_target *target,
 	struct list_head *pkt_pos;
 	int refill_cnt = 0, depth = 0;
 
-	ath6kl_dbg(ATH6KL_DBG_WLAN_RX, "%s: eid=%d, len:%d\n",
-		   __func__, endpoint, len);
+	ath6kl_dbg(ATH6KL_DBG_WLAN_RX, "eid=%d, len:%d\n", endpoint, len);
 
 	if ((len <= ATH6KL_BUFFER_SIZE) ||
 	    (len > ATH6KL_AMSDU_BUFFER_SIZE))
@@ -1025,9 +1022,8 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 	u8 tid;
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_RX,
-		   "%s: ar=0x%p eid=%d, skb=0x%p, data=0x%p, len=0x%x status:%d",
-		   __func__, ar, ept, skb, packet->buf,
-		   packet->act_len, status);
+		   "ar=0x%p eid=%d, skb=0x%p, data=0x%p, len=0x%x status:%d\n",
+		   ar, ept, skb, packet->buf, packet->act_len, status);
 
 	if (status || !(skb->data + HTC_HDR_LENGTH)) {
 		ar->net_stats.rx_errors++;
@@ -1324,8 +1320,8 @@ void aggr_recv_addba_req_evt(struct ath6kl *ar, u8 tid, u16 seq_no, u8 win_sz)
 	stats = &p_aggr->stat[tid];
 
 	if (win_sz < AGGR_WIN_SZ_MIN || win_sz > AGGR_WIN_SZ_MAX)
-		ath6kl_dbg(ATH6KL_DBG_WLAN_RX, "%s: win_sz %d, tid %d\n",
-			   __func__, win_sz, tid);
+		ath6kl_dbg(ATH6KL_DBG_WLAN_RX, "win_sz %d, tid %d\n",
+			   win_sz, tid);
 
 	if (rxtid->aggr)
 		aggr_delete_tid_state(p_aggr, tid);
diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index a52d7d2..29790e5 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -102,8 +102,7 @@ int ath6kl_wmi_dix_2_dot3(struct wmi *wmi, struct sk_buff *skb)
 	type = eth_hdr->h_proto;
 
 	if (!is_ethertype(be16_to_cpu(type))) {
-		ath6kl_dbg(ATH6KL_DBG_WMI,
-			"%s: pkt is already in 802.3 format\n", __func__);
+		ath6kl_dbg(ATH6KL_DBG_WMI, "pkt is already in 802.3 format\n");
 		return 0;
 	}
 
@@ -496,8 +495,7 @@ static int ath6kl_wmi_connect_event_rx(struct wmi *wmi, u8 *datap, int len)
 
 	ev = (struct wmi_connect_event *) datap;
 
-	ath6kl_dbg(ATH6KL_DBG_WMI, "%s: freq %d bssid %pM\n",
-		   __func__, ev->ch, ev->bssid);
+	ath6kl_dbg(ATH6KL_DBG_WMI, "freq %d bssid %pM\n", ev->ch, ev->bssid);
 
 	memcpy(wmi->bssid, ev->bssid, ETH_ALEN);
 
@@ -2545,7 +2543,7 @@ int ath6kl_wmi_control_rx(struct wmi *wmi, struct sk_buff *skb)
 	datap = skb->data;
 	len = skb->len;
 
-	ath6kl_dbg(ATH6KL_DBG_WMI, "%s: wmi id: %d\n", __func__, id);
+	ath6kl_dbg(ATH6KL_DBG_WMI, "wmi id: %d\n", id);
 	ath6kl_dbg_dump(ATH6KL_DBG_RAW_BYTES, "msg payload ", datap, len);
 
 	switch (id) {
-- 
1.7.6.131.g99019

