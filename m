From: Linus Walleij <linus.walleij@linaro.org>
Subject: [PATCH 06/14] usb/net: rndis: merge duplicate 802_* OIDs
Date: Sun,  8 Apr 2012 10:47:59 +0200
Message-ID: <1333874879-4764-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:14124 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753484Ab2DHIsB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Apr 2012 04:48:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 802_* network OIDs were duplicated, so let's merge them and
use the RNDIS_* prefixed definitions from the hyperV driver.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/wireless/rndis_wlan.c |  158 ++++++++++++++++++------------------
 drivers/usb/gadget/rndis.c        |   62 +++++++-------
 include/linux/rndis.h             |   76 ++++++------------
 3 files changed, 137 insertions(+), 159 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d84bf11..41b96e3 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -641,36 +641,36 @@ static const char *oid_to_string(__le32 oid)
 		OID_STR(RNDIS_OID_GEN_RCV_ERROR);
 		OID_STR(RNDIS_OID_GEN_RCV_NO_BUFFER);
 
-		OID_STR(OID_802_3_CURRENT_ADDRESS);
-		OID_STR(OID_802_3_MULTICAST_LIST);
-		OID_STR(OID_802_3_MAXIMUM_LIST_SIZE);
-
-		OID_STR(OID_802_11_BSSID);
-		OID_STR(OID_802_11_SSID);
-		OID_STR(OID_802_11_INFRASTRUCTURE_MODE);
-		OID_STR(OID_802_11_ADD_WEP);
-		OID_STR(OID_802_11_REMOVE_WEP);
-		OID_STR(OID_802_11_DISASSOCIATE);
-		OID_STR(OID_802_11_AUTHENTICATION_MODE);
-		OID_STR(OID_802_11_PRIVACY_FILTER);
-		OID_STR(OID_802_11_BSSID_LIST_SCAN);
-		OID_STR(OID_802_11_ENCRYPTION_STATUS);
-		OID_STR(OID_802_11_ADD_KEY);
-		OID_STR(OID_802_11_REMOVE_KEY);
-		OID_STR(OID_802_11_ASSOCIATION_INFORMATION);
-		OID_STR(OID_802_11_CAPABILITY);
-		OID_STR(OID_802_11_PMKID);
-		OID_STR(OID_802_11_NETWORK_TYPES_SUPPORTED);
-		OID_STR(OID_802_11_NETWORK_TYPE_IN_USE);
-		OID_STR(OID_802_11_TX_POWER_LEVEL);
-		OID_STR(OID_802_11_RSSI);
-		OID_STR(OID_802_11_RSSI_TRIGGER);
-		OID_STR(OID_802_11_FRAGMENTATION_THRESHOLD);
-		OID_STR(OID_802_11_RTS_THRESHOLD);
-		OID_STR(OID_802_11_SUPPORTED_RATES);
-		OID_STR(OID_802_11_CONFIGURATION);
-		OID_STR(OID_802_11_POWER_MODE);
-		OID_STR(OID_802_11_BSSID_LIST);
+		OID_STR(RNDIS_OID_802_3_CURRENT_ADDRESS);
+		OID_STR(RNDIS_OID_802_3_MULTICAST_LIST);
+		OID_STR(RNDIS_OID_802_3_MAXIMUM_LIST_SIZE);
+
+		OID_STR(RNDIS_OID_802_11_BSSID);
+		OID_STR(RNDIS_OID_802_11_SSID);
+		OID_STR(RNDIS_OID_802_11_INFRASTRUCTURE_MODE);
+		OID_STR(RNDIS_OID_802_11_ADD_WEP);
+		OID_STR(RNDIS_OID_802_11_REMOVE_WEP);
+		OID_STR(RNDIS_OID_802_11_DISASSOCIATE);
+		OID_STR(RNDIS_OID_802_11_AUTHENTICATION_MODE);
+		OID_STR(RNDIS_OID_802_11_PRIVACY_FILTER);
+		OID_STR(RNDIS_OID_802_11_BSSID_LIST_SCAN);
+		OID_STR(RNDIS_OID_802_11_ENCRYPTION_STATUS);
+		OID_STR(RNDIS_OID_802_11_ADD_KEY);
+		OID_STR(RNDIS_OID_802_11_REMOVE_KEY);
+		OID_STR(RNDIS_OID_802_11_ASSOCIATION_INFORMATION);
+		OID_STR(RNDIS_OID_802_11_CAPABILITY);
+		OID_STR(RNDIS_OID_802_11_PMKID);
+		OID_STR(RNDIS_OID_802_11_NETWORK_TYPES_SUPPORTED);
+		OID_STR(RNDIS_OID_802_11_NETWORK_TYPE_IN_USE);
+		OID_STR(RNDIS_OID_802_11_TX_POWER_LEVEL);
+		OID_STR(RNDIS_OID_802_11_RSSI);
+		OID_STR(RNDIS_OID_802_11_RSSI_TRIGGER);
+		OID_STR(RNDIS_OID_802_11_FRAGMENTATION_THRESHOLD);
+		OID_STR(RNDIS_OID_802_11_RTS_THRESHOLD);
+		OID_STR(RNDIS_OID_802_11_SUPPORTED_RATES);
+		OID_STR(RNDIS_OID_802_11_CONFIGURATION);
+		OID_STR(RNDIS_OID_802_11_POWER_MODE);
+		OID_STR(RNDIS_OID_802_11_BSSID_LIST);
 #undef OID_STR
 	}
 
