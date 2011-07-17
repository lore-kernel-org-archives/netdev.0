From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/3] ath6kl: Remove __func__ uses from ath6kl_err
Date: Sun, 17 Jul 2011 11:43:43 -0700
Message-ID: <e835f257239b40e651b99d73dcdf2fc9f9eaf2fb.1310927985.git.joe@perches.com>
References: <cover.1310927985.git.joe@perches.com>
Cc: devel@linuxdriverproject.org, gregkh@suse.de, error27@gmail.com,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1310927985.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary clutter from ath6kl_err messages.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath6kl/bmi.c      |    2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c |  129 +++++++++++++--------------
 drivers/net/wireless/ath/ath6kl/htc.c      |    7 +-
 drivers/net/wireless/ath/ath6kl/htc_hif.c  |    3 +-
 drivers/net/wireless/ath/ath6kl/init.c     |   78 +++++++----------
 drivers/net/wireless/ath/ath6kl/main.c     |   16 ++--
 drivers/net/wireless/ath/ath6kl/txrx.c     |   39 ++++-----
 drivers/net/wireless/ath/ath6kl/wmi.c      |    8 +-
 8 files changed, 125 insertions(+), 157 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/bmi.c b/drivers/net/wireless/ath/ath6kl/bmi.c
index 1aed4f1..8467669 100644
--- a/drivers/net/wireless/ath/ath6kl/bmi.c
+++ b/drivers/net/wireless/ath/ath6kl/bmi.c
@@ -55,7 +55,7 @@ static int ath6kl_get_bmi_cmd_credits(struct ath6kl *ar)
 	}
 
 	if (!ar->bmi.cmd_credits) {
-		ath6kl_err("%s bmi communication timeout\n", __func__);
+		ath6kl_err("bmi communication timeout\n");
 		return -ETIMEDOUT;
 	}
 
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index f556e23..34df184 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -196,7 +196,7 @@ static int ath6kl_set_cipher(struct ath6kl *ar, u32 cipher, bool ucast)
 		*ar_cipher_len = 0;
 		break;
 	default:
-		ath6kl_err("%s: cipher 0x%x not supported\n", __func__, cipher);
+		ath6kl_err("cipher 0x%x not supported\n", cipher);
 		return -ENOTSUPP;
 	}
 
@@ -226,40 +226,39 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 	ar->sme_state = SME_CONNECTING;
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready yet\n", __func__);
+		ath6kl_err("wmi is not ready yet\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
 	if (test_bit(DESTROY_IN_PROGRESS, &ar->flag)) {
-		ath6kl_err("%s: destroy in progress\n", __func__);
+		ath6kl_err("destroy in progress\n");
 		return -EBUSY;
 	}
 
 	if (!sme->ssid_len || sme->ssid_len > IEEE80211_MAX_SSID_LEN) {
-		ath6kl_err("%s: ssid invalid\n", __func__);
+		ath6kl_err("ssid invalid\n");
 		return -EINVAL;
 	}
 
 	if (test_bit(SKIP_SCAN, &ar->flag) &&
 	    ((sme->channel && sme->channel->center_freq == 0) ||
 	     (sme->bssid && is_zero_ether_addr(sme->bssid)))) {
-		ath6kl_err("%s: SkipScan: channel or bssid invalid\n",
-			   __func__);
+		ath6kl_err("SkipScan: channel or bssid invalid\n");
 		return -EINVAL;
 	}
 
 	if (down_interruptible(&ar->sem)) {
-		ath6kl_err("%s: busy, couldn't get access\n", __func__);
+		ath6kl_err("busy, couldn't get access\n");
 		return -ERESTARTSYS;
 	}
 
 	if (test_bit(DESTROY_IN_PROGRESS, &ar->flag)) {
-		ath6kl_err("%s: busy, destroy in progress\n", __func__);
+		ath6kl_err("busy, destroy in progress\n");
 		up(&ar->sem);
 		return -EBUSY;
 	}
@@ -272,7 +271,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 			ar->tx_pending[ath6kl_wmi_get_control_ep(ar->wmi)] == 0,
 			WMI_TIMEOUT);
 		if (signal_pending(current)) {
-			ath6kl_err("%s: cmd queue drain timeout\n", __func__);
+			ath6kl_err("cmd queue drain timeout\n");
 			up(&ar->sem);
 			return -EINTR;
 		}
@@ -287,7 +286,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 
 		up(&ar->sem);
 		if (status) {
-			ath6kl_err("%s: wmi_reconnect_cmd failed\n", __func__);
+			ath6kl_err("wmi_reconnect_cmd failed\n");
 			return -EIO;
 		}
 		return 0;
@@ -326,8 +325,8 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 
 		if (sme->key_idx < WMI_MIN_KEY_INDEX ||
 		    sme->key_idx > WMI_MAX_KEY_INDEX) {
-			ath6kl_err("%s: key index %d out of bounds\n",
-				   __func__, sme->key_idx);
+			ath6kl_err("key index %d out of bounds\n",
+				   sme->key_idx);
 			up(&ar->sem);
 			return -ENOENT;
 		}
