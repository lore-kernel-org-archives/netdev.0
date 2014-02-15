From: Justin van Wijngaarden <justinvanwijngaarden@gmail.com>
Subject: [PATCH] Drivers: net: wireless: mac80211_hwim fixed coding style issues
Date: Sat, 15 Feb 2014 12:55:12 +0100
Message-ID: <1392465312-3780-1-git-send-email-justinvanwijngaarden@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Justin van Wijngaarden <justinvanwijngaarden@gmail.com>
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed a few coding style issues, things like comments and braces.

Signed-off-by: Justin van Wijngaarden <justinvanwijngaarden@gmail.com>
---
 drivers/net/wireless/mac80211_hwsim.c | 101 ++++++++++++++++------------------
 1 file changed, 47 insertions(+), 54 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 69d4c31..4a1ce5b 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1,19 +1,17 @@
-/*
- * mac80211_hwsim - software simulator of 802.11 radio(s) for mac80211
+/* mac80211_hwsim - software simulator of 802.11 radio(s) for mac80211
  * Copyright (c) 2008, Jouni Malinen <j@w1.fi>
  * Copyright (c) 2011, Javier Lopez <jlopex@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
- */
+*/
 
-/*
- * TODO:
+/* TODO:
  * - Add TSF sync and fix IBSS beacon transmission by adding
  *   competition for "air time" at TBTT
  * - RX filtering based on filter configuration (data->rx_filter)
- */
+*/
 
 #include <linux/list.h>
 #include <linux/slab.h>
@@ -49,11 +47,11 @@ static int channels = 1;
 module_param(channels, int, 0444);
 MODULE_PARM_DESC(channels, "Number of concurrent channels");
 
-static bool paged_rx = false;
+static bool paged_rx;
 module_param(paged_rx, bool, 0644);
 MODULE_PARM_DESC(paged_rx, "Use paged SKBs for RX instead of linear ones");
 
-static bool rctbl = false;
+static bool rctbl;
 module_param(rctbl, bool, 0444);
 MODULE_PARM_DESC(rctbl, "Handle rate control table");
 
@@ -70,27 +68,27 @@ MODULE_PARM_DESC(rctbl, "Handle rate control table");
  * and all possible combinations.
  *
  * @HWSIM_REGTEST_DISABLED: No regulatory tests are performed,
- * 	this is the default value.
+ *	this is the default value.
  * @HWSIM_REGTEST_DRIVER_REG_FOLLOW: Used for testing the driver regulatory
  *	hint, only one driver regulatory hint will be sent as such the
- * 	secondary radios are expected to follow.
+ *	secondary radios are expected to follow.
  * @HWSIM_REGTEST_DRIVER_REG_ALL: Used for testing the driver regulatory
- * 	request with all radios reporting the same regulatory domain.
+ *	request with all radios reporting the same regulatory domain.
  * @HWSIM_REGTEST_DIFF_COUNTRY: Used for testing the drivers calling
- * 	different regulatory domains requests. Expected behaviour is for
- * 	an intersection to occur but each device will still use their
- * 	respective regulatory requested domains. Subsequent radios will
- * 	use the resulting intersection.
+ *	different regulatory domains requests. Expected behaviour is for
+ *	an intersection to occur but each device will still use their
+ *	respective regulatory requested domains. Subsequent radios will
+ *	use the resulting intersection.
  * @HWSIM_REGTEST_WORLD_ROAM: Used for testing the world roaming. We accomplish
  *	this by using a custom beacon-capable regulatory domain for the first
  *	radio. All other device world roam.
  * @HWSIM_REGTEST_CUSTOM_WORLD: Used for testing the custom world regulatory
- * 	domain requests. All radios will adhere to this custom world regulatory
- * 	domain.
+ *	domain requests. All radios will adhere to this custom world regulatory
+ *	domain.
  * @HWSIM_REGTEST_CUSTOM_WORLD_2: Used for testing 2 custom world regulatory