@@ -982,9 +982,9 @@ static int rndis_start_bssid_list_scan(struct usbnet *usbdev)
 {
 	__le32 tmp;
 
-	/* Note: OID_802_11_BSSID_LIST_SCAN clears internal BSS list. */
+	/* Note: RNDIS_OID_802_11_BSSID_LIST_SCAN clears internal BSS list. */
 	tmp = cpu_to_le32(1);
-	return rndis_set_oid(usbdev, OID_802_11_BSSID_LIST_SCAN, &tmp,
+	return rndis_set_oid(usbdev, RNDIS_OID_802_11_BSSID_LIST_SCAN, &tmp,
 							sizeof(tmp));
 }
 
@@ -993,7 +993,7 @@ static int set_essid(struct usbnet *usbdev, struct ndis_80211_ssid *ssid)
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 	int ret;
 
-	ret = rndis_set_oid(usbdev, OID_802_11_SSID, ssid, sizeof(*ssid));
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_SSID, ssid, sizeof(*ssid));
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "setting SSID failed (%08X)\n", ret);
 		return ret;
@@ -1010,7 +1010,7 @@ static int set_bssid(struct usbnet *usbdev, const u8 *bssid)
 {
 	int ret;
 
-	ret = rndis_set_oid(usbdev, OID_802_11_BSSID, bssid, ETH_ALEN);
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_BSSID, bssid, ETH_ALEN);
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "setting BSSID[%pM] failed (%08X)\n",
 			    bssid, ret);
@@ -1034,7 +1034,7 @@ static int get_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 	int ret, len;
 
 	len = ETH_ALEN;
-	ret = rndis_query_oid(usbdev, OID_802_11_BSSID, bssid, &len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_BSSID, bssid, &len);
 
 	if (ret != 0)
 		memset(bssid, 0, ETH_ALEN);
