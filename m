From: "Linus Walleij" <linus.walleij@linaro.org>
Subject: [PATCH 17/17 v5] rndis_wlan: cleanup: change oid from __le32 to u32 in various places
Date: Sat, 12 May 2012 10:17:57 +0200
Message-ID: <1336810677-6846-1-git-send-email-linus.walleij@linaro.org>
Cc: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Ben Hutchings <ben@decadent.org.uk>,
	Linus Walleij <linus.walleij@linaro.org>
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.df.lth.se ([194.47.250.12]:51231 "EHLO mail.df.lth.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753799Ab2ELISC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2012 04:18:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/wireless/rndis_wlan.c |   98 ++++++++++++++++++------------------
 1 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index c7f22cd..3347286 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -466,7 +466,7 @@ struct rndis_wlan_private {
 	int infra_mode;
 	bool connected;
 	u8 bssid[ETH_ALEN];
-	__le32 current_command_oid;
+	u32 current_command_oid;
 
 	/* encryption stuff */
 	u8 encr_tx_key_index;
@@ -621,9 +621,9 @@ static int rndis_akm_suite_to_key_mgmt(u32 akm_suite)
 }
 
 #ifdef DEBUG
-static const char *oid_to_string(__le32 oid)
+static const char *oid_to_string(u32 oid)
 {
-	switch (le32_to_cpu(oid)) {
+	switch (oid) {
 #define OID_STR(oid) case oid: return(#oid)
 		/* from rndis_host.h */
 		OID_STR(RNDIS_OID_802_3_PERMANENT_ADDRESS);
@@ -677,7 +677,7 @@ static const char *oid_to_string(__le32 oid)
 	return "?";
 }
 #else
-static const char *oid_to_string(__le32 oid)
+static const char *oid_to_string(u32 oid)
 {
 	return "?";
 }
@@ -706,7 +706,7 @@ static int rndis_error_status(__le32 rndis_status)
 	return ret;
 }
 
-static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
+static int rndis_query_oid(struct usbnet *dev, u32 oid, void *data, int *len)
 {
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(dev);
 	union {
@@ -735,7 +735,7 @@ static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
 	memset(u.get, 0, sizeof *u.get);
 	u.get->msg_type = cpu_to_le32(RNDIS_MSG_QUERY);
 	u.get->msg_len = cpu_to_le32(sizeof *u.get);
-	u.get->oid = oid;
+	u.get->oid = cpu_to_le32(oid);
 
 	priv->current_command_oid = oid;
 	ret = rndis_command(dev, u.header, buflen);
@@ -790,7 +790,7 @@ exit_unlock:
 	return ret;
 }
 
-static int rndis_set_oid(struct usbnet *dev, __le32 oid, const void *data,
+static int rndis_set_oid(struct usbnet *dev, u32 oid, const void *data,
 			 int len)
 {
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(dev);
@@ -819,7 +819,7 @@ static int rndis_set_oid(struct usbnet *dev, __le32 oid, const void *data,
 	memset(u.set, 0, sizeof *u.set);
 	u.set->msg_type = cpu_to_le32(RNDIS_MSG_SET);
 	u.set->msg_len = cpu_to_le32(sizeof(*u.set) + len);
-	u.set->oid = oid;
+	u.set->oid = cpu_to_le32(oid);
 	u.set->len = cpu_to_le32(len);
 	u.set->offset = cpu_to_le32(sizeof(*u.set) - 8);
 	u.set->handle = cpu_to_le32(0);
@@ -945,7 +945,7 @@ static int rndis_set_config_parameter(struct usbnet *dev, char *param,
 	}
 #endif
 
-	ret = rndis_set_oid(dev, cpu_to_le32(RNDIS_OID_GEN_RNDIS_CONFIG_PARAMETER),
+	ret = rndis_set_oid(dev, RNDIS_OID_GEN_RNDIS_CONFIG_PARAMETER,
 							infobuf, info_len);
 	if (ret != 0)
 		netdev_dbg(dev->net, "setting rndis config parameter failed, %d\n",
@@ -984,7 +984,7 @@ static int rndis_start_bssid_list_scan(struct usbnet *usbdev)
 
 	/* Note: RNDIS_OID_802_11_BSSID_LIST_SCAN clears internal BSS list. */
 	tmp = cpu_to_le32(1);
-	return rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_BSSID_LIST_SCAN), &tmp,
+	return rndis_set_oid(usbdev, RNDIS_OID_802_11_BSSID_LIST_SCAN, &tmp,
 							sizeof(tmp));
 }
 
@@ -993,7 +993,7 @@ static int set_essid(struct usbnet *usbdev, struct ndis_80211_ssid *ssid)
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 	int ret;
 
-	ret = rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_SSID),
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_SSID,
 			    ssid, sizeof(*ssid));
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "setting SSID failed (%08X)\n", ret);
@@ -1011,7 +1011,7 @@ static int set_bssid(struct usbnet *usbdev, const u8 *bssid)
 {
 	int ret;
 
-	ret = rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_BSSID),
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_BSSID,
 			    bssid, ETH_ALEN);
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "setting BSSID[%pM] failed (%08X)\n",
@@ -1036,7 +1036,7 @@ static int get_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 	int ret, len;
 
 	len = ETH_ALEN;
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_BSSID),
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_BSSID,
 			      bssid, &len);
 
 	if (ret != 0)