- * 	domain requests. The first radio will adhere to the first custom world
- * 	regulatory domain, the second one to the second custom world regulatory
- * 	domain. All other devices will world roam.
+ *	domain requests. The first radio will adhere to the first custom world
+ *	regulatory domain, the second one to the second custom world regulatory
+ *	domain. All other devices will world roam.
  * @HWSIM_REGTEST_STRICT_FOLLOW_: Used for testing strict regulatory domain
  *	settings, only the first radio will send a regulatory domain request
  *	and use strict settings. The rest of the radios are expected to follow.
@@ -104,15 +102,15 @@ MODULE_PARM_DESC(rctbl, "Handle rate control table");
  *	other devices should follow the intersection created between the
  *	first two.
  * @HWSIM_REGTEST_ALL: Used for testing every possible mix. You will need
- * 	at least 6 radios for a complete test. We will test in this order:
- * 	1 - driver custom world regulatory domain
- * 	2 - second custom world regulatory domain
- * 	3 - first driver regulatory domain request
- * 	4 - second driver regulatory domain request
- * 	5 - strict regulatory domain settings using the third driver regulatory
- * 	    domain request
- * 	6 and on - should follow the intersection of the 3rd, 4rth and 5th radio
- * 	           regulatory requests.
+ *	at least 6 radios for a complete test. We will test in this order:
+ *	1 - driver custom world regulatory domain
+ *	2 - second custom world regulatory domain
+ *	3 - first driver regulatory domain request
+ *	4 - second driver regulatory domain request
+ *	5 - strict regulatory domain settings using the third driver regulatory
+ *		domain request
+ *	6 and on - should follow the intersection of the 3rd, 4rth and 5th radio
+ *	          regulatory requests.
  */
 enum hwsim_regtest {
 	HWSIM_REGTEST_DISABLED = 0,
@@ -406,8 +404,7 @@ struct mac80211_hwsim_data {
 	struct dentry *debugfs;
 
 	struct sk_buff_head pending;	/* packets pending */
-	/*
-	 * Only radios in the same group can communicate together (the
+	/* Only radios in the same group can communicate together (the
 	 * channel has to match too). Each bit represents a group. A
 	 * radio can be in more then one group.
 	 */
@@ -764,11 +761,13 @@ static bool hwsim_ps_rx_ok(struct mac80211_hwsim_data *data,
 		return false;
 	case PS_AUTO_POLL:
 		/* TODO: accept (some) Beacons by default and other frames only
-		 * if pending PS-Poll has been sent */
+		 * if pending PS-Poll has been sent
+		*/
 		return true;
 	case PS_MANUAL_POLL:
 		/* Allow unicast frames to own address if there is a pending
-		 * PS-Poll */
+		 * PS-Poll
+		*/
 		if (data->ps_poll_pending &&
 		    memcmp(data->hw->wiphy->perm_addr, skb->data + 4,
 			   ETH_ALEN) == 0) {
@@ -856,7 +855,8 @@ static void mac80211_hwsim_tx_frame_nl(struct ieee80211_hw *hw,
 		goto nla_put_failure;
 
 	/* We get the flags for this transmission, and we translate them to
-	   wmediumd flags  */
+	* wmediumd flags
+	*/
 
 	if (info->flags & IEEE80211_TX_CTL_REQ_TX_STATUS)
 		hwsim_flags |= HWSIM_TX_CTL_REQ_TX_STATUS;
@@ -966,8 +966,7 @@ static bool mac80211_hwsim_tx_frame_no_nl(struct ieee80211_hw *hw,
 	secpath_reset(skb);
 	nf_reset(skb);
 
-	/*
-	 * Get absolute mactime here so all HWs RX at the "same time", and
+	/* Get absolute mactime here so all HWs RX at the "same time", and
 	 * absolute TX time for beacon mactime so the timestamp matches.
 	 * Giving beacons a different mactime than non-beacons looks messy, but
 	 * it helps the Toffset be exact and a ~10us mactime discrepancy
@@ -1007,8 +1006,7 @@ static bool mac80211_hwsim_tx_frame_no_nl(struct ieee80211_hw *hw,
 				continue;
 		}
 
-		/*
-		 * reserve some space for our vendor and the normal
+		/* reserve some space for our vendor and the normal
 		 * radiotap header, since we're copying anyway
 		 */
 		if (skb->len < PAGE_SIZE && paged_rx) {
@@ -1036,8 +1034,7 @@ static bool mac80211_hwsim_tx_frame_no_nl(struct ieee80211_hw *hw,
 
 		rx_status.mactime = now + data2->tsf_offset;
 #if 0
-		/*
-		 * Don't enable this code by default as the OUI 00:00:00
+		/* Don't enable this code by default as the OUI 00:00:00
 		 * is registered to Xerox so we shouldn't use it here, it
 		 * might find its way into pcap files.
 		 * Note that this code requires the headroom in the SKB
@@ -1047,8 +1044,7 @@ static bool mac80211_hwsim_tx_frame_no_nl(struct ieee80211_hw *hw,
 		rx_status.vendor_radiotap_oui[1] = 0x00;
 		rx_status.vendor_radiotap_oui[2] = 0x00;
 		rx_status.vendor_radiotap_subns = 127;
-		/*
-		 * Radiotap vendor namespaces can (and should) also be
+		/* Radiotap vendor namespaces can (and should) also be
 		 * split into fields by using the standard radiotap
 		 * presence bitmap mechanism. Use just BIT(0) here for
 		 * the presence bitmap.
@@ -1197,8 +1193,7 @@ static int mac80211_hwsim_change_interface(struct ieee80211_hw *hw,
 		    newtype, vif->addr);
 	hwsim_check_magic(vif);
 
-	/*
-	 * interface may change from non-AP to AP in
+	/* interface may change from non-AP to AP in
 	 * which case this needs to be set up again
 	 */
 	vif->cab_queue = 0;
@@ -1371,7 +1366,7 @@ static int mac80211_hwsim_config(struct ieee80211_hw *hw, u32 changed)
 
 static void mac80211_hwsim_configure_filter(struct ieee80211_hw *hw,
 					    unsigned int changed_flags,
-					    unsigned int *total_flags,u64 multicast)
+					    unsigned int *total_flags, u64 multicast)
 {
 	struct mac80211_hwsim_data *data = hw->priv;
 
@@ -1465,9 +1460,8 @@ static void mac80211_hwsim_bss_info_changed(struct ieee80211_hw *hw,
 			    info->use_short_preamble);
 	}
 
-	if (changed & BSS_CHANGED_ERP_SLOT) {
+	if (changed & BSS_CHANGED_ERP_SLOT)
 		wiphy_debug(hw->wiphy, "  ERP_SLOT: %d\n", info->use_short_slot);
-	}
 
 	if (changed & BSS_CHANGED_HT) {
 		wiphy_debug(hw->wiphy, "  HT: op_mode=0x%x\n",
@@ -1556,8 +1550,7 @@ static int mac80211_hwsim_get_survey(
 	/* Current channel */
 	survey->channel = conf->chandef.chan;
 
-	/*
-	 * Magically conjured noise level --- this is only ok for simulated hardware.
+	/* Magically conjured noise level --- this is only ok for simulated hardware.
 	 *
 	 * A real driver which cannot determine the real channel noise MUST NOT
 	 * report any noise, especially not a magically conjured one :-)
@@ -1569,8 +1562,7 @@ static int mac80211_hwsim_get_survey(
 }
 
 #ifdef CONFIG_NL80211_TESTMODE
-/*
- * This section contains example code for using netlink
+/* This section contains example code for using netlink
  * attributes with the testmode command in nl80211.
  */
 
@@ -2191,9 +2183,9 @@ static void mac80211_hwsim_free(void)
 }
 
 static const struct net_device_ops hwsim_netdev_ops = {
-	.ndo_start_xmit 	= hwsim_mon_xmit,
+	.ndo_start_xmit		= hwsim_mon_xmit,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
@@ -2274,7 +2266,8 @@ static int hwsim_tx_info_frame_received_nl(struct sk_buff *skb_2,
 		goto out;
 
 	/* Tx info received because the frame was broadcasted on user space,
-	 so we get all the necessary info: tx attempts and skb control buff */
+	* so we get all the necessary info: tx attempts and skb control buff
+	*/
 
 	tx_attempts = (struct hwsim_tx_rate *)nla_data(
 		       info->attrs[HWSIM_ATTR_TX_INFO]);
-- 
1.9.rc1
