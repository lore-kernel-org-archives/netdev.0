From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 12/18] d80211:  fix some sparse warnings
Date: Mon, 21 Aug 2006 09:41:19 +0200
Message-ID: <20060821075201.370802472@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:62656 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030328AbWHUICU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:20 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes some warnings from sparse in d80211. Also
fixes indentation in places near where the changes were.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-08-20 17:21:26.778192788 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-20 17:21:27.318192788 +0200
@@ -246,10 +246,10 @@ struct ieee80211_conf {
 
 	/* Bitfields, grouped together */
 
-	int sw_encrypt:1;
-	int sw_decrypt:1;
-	int short_slot_time:1;		/* use IEEE 802.11g Short Slot Time */
-        int ssid_hidden:1;		/* do not broadcast the ssid */
+	unsigned int sw_encrypt:1;
+	unsigned int sw_decrypt:1;
+	unsigned int short_slot_time:1;	/* use IEEE 802.11g Short Slot Time */
+	unsigned int ssid_hidden:1;	/* do not broadcast the ssid */
 
         u8 power_level;			/* transmit power limit for current
 					 * regulatory domain; in dBm */
@@ -376,13 +376,13 @@ struct ieee80211_key_conf {
 	ieee80211_key_alg alg;
 	int keylen;
 
-        int force_sw_encrypt:1;		/* to be cleared by low-level driver */
+	unsigned int force_sw_encrypt:1;/* to be cleared by low-level driver */
 	int keyidx:8;			/* WEP key index */
-	int default_tx_key:1;		/* This key is the new default TX key
+	unsigned int default_tx_key:1;	/* This key is the new default TX key
 			       		 * (used only for broadcast keys). */
-	int default_wep_only:1; /* static WEP is the only configured security
-				 * policy; this allows some low-level drivers
-				 * to determine when hwaccel can be used */
+	unsigned int default_wep_only:1;/* static WEP is the only configured security
+					 * policy; this allows some low-level drivers
+					 * to determine when hwaccel can be used */
         u8 key[0];
 };
 
@@ -441,20 +441,20 @@ struct ieee80211_hw {
 	 * configure upper layer IEEE 802.11 module to generate beacons. The
 	 * low-level driver can use ieee80211_beacon_get() to fetch next
 	 * beacon frame. */
-	int host_gen_beacon:1;
+	unsigned int host_gen_beacon:1;
 
 	/* The device needs to be supplied with a beacon template only. */
-	int host_gen_beacon_template:1;
+	unsigned int host_gen_beacon_template:1;
 
 	/* Some devices handle decryption internally and do not
 	 * indicate whether the frame was encrypted (unencrypted frames
 	 * will be dropped by the hardware, unless specifically allowed
 	 * through) */
-        int device_hides_wep:1;
+	unsigned int device_hides_wep:1;
 
 	/* Whether RX frames passed to ieee80211_rx() include FCS in the end
 	 */
-	int rx_includes_fcs:1;
+	unsigned int rx_includes_fcs:1;
 
 	/* Some wireless LAN chipsets buffer broadcast/multicast frames for
 	 * power saving stations in the hardware/firmware and others rely on
@@ -462,19 +462,19 @@ struct ieee80211_hw {
 	 * configure upper layer IEEE 802.11 to buffer broadcast/multicast
 	 * frames when there are power saving stations so that low-level driver
 	 * can fetch them with ieee80211_get_buffered_bc(). */
-	int host_broadcast_ps_buffering:1;
+	unsigned int host_broadcast_ps_buffering:1;
 
-	int wep_include_iv:1;
-	int data_nullfunc_ack:1; /* will data nullfunc frames get proper
-                                  * TX status callback */
+	unsigned int wep_include_iv:1;
+	unsigned int data_nullfunc_ack:1; /* will data nullfunc frames get proper
+					   * TX status callback */
 
 	/* Force sw version of encryption for TKIP packets if WMM is enabled.
 	 */
-	int no_tkip_wmm_hwaccel:1;
+	unsigned int no_tkip_wmm_hwaccel:1;
 
         /* 1 if the payload needs to be padded at even boundaries after the
 	 * header */
-        unsigned int extra_hdr_room:1;
+	unsigned int extra_hdr_room:1;
 
 	/* Some devices handle Michael MIC internally and do not include MIC in
 	 * the received packets given to 80211.o. device_strips_mic must be set
--- wireless-dev.orig/net/d80211/ieee80211.c	2006-08-20 17:21:27.278192788 +0200
+++ wireless-dev/net/d80211/ieee80211.c	2006-08-20 20:13:29.932819787 +0200
@@ -229,7 +229,7 @@ static void ieee80211_key_threshold_noti
 
 	key->tx_rx_count = 0;
 
-	ieee80211_rx_mgmt(dev, skb, 0,
+	ieee80211_rx_mgmt(dev, skb, NULL,
 			  ieee80211_msg_key_threshold_notification);
 }
 
@@ -2636,7 +2636,7 @@ int ieee80211_radar_status(struct net_de
 	msg->radar = radar;
 	msg->radar_type = radar_type;
 
-	ieee80211_rx_mgmt(dev, skb, 0, ieee80211_msg_radar);
+	ieee80211_rx_mgmt(dev, skb, NULL, ieee80211_msg_radar);
 	return 0;
 }
 EXPORT_SYMBOL(ieee80211_radar_status);
@@ -2645,8 +2645,8 @@ EXPORT_SYMBOL(ieee80211_radar_status);
 int ieee80211_set_aid_for_sta(struct net_device *dev, u8 *peer_address,
 			      u16 aid)
 {
-        struct sk_buff *skb;
-        struct ieee80211_msg_set_aid_for_sta *msg;
+	struct sk_buff *skb;
+	struct ieee80211_msg_set_aid_for_sta *msg;
 
 	skb = dev_alloc_skb(sizeof(struct ieee80211_frame_info) +
 			    sizeof(struct ieee80211_msg_set_aid_for_sta));
@@ -2655,13 +2655,13 @@ int ieee80211_set_aid_for_sta(struct net
 		return -ENOMEM;
 	skb_reserve(skb, sizeof(struct ieee80211_frame_info));
 
-        msg = (struct ieee80211_msg_set_aid_for_sta *)
+	msg = (struct ieee80211_msg_set_aid_for_sta *)
 		skb_put(skb, sizeof(struct ieee80211_msg_set_aid_for_sta));
 	memcpy(msg->sta_address, peer_address, ETH_ALEN);
-        msg->aid = aid;
+	msg->aid = aid;
 
-        ieee80211_rx_mgmt(dev, skb, 0, ieee80211_msg_set_aid_for_sta);
-        return 0;
+	ieee80211_rx_mgmt(dev, skb, NULL, ieee80211_msg_set_aid_for_sta);
+	return 0;
 }
 EXPORT_SYMBOL(ieee80211_set_aid_for_sta);
 
--- wireless-dev.orig/net/d80211/ieee80211_i.h	2006-08-20 17:21:27.088192788 +0200
+++ wireless-dev/net/d80211/ieee80211_i.h	2006-08-20 20:13:30.362819787 +0200
@@ -115,10 +115,10 @@ struct ieee80211_txrx_data {
 	union {
 		struct {
 			struct ieee80211_tx_control *control;
-			int unicast:1;
-			int ps_buffered:1;
-			int short_preamble:1;
-			int probe_last_frag:1;
+			unsigned int unicast:1;
+			unsigned int ps_buffered:1;
+			unsigned int short_preamble:1;
+			unsigned int probe_last_frag:1;
 			struct ieee80211_rate *rate;
 			/* use this rate (if set) for last fragment; rate can
 			 * be set to lower rate for the first fragments, e.g.,
@@ -138,10 +138,10 @@ struct ieee80211_txrx_data {
 			int sent_ps_buffered;
 			int queue;
 			int load;
-			int in_scan:1;
-			int ra_match:1; /* frame is destined to interface
-					 * currently processed (including
-					 * multicast frames) */
+			unsigned int in_scan:1;
+			/* frame is destined to interface currently processed
+			 * (including multicast frames) */
+			unsigned int ra_match:1;
 		} rx;
 	} u;
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
@@ -255,16 +255,16 @@ struct ieee80211_if_sta {
 
 	int auth_tries, assoc_tries;
 
-	int ssid_set:1;
-	int bssid_set:1;
-	int prev_bssid_set:1;
-	int authenticated:1;
-	int associated:1;
-	int probereq_poll:1;
-	int use_protection:1;
-	int create_ibss:1;
-	int mixed_cell:1;
-	int wmm_enabled:1;
+	unsigned int ssid_set:1;
+	unsigned int bssid_set:1;
+	unsigned int prev_bssid_set:1;
+	unsigned int authenticated:1;
+	unsigned int associated:1;
+	unsigned int probereq_poll:1;
+	unsigned int use_protection:1;
+	unsigned int create_ibss:1;
+	unsigned int mixed_cell:1;
+	unsigned int wmm_enabled:1;
 
 	int key_mgmt;
 	unsigned long last_probe;
@@ -293,8 +293,8 @@ struct ieee80211_sub_if_data {
         struct ieee80211_local *local;
 
 	int mc_count;
-	unsigned allmulti:1;
-	unsigned promisc:1;
+	unsigned int allmulti:1;
+	unsigned int promisc:1;
 
         struct net_device_stats stats;
 	int drop_unencrypted;
--- wireless-dev.orig/net/d80211/ieee80211_key.h	2006-08-20 17:21:27.238192788 +0200
+++ wireless-dev/net/d80211/ieee80211_key.h	2006-08-20 17:21:27.328192788 +0200
@@ -77,10 +77,10 @@ struct ieee80211_key {
 
 	/* if the low level driver can provide hardware acceleration it should
 	 * clear this flag */
-	int force_sw_encrypt:1;
+	unsigned int force_sw_encrypt:1;
 	int keyidx:8; /* WEP key index */
-	int default_tx_key:1; /* This key is the new default TX key
-			       * (used only for broadcast keys). */
+	unsigned int default_tx_key:1; /* This key is the new default TX key
+					* (used only for broadcast keys). */
 
 	u8 key[0];
 };
--- wireless-dev.orig/net/d80211/rate_control_simple.c	2006-08-20 17:21:27.228192788 +0200
+++ wireless-dev/net/d80211/rate_control_simple.c	2006-08-20 20:13:30.172819787 +0200
@@ -363,7 +363,7 @@ static struct rate_control_ops rate_cont
 	.remove_sta_attrs = rate_control_simple_remove_sta_attrs,
 };
 
-int __init rate_control_simple_init(void)
+static int __init rate_control_simple_init(void)
 {
 	return ieee80211_rate_control_register(&rate_control_simple);
 }
--- wireless-dev.orig/net/d80211/sta_info.h	2006-08-20 17:21:27.238192788 +0200
+++ wireless-dev/net/d80211/sta_info.h	2006-08-20 17:36:57.728192788 +0200
@@ -94,9 +94,9 @@ struct sta_info {
 				  * filtering; used only if sta->key is not
 				  * set */
 
-	int sysfs_registered:1;
-	int assoc_ap:1; /* whether this is an AP that we are associated with
-			 * as a client */
+	unsigned int sysfs_registered:1;
+	unsigned int assoc_ap:1; /* whether this is an AP that we are
+				  * associated with as a client */
 
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	u32 wpa_trigger;

--