@@ -1049,7 +1049,7 @@ static int get_association_info(struct usbnet *usbdev,
 			struct ndis_80211_assoc_info *info, int len)
 {
 	return rndis_query_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_ASSOCIATION_INFORMATION),
+			RNDIS_OID_802_11_ASSOCIATION_INFORMATION,
 			info, &len);
 }
 
@@ -1075,7 +1075,7 @@ static int disassociate(struct usbnet *usbdev, bool reset_ssid)
 
 	if (priv->radio_on) {
 		ret = rndis_set_oid(usbdev,
-				cpu_to_le32(RNDIS_OID_802_11_DISASSOCIATE),
+				RNDIS_OID_802_11_DISASSOCIATE,
 				NULL, 0);
 		if (ret == 0) {
 			priv->radio_on = false;
@@ -1139,7 +1139,7 @@ static int set_auth_mode(struct usbnet *usbdev, u32 wpa_version,
 
 	tmp = cpu_to_le32(auth_mode);
 	ret = rndis_set_oid(usbdev,
-			    cpu_to_le32(RNDIS_OID_802_11_AUTHENTICATION_MODE),
+			    RNDIS_OID_802_11_AUTHENTICATION_MODE,
 			    &tmp, sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting auth mode failed (%08X)\n",
@@ -1167,7 +1167,7 @@ static int set_priv_filter(struct usbnet *usbdev)
 		tmp = cpu_to_le32(NDIS_80211_PRIV_ACCEPT_ALL);
 
 	return rndis_set_oid(usbdev,
-			     cpu_to_le32(RNDIS_OID_802_11_PRIVACY_FILTER), &tmp,
+			     RNDIS_OID_802_11_PRIVACY_FILTER, &tmp,
 			     sizeof(tmp));
 }
 
@@ -1194,7 +1194,7 @@ static int set_encr_mode(struct usbnet *usbdev, int pairwise, int groupwise)
 
 	tmp = cpu_to_le32(encr_mode);
 	ret = rndis_set_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_ENCRYPTION_STATUS), &tmp,
+			RNDIS_OID_802_11_ENCRYPTION_STATUS, &tmp,
 			sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting encr mode failed (%08X)\n",
@@ -1216,7 +1216,7 @@ static int set_infra_mode(struct usbnet *usbdev, int mode)
 
 	tmp = cpu_to_le32(mode);
 	ret = rndis_set_oid(usbdev,
-			    cpu_to_le32(RNDIS_OID_802_11_INFRASTRUCTURE_MODE),
+			    RNDIS_OID_802_11_INFRASTRUCTURE_MODE,
 			    &tmp, sizeof(tmp));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "setting infra mode failed (%08X)\n",
@@ -1244,7 +1244,7 @@ static int set_rts_threshold(struct usbnet *usbdev, u32 rts_threshold)
 
 	tmp = cpu_to_le32(rts_threshold);
 	return rndis_set_oid(usbdev,
-			     cpu_to_le32(RNDIS_OID_802_11_RTS_THRESHOLD),
+			     RNDIS_OID_802_11_RTS_THRESHOLD,
 			     &tmp, sizeof(tmp));
 }
 
@@ -1259,7 +1259,7 @@ static int set_frag_threshold(struct usbnet *usbdev, u32 frag_threshold)
 
 	tmp = cpu_to_le32(frag_threshold);
 	return rndis_set_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_FRAGMENTATION_THRESHOLD),