@@ -349,8 +348,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	if (!ar->usr_bss_filter) {
 		if (ath6kl_wmi_bssfilter_cmd(ar->wmi, ALL_BSS_FILTER, 0) != 0) {
-			ath6kl_err("%s: couldn't set bss filtering\n",
-				   __func__);
+			ath6kl_err("couldn't set bss filtering\n");
 			up(&ar->sem);
 			return -EIO;
 		}
@@ -382,10 +380,10 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 	if (status == -EINVAL) {
 		memset(ar->ssid, 0, sizeof(ar->ssid));
 		ar->ssid_len = 0;
-		ath6kl_err("%s: invalid request\n", __func__);
+		ath6kl_err("invalid request\n");
 		return -ENOENT;
 	} else if (status) {
-		ath6kl_err("%s: ath6kl_wmi_connect_cmd failed\n", __func__);
+		ath6kl_err("ath6kl_wmi_connect_cmd failed\n");
 		return -EIO;
 	}
 
@@ -521,7 +519,7 @@ void ath6kl_cfg80211_connect_event(struct ath6kl *ar, u16 channel,
 
 	ieeemgmtbuf = kzalloc(size, GFP_ATOMIC);
 	if (!ieeemgmtbuf) {
-		ath6kl_err("%s: ieee mgmt buf alloc error\n", __func__);
+		ath6kl_err("ieee mgmt buf alloc error\n");
 		cfg80211_put_bss(bss);
 		return;
 	}
@@ -578,22 +576,22 @@ static int ath6kl_cfg80211_disconnect(struct wiphy *wiphy,
 		   reason_code);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
 	if (test_bit(DESTROY_IN_PROGRESS, &ar->flag)) {
-		ath6kl_err("%s: busy, destroy in progress\n", __func__);
+		ath6kl_err("busy, destroy in progress\n");
 		return -EBUSY;
 	}
 
 	if (down_interruptible(&ar->sem)) {
-		ath6kl_err("%s: busy, couldn't get access\n", __func__);
+		ath6kl_err("busy, couldn't get access\n");
 		return -ERESTARTSYS;
 	}
 
@@ -685,7 +683,7 @@ void ath6kl_cfg80211_disconnect_event(struct ath6kl *ar, u8 reason,
 	 */
 	key = &ar->keys[ar->def_txkey_index];
 	if (down_interruptible(&ar->sem)) {
-		ath6kl_err("%s: busy, couldn't get access\n", __func__);
+		ath6kl_err("busy, couldn't get access\n");
 		return;
 	}
 
@@ -746,7 +744,7 @@ static void ath6kl_cfg80211_scan_node(void *arg, struct bss *ni)
 	size = ni->ni_framelen + offsetof(struct ieee80211_mgmt, u);
 	ieeemgmtbuf = kmalloc(size, GFP_ATOMIC);
 	if (!ieeemgmtbuf) {
-		ath6kl_err("%s: ieee mgmt buf alloc error\n", __func__);
+		ath6kl_err("ieee mgmt buf alloc error\n");
 		return;
 	}
 
@@ -784,12 +782,12 @@ static int ath6kl_cfg80211_scan(struct wiphy *wiphy, struct net_device *ndev,
 	u32 force_fg_scan = 0;
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -798,8 +796,7 @@ static int ath6kl_cfg80211_scan(struct wiphy *wiphy, struct net_device *ndev,
 					     (test_bit(CONNECTED, &ar->flag) ?
 					     ALL_BUT_BSS_FILTER :
 					     ALL_BSS_FILTER), 0) != 0) {
-			ath6kl_err("%s: couldn't set bss filtering\n",
-				   __func__);
+			ath6kl_err("couldn't set bss filtering\n");
 			return -EIO;
 		}
 	}
@@ -822,7 +819,7 @@ static int ath6kl_cfg80211_scan(struct wiphy *wiphy, struct net_device *ndev,
 
 	if (ath6kl_wmi_startscan_cmd(ar->wmi, WMI_LONG_SCAN, force_fg_scan,
 				     false, 0, 0, 0, NULL) != 0) {
-		ath6kl_err("%s: wmi_startscan_cmd failed\n", __func__);
+		ath6kl_err("wmi_startscan_cmd failed\n");
 		ret = -EIO;
 	}
 
@@ -870,12 +867,12 @@ static int ath6kl_cfg80211_add_key(struct wiphy *wiphy, struct net_device *ndev,
 	int status = 0;
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -955,12 +952,12 @@ static int ath6kl_cfg80211_del_key(struct wiphy *wiphy, struct net_device *ndev,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -995,12 +992,12 @@ static int ath6kl_cfg80211_get_key(struct wiphy *wiphy, struct net_device *ndev,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1037,12 +1034,12 @@ static int ath6kl_cfg80211_set_default_key(struct wiphy *wiphy,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1085,12 +1082,12 @@ static int ath6kl_cfg80211_set_default_mgmt_key(struct wiphy *wiphy,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: index %d\n", __func__, key_index);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1119,20 +1116,19 @@ static int ath6kl_cfg80211_set_wiphy_params(struct wiphy *wiphy, u32 changed)
 		   changed);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
 	if (changed & WIPHY_PARAM_RTS_THRESHOLD) {
 		ret = ath6kl_wmi_set_rts_cmd(ar->wmi, wiphy->rts_threshold);
 		if (ret != 0) {
-			ath6kl_err("%s: ath6kl_wmi_set_rts_cmd failed\n",
-				   __func__);
+			ath6kl_err("ath6kl_wmi_set_rts_cmd failed\n");
 			return -EIO;
 		}
 	}
@@ -1155,12 +1151,12 @@ static int ath6kl_cfg80211_set_txpower(struct wiphy *wiphy,
 		   type, dbm);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1186,12 +1182,12 @@ static int ath6kl_cfg80211_get_txpower(struct wiphy *wiphy, int *dbm)
 	struct ath6kl *ar = (struct ath6kl *)wiphy_priv(wiphy);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1199,8 +1195,7 @@ static int ath6kl_cfg80211_get_txpower(struct wiphy *wiphy, int *dbm)
 		ar->tx_pwr = 0;
 
 		if (ath6kl_wmi_get_tx_pwr_cmd(ar->wmi) != 0) {
-			ath6kl_err("%s: ath6kl_wmi_get_tx_pwr_cmd failed\n",
-				    __func__);
+			ath6kl_err("ath6kl_wmi_get_tx_pwr_cmd failed\n");
 			return -EIO;
 		}
 
@@ -1208,7 +1203,7 @@ static int ath6kl_cfg80211_get_txpower(struct wiphy *wiphy, int *dbm)
 						 5 * HZ);
 
 		if (signal_pending(current)) {
-			ath6kl_err("%s: target did not respond\n", __func__);
+			ath6kl_err("target did not respond\n");
 			return -EINTR;
 		}
 	}
@@ -1228,12 +1223,12 @@ static int ath6kl_cfg80211_set_power_mgmt(struct wiphy *wiphy,
 		   __func__, pmgmt, timeout);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1246,7 +1241,7 @@ static int ath6kl_cfg80211_set_power_mgmt(struct wiphy *wiphy,
 	}
 
 	if (ath6kl_wmi_powermode_cmd(ar->wmi, mode.pwr_mode) != 0) {
-		ath6kl_err("%s: wmi_powermode_cmd failed\n", __func__);
+		ath6kl_err("wmi_powermode_cmd failed\n");
 		return -EIO;
 	}
 
@@ -1264,12 +1259,12 @@ static int ath6kl_cfg80211_change_iface(struct wiphy *wiphy,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG, "%s: type %u\n", __func__, type);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1281,7 +1276,7 @@ static int ath6kl_cfg80211_change_iface(struct wiphy *wiphy,
 		ar->next_mode = ADHOC_NETWORK;
 		break;
 	default:
-		ath6kl_err("%s: invalid type %u\n", __func__, type);
+		ath6kl_err("invalid interface type %u\n", type);
 		return -EOPNOTSUPP;
 	}
 
@@ -1298,18 +1293,18 @@ static int ath6kl_cfg80211_join_ibss(struct wiphy *wiphy,
 	int status;
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
-	if (!ibss_param->ssid_len
-	    || IEEE80211_MAX_SSID_LEN < ibss_param->ssid_len) {
-		ath6kl_err("%s: ssid invalid\n", __func__);
+	if (!ibss_param->ssid_len ||
+	    IEEE80211_MAX_SSID_LEN < ibss_param->ssid_len) {
+		ath6kl_err("ssid invalid\n");
 		return -EINVAL;
 	}
 
@@ -1373,12 +1368,12 @@ static int ath6kl_cfg80211_leave_ibss(struct wiphy *wiphy,
 	struct ath6kl *ar = (struct ath6kl *)ath6kl_priv(dev);
 
 	if (!test_bit(WMI_READY, &ar->flag)) {
-		ath6kl_err("%s: wmi is not ready\n", __func__);
+		ath6kl_err("wmi is not ready\n");
 		return -EIO;
 	}
 
 	if (ar->wlan_state == WLAN_DISABLED) {
-		ath6kl_err("%s: wlan disabled\n", __func__);
+		ath6kl_err("wlan disabled\n");
 		return -EIO;
 	}
 
@@ -1535,7 +1530,7 @@ static int ath6kl_get_station(struct wiphy *wiphy, struct net_device *dev,
 		sinfo->txrate.flags |= RATE_INFO_FLAGS_40_MHZ_WIDTH;
 		sinfo->txrate.flags |= RATE_INFO_FLAGS_MCS;
 	} else {
-		ath6kl_warn("%s: invalid rate: %d\n", __func__, rate);
+		ath6kl_warn("invalid rate: %d\n", rate);
 		return 0;
 	}
 
@@ -1597,14 +1592,14 @@ struct wireless_dev *ath6kl_cfg80211_init(struct device *dev)
 
 	wdev = kzalloc(sizeof(struct wireless_dev), GFP_KERNEL);
 	if (!wdev) {
-		ath6kl_err("%s: couldn't allocate wireless device\n", __func__);
+		ath6kl_err("couldn't allocate wireless device\n");
 		return NULL;
 	}
 
 	/* create a new wiphy for use with cfg80211 */
 	wdev->wiphy = wiphy_new(&ath6kl_cfg80211_ops, sizeof(struct ath6kl));
 	if (!wdev->wiphy) {
-		ath6kl_err("%s: couldn't allocate wiphy device\n", __func__);
+		ath6kl_err("couldn't allocate wiphy device\n");
 		kfree(wdev);
 		return NULL;
 	}
@@ -1625,7 +1620,7 @@ struct wireless_dev *ath6kl_cfg80211_init(struct device *dev)
 
 	ret = wiphy_register(wdev->wiphy);
 	if (ret < 0) {
-		ath6kl_err("%s: couldn't register wiphy device\n", __func__);
+		ath6kl_err("couldn't register wiphy device\n");
 		wiphy_free(wdev->wiphy);
 		kfree(wdev);
 		return NULL;
diff --git a/drivers/net/wireless/ath/ath6kl/htc.c b/drivers/net/wireless/ath/ath6kl/htc.c
index f9b2294..95c47bb 100644
--- a/drivers/net/wireless/ath/ath6kl/htc.c
+++ b/drivers/net/wireless/ath/ath6kl/htc.c
@@ -81,8 +81,7 @@ static void htc_tx_comp_update(struct htc_target *target,
 	if (!packet->status)
 		return;
 
-	ath6kl_err("%s: req failed (status:%d, ep:%d, len:%d creds:%d)\n",
-		   __func__,
+	ath6kl_err("req failed (status:%d, ep:%d, len:%d creds:%d)\n",
 		   packet->status, packet->endpoint, packet->act_len,
 		   packet->info.tx.cred_used);
 
@@ -906,8 +905,8 @@ static int dev_rx_pkt(struct htc_target *target, struct htc_packet *packet,
 	padded_len = CALC_TXRX_PADDED_LEN(dev, rx_len);
 
 	if (padded_len > packet->buf_len) {
-		ath6kl_err("%s: not enough space for padlen:%d recvlen:%d bufferlen:%d\n",
-			   __func__, padded_len, rx_len, packet->buf_len);
+		ath6kl_err("not enough receive space for packet - padlen:%d recvlen:%d bufferlen:%d\n",
+			   padded_len, rx_len, packet->buf_len);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/wireless/ath/ath6kl/htc_hif.c b/drivers/net/wireless/ath/ath6kl/htc_hif.c
index bc06b3d..1bcaaec 100644
--- a/drivers/net/wireless/ath/ath6kl/htc_hif.c
+++ b/drivers/net/wireless/ath/ath6kl/htc_hif.c
@@ -553,8 +553,7 @@ static int proc_pending_irqs(struct ath6kl_device *dev, bool *done)
 				rg = &dev->irq_proc_reg;
 				lk_ahd = le32_to_cpu(rg->rx_lkahd[HTC_MAILBOX]);
 				if (!lk_ahd)
-					ath6kl_err("%s():lookAhead is zero!\n",
-						   __func__);
+					ath6kl_err("lookAhead is zero!\n");
 			}
 		}
 	}
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index dae5442..fe61871 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -162,8 +162,8 @@ static int ath6kl_connectservice(struct ath6kl *ar,
 
 	status = htc_conn_service(ar->htc_target, con_req, &response);
 	if (status) {
-		ath6kl_err("%s: failed to connect to %s service status:%d\n",
-				__func__, desc, status);
+		ath6kl_err("failed to connect to %s service status:%d\n",
+			   desc, status);
 		return status;
 	}
 
@@ -186,8 +186,7 @@ static int ath6kl_connectservice(struct ath6kl *ar,
 		set_ac2_ep_map(ar, WMM_AC_VO, response.endpoint);
 		break;
 	default:
-		ath6kl_err("%s: service id is not mapped %d\n",
-			__func__, con_req->svc_id);
+		ath6kl_err("service id is not mapped %d\n", con_req->svc_id);
 		return -EINVAL;
 	}
 
@@ -330,8 +329,7 @@ static int ath6kl_set_htc_params(struct ath6kl *ar, u32 mbox_isr_yield_val,
 			(u8 *)&blk_size,
 			4);
 	if (status) {
-		ath6kl_err("%s: bmi_write_memory for IO block size failed\n",
-			   __func__);
+		ath6kl_err("bmi_write_memory for IO block size failed\n");
 		goto out;
 	}
 
@@ -347,8 +345,7 @@ static int ath6kl_set_htc_params(struct ath6kl *ar, u32 mbox_isr_yield_val,
 				(u8 *)&mbox_isr_yield_val,
 				4);
 		if (status) {
-			ath6kl_err("%s: bmi_write_memory for yield limit failed\n",
-				   __func__);
+			ath6kl_err("bmi_write_memory for yield limit failed\n");
 			goto out;
 		}
 	}
@@ -379,8 +376,7 @@ static void ath6kl_dump_target_assert_info(struct ath6kl *ar)
 	status = ath6kl_read_reg_diag(ar, &address, &regdump_loc);
 
 	if (status || !regdump_loc) {
-		ath6kl_err("%s: failed to get ptr to register dump area\n",
-			__func__);
+		ath6kl_err("failed to get ptr to register dump area\n");
 		return;
 	}
 
@@ -410,7 +406,7 @@ static void ath6kl_dump_target_assert_info(struct ath6kl *ar)
 
 void ath6kl_target_failure(struct ath6kl *ar)
 {
-	ath6kl_err("%s: target asserted\n", __func__);
+	ath6kl_err("target asserted\n");
 
 	/* try dumping target assertion information (if any) */
 	ath6kl_dump_target_assert_info(ar);
@@ -428,44 +424,39 @@ static int ath6kl_target_config_wlan_params(struct ath6kl *ar)
 	 */
 	if (ath6kl_wmi_set_rx_frame_format_cmd(ar->wmi,
 					       ar->rx_meta_ver, 0, 0)) {
-		ath6kl_err("%s: unable to set the rx frame format\n", __func__);
+		ath6kl_err("unable to set the rx frame format\n");
 		status = -EIO;
 	}
 
 	if (ar->conf_flags & ATH6KL_CONF_IGNORE_PS_FAIL_EVT_IN_SCAN)
 		if ((ath6kl_wmi_pmparams_cmd(ar->wmi, 0, 1, 0, 0, 1,
 		     IGNORE_POWER_SAVE_FAIL_EVENT_DURING_SCAN)) != 0) {
-			ath6kl_err("%s: unable to set power save fail event policy\n",
-				   __func__);
+			ath6kl_err("unable to set power save fail event policy\n");
 			status = -EIO;
 		}
 
 	if (!(ar->conf_flags & ATH6KL_CONF_IGNORE_ERP_BARKER))
 		if ((ath6kl_wmi_set_lpreamble_cmd(ar->wmi, 0,
 		     WMI_DONOT_IGNORE_BARKER_IN_ERP)) != 0) {
-			ath6kl_err("%s: unable to set barker preamble policy\n",
-				   __func__);
+			ath6kl_err("unable to set barker preamble policy\n");
 			status = -EIO;
 		}
 
 	if (ath6kl_wmi_set_keepalive_cmd(ar->wmi,
 			WLAN_CONFIG_KEEP_ALIVE_INTERVAL)) {
-		ath6kl_err("%s: unable to set keep alive interval\n",
-			   __func__);
+		ath6kl_err("unable to set keep alive interval\n");
 		status = -EIO;
 	}
 
 	if (ath6kl_wmi_disctimeout_cmd(ar->wmi,
 			WLAN_CONFIG_DISCONNECT_TIMEOUT)) {
-		ath6kl_err("%s: unable to set disconnect timeout\n",
-			   __func__);
+		ath6kl_err("unable to set disconnect timeout\n");
 		status = -EIO;
 	}
 
 	if (!(ar->conf_flags & ATH6KL_CONF_ENABLE_TX_BURST))
 		if (ath6kl_wmi_set_wmm_txop(ar->wmi, WMI_TXOP_DISABLED)) {
-			ath6kl_err("%s: unable to set txop bursting\n",
-				   __func__);
+			ath6kl_err("unable to set txop bursting\n");
 			status = -EIO;
 		}
 
@@ -487,8 +478,7 @@ int ath6kl_configure_target(struct ath6kl *ar)
 			     ath6kl_get_hi_item_addr(ar,
 			     HI_ITEM(hi_app_host_interest)),
 			     (u8 *)&param, 4) != 0) {
-		ath6kl_err("%s: bmi_write_memory for htc version failed\n",
-			__func__);
+		ath6kl_err("bmi_write_memory for htc version failed\n");
 		return -EIO;
 	}
 
@@ -499,8 +489,7 @@ int ath6kl_configure_target(struct ath6kl *ar)
 			    ath6kl_get_hi_item_addr(ar,
 			    HI_ITEM(hi_option_flag)),
 			    (u8 *)&param, 4) != 0) {
-		ath6kl_err("%s: bmi_read_memory for setting fwmode failed\n",
-			__func__);
+		ath6kl_err("bmi_read_memory for setting fwmode failed\n");
 		return -EIO;
 	}
 
@@ -514,8 +503,7 @@ int ath6kl_configure_target(struct ath6kl *ar)
 			     HI_ITEM(hi_option_flag)),
 			     (u8 *)&param,
 			     4) != 0) {
-		ath6kl_err("%s: bmi_write_memory for setting fwmode failed\n",
-			__func__);
+		ath6kl_err("bmi_write_memory for setting fwmode failed\n");
 		return -EIO;
 	}
 
@@ -543,16 +531,14 @@ int ath6kl_configure_target(struct ath6kl *ar)
 				     ath6kl_get_hi_item_addr(ar,
 				     HI_ITEM(hi_board_ext_data)),
 				     (u8 *)&param, 4) != 0) {
-			ath6kl_err("%s: bmi_write_memory for hi_board_ext_data failed\n",
-				   __func__);
+			ath6kl_err("bmi_write_memory for hi_board_ext_data failed\n");
 			return -EIO;
 		}
 		if (ath6kl_bmi_write(ar,
 				     ath6kl_get_hi_item_addr(ar,
 				     HI_ITEM(hi_end_ram_reserve_sz)),
 				     (u8 *)&ram_reserved_size, 4) != 0) {
-			ath6kl_err("%s: bmi_write_memory for hi_end_ram_reserve_sz failed\n",
-				   __func__);
+			ath6kl_err("bmi_write_memory for hi_end_ram_reserve_sz failed\n");
 			return -EIO;
 		}
 	}
@@ -573,7 +559,7 @@ struct ath6kl *ath6kl_core_alloc(struct device *sdev)
 
 	wdev = ath6kl_cfg80211_init(sdev);
 	if (!wdev) {
-		ath6kl_err("%s: ath6kl_cfg80211_init failed\n", __func__);
+		ath6kl_err("ath6kl_cfg80211_init failed\n");
 		return NULL;
 	}
 
@@ -584,8 +570,7 @@ struct ath6kl *ath6kl_core_alloc(struct device *sdev)
 
 	dev = alloc_netdev(0, "wlan%d", ether_setup);
 	if (!dev) {
-		ath6kl_err("%s: no memory for network device instance\n",
-			__func__);
+		ath6kl_err("no memory for network device instance\n");
 		ath6kl_cfg80211_deinit(ar);
 		return NULL;
 	}
@@ -985,8 +970,7 @@ static int ath6kl_init_upload(struct ath6kl *ar)
 
 	/* WAR to avoid SDIO CRC err */
 	if (ar->version.target_ver == AR6003_REV2_VERSION) {
-		ath6kl_err("%s: temporary war to avoid sdio crc error\n",
-			   __func__);
+		ath6kl_err("temporary war to avoid sdio crc error\n");
 
 		param = 0x20;
 
@@ -1071,7 +1055,7 @@ static int ath6kl_init(struct net_device *dev)
 	set_bit(WMI_ENABLED, &ar->flag);
 	ar->wmi = ath6kl_wmi_init((void *) ar);
 	if (!ar->wmi) {
-		ath6kl_err("%s: failed to initialize wmi\n", __func__);
+		ath6kl_err("failed to initialize wmi\n");
 		status = -EIO;
 		goto ath6kl_init_done;
 	}
@@ -1126,16 +1110,14 @@ static int ath6kl_init(struct net_device *dev)
 						    WMI_TIMEOUT);
 
 	if (ar->version.abi_ver != ATH6KL_ABI_VERSION) {
-		ath6kl_err("%s: abi version mismatch: host(0x%x), target(0x%x)\n",
-			   __func__, ATH6KL_ABI_VERSION,
-			   ar->version.abi_ver);
+		ath6kl_err("abi version mismatch: host(0x%x), target(0x%x)\n",
+			   ATH6KL_ABI_VERSION, ar->version.abi_ver);
 		status = -EIO;
 		goto err_htc_stop;
 	}
 
 	if (!timeleft || signal_pending(current)) {
-		ath6kl_err("%s: wmi is not ready or wait was interrupted\n",
-			   __func__);
+		ath6kl_err("wmi is not ready or wait was interrupted\n");
 		status = -EIO;
 		goto err_htc_stop;
 	}
@@ -1144,7 +1126,7 @@ static int ath6kl_init(struct net_device *dev)
 
 	/* communicate the wmi protocol verision to the target */
 	if ((ath6kl_set_host_app_area(ar)) != 0)
-		ath6kl_err("%s: unable to set the host app area\n", __func__);
+		ath6kl_err("unable to set the host app area\n");
 
 	ar->conf_flags = ATH6KL_CONF_IGNORE_ERP_BARKER |
 			 ATH6KL_CONF_ENABLE_11N | ATH6KL_CONF_ENABLE_TX_BURST;
@@ -1203,7 +1185,7 @@ int ath6kl_core_init(struct ath6kl *ar)
 
 	ar->aggr_cntxt = aggr_init(ar->net_dev);
 	if (!ar->aggr_cntxt) {
-		ath6kl_err("%s: failed to initialize aggr.\n", __func__);
+		ath6kl_err("failed to initialize aggr\n");
 		ret = -ENOMEM;
 		goto err_htc_cleanup;
 	}
@@ -1219,7 +1201,7 @@ int ath6kl_core_init(struct ath6kl *ar)
 	/* This runs the init function if registered */
 	ret = register_netdev(ar->net_dev);
 	if (ret) {
-		ath6kl_err("%s: register_netdev failed\n", __func__);
+		ath6kl_err("register_netdev failed\n");
 		ath6kl_destroy(ar->net_dev, 0);
 		return ret;
 	}
@@ -1250,7 +1232,7 @@ void ath6kl_stop_txrx(struct ath6kl *ar)
 	set_bit(DESTROY_IN_PROGRESS, &ar->flag);
 
 	if (down_interruptible(&ar->sem)) {
-		ath6kl_err("%s: down_interruptible failed\n", __func__);
+		ath6kl_err("down_interruptible failed\n");
 		return;
 	}
 
@@ -1281,7 +1263,7 @@ void ath6kl_destroy(struct net_device *dev, unsigned int unregister)
 	struct ath6kl *ar;
 
 	if (!dev || !ath6kl_priv(dev)) {
-		ath6kl_err("%s: failed to get device structure\n", __func__);
+		ath6kl_err("failed to get device structure\n");
 		return;
 	}
 
diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index ec07888..f325a23 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -204,8 +204,8 @@ static int ath6kl_set_addrwin_reg(struct ath6kl *ar, u32 reg_addr, u32 addr)
 	}
 
 	if (status) {
-		ath6kl_err("%s: failed to write initial bytes of 0x%x to window reg: 0x%X\n",
-			   __func__, addr, reg_addr);
+		ath6kl_err("failed to write initial bytes of 0x%x to window reg: 0x%X\n",
+			   addr, reg_addr);
 		return status;
 	}
 
