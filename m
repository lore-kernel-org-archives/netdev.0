From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 3/4 #2] Net: mac80211, remove bitfields from struct ieee80211_if_sta
Date: Sat, 18 Aug 2007 10:54:54 +0200 (CEST)
Message-ID: <21967225262149826017@wsc.cz>
References: <25024219461172228260@wsc.cz>
Cc: <jbenc@suse.cz>
To: <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cacti.profiwh.com ([85.93.165.66]:38205 "EHLO smtp.wsc.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751561AbXHRIxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2007 04:53:35 -0400
In-reply-to: <25024219461172228260@wsc.cz>
Cc: <flamingice@sourmilk.net>
Cc: <jeff@garzik.org>
Cc: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mac80211, remove bitfields from struct ieee80211_if_sta

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit 5d3b17704c1cb1d8c8ff45f72282918f89e1d5c0
tree 41c8b637c79728517d647edc8f0e41f544ccefbc
parent bb1e8d28c269abe10378d39c2050ad2653c4f1a9
author Jiri Slaby <jirislaby@gmail.com> Sat, 18 Aug 2007 10:39:52 +0200
committer Jiri Slaby <jirislaby@gmail.com> Sat, 18 Aug 2007 10:39:52 +0200

 net/mac80211/debugfs_netdev.c  |   14 +++--
 net/mac80211/ieee80211.c       |    2 -
 net/mac80211/ieee80211_i.h     |   28 ++++++-----
 net/mac80211/ieee80211_iface.c |    9 ++-
 net/mac80211/ieee80211_ioctl.c |   57 +++++++++++++++-------
 net/mac80211/ieee80211_sta.c   |  104 ++++++++++++++++++++++------------------
 6 files changed, 123 insertions(+), 91 deletions(-)

diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 806c5bd..fa3b153 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -373,13 +373,13 @@ static ssize_t ieee80211_if_fmt_flags(
 	const struct ieee80211_sub_if_data *sdata, char *buf, int buflen)
 {
 	return scnprintf(buf, buflen, "%s%s%s%s%s%s%s\n",
-			 sdata->u.sta.ssid_set ? "SSID\n" : "",
-			 sdata->u.sta.bssid_set ? "BSSID\n" : "",
-			 sdata->u.sta.prev_bssid_set ? "prev BSSID\n" : "",
-			 sdata->u.sta.authenticated ? "AUTH\n" : "",
-			 sdata->u.sta.associated ? "ASSOC\n" : "",
-			 sdata->u.sta.probereq_poll ? "PROBEREQ POLL\n" : "",
-			 sdata->use_protection ? "CTS prot\n" : "");
+		 sdata->u.sta.flags & IEEE80211_STA_SSID_SET ? "SSID\n" : "",
+		 sdata->u.sta.flags & IEEE80211_STA_BSSID_SET ? "BSSID\n" : "",
+		 sdata->u.sta.flags & IEEE80211_STA_PREV_BSSID_SET ? "prev BSSID\n" : "",
+		 sdata->u.sta.flags & IEEE80211_STA_AUTHENTICATED ? "AUTH\n" : "",
+		 sdata->u.sta.flags & IEEE80211_STA_ASSOCIATED ? "ASSOC\n" : "",
+		 sdata->u.sta.flags & IEEE80211_STA_PROBEREQ_POLL ? "PROBEREQ POLL\n" : "",
+		 sdata->use_protection ? "CTS prot\n" : "");
 }
 __IEEE80211_IF_FILE(flags);
 
diff --git a/net/mac80211/ieee80211.c b/net/mac80211/ieee80211.c
index 0952237..8a6e66f 100644
--- a/net/mac80211/ieee80211.c
+++ b/net/mac80211/ieee80211.c
@@ -382,7 +382,7 @@ static void ieee80211_if_open(struct net_device *dev)
 	switch (sdata->type) {
 	case IEEE80211_IF_TYPE_STA:
 	case IEEE80211_IF_TYPE_IBSS:
-		sdata->u.sta.prev_bssid_set = 0;
+		sdata->u.sta.flags &= ~IEEE80211_STA_PREV_BSSID_SET;
 		break;
 	}
 }
diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 0c4b73c..de429d1 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -241,6 +241,20 @@ struct ieee80211_if_vlan {
 	u8 id;
 };
 
+/* flags used in struct ieee80211_if_sta.flags */
+#define IEEE80211_STA_SSID_SET		BIT(0)
+#define IEEE80211_STA_BSSID_SET		BIT(1)
+#define IEEE80211_STA_PREV_BSSID_SET	BIT(2)
+#define IEEE80211_STA_AUTHENTICATED	BIT(3)
+#define IEEE80211_STA_ASSOCIATED	BIT(4)
+#define IEEE80211_STA_PROBEREQ_POLL	BIT(5)
+#define IEEE80211_STA_CREATE_IBSS	BIT(6)
+#define IEEE80211_STA_MIXED_CELL	BIT(7)
+#define IEEE80211_STA_WMM_ENABLED	BIT(8)
+#define IEEE80211_STA_HT_ENABLED	BIT(9)
+#define IEEE80211_STA_AUTO_SSID_SEL	BIT(10)
+#define IEEE80211_STA_AUTO_BSSID_SEL	BIT(11)
+#define IEEE80211_STA_AUTO_CHANNEL_SEL	BIT(12)
 struct ieee80211_if_sta {
 	enum {
 		IEEE80211_DISABLED, IEEE80211_AUTHENTICATE,
@@ -264,19 +278,7 @@ struct ieee80211_if_sta {
 
 	int auth_tries, assoc_tries;
 
-	unsigned int ssid_set:1;
-	unsigned int bssid_set:1;
-	unsigned int prev_bssid_set:1;
-	unsigned int authenticated:1;
-	unsigned int associated:1;
-	unsigned int probereq_poll:1;
-	unsigned int create_ibss:1;
-	unsigned int mixed_cell:1;
-	unsigned int wmm_enabled:1;
-	unsigned int ht_enabled:1;
-	unsigned int auto_ssid_sel:1;
-	unsigned int auto_bssid_sel:1;
-	unsigned int auto_channel_sel:1;
+	unsigned int flags;
 #define IEEE80211_STA_REQ_SCAN 0
 #define IEEE80211_STA_REQ_AUTH 1
 #define IEEE80211_STA_REQ_RUN  2
diff --git a/net/mac80211/ieee80211_iface.c b/net/mac80211/ieee80211_iface.c
index edd1535..c5e0288 100644
--- a/net/mac80211/ieee80211_iface.c
+++ b/net/mac80211/ieee80211_iface.c
@@ -191,11 +191,10 @@ void ieee80211_if_set_type(struct net_device *dev, int type)
 		ifsta->capab = WLAN_CAPABILITY_ESS;
 		ifsta->auth_algs = IEEE80211_AUTH_ALG_OPEN |
 			IEEE80211_AUTH_ALG_SHARED_KEY;
-		ifsta->create_ibss = 1;
-		ifsta->wmm_enabled = 1;
-		ifsta->ht_enabled = 1;
-		ifsta->auto_channel_sel = 1;
-		ifsta->auto_bssid_sel = 1;
+		ifsta->flags |= IEEE80211_STA_CREATE_IBSS |
+			IEEE80211_STA_WMM_ENABLED | IEEE80211_STA_HT_ENABLED |
+			IEEE80211_STA_AUTO_BSSID_SEL |
+			IEEE80211_STA_AUTO_CHANNEL_SEL;
 
 		/* Initialize non-AP QSTA QoS Params */
 		ifsta->dot11EDCAAveragingPeriod = 5;
diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 009ed1c..6283e83 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -1113,7 +1113,7 @@ static int ieee80211_set_gen_ie(struct net_device *dev, u8 *ie, size_t len)
 		int ret = ieee80211_sta_set_extra_ie(dev, ie, len);
 		if (ret)
 			return ret;
-		sdata->u.sta.auto_bssid_sel = 0;
+		sdata->u.sta.flags &= ~IEEE80211_STA_AUTO_BSSID_SEL;
 		ieee80211_sta_req_auth(dev, &sdata->u.sta);
 		return 0;
 	}
@@ -1615,13 +1615,14 @@ static int ieee80211_ioctl_siwfreq(struct net_device *dev,
 	struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (sdata->type == IEEE80211_IF_TYPE_STA)
-		sdata->u.sta.auto_channel_sel = 0;
+		sdata->u.sta.flags &= ~IEEE80211_STA_AUTO_CHANNEL_SEL;
 
 	/* freq->e == 0: freq->m = channel; otherwise freq = m * 10^e */
 	if (freq->e == 0) {
 		if (freq->m < 0) {
 			if (sdata->type == IEEE80211_IF_TYPE_STA)
-				sdata->u.sta.auto_channel_sel = 1;
+				sdata->u.sta.flags |=
+					IEEE80211_STA_AUTO_CHANNEL_SEL;
 			return 0;
 		} else
 			return ieee80211_set_channel(local, freq->m, -1);
@@ -1676,7 +1677,10 @@ static int ieee80211_ioctl_siwessid(struct net_device *dev,
 			sdata->u.sta.ssid_len = len;
 			return 0;
 		}
-		sdata->u.sta.auto_ssid_sel = !data->flags;
+		if (data->flags)
+			sdata->u.sta.flags &= ~IEEE80211_STA_AUTO_SSID_SEL;
+		else
+			sdata->u.sta.flags |= IEEE80211_STA_AUTO_SSID_SEL;
 		ret = ieee80211_sta_set_ssid(dev, ssid, len);
 		if (ret)
 			return ret;
@@ -1743,13 +1747,13 @@ static int ieee80211_ioctl_siwap(struct net_device *dev,
 			       ETH_ALEN);
 			return 0;
 		}
-		if (is_zero_ether_addr((u8 *) &ap_addr->sa_data)) {
-			sdata->u.sta.auto_bssid_sel = 1;
-			sdata->u.sta.auto_channel_sel = 1;
-		} else if (is_broadcast_ether_addr((u8 *) &ap_addr->sa_data))
-			sdata->u.sta.auto_bssid_sel = 1;
+		if (is_zero_ether_addr((u8 *) &ap_addr->sa_data))
+			sdata->u.sta.flags |= IEEE80211_STA_AUTO_BSSID_SEL |
+				IEEE80211_STA_AUTO_CHANNEL_SEL;
+		else if (is_broadcast_ether_addr((u8 *) &ap_addr->sa_data))
+			sdata->u.sta.flags |= IEEE80211_STA_AUTO_BSSID_SEL;
 		else
-			sdata->u.sta.auto_bssid_sel = 0;
+			sdata->u.sta.flags &= ~IEEE80211_STA_AUTO_BSSID_SEL;
 		ret = ieee80211_sta_set_bssid(dev, (u8 *) &ap_addr->sa_data);
 		if (ret)
 			return ret;
@@ -2294,8 +2298,12 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
-		else
-			sdata->u.sta.mixed_cell = !!value;
+		else {
+			if (value)
+				sdata->u.sta.flags |= IEEE80211_STA_MIXED_CELL;
+			else
+				sdata->u.sta.flags &= ~IEEE80211_STA_MIXED_CELL;
+		}
 		break;
 
 	case PRISM2_PARAM_KEY_MGMT:
@@ -2312,15 +2320,23 @@ static int ieee80211_ioctl_prism2_param(struct net_device *dev,
 	case PRISM2_PARAM_CREATE_IBSS:
 		if (sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
-		else
-			sdata->u.sta.create_ibss = !!value;
+		else {
+			if (value)
+				sdata->u.sta.flags |= IEEE80211_STA_CREATE_IBSS;
+			else
+				sdata->u.sta.flags &= ~IEEE80211_STA_CREATE_IBSS;
+		}
 		break;
 	case PRISM2_PARAM_WMM_ENABLED:
 		if (sdata->type != IEEE80211_IF_TYPE_STA &&
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
-		else
-			sdata->u.sta.wmm_enabled = !!value;
+		else {
+			if (value)
+				sdata->u.sta.flags |= IEEE80211_STA_WMM_ENABLED;
+			else
+				sdata->u.sta.flags &= ~IEEE80211_STA_WMM_ENABLED;
+		}
 		break;
 	case PRISM2_PARAM_RADAR_DETECT:
 		local->hw.conf.radar_detect = value;
@@ -2463,7 +2479,8 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 		if (sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
-			*param = !!sdata->u.sta.create_ibss;
+			*param = !!(sdata->u.sta.flags &
+					IEEE80211_STA_CREATE_IBSS);
 		break;
 
 	case PRISM2_PARAM_MIXED_CELL:
@@ -2471,7 +2488,8 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
-			*param = !!sdata->u.sta.mixed_cell;
+			*param = !!(sdata->u.sta.flags &
+					IEEE80211_STA_MIXED_CELL);
 		break;
 
 	case PRISM2_PARAM_KEY_MGMT:
@@ -2485,7 +2503,8 @@ static int ieee80211_ioctl_get_prism2_param(struct net_device *dev,
 		    sdata->type != IEEE80211_IF_TYPE_IBSS)
 			ret = -EINVAL;
 		else
-			*param = !!sdata->u.sta.wmm_enabled;
+			*param = !!(sdata->u.sta.flags &
+					IEEE80211_STA_WMM_ENABLED);
 		break;
 	case PRISM2_PARAM_MGMT_IF:
 		if (local->apdev)
diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 75521ae..e6a1e8d 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -444,18 +444,20 @@ static void ieee80211_sta_send_associnfo(struct net_device *dev,
 
 
 static void ieee80211_set_associated(struct net_device *dev,
-				     struct ieee80211_if_sta *ifsta, int assoc)
+				     struct ieee80211_if_sta *ifsta,
+				     unsigned int assoc)
 {
 	union iwreq_data wrqu;
 
-	if (ifsta->associated == assoc)
+	if (!!(ifsta->flags & IEEE80211_STA_ASSOCIATED) == assoc)
 		return;
 
-	ifsta->associated = assoc;
-
 	if (assoc) {
 		struct ieee80211_sub_if_data *sdata;
 		struct ieee80211_sta_bss *bss;
+
+		ifsta->flags |= IEEE80211_STA_ASSOCIATED;
+
 		sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 		if (sdata->type != IEEE80211_IF_TYPE_STA)
 			return;
@@ -468,11 +470,13 @@ static void ieee80211_set_associated(struct net_device *dev,
 		}
 
 		netif_carrier_on(dev);
-		ifsta->prev_bssid_set = 1;
+		ifsta->flags |= IEEE80211_STA_PREV_BSSID_SET;
 		memcpy(ifsta->prev_bssid, sdata->u.sta.bssid, ETH_ALEN);
 		memcpy(wrqu.ap_addr.sa_data, sdata->u.sta.bssid, ETH_ALEN);
 		ieee80211_sta_send_associnfo(dev, ifsta);
 	} else {
+		ifsta->flags &= ~IEEE80211_STA_ASSOCIATED;
+
 		netif_carrier_off(dev);
 		ieee80211_reset_erp_info(dev);
 		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
@@ -623,7 +627,7 @@ static void ieee80211_send_assoc(struct net_device *dev,
 	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
 	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
 
-	if (ifsta->prev_bssid_set) {
+	if (ifsta->flags & IEEE80211_STA_PREV_BSSID_SET) {
 		skb_put(skb, 10);
 		mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
 						   IEEE80211_STYPE_REASSOC_REQ);
@@ -675,7 +679,7 @@ static void ieee80211_send_assoc(struct net_device *dev,
 		memcpy(pos, ifsta->extra_ie, ifsta->extra_ie_len);
 	}
 
-	if (wmm && ifsta->wmm_enabled) {
+	if (wmm && (ifsta->flags & IEEE80211_STA_WMM_ENABLED)) {
 		pos = skb_put(skb, 9);
 		*pos++ = WLAN_EID_VENDOR_SPECIFIC;
 		*pos++ = 7; /* len */
@@ -690,7 +694,8 @@ static void ieee80211_send_assoc(struct net_device *dev,
 
 #ifdef CONFIG_MAC80211_HT
 	/* if low level driver supports 11n, fill in 11n IE */
-	if (ht_enabled && ifsta->ht_enabled && local->ops->get_ht_capab) {
+	if (ht_enabled && (ifsta->flags & IEEE80211_STA_HT_ENABLED) &&
+	    local->ops->get_ht_capab) {
 		pos = skb_put(skb, sizeof(struct ieee80211_ht_capability)+2);
 		*pos++ = WLAN_EID_HT_CAPABILITY;
 		*pos++ = sizeof(struct ieee80211_ht_capability);
@@ -1170,7 +1175,7 @@ static int ieee80211_privacy_mismatch(struct net_device *dev,
 	struct ieee80211_sta_bss *bss;
 	int res = 0;
 
-	if (!ifsta || ifsta->mixed_cell ||
+	if (!ifsta || (ifsta->flags & IEEE80211_STA_MIXED_CELL) ||
 	    ifsta->key_mgmt != IEEE80211_KEY_MGMT_NONE)
 		return 0;
 
@@ -1239,22 +1244,20 @@ static void ieee80211_associated(struct net_device *dev,
 		disassoc = 0;
 		if (time_after(jiffies,
 			       sta->last_rx + IEEE80211_MONITORING_INTERVAL)) {
-			if (ifsta->probereq_poll) {
+			if (ifsta->flags & IEEE80211_STA_PROBEREQ_POLL) {
 				printk(KERN_DEBUG "%s: No ProbeResp from "
 				       "current AP " MAC_FMT " - assume out of "
 				       "range\n",
 				       dev->name, MAC_ARG(ifsta->bssid));
 				disassoc = 1;
 				sta_info_free(sta);
-				ifsta->probereq_poll = 0;
-			} else {
+			} else
 				ieee80211_send_probe_req(dev, ifsta->bssid,
 							 local->scan_ssid,
 							 local->scan_ssid_len);
-				ifsta->probereq_poll = 1;
-			}
+			ifsta->flags ^= IEEE80211_STA_PROBEREQ_POLL;
 		} else {
-			ifsta->probereq_poll = 0;
+			ifsta->flags &= ~IEEE80211_STA_PROBEREQ_POLL;
 			if (time_after(jiffies, ifsta->last_probe +
 				       IEEE80211_PROBE_INTERVAL)) {
 				ifsta->last_probe = jiffies;
@@ -1358,7 +1361,7 @@ static void ieee80211_auth_completed(struct net_device *dev,
 				     struct ieee80211_if_sta *ifsta)
 {
 	printk(KERN_DEBUG "%s: authenticated\n", dev->name);
-	ifsta->authenticated = 1;
+	ifsta->flags |= IEEE80211_STA_AUTHENTICATED;
 	ieee80211_associate(dev, ifsta);
 }
 
@@ -1545,7 +1548,7 @@ static void ieee80211_rx_mgmt_deauth(struct net_device *dev,
 	       " (reason=%d)\n",
 	       dev->name, MAC_ARG(mgmt->sa), reason_code);
 
-	if (ifsta->authenticated) {
+	if (ifsta->flags & IEEE80211_STA_AUTHENTICATED) {
 		printk(KERN_DEBUG "%s: deauthenticated\n", dev->name);
 	}
 
@@ -1558,7 +1561,7 @@ static void ieee80211_rx_mgmt_deauth(struct net_device *dev,
 	}
 
 	ieee80211_set_disassoc(dev, ifsta, 1);
-	ifsta->authenticated = 0;
+	ifsta->flags &= ~IEEE80211_STA_AUTHENTICATED;
 }
 
 
@@ -1590,7 +1593,7 @@ static void ieee80211_rx_mgmt_disassoc(struct net_device *dev,
 	       " (reason=%d)\n",
 	       dev->name, MAC_ARG(mgmt->sa), reason_code);
 
-	if (ifsta->associated)
+	if (ifsta->flags & IEEE80211_STA_ASSOCIATED)
 		printk(KERN_DEBUG "%s: disassociated\n", dev->name);
 
 	if (ifsta->state == IEEE80211_ASSOCIATED) {
@@ -1662,7 +1665,7 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 		/* if this was a reassociation, ensure we try a "full"
 		 * association next time. This works around some broken APs
 		 * which do not correctly reject reassociation requests. */
-		ifsta->prev_bssid_set = 0;
+		ifsta->flags &= ~IEEE80211_STA_PREV_BSSID_SET;
 		return;
 	}
 
@@ -1748,7 +1751,7 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 	sta->supp_rates = rates;
 #ifdef CONFIG_MAC80211_HT
 	if (elems.ht_extra_param && elems.ht_cap_param && elems.wmm_param &&
-	    ifsta->ht_enabled && local->ops->conf_ht){
+	    (ifsta->flags & IEEE80211_STA_HT_ENABLED) && local->ops->conf_ht) {
 		int rc;
 
 		rc = local->ops->conf_ht(local_to_hw(local),
@@ -1764,7 +1767,7 @@ static void ieee80211_rx_mgmt_assoc_resp(struct net_device *dev,
 
 	rate_control_rate_init(sta, local);
 
-	if (elems.wmm_param && ifsta->wmm_enabled) {
+	if (elems.wmm_param && (ifsta->flags & IEEE80211_STA_WMM_ENABLED)) {
 		sta->flags |= WLAN_STA_WME;
 		ieee80211_sta_wmm_params(dev, ifsta, elems.wmm_param,
 					 elems.wmm_param_len);
@@ -2431,7 +2434,7 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 		return;
 	ifsta = &sdata->u.sta;
 
-	if (!ifsta->associated ||
+	if (!(ifsta->flags & IEEE80211_STA_ASSOCIATED) ||
 	    memcmp(ifsta->bssid, mgmt->bssid, ETH_ALEN) != 0)
 		return;
 
@@ -2447,7 +2450,7 @@ static void ieee80211_rx_mgmt_beacon(struct net_device *dev,
 	if (elems.erp_info && elems.erp_info_len >= 1)
 		ieee80211_handle_erp_ie(dev, elems.erp_info[0]);
 
-	if (elems.wmm_param && ifsta->wmm_enabled) {
+	if (elems.wmm_param && (ifsta->flags & IEEE80211_STA_WMM_ENABLED)) {
 		ieee80211_sta_wmm_params(dev, ifsta, elems.wmm_param,
 					 elems.wmm_param_len);
 	}
@@ -3024,7 +3027,8 @@ static void ieee80211_sta_reset_auth(struct net_device *dev,
 	printk(KERN_DEBUG "%s: Initial auth_alg=%d\n", dev->name,
 	       ifsta->auth_alg);
 	ifsta->auth_transaction = -1;
-	ifsta->associated = ifsta->auth_tries = ifsta->assoc_tries = 0;
+	ifsta->flags &= ~IEEE80211_STA_ASSOCIATED;
+	ifsta->auth_tries = ifsta->assoc_tries = 0;
 	netif_carrier_off(dev);
 }
 
@@ -3038,8 +3042,10 @@ void ieee80211_sta_req_auth(struct net_device *dev,
 	if (sdata->type != IEEE80211_IF_TYPE_STA)
 		return;
 
-	if ((ifsta->bssid_set || ifsta->auto_bssid_sel) &&
-	    (ifsta->ssid_set || ifsta->auto_ssid_sel)) {
+	if ((ifsta->flags & (IEEE80211_STA_BSSID_SET |
+				IEEE80211_STA_AUTO_BSSID_SEL)) &&
+	    (ifsta->flags & (IEEE80211_STA_SSID_SET |
+				IEEE80211_STA_AUTO_SSID_SEL))) {
 		set_bit(IEEE80211_STA_REQ_AUTH, &ifsta->request);
 		queue_work(local->hw.workqueue, &ifsta->work);
 	}
@@ -3053,7 +3059,7 @@ static int ieee80211_sta_match_ssid(struct ieee80211_if_sta *ifsta,
 	if (!memcmp(ifsta->ssid, ssid, ssid_len))
 		return 1;
 
-	if (ifsta->auto_bssid_sel)
+	if (ifsta->flags & IEEE80211_STA_AUTO_BSSID_SEL)
 		return 0;
 
 	hidden_ssid = 1;
@@ -3082,8 +3088,8 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 	struct ieee80211_sta_bss *bss, *selected = NULL;
 	int top_rssi = 0, freq;
 
-	if (!ifsta->auto_channel_sel && !ifsta->auto_bssid_sel &&
-	    !ifsta->auto_ssid_sel) {
+	if (!(ifsta->flags & (IEEE80211_STA_AUTO_SSID_SEL |
+	    IEEE80211_STA_AUTO_BSSID_SEL | IEEE80211_STA_AUTO_CHANNEL_SEL))) {
 		ifsta->state = IEEE80211_AUTHENTICATE;
 		ieee80211_sta_reset_auth(dev, ifsta);
 		return 0;
@@ -3099,14 +3105,15 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 		    !!sdata->default_key)
 			continue;
 
-		if (!ifsta->auto_channel_sel && bss->freq != freq)
+		if (!(ifsta->flags & IEEE80211_STA_AUTO_CHANNEL_SEL) &&
+		    bss->freq != freq)
 			continue;
 
-		if (!ifsta->auto_bssid_sel &&
+		if (!(ifsta->flags & IEEE80211_STA_AUTO_BSSID_SEL) &&
 		    memcmp(bss->bssid, ifsta->bssid, ETH_ALEN))
 			continue;
 
-		if (!ifsta->auto_ssid_sel &&
+		if (!(ifsta->flags & IEEE80211_STA_AUTO_SSID_SEL) &&
 		    !ieee80211_sta_match_ssid(ifsta, bss->ssid, bss->ssid_len))
 			continue;
 
@@ -3121,7 +3128,7 @@ static int ieee80211_sta_config_auth(struct net_device *dev,
 
 	if (selected) {
 		ieee80211_set_channel(local, -1, selected->freq);
-		if (!ifsta->ssid_set)
+		if (!(ifsta->flags & IEEE80211_STA_SSID_SET))
 			ieee80211_sta_set_ssid(dev, selected->ssid,
 					       selected->ssid_len);
 		ieee80211_sta_set_bssid(dev, selected->bssid);
@@ -3424,10 +3431,10 @@ static int ieee80211_sta_find_ibss(struct net_device *dev,
 
 		if (time_after(jiffies, ifsta->ibss_join_req +
 			       IEEE80211_IBSS_JOIN_TIMEOUT)) {
-			if (ifsta->create_ibss &&
+			if ((ifsta->flags & IEEE80211_STA_CREATE_IBSS) &&
 			    local->oper_channel->flag & IEEE80211_CHAN_W_IBSS)
 				return ieee80211_sta_create_ibss(dev, ifsta);
-			if (ifsta->create_ibss) {
+			if (ifsta->flags & IEEE80211_STA_CREATE_IBSS) {
 				printk(KERN_DEBUG "%s: IBSS not allowed on the"
 				       " configured channel %d (%d MHz)\n",
 				       dev->name, local->hw.conf.channel,
@@ -3488,13 +3495,17 @@ int ieee80211_sta_set_ssid(struct net_device *dev, char *ssid, size_t len)
 	ifsta = &sdata->u.sta;
 
 	if (ifsta->ssid_len != len || memcmp(ifsta->ssid, ssid, len) != 0)
-		ifsta->prev_bssid_set = 0;
+		ifsta->flags &= ~IEEE80211_STA_PREV_BSSID_SET;
 	memcpy(ifsta->ssid, ssid, len);
 	memset(ifsta->ssid + len, 0, IEEE80211_MAX_SSID_LEN - len);
 	ifsta->ssid_len = len;
 
-	ifsta->ssid_set = len ? 1 : 0;
-	if (sdata->type == IEEE80211_IF_TYPE_IBSS && !ifsta->bssid_set) {
+	if (len)
+		ifsta->flags |= IEEE80211_STA_SSID_SET;
+	else
+		ifsta->flags &= ~IEEE80211_STA_SSID_SET;
+	if (sdata->type == IEEE80211_IF_TYPE_IBSS &&
+	    !(ifsta->flags & IEEE80211_STA_BSSID_SET)) {
 		ifsta->ibss_join_req = jiffies;
 		ifsta->state = IEEE80211_IBSS_SEARCH;
 		return ieee80211_sta_find_ibss(dev, ifsta);
@@ -3532,10 +3543,11 @@ int ieee80211_sta_set_bssid(struct net_device *dev, u8 *bssid)
 		}
 	}
 
-	if (!is_valid_ether_addr(bssid))
-		ifsta->bssid_set = 0;
+	if (is_valid_ether_addr(bssid))
+		ifsta->flags |= IEEE80211_STA_BSSID_SET;
 	else
-		ifsta->bssid_set = 1;
+		ifsta->flags &= ~IEEE80211_STA_BSSID_SET;
+
 	return 0;
 }
 
@@ -3602,7 +3614,7 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 			continue;
 
 		if (sdata->type == IEEE80211_IF_TYPE_STA) {
-			if (sdata->u.sta.associated)
+			if (sdata->u.sta.flags & IEEE80211_STA_ASSOCIATED)
 				ieee80211_send_nullfunc(local, sdata, 0);
 			ieee80211_sta_timer((unsigned long)sdata);
 		}
@@ -3614,7 +3626,7 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
 		struct ieee80211_if_sta *ifsta = &sdata->u.sta;
-		if (!ifsta->bssid_set ||
+		if (!(ifsta->flags & IEEE80211_STA_BSSID_SET) ||
 		    (!ifsta->state == IEEE80211_IBSS_JOINED &&
 		    !ieee80211_sta_active_ibss(dev)))
 			ieee80211_sta_find_ibss(dev, ifsta);
@@ -3756,7 +3768,7 @@ static int ieee80211_sta_start_scan(struct net_device *dev,
 
 		netif_stop_queue(sdata->dev);
 		if (sdata->type == IEEE80211_IF_TYPE_STA &&
-		    sdata->u.sta.associated)
+		    (sdata->u.sta.flags & IEEE80211_STA_ASSOCIATED))
 			ieee80211_send_nullfunc(local, sdata, 1);
 	}
 	read_unlock(&local->sub_if_lock);
@@ -4069,7 +4081,7 @@ int ieee80211_sta_disassociate(struct net_device *dev, u16 reason)
 	if (sdata->type != IEEE80211_IF_TYPE_STA)
 		return -EINVAL;
 
-	if (!ifsta->associated)
+	if (!(ifsta->flags & IEEE80211_STA_ASSOCIATED))
 		return -1;
 
 	ieee80211_send_disassoc(dev, ifsta, reason);