+			RNDIS_OID_802_11_FRAGMENTATION_THRESHOLD,
 			&tmp, sizeof(tmp));
 }
 
@@ -1297,7 +1297,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 
 	len = sizeof(config);
 	ret = rndis_query_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_CONFIGURATION),
+			RNDIS_OID_802_11_CONFIGURATION,
 			&config, &len);
 	if (ret < 0) {
 		netdev_dbg(usbdev->net, "%s(): querying configuration failed\n",
@@ -1307,7 +1307,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 
 	config.ds_config = cpu_to_le32(dsconfig);
 	ret = rndis_set_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_CONFIGURATION),
+			RNDIS_OID_802_11_CONFIGURATION,
 			&config, sizeof(config));
 
 	netdev_dbg(usbdev->net, "%s(): %d -> %d\n", __func__, channel, ret);
@@ -1326,7 +1326,7 @@ static struct ieee80211_channel *get_current_channel(struct usbnet *usbdev,
 	/* Get channel and beacon interval */
 	len = sizeof(config);
 	ret = rndis_query_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_CONFIGURATION),
+			RNDIS_OID_802_11_CONFIGURATION,
 			&config, &len);
 	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_CONFIGURATION -> %d\n",
 				__func__, ret);
@@ -1382,7 +1382,7 @@ static int add_wep_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	}
 
 	ret = rndis_set_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_ADD_WEP), &ndis_key,
+			RNDIS_OID_802_11_ADD_WEP, &ndis_key,
 			sizeof(ndis_key));
 	if (ret != 0) {
 		netdev_warn(usbdev->net, "adding encryption key %d failed (%08X)\n",
@@ -1474,7 +1474,7 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	}
 
 	ret = rndis_set_oid(usbdev,
-			cpu_to_le32(RNDIS_OID_802_11_ADD_KEY), &ndis_key,
+			RNDIS_OID_802_11_ADD_KEY, &ndis_key,
 			le32_to_cpu(ndis_key.size));
 	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_ADD_KEY -> %08X\n",
 		   __func__, ret);
@@ -1565,14 +1565,14 @@ static int remove_key(struct usbnet *usbdev, u8 index, const u8 *bssid)
 						sizeof(remove_key.bssid));
 
 		ret = rndis_set_oid(usbdev,
-				cpu_to_le32(RNDIS_OID_802_11_REMOVE_KEY),
+				RNDIS_OID_802_11_REMOVE_KEY,
 				&remove_key, sizeof(remove_key));
 		if (ret != 0)
 			return ret;
 	} else {
 		keyindex = cpu_to_le32(index);
 		ret = rndis_set_oid(usbdev,
-				cpu_to_le32(RNDIS_OID_802_11_REMOVE_WEP),
+				RNDIS_OID_802_11_REMOVE_WEP,
 				&keyindex, sizeof(keyindex));
 		if (ret != 0) {
 			netdev_warn(usbdev->net,
@@ -1642,7 +1642,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 
 	if (mc_count) {
 		ret = rndis_set_oid(usbdev,
-				cpu_to_le32(RNDIS_OID_802_3_MULTICAST_LIST),
+				RNDIS_OID_802_3_MULTICAST_LIST,
 				mc_addrs, mc_count * ETH_ALEN);
 		kfree(mc_addrs);
 		if (ret == 0)
@@ -1655,7 +1655,7 @@ static void set_multicast_list(struct usbnet *usbdev)
 	}
 
 set_filter:
-	ret = rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_GEN_CURRENT_PACKET_FILTER), &filter,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_GEN_CURRENT_PACKET_FILTER, &filter,
 							sizeof(filter));
 	if (ret < 0) {
 		netdev_warn(usbdev->net, "couldn't set packet filter: %08x\n",
@@ -1721,7 +1721,7 @@ static struct ndis_80211_pmkid *get_device_pmkids(struct usbnet *usbdev)
 	pmkids->length = cpu_to_le32(len);
 	pmkids->bssid_info_count = cpu_to_le32(max_pmkids);
 
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_PMKID),
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_PMKID,
 			pmkids, &len);
 	if (ret < 0) {
 		netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_PMKID(%d, %d)"
@@ -1750,7 +1750,7 @@ static int set_device_pmkids(struct usbnet *usbdev,
 
 	debug_print_pmkids(usbdev, pmkids, __func__);
 
-	ret = rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_PMKID), pmkids,
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_PMKID, pmkids,
 			    le32_to_cpu(pmkids->length));
 	if (ret < 0) {
 		netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_PMKID(%d, %d) -> %d"
@@ -2087,7 +2087,7 @@ resize_buf:
 	 * resizing until it won't get any bigger.
 	 */
 	new_len = len;
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_BSSID_LIST),
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_BSSID_LIST,
 			      buf, &new_len);
 	if (ret != 0 || new_len < sizeof(struct ndis_80211_bssid_list_ex))
 		goto out;