@@ -219,8 +219,8 @@ static int ath6kl_set_addrwin_reg(struct ath6kl *ar, u32 reg_addr, u32 addr)
 				     4, HIF_WR_SYNC_BYTE_INC);
 
 	if (status) {
-		ath6kl_err("%s: failed to write 0x%x to window reg: 0x%X\n",
-			   __func__, addr, reg_addr);
+		ath6kl_err("failed to write 0x%x to window reg: 0x%X\n",
+			   addr, reg_addr);
 		return status;
 	}
 
@@ -246,8 +246,7 @@ int ath6kl_read_reg_diag(struct ath6kl *ar, u32 *address, u32 *data)
 	status = hif_read_write_sync(ar, WINDOW_DATA_ADDRESS, (u8 *)data,
 				     sizeof(u32), HIF_RD_SYNC_BYTE_INC);
 	if (status) {
-		ath6kl_err("%s: failed to read from window data addr\n",
-			__func__);
+		ath6kl_err("failed to read from window data addr\n");
 		return status;
 	}
 
@@ -267,8 +266,7 @@ static int ath6kl_write_reg_diag(struct ath6kl *ar, u32 *address, u32 *data)
 	status = hif_read_write_sync(ar, WINDOW_DATA_ADDRESS, (u8 *)data,
 				     sizeof(u32), HIF_WR_SYNC_BYTE_INC);
 	if (status) {
-		ath6kl_err("%s: failed to write 0x%x to window data addr\n",
-			   __func__, *data);
+		ath6kl_err("failed to write 0x%x to window data addr\n", *data);
 		return status;
 	}
 