@@ -1045,7 +1045,7 @@ static int get_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 static int get_association_info(struct usbnet *usbdev,
 			struct ndis_80211_assoc_info *info, int len)
 {
-	return rndis_query_oid(usbdev, OID_802_11_ASSOCIATION_INFORMATION,
+	return rndis_query_oid(usbdev, RNDIS_OID_802_11_ASSOCIATION_INFORMATION,
 				info, &len);
 }
 
@@ -1070,7 +1070,7 @@ static int disassociate(struct usbnet *usbdev, bool reset_ssid)
 	int i, ret = 0;
 
 	if (priv->radio_on) {
-		ret = rndis_set_oid(usbdev, OID_802_11_DISASSOCIATE, NULL, 0);
+		ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_DISASSOCIATE, NULL, 0);
 		if (ret == 0) {
 			priv->radio_on = false;
 			netdev_dbg(usbdev->net, "%s(): radio_on = false\n",
@@ -1132,7 +1132,7 @@ static int set_auth_mode(struct usbnet *usbdev, u32 wpa_version,
 		return -ENOTSUPP;
 
 	tmp = cpu_to_le32(auth_mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_AUTHENTICATION_MODE, &tmp,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_AUTHENTICATION_MODE, &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting auth mode failed (%08X)\n",
@@ -1159,7 +1159,7 @@ static int set_priv_filter(struct usbnet *usbdev)
 	else
 		tmp = cpu_to_le32(NDIS_80211_PRIV_ACCEPT_ALL);
 
-	return rndis_set_oid(usbdev, OID_802_11_PRIVACY_FILTER, &tmp,
+	return rndis_set_oid(usbdev, RNDIS_OID_802_11_PRIVACY_FILTER, &tmp,
 								sizeof(tmp));
 }
 
@@ -1185,7 +1185,7 @@ static int set_encr_mode(struct usbnet *usbdev, int pairwise, int groupwise)
 		encr_mode = NDIS_80211_ENCR_DISABLED;
 
 	tmp = cpu_to_le32(encr_mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_ENCRYPTION_STATUS, &tmp,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_ENCRYPTION_STATUS, &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting encr mode failed (%08X)\n",
@@ -1206,7 +1206,7 @@ static int set_infra_mode(struct usbnet *usbdev, int mode)
 		   __func__, priv->infra_mode);
 
 	tmp = cpu_to_le32(mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_INFRASTRUCTURE_MODE, &tmp,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_INFRASTRUCTURE_MODE, &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting infra mode failed (%08X)\n",
@@ -1233,7 +1233,7 @@ static int set_rts_threshold(struct usbnet *usbdev, u32 rts_threshold)
 		rts_threshold = 2347;
 
 	tmp = cpu_to_le32(rts_threshold);
-	return rndis_set_oid(usbdev, OID_802_11_RTS_THRESHOLD, &tmp,
+	return rndis_set_oid(usbdev, RNDIS_OID_802_11_RTS_THRESHOLD, &tmp,
 								sizeof(tmp));
 }
 
@@ -1247,7 +1247,7 @@ static int set_frag_threshold(struct usbnet *usbdev, u32 frag_threshold)
 		frag_threshold = 2346;
 
 	tmp = cpu_to_le32(frag_threshold);
-	return rndis_set_oid(usbdev, OID_802_11_FRAGMENTATION_THRESHOLD, &tmp,
+	return rndis_set_oid(usbdev, RNDIS_OID_802_11_FRAGMENTATION_THRESHOLD, &tmp,
 								sizeof(tmp));
 }
 
@@ -1284,7 +1284,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 	dsconfig = ieee80211_dsss_chan_to_freq(channel) * 1000;
 
 	len = sizeof(config);
-	ret = rndis_query_oid(usbdev, OID_802_11_CONFIGURATION, &config, &len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_CONFIGURATION, &config, &len);
 	if (ret < 0) {
 		netdev_dbg(usbdev->net, "%s(): querying configuration failed\n",
 			   __func__);
@@ -1292,7 +1292,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 	}
 
 	config.ds_config = cpu_to_le32(dsconfig);
-	ret = rndis_set_oid(usbdev, OID_802_11_CONFIGURATION, &config,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_CONFIGURATION, &config,
 								sizeof(config));
 
 	netdev_dbg(usbdev->net, "%s(): %d -> %d\n", __func__, channel, ret);
@@ -1310,8 +1310,8 @@ static struct ieee80211_channel *get_current_channel(struct usbnet *usbdev,
 
 	/* Get channel and beacon interval */
 	len = sizeof(config);
-	ret = rndis_query_oid(usbdev, OID_802_11_CONFIGURATION, &config, &len);
-	netdev_dbg(usbdev->net, "%s(): OID_802_11_CONFIGURATION -> %d\n",
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_CONFIGURATION, &config, &len);
+	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_CONFIGURATION -> %d\n",
 				__func__, ret);
 	if (ret < 0)
 		return NULL;
@@ -1364,7 +1364,7 @@ static int add_wep_key(struct usbnet *usbdev, const u8 *key, int key_len,
 				    ret);
 	}
 
-	ret = rndis_set_oid(usbdev, OID_802_11_ADD_WEP, &ndis_key,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_ADD_WEP, &ndis_key,
 							sizeof(ndis_key));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "adding encryption key %d failed (%08X)\n",
@@ -1455,9 +1455,9 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 			get_bssid(usbdev, ndis_key.bssid);
 	}
 
-	ret = rndis_set_oid(usbdev, OID_802_11_ADD_KEY, &ndis_key,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_ADD_KEY, &ndis_key,
 					le32_to_cpu(ndis_key.size));
-	netdev_dbg(usbdev->net, "%s(): OID_802_11_ADD_KEY -> %08X\n",
+	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_ADD_KEY -> %08X\n",
 		   __func__, ret);
 	if (ret != 0)
 		return ret;
@@ -1545,13 +1545,13 @@ static int remove_key(struct usbnet *usbdev, u8 index, const u8 *bssid)
 			memset(remove_key.bssid, 0xff,
 						sizeof(remove_key.bssid));
 
-		ret = rndis_set_oid(usbdev, OID_802_11_REMOVE_KEY, &remove_key,
+		ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_REMOVE_KEY, &remove_key,
 							sizeof(remove_key));
 		if (ret != 0)
 			return ret;
 	} else {
 		keyindex = cpu_to_le32(index);
-		ret = rndis_set_oid(usbdev, OID_802_11_REMOVE_WEP, &keyindex,
+		ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_REMOVE_WEP, &keyindex,
 							sizeof(keyindex));
 		if (ret != 0) {
 			netdev_warn(usbdev->net,
@@ -1620,7 +1620,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 		goto set_filter;
 
 	if (mc_count) {
-		ret = rndis_set_oid(usbdev, OID_802_3_MULTICAST_LIST, mc_addrs,
+		ret = rndis_set_oid(usbdev, RNDIS_OID_802_3_MULTICAST_LIST, mc_addrs,
 				    mc_count * ETH_ALEN);
 		kfree(mc_addrs);
 		if (ret == 0)
@@ -1628,7 +1628,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 		else
 			filter |= cpu_to_le32(RNDIS_PACKET_TYPE_ALL_MULTICAST);
 
-		netdev_dbg(usbdev->net, "OID_802_3_MULTICAST_LIST(%d, max: %d) -> %d\n",
+		netdev_dbg(usbdev->net, "RNDIS_OID_802_3_MULTICAST_LIST(%d, max: %d) -> %d\n",
 			   mc_count, priv->multicast_size, ret);
 	}
 
@@ -1699,9 +1699,9 @@ static struct ndis_80211_pmkid *get_device_pmkids(struct usbnet *usbdev)
 	pmkids->length = cpu_to_le32(len);
 	pmkids->bssid_info_count = cpu_to_le32(max_pmkids);
 
-	ret = rndis_query_oid(usbdev, OID_802_11_PMKID, pmkids, &len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_PMKID, pmkids, &len);
 	if (ret < 0) {
-		netdev_dbg(usbdev->net, "%s(): OID_802_11_PMKID(%d, %d)"
+		netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_PMKID(%d, %d)"
 				" -> %d\n", __func__, len, max_pmkids, ret);
 
 		kfree(pmkids);
@@ -1727,10 +1727,10 @@ static int set_device_pmkids(struct usbnet *usbdev,
 
 	debug_print_pmkids(usbdev, pmkids, __func__);
 
-	ret = rndis_set_oid(usbdev, OID_802_11_PMKID, pmkids,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_PMKID, pmkids,
 						le32_to_cpu(pmkids->length));
 	if (ret < 0) {
-		netdev_dbg(usbdev->net, "%s(): OID_802_11_PMKID(%d, %d) -> %d"
+		netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_PMKID(%d, %d) -> %d"
 				"\n", __func__, len, num_pmkids, ret);
 	}
 
@@ -2064,7 +2064,7 @@ resize_buf:
 	 * resizing until it won't get any bigger.
 	 */
 	new_len = len;
-	ret = rndis_query_oid(usbdev, OID_802_11_BSSID_LIST, buf, &new_len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_BSSID_LIST, buf, &new_len);
 	if (ret != 0 || new_len < sizeof(struct ndis_80211_bssid_list_ex))
 		goto out;
 
@@ -2469,7 +2469,7 @@ static void rndis_fill_station_info(struct usbnet *usbdev,
 	}
 
 	len = sizeof(rssi);
-	ret = rndis_query_oid(usbdev, OID_802_11_RSSI, &rssi, &len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_RSSI, &rssi, &len);
 	if (ret == 0) {
 		sinfo->signal = level_to_qual(le32_to_cpu(rssi));
 		sinfo->filled |= STATION_INFO_SIGNAL;
@@ -2575,7 +2575,7 @@ static int rndis_flush_pmksa(struct wiphy *wiphy, struct net_device *netdev)
 	pmkid.length = cpu_to_le32(sizeof(pmkid));
 	pmkid.bssid_info_count = cpu_to_le32(0);
 
-	return rndis_set_oid(usbdev, OID_802_11_PMKID, &pmkid, sizeof(pmkid));
+	return rndis_set_oid(usbdev, RNDIS_OID_802_11_PMKID, &pmkid, sizeof(pmkid));
 }
 
 static int rndis_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
@@ -2605,9 +2605,9 @@ static int rndis_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
 	priv->power_mode = power_mode;
 
 	mode = cpu_to_le32(power_mode);
-	ret = rndis_set_oid(usbdev, OID_802_11_POWER_MODE, &mode, sizeof(mode));
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_POWER_MODE, &mode, sizeof(mode));
 
-	netdev_dbg(usbdev->net, "%s(): OID_802_11_POWER_MODE -> %d\n",
+	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_POWER_MODE -> %d\n",
 				__func__, ret);
 
 	return ret;
@@ -2644,10 +2644,10 @@ static void rndis_wlan_craft_connected_bss(struct usbnet *usbdev, u8 *bssid,
 	/* Get signal quality, in case of error use rssi=0 and ignore error. */
 	len = sizeof(rssi);
 	rssi = 0;
-	ret = rndis_query_oid(usbdev, OID_802_11_RSSI, &rssi, &len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_RSSI, &rssi, &len);
 	signal = level_to_qual(le32_to_cpu(rssi));
 
-	netdev_dbg(usbdev->net, "%s(): OID_802_11_RSSI -> %d, "
+	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_RSSI -> %d, "
 		   "rssi:%d, qual: %d\n", __func__, ret, le32_to_cpu(rssi),
 		   level_to_qual(le32_to_cpu(rssi)));
 
@@ -2671,8 +2671,8 @@ static void rndis_wlan_craft_connected_bss(struct usbnet *usbdev, u8 *bssid,
 	/* Get SSID, in case of error, use zero length SSID and ignore error. */
 	len = sizeof(ssid);
 	memset(&ssid, 0, sizeof(ssid));
-	ret = rndis_query_oid(usbdev, OID_802_11_SSID, &ssid, &len);
-	netdev_dbg(usbdev->net, "%s(): OID_802_11_SSID -> %d, len: %d, ssid: "
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_SSID, &ssid, &len);
+	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_SSID -> %d, len: %d, ssid: "
 				"'%.32s'\n", __func__, ret,
 				le32_to_cpu(ssid.length), ssid.essid);
 
@@ -2794,7 +2794,7 @@ static void rndis_wlan_do_link_up_work(struct usbnet *usbdev)
 	 * NDIS spec says: "If the device is associated, but the associated
 	 *  BSSID is not in its BSSID scan list, then the driver must add an
 	 *  entry for the BSSID at the end of the data that it returns in
-	 *  response to query of OID_802_11_BSSID_LIST."
+	 *  response to query of RNDIS_OID_802_11_BSSID_LIST."
 	 *
 	 * NOTE: Seems to be true for BCM4320b variant, but not BCM4320a.
 	 */
@@ -3048,13 +3048,13 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 
 	switch (msg->status) {
 	case cpu_to_le32(RNDIS_STATUS_MEDIA_CONNECT):
-		if (priv->current_command_oid == OID_802_11_ADD_KEY) {
-			/* OID_802_11_ADD_KEY causes sometimes extra
+		if (priv->current_command_oid == RNDIS_OID_802_11_ADD_KEY) {
+			/* RNDIS_OID_802_11_ADD_KEY causes sometimes extra
 			 * "media connect" indications which confuses driver
 			 * and userspace to think that device is
 			 * roaming/reassociating when it isn't.
 			 */
-			netdev_dbg(usbdev->net, "ignored OID_802_11_ADD_KEY triggered 'media connect'\n");
+			netdev_dbg(usbdev->net, "ignored RNDIS_OID_802_11_ADD_KEY triggered 'media connect'\n");
 			return;
 		}
 
@@ -3099,7 +3099,7 @@ static int rndis_wlan_get_caps(struct usbnet *usbdev, struct wiphy *wiphy)
 
 	/* determine supported modes */
 	len = sizeof(networks_supported);
-	retval = rndis_query_oid(usbdev, OID_802_11_NETWORK_TYPES_SUPPORTED,
+	retval = rndis_query_oid(usbdev, RNDIS_OID_802_11_NETWORK_TYPES_SUPPORTED,
 						&networks_supported, &len);
 	if (retval >= 0) {
 		n = le32_to_cpu(networks_supported.num_items);
@@ -3124,9 +3124,9 @@ static int rndis_wlan_get_caps(struct usbnet *usbdev, struct wiphy *wiphy)
 	/* get device 802.11 capabilities, number of PMKIDs */
 	caps = (struct ndis_80211_capability *)caps_buf;
 	len = sizeof(caps_buf);
-	retval = rndis_query_oid(usbdev, OID_802_11_CAPABILITY, caps, &len);
+	retval = rndis_query_oid(usbdev, RNDIS_OID_802_11_CAPABILITY, caps, &len);
 	if (retval >= 0) {
-		netdev_dbg(usbdev->net, "OID_802_11_CAPABILITY -> len %d, "
+		netdev_dbg(usbdev->net, "RNDIS_OID_802_11_CAPABILITY -> len %d, "
 				"ver %d, pmkids %d, auth-encr-pairs %d\n",
 				le32_to_cpu(caps->length),
 				le32_to_cpu(caps->version),
@@ -3198,13 +3198,13 @@ static void rndis_device_poller(struct work_struct *work)
 	}
 
 	len = sizeof(rssi);
-	ret = rndis_query_oid(usbdev, OID_802_11_RSSI, &rssi, &len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_RSSI, &rssi, &len);
 	if (ret == 0) {
 		priv->last_qual = level_to_qual(le32_to_cpu(rssi));
 		rndis_do_cqm(usbdev, le32_to_cpu(rssi));
 	}
 
-	netdev_dbg(usbdev->net, "dev-poller: OID_802_11_RSSI -> %d, rssi:%d, qual: %d\n",
+	netdev_dbg(usbdev->net, "dev-poller: RNDIS_OID_802_11_RSSI -> %d, rssi:%d, qual: %d\n",
 		   ret, le32_to_cpu(rssi), level_to_qual(le32_to_cpu(rssi)));
 
 	/* Workaround transfer stalls on poor quality links.
@@ -3226,7 +3226,7 @@ static void rndis_device_poller(struct work_struct *work)
 		 * working.
 		 */
 		tmp = cpu_to_le32(1);
-		rndis_set_oid(usbdev, OID_802_11_BSSID_LIST_SCAN, &tmp,
+		rndis_set_oid(usbdev, RNDIS_OID_802_11_BSSID_LIST_SCAN, &tmp,
 								sizeof(tmp));
 
 		len = CONTROL_BUFFER_SIZE;
@@ -3234,7 +3234,7 @@ static void rndis_device_poller(struct work_struct *work)
 		if (!buf)
 			goto end;
 
-		rndis_query_oid(usbdev, OID_802_11_BSSID_LIST, buf, &len);
+		rndis_query_oid(usbdev, RNDIS_OID_802_11_BSSID_LIST, buf, &len);
 		kfree(buf);
 	}
 
@@ -3423,7 +3423,7 @@ static int rndis_wlan_bind(struct usbnet *usbdev, struct usb_interface *intf)
 
 	len = sizeof(tmp);
 	retval = rndis_query_oid(usbdev,
-				 cpu_to_le32(OID_802_3_MAXIMUM_LIST_SIZE),
+				 cpu_to_le32(RNDIS_OID_802_3_MAXIMUM_LIST_SIZE),
 				 &tmp, &len);
 	priv->multicast_size = le32_to_cpu(tmp);
 	if (retval < 0 || priv->multicast_size < 0)
diff --git a/drivers/usb/gadget/rndis.c b/drivers/usb/gadget/rndis.c
index 3ade168..79ed261 100644
--- a/drivers/usb/gadget/rndis.c
+++ b/drivers/usb/gadget/rndis.c
@@ -115,23 +115,23 @@ static const u32 oid_supported_list[] =
 	/* mandatory 802.3 */
 	/* the general stuff */
 	RNDIS_OID_802_3_PERMANENT_ADDRESS,
-	OID_802_3_CURRENT_ADDRESS,
-	OID_802_3_MULTICAST_LIST,
-	OID_802_3_MAC_OPTIONS,
-	OID_802_3_MAXIMUM_LIST_SIZE,
+	RNDIS_OID_802_3_CURRENT_ADDRESS,
+	RNDIS_OID_802_3_MULTICAST_LIST,
+	RNDIS_OID_802_3_MAC_OPTIONS,
+	RNDIS_OID_802_3_MAXIMUM_LIST_SIZE,
 
 	/* the statistical stuff */
-	OID_802_3_RCV_ERROR_ALIGNMENT,
-	OID_802_3_XMIT_ONE_COLLISION,
-	OID_802_3_XMIT_MORE_COLLISIONS,
+	RNDIS_OID_802_3_RCV_ERROR_ALIGNMENT,
+	RNDIS_OID_802_3_XMIT_ONE_COLLISION,
+	RNDIS_OID_802_3_XMIT_MORE_COLLISIONS,
 #ifdef	RNDIS_OPTIONAL_STATS
-	OID_802_3_XMIT_DEFERRED,
-	OID_802_3_XMIT_MAX_COLLISIONS,
-	OID_802_3_RCV_OVERRUN,
-	OID_802_3_XMIT_UNDERRUN,
-	OID_802_3_XMIT_HEARTBEAT_FAILURE,
-	OID_802_3_XMIT_TIMES_CRS_LOST,
-	OID_802_3_XMIT_LATE_COLLISIONS,
+	RNDIS_OID_802_3_XMIT_DEFERRED,
+	RNDIS_OID_802_3_XMIT_MAX_COLLISIONS,
+	RNDIS_OID_802_3_RCV_OVERRUN,
+	RNDIS_OID_802_3_XMIT_UNDERRUN,
+	RNDIS_OID_802_3_XMIT_HEARTBEAT_FAILURE,
+	RNDIS_OID_802_3_XMIT_TIMES_CRS_LOST,
+	RNDIS_OID_802_3_XMIT_LATE_COLLISIONS,
 #endif	/* RNDIS_OPTIONAL_STATS */
 
 #ifdef	RNDIS_PM
@@ -408,7 +408,7 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 
 	/* mandatory */
 	case RNDIS_OID_802_3_PERMANENT_ADDRESS:
-		pr_debug("%s: OID_802_3_PERMANENT_ADDRESS\n", __func__);
+		pr_debug("%s: RNDIS_OID_802_3_PERMANENT_ADDRESS\n", __func__);
 		if (rndis_per_dev_params[configNr].dev) {
 			length = ETH_ALEN;
 			memcpy(outbuf,
@@ -419,8 +419,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_802_3_CURRENT_ADDRESS:
-		pr_debug("%s: OID_802_3_CURRENT_ADDRESS\n", __func__);
+	case RNDIS_OID_802_3_CURRENT_ADDRESS:
+		pr_debug("%s: RNDIS_OID_802_3_CURRENT_ADDRESS\n", __func__);
 		if (rndis_per_dev_params[configNr].dev) {
 			length = ETH_ALEN;
 			memcpy(outbuf,
@@ -431,23 +431,23 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_802_3_MULTICAST_LIST:
-		pr_debug("%s: OID_802_3_MULTICAST_LIST\n", __func__);
+	case RNDIS_OID_802_3_MULTICAST_LIST:
+		pr_debug("%s: RNDIS_OID_802_3_MULTICAST_LIST\n", __func__);
 		/* Multicast base address only */
 		*outbuf = cpu_to_le32(0xE0000000);
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_802_3_MAXIMUM_LIST_SIZE:
-		pr_debug("%s: OID_802_3_MAXIMUM_LIST_SIZE\n", __func__);
+	case RNDIS_OID_802_3_MAXIMUM_LIST_SIZE:
+		pr_debug("%s: RNDIS_OID_802_3_MAXIMUM_LIST_SIZE\n", __func__);
 		/* Multicast base address only */
 		*outbuf = cpu_to_le32(1);
 		retval = 0;
 		break;
 
-	case OID_802_3_MAC_OPTIONS:
-		pr_debug("%s: OID_802_3_MAC_OPTIONS\n", __func__);
+	case RNDIS_OID_802_3_MAC_OPTIONS:
+		pr_debug("%s: RNDIS_OID_802_3_MAC_OPTIONS\n", __func__);
 		*outbuf = cpu_to_le32(0);
 		retval = 0;
 		break;
@@ -455,8 +455,8 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 	/* ieee802.3 statistics OIDs (table 4-4) */
 
 	/* mandatory */
-	case OID_802_3_RCV_ERROR_ALIGNMENT:
-		pr_debug("%s: OID_802_3_RCV_ERROR_ALIGNMENT\n", __func__);
+	case RNDIS_OID_802_3_RCV_ERROR_ALIGNMENT:
+		pr_debug("%s: RNDIS_OID_802_3_RCV_ERROR_ALIGNMENT\n", __func__);
 		if (stats) {
 			*outbuf = cpu_to_le32(stats->rx_frame_errors);
 			retval = 0;
@@ -464,15 +464,15 @@ static int gen_ndis_query_resp(int configNr, u32 OID, u8 *buf,
 		break;
 
 	/* mandatory */
-	case OID_802_3_XMIT_ONE_COLLISION:
-		pr_debug("%s: OID_802_3_XMIT_ONE_COLLISION\n", __func__);
+	case RNDIS_OID_802_3_XMIT_ONE_COLLISION:
+		pr_debug("%s: RNDIS_OID_802_3_XMIT_ONE_COLLISION\n", __func__);
 		*outbuf = cpu_to_le32(0);
 		retval = 0;
 		break;
 
 	/* mandatory */
-	case OID_802_3_XMIT_MORE_COLLISIONS:
-		pr_debug("%s: OID_802_3_XMIT_MORE_COLLISIONS\n", __func__);
+	case RNDIS_OID_802_3_XMIT_MORE_COLLISIONS:
+		pr_debug("%s: RNDIS_OID_802_3_XMIT_MORE_COLLISIONS\n", __func__);
 		*outbuf = cpu_to_le32(0);
 		retval = 0;
 		break;
@@ -545,9 +545,9 @@ static int gen_ndis_set_resp(u8 configNr, u32 OID, u8 *buf, u32 buf_len,
 		}
 		break;
 
-	case OID_802_3_MULTICAST_LIST:
+	case RNDIS_OID_802_3_MULTICAST_LIST:
 		/* I think we can ignore this */
-		pr_debug("%s: OID_802_3_MULTICAST_LIST\n", __func__);
+		pr_debug("%s: RNDIS_OID_802_3_MULTICAST_LIST\n", __func__);
 		retval = 0;
 		break;
 
diff --git a/include/linux/rndis.h b/include/linux/rndis.h
index ebc40b3..62aecb7 100644
--- a/include/linux/rndis.h
+++ b/include/linux/rndis.h
@@ -70,21 +70,6 @@
 /* IEEE 802.3 (Ethernet) OIDs */
 #define NDIS_802_3_MAC_OPTION_PRIORITY    0x00000001
 
-#define OID_802_3_CURRENT_ADDRESS         0x01010102
-#define OID_802_3_MULTICAST_LIST          0x01010103
-#define OID_802_3_MAXIMUM_LIST_SIZE       0x01010104
-#define OID_802_3_MAC_OPTIONS             0x01010105
-#define OID_802_3_RCV_ERROR_ALIGNMENT     0x01020101
-#define OID_802_3_XMIT_ONE_COLLISION      0x01020102
-#define OID_802_3_XMIT_MORE_COLLISIONS    0x01020103
-#define OID_802_3_XMIT_DEFERRED           0x01020201
-#define OID_802_3_XMIT_MAX_COLLISIONS     0x01020202
-#define OID_802_3_RCV_OVERRUN             0x01020203
-#define OID_802_3_XMIT_UNDERRUN           0x01020204
-#define OID_802_3_XMIT_HEARTBEAT_FAILURE  0x01020205
-#define OID_802_3_XMIT_TIMES_CRS_LOST     0x01020206
-#define OID_802_3_XMIT_LATE_COLLISIONS    0x01020207
-
 /* RNDIS_OID_GEN_MINIPORT_INFO constants */
 #define NDIS_MINIPORT_BUS_MASTER                      0x00000001
 #define NDIS_MINIPORT_WDM_DRIVER                      0x00000002
@@ -402,6 +387,33 @@
 #define RNDIS_OID_802_3_XMIT_TIMES_CRS_LOST	0x01020206
 #define RNDIS_OID_802_3_XMIT_LATE_COLLISIONS	0x01020207
 
+#define RNDIS_OID_802_11_BSSID				0x0d010101
+#define RNDIS_OID_802_11_SSID				0x0d010102
+#define RNDIS_OID_802_11_INFRASTRUCTURE_MODE		0x0d010108
+#define RNDIS_OID_802_11_ADD_WEP			0x0d010113
+#define RNDIS_OID_802_11_REMOVE_WEP			0x0d010114
+#define RNDIS_OID_802_11_DISASSOCIATE			0x0d010115
+#define RNDIS_OID_802_11_AUTHENTICATION_MODE		0x0d010118
+#define RNDIS_OID_802_11_PRIVACY_FILTER			0x0d010119
+#define RNDIS_OID_802_11_BSSID_LIST_SCAN		0x0d01011a
+#define RNDIS_OID_802_11_ENCRYPTION_STATUS		0x0d01011b
+#define RNDIS_OID_802_11_ADD_KEY			0x0d01011d
+#define RNDIS_OID_802_11_REMOVE_KEY			0x0d01011e
+#define RNDIS_OID_802_11_ASSOCIATION_INFORMATION	0x0d01011f
+#define RNDIS_OID_802_11_CAPABILITY			0x0d010122
+#define RNDIS_OID_802_11_PMKID				0x0d010123
+#define RNDIS_OID_802_11_NETWORK_TYPES_SUPPORTED	0x0d010203
+#define RNDIS_OID_802_11_NETWORK_TYPE_IN_USE		0x0d010204
+#define RNDIS_OID_802_11_TX_POWER_LEVEL			0x0d010205
+#define RNDIS_OID_802_11_RSSI				0x0d010206
+#define RNDIS_OID_802_11_RSSI_TRIGGER			0x0d010207
+#define RNDIS_OID_802_11_FRAGMENTATION_THRESHOLD	0x0d010209
+#define RNDIS_OID_802_11_RTS_THRESHOLD			0x0d01020a
+#define RNDIS_OID_802_11_SUPPORTED_RATES		0x0d01020e
+#define RNDIS_OID_802_11_CONFIGURATION			0x0d010211
+#define RNDIS_OID_802_11_POWER_MODE			0x0d010216
+#define RNDIS_OID_802_11_BSSID_LIST			0x0d010217
+
 #define REMOTE_CONDIS_MP_CREATE_VC_MSG		0x00008001
 #define REMOTE_CONDIS_MP_DELETE_VC_MSG		0x00008002
 #define REMOTE_CONDIS_MP_ACTIVATE_VC_MSG	0x00008005
@@ -438,37 +450,3 @@
 /* Remote NDIS medium connection states. */
 #define RNDIS_MEDIA_STATE_CONNECTED		0x00000000
 #define RNDIS_MEDIA_STATE_DISCONNECTED		0x00000001
-
-/* From drivers/net/wireless/rndis_wlan.c */
-
-/* various RNDIS OID defs */
-#define OID_802_3_CURRENT_ADDRESS		0x01010102
-#define OID_802_3_MULTICAST_LIST		0x01010103
-#define OID_802_3_MAXIMUM_LIST_SIZE		0x01010104
-
-#define OID_802_11_BSSID			0x0d010101
-#define OID_802_11_SSID				0x0d010102
-#define OID_802_11_INFRASTRUCTURE_MODE		0x0d010108
-#define OID_802_11_ADD_WEP			0x0d010113
-#define OID_802_11_REMOVE_WEP			0x0d010114
-#define OID_802_11_DISASSOCIATE			0x0d010115
-#define OID_802_11_AUTHENTICATION_MODE		0x0d010118
-#define OID_802_11_PRIVACY_FILTER		0x0d010119
-#define OID_802_11_BSSID_LIST_SCAN		0x0d01011a
-#define OID_802_11_ENCRYPTION_STATUS		0x0d01011b
-#define OID_802_11_ADD_KEY			0x0d01011d
-#define OID_802_11_REMOVE_KEY			0x0d01011e
-#define OID_802_11_ASSOCIATION_INFORMATION	0x0d01011f
-#define OID_802_11_CAPABILITY			0x0d010122
-#define OID_802_11_PMKID			0x0d010123
-#define OID_802_11_NETWORK_TYPES_SUPPORTED	0x0d010203
-#define OID_802_11_NETWORK_TYPE_IN_USE		0x0d010204
-#define OID_802_11_TX_POWER_LEVEL		0x0d010205
-#define OID_802_11_RSSI				0x0d010206
-#define OID_802_11_RSSI_TRIGGER			0x0d010207
-#define OID_802_11_FRAGMENTATION_THRESHOLD	0x0d010209
-#define OID_802_11_RTS_THRESHOLD		0x0d01020a
-#define OID_802_11_SUPPORTED_RATES		0x0d01020e
-#define OID_802_11_CONFIGURATION		0x0d010211
-#define OID_802_11_POWER_MODE			0x0d010216
-#define OID_802_11_BSSID_LIST			0x0d010217
-- 
1.7.7.6