@@ -2486,14 +2486,14 @@ static void rndis_fill_station_info(struct usbnet *usbdev,
 	memset(sinfo, 0, sizeof(*sinfo));
 
 	len = sizeof(linkspeed);
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_GEN_LINK_SPEED), &linkspeed, &len);
+	ret = rndis_query_oid(usbdev, RNDIS_OID_GEN_LINK_SPEED, &linkspeed, &len);
 	if (ret == 0) {
 		sinfo->txrate.legacy = le32_to_cpu(linkspeed) / 1000;
 		sinfo->filled |= STATION_INFO_TX_BITRATE;
 	}
 
 	len = sizeof(rssi);
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_RSSI),
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_RSSI,
 			      &rssi, &len);
 	if (ret == 0) {
 		sinfo->signal = level_to_qual(le32_to_cpu(rssi));
@@ -2600,7 +2600,7 @@ static int rndis_flush_pmksa(struct wiphy *wiphy, struct net_device *netdev)
 	pmkid.length = cpu_to_le32(sizeof(pmkid));
 	pmkid.bssid_info_count = cpu_to_le32(0);
 
-	return rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_PMKID),
+	return rndis_set_oid(usbdev, RNDIS_OID_802_11_PMKID,
 			     &pmkid, sizeof(pmkid));
 }
 
@@ -2631,7 +2631,7 @@ static int rndis_set_power_mgmt(struct wiphy *wiphy, struct net_device *dev,
 	priv->power_mode = power_mode;
 
 	mode = cpu_to_le32(power_mode);
-	ret = rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_POWER_MODE),
+	ret = rndis_set_oid(usbdev, RNDIS_OID_802_11_POWER_MODE,
 			    &mode, sizeof(mode));
 
 	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_POWER_MODE -> %d\n",
@@ -2671,7 +2671,7 @@ static void rndis_wlan_craft_connected_bss(struct usbnet *usbdev, u8 *bssid,
 	/* Get signal quality, in case of error use rssi=0 and ignore error. */
 	len = sizeof(rssi);
 	rssi = 0;
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_RSSI),
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_RSSI,
 			      &rssi, &len);
 	signal = level_to_qual(le32_to_cpu(rssi));
 