@@ -316,7 +314,7 @@ static void ath6kl_reset_device(struct ath6kl *ar, u32 target_type,
 	status = ath6kl_write_reg_diag(ar, &address, &data);
 
 	if (status)
-		ath6kl_err("%s: failed to reset target\n", __func__);
+		ath6kl_err("failed to reset target\n");
 }
 
 void ath6kl_stop_endpoint(struct net_device *dev, bool keep_profile,
diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index 1125b37..615b46d 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -194,8 +194,8 @@ int ath6kl_control_tx(void *devt, struct sk_buff *skb,
 		 * are just going to drop this packet.
 		 */
 		cookie = NULL;
-		ath6kl_err("%s: wmi ctrl ep full, dropping pkt : 0x%p, len:%d\n",
-			   __func__, skb, skb->len);
+		ath6kl_err("wmi ctrl ep full, dropping pkt : 0x%p, len:%d\n",
+			   skb, skb->len);
 	} else
 		cookie = ath6kl_alloc_cookie(ar);
 
@@ -270,14 +270,13 @@ int ath6kl_data_tx(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		if (ath6kl_wmi_dix_2_dot3(ar->wmi, skb)) {
-			ath6kl_err("%s: ath6kl_wmi_dix_2_dot3 failed\n",
-				   __func__);
+			ath6kl_err("ath6kl_wmi_dix_2_dot3 failed\n");
 			goto fail_tx;
 		}
 
 		if (ath6kl_wmi_data_hdr_add(ar->wmi, skb, DATA_MSGTYPE,
 					    more_data, 0, 0, NULL)) {
-			ath6kl_err("%s: wmi_data_hdr_add failed\n", __func__);
+			ath6kl_err("wmi_data_hdr_add failed\n");
 			goto fail_tx;
 		}
 
@@ -302,7 +301,7 @@ int ath6kl_data_tx(struct sk_buff *skb, struct net_device *dev)
 		eid = ar->ac2ep_map[ac];
 
 	if (eid == 0 || eid == ENDPOINT_UNUSED) {
-		ath6kl_err("%s: eid %d is not mapped!\n", __func__, eid);
+		ath6kl_err("eid %d is not mapped!\n", eid);
 		spin_unlock_bh(&ar->lock);
 		goto fail_tx;
 	}
@@ -423,7 +422,7 @@ enum htc_send_full_action ath6kl_tx_queue_full(struct htc_target *target,
 		spin_lock_bh(&ar->lock);
 		set_bit(WMI_CTRL_EP_FULL, &ar->flag);
 		spin_unlock_bh(&ar->lock);
-		ath6kl_err("%s: wmi ctrl ep is full\n", __func__);
+		ath6kl_err("wmi ctrl ep is full\n");
 		return HTC_SEND_FULL_KEEP;
 	}
 
@@ -562,8 +561,7 @@ void ath6kl_tx_complete(void *context, struct list_head *packet_queue)
 			ar->net_stats.tx_errors++;
 
 			if (status != -ENOSPC)
-				ath6kl_err("%s: tx error, status: 0x%x\n",
-					   __func__, status);
+				ath6kl_err("tx error, status: 0x%x\n", status);
 			ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
 				   "%s: skb=0x%p data=0x%p len=0x%x eid=%d %s\n",
 				   __func__, skb, packet->buf, packet->act_len,
@@ -644,7 +642,7 @@ static void ath6kl_alloc_netbufs(struct sk_buff_head *q, u16 num)
 	while (num) {
 		skb = ath6kl_buf_alloc(ATH6KL_BUFFER_SIZE);
 		if (!skb) {
-			ath6kl_err("%s: netbuf allocation failed\n", __func__);
+			ath6kl_err("netbuf allocation failed\n");
 			return;
 		}
 		skb_queue_tail(q, skb);
@@ -785,22 +783,22 @@ static void aggr_slice_amsdu(struct aggr_info *p_aggr,
 
 		if (payload_8023_len < MIN_MSDU_SUBFRAME_PAYLOAD_LEN ||
 		    payload_8023_len > MAX_MSDU_SUBFRAME_PAYLOAD_LEN) {
-			ath6kl_err("%s: 802.3 AMSDU frame bound check failed. len %d\n",
-				   __func__, payload_8023_len);
+			ath6kl_err("802.3 AMSDU frame bound check failed. len %d\n",
+				   payload_8023_len);
 			break;
 		}
 
 		frame_8023_len = payload_8023_len + mac_hdr_len;
 		new_skb = aggr_get_free_skb(p_aggr);
 		if (!new_skb) {
-			ath6kl_err("%s: no buffer available\n", __func__);
+			ath6kl_err("no buffer available\n");
 			break;
 		}
 
 		memcpy(new_skb->data, framep, frame_8023_len);
 		skb_put(new_skb, frame_8023_len);
 		if (ath6kl_wmi_dot3_2_dix(new_skb)) {
-			ath6kl_err("%s: dot3_2_dix error\n", __func__);
+			ath6kl_err("dot3_2_dix error\n");
 			dev_kfree_skb(new_skb);
 			break;
 		}
@@ -1080,10 +1078,8 @@ void ath6kl_rx(struct htc_target *target, struct htc_packet *packet)
 	 */
 	if (ar->nw_type != AP_NETWORK &&
 	    ((packet->act_len < min_hdr_len) ||
-	     (packet->act_len >
-	      WMI_MAX_AMSDU_RX_DATA_FRAME_LENGTH))) {
-		ath6kl_info("%s: frame len is too short or too long\n",
-			    __func__);
+	     (packet->act_len > WMI_MAX_AMSDU_RX_DATA_FRAME_LENGTH))) {
+		ath6kl_info("frame len is too short or too long\n");
 		ar->net_stats.rx_errors++;
 		ar->net_stats.rx_length_errors++;
 		dev_kfree_skb(skb);
@@ -1255,8 +1251,8 @@ static void aggr_timeout(unsigned long arg)
 			continue;
 
 		stats->num_timeouts++;
-		ath6kl_err("%s: aggr timeout (st %d end %d)\n",
-			   __func__, rxtid->seq_next,
+		ath6kl_err("aggr timeout (st %d end %d)\n",
+			   rxtid->seq_next,
 			   ((rxtid->seq_next + rxtid->hold_q_sz-1) &
 			    ATH6KL_MAX_SEQ_NO));
 		aggr_deque_frms(p_aggr, i, 0, 0);
@@ -1356,8 +1352,7 @@ struct aggr_info *aggr_init(struct net_device *dev)
 
 	p_aggr = kzalloc(sizeof(struct aggr_info), GFP_KERNEL);
 	if (!p_aggr) {
-		ath6kl_err("%s: failed to alloc memory for aggr_node\n",
-			   __func__);
+		ath6kl_err("failed to alloc memory for aggr_node\n");
 		return NULL;
 	}
 
diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index 5d95b56..a52d7d2 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -1373,7 +1373,7 @@ static int ath6kl_wmi_snr_threshold_event_rx(struct wmi *wmi, u8 *datap,
 
 	ret = ath6kl_wmi_send_snr_threshold_params(wmi, &cmd);
 	if (ret) {
-		ath6kl_err("%s: unable to configure snr threshold\n", __func__);
+		ath6kl_err("unable to configure snr threshold\n");
 		return -EIO;
 	}
 
@@ -2490,7 +2490,7 @@ static int ath6kl_wmi_control_rx_xtnd(struct wmi *wmi, struct sk_buff *skb)
 	int ret = 0;
 
 	if (skb->len < sizeof(struct wmix_cmd_hdr)) {
-		ath6kl_err("%s: bad packet 1\n", __func__);
+		ath6kl_err("bad packet 1\n");
 		wmi->stat.cmd_len_err++;
 		return -EINVAL;
 	}
@@ -2509,7 +2509,7 @@ static int ath6kl_wmi_control_rx_xtnd(struct wmi *wmi, struct sk_buff *skb)
 	case WMIX_DBGLOG_EVENTID:
 		break;
 	default:
-		ath6kl_err("%s: unknown cmd id 0x%x\n", __func__, id);
+		ath6kl_err("unknown cmd id 0x%x\n", id);
 		wmi->stat.cmd_id_err++;
 		ret = -EINVAL;
 		break;
@@ -2531,7 +2531,7 @@ int ath6kl_wmi_control_rx(struct wmi *wmi, struct sk_buff *skb)
 		return -EINVAL;
 
 	if (skb->len < sizeof(struct wmi_cmd_hdr)) {
-		ath6kl_err("%s: bad packet 1\n", __func__);
+		ath6kl_err("bad packet 1\n");
 		dev_kfree_skb(skb);
 		wmi->stat.cmd_len_err++;
 		return -EINVAL;
-- 
1.7.6.131.g99019
