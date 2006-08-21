From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 18/18] d80211:  fix some documentation
Date: Mon, 21 Aug 2006 09:41:25 +0200
Message-ID: <20060821075203.135943128@sipsolutions.net>
References: <20060821074107.648561364@sipsolutions.net>
Mime-Version: 1.0
Cc: Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:4289 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030312AbWHUICd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 04:02:33 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=d80211-doc-fixes.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes some spelling errors, typos etc. in d80211.h

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-08-20 20:34:00.682819787 +0200
+++ wireless-dev/include/net/d80211.h	2006-08-20 20:58:32.412819787 +0200
@@ -17,7 +17,7 @@
 #include <linux/wireless.h>
 #include "d80211_shared.h"
 
-/* Note! Only ieee80211_tx_status_irqsafe() and ieee80211_rx_irqsave() can be
+/* Note! Only ieee80211_tx_status_irqsafe() and ieee80211_rx_irqsafe() can be
  * called in hardware interrupt context. The low-level driver must not call any
  * other functions in hardware interrupt context. If there is a need for such
  * call, the low-level driver should first ACK the interrupt and perform the
@@ -131,8 +131,8 @@ struct ieee80211_low_level_stats {
 };
 
 /* Transmit control fields. This data structure is passed to low-level driver
- * with each TX frame. The low-level driver is responsible of configuring
- * hardware to use given values (depending on what is supported). */
+ * with each TX frame. The low-level driver is responsible for configuring
+ * the hardware to use given values (depending on what is supported). */
 #define HW_KEY_IDX_INVALID -1
 
 struct ieee80211_tx_control {
@@ -162,7 +162,7 @@ struct ieee80211_tx_control {
 					 * frame */
 	 /* following three flags are only used with Atheros Super A/G */
 	unsigned int compress:1;
-	unsigned int turbo_prime_notify:1; /* notify HostaAPd after frame
+	unsigned int turbo_prime_notify:1; /* notify HostAPd after frame
 					    * transmission */
 	unsigned int fast_frame:1;
 
@@ -230,7 +230,10 @@ struct ieee80211_tx_status {
 
 
 /**
- * struct ieee80211_conf - configuration of a hardware
+ * struct ieee80211_conf - configuration of the device
+ *
+ * This struct indicates how the driver shall configure the hardware.
+ *
  * @radio_enabled: when zero, driver is required to switch off the radio.
  */
 struct ieee80211_conf {
@@ -290,7 +293,8 @@ struct ieee80211_conf {
 };
 
 /**
- * enum ieee80211_if_types - types of 802.11 network interface
+ * enum ieee80211_if_types - types of 802.11 network interfaces
+ *
  * @IEEE80211_IF_TYPE_AP: interface in AP mode.
  * @IEEE80211_IF_TYPE_MGMT: special interface for communication with hostap
  *	daemon. Drivers should never see this type.
@@ -312,6 +316,7 @@ enum ieee80211_if_types {
 
 /**
  * struct ieee80211_if_init_conf - initial configuration of an interface
+ *
  * @if_id: internal interface ID. This number has no particular meaning to
  *	drivers and the only allowed usage is to pass it to
  *	ieee80211_beacon_get() and ieee80211_get_buffered_bc() functions.
@@ -334,26 +339,27 @@ struct ieee80211_if_init_conf {
 
 /**
  * struct ieee80211_if_conf - configuration of an interface
+ *
  * @type: type of the interface. This is always the same as was specified in
- *	&struct ieee80211_if_init_conf. The type of interface never change
- *	during the live of the interface; this field is present only for
+ *	&struct ieee80211_if_init_conf. The type of an interface never changes
+ *	during the life of the interface; this field is present only for
  *	convenience.
  * @bssid: BSSID of the network we are associated to/creating.
  * @ssid: used (together with @ssid_len) by drivers for hardware that
- *	generate beacons independently. The pointer is valid only during
- *	config_interface() callback (so copy the value somewhere if you need
- *	it).
+ *	generate beacons independently. The pointer is valid only during the
+ *	config_interface() call, so copy the value somewhere if you need
+ *	it.
  * @ssid_len: length of the @ssid field.
  * @generic_elem: used (together with @generic_elem_len) by drivers for
  *	hardware that generate beacons independently. The pointer is valid
- *	only during config_interface() callback (so copy the value somewhere
- *	if you need it).
+ *	only during the config_interface() call, so copy the value somewhere
+ *	if you need it.
  * @generic_elem_len: length of the generic element.
  * @beacon: beacon template. Valid only if @host_gen_beacon_template in
  *	&struct ieee80211_hw is set. The driver is responsible of freeing
  *	the sk_buff.
  *
- * This structure is passed to config_interface() callback of
+ * This structure is passed to the config_interface() callback of
  * &struct ieee80211_hw.
  */
 struct ieee80211_if_conf {
@@ -432,8 +438,8 @@ typedef enum {
 	DISABLE_COMPRESSION
 } set_key_cmd;
 
-/* Configuration block used by the low-level driver to tell 802.11 code about
- * supported hardware features and to pass function pointers for callback
+/* Configuration block used by the low-level driver to tell the 802.11 code
+ * about supported hardware features and to pass function pointers to callback
  * functions. */
 struct ieee80211_hw {
 	int version; /* IEEE80211_VERSION */
@@ -445,9 +451,9 @@ struct ieee80211_hw {
 
 	/* Some wireless LAN chipsets generate beacons in the hardware/firmware
 	 * and others rely on host generated beacons. This option is used to
-	 * configure upper layer IEEE 802.11 module to generate beacons. The
-	 * low-level driver can use ieee80211_beacon_get() to fetch next
-	 * beacon frame. */
+	 * configure the upper layer IEEE 802.11 module to generate beacons.
+	 * The low-level driver can use ieee80211_beacon_get() to fetch the
+	 * next beacon frame. */
 	unsigned int host_gen_beacon:1;
 
 	/* The device needs to be supplied with a beacon template only. */
@@ -459,14 +465,13 @@ struct ieee80211_hw {
 	 * through) */
 	unsigned int device_hides_wep:1;
 
-	/* Whether RX frames passed to ieee80211_rx() include FCS in the end
-	 */
+	/* Whether RX frames passed to ieee80211_rx() include FCS in the end */
 	unsigned int rx_includes_fcs:1;
 
 	/* Some wireless LAN chipsets buffer broadcast/multicast frames for
 	 * power saving stations in the hardware/firmware and others rely on
 	 * the host system for such buffering. This option is used to
-	 * configure upper layer IEEE 802.11 to buffer broadcast/multicast
+	 * configure the IEEE 802.11 upper layer to buffer broadcast/multicast
 	 * frames when there are power saving stations so that low-level driver
 	 * can fetch them with ieee80211_get_buffered_bc(). */
 	unsigned int host_broadcast_ps_buffering:1;
@@ -475,18 +480,18 @@ struct ieee80211_hw {
 	unsigned int data_nullfunc_ack:1; /* will data nullfunc frames get proper
 					   * TX status callback */
 
-	/* Force sw version of encryption for TKIP packets if WMM is enabled.
-	 */
+	/* Force software encryption for TKIP packets if WMM is enabled. */
 	unsigned int no_tkip_wmm_hwaccel:1;
 
-        /* 1 if the payload needs to be padded at even boundaries after the
+        /* set if the payload needs to be padded at even boundaries after the
 	 * header */
 	unsigned int extra_hdr_room:1;
 
 	/* Some devices handle Michael MIC internally and do not include MIC in
-	 * the received packets given to 80211.o. device_strips_mic must be set
-	 * for such devices. ISWEP bit is still expected to be set in the IEEE
-	 * 802.11 header with this option unlike with device_hides_wep option.
+	 * the received packets passed up. device_strips_mic must be set
+	 * for such devices. The 'encryption' frame control bit is expected to
+	 * be still set in the IEEE 802.11 header with this option unlike with
+	 * the device_hides_wep configuration option.
 	 */
 	unsigned int device_strips_mic:1;
 
@@ -494,9 +499,9 @@ struct ieee80211_hw {
 	 * normal operation. */
 	unsigned int monitor_during_oper:1;
 
-	/* 1 = low-level driver supports skb fraglist (NETIF_F_FRAGLIST), i.e.,
-	 * more than one skb per frame */
-	unsigned int fraglist;
+	/* Set if the low-level driver supports skb fraglist (NETIF_F_FRAGLIST),
+	 * i.e. more than one skb per frame */
+	unsigned int fraglist:1;
 
         /* This is the time in us to change channels
          */
@@ -528,17 +533,17 @@ struct ieee80211_hw {
 	/* Handler for asking a driver if a new interface can be added (or,
 	 * more exactly, set UP). If the handler returns zero, the interface
 	 * is added. Driver should perform any initialization it needs prior
-	 * to returning zero. By returning non-zero, adding of the interface
-	 * is not permitted. Unless monitor_during_oper is set, it is
-	 * guaranteed that monitor interfaces and normal interfaces are
-	 * mutually exclusive. The open() handler is called after
-	 * add_interface() if this is the first device added. At least one
-	 * of open() and add_interface() handler has to be non-NULL. If
+	 * to returning zero. By returning non-zero addition of the interface
+	 * is inhibited. Unless monitor_during_oper is set, it is guaranteed
+	 * that monitor interfaces and normal interfaces are mutually
+	 * exclusive. The open() handler is called after add_interface()
+	 * if this is the first device added. At least one of the open()
+	 * open() and add_interface() callbacks has to be assigned. If
 	 * add_interface() is NULL, one STA interface is permitted only. */
 	int (*add_interface)(struct net_device *dev,
 			     struct ieee80211_if_init_conf *conf);
 
-	/* Notify a driver that interface is going down. The stop() handler
+	/* Notify a driver that an interface is going down. The stop() handler
 	 * is called prior to this if this is a last interface. */
 	void (*remove_interface)(struct net_device *dev,
 				 struct ieee80211_if_init_conf *conf);
@@ -552,9 +557,9 @@ struct ieee80211_hw {
 	int (*config_interface)(struct net_device *dev, int if_id,
 				struct ieee80211_if_conf *conf);
 
-	/* ieee80211 drivers should use this and not the function in
-	 * net_device. dev->flags, dev->mc_count and dev->mc_list must not
-	 * be used; use passed parameters and ieee80211_get_mc_list_item()
+	/* ieee80211 drivers must assign this instead of the callback in
+	 * &struct net_device. dev->flags, dev->mc_count and dev->mc_list must
+	 * not be used; use passed parameters and ieee80211_get_mc_list_item()
 	 * instead. */
 	void (*set_multicast_list)(struct net_device *dev,
 				   unsigned short flags, int mc_count);
@@ -578,14 +583,14 @@ struct ieee80211_hw {
 	/* Set TX key index for default/broadcast keys. This is needed in cases
 	 * where wlan card is doing full WEP/TKIP encapsulation (wep_include_iv
 	 * is not set), in other cases, this function pointer can be set to
-	 * NULL since 80211.o takes care of selecting the key index for each
-	 * TX frame. */
+	 * NULL since the IEEE 802. 11 module takes care of selecting the key
+	 * index for each TX frame. */
 	int (*set_key_idx)(struct net_device *dev, int idx);
 
 	/* Enable/disable IEEE 802.1X. This item requests wlan card to pass
 	 * unencrypted EAPOL-Key frames even when encryption is configured.
 	 * If the wlan card does not require such a configuration, this
-	 * function pointer can be set to NULL. 80211.o */
+	 * function pointer can be set to NULL. */
 	int (*set_ieee8021x)(struct net_device *dev, int use_ieee8021x);
 
 	/* Set port authorization state (IEEE 802.1X PAE) to be authorized
@@ -615,7 +620,6 @@ struct ieee80211_hw {
         /* For devices that generate their own beacons and probe response
          * or association responses this updates the state of privacy_invoked
          * returns 0 for success or an error number */
-
         int (*set_privacy_invoked)(struct net_device *dev,
                                    int privacy_invoked);
 

--