@@ -2699,7 +2699,7 @@ static void rndis_wlan_craft_connected_bss(struct usbnet *usbdev, u8 *bssid,
 	/* Get SSID, in case of error, use zero length SSID and ignore error. */
 	len = sizeof(ssid);
 	memset(&ssid, 0, sizeof(ssid));
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_SSID),
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_SSID,
 			      &ssid, &len);
 	netdev_dbg(usbdev->net, "%s(): RNDIS_OID_802_11_SSID -> %d, len: %d, ssid: "
 				"'%.32s'\n", __func__, ret,
@@ -3077,8 +3077,8 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 
 	switch (le32_to_cpu(msg->status)) {
 	case RNDIS_STATUS_MEDIA_CONNECT:
-		if (priv->current_command_oid == cpu_to_le32(RNDIS_OID_802_11_ADD_KEY)) {
-			/* OID_802_11_ADD_KEY causes sometimes extra
+		if (priv->current_command_oid == RNDIS_OID_802_11_ADD_KEY) {
+			/* RNDIS_OID_802_11_ADD_KEY causes sometimes extra
 			 * "media connect" indications which confuses driver
 			 * and userspace to think that device is
 			 * roaming/reassociating when it isn't.
@@ -3129,7 +3129,7 @@ static int rndis_wlan_get_caps(struct usbnet *usbdev, struct wiphy *wiphy)
 	/* determine supported modes */
 	len = sizeof(networks_supported);
 	retval = rndis_query_oid(usbdev,
-				 cpu_to_le32(RNDIS_OID_802_11_NETWORK_TYPES_SUPPORTED),
+				 RNDIS_OID_802_11_NETWORK_TYPES_SUPPORTED,
 				 &networks_supported, &len);
 	if (retval >= 0) {
 		n = le32_to_cpu(networks_supported.num_items);
@@ -3155,7 +3155,7 @@ static int rndis_wlan_get_caps(struct usbnet *usbdev, struct wiphy *wiphy)
 	caps = (struct ndis_80211_capability *)caps_buf;
 	len = sizeof(caps_buf);
 	retval = rndis_query_oid(usbdev,
-				 cpu_to_le32(RNDIS_OID_802_11_CAPABILITY),
+				 RNDIS_OID_802_11_CAPABILITY,
 				 caps, &len);
 	if (retval >= 0) {
 		netdev_dbg(usbdev->net, "RNDIS_OID_802_11_CAPABILITY -> len %d, "
@@ -3230,7 +3230,7 @@ static void rndis_device_poller(struct work_struct *work)
 	}
 
 	len = sizeof(rssi);
-	ret = rndis_query_oid(usbdev, cpu_to_le32(RNDIS_OID_802_11_RSSI),
+	ret = rndis_query_oid(usbdev, RNDIS_OID_802_11_RSSI,
 			      &rssi, &len);
 	if (ret == 0) {
 		priv->last_qual = level_to_qual(le32_to_cpu(rssi));
@@ -3260,7 +3260,7 @@ static void rndis_device_poller(struct work_struct *work)
 		 */
 		tmp = cpu_to_le32(1);
 		rndis_set_oid(usbdev,
-			      cpu_to_le32(RNDIS_OID_802_11_BSSID_LIST_SCAN),
+			      RNDIS_OID_802_11_BSSID_LIST_SCAN,
 			      &tmp, sizeof(tmp));
 
 		len = CONTROL_BUFFER_SIZE;
@@ -3269,7 +3269,7 @@ static void rndis_device_poller(struct work_struct *work)
 			goto end;
 
 		rndis_query_oid(usbdev,
-				cpu_to_le32(RNDIS_OID_802_11_BSSID_LIST),
+				RNDIS_OID_802_11_BSSID_LIST,
 				buf, &len);
 		kfree(buf);
 	}
@@ -3454,12 +3454,12 @@ static int rndis_wlan_bind(struct usbnet *usbdev, struct usb_interface *intf)
 
 	tmp = cpu_to_le32(RNDIS_PACKET_TYPE_DIRECTED | RNDIS_PACKET_TYPE_BROADCAST);
 	retval = rndis_set_oid(usbdev,
-			       cpu_to_le32(RNDIS_OID_GEN_CURRENT_PACKET_FILTER),
+			       RNDIS_OID_GEN_CURRENT_PACKET_FILTER,
 			       &tmp, sizeof(tmp));
 
 	len = sizeof(tmp);
 	retval = rndis_query_oid(usbdev,
-				 cpu_to_le32(RNDIS_OID_802_3_MAXIMUM_LIST_SIZE),
+				 RNDIS_OID_802_3_MAXIMUM_LIST_SIZE,
 				 &tmp, &len);
 	priv->multicast_size = le32_to_cpu(tmp);
 	if (retval < 0 || priv->multicast_size < 0)
@@ -3590,7 +3590,7 @@ static int rndis_wlan_stop(struct usbnet *usbdev)
 	/* Set current packet filter zero to block receiving data packets from
 	   device. */
 	filter = 0;
-	rndis_set_oid(usbdev, cpu_to_le32(RNDIS_OID_GEN_CURRENT_PACKET_FILTER), &filter,
+	rndis_set_oid(usbdev, RNDIS_OID_GEN_CURRENT_PACKET_FILTER, &filter,
 								sizeof(filter));
 
 	return retval;
-- 
1.7.7.6
