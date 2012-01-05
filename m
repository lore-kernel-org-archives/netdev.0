From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/7] rtlwifi: Convert RT_TRACE macro to use ##__VA_ARGS__
Date: Wed,  4 Jan 2012 19:40:41 -0800
Message-ID: <a6f29cc811acd231a08cf2f4fca59ec80b83f510.1325734203.git.joe@perches.com>
References: <cover.1325734202.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39146 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757803Ab2AEDmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 22:42:11 -0500
In-Reply-To: <cover.1325734202.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate printks to avoid possible message interleaving
and reduce the object size.

Remove unnecessary RT_TRACE parentheses.

Miscellaneous typo and grammar fixes.
Add missing newlines to formats.
Remove duplicate KERN_DEBUG prefixes.
Coalesce formats.
Align arguments.

$ size drivers/net/wireless/rtlwifi/built-in.o*
   text    data     bss     dec     hex filename
 594841   55333  129680  779854   be64e drivers/net/wireless/rtlwifi/built-in.o.new
 607022   55333  138720  801075   c3933 drivers/net/wireless/rtlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/base.c                |   56 ++--
 drivers/net/wireless/rtlwifi/cam.c                 |   81 ++--
 drivers/net/wireless/rtlwifi/core.c                |  120 +++---
 drivers/net/wireless/rtlwifi/debug.h               |    7 +-
 drivers/net/wireless/rtlwifi/efuse.c               |   31 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  196 +++++-----
 drivers/net/wireless/rtlwifi/ps.c                  |   31 +-
 drivers/net/wireless/rtlwifi/rc.c                  |    2 +-
 drivers/net/wireless/rtlwifi/regd.c                |   12 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  189 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   69 ++--
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |  201 +++++-----
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |   24 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  182 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192ce/led.c       |   16 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |  108 +++---
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |   24 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |  179 ++++-----
 drivers/net/wireless/rtlwifi/rtl8192cu/led.c       |   15 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |  101 +++---
 drivers/net/wireless/rtlwifi/rtl8192cu/phy.c       |  121 +++---
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   36 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |  239 +++++------
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |  103 +++---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |  182 +++++-----
 drivers/net/wireless/rtlwifi/rtl8192de/led.c       |   14 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |  419 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |   26 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192se/fw.c        |   66 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  155 ++++----
 drivers/net/wireless/rtlwifi/rtl8192se/led.c       |   15 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |  200 +++++-----
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |   60 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   37 +-
 44 files changed, 1613 insertions(+), 1784 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index 8d6eb0f..fa16b1d 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -211,7 +211,7 @@ static void _rtl_init_hw_ht_capab(struct ieee80211_hw *hw,
 	 */
 	if (get_rf_type(rtlphy) == RF_1T2R || get_rf_type(rtlphy) == RF_2T2R) {
 
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("1T2R or 2T2R\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "1T2R or 2T2R\n");
 
 		ht_cap->mcs.rx_mask[0] = 0xFF;
 		ht_cap->mcs.rx_mask[1] = 0xFF;
@@ -220,7 +220,7 @@ static void _rtl_init_hw_ht_capab(struct ieee80211_hw *hw,
 		ht_cap->mcs.rx_highest = cpu_to_le16(MAX_BIT_RATE_40MHZ_MCS15);
 	} else if (get_rf_type(rtlphy) == RF_1T1R) {
 
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("1T1R\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "1T1R\n");
 
 		ht_cap->mcs.rx_mask[0] = 0xFF;
 		ht_cap->mcs.rx_mask[1] = 0x00;
@@ -302,9 +302,8 @@ static void _rtl_init_mac80211(struct ieee80211_hw *hw)
 			/* <4> set mac->sband to wiphy->sband */
 			hw->wiphy->bands[IEEE80211_BAND_5GHZ] = sband;
 		} else {
-			RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-				 ("Err BAND %d\n",
-				 rtlhal->current_bandtype));
+			RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Err BAND %d\n",
+				 rtlhal->current_bandtype);
 		}
 	}
 	/* <5> set hw caps */
@@ -436,13 +435,13 @@ int rtl_init_core(struct ieee80211_hw *hw)
 	 * mac80211 hw  in _rtl_init_mac80211.
 	 */
 	if (rtl_regd_init(hw, rtl_reg_notifier)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("REGD init failed\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "REGD init failed\n");
 		return 1;
 	} else {
 		/* CRDA regd hint must after init CRDA */
 		if (regulatory_hint(hw->wiphy, rtlpriv->regd.alpha2)) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-				 ("regulatory_hint fail\n"));
+				 "regulatory_hint fail\n");
 		}
 	}
 
@@ -922,17 +921,17 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 				return false;
 
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-				 ("%s ACT_ADDBAREQ From :%pM\n",
-				  is_tx ? "Tx" : "Rx", hdr->addr2));
+				 "%s ACT_ADDBAREQ From :%pM\n",
+				 is_tx ? "Tx" : "Rx", hdr->addr2);
 			break;
 		case ACT_ADDBARSP:
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-				 ("%s ACT_ADDBARSP From :%pM\n",
-				  is_tx ? "Tx" : "Rx", hdr->addr2));
+				 "%s ACT_ADDBARSP From :%pM\n",
+				 is_tx ? "Tx" : "Rx", hdr->addr2);
 			break;
 		case ACT_DELBA:
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-				 ("ACT_ADDBADEL From :%pM\n", hdr->addr2));
+				 "ACT_ADDBADEL From :%pM\n", hdr->addr2);
 			break;
 		}
 		break;
@@ -975,8 +974,8 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 				 * 67 : UDP BOOTP server
 				 */
 				RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV),
-					 DBG_DMESG, ("dhcp %s !!\n",
-						     (is_tx) ? "Tx" : "Rx"));
+					 DBG_DMESG, "dhcp %s !!\n",
+					 is_tx ? "Tx" : "Rx");
 
 				if (is_tx) {
 					rtl_lps_leave(hw);
@@ -996,7 +995,7 @@ u8 rtl_is_special_data(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 		return true;
 	} else if (ETH_P_PAE == ether_type) {
 		RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-			 ("802.1X %s EAPOL pkt!!\n", (is_tx) ? "Tx" : "Rx"));
+			 "802.1X %s EAPOL pkt!!\n", is_tx ? "Tx" : "Rx");
 
 		if (is_tx) {
 			rtl_lps_leave(hw);
@@ -1036,9 +1035,8 @@ int rtl_tx_agg_start(struct ieee80211_hw *hw,
 		return -ENXIO;
 	tid_data = &sta_entry->tids[tid];
 
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
-		 ("on ra = %pM tid = %d seq:%d\n", sta->addr, tid,
-		 tid_data->seq_number));
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "on ra = %pM tid = %d seq:%d\n",
+		 sta->addr, tid, tid_data->seq_number);
 
 	*ssn = tid_data->seq_number;
 	tid_data->agg.agg_state = RTL_AGG_START;
@@ -1059,12 +1057,12 @@ int rtl_tx_agg_stop(struct ieee80211_hw *hw,
 		return -EINVAL;
 
 	if (!sta->addr) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("ra = NULL\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "ra = NULL\n");
 		return -EINVAL;
 	}
 
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
-		 ("on ra = %pM tid = %d\n", sta->addr, tid));
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "on ra = %pM tid = %d\n",
+		 sta->addr, tid);
 
 	if (unlikely(tid >= MAX_TID_COUNT))
 		return -EINVAL;
@@ -1087,12 +1085,12 @@ int rtl_tx_agg_oper(struct ieee80211_hw *hw,
 		return -EINVAL;
 
 	if (!sta->addr) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("ra = NULL\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "ra = NULL\n");
 		return -EINVAL;
 	}
 
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG,
-		 ("on ra = %pM tid = %d\n", sta->addr, tid));
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "on ra = %pM tid = %d\n",
+		 sta->addr, tid);
 
 	if (unlikely(tid >= MAX_TID_COUNT))
 		return -EINVAL;
@@ -1474,29 +1472,29 @@ void rtl_recognize_peer(struct ieee80211_hw *hw, u8 *data, unsigned int len)
 		(memcmp(mac->bssid, ap5_6, 3) == 0) ||
 		vendor == PEER_ATH) {
 		vendor = PEER_ATH;
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, ("=>ath find\n"));
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "=>ath find\n");
 	} else if ((memcmp(mac->bssid, ap4_4, 3) == 0) ||
 		(memcmp(mac->bssid, ap4_5, 3) == 0) ||
 		(memcmp(mac->bssid, ap4_1, 3) == 0) ||
 		(memcmp(mac->bssid, ap4_2, 3) == 0) ||
 		(memcmp(mac->bssid, ap4_3, 3) == 0) ||
 		vendor == PEER_RAL) {
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, ("=>ral findn\n"));
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "=>ral find\n");
 		vendor = PEER_RAL;
 	} else if (memcmp(mac->bssid, ap6_1, 3) == 0 ||
 		vendor == PEER_CISCO) {
 		vendor = PEER_CISCO;
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, ("=>cisco find\n"));
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "=>cisco find\n");
 	} else if ((memcmp(mac->bssid, ap3_1, 3) == 0) ||
 		(memcmp(mac->bssid, ap3_2, 3) == 0) ||
 		(memcmp(mac->bssid, ap3_3, 3) == 0) ||
 		vendor == PEER_BROAD) {
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, ("=>broad find\n"));
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "=>broad find\n");
 		vendor = PEER_BROAD;
 	} else if (memcmp(mac->bssid, ap7_1, 3) == 0 ||
 		vendor == PEER_MARV) {
 		vendor = PEER_MARV;
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, ("=>marv find\n"));
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "=>marv find\n");
 	}
 
 	mac->vendor = vendor;
diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index dc36d74..cbf5e3c 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -55,10 +55,10 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 	u8 entry_i;
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-		 ("key_cont_128:\n %x:%x:%x:%x:%x:%x\n",
-		  key_cont_128[0], key_cont_128[1],
-		  key_cont_128[2], key_cont_128[3],
-		  key_cont_128[4], key_cont_128[5]));
+		 "key_cont_128:\n %x:%x:%x:%x:%x:%x\n",
+		 key_cont_128[0], key_cont_128[1],
+		 key_cont_128[2], key_cont_128[3],
+		 key_cont_128[4], key_cont_128[5]);
 
 	for (entry_i = 0; entry_i < CAM_CONTENT_COUNT; entry_i++) {
 		target_command = entry_i + CAM_CONTENT_COUNT * entry_no;
@@ -73,14 +73,12 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 			rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[RWCAM],
 					target_command);
 
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE %x: %x\n",
+				 rtlpriv->cfg->maps[WCAMI], target_content);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("WRITE %x: %x\n",
-				  rtlpriv->cfg->maps[WCAMI], target_content));
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The Key ID is %d\n", entry_no));
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("WRITE %x: %x\n",
-				  rtlpriv->cfg->maps[RWCAM], target_command));
+				 "The Key ID is %d\n", entry_no);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE %x: %x\n",
+				 rtlpriv->cfg->maps[RWCAM], target_command);
 
 		} else if (entry_i == 1) {
 
@@ -94,10 +92,10 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 			rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[RWCAM],
 					target_command);
 
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("WRITE A4: %x\n", target_content));
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("WRITE A0: %x\n", target_command));
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A4: %x\n",
+				 target_content);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A0: %x\n",
+				 target_command);
 
 		} else {
 
@@ -114,15 +112,15 @@ static void rtl_cam_program_entry(struct ieee80211_hw *hw, u32 entry_no,
 					target_command);
 			udelay(100);
 
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("WRITE A4: %x\n", target_content));
-			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("WRITE A0: %x\n", target_command));
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A4: %x\n",
+				 target_content);
+			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "WRITE A0: %x\n",
+				 target_command);
 		}
 	}
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-		 ("after set key, usconfig:%x\n", us_config));
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "after set key, usconfig:%x\n",
+		 us_config);
 }
 
 u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
@@ -133,14 +131,13 @@ u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-		 ("EntryNo:%x, ulKeyId=%x, ulEncAlg=%x, "
-		  "ulUseDK=%x MacAddr %pM\n",
-		  ul_entry_idx, ul_key_id, ul_enc_alg,
-		  ul_default_key, mac_addr));
+		 "EntryNo:%x, ulKeyId=%x, ulEncAlg=%x, ulUseDK=%x MacAddr %pM\n",
+		 ul_entry_idx, ul_key_id, ul_enc_alg,
+		 ul_default_key, mac_addr);
 
 	if (ul_key_id == TOTAL_CAM_ENTRY) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("<=== ulKeyId exceed!\n"));
+			 "<=== ulKeyId exceed!\n");
 		return 0;
 	}
 
@@ -153,7 +150,7 @@ u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
 	rtl_cam_program_entry(hw, ul_entry_idx, mac_addr,
 			      (u8 *) key_content, us_config);
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("<===\n"));
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "<===\n");
 
 	return 1;
 
@@ -166,7 +163,7 @@ int rtl_cam_delete_one_entry(struct ieee80211_hw *hw,
 	u32 ul_command;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("key_idx:%d\n", ul_key_id));
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "key_idx:%d\n", ul_key_id);
 
 	ul_command = ul_key_id * CAM_CONTENT_COUNT;
 	ul_command = ul_command | BIT(31) | BIT(16);
@@ -175,9 +172,9 @@ int rtl_cam_delete_one_entry(struct ieee80211_hw *hw,
 	rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[RWCAM], ul_command);
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-		 ("rtl_cam_delete_one_entry(): WRITE A4: %x\n", 0));
+		 "rtl_cam_delete_one_entry(): WRITE A4: %x\n", 0);
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-		 ("rtl_cam_delete_one_entry(): WRITE A0: %x\n", ul_command));
+		 "rtl_cam_delete_one_entry(): WRITE A0: %x\n", ul_command);
 
 	return 0;
 
@@ -229,9 +226,9 @@ void rtl_cam_mark_invalid(struct ieee80211_hw *hw, u8 uc_index)
 	rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[RWCAM], ul_command);
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-		 ("rtl_cam_mark_invalid(): WRITE A4: %x\n", ul_content));
+		 "rtl_cam_mark_invalid(): WRITE A4: %x\n", ul_content);
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-		 ("rtl_cam_mark_invalid(): WRITE A0: %x\n", ul_command));
+		 "rtl_cam_mark_invalid(): WRITE A0: %x\n", ul_command);
 }
 EXPORT_SYMBOL(rtl_cam_mark_invalid);
 
@@ -279,11 +276,11 @@ void rtl_cam_empty_entry(struct ieee80211_hw *hw, u8 uc_index)
 		rtl_write_dword(rtlpriv, rtlpriv->cfg->maps[RWCAM], ul_command);
 
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-			 ("rtl_cam_empty_entry(): WRITE A4: %x\n",
-			  ul_content));
+			 "rtl_cam_empty_entry(): WRITE A4: %x\n",
+			 ul_content);
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-			 ("rtl_cam_empty_entry(): WRITE A0: %x\n",
-			  ul_command));
+			 "rtl_cam_empty_entry(): WRITE A0: %x\n",
+			 ul_command);
 	}
 
 }
@@ -297,8 +294,7 @@ u8 rtl_cam_get_free_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 	u8 i, *addr;
 
 	if (NULL == sta_addr) {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
-			("sta_addr is NULL.\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG, "sta_addr is NULL\n");
 		return TOTAL_CAM_ENTRY;
 	}
 	/* Does STA already exist? */
@@ -311,8 +307,8 @@ u8 rtl_cam_get_free_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 	for (entry_idx = 4; entry_idx < TOTAL_CAM_ENTRY; entry_idx++) {
 		if ((bitmap & BIT(0)) == 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
-				("-----hwsec_cam_bitmap: 0x%x entry_idx=%d\n",
-				 rtlpriv->sec.hwsec_cam_bitmap, entry_idx));
+				 "-----hwsec_cam_bitmap: 0x%x entry_idx=%d\n",
+				 rtlpriv->sec.hwsec_cam_bitmap, entry_idx);
 			rtlpriv->sec.hwsec_cam_bitmap |= BIT(0) << entry_idx;
 			memcpy(rtlpriv->sec.hwsec_cam_sta_addr[entry_idx],
 			       sta_addr, ETH_ALEN);
@@ -331,14 +327,13 @@ void rtl_cam_del_entry(struct ieee80211_hw *hw, u8 *sta_addr)
 	u8 i, *addr;
 
 	if (NULL == sta_addr) {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
-			("sta_addr is NULL.\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG, "sta_addr is NULL\n");
 	}
 
 	if ((sta_addr[0]|sta_addr[1]|sta_addr[2]|sta_addr[3]|\
 				sta_addr[4]|sta_addr[5]) == 0) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
-			("sta_addr is 00:00:00:00:00:00.\n"));
+			 "sta_addr is 00:00:00:00:00:00\n");
 		return;
 	}
 	/* Does STA already exist? */
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 3f0f056..186c944 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -114,7 +114,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 
 	if (mac->vif) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("vif has been set!! mac->vif = 0x%p\n", mac->vif));
+			 "vif has been set!! mac->vif = 0x%p\n", mac->vif);
 		return -EOPNOTSUPP;
 	}
 
@@ -125,7 +125,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 	case NL80211_IFTYPE_STATION:
 		if (mac->beacon_enabled == 1) {
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("NL80211_IFTYPE_STATION\n"));
+				 "NL80211_IFTYPE_STATION\n");
 			mac->beacon_enabled = 0;
 			rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
 					rtlpriv->cfg->maps
@@ -134,7 +134,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-			 ("NL80211_IFTYPE_ADHOC\n"));
+			 "NL80211_IFTYPE_ADHOC\n");
 
 		mac->link_state = MAC80211_LINKED;
 		rtlpriv->cfg->ops->set_bcn_reg(hw);
@@ -148,7 +148,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		break;
 	case NL80211_IFTYPE_AP:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-			 ("NL80211_IFTYPE_AP\n"));
+			 "NL80211_IFTYPE_AP\n");
 
 		mac->link_state = MAC80211_LINKED;
 		rtlpriv->cfg->ops->set_bcn_reg(hw);
@@ -161,7 +161,7 @@ static int rtl_op_add_interface(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("operation mode %d is not support!\n", vif->type));
+			 "operation mode %d is not supported!\n", vif->type);
 		err = -EOPNOTSUPP;
 		goto out;
 	}
@@ -221,7 +221,7 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 	mutex_lock(&rtlpriv->locks.conf_mutex);
 	if (changed & IEEE80211_CONF_CHANGE_LISTEN_INTERVAL) {	/*BIT(2)*/
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-			 ("IEEE80211_CONF_CHANGE_LISTEN_INTERVAL\n"));
+			 "IEEE80211_CONF_CHANGE_LISTEN_INTERVAL\n");
 	}
 
 	/*For IPS */
@@ -264,8 +264,8 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 
 	if (changed & IEEE80211_CONF_CHANGE_RETRY_LIMITS) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-			 ("IEEE80211_CONF_CHANGE_RETRY_LIMITS %x\n",
-			  hw->conf.long_frame_max_tx_count));
+			 "IEEE80211_CONF_CHANGE_RETRY_LIMITS %x\n",
+			 hw->conf.long_frame_max_tx_count);
 		mac->retry_long = hw->conf.long_frame_max_tx_count;
 		mac->retry_short = hw->conf.long_frame_max_tx_count;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_RETRY_LIMIT,
@@ -320,7 +320,7 @@ static int rtl_op_config(struct ieee80211_hw *hw, u32 changed)
 		default:
 			mac->bw_40 = false;
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-					("switch case not processed\n"));
+				 "switch case not processed\n");
 			break;
 		}
 
@@ -369,12 +369,12 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_AM] |
 			    rtlpriv->cfg->maps[MAC_RCR_AB];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Enable receive multicast frame.\n"));
+				 "Enable receive multicast frame\n");
 		} else {
 			mac->rx_conf &= ~(rtlpriv->cfg->maps[MAC_RCR_AM] |
 					  rtlpriv->cfg->maps[MAC_RCR_AB]);
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Disable receive multicast frame.\n"));
+				 "Disable receive multicast frame\n");
 		}
 	}
 
@@ -382,11 +382,11 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 		if (*new_flags & FIF_FCSFAIL) {
 			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_ACRC32];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Enable receive FCS error frame.\n"));
+				 "Enable receive FCS error frame\n");
 		} else {
 			mac->rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_ACRC32];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Disable receive FCS error frame.\n"));
+				 "Disable receive FCS error frame\n");
 		}
 	}
 
@@ -409,11 +409,11 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_ACF];
 
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Enable receive control frame.\n"));
+				 "Enable receive control frame\n");
 		} else {
 			mac->rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_ACF];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Disable receive control frame.\n"));
+				 "Disable receive control frame\n");
 		}
 	}
 
@@ -421,11 +421,11 @@ static void rtl_op_configure_filter(struct ieee80211_hw *hw,
 		if (*new_flags & FIF_OTHER_BSS) {
 			mac->rx_conf |= rtlpriv->cfg->maps[MAC_RCR_AAP];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Enable receive other BSS's frame.\n"));
+				 "Enable receive other BSS's frame\n");
 		} else {
 			mac->rx_conf &= ~rtlpriv->cfg->maps[MAC_RCR_AAP];
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-				 ("Disable receive other BSS's frame.\n"));
+				 "Disable receive other BSS's frame\n");
 		}
 	}
 }
@@ -456,7 +456,7 @@ static int rtl_op_sta_add(struct ieee80211_hw *hw,
 			sta_entry->wireless_mode = WIRELESS_MODE_G;
 
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-			("Add sta addr is %pM\n", sta->addr));
+			 "Add sta addr is %pM\n", sta->addr);
 		rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 	}
 	return 0;
@@ -469,7 +469,7 @@ static int rtl_op_sta_remove(struct ieee80211_hw *hw,
 	struct rtl_sta_info *sta_entry;
 	if (sta) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-			("Remove sta addr is %pM\n", sta->addr));
+			 "Remove sta addr is %pM\n", sta->addr);
 		sta_entry = (struct rtl_sta_info *) sta->drv_priv;
 		sta_entry->wireless_mode = 0;
 		sta_entry->ratr_index = 0;
@@ -514,7 +514,7 @@ static int rtl_op_conf_tx(struct ieee80211_hw *hw,
 
 	if (queue >= AC_MAX) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("queue number %d is incorrect!\n", queue));
+			 "queue number %d is incorrect!\n", queue);
 		return -EINVAL;
 	}
 
@@ -547,7 +547,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		     bss_conf->enable_beacon)) {
 			if (mac->beacon_enabled == 0) {
 				RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-					 ("BSS_CHANGED_BEACON_ENABLED\n"));
+					 "BSS_CHANGED_BEACON_ENABLED\n");
 
 				/*start hw beacon interrupt. */
 				/*rtlpriv->cfg->ops->set_bcn_reg(hw); */
@@ -565,7 +565,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			!bss_conf->enable_beacon)) {
 			if (mac->beacon_enabled == 1) {
 				RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-					 ("ADHOC DISABLE BEACON\n"));
+					 "ADHOC DISABLE BEACON\n");
 
 				mac->beacon_enabled = 0;
 				rtlpriv->cfg->ops->update_interrupt_mask(hw, 0,
@@ -575,7 +575,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		}
 		if (changed & BSS_CHANGED_BEACON_INT) {
 			RT_TRACE(rtlpriv, COMP_BEACON, DBG_TRACE,
-				 ("BSS_CHANGED_BEACON_INT\n"));
+				 "BSS_CHANGED_BEACON_INT\n");
 			mac->beacon_interval = bss_conf->beacon_int;
 			rtlpriv->cfg->ops->set_bcn_intv(hw);
 		}
@@ -604,7 +604,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			if (mac->opmode == NL80211_IFTYPE_STATION && sta)
 				rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-				 ("BSS_CHANGED_ASSOC\n"));
+				 "BSS_CHANGED_ASSOC\n");
 		} else {
 			if (mac->link_state == MAC80211_LINKED)
 				rtl_lps_leave(hw);
@@ -619,20 +619,20 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			mac->vendor = PEER_UNKNOWN;
 
 			RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-				 ("BSS_CHANGED_UN_ASSOC\n"));
+				 "BSS_CHANGED_UN_ASSOC\n");
 		}
 	}
 
 	if (changed & BSS_CHANGED_ERP_CTS_PROT) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("BSS_CHANGED_ERP_CTS_PROT\n"));
+			 "BSS_CHANGED_ERP_CTS_PROT\n");
 		mac->use_cts_protect = bss_conf->use_cts_prot;
 	}
 
 	if (changed & BSS_CHANGED_ERP_PREAMBLE) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD,
-			 ("BSS_CHANGED_ERP_PREAMBLE use short preamble:%x\n",
-			  bss_conf->use_short_preamble));
+			 "BSS_CHANGED_ERP_PREAMBLE use short preamble:%x\n",
+			 bss_conf->use_short_preamble);
 
 		mac->short_preamble = bss_conf->use_short_preamble;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACK_PREAMBLE,
@@ -641,7 +641,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 
 	if (changed & BSS_CHANGED_ERP_SLOT) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("BSS_CHANGED_ERP_SLOT\n"));
+			 "BSS_CHANGED_ERP_SLOT\n");
 
 		if (bss_conf->use_short_slot)
 			mac->slot_time = RTL_SLOT_TIME_9;
@@ -653,8 +653,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_HT) {
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("BSS_CHANGED_HT\n"));
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE, "BSS_CHANGED_HT\n");
 		rcu_read_lock();
 		sta = get_sta(hw, vif, bss_conf->bssid);
 		if (sta) {
@@ -683,8 +682,8 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_BSSID,
 					      (u8 *) bss_conf->bssid);
 
-		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-			 ("%pM\n", bss_conf->bssid));
+		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG, "%pM\n",
+			 bss_conf->bssid);
 
 		mac->vendor = PEER_UNKNOWN;
 		memcpy(mac->bssid, bss_conf->bssid, 6);
@@ -831,30 +830,30 @@ static int rtl_op_ampdu_action(struct ieee80211_hw *hw,
 	switch (action) {
 	case IEEE80211_AMPDU_TX_START:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("IEEE80211_AMPDU_TX_START: TID:%d\n", tid));
+			 "IEEE80211_AMPDU_TX_START: TID:%d\n", tid);
 		return rtl_tx_agg_start(hw, sta, tid, ssn);
 		break;
 	case IEEE80211_AMPDU_TX_STOP:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("IEEE80211_AMPDU_TX_STOP: TID:%d\n", tid));
+			 "IEEE80211_AMPDU_TX_STOP: TID:%d\n", tid);
 		return rtl_tx_agg_stop(hw, sta, tid);
 		break;
 	case IEEE80211_AMPDU_TX_OPERATIONAL:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("IEEE80211_AMPDU_TX_OPERATIONAL:TID:%d\n", tid));
+			 "IEEE80211_AMPDU_TX_OPERATIONAL:TID:%d\n", tid);
 		rtl_tx_agg_oper(hw, sta, tid);
 		break;
 	case IEEE80211_AMPDU_RX_START:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("IEEE80211_AMPDU_RX_START:TID:%d\n", tid));
+			 "IEEE80211_AMPDU_RX_START:TID:%d\n", tid);
 		break;
 	case IEEE80211_AMPDU_RX_STOP:
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_TRACE,
-			 ("IEEE80211_AMPDU_RX_STOP:TID:%d\n", tid));
+			 "IEEE80211_AMPDU_RX_STOP:TID:%d\n", tid);
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("IEEE80211_AMPDU_ERR!!!!:\n"));
+			 "IEEE80211_AMPDU_ERR!!!!:\n");
 		return -EOPNOTSUPP;
 	}
 	return 0;
@@ -867,7 +866,7 @@ static void rtl_op_sw_scan_start(struct ieee80211_hw *hw)
 
 	mac->act_scanning = true;
 
-	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, ("\n"));
+	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
 
 	if (mac->link_state == MAC80211_LINKED) {
 		rtl_lps_leave(hw);
@@ -888,7 +887,7 @@ static void rtl_op_sw_scan_complete(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 
-	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, ("\n"));
+	RT_TRACE(rtlpriv, COMP_MAC80211, DBG_LOUD, "\n");
 	mac->act_scanning = false;
 	/* Dual mac */
 	rtlpriv->rtlhal.load_imrandiqk_setting_for2g = false;
@@ -921,13 +920,13 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 
 	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("not open hw encryption\n"));
+			 "not open hw encryption\n");
 		return -ENOSPC;	/*User disabled HW-crypto */
 	}
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-		 ("%s hardware based encryption for keyidx: %d, mac: %pM\n",
-		  cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
-		  sta ? sta->addr : bcast_addr));
+		 "%s hardware based encryption for keyidx: %d, mac: %pM\n",
+		 cmd == SET_KEY ? "Using" : "Disabling", key->keyidx,
+		 sta ? sta->addr : bcast_addr);
 	rtlpriv->sec.being_setkey = true;
 	rtl_ips_nic_on(hw);
 	mutex_lock(&rtlpriv->locks.conf_mutex);
@@ -936,24 +935,23 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	switch (key->cipher) {
 	case WLAN_CIPHER_SUITE_WEP40:
 		key_type = WEP40_ENCRYPTION;
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("alg:WEP40\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:WEP40\n");
 		break;
 	case WLAN_CIPHER_SUITE_WEP104:
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-			 ("alg:WEP104\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:WEP104\n");
 		key_type = WEP104_ENCRYPTION;
 		break;
 	case WLAN_CIPHER_SUITE_TKIP:
 		key_type = TKIP_ENCRYPTION;
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("alg:TKIP\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:TKIP\n");
 		break;
 	case WLAN_CIPHER_SUITE_CCMP:
 		key_type = AESCCMP_ENCRYPTION;
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("alg:CCMP\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "alg:CCMP\n");
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("alg_err:%x!!!!:\n", key->cipher));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "alg_err:%x!!!!\n",
+			 key->cipher);
 		goto out_unlock;
 	}
 	if (key_type == WEP40_ENCRYPTION ||
@@ -995,8 +993,8 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 				wep_only = true;
 			rtlpriv->sec.pairwise_enc_algorithm = key_type;
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				("set enable_hw_sec, key_type:%x(OPEN:0 WEP40:1"
-				" TKIP:2 AES:4 WEP104:5)\n", key_type));
+				 "set enable_hw_sec, key_type:%x(OPEN:0 WEP40:1 TKIP:2 AES:4 WEP104:5)\n",
+				 key_type);
 			rtlpriv->cfg->ops->enable_hw_sec(hw);
 		}
 	}
@@ -1005,7 +1003,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	case SET_KEY:
 		if (wep_only) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("set WEP(group/pairwise) key\n"));
+				 "set WEP(group/pairwise) key\n");
 			/* Pairwise key with an assigned MAC address. */
 			rtlpriv->sec.pairwise_enc_algorithm = key_type;
 			rtlpriv->sec.group_enc_algorithm = key_type;
@@ -1016,7 +1014,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			memcpy(mac_addr, zero_addr, ETH_ALEN);
 		} else if (group_key) {	/* group key */
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("set group key\n"));
+				 "set group key\n");
 			/* group key */
 			rtlpriv->sec.group_enc_algorithm = key_type;
 			/*set local buf about group key. */
@@ -1026,7 +1024,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			memcpy(mac_addr, bcast_addr, ETH_ALEN);
 		} else {	/* pairwise key */
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("set pairwise key\n"));
+				 "set pairwise key\n");
 			if (!sta) {
 				RT_ASSERT(false, ("pairwise key withnot"
 						  "mac_addr\n"));
@@ -1056,7 +1054,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		break;
 	case DISABLE_KEY:
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-			 ("disable key delete one entry\n"));
+			 "disable key delete one entry\n");
 		/*set local buf about wep key. */
 		if (mac->opmode == NL80211_IFTYPE_AP) {
 			if (sta)
@@ -1077,7 +1075,7 @@ static int rtl_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("cmd_err:%x!!!!:\n", cmd));
+			 "cmd_err:%x!!!!\n", cmd);
 	}
 out_unlock:
 	mutex_unlock(&rtlpriv->locks.conf_mutex);
@@ -1106,8 +1104,8 @@ static void rtl_op_rfkill_poll(struct ieee80211_hw *hw)
 			rtlpriv->rfkill.rfkill_state = radio_state;
 
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 (KERN_INFO "wireless radio switch turned %s\n",
-				  radio_state ? "on" : "off"));
+				 "wireless radio switch turned %s\n",
+				 radio_state ? "on" : "off");
 
 			blocked = (rtlpriv->rfkill.rfkill_state == 1) ? 0 : 1;
 			wiphy_rfkill_set_hw_state(hw->wiphy, blocked);
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index 588986a..8c13969 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -165,14 +165,13 @@ do {									\
 	}								\
 } while (0)
 
-#define RT_TRACE(rtlpriv, comp, level, fmt)				\
+#define RT_TRACE(rtlpriv, comp, level, fmt, ...)			\
 do {									\
 	if (unlikely(((comp) & rtlpriv->dbg.global_debugcomponents) &&	\
 		     ((level) <= rtlpriv->dbg.global_debuglevel))) {	\
-		printk(KERN_DEBUG "%s:%s():<%lx-%x> ",			\
+		printk(KERN_DEBUG "%s:%s():<%lx-%x> " fmt,		\
 		       KBUILD_MODNAME, __func__,			\
-		       in_interrupt(), in_atomic());			\
-		printk fmt;						\
+		       in_interrupt(), in_atomic(), ##__VA_ARGS__);	\
 	}								\
 } while (0)
 
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 91fd363..2885131 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -162,8 +162,8 @@ void efuse_write_1byte(struct ieee80211_hw *hw, u16 address, u8 value)
 	const u32 efuse_len =
 		rtlpriv->cfg->maps[EFUSE_REAL_CONTENT_SIZE];
 
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-		 ("Addr=%x Data =%x\n", address, value));
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "Addr=%x Data =%x\n",
+		 address, value);
 
 	if (address < efuse_len) {
 		rtl_write_byte(rtlpriv, rtlpriv->cfg->maps[EFUSE_CTRL], value);
@@ -252,8 +252,8 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 
 	if ((_offset + _size_byte) > rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]) {
 		RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-			 ("read_efuse(): Invalid offset(%#x) with read "
-			  "bytes(%#x)!!\n", _offset, _size_byte));
+			 "read_efuse(): Invalid offset(%#x) with read bytes(%#x)!!\n",
+			 _offset, _size_byte);
 		return;
 	}
 
@@ -395,9 +395,8 @@ bool efuse_shadow_update_chk(struct ieee80211_hw *hw)
 		result = false;
 
 	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-		 ("efuse_shadow_update_chk(): totalbytes(%#x), "
-		  "hdr_num(%#x), words_need(%#x), efuse_used(%d)\n",
-		  totalbytes, hdr_num, words_need, efuse_used));
+		 "efuse_shadow_update_chk(): totalbytes(%#x), hdr_num(%#x), words_need(%#x), efuse_used(%d)\n",
+		 totalbytes, hdr_num, words_need, efuse_used);
 
 	return result;
 }
@@ -434,7 +433,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 	u8 word_en = 0x0F;
 	u8 first_pg = false;
 
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, ("--->\n"));
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "--->\n");
 
 	if (!efuse_shadow_update_chk(hw)) {
 		efuse_read_all_map(hw, &rtlefuse->efuse_map[EFUSE_INIT_MAP][0]);
@@ -443,7 +442,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 		       rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
 
 		RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-			 ("<---efuse out of capacity!!\n"));
+			 "<---efuse out of capacity!!\n");
 		return false;
 	}
 	efuse_power_switch(hw, true, true);
@@ -483,7 +482,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 			if (!efuse_pg_packet_write(hw, (u8) offset, word_en,
 						   tmpdata)) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("PG section(%#x) fail!!\n", offset));
+					 "PG section(%#x) fail!!\n", offset);
 				break;
 			}
 		}
@@ -497,7 +496,7 @@ bool efuse_shadow_update(struct ieee80211_hw *hw)
 	       &rtlefuse->efuse_map[EFUSE_INIT_MAP][0],
 	       rtlpriv->cfg->maps[EFUSE_HWSET_MAX_SIZE]);
 
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, ("<---\n"));
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "<---\n");
 	return true;
 }
 
@@ -634,8 +633,8 @@ static int efuse_one_byte_write(struct ieee80211_hw *hw, u16 addr, u8 data)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmpidx = 0;
 
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-		 ("Addr = %x Data=%x\n", addr, data));
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "Addr = %x Data=%x\n",
+		 addr, data);
 
 	rtl_write_byte(rtlpriv,
 		       rtlpriv->cfg->maps[EFUSE_CTRL] + 1, (u8) (addr & 0xff));
@@ -1006,7 +1005,7 @@ static int efuse_pg_packet_write(struct ieee80211_hw *hw,
 
 	if (efuse_addr >= (EFUSE_MAX_SIZE - EFUSE_OOB_PROTECT_BYTES)) {
 		RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-			 ("efuse_addr(%#x) Out of size!!\n", efuse_addr));
+			 "efuse_addr(%#x) Out of size!!\n", efuse_addr);
 	}
 
 	return true;
@@ -1046,8 +1045,8 @@ static u8 efuse_word_enable_data_write(struct ieee80211_hw *hw,
 	u8 tmpdata[8];
 
 	memset(tmpdata, 0xff, PGPKT_DATA_SIZE);
-	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD,
-		 ("word_en = %x efuse_addr=%x\n", word_en, efuse_addr));
+	RT_TRACE(rtlpriv, COMP_EFUSE, DBG_LOUD, "word_en = %x efuse_addr=%x\n",
+		 word_en, efuse_addr);
 
 	if (!(word_en & BIT(0))) {
 		tmpaddr = start_addr;
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 39e0907..b52fef2 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -170,7 +170,7 @@ static void _rtl_pci_update_default_setting(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 
@@ -232,7 +232,7 @@ static void rtl_pci_disable_aspm(struct ieee80211_hw *hw)
 
 	if (pcibridge_vendor == PCI_BRIDGE_VENDOR_UNKNOWN) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("PCI(Bridge) UNKNOWN.\n"));
+			 "PCI(Bridge) UNKNOWN\n");
 
 		return;
 	}
@@ -286,7 +286,7 @@ static void rtl_pci_enable_aspm(struct ieee80211_hw *hw)
 
 	if (pcibridge_vendor == PCI_BRIDGE_VENDOR_UNKNOWN) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("PCI(Bridge) UNKNOWN.\n"));
+			 "PCI(Bridge) UNKNOWN\n");
 		return;
 	}
 
@@ -303,11 +303,10 @@ static void rtl_pci_enable_aspm(struct ieee80211_hw *hw)
 			      u_pcibridge_aspmsetting);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("PlatformEnableASPM():PciBridge busnumber[%x], "
-		  "DevNumbe[%x], funcnumber[%x], Write reg[%x] = %x\n",
-		  pcibridge_busnum, pcibridge_devnum, pcibridge_funcnum,
-		  (pcipriv->ndis_adapter.pcibridge_pciehdr_offset + 0x10),
-		  u_pcibridge_aspmsetting));
+		 "PlatformEnableASPM():PciBridge busnumber[%x], DevNumbe[%x], funcnumber[%x], Write reg[%x] = %x\n",
+		 pcibridge_busnum, pcibridge_devnum, pcibridge_funcnum,
+		 (pcipriv->ndis_adapter.pcibridge_pciehdr_offset + 0x10),
+		 u_pcibridge_aspmsetting);
 
 	udelay(50);
 
@@ -382,9 +381,8 @@ static void rtl_pci_parse_configuration(struct pci_dev *pdev,
 	pci_read_config_byte(pdev, pos + PCI_EXP_LNKCTL, &linkctrl_reg);
 	pcipriv->ndis_adapter.linkctrl_reg = linkctrl_reg;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Link Control Register =%x\n",
-		  pcipriv->ndis_adapter.linkctrl_reg));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Link Control Register =%x\n",
+		 pcipriv->ndis_adapter.linkctrl_reg);
 
 	pci_read_config_byte(pdev, 0x98, &tmp);
 	tmp |= BIT(4);
@@ -551,11 +549,10 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 			skb_pull(skb, EM_HDR_LEN);
 
 		RT_TRACE(rtlpriv, (COMP_INTR | COMP_SEND), DBG_TRACE,
-			 ("new ring->idx:%d, "
-			  "free: skb_queue_len:%d, free: seq:%x\n",
-			  ring->idx,
-			  skb_queue_len(&ring->queue),
-			  *(u16 *) (skb->data + 22)));
+			 "new ring->idx:%d, free: skb_queue_len:%d, free: seq:%x\n",
+			 ring->idx,
+			 skb_queue_len(&ring->queue),
+			 *(u16 *) (skb->data + 22));
 
 		if (prio == TXCMD_QUEUE) {
 			dev_kfree_skb(skb);
@@ -593,11 +590,9 @@ static void _rtl_pci_tx_isr(struct ieee80211_hw *hw, int prio)
 				== 2) {
 
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-					("more desc left, wake"
-					 "skb_queue@%d,ring->idx = %d,"
-					 "skb_queue_len = 0x%d\n",
-					 prio, ring->idx,
-					 skb_queue_len(&ring->queue)));
+				 "more desc left, wake skb_queue@%d, ring->idx = %d, skb_queue_len = 0x%d\n",
+				 prio, ring->idx,
+				 skb_queue_len(&ring->queue));
 
 			ieee80211_wake_queue(hw,
 					skb_get_queue_mapping
@@ -709,9 +704,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 
 		new_skb = dev_alloc_skb(rtlpci->rxbuffersize);
 		if (unlikely(!new_skb)) {
-			RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV),
-				 DBG_DMESG,
-				 ("can't alloc skb for rx\n"));
+			RT_TRACE(rtlpriv, (COMP_INTR | COMP_RECV), DBG_DMESG,
+				 "can't alloc skb for rx\n");
 			goto done;
 		}
 
@@ -796,38 +790,37 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 	/*<1> beacon related */
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_TBDOK]) {
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("beacon ok interrupt!\n"));
+			 "beacon ok interrupt!\n");
 	}
 
 	if (unlikely(inta & rtlpriv->cfg->maps[RTL_IMR_TBDER])) {
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("beacon err interrupt!\n"));
+			 "beacon err interrupt!\n");
 	}
 
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_BDOK]) {
-		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("beacon interrupt!\n"));
+		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE, "beacon interrupt!\n");
 	}
 
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_BcnInt]) {
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("prepare beacon for interrupt!\n"));
+			 "prepare beacon for interrupt!\n");
 		tasklet_schedule(&rtlpriv->works.irq_prepare_bcn_tasklet);
 	}
 
 	/*<3> Tx related */
 	if (unlikely(inta & rtlpriv->cfg->maps[RTL_IMR_TXFOVW]))
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, ("IMR_TXFOVW!\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, "IMR_TXFOVW!\n");
 
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_MGNTDOK]) {
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("Manage ok interrupt!\n"));
+			 "Manage ok interrupt!\n");
 		_rtl_pci_tx_isr(hw, MGNT_QUEUE);
 	}
 
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_HIGHDOK]) {
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("HIGH_QUEUE ok interrupt!\n"));
+			 "HIGH_QUEUE ok interrupt!\n");
 		_rtl_pci_tx_isr(hw, HIGH_QUEUE);
 	}
 
@@ -835,7 +828,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		rtlpriv->link_info.num_tx_inperiod++;
 
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("BK Tx OK interrupt!\n"));
+			 "BK Tx OK interrupt!\n");
 		_rtl_pci_tx_isr(hw, BK_QUEUE);
 	}
 
@@ -843,7 +836,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		rtlpriv->link_info.num_tx_inperiod++;
 
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("BE TX OK interrupt!\n"));
+			 "BE TX OK interrupt!\n");
 		_rtl_pci_tx_isr(hw, BE_QUEUE);
 	}
 
@@ -851,7 +844,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		rtlpriv->link_info.num_tx_inperiod++;
 
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("VI TX OK interrupt!\n"));
+			 "VI TX OK interrupt!\n");
 		_rtl_pci_tx_isr(hw, VI_QUEUE);
 	}
 
@@ -859,7 +852,7 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 		rtlpriv->link_info.num_tx_inperiod++;
 
 		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-			 ("Vo TX OK interrupt!\n"));
+			 "Vo TX OK interrupt!\n");
 		_rtl_pci_tx_isr(hw, VO_QUEUE);
 	}
 
@@ -868,25 +861,25 @@ static irqreturn_t _rtl_pci_interrupt(int irq, void *dev_id)
 			rtlpriv->link_info.num_tx_inperiod++;
 
 			RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE,
-					("CMD TX OK interrupt!\n"));
+				 "CMD TX OK interrupt!\n");
 			_rtl_pci_tx_isr(hw, TXCMD_QUEUE);
 		}
 	}
 
 	/*<2> Rx related */
 	if (inta & rtlpriv->cfg->maps[RTL_IMR_ROK]) {
-		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE, ("Rx ok interrupt!\n"));
+		RT_TRACE(rtlpriv, COMP_INTR, DBG_TRACE, "Rx ok interrupt!\n");
 		_rtl_pci_rx_interrupt(hw);
 	}
 
 	if (unlikely(inta & rtlpriv->cfg->maps[RTL_IMR_RDU])) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("rx descriptor unavailable!\n"));
+			 "rx descriptor unavailable!\n");
 		_rtl_pci_rx_interrupt(hw);
 	}
 
 	if (unlikely(inta & rtlpriv->cfg->maps[RTL_IMR_RXFOVW])) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, ("rx overflow !\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, "rx overflow !\n");
 		_rtl_pci_rx_interrupt(hw);
 	}
 
@@ -1028,7 +1021,7 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 
 	if (!ring || (unsigned long)ring & 0xFF) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Cannot allocate TX ring (prio = %d)\n", prio));
+			 "Cannot allocate TX ring (prio = %d)\n", prio);
 		return -ENOMEM;
 	}
 
@@ -1039,8 +1032,8 @@ static int _rtl_pci_init_tx_ring(struct ieee80211_hw *hw,
 	rtlpci->tx_ring[prio].entries = entries;
 	skb_queue_head_init(&rtlpci->tx_ring[prio].queue);
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("queue:%d, ring_addr:%p\n", prio, ring));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "queue:%d, ring_addr:%p\n",
+		 prio, ring);
 
 	for (i = 0; i < entries; i++) {
 		nextdescaddress = (u32) dma +
@@ -1078,7 +1071,7 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw)
 		if (!rtlpci->rx_ring[rx_queue_idx].desc ||
 		    (unsigned long)rtlpci->rx_ring[rx_queue_idx].desc & 0xFF) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Cannot allocate RX ring\n"));
+				 "Cannot allocate RX ring\n");
 			return -ENOMEM;
 		}
 
@@ -1355,7 +1348,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	u8 temp_one = 1;
 
 	if (ieee80211_is_auth(fc)) {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, ("MAC80211_LINKING\n"));
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
 		rtl_ips_nic_on(hw);
 	}
 
@@ -1388,10 +1381,9 @@ static int rtl_pci_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 
 	if ((own == 1) && (hw_queue != BEACON_QUEUE)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("No more TX desc@%d, ring->idx = %d,"
-			  "idx = %d, skb_queue_len = 0x%d\n",
-			  hw_queue, ring->idx, idx,
-			  skb_queue_len(&ring->queue)));
+			 "No more TX desc@%d, ring->idx = %d, idx = %d, skb_queue_len = 0x%d\n",
+			 hw_queue, ring->idx, idx,
+			 skb_queue_len(&ring->queue));
 
 		spin_unlock_irqrestore(&rtlpriv->locks.irq_th_lock, flags);
 		return skb->len;
@@ -1426,11 +1418,9 @@ static int rtl_pci_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	    hw_queue != BEACON_QUEUE) {
 
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
-			 ("less desc left, stop skb_queue@%d, "
-			  "ring->idx = %d,"
-			  "idx = %d, skb_queue_len = 0x%d\n",
-			  hw_queue, ring->idx, idx,
-			  skb_queue_len(&ring->queue)));
+			 "less desc left, stop skb_queue@%d, ring->idx = %d, idx = %d, skb_queue_len = 0x%d\n",
+			 hw_queue, ring->idx, idx,
+			 skb_queue_len(&ring->queue));
 
 		ieee80211_stop_queue(hw, skb_get_queue_mapping(skb));
 	}
@@ -1497,7 +1487,7 @@ static int rtl_pci_init(struct ieee80211_hw *hw, struct pci_dev *pdev)
 	err = _rtl_pci_init_trx_ring(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("tx ring initialization failed"));
+			 "tx ring initialization failed\n");
 		return err;
 	}
 
@@ -1519,12 +1509,12 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 	err = rtlpriv->cfg->ops->hw_init(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("Failed to config hardware!\n"));
+			 "Failed to config hardware!\n");
 		return err;
 	}
 
 	rtlpriv->cfg->ops->enable_interrupt(hw);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("enable_interrupt OK\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "enable_interrupt OK\n");
 
 	rtl_init_rx_config(hw);
 
@@ -1535,7 +1525,7 @@ static int rtl_pci_start(struct ieee80211_hw *hw)
 
 	rtlpci->up_first_time = false;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("OK\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "OK\n");
 	return 0;
 }
 
@@ -1622,20 +1612,20 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 		switch (revisionid) {
 		case RTL_PCI_REVISION_ID_8192PCIE:
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-				 ("8192 PCI-E is found - "
-				  "vid/did=%x/%x\n", venderid, deviceid));
+				 "8192 PCI-E is found - vid/did=%x/%x\n",
+				 venderid, deviceid);
 			rtlhal->hw_type = HARDWARE_TYPE_RTL8192E;
 			break;
 		case RTL_PCI_REVISION_ID_8192SE:
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-				 ("8192SE is found - "
-				  "vid/did=%x/%x\n", venderid, deviceid));
+				 "8192SE is found - vid/did=%x/%x\n",
+				 venderid, deviceid);
 			rtlhal->hw_type = HARDWARE_TYPE_RTL8192SE;
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-				 ("Err: Unknown device - "
-				  "vid/did=%x/%x\n", venderid, deviceid));
+				 "Err: Unknown device - vid/did=%x/%x\n",
+				 venderid, deviceid);
 			rtlhal->hw_type = HARDWARE_TYPE_RTL8192SE;
 			break;
 
@@ -1646,18 +1636,18 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 		   deviceid == RTL_PCI_8188CE_DID) {
 		rtlhal->hw_type = HARDWARE_TYPE_RTL8192CE;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("8192C PCI-E is found - "
-			  "vid/did=%x/%x\n", venderid, deviceid));
+			 "8192C PCI-E is found - vid/did=%x/%x\n",
+			 venderid, deviceid);
 	} else if (deviceid == RTL_PCI_8192DE_DID ||
 		   deviceid == RTL_PCI_8192DE_DID2) {
 		rtlhal->hw_type = HARDWARE_TYPE_RTL8192DE;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("8192D PCI-E is found - "
-			  "vid/did=%x/%x\n", venderid, deviceid));
+			 "8192D PCI-E is found - vid/did=%x/%x\n",
+			 venderid, deviceid);
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Err: Unknown device -"
-			  " vid/did=%x/%x\n", venderid, deviceid));
+			 "Err: Unknown device - vid/did=%x/%x\n",
+			 venderid, deviceid);
 
 		rtlhal->hw_type = RTL_DEFAULT_HARDWARE_TYPE;
 	}
@@ -1665,19 +1655,18 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192DE) {
 		if (revisionid == 0 || revisionid == 1) {
 			if (revisionid == 0) {
-				RT_TRACE(rtlpriv, COMP_INIT,
-					 DBG_LOUD, ("Find 92DE MAC0.\n"));
+				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+					 "Find 92DE MAC0\n");
 				rtlhal->interfaceindex = 0;
 			} else if (revisionid == 1) {
 				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-					("Find 92DE MAC1.\n"));
+					 "Find 92DE MAC1\n");
 				rtlhal->interfaceindex = 1;
 			}
 		} else {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				("Unknown device - "
-				"VendorID/DeviceID=%x/%x, Revision=%x\n",
-				venderid, deviceid, revisionid));
+				 "Unknown device - VendorID/DeviceID=%x/%x, Revision=%x\n",
+				 venderid, deviceid, revisionid);
 			rtlhal->interfaceindex = 0;
 		}
 	}
@@ -1693,8 +1682,8 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 			if (bridge_pdev->vendor == pcibridge_vendors[tmp]) {
 				pcipriv->ndis_adapter.pcibridge_vendor = tmp;
 				RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-					 ("Pci Bridge Vendor is found index:"
-					 " %d\n", tmp));
+					 "Pci Bridge Vendor is found index: %d\n",
+					 tmp);
 				break;
 			}
 		}
@@ -1723,23 +1712,21 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	}
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("pcidev busnumber:devnumber:funcnumber:"
-		  "vendor:link_ctl %d:%d:%d:%x:%x\n",
-		  pcipriv->ndis_adapter.busnumber,
-		  pcipriv->ndis_adapter.devnumber,
-		  pcipriv->ndis_adapter.funcnumber,
-		  pdev->vendor, pcipriv->ndis_adapter.linkctrl_reg));
+		 "pcidev busnumber:devnumber:funcnumber:vendor:link_ctl %d:%d:%d:%x:%x\n",
+		 pcipriv->ndis_adapter.busnumber,
+		 pcipriv->ndis_adapter.devnumber,
+		 pcipriv->ndis_adapter.funcnumber,
+		 pdev->vendor, pcipriv->ndis_adapter.linkctrl_reg);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("pci_bridge busnumber:devnumber:funcnumber:vendor:"
-		  "pcie_cap:link_ctl_reg:amd %d:%d:%d:%x:%x:%x:%x\n",
-		  pcipriv->ndis_adapter.pcibridge_busnum,
-		  pcipriv->ndis_adapter.pcibridge_devnum,
-		  pcipriv->ndis_adapter.pcibridge_funcnum,
-		  pcibridge_vendors[pcipriv->ndis_adapter.pcibridge_vendor],
-		  pcipriv->ndis_adapter.pcibridge_pciehdr_offset,
-		  pcipriv->ndis_adapter.pcibridge_linkctrlreg,
-		  pcipriv->ndis_adapter.amd_l1_patch));
+		 "pci_bridge busnumber:devnumber:funcnumber:vendor:pcie_cap:link_ctl_reg:amd %d:%d:%d:%x:%x:%x:%x\n",
+		 pcipriv->ndis_adapter.pcibridge_busnum,
+		 pcipriv->ndis_adapter.pcibridge_devnum,
+		 pcipriv->ndis_adapter.pcibridge_funcnum,
+		 pcibridge_vendors[pcipriv->ndis_adapter.pcibridge_vendor],
+		 pcipriv->ndis_adapter.pcibridge_pciehdr_offset,
+		 pcipriv->ndis_adapter.pcibridge_linkctrlreg,
+		 pcipriv->ndis_adapter.amd_l1_patch);
 
 	rtl_pci_parse_configuration(pdev, hw);
 
@@ -1828,10 +1815,9 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	}
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("mem mapped space: start: 0x%08lx len:%08lx "
-		  "flags:%08lx, after map:0x%08lx\n",
-		  pmem_start, pmem_len, pmem_flags,
-		  rtlpriv->io.pci_mem_start));
+		 "mem mapped space: start: 0x%08lx len:%08lx flags:%08lx, after map:0x%08lx\n",
+		 pmem_start, pmem_len, pmem_flags,
+		 rtlpriv->io.pci_mem_start);
 
 	/* Disable Clk Request */
 	pci_write_config_byte(pdev, 0x81, 0);
@@ -1851,8 +1837,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
 
 	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't init_sw_vars.\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
 		goto fail3;
 	}
 
@@ -1865,22 +1850,21 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	err = rtl_init_core(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't allocate sw for mac80211.\n"));
+			 "Can't allocate sw for mac80211\n");
 		goto fail3;
 	}
 
 	/* Init PCI sw */
 	err = !rtl_pci_init(hw, pdev);
 	if (err) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Failed to init PCI.\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Failed to init PCI\n");
 		goto fail3;
 	}
 
 	err = ieee80211_register_hw(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't register mac80211 hw.\n"));
+			 "Can't register mac80211 hw\n");
 		goto fail3;
 	} else {
 		rtlpriv->mac80211.mac80211_registered = 1;
@@ -1889,7 +1873,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	err = sysfs_create_group(&pdev->dev.kobj, &rtl_attribute_group);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("failed to create sysfs device attributes\n"));
+			 "failed to create sysfs device attributes\n");
 		goto fail3;
 	}
 
@@ -1901,8 +1885,8 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 			  IRQF_SHARED, KBUILD_MODNAME, hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("%s: failed to register IRQ handler\n",
-			  wiphy_name(hw->wiphy)));
+			 "%s: failed to register IRQ handler\n",
+			 wiphy_name(hw->wiphy));
 		goto fail3;
 	} else {
 		rtlpci->irq_alloc = 1;
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 130fdd9..a36dc3d 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -44,7 +44,7 @@ bool rtl_ps_enable_nic(struct ieee80211_hw *hw)
 
 	if (is_hal_stop(rtlhal))
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Driver is already down!\n"));
+			 "Driver is already down!\n");
 
 	/*<2> Enable Adapter */
 	rtlpriv->cfg->ops->hw_init(hw);
@@ -120,7 +120,7 @@ bool rtl_ps_set_rf_state(struct ieee80211_hw *hw,
 
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 
@@ -176,7 +176,7 @@ void rtl_ips_nic_off_wq_callback(void *data)
 
 	if (mac->opmode != NL80211_IFTYPE_STATION) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("not station return\n"));
+			 "not station return\n");
 		return;
 	}
 
@@ -207,7 +207,7 @@ void rtl_ips_nic_off_wq_callback(void *data)
 		    (mac->link_state == MAC80211_NOLINK) &&
 		    !mac->act_scanning) {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-				 ("IPSEnter(): Turn off RF.\n"));
+				 "IPSEnter(): Turn off RF\n");
 
 			ppsc->inactive_pwrstate = ERFOFF;
 			ppsc->in_powersavemode = true;
@@ -280,8 +280,7 @@ static bool rtl_get_fwlps_doze(struct ieee80211_hw *hw)
 
 	if (ps_timediff < 2000) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("Delay enter Fw LPS for DHCP, ARP,"
-			  " or EAPOL exchanging state.\n"));
+			 "Delay enter Fw LPS for DHCP, ARP, or EAPOL exchanging state\n");
 		return false;
 	}
 
@@ -328,8 +327,8 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 		bool fw_current_inps;
 		if (ppsc->dot11_psmode == EACTIVE) {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 ("FW LPS leave ps_mode:%x\n",
-				  FW_PS_ACTIVE_MODE));
+				 "FW LPS leave ps_mode:%x\n",
+				 FW_PS_ACTIVE_MODE);
 
 			rpwm_val = 0x0C;	/* RF on */
 			fw_pwrmode = FW_PS_ACTIVE_MODE;
@@ -347,8 +346,8 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 		} else {
 			if (rtl_get_fwlps_doze(hw)) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-						("FW LPS enter ps_mode:%x\n",
-						 ppsc->fwctrl_psmode));
+					 "FW LPS enter ps_mode:%x\n",
+					 ppsc->fwctrl_psmode);
 
 				rpwm_val = 0x02;	/* RF off */
 				fw_current_inps = true;
@@ -402,7 +401,7 @@ void rtl_lps_enter(struct ieee80211_hw *hw)
 	if (mac->cnt_after_linked >= 2) {
 		if (ppsc->dot11_psmode == EACTIVE) {
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-					("Enter 802.11 power save mode...\n"));
+				 "Enter 802.11 power save mode...\n");
 
 			rtl_lps_set_psmode(hw, EAUTOPS);
 		}
@@ -434,7 +433,7 @@ void rtl_lps_leave(struct ieee80211_hw *hw)
 			}
 
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("Busy Traffic,Leave 802.11 power save..\n"));
+				 "Busy Traffic,Leave 802.11 power save..\n");
 
 			rtl_lps_set_psmode(hw, EACTIVE);
 		}
@@ -518,8 +517,8 @@ void rtl_swlps_beacon(struct ieee80211_hw *hw, void *data, unsigned int len)
 		queue_delayed_work(rtlpriv->works.rtl_wq,
 				&rtlpriv->works.ps_work, MSECS(5));
 	} else {
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG, ("u_bufferd: %x, "
-				"m_buffered: %x\n", u_buffed, m_buffed));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "u_bufferd: %x, m_buffered: %x\n", u_buffed, m_buffed);
 	}
 }
 
@@ -607,8 +606,8 @@ void rtl_swlps_rf_sleep(struct ieee80211_hw *hw)
 	 * sleep  = dtim_period, that meaons, we should
 	 * awake before every dtim */
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-		 ("dtim_counter:%x will sleep :%d"
-		 " beacon_intv\n", rtlpriv->psc.dtim_counter, sleep_intv));
+		 "dtim_counter:%x will sleep :%d beacon_intv\n",
+		 rtlpriv->psc.dtim_counter, sleep_intv);
 
 	/* we tested that 40ms is enough for sw & hw sw delay */
 	queue_delayed_work(rtlpriv->works.rtl_wq, &rtlpriv->works.ps_rfon_wq,
diff --git a/drivers/net/wireless/rtlwifi/rc.c b/drivers/net/wireless/rtlwifi/rc.c
index 539df66..4f560d6 100644
--- a/drivers/net/wireless/rtlwifi/rc.c
+++ b/drivers/net/wireless/rtlwifi/rc.c
@@ -251,7 +251,7 @@ static void *rtl_rate_alloc_sta(void *ppriv,
 	rate_priv = kzalloc(sizeof(struct rtl_rate_priv), gfp);
 	if (!rate_priv) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Unable to allocate private rc structure\n"));
+			 "Unable to allocate private rc structure\n");
 		return NULL;
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/regd.c b/drivers/net/wireless/rtlwifi/regd.c
index 9fedb1f..c263df2 100644
--- a/drivers/net/wireless/rtlwifi/regd.c
+++ b/drivers/net/wireless/rtlwifi/regd.c
@@ -398,13 +398,11 @@ int rtl_regd_init(struct ieee80211_hw *hw,
 	rtlpriv->regd.country_code = rtlpriv->efuse.channel_plan;
 
 	RT_TRACE(rtlpriv, COMP_REGD, DBG_TRACE,
-		 (KERN_DEBUG "rtl: EEPROM regdomain: 0x%0x\n",
-		  rtlpriv->regd.country_code));
+		 "rtl: EEPROM regdomain: 0x%0x\n", rtlpriv->regd.country_code);
 
 	if (rtlpriv->regd.country_code >= COUNTRY_CODE_MAX) {
 		RT_TRACE(rtlpriv, COMP_REGD, DBG_DMESG,
-			 (KERN_DEBUG "rtl: EEPROM indicates invalid contry code"
-			  "world wide 13 should be used\n"));
+			 "rtl: EEPROM indicates invalid contry code, world wide 13 should be used\n");
 
 		rtlpriv->regd.country_code = COUNTRY_CODE_WORLD_WIDE_13;
 	}
@@ -420,8 +418,8 @@ int rtl_regd_init(struct ieee80211_hw *hw,
 	}
 
 	RT_TRACE(rtlpriv, COMP_REGD, DBG_TRACE,
-		 (KERN_DEBUG "rtl: Country alpha2 being used: %c%c\n",
-		  rtlpriv->regd.alpha2[0], rtlpriv->regd.alpha2[1]));
+		 "rtl: Country alpha2 being used: %c%c\n",
+		 rtlpriv->regd.alpha2[0], rtlpriv->regd.alpha2[1]);
 
 	_rtl_regd_init_wiphy(&rtlpriv->regd, wiphy, reg_notifier);
 
@@ -433,7 +431,7 @@ int rtl_reg_notifier(struct wiphy *wiphy, struct regulatory_request *request)
 	struct ieee80211_hw *hw = wiphy_to_ieee80211_hw(wiphy);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_REGD, DBG_LOUD, ("\n"));
+	RT_TRACE(rtlpriv, COMP_REGD, DBG_LOUD, "\n");
 
 	return _rtl_reg_notifier_apply(wiphy, request, &rtlpriv->regd);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index 72a98ca..bf94cbf 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -246,16 +246,15 @@ static void rtl92c_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 	rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, 0x0000c000, 2);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 ("cnt_parity_fail = %d, cnt_rate_illegal = %d, "
-		  "cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
-		  falsealm_cnt->cnt_parity_fail,
-		  falsealm_cnt->cnt_rate_illegal,
-		  falsealm_cnt->cnt_crc8_fail, falsealm_cnt->cnt_mcs_fail));
+		 "cnt_parity_fail = %d, cnt_rate_illegal = %d, cnt_crc8_fail = %d, cnt_mcs_fail = %d\n",
+		 falsealm_cnt->cnt_parity_fail,
+		 falsealm_cnt->cnt_rate_illegal,
+		 falsealm_cnt->cnt_crc8_fail, falsealm_cnt->cnt_mcs_fail);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 ("cnt_ofdm_fail = %x, cnt_cck_fail = %x, cnt_all = %x\n",
-		  falsealm_cnt->cnt_ofdm_fail,
-		  falsealm_cnt->cnt_cck_fail, falsealm_cnt->cnt_all));
+		 "cnt_ofdm_fail = %x, cnt_cck_fail = %x, cnt_all = %x\n",
+		 falsealm_cnt->cnt_ofdm_fail,
+		 falsealm_cnt->cnt_cck_fail, falsealm_cnt->cnt_all);
 }
 
 static void rtl92c_dm_ctrl_initgain_by_fa(struct ieee80211_hw *hw)
@@ -313,8 +312,8 @@ static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
 		    dm_digtable.backoff_val;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 ("rssi_val_min = %x backoff_val %x\n",
-		  dm_digtable.rssi_val_min, dm_digtable.backoff_val));
+		 "rssi_val_min = %x backoff_val %x\n",
+		 dm_digtable.rssi_val_min, dm_digtable.backoff_val);
 
 	rtl92c_dm_write_dig(hw);
 }
@@ -364,10 +363,9 @@ static void rtl92c_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 	}
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 ("curmultista_connectstate = "
-		  "%x dig_ext_port_stage %x\n",
-		  dm_digtable.curmultista_connectstate,
-		  dm_digtable.dig_ext_port_stage));
+		 "curmultista_connectstate = %x dig_ext_port_stage %x\n",
+		 dm_digtable.curmultista_connectstate,
+		 dm_digtable.dig_ext_port_stage);
 }
 
 static void rtl92c_dm_initial_gain_sta(struct ieee80211_hw *hw)
@@ -375,10 +373,9 @@ static void rtl92c_dm_initial_gain_sta(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 ("presta_connectstate = %x,"
-		  " cursta_connectctate = %x\n",
-		  dm_digtable.presta_connectstate,
-		  dm_digtable.cursta_connectctate));
+		 "presta_connectstate = %x, cursta_connectctate = %x\n",
+		 dm_digtable.presta_connectstate,
+		 dm_digtable.cursta_connectctate);
 
 	if (dm_digtable.presta_connectstate == dm_digtable.cursta_connectctate
 	    || dm_digtable.cursta_connectctate == DIG_STA_BEFORE_CONNECT
@@ -464,11 +461,11 @@ static void rtl92c_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 		dm_digtable.pre_cck_pd_state = dm_digtable.cur_cck_pd_state;
 	}
 
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 ("CCKPDStage=%x\n", dm_digtable.cur_cck_pd_state));
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE, "CCKPDStage=%x\n",
+		 dm_digtable.cur_cck_pd_state);
 
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 ("is92C=%x\n", IS_92C_SERIAL(rtlhal->version)));
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE, "is92C=%x\n",
+		 IS_92C_SERIAL(rtlhal->version));
 }
 
 static void rtl92c_dm_ctrl_initgain_by_twoport(struct ieee80211_hw *hw)
@@ -519,10 +516,9 @@ void rtl92c_dm_write_dig(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 ("cur_igvalue = 0x%x, "
-		  "pre_igvalue = 0x%x, backoff_val = %d\n",
-		  dm_digtable.cur_igvalue, dm_digtable.pre_igvalue,
-		  dm_digtable.backoff_val));
+		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, backoff_val = %d\n",
+		 dm_digtable.cur_igvalue, dm_digtable.pre_igvalue,
+		 dm_digtable.backoff_val);
 
 	if (dm_digtable.pre_igvalue != dm_digtable.cur_igvalue) {
 		rtl_set_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f,
@@ -676,15 +672,14 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 
 	rtlpriv->dm.txpower_trackinginit = true;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 ("rtl92c_dm_txpower_tracking_callback_thermalmeter\n"));
+		 "rtl92c_dm_txpower_tracking_callback_thermalmeter\n");
 
 	thermalvalue = (u8) rtl_get_rfreg(hw, RF90_PATH_A, RF_T_METER, 0x1f);
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 ("Readback Thermal Meter = 0x%x pre thermal meter 0x%x "
-		  "eeprom_thermalmeter 0x%x\n",
-		  thermalvalue, rtlpriv->dm.thermalvalue,
-		  rtlefuse->eeprom_thermalmeter));
+		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermalmeter 0x%x\n",
+		 thermalvalue, rtlpriv->dm.thermalvalue,
+		 rtlefuse->eeprom_thermalmeter);
 
 	rtl92c_phy_ap_calibrate(hw, (thermalvalue -
 				     rtlefuse->eeprom_thermalmeter));
@@ -702,10 +697,9 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 				ofdm_index_old[0] = (u8) i;
 
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					("Initial pathA ele_d reg0x%x = 0x%lx, "
-					 "ofdm_index=0x%x\n",
+					 "Initial pathA ele_d reg0x%x = 0x%lx, ofdm_index=0x%x\n",
 					 ROFDM0_XATXIQIMBALANCE,
-					 ele_d, ofdm_index_old[0]));
+					 ele_d, ofdm_index_old[0]);
 				break;
 			}
 		}
@@ -719,11 +713,10 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 				    MASKOFDM_D)) {
 
 					RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
-					   DBG_LOUD,
-					   ("Initial pathB ele_d reg0x%x = "
-					   "0x%lx, ofdm_index=0x%x\n",
-					   ROFDM0_XBTXIQIMBALANCE, ele_d,
-					   ofdm_index_old[1]));
+						 DBG_LOUD,
+						 "Initial pathB ele_d reg0x%x = 0x%lx, ofdm_index=0x%x\n",
+						 ROFDM0_XBTXIQIMBALANCE, ele_d,
+						 ofdm_index_old[1]);
 					break;
 				}
 			}
@@ -741,11 +734,10 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 
 					RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
 						 DBG_LOUD,
-						 ("Initial reg0x%x = 0x%lx, "
-						  "cck_index=0x%x, ch 14 %d\n",
-						  RCCK0_TXFILTER2, temp_cck,
-						  cck_index_old,
-						  rtlpriv->dm.cck_inch14));
+						 "Initial reg0x%x = 0x%lx, cck_index=0x%x, ch 14 %d\n",
+						 RCCK0_TXFILTER2, temp_cck,
+						 cck_index_old,
+						 rtlpriv->dm.cck_inch14);
 					break;
 				}
 			} else {
@@ -757,11 +749,10 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 
 					RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
 						 DBG_LOUD,
-						 ("Initial reg0x%x = 0x%lx, "
-						  "cck_index=0x%x, ch14 %d\n",
-						  RCCK0_TXFILTER2, temp_cck,
-						  cck_index_old,
-						  rtlpriv->dm.cck_inch14));
+						 "Initial reg0x%x = 0x%lx, cck_index=0x%x, ch14 %d\n",
+						 RCCK0_TXFILTER2, temp_cck,
+						 cck_index_old,
+						 rtlpriv->dm.cck_inch14);
 					break;
 				}
 			}
@@ -790,12 +781,10 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 		    (rtlpriv->dm.thermalvalue_iqk - thermalvalue);
 
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			("Readback Thermal Meter = 0x%x pre thermal meter 0x%x "
-			 "eeprom_thermalmeter 0x%x delta 0x%x "
-			 "delta_lck 0x%x delta_iqk 0x%x\n",
+			 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermalmeter 0x%x delta 0x%x delta_lck 0x%x delta_iqk 0x%x\n",
 			 thermalvalue, rtlpriv->dm.thermalvalue,
 			 rtlefuse->eeprom_thermalmeter, delta, delta_lck,
-			 delta_iqk));
+			 delta_iqk);
 
 		if (delta_lck > 1) {
 			rtlpriv->dm.thermalvalue_lck = thermalvalue;
@@ -815,18 +804,15 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 
 			if (is2t) {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("temp OFDM_A_index=0x%x, "
-					  "OFDM_B_index=0x%x,"
-					  "cck_index=0x%x\n",
-					  rtlpriv->dm.ofdm_index[0],
-					  rtlpriv->dm.ofdm_index[1],
-					  rtlpriv->dm.cck_index));
+					 "temp OFDM_A_index=0x%x, OFDM_B_index=0x%x, cck_index=0x%x\n",
+					 rtlpriv->dm.ofdm_index[0],
+					 rtlpriv->dm.ofdm_index[1],
+					 rtlpriv->dm.cck_index);
 			} else {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("temp OFDM_A_index=0x%x,"
-					  "cck_index=0x%x\n",
-					  rtlpriv->dm.ofdm_index[0],
-					  rtlpriv->dm.cck_index));
+					 "temp OFDM_A_index=0x%x, cck_index=0x%x\n",
+					 rtlpriv->dm.ofdm_index[0],
+					 rtlpriv->dm.cck_index);
 			}
 
 			if (thermalvalue > rtlefuse->eeprom_thermalmeter) {
@@ -918,16 +904,13 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 
 			if (is2t) {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("new OFDM_A_index=0x%x, "
-					  "OFDM_B_index=0x%x,"
-					  "cck_index=0x%x\n",
-					  ofdm_index[0], ofdm_index[1],
-					  cck_index));
+					 "new OFDM_A_index=0x%x, OFDM_B_index=0x%x, cck_index=0x%x\n",
+					 ofdm_index[0], ofdm_index[1],
+					 cck_index);
 			} else {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("new OFDM_A_index=0x%x,"
-					  "cck_index=0x%x\n",
-					  ofdm_index[0], cck_index));
+					 "new OFDM_A_index=0x%x, cck_index=0x%x\n",
+					 ofdm_index[0], cck_index);
 			}
 		}
 
@@ -1085,7 +1068,7 @@ static void rtl92c_dm_txpower_tracking_callback_thermalmeter(struct ieee80211_hw
 			rtlpriv->dm.thermalvalue = thermalvalue;
 	}
 
-	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, ("<===\n"));
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "<===\n");
 
 }
 
@@ -1098,8 +1081,8 @@ static void rtl92c_dm_initialize_txpower_tracking_thermalmeter(
 	rtlpriv->dm.txpower_trackinginit = false;
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 ("pMgntInfo->txpower_tracking = %d\n",
-		  rtlpriv->dm.txpower_tracking));
+		 "pMgntInfo->txpower_tracking = %d\n",
+		 rtlpriv->dm.txpower_tracking);
 }
 
 static void rtl92c_dm_initialize_txpower_tracking(struct ieee80211_hw *hw)
@@ -1125,12 +1108,12 @@ static void rtl92c_dm_check_txpower_tracking_thermal_meter(
 		rtl_set_rfreg(hw, RF90_PATH_A, RF_T_METER, RFREG_OFFSET_MASK,
 			      0x60);
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 ("Trigger 92S Thermal Meter!!\n"));
+			 "Trigger 92S Thermal Meter!!\n");
 		tm_trigger = 1;
 		return;
 	} else {
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 ("Schedule TxPowerTracking direct call!!\n"));
+			 "Schedule TxPowerTracking direct call!!\n");
 		rtl92c_dm_txpower_tracking_directcall(hw);
 		tm_trigger = 0;
 	}
@@ -1169,13 +1152,13 @@ static void rtl92c_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 
 	if (is_hal_stop(rtlhal)) {
 		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-			 ("<---- driver is going to unload\n"));
+			 "<---- driver is going to unload\n");
 		return;
 	}
 
 	if (!rtlpriv->dm.useramask) {
 		RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-			("<---- driver does not control rate adaptive mask\n"));
+			 "<---- driver does not control rate adaptive mask\n");
 		return;
 	}
 
@@ -1210,14 +1193,13 @@ static void rtl92c_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 			p_ra->ratr_state = DM_RATR_STA_LOW;
 
 		if (p_ra->pre_ratr_state != p_ra->ratr_state) {
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD, "RSSI = %ld\n",
+				 rtlpriv->dm.undecorated_smoothed_pwdb);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 ("RSSI = %ld\n",
-				  rtlpriv->dm.undecorated_smoothed_pwdb));
+				 "RSSI_LEVEL = %d\n", p_ra->ratr_state);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 ("RSSI_LEVEL = %d\n", p_ra->ratr_state));
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
-				 ("PreState = %d, CurState = %d\n",
-				  p_ra->pre_ratr_state, p_ra->ratr_state));
+				 "PreState = %d, CurState = %d\n",
+				 p_ra->pre_ratr_state, p_ra->ratr_state);
 
 			rcu_read_lock();
 			sta = ieee80211_find_sta(mac->vif, mac->bssid);
@@ -1316,8 +1298,7 @@ static void rtl92c_dm_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 	if (((mac->link_state == MAC80211_NOLINK)) &&
 	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
 		dm_pstable.rssi_val_min = 0;
-		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
-			 ("Not connected to any\n"));
+		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD, "Not connected to any\n");
 	}
 
 	if (mac->link_state == MAC80211_LINKED) {
@@ -1325,22 +1306,22 @@ static void rtl92c_dm_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 			dm_pstable.rssi_val_min =
 			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
-				 ("AP Client PWDB = 0x%lx\n",
-				  dm_pstable.rssi_val_min));
+				 "AP Client PWDB = 0x%lx\n",
+				 dm_pstable.rssi_val_min);
 		} else {
 			dm_pstable.rssi_val_min =
 			    rtlpriv->dm.undecorated_smoothed_pwdb;
 			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
-				 ("STA Default Port PWDB = 0x%lx\n",
-				  dm_pstable.rssi_val_min));
+				 "STA Default Port PWDB = 0x%lx\n",
+				 dm_pstable.rssi_val_min);
 		}
 	} else {
 		dm_pstable.rssi_val_min =
 		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 
 		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
-			 ("AP Ext Port PWDB = 0x%lx\n",
-			  dm_pstable.rssi_val_min));
+			 "AP Ext Port PWDB = 0x%lx\n",
+			 dm_pstable.rssi_val_min);
 	}
 
 	if (IS_92C_SERIAL(rtlhal->version))
@@ -1381,7 +1362,7 @@ void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("Not connected to any\n"));
+			 "Not connected to any\n");
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 
@@ -1394,28 +1375,28 @@ void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("AP Client PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "AP Client PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		} else {
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.undecorated_smoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("STA Default Port PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "STA Default Port PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		}
 	} else {
 		undecorated_smoothed_pwdb =
 		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("AP Ext Port PWDB = 0x%lx\n",
-			  undecorated_smoothed_pwdb));
+			 "AP Ext Port PWDB = 0x%lx\n",
+			 undecorated_smoothed_pwdb);
 	}
 
 	if (undecorated_smoothed_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n"));
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
 	} else if ((undecorated_smoothed_pwdb <
 		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
 		   (undecorated_smoothed_pwdb >=
@@ -1423,18 +1404,18 @@ void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n"));
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
 	} else if (undecorated_smoothed_pwdb <
 		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_NORMAL\n"));
+			 "TXHIGHPWRLEVEL_NORMAL\n");
 	}
 
 	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("PHY_SetTxPowerLevel8192S() Channel = %d\n",
-			  rtlphy->current_channel));
+			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
+			 rtlphy->current_channel);
 		rtl92c_phy_set_txpower_level(hw, rtlphy->current_channel);
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 5401b32..12c025b 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -172,7 +172,7 @@ static void _rtl92c_write_fw(struct ieee80211_hw *hw,
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u8 *bufferPtr = (u8 *) buffer;
 
-	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, ("FW size is %d bytes,\n", size));
+	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "FW size is %d bytes\n", size);
 
 	if (IS_CHIP_VER_B(version)) {
 		u32 pageNums, remainSize;
@@ -186,7 +186,7 @@ static void _rtl92c_write_fw(struct ieee80211_hw *hw,
 
 		if (pageNums > 4) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Page numbers should not greater then 4\n"));
+				 "Page numbers should not greater then 4\n");
 		}
 
 		for (page = 0; page < pageNums; page++) {
@@ -219,13 +219,12 @@ static int _rtl92c_fw_free_to_go(struct ieee80211_hw *hw)
 
 	if (counter >= FW_8192C_POLLING_TIMEOUT_COUNT) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("chksum report faill ! REG_MCUFWDL:0x%08x .\n",
-			  value32));
+			 "chksum report faill ! REG_MCUFWDL:0x%08x\n", value32);
 		return -EIO;
 	}
 
 	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-		 ("Checksum report OK ! REG_MCUFWDL:0x%08x .\n", value32));
+		 "Checksum report OK ! REG_MCUFWDL:0x%08x\n", value32);
 
 	value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
 	value32 |= MCUFWDL_RDY;
@@ -238,9 +237,8 @@ static int _rtl92c_fw_free_to_go(struct ieee80211_hw *hw)
 		value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
 		if (value32 & WINTINI_RDY) {
 			RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-				 ("Polling FW ready success!!"
-				 " REG_MCUFWDL:0x%08x .\n",
-				 value32));
+				 "Polling FW ready success!! REG_MCUFWDL:0x%08x\n",
+				 value32);
 			return 0;
 		}
 
@@ -249,7 +247,7 @@ static int _rtl92c_fw_free_to_go(struct ieee80211_hw *hw)
 	} while (counter++ < FW_8192C_POLLING_TIMEOUT_COUNT);
 
 	RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-		 ("Polling FW ready fail!! REG_MCUFWDL:0x%08x .\n", value32));
+		 "Polling FW ready fail!! REG_MCUFWDL:0x%08x\n", value32);
 	return -EIO;
 }
 
@@ -272,10 +270,10 @@ int rtl92c_download_fw(struct ieee80211_hw *hw)
 
 	if (IS_FW_HEADER_EXIST(pfwheader)) {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-			 ("Firmware Version(%d), Signature(%#x),Size(%d)\n",
+			 "Firmware Version(%d), Signature(%#x),Size(%d)\n",
 			 le16_to_cpu(pfwheader->version),
 			 le16_to_cpu(pfwheader->signature),
-			 (uint)sizeof(struct rtl92c_firmware_header)));
+			 (uint)sizeof(struct rtl92c_firmware_header));
 
 		pfwdata = pfwdata + sizeof(struct rtl92c_firmware_header);
 		fwsize = fwsize - sizeof(struct rtl92c_firmware_header);
@@ -287,10 +285,10 @@ int rtl92c_download_fw(struct ieee80211_hw *hw)
 
 	if (_rtl92c_fw_free_to_go(hw)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Firmware is not ready to run!\n"));
+			 "Firmware is not ready to run!\n");
 	} else {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-			 ("Firmware is ready to run!\n"));
+			 "Firmware is ready to run!\n");
 	}
 
 	return 0;
@@ -328,22 +326,22 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 	unsigned long flag;
 	u8 idx;
 
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("come in\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "come in\n");
 
 	while (true) {
 		spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 		if (rtlhal->h2c_setinprogress) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("H2C set in progress! Wait to set.."
-				  "element_id(%d).\n", element_id));
+				 "H2C set in progress! Wait to set..element_id(%d)\n",
+				 element_id);
 
 			while (rtlhal->h2c_setinprogress) {
 				spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock,
 						       flag);
 				h2c_waitcounter++;
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					 ("Wait 100 us (%d times)...\n",
-					  h2c_waitcounter));
+					 "Wait 100 us (%d times)...\n",
+					 h2c_waitcounter);
 				udelay(100);
 
 				if (h2c_waitcounter > 1000)
@@ -363,8 +361,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 		wait_writeh2c_limmit--;
 		if (wait_writeh2c_limmit == 0) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Write H2C fail because no trigger "
-				  "for FW INT!\n"));
+				 "Write H2C fail because no trigger for FW INT!\n");
 			break;
 		}
 
@@ -388,7 +385,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 
@@ -398,8 +395,8 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			wait_h2c_limmit--;
 			if (wait_h2c_limmit == 0) {
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					 ("Wating too long for FW read "
-					  "clear HMEBox(%d)!\n", boxnum));
+					 "Waiting too long for FW read clear HMEBox(%d)!\n",
+					 boxnum);
 				break;
 			}
 
@@ -408,14 +405,14 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			isfw_read = _rtl92c_check_fw_read_last_h2c(hw, boxnum);
 			u1b_tmp = rtl_read_byte(rtlpriv, 0x1BF);
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("Wating for FW read clear HMEBox(%d)!!! "
-				  "0x1BF = %2x\n", boxnum, u1b_tmp));
+				 "Waiting for FW read clear HMEBox(%d)!!! 0x1BF = %2x\n",
+				 boxnum, u1b_tmp);
 		}
 
 		if (!isfw_read) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("Write H2C register BOX[%d] fail!!!!! "
-				  "Fw do not read.\n", boxnum));
+				 "Write H2C register BOX[%d] fail!!!!! Fw do not read\n",
+				 boxnum);
 			break;
 		}
 
@@ -423,8 +420,8 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 		memset(boxextcontent, 0, sizeof(boxextcontent));
 		boxcontent[0] = element_id;
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-			 ("Write element_id box_reg(%4x) = %2x\n",
-			  box_reg, element_id));
+			 "Write element_id box_reg(%4x) = %2x\n",
+			 box_reg, element_id);
 
 		switch (cmd_len) {
 		case 1:
@@ -493,7 +490,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 
@@ -504,15 +501,15 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 			rtlhal->last_hmeboxnum = 0;
 
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-			 ("pHalData->last_hmeboxnum  = %d\n",
-			  rtlhal->last_hmeboxnum));
+			 "pHalData->last_hmeboxnum  = %d\n",
+			 rtlhal->last_hmeboxnum);
 	}
 
 	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 	rtlhal->h2c_setinprogress = false;
 	spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
 
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("go out\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "go out\n");
 }
 
 void rtl92c_fill_h2c_cmd(struct ieee80211_hw *hw,
@@ -562,7 +559,7 @@ void rtl92c_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 	u8 u1_h2c_set_pwrmode[3] = {0};
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 
-	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, ("FW LPS mode = %d\n", mode));
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 
 	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, mode);
 	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode, 1);
@@ -798,14 +795,14 @@ void rtl92c_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 
 	if (dlok) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("Set RSVD page location to Fw.\n"));
+			 "Set RSVD page location to Fw\n");
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
 			      "H2C_RSVDPAGE", u1RsvdPageLoc, 3);
 		rtl92c_fill_h2c_cmd(hw, H2C_RSVDPAGE,
 				    sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
 	} else
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Set RSVD page location to Fw FAIL!!!!!!.\n"));
+			 "Set RSVD page location to Fw FAIL!!!!!!\n");
 }
 EXPORT_SYMBOL(rtl92c_set_fw_rsvdpagepkt);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
index 1f07558..8ab93a6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -42,16 +42,15 @@ u32 rtl92c_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 returnvalue, originalvalue, bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-					       "bitmask(%#x)\n", regaddr,
-					       bitmask));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "regaddr(%#x), bitmask(%#x)\n",
+		 regaddr, bitmask);
 	originalvalue = rtl_read_dword(rtlpriv, regaddr);
 	bitshift = _rtl92c_phy_calculate_bit_shift(bitmask);
 	returnvalue = (originalvalue & bitmask) >> bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("BBR MASK=0x%x "
-					       "Addr[0x%x]=0x%x\n", bitmask,
-					       regaddr, originalvalue));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "BBR MASK=0x%x Addr[0x%x]=0x%x\n",
+		 bitmask, regaddr, originalvalue);
 
 	return returnvalue;
 
@@ -64,9 +63,9 @@ void rtl92c_phy_set_bb_reg(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 originalvalue, bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x),"
-					       " data(%#x)\n", regaddr, bitmask,
-					       data));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
 
 	if (bitmask != MASKDWORD) {
 		originalvalue = rtl_read_dword(rtlpriv, regaddr);
@@ -76,9 +75,9 @@ void rtl92c_phy_set_bb_reg(struct ieee80211_hw *hw,
 
 	rtl_write_dword(rtlpriv, regaddr, data);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x),"
-					       " data(%#x)\n", regaddr, bitmask,
-					       data));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
 
 }
 EXPORT_SYMBOL(rtl92c_phy_set_bb_reg);
@@ -114,7 +113,7 @@ u32 _rtl92c_phy_rf_serial_read(struct ieee80211_hw *hw,
 	offset &= 0x3f;
 	newoffset = offset;
 	if (RT_CANNOT_IO(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("return all one\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "return all one\n");
 		return 0xFFFFFFFF;
 	}
 	tmplong = rtl_get_bbreg(hw, RFPGA0_XA_HSSIPARAMETER2, MASKDWORD);
@@ -144,9 +143,8 @@ u32 _rtl92c_phy_rf_serial_read(struct ieee80211_hw *hw,
 	else
 		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
 					 BLSSIREADBACKDATA);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("RFR-%d Addr[0x%x]=0x%x\n",
-					       rfpath, pphyreg->rflssi_readback,
-					       retvalue));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rflssi_readback, retvalue);
 	return retvalue;
 }
 EXPORT_SYMBOL(_rtl92c_phy_rf_serial_read);
@@ -162,16 +160,15 @@ void _rtl92c_phy_rf_serial_write(struct ieee80211_hw *hw,
 	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
 
 	if (RT_CANNOT_IO(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("stop\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "stop\n");
 		return;
 	}
 	offset &= 0x3f;
 	newoffset = offset;
 	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
 	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("RFW-%d Addr[0x%x]=0x%x\n",
-					       rfpath, pphyreg->rf3wire_offset,
-					       data_and_addr));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFW-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rf3wire_offset, data_and_addr);
 }
 EXPORT_SYMBOL(_rtl92c_phy_rf_serial_write);
 
@@ -216,16 +213,16 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	bool rtstatus;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("==>\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "==>\n");
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
 						 BASEBAND_CONFIG_PHY_REG);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Write BB Reg Fail!!"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 	if (rtlphy->rf_type == RF_1T2R) {
 		_rtl92c_phy_bb_config_1t(hw);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Config to 1T!!\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Config to 1T!!\n");
 	}
 	if (rtlefuse->autoload_failflag == false) {
 		rtlphy->pwrgroup_cnt = 0;
@@ -233,13 +230,13 @@ bool _rtl92c_phy_bb8192c_config_parafile(struct ieee80211_hw *hw)
 						   BASEBAND_CONFIG_PHY_REG);
 	}
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("BB_PG Reg Fail!!"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus = rtlpriv->cfg->ops->config_bb_with_headerfile(hw,
 						 BASEBAND_CONFIG_AGC_TAB);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("AGC Table Fail\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
 		return false;
 	}
 	rtlphy->cck_high_power = (bool) (rtl_get_bbreg(hw,
@@ -260,114 +257,114 @@ void _rtl92c_store_pwrIndex_diffrate_offset(struct ieee80211_hw *hw,
 	if (regaddr == RTXAGC_A_RATE18_06) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][0] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][0] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][0]));
+			 "MCSTxPowerLevelOriginalOffset[%d][0] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][0]);
 	}
 	if (regaddr == RTXAGC_A_RATE54_24) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][1] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][1] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][1]));
+			 "MCSTxPowerLevelOriginalOffset[%d][1] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][1]);
 	}
 	if (regaddr == RTXAGC_A_CCK1_MCS32) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][6] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][6] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][6]));
+			 "MCSTxPowerLevelOriginalOffset[%d][6] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][6]);
 	}
 	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0xffffff00) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][7] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][7] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][7]));
+			 "MCSTxPowerLevelOriginalOffset[%d][7] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][7]);
 	}
 	if (regaddr == RTXAGC_A_MCS03_MCS00) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][2] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][2] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][2]));
+			 "MCSTxPowerLevelOriginalOffset[%d][2] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][2]);
 	}
 	if (regaddr == RTXAGC_A_MCS07_MCS04) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][3] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][3] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][3]));
+			 "MCSTxPowerLevelOriginalOffset[%d][3] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][3]);
 	}
 	if (regaddr == RTXAGC_A_MCS11_MCS08) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][4] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][4] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][4]));
+			 "MCSTxPowerLevelOriginalOffset[%d][4] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][4]);
 	}
 	if (regaddr == RTXAGC_A_MCS15_MCS12) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][5] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][5] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][5]));
+			 "MCSTxPowerLevelOriginalOffset[%d][5] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][5]);
 	}
 	if (regaddr == RTXAGC_B_RATE18_06) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][8] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][8] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][8]));
+			 "MCSTxPowerLevelOriginalOffset[%d][8] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][8]);
 	}
 	if (regaddr == RTXAGC_B_RATE54_24) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][9] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][9] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][9]));
+			 "MCSTxPowerLevelOriginalOffset[%d][9] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][9]);
 	}
 	if (regaddr == RTXAGC_B_CCK1_55_MCS32) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][14] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][14] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][14]));
+			 "MCSTxPowerLevelOriginalOffset[%d][14] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][14]);
 	}
 	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0x000000ff) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][15] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][15] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][15]));
+			 "MCSTxPowerLevelOriginalOffset[%d][15] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][15]);
 	}
 	if (regaddr == RTXAGC_B_MCS03_MCS00) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][10] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][10] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][10]));
+			 "MCSTxPowerLevelOriginalOffset[%d][10] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][10]);
 	}
 	if (regaddr == RTXAGC_B_MCS07_MCS04) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][11] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][11] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][11]));
+			 "MCSTxPowerLevelOriginalOffset[%d][11] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][11]);
 	}
 	if (regaddr == RTXAGC_B_MCS11_MCS08) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][12] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][12] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][12]));
+			 "MCSTxPowerLevelOriginalOffset[%d][12] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][12]);
 	}
 	if (regaddr == RTXAGC_B_MCS15_MCS12) {
 		rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][13] = data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][13] = 0x%x\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][13]));
+			 "MCSTxPowerLevelOriginalOffset[%d][13] = 0x%x\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][13]);
 
 		rtlphy->pwrgroup_cnt++;
 	}
@@ -389,12 +386,11 @@ void rtl92c_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 	    (u8) rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, MASKBYTE0);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Default initial gain (c50=0x%x, "
-		  "c58=0x%x, c60=0x%x, c68=0x%x\n",
-		  rtlphy->default_initialgain[0],
-		  rtlphy->default_initialgain[1],
-		  rtlphy->default_initialgain[2],
-		  rtlphy->default_initialgain[3]));
+		 "Default initial gain (c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x\n",
+		 rtlphy->default_initialgain[0],
+		 rtlphy->default_initialgain[1],
+		 rtlphy->default_initialgain[2],
+		 rtlphy->default_initialgain[3]);
 
 	rtlphy->framesync = (u8) rtl_get_bbreg(hw,
 					       ROFDM0_RXDETECTOR3, MASKBYTE0);
@@ -402,8 +398,8 @@ void rtl92c_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 					      ROFDM0_RXDETECTOR2, MASKDWORD);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Default framesync (0x%x) = 0x%x\n",
-		  ROFDM0_RXDETECTOR3, rtlphy->framesync));
+		 "Default framesync (0x%x) = 0x%x\n",
+		 ROFDM0_RXDETECTOR3, rtlphy->framesync);
 }
 
 void _rtl92c_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
@@ -615,8 +611,8 @@ bool rtl92c_phy_update_txpower_dbm(struct ieee80211_hw *hw, long power_indbm)
 	else
 		ofdmtxpwridx = 0;
 	RT_TRACE(rtlpriv, COMP_TXAGC, DBG_TRACE,
-		 ("%lx dBm, ccktxpwridx = %d, ofdmtxpwridx = %d\n",
-		  power_indbm, ccktxpwridx, ofdmtxpwridx));
+		 "%lx dBm, ccktxpwridx = %d, ofdmtxpwridx = %d\n",
+		 power_indbm, ccktxpwridx, ofdmtxpwridx);
 	for (idx = 0; idx < 14; idx++) {
 		for (rf_path = 0; rf_path < 2; rf_path++) {
 			rtlefuse->txpwrlevel_cck[rf_path][idx] = ccktxpwridx;
@@ -710,7 +706,7 @@ void rtl92c_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Unknown Scan Backup operation.\n"));
+				 "Unknown Scan Backup operation\n");
 			break;
 		}
 	}
@@ -732,7 +728,7 @@ void rtl92c_phy_set_bw_mode(struct ieee80211_hw *hw,
 		rtlpriv->cfg->ops->phy_set_bw_mode_callback(hw);
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("FALSE driver sleep or unload\n"));
+			 "FALSE driver sleep or unload\n");
 		rtlphy->set_bwmode_inprogress = false;
 		rtlphy->current_chan_bw = tmp_bw;
 	}
@@ -747,7 +743,7 @@ void rtl92c_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 	u32 delay;
 
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
-		 ("switch to channel%d\n", rtlphy->current_channel));
+		 "switch to channel%d\n", rtlphy->current_channel);
 	if (is_hal_stop(rtlhal))
 		return;
 	do {
@@ -765,7 +761,7 @@ void rtl92c_phy_sw_chnl_callback(struct ieee80211_hw *hw)
 		}
 		break;
 	} while (true);
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("<==\n"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
 }
 EXPORT_SYMBOL(rtl92c_phy_sw_chnl_callback);
 
@@ -787,12 +783,11 @@ u8 rtl92c_phy_sw_chnl(struct ieee80211_hw *hw)
 	if (!(is_hal_stop(rtlhal)) && !(RT_CANNOT_IO(hw))) {
 		rtl92c_phy_sw_chnl_callback(hw);
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 ("sw_chnl_inprogress false schdule workitem\n"));
+			 "sw_chnl_inprogress false schdule workitem\n");
 		rtlphy->sw_chnl_inprogress = false;
 	} else {
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 ("sw_chnl_inprogress false driver sleep or"
-			  " unload\n"));
+			 "sw_chnl_inprogress false driver sleep or unload\n");
 		rtlphy->sw_chnl_inprogress = false;
 	}
 	return 1;
@@ -916,7 +911,7 @@ bool _rtl92c_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 
@@ -1920,23 +1915,23 @@ bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 	bool postprocessing = false;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 ("-->IO Cmd(%#x), set_io_inprogress(%d)\n",
-		  iotype, rtlphy->set_io_inprogress));
+		 "-->IO Cmd(%#x), set_io_inprogress(%d)\n",
+		 iotype, rtlphy->set_io_inprogress);
 	do {
 		switch (iotype) {
 		case IO_CMD_RESUME_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-				 ("[IO CMD] Resume DM after scan.\n"));
+				 "[IO CMD] Resume DM after scan\n");
 			postprocessing = true;
 			break;
 		case IO_CMD_PAUSE_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-				 ("[IO CMD] Pause DM before scan.\n"));
+				 "[IO CMD] Pause DM before scan\n");
 			postprocessing = true;
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 	} while (false);
@@ -1947,7 +1942,7 @@ bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 		return false;
 	}
 	rtl92c_phy_set_io(hw);
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, ("<--IO Type(%#x)\n", iotype));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "<--IO Type(%#x)\n", iotype);
 	return true;
 }
 EXPORT_SYMBOL(rtl92c_phy_set_io_cmd);
@@ -1958,8 +1953,8 @@ void rtl92c_phy_set_io(struct ieee80211_hw *hw)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 ("--->Cmd(%#x), set_io_inprogress(%d)\n",
-		  rtlphy->current_io_type, rtlphy->set_io_inprogress));
+		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
+		 rtlphy->current_io_type, rtlphy->set_io_inprogress);
 	switch (rtlphy->current_io_type) {
 	case IO_CMD_RESUME_DM_BY_SCAN:
 		dm_digtable.cur_igvalue = rtlphy->initgain_backup.xaagccore1;
@@ -1973,12 +1968,12 @@ void rtl92c_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 ("<---(%#x)\n", rtlphy->current_io_type));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "<---(%#x)\n",
+		 rtlphy->current_io_type);
 }
 EXPORT_SYMBOL(rtl92c_phy_set_io);
 
@@ -2018,7 +2013,7 @@ void _rtl92c_phy_set_rf_sleep(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
 		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("Switch RF timeout !!!.\n"));
+			 "Switch RF timeout !!!\n");
 		return;
 	}
 	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE2);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
index 2df33e5..6730e68 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
@@ -54,7 +54,7 @@ void rtl92ce_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("Not connected to any\n"));
+			 "Not connected to any\n");
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 
@@ -67,28 +67,28 @@ void rtl92ce_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("AP Client PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "AP Client PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		} else {
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.undecorated_smoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("STA Default Port PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "STA Default Port PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		}
 	} else {
 		undecorated_smoothed_pwdb =
 		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("AP Ext Port PWDB = 0x%lx\n",
-			  undecorated_smoothed_pwdb));
+			 "AP Ext Port PWDB = 0x%lx\n",
+			 undecorated_smoothed_pwdb);
 	}
 
 	if (undecorated_smoothed_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n"));
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
 	} else if ((undecorated_smoothed_pwdb <
 		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
 		   (undecorated_smoothed_pwdb >=
@@ -96,18 +96,18 @@ void rtl92ce_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n"));
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
 	} else if (undecorated_smoothed_pwdb <
 		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_NORMAL\n"));
+			 "TXHIGHPWRLEVEL_NORMAL\n");
 	}
 
 	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("PHY_SetTxPowerLevel8192S() Channel = %d\n",
-			  rtlphy->current_channel));
+			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
+			 rtlphy->current_channel);
 		rtl92c_phy_set_txpower_level(hw, rtlphy->current_channel);
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 2156378..4aa228f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -141,7 +141,7 @@ void rtl92ce_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 }
@@ -207,7 +207,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			u8 e_aci;
 
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("HW_VAR_SLOT_TIME %x\n", val[0]));
+				 "HW_VAR_SLOT_TIME %x\n", val[0]);
 
 			rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
 
@@ -246,8 +246,8 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				*val = min_spacing_to_set;
 
 				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-					 ("Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
-					  mac->min_space_cfg));
+					 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
+					 mac->min_space_cfg);
 
 				rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 					       mac->min_space_cfg);
@@ -261,8 +261,8 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			mac->min_space_cfg |= (density_to_set << 3);
 
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("Set HW_VAR_SHORTGI_DENSITY: %#x\n",
-				  mac->min_space_cfg));
+				 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
+				 mac->min_space_cfg);
 
 			rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 				       mac->min_space_cfg);
@@ -310,8 +310,8 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				}
 
 				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-					 ("Set HW_VAR_AMPDU_FACTOR: %#x\n",
-					  factor_toset));
+					 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
+					 factor_toset);
 			}
 			break;
 		}
@@ -348,8 +348,8 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-						 ("HW_VAR_ACM_CTRL acm set "
-						  "failed: eACI is %d\n", acm));
+						 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
+						 acm);
 					break;
 				}
 			} else {
@@ -365,14 +365,14 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-						 ("switch case not process\n"));
+						 "switch case not processed\n");
 					break;
 				}
 			}
 
 			RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
-				 ("SetHwReg8190pci(): [HW_VAR_ACM_CTRL] "
-				  "Write 0x%X\n", acm_ctrl));
+				 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
+				 acm_ctrl);
 			rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
 			break;
 		}
@@ -507,8 +507,8 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 		}
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("switch case "
-							"not process\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not processed\n");
 		break;
 	}
 }
@@ -530,8 +530,8 @@ static bool _rtl92ce_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
 
 		if (count > POLLING_LLT_THRESHOLD) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Failed to polling write LLT done at "
-				  "address %d!\n", address));
+				 "Failed to polling write LLT done at address %d!\n",
+				 address);
 			status = false;
 			break;
 		}
@@ -669,18 +669,15 @@ static bool _rtl92ce_init_mac(struct ieee80211_hw *hw)
 	udelay(2);
 
 	retry = 0;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("reg0xec:%x:%x\n",
-						rtl_read_dword(rtlpriv, 0xEC),
-						bytetmp));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "reg0xec:%x:%x\n",
+		 rtl_read_dword(rtlpriv, 0xEC), bytetmp);
 
 	while ((bytetmp & BIT(0)) && retry < 1000) {
 		retry++;
 		udelay(50);
 		bytetmp = rtl_read_byte(rtlpriv, REG_APS_FSMCO + 1);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("reg0xec:%x:%x\n",
-							rtl_read_dword(rtlpriv,
-								       0xEC),
-							bytetmp));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "reg0xec:%x:%x\n",
+			 rtl_read_dword(rtlpriv, 0xEC), bytetmp);
 		udelay(50);
 	}
 
@@ -864,13 +861,13 @@ void rtl92ce_enable_hw_security_config(struct ieee80211_hw *hw)
 	u8 sec_reg_value;
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
-		  rtlpriv->sec.pairwise_enc_algorithm,
-		  rtlpriv->sec.group_enc_algorithm));
+		 "PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
+		 rtlpriv->sec.pairwise_enc_algorithm,
+		 rtlpriv->sec.group_enc_algorithm);
 
 	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("not open "
-							"hw encryption\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
+			 "not open hw encryption\n");
 		return;
 	}
 
@@ -886,7 +883,7 @@ void rtl92ce_enable_hw_security_config(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_CR + 1, 0x02);
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-		 ("The SECR-value %x\n", sec_reg_value));
+		 "The SECR-value %x\n", sec_reg_value);
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
 
@@ -910,7 +907,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	rtlpriv->intf_ops->disable_aspm(hw);
 	rtstatus = _rtl92ce_init_mac(hw);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Init MAC failed\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
 		err = 1;
 		return err;
 	}
@@ -918,8 +915,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	err = rtl92c_download_fw(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Failed to download FW. Init HW "
-			  "without FW now..\n"));
+			 "Failed to download FW. Init HW without FW now..\n");
 		err = 1;
 		rtlhal->fw_ready = false;
 		return err;
@@ -968,12 +964,12 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 	tmp_u1b = efuse_read_1byte(hw, 0x1FA);
 	if (!(tmp_u1b & BIT(0))) {
 		rtl_set_rfreg(hw, RF90_PATH_A, 0x15, 0x0F, 0x05);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("PA BIAS path A\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "PA BIAS path A\n");
 	}
 
 	if (!(tmp_u1b & BIT(1)) && is92c) {
 		rtl_set_rfreg(hw, RF90_PATH_B, 0x15, 0x0F, 0x05);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("PA BIAS path B\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "PA BIAS path B\n");
 	}
 
 	if (!(tmp_u1b & BIT(4))) {
@@ -982,7 +978,7 @@ int rtl92ce_hw_init(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, 0x16, tmp_u1b | 0x80);
 		udelay(10);
 		rtl_write_byte(rtlpriv, 0x16, tmp_u1b | 0x90);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("under 1.5V\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "under 1.5V\n");
 	}
 	rtl92c_dm_init(hw);
 	rtlpci->being_init_adapter = false;
@@ -1008,23 +1004,23 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
 	switch (version) {
 	case VERSION_B_CHIP_92C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Chip Version ID: VERSION_B_CHIP_92C.\n"));
+			 "Chip Version ID: VERSION_B_CHIP_92C\n");
 		break;
 	case VERSION_B_CHIP_88C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Chip Version ID: VERSION_B_CHIP_88C.\n"));
+			 "Chip Version ID: VERSION_B_CHIP_88C\n");
 		break;
 	case VERSION_A_CHIP_92C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Chip Version ID: VERSION_A_CHIP_92C.\n"));
+			 "Chip Version ID: VERSION_A_CHIP_92C\n");
 		break;
 	case VERSION_A_CHIP_88C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Chip Version ID: VERSION_A_CHIP_88C.\n"));
+			 "Chip Version ID: VERSION_A_CHIP_88C\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Chip Version ID: Unknown. Bug?\n"));
+			 "Chip Version ID: Unknown. Bug?\n");
 		break;
 	}
 
@@ -1041,13 +1037,12 @@ static enum version_8192c _rtl92ce_read_chip_version(struct ieee80211_hw *hw)
 	default:
 		rtlphy->rf_type = RF_1T1R;
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("ERROR RF_Type is set!!"));
+			 "ERROR RF_Type is set!!\n");
 		break;
 	}
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("Chip RF Type: %s\n", (rtlphy->rf_type == RF_2T2R) ?
-		  "RF_2T2R" : "RF_1T1R"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Chip RF Type: %s\n",
+		 rtlphy->rf_type == RF_2T2R ? "RF_2T2R" : "RF_1T1R");
 
 	return version;
 }
@@ -1069,8 +1064,8 @@ static int _rtl92ce_set_media_status(struct ieee80211_hw *hw,
 		_rtl92ce_disable_bcn_sub_func(hw);
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Set HW_VAR_MEDIA_STATUS: "
-			  "No such media status(%x).\n", type));
+			 "Set HW_VAR_MEDIA_STATUS: No such media status(%x)\n",
+			 type);
 	}
 
 	switch (type) {
@@ -1078,27 +1073,27 @@ static int _rtl92ce_set_media_status(struct ieee80211_hw *hw,
 		bt_msr |= MSR_NOLINK;
 		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to NO LINK!\n"));
+			 "Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		bt_msr |= MSR_ADHOC;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to Ad Hoc!\n"));
+			 "Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
 		bt_msr |= MSR_INFRA;
 		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to STA!\n"));
+			 "Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
 		bt_msr |= MSR_AP;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to AP!\n"));
+			 "Set Network type to AP!\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Network type %d not support!\n", type));
+			 "Network type %d not supported!\n", type);
 		return 1;
 		break;
 
@@ -1300,7 +1295,7 @@ void rtl92ce_set_beacon_interval(struct ieee80211_hw *hw)
 	u16 bcn_interval = mac->beacon_interval;
 
 	RT_TRACE(rtlpriv, COMP_BEACON, DBG_DMESG,
-		 ("beacon_interval:%d\n", bcn_interval));
+		 "beacon_interval:%d\n", bcn_interval);
 	rtl92ce_disable_interrupt(hw);
 	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
 	rtl92ce_enable_interrupt(hw);
@@ -1312,8 +1307,8 @@ void rtl92ce_update_interrupt_mask(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
-	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
-		 ("add_msr:%x, rm_msr:%x\n", add_msr, rm_msr));
+	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD, "add_msr:%x, rm_msr:%x\n",
+		 add_msr, rm_msr);
 
 	if (add_msr)
 		rtlpci->irq_mask[0] |= add_msr;
@@ -1567,7 +1562,7 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 		       HWSET_MAX_SIZE);
 	} else if (rtlefuse->epromtype == EEPROM_93C46) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("RTL819X Not boot from eeprom, check it !!"));
+			 "RTL819X Not boot from eeprom, check it !!");
 	}
 
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
@@ -1576,10 +1571,10 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 	eeprom_id = *((u16 *)&hwinfo[0]);
 	if (eeprom_id != RTL8190_EEPROM_ID) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("EEPROM ID(%#x) is invalid!!\n", eeprom_id));
+			 "EEPROM ID(%#x) is invalid!!\n", eeprom_id);
 		rtlefuse->autoload_failflag = true;
 	} else {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
 	}
 
@@ -1591,8 +1586,7 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 		*((u16 *) (&rtlefuse->dev_addr[i])) = usvalue;
 	}
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("%pM\n", rtlefuse->dev_addr));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "%pM\n", rtlefuse->dev_addr);
 
 	_rtl92ce_read_txpower_info_from_hwpg(hw,
 					     rtlefuse->autoload_failflag,
@@ -1608,7 +1602,7 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid));
+		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
 
 	/* set channel paln to world wide 13 */
 	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
@@ -1662,7 +1656,7 @@ static void _rtl92ce_hal_customized_behavior(struct ieee80211_hw *hw)
 		break;
 	}
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("RT Customized ID: 0x%02X\n", rtlhal->oem_id));
+		 "RT Customized ID: 0x%02X\n", rtlhal->oem_id);
 }
 
 void rtl92ce_read_eeprom_info(struct ieee80211_hw *hw)
@@ -1679,22 +1673,22 @@ void rtl92ce_read_eeprom_info(struct ieee80211_hw *hw)
 	else
 		rtlpriv->dm.rfpath_rxenable[0] =
 		    rtlpriv->dm.rfpath_rxenable[1] = true;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("VersionID = 0x%4x\n",
-						rtlhal->version));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "VersionID = 0x%4x\n",
+		 rtlhal->version);
 	tmp_u1b = rtl_read_byte(rtlpriv, REG_9346CR);
 	if (tmp_u1b & BIT(4)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Boot from EEPROM\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EEPROM\n");
 		rtlefuse->epromtype = EEPROM_93C46;
 	} else {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Boot from EFUSE\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EFUSE\n");
 		rtlefuse->epromtype = EEPROM_BOOT_EFUSE;
 	}
 	if (tmp_u1b & BIT(5)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
 		_rtl92ce_read_adapter_info(hw);
 	} else {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Autoload ERR!!\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Autoload ERR!!\n");
 	}
 	_rtl92ce_hal_customized_behavior(hw);
 }
@@ -1790,8 +1784,8 @@ static void rtl92ce_update_hal_rate_table(struct ieee80211_hw *hw,
 
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
 
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-		 ("%x\n", rtl_read_dword(rtlpriv, REG_ARFR0)));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
+		 rtl_read_dword(rtlpriv, REG_ARFR0));
 }
 
 static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
@@ -1919,16 +1913,15 @@ static void rtl92ce_update_hal_rate_mask(struct ieee80211_hw *hw,
 		break;
 	}
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-		 ("ratr_bitmap :%x\n", ratr_bitmap));
+		 "ratr_bitmap :%x\n", ratr_bitmap);
 	*(u32 *)&rate_mask = EF4BYTE((ratr_bitmap & 0x0fffffff) |
 				     (ratr_index << 28));
 	rate_mask[4] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, ("Rate_index:%x, "
-						 "ratr_val:%x, %x:%x:%x:%x:%x\n",
-						 ratr_index, ratr_bitmap,
-						 rate_mask[0], rate_mask[1],
-						 rate_mask[2], rate_mask[3],
-						 rate_mask[4]));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
+		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
+		 ratr_index, ratr_bitmap,
+		 rate_mask[0], rate_mask[1], rate_mask[2], rate_mask[3],
+		 rate_mask[4]);
 	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
 
 	if (macid != 0)
@@ -1994,7 +1987,7 @@ bool rtl92ce_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 
 	if ((ppsc->hwradiooff) && (e_rfpowerstate_toset == ERFON)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 ("GPIOChangeRF  - HW Radio ON, RF ON\n"));
+			 "GPIOChangeRF  - HW Radio ON, RF ON\n");
 
 		e_rfpowerstate_toset = ERFON;
 		ppsc->hwradiooff = false;
@@ -2002,7 +1995,7 @@ bool rtl92ce_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	} else if ((ppsc->hwradiooff == false)
 		   && (e_rfpowerstate_toset == ERFOFF)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 ("GPIOChangeRF  - HW Radio OFF, RF OFF\n"));
+			 "GPIOChangeRF  - HW Radio OFF, RF OFF\n");
 
 		e_rfpowerstate_toset = ERFOFF;
 		ppsc->hwradiooff = true;
@@ -2053,7 +2046,7 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 		u8 cam_offset = 0;
 		u8 clear_number = 5;
 
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("clear_all\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "clear_all\n");
 
 		for (idx = 0; idx < clear_number; idx++) {
 			rtl_cam_mark_invalid(hw, cam_offset + idx);
@@ -2081,8 +2074,8 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 			enc_algo = CAM_AES;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("switch case "
-					"not process\n"));
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "switch case not processed\n");
 			enc_algo = CAM_TKIP;
 			break;
 		}
@@ -2100,9 +2093,8 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 								 p_macaddr);
 					if (entry_id >=  TOTAL_CAM_ENTRY) {
 						RT_TRACE(rtlpriv, COMP_SEC,
-						     DBG_EMERG,
-						     ("Can not find free hw"
-						     " security cam entry\n"));
+							 DBG_EMERG,
+							 "Can not find free hw security cam entry\n");
 						return;
 					}
 				} else {
@@ -2116,22 +2108,22 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 
 		if (rtlpriv->sec.key_len[key_index] == 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("delete one entry, entry_id is %d\n",
-				 entry_id));
+				 "delete one entry, entry_id is %d\n",
+				 entry_id);
 			if (mac->opmode == NL80211_IFTYPE_AP)
 				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY length is %d\n",
-				  rtlpriv->sec.key_len[PAIRWISE_KEYIDX]));
+				 "The insert KEY length is %d\n",
+				 rtlpriv->sec.key_len[PAIRWISE_KEYIDX]);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY  is %x %x\n",
-				  rtlpriv->sec.key_buf[0][0],
-				  rtlpriv->sec.key_buf[0][1]));
+				 "The insert KEY is %x %x\n",
+				 rtlpriv->sec.key_buf[0][0],
+				 rtlpriv->sec.key_buf[0][1]);
 
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("add one entry\n"));
+				 "add one entry\n");
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
 					      "Pairwise Key content",
@@ -2140,7 +2132,7 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 					      key_len[PAIRWISE_KEYIDX]);
 
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set Pairwiase key\n"));
+					 "set Pairwise key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
 						      entry_id, enc_algo,
@@ -2149,7 +2141,7 @@ void rtl92ce_set_key(struct ieee80211_hw *hw, u32 key_index,
 						      key_buf[key_index]);
 			} else {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set group key\n"));
+					 "set group key\n");
 
 				if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 					rtl_cam_add_one_entry(hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/led.c b/drivers/net/wireless/rtlwifi/rtl8192ce/led.c
index 28a1a70..09758f4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/led.c
@@ -45,8 +45,8 @@ void rtl92ce_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 	u8 ledcfg;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 REG_LEDCFG2, pled->ledpin);
 
 	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 
@@ -62,7 +62,7 @@ void rtl92ce_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = true;
@@ -74,8 +74,8 @@ void rtl92ce_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	u8 ledcfg;
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 REG_LEDCFG2, pled->ledpin);
 
 	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 
@@ -97,7 +97,7 @@ void rtl92ce_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = false;
@@ -145,7 +145,7 @@ void rtl92ce_led_control(struct ieee80211_hw *hw,
 	     ledaction == LED_CTL_POWER_ON)) {
 		return;
 	}
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, ("ledaction %d.\n",
-				ledaction));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d\n",
+		 ledaction);
 	_rtl92ce_sw_led_control(hw, ledaction);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
index ce9eea9..03ee82e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c
@@ -47,9 +47,9 @@ u32 rtl92c_phy_query_rf_reg(struct ieee80211_hw *hw,
 	u32 original_value, readback_value, bitshift;
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-					       "rfpath(%#x), bitmask(%#x)\n",
-					       regaddr, rfpath, bitmask));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x)\n",
+		 regaddr, rfpath, bitmask);
 
 	spin_lock(&rtlpriv->locks.rf_lock);
 
@@ -67,9 +67,8 @@ u32 rtl92c_phy_query_rf_reg(struct ieee80211_hw *hw,
 	spin_unlock(&rtlpriv->locks.rf_lock);
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 ("regaddr(%#x), rfpath(%#x), "
-		  "bitmask(%#x), original_value(%#x)\n",
-		  regaddr, rfpath, bitmask, original_value));
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
+		 regaddr, rfpath, bitmask, original_value);
 
 	return readback_value;
 }
@@ -121,8 +120,8 @@ void rtl92ce_phy_set_rf_reg(struct ieee80211_hw *hw,
 	u32 original_value, bitshift;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 ("regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
-		  regaddr, bitmask, data, rfpath));
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 
 	spin_lock(&rtlpriv->locks.rf_lock);
 
@@ -153,10 +152,9 @@ void rtl92ce_phy_set_rf_reg(struct ieee80211_hw *hw,
 
 	spin_unlock(&rtlpriv->locks.rf_lock);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-					       "bitmask(%#x), data(%#x), "
-					       "rfpath(%#x)\n", regaddr,
-					       bitmask, data, rfpath));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 }
 
 static bool _rtl92c_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
@@ -166,11 +164,10 @@ static bool _rtl92c_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
 	u32 arraylength;
 	u32 *ptrarray;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Read Rtl819XMACPHY_Array\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read Rtl819XMACPHY_Array\n");
 	arraylength = MAC_2T_ARRAYLENGTH;
 	ptrarray = RTL8192CEMAC_2T_ARRAY;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Img:RTL8192CEMAC_2T_ARRAY\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Img:RTL8192CEMAC_2T_ARRAY\n");
 	for (i = 0; i < arraylength; i = i + 2)
 		rtl_write_byte(rtlpriv, ptrarray[i], (u8) ptrarray[i + 1]);
 	return true;
@@ -215,10 +212,9 @@ bool _rtl92ce_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 				      phy_regarray_table[i + 1]);
 			udelay(1);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 ("The phy_regarray_table[0] is %x"
-				  " Rtl819XPHY_REGArray[1] is %x\n",
-				  phy_regarray_table[i],
-				  phy_regarray_table[i + 1]));
+				 "The phy_regarray_table[0] is %x Rtl819XPHY_REGArray[1] is %x\n",
+				 phy_regarray_table[i],
+				 phy_regarray_table[i + 1]);
 		}
 	} else if (configtype == BASEBAND_CONFIG_AGC_TAB) {
 		for (i = 0; i < agctab_arraylen; i = i + 2) {
@@ -226,10 +222,9 @@ bool _rtl92ce_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 				      agctab_array_table[i + 1]);
 			udelay(1);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 ("The agctab_array_table[0] is "
-				  "%x Rtl819XPHY_REGArray[1] is %x\n",
-				  agctab_array_table[i],
-				  agctab_array_table[i + 1]));
+				 "The agctab_array_table[0] is %x Rtl819XPHY_REGArray[1] is %x\n",
+				 agctab_array_table[i],
+				 agctab_array_table[i + 1]);
 		}
 	}
 	return true;
@@ -269,7 +264,7 @@ bool _rtl92ce_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
 	} else {
 
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 ("configtype != BaseBand_Config_PHY_REG\n"));
+			 "configtype != BaseBand_Config_PHY_REG\n");
 	}
 	return true;
 }
@@ -291,20 +286,20 @@ bool rtl92c_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		radiob_arraylen = RADIOB_2TARRAYLENGTH;
 		radiob_array_table = RTL8192CE_RADIOB_2TARRAY;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_A:RTL8192CERADIOA_2TARRAY\n"));
+			 "Radio_A:RTL8192CERADIOA_2TARRAY\n");
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_B:RTL8192CE_RADIOB_2TARRAY\n"));
+			 "Radio_B:RTL8192CE_RADIOB_2TARRAY\n");
 	} else {
 		radioa_arraylen = RADIOA_1TARRAYLENGTH;
 		radioa_array_table = RTL8192CE_RADIOA_1TARRAY;
 		radiob_arraylen = RADIOB_1TARRAYLENGTH;
 		radiob_array_table = RTL8192CE_RADIOB_1TARRAY;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_A:RTL8192CE_RADIOA_1TARRAY\n"));
+			 "Radio_A:RTL8192CE_RADIOA_1TARRAY\n");
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_B:RTL8192CE_RADIOB_1TARRAY\n"));
+			 "Radio_B:RTL8192CE_RADIOB_1TARRAY\n");
 	}
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Radio No %x\n", rfpath));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Radio No %x\n", rfpath);
 	switch (rfpath) {
 	case RF90_PATH_A:
 		for (i = 0; i < radioa_arraylen; i = i + 2) {
@@ -352,11 +347,11 @@ bool rtl92c_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		break;
 	case RF90_PATH_C:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	return true;
@@ -371,10 +366,9 @@ void rtl92ce_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 	u8 reg_bw_opmode;
 	u8 reg_prsr_rsc;
 
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
-		 ("Switch to %s bandwidth\n",
-		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
-		  "20MHz" : "40MHz"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "Switch to %s bandwidth\n",
+		 rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
+		 "20MHz" : "40MHz");
 
 	if (is_hal_stop(rtlhal)) {
 		rtlphy->set_bwmode_inprogress = false;
@@ -398,7 +392,7 @@ void rtl92ce_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
 
@@ -423,12 +417,12 @@ void rtl92ce_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
 	rtl92ce_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
 	rtlphy->set_bwmode_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("<==\n"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
 }
 
 void _rtl92ce_phy_lc_calibrate(struct ieee80211_hw *hw, bool is2t)
@@ -499,7 +493,7 @@ static void _rtl92ce_phy_set_rf_sleep(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
 		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("Switch RF timeout !!!.\n"));
+			 "Switch RF timeout !!!\n");
 		return;
 	}
 	rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE2);
@@ -526,7 +520,7 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				do {
 					InitializeCount++;
 					RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-						 ("IPS Set eRf nic enable\n"));
+						 "IPS Set eRf nic enable\n");
 					rtstatus = rtl_ps_enable_nic(hw);
 				} while ((rtstatus != true)
 					 && (InitializeCount < 10));
@@ -534,10 +528,10 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 						  RT_RF_OFF_LEVL_HALT_NIC);
 			} else {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-					 ("Set ERFON sleeped:%d ms\n",
-					  jiffies_to_msecs(jiffies -
-						   ppsc->
-						   last_sleep_jiffies)));
+					 "Set ERFON sleeped:%d ms\n",
+					 jiffies_to_msecs(jiffies -
+							  ppsc->
+							  last_sleep_jiffies));
 				ppsc->last_awake_jiffies = jiffies;
 				rtl92ce_phy_set_rf_on(hw);
 			}
@@ -553,7 +547,7 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 	case ERFOFF:{
 			if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-					 ("IPS Set eRf nic disable\n"));
+					 "IPS Set eRf nic disable\n");
 				rtl_ps_disable_nic(hw);
 				RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 			} else {
@@ -578,35 +572,33 @@ static bool _rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					continue;
 				} else {
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-						 ("eRf Off/Sleep: %d times "
-						  "TcbBusyQueue[%d] =%d before "
-						  "doze!\n", (i + 1), queue_id,
-						  skb_queue_len(&ring->queue)));
+						 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+						 i + 1, queue_id,
+						 skb_queue_len(&ring->queue));
 
 					udelay(10);
 					i++;
 				}
 				if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-						 ("\n ERFSLEEP: %d times "
-						  "TcbBusyQueue[%d] = %d !\n",
-						  MAX_DOZE_WAITING_TIMES_9x,
-						  queue_id,
-						  skb_queue_len(&ring->queue)));
+						 "ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
+						 MAX_DOZE_WAITING_TIMES_9x,
+						 queue_id,
+						 skb_queue_len(&ring->queue));
 					break;
 				}
 			}
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 ("Set ERFSLEEP awaked:%d ms\n",
-				  jiffies_to_msecs(jiffies -
-						   ppsc->last_awake_jiffies)));
+				 "Set ERFSLEEP awaked:%d ms\n",
+				 jiffies_to_msecs(jiffies -
+						  ppsc->last_awake_jiffies));
 			ppsc->last_sleep_jiffies = jiffies;
 			_rtl92ce_phy_set_rf_sleep(hw);
 			break;
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
index d3b01e6..3ba1a4f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
@@ -56,7 +56,7 @@ void rtl92ce_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", bandwidth));
+			 "unknown bandwidth: %#X\n", bandwidth);
 		break;
 	}
 }
@@ -512,12 +512,12 @@ static bool _rtl92ce_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 
 		if (rtstatus != true) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 ("Radio[%d] Fail!!", rfpath));
+				 "Radio[%d] Fail!!\n", rfpath);
 			return false;
 		}
 
 	}
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("<---\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "<---\n");
 	return rtstatus;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index 9ba6257..cab1c1f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -159,7 +159,7 @@ int rtl92c_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->rtlhal.pfirmware = vzalloc(0x4000);
 	if (!rtlpriv->rtlhal.pfirmware) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't alloc buffer for fw.\n"));
+			 "Can't alloc buffer for fw\n");
 		return 1;
 	}
 
@@ -174,12 +174,12 @@ int rtl92c_init_sw_vars(struct ieee80211_hw *hw)
 	err = request_firmware(&firmware, fw_name, rtlpriv->io.dev);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Failed to request firmware!\n"));
+			 "Failed to request firmware!\n");
 		return 1;
 	}
 	if (firmware->size > 0x4000) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Firmware is too big!\n"));
+			 "Firmware is too big!\n");
 		release_firmware(firmware);
 		return 1;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 378bc56..9f6fac4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -725,7 +725,7 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 		if (ieee80211_is_data_qos(fc)) {
 			if (mac->rdg_en) {
 				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-					 ("Enable RDG function.\n"));
+					 "Enable RDG function\n");
 				SET_TX_DESC_RDG_ENABLE(pdesc, 1);
 				SET_TX_DESC_HTC(pdesc, 1);
 			}
@@ -763,7 +763,7 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 		SET_TX_DESC_BMC(pdesc, 1);
 	}
 
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, ("\n"));
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
 }
 
 void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c b/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
index f311bae..c0016f3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
@@ -52,7 +52,7 @@ void rtl92cu_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("Not connected to any\n"));
+			 "Not connected to any\n");
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 
@@ -65,28 +65,28 @@ void rtl92cu_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("AP Client PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "AP Client PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		} else {
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.undecorated_smoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("STA Default Port PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "STA Default Port PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		}
 	} else {
 		undecorated_smoothed_pwdb =
 		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("AP Ext Port PWDB = 0x%lx\n",
-			  undecorated_smoothed_pwdb));
+			 "AP Ext Port PWDB = 0x%lx\n",
+			 undecorated_smoothed_pwdb);
 	}
 
 	if (undecorated_smoothed_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n"));
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
 	} else if ((undecorated_smoothed_pwdb <
 		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
 		   (undecorated_smoothed_pwdb >=
@@ -94,18 +94,18 @@ void rtl92cu_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n"));
+			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
 	} else if (undecorated_smoothed_pwdb <
 		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("TXHIGHPWRLEVEL_NORMAL\n"));
+			 "TXHIGHPWRLEVEL_NORMAL\n");
 	}
 
 	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("PHY_SetTxPowerLevel8192S() Channel = %d\n",
-			  rtlphy->current_channel));
+			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
+			 rtlphy->current_channel);
 		rtl92c_phy_set_txpower_level(hw, rtlphy->current_channel);
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 778c0e6..80bd17d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -494,17 +494,17 @@ static void _rtl92cu_read_adapter_info(struct ieee80211_hw *hw)
 		       HWSET_MAX_SIZE);
 	} else if (rtlefuse->epromtype == EEPROM_93C46) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("RTL819X Not boot from eeprom, check it !!"));
+			 "RTL819X Not boot from eeprom, check it !!\n");
 	}
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_LOUD, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
 	eeprom_id = le16_to_cpu(*((__le16 *)&hwinfo[0]));
 	if (eeprom_id != RTL8190_EEPROM_ID) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("EEPROM ID(%#x) is invalid!!\n", eeprom_id));
+			 "EEPROM ID(%#x) is invalid!!\n", eeprom_id);
 		rtlefuse->autoload_failflag = true;
 	} else {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
 	}
 	if (rtlefuse->autoload_failflag)
@@ -518,16 +518,15 @@ static void _rtl92cu_read_adapter_info(struct ieee80211_hw *hw)
 					   rtlefuse->autoload_failflag, hwinfo);
 	rtlefuse->eeprom_vid = le16_to_cpu(*(__le16 *)&hwinfo[EEPROM_VID]);
 	rtlefuse->eeprom_did = le16_to_cpu(*(__le16 *)&hwinfo[EEPROM_DID]);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 (" VID = 0x%02x PID = 0x%02x\n",
-		 rtlefuse->eeprom_vid, rtlefuse->eeprom_did));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, " VID = 0x%02x PID = 0x%02x\n",
+		 rtlefuse->eeprom_vid, rtlefuse->eeprom_did);
 	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->eeprom_version =
 			 le16_to_cpu(*(__le16 *)&hwinfo[EEPROM_VERSION]);
 	rtlefuse->txpwr_fromeprom = true;
 	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "EEPROM Customer ID: 0x%2x\n",
+		 rtlefuse->eeprom_oemid);
 	if (rtlhal->oem_id == RT_CID_DEFAULT) {
 		switch (rtlefuse->eeprom_oemid) {
 		case EEPROM_CID_DEFAULT:
@@ -579,8 +578,8 @@ static void _rtl92cu_hal_customized_behavior(struct ieee80211_hw *hw)
 	default:
 		break;
 	}
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("RT Customized ID: 0x%02X\n", rtlhal->oem_id));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "RT Customized ID: 0x%02X\n",
+		 rtlhal->oem_id);
 }
 
 void rtl92cu_read_eeprom_info(struct ieee80211_hw *hw)
@@ -596,11 +595,11 @@ void rtl92cu_read_eeprom_info(struct ieee80211_hw *hw)
 	tmp_u1b = rtl_read_byte(rtlpriv, REG_9346CR);
 	rtlefuse->epromtype = (tmp_u1b & BOOT_FROM_EEPROM) ?
 			       EEPROM_93C46 : EEPROM_BOOT_EFUSE;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Boot from %s\n",
-		 (tmp_u1b & BOOT_FROM_EEPROM) ? "EERROM" : "EFUSE"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from %s\n",
+		 tmp_u1b & BOOT_FROM_EEPROM ? "EERROM" : "EFUSE");
 	rtlefuse->autoload_failflag = (tmp_u1b & EEPROM_EN) ? false : true;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload %s\n",
-		 (tmp_u1b & EEPROM_EN) ? "OK!!" : "ERR!!"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload %s\n",
+		 tmp_u1b & EEPROM_EN ? "OK!!" : "ERR!!");
 	_rtl92cu_read_adapter_info(hw);
 	_rtl92cu_hal_customized_behavior(hw);
 	return;
@@ -618,13 +617,12 @@ static int _rtl92cu_init_power_on(struct ieee80211_hw *hw)
 	do {
 		if (rtl_read_byte(rtlpriv, REG_APS_FSMCO) & PFM_ALDN) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-				 ("Autoload Done!\n"));
+				 "Autoload Done!\n");
 			break;
 		}
 		if (pollingCount++ > 100) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-				 ("Failed to polling REG_APS_FSMCO[PFM_ALDN]"
-				 " done!\n"));
+				 "Failed to polling REG_APS_FSMCO[PFM_ALDN] done!\n");
 			return -ENODEV;
 		}
 	} while (true);
@@ -639,8 +637,8 @@ static int _rtl92cu_init_power_on(struct ieee80211_hw *hw)
 		value8 |= LDV12_EN;
 		rtl_write_byte(rtlpriv, REG_LDOV12D_CTRL, value8);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 (" power-on :REG_LDOV12D_CTRL Reg0x21:0x%02x.\n",
-			 value8));
+			 " power-on :REG_LDOV12D_CTRL Reg0x21:0x%02x\n",
+			 value8);
 		udelay(100);
 		value8 = rtl_read_byte(rtlpriv, REG_SYS_ISO_CTRL);
 		value8 &= ~ISO_MD2PP;
@@ -658,8 +656,7 @@ static int _rtl92cu_init_power_on(struct ieee80211_hw *hw)
 		}
 		if (pollingCount++ > 100) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-				 ("Failed to polling REG_APS_FSMCO[APFM_ONMAC]"
-				 " done!\n"));
+				 "Failed to polling REG_APS_FSMCO[APFM_ONMAC] done!\n");
 			return -ENODEV;
 		}
 	} while (true);
@@ -877,8 +874,8 @@ static void _rtl92cu_init_chipN_three_out_ep_priority(struct ieee80211_hw *hw,
 		hiQ	= QUEUE_HIGH;
 	}
 	_rtl92c_init_chipN_reg_priority(hw, beQ, bkQ, viQ, voQ, mgtQ, hiQ);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-		 ("Tx queue select :0x%02x..\n", queue_sel));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Tx queue select :0x%02x..\n",
+		 queue_sel);
 }
 
 static void _rtl92cu_init_chipN_queue_priority(struct ieee80211_hw *hw,
@@ -937,8 +934,8 @@ static void _rtl92cu_init_chipT_queue_priority(struct ieee80211_hw *hw,
 		break;
 	}
 	rtl_write_byte(rtlpriv, (REG_TRXDMA_CTRL+1), hq_sele);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-		 ("Tx queue select :0x%02x..\n", hq_sele));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Tx queue select :0x%02x..\n",
+		 hq_sele);
 }
 
 static void _rtl92cu_init_queue_priority(struct ieee80211_hw *hw,
@@ -998,7 +995,7 @@ static int _rtl92cu_init_mac(struct ieee80211_hw *hw)
 
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			("Failed to init power on!\n"));
+			 "Failed to init power on!\n");
 		return err;
 	}
 	if (!wmm_enable) {
@@ -1010,7 +1007,7 @@ static int _rtl92cu_init_mac(struct ieee80211_hw *hw)
 	}
 	if (false == rtl92c_init_llt_table(hw, boundary)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			("Failed to init LLT Table!\n"));
+			 "Failed to init LLT Table!\n");
 		return -EINVAL;
 	}
 	_rtl92cu_init_queue_reserved_page(hw, wmm_enable, out_ep_nums,
@@ -1043,12 +1040,12 @@ void rtl92cu_enable_hw_security_config(struct ieee80211_hw *hw)
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
-		  rtlpriv->sec.pairwise_enc_algorithm,
-		  rtlpriv->sec.group_enc_algorithm));
+		 "PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
+		 rtlpriv->sec.pairwise_enc_algorithm,
+		 rtlpriv->sec.group_enc_algorithm);
 	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-			 ("not open sw encryption\n"));
+			 "not open sw encryption\n");
 		return;
 	}
 	sec_reg_value = SCR_TxEncEnable | SCR_RxDecEnable;
@@ -1059,8 +1056,8 @@ void rtl92cu_enable_hw_security_config(struct ieee80211_hw *hw)
 	if (IS_NORMAL_CHIP(rtlhal->version))
 		sec_reg_value |= (SCR_RXBCUSEDK | SCR_TXBCUSEDK);
 	rtl_write_byte(rtlpriv, REG_CR + 1, 0x02);
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-		 ("The SECR-value %x\n", sec_reg_value));
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "The SECR-value %x\n",
+		 sec_reg_value);
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
 }
 
@@ -1163,13 +1160,13 @@ int rtl92cu_hw_init(struct ieee80211_hw *hw)
 	rtlhal->hw_type = HARDWARE_TYPE_RTL8192CU;
 	err = _rtl92cu_init_mac(hw);
 	if (err) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("init mac failed!\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "init mac failed!\n");
 		return err;
 	}
 	err = rtl92c_download_fw(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Failed to download FW. Init HW without FW now..\n"));
+			 "Failed to download FW. Init HW without FW now..\n");
 		err = 1;
 		rtlhal->fw_ready = false;
 		return err;
@@ -1280,8 +1277,7 @@ static void  _ResetDigitalProcedure1(struct ieee80211_hw *hw, bool bWithoutHWSM)
 				}
 				if (retry_cnts >= 100) {
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-						("#####=> 8051 reset failed!.."
-						".......................\n"););
+						 "#####=> 8051 reset failed!.........................\n");
 					/* if 8051 reset fail, reset MAC. */
 					rtl_write_byte(rtlpriv,
 						       REG_SYS_FUNC_EN + 1,
@@ -1495,35 +1491,36 @@ static int _rtl92cu_set_media_status(struct ieee80211_hw *hw,
 		_rtl92cu_resume_tx_beacon(hw);
 		_rtl92cu_disable_bcn_sub_func(hw);
 	} else {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING, ("Set HW_VAR_MEDIA_"
-			 "STATUS:No such media status(%x).\n", type));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
+			 "Set HW_VAR_MEDIA_STATUS:No such media status(%x)\n",
+			 type);
 	}
 	switch (type) {
 	case NL80211_IFTYPE_UNSPECIFIED:
 		bt_msr |= MSR_NOLINK;
 		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to NO LINK!\n"));
+			 "Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		bt_msr |= MSR_ADHOC;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to Ad Hoc!\n"));
+			 "Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
 		bt_msr |= MSR_INFRA;
 		ledaction = LED_CTL_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to STA!\n"));
+			 "Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
 		bt_msr |= MSR_AP;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to AP!\n"));
+			 "Set Network type to AP!\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Network type %d not support!\n", type));
+			 "Network type %d not supported!\n", type);
 		goto error_out;
 	}
 	rtl_write_byte(rtlpriv, (MSR), bt_msr);
@@ -1684,8 +1681,8 @@ void rtl92cu_set_beacon_related_registers(struct ieee80211_hw *hw)
 	value32 |= TSFRST;
 	rtl_write_dword(rtlpriv, REG_TCR, value32);
 	RT_TRACE(rtlpriv, COMP_INIT|COMP_BEACON, DBG_LOUD,
-		 ("SetBeaconRelatedRegisters8192CUsb(): Set TCR(%x)\n",
-		 value32));
+		 "SetBeaconRelatedRegisters8192CUsb(): Set TCR(%x)\n",
+		 value32);
 	/* TODO: Modify later (Find the right parameters)
 	 * NOTE: Fix test chip's bug (about contention windows's randomness) */
 	if ((mac->opmode == NL80211_IFTYPE_ADHOC) ||
@@ -1702,8 +1699,8 @@ void rtl92cu_set_beacon_interval(struct ieee80211_hw *hw)
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u16 bcn_interval = mac->beacon_interval;
 
-	RT_TRACE(rtlpriv, COMP_BEACON, DBG_DMESG,
-		 ("beacon_interval:%d\n", bcn_interval));
+	RT_TRACE(rtlpriv, COMP_BEACON, DBG_DMESG, "beacon_interval:%d\n",
+		 bcn_interval);
 	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
 }
 
@@ -1767,7 +1764,7 @@ void rtl92cu_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 }
@@ -1827,8 +1824,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtl_write_byte(rtlpriv, REG_MAC_SPEC_SIFS + 1, val[0]);
 			rtl_write_byte(rtlpriv, REG_R2T_SIFS+1, val[0]);
 			rtl_write_byte(rtlpriv, REG_T2T_SIFS+1, val[0]);
-			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("HW_VAR_SIFS\n"));
+			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD, "HW_VAR_SIFS\n");
 			break;
 		}
 	case HW_VAR_SLOT_TIME:{
@@ -1837,7 +1833,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 
 			rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("HW_VAR_SLOT_TIME %x\n", val[0]));
+				 "HW_VAR_SLOT_TIME %x\n", val[0]);
 			if (QOS_MODE) {
 				for (e_aci = 0; e_aci < AC_MAX; e_aci++)
 					rtlpriv->cfg->ops->set_hw_reg(hw,
@@ -1901,8 +1897,8 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 						     min_spacing_to_set);
 				*val = min_spacing_to_set;
 				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-					("Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
-					mac->min_space_cfg));
+					 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
+					 mac->min_space_cfg);
 				rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 					       mac->min_space_cfg);
 			}
@@ -1916,8 +1912,8 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			mac->min_space_cfg &= 0x07;
 			mac->min_space_cfg |= (density_to_set << 3);
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("Set HW_VAR_SHORTGI_DENSITY: %#x\n",
-				  mac->min_space_cfg));
+				 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
+				 mac->min_space_cfg);
 			rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 				       mac->min_space_cfg);
 			break;
@@ -1950,8 +1946,8 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 						       p_regtoset[index]);
 				}
 				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-					 ("Set HW_VAR_AMPDU_FACTOR: %#x\n",
-					  factor_toset));
+					 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
+					 factor_toset);
 			}
 			break;
 		}
@@ -1969,8 +1965,8 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					 AC_PARAM_ECW_MAX_OFFSET);
 			u4b_ac_param |= (u32) tx_op << AC_PARAM_TXOP_OFFSET;
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("queue:%x, ac_param:%x\n", e_aci,
-				  u4b_ac_param));
+				 "queue:%x, ac_param:%x\n",
+				 e_aci, u4b_ac_param);
 			switch (e_aci) {
 			case AC1_BK:
 				rtl_write_dword(rtlpriv, REG_EDCA_BK_PARAM,
@@ -2020,8 +2016,8 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-						 ("HW_VAR_ACM_CTRL acm set "
-						  "failed: eACI is %d\n", acm));
+						 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
+						 acm);
 					break;
 				}
 			} else {
@@ -2037,13 +2033,13 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-						 ("switch case not process\n"));
+						 "switch case not processed\n");
 					break;
 				}
 			}
 			RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
-				 ("SetHwReg8190pci(): [HW_VAR_ACM_CTRL] "
-				  "Write 0x%X\n", acm_ctrl));
+				 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
+				 acm_ctrl);
 			rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
 			break;
 		}
@@ -2051,7 +2047,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtl_write_dword(rtlpriv, REG_RCR, ((u32 *) (val))[0]);
 			mac->rx_conf = ((u32 *) (val))[0];
 			RT_TRACE(rtlpriv, COMP_RECV, DBG_DMESG,
-				 ("### Set RCR(0x%08x) ###\n", mac->rx_conf));
+				 "### Set RCR(0x%08x) ###\n", mac->rx_conf);
 			break;
 		}
 	case HW_VAR_RETRY_LIMIT:{
@@ -2060,8 +2056,9 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtl_write_word(rtlpriv, REG_RL,
 				       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
 				       retry_limit << RETRY_LIMIT_LONG_SHIFT);
-			RT_TRACE(rtlpriv, COMP_MLME, DBG_DMESG, ("Set HW_VAR_R"
-				 "ETRY_LIMIT(0x%08x)\n", retry_limit));
+			RT_TRACE(rtlpriv, COMP_MLME, DBG_DMESG,
+				 "Set HW_VAR_RETRY_LIMIT(0x%08x)\n",
+				 retry_limit);
 			break;
 		}
 	case HW_VAR_DUAL_TSF_RST:
@@ -2165,8 +2162,8 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtl_write_word(rtlpriv, REG_RXFLTMAP2, *(u16 *)val);
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("switch case "
-							"not process\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not processed\n");
 		break;
 	}
 }
@@ -2239,8 +2236,8 @@ void rtl92cu_update_hal_rate_table(struct ieee80211_hw *hw,
 			       (shortgi_rate << 4) | (shortgi_rate);
 	}
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, ("%x\n", rtl_read_dword(rtlpriv,
-		 REG_ARFR0)));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
+		 rtl_read_dword(rtlpriv, REG_ARFR0));
 }
 
 void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
@@ -2344,17 +2341,16 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
 			ratr_bitmap &= 0x0f0ff0ff;
 		break;
 	}
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, ("ratr_bitmap :%x\n",
-		 ratr_bitmap));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "ratr_bitmap :%x\n",
+		 ratr_bitmap);
 	*(u32 *)&rate_mask = ((ratr_bitmap & 0x0fffffff) |
 				      ratr_index << 28);
 	rate_mask[4] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, ("Rate_index:%x, "
-						"ratr_val:%x, %x:%x:%x:%x:%x\n",
-						ratr_index, ratr_bitmap,
-						rate_mask[0], rate_mask[1],
-						rate_mask[2], rate_mask[3],
-						rate_mask[4]));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
+		 "Rate_index:%x, ratr_val:%x, %x:%x:%x:%x:%x\n",
+		 ratr_index, ratr_bitmap,
+		 rate_mask[0], rate_mask[1], rate_mask[2], rate_mask[3],
+		 rate_mask[4]);
 	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
 }
 
@@ -2404,7 +2400,7 @@ bool rtl92cu_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 * valid)
 			e_rfpowerstate_toset = (u1tmp & BIT(7)) ?
 					       ERFOFF : ERFON;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-				 ("pwrdown, 0x5c(BIT7)=%02x\n", u1tmp));
+				 "pwrdown, 0x5c(BIT7)=%02x\n", u1tmp);
 		} else {
 			rtl_write_byte(rtlpriv, REG_MAC_PINMUX_CFG,
 				       rtl_read_byte(rtlpriv,
@@ -2413,27 +2409,26 @@ bool rtl92cu_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 * valid)
 			e_rfpowerstate_toset  = (u1tmp & BIT(3)) ?
 						 ERFON : ERFOFF;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-				("GPIO_IN=%02x\n", u1tmp));
+				 "GPIO_IN=%02x\n", u1tmp);
 		}
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, ("N-SS RF =%x\n",
-			 e_rfpowerstate_toset));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "N-SS RF =%x\n",
+			 e_rfpowerstate_toset);
 	}
 	if ((ppsc->hwradiooff) && (e_rfpowerstate_toset == ERFON)) {
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, ("GPIOChangeRF  - HW "
-			 "Radio ON, RF ON\n"));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "GPIOChangeRF  - HW Radio ON, RF ON\n");
 		ppsc->hwradiooff = false;
 		actuallyset = true;
 	} else if ((!ppsc->hwradiooff) && (e_rfpowerstate_toset  ==
 		    ERFOFF)) {
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, ("GPIOChangeRF  - HW"
-			 " Radio OFF\n"));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "GPIOChangeRF  - HW Radio OFF\n");
 		ppsc->hwradiooff = true;
 		actuallyset = true;
 	} else {
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD ,
-			 ("pHalData->bHwRadioOff and eRfPowerStateToSet do not"
-			 " match: pHalData->bHwRadioOff %x, eRfPowerStateToSet "
-			 "%x\n", ppsc->hwradiooff, e_rfpowerstate_toset));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "pHalData->bHwRadioOff and eRfPowerStateToSet do not match: pHalData->bHwRadioOff %x, eRfPowerStateToSet %x\n",
+			 ppsc->hwradiooff, e_rfpowerstate_toset);
 	}
 	if (actuallyset) {
 		ppsc->hwradiooff = true;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/led.c b/drivers/net/wireless/rtlwifi/rtl8192cu/led.c
index 2ff9d83..65fd044 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/led.c
@@ -47,8 +47,8 @@ void rtl92cu_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 	u8 ledcfg;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 REG_LEDCFG2, pled->ledpin);
 	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 	switch (pled->ledpin) {
 	case LED_PIN_GPIO0:
@@ -62,7 +62,7 @@ void rtl92cu_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = true;
@@ -74,8 +74,8 @@ void rtl92cu_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	struct rtl_usb_priv *usbpriv = rtl_usbpriv(hw);
 	u8 ledcfg;
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 REG_LEDCFG2, pled->ledpin);
 	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 	switch (pled->ledpin) {
 	case LED_PIN_GPIO0:
@@ -95,7 +95,7 @@ void rtl92cu_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = false;
@@ -136,7 +136,6 @@ void rtl92cu_led_control(struct ieee80211_hw *hw,
 	     ledaction == LED_CTL_POWER_ON)) {
 		return;
 	}
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, ("ledaction %d,\n",
-				ledaction));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d\n", ledaction);
 	_rtl92cu_sw_led_control(hw, ledaction);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 487ee90..9f09844 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -88,67 +88,59 @@ void rtl92c_read_chip_version(struct ieee80211_hw *hw)
 	switch (rtlhal->version) {
 	case VERSION_NORMAL_TSMC_CHIP_92C_1T2R:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Chip Version ID: VERSION_B_CHIP_92C.\n"));
+			 "Chip Version ID: VERSION_B_CHIP_92C\n");
 		break;
 	case VERSION_NORMAL_TSMC_CHIP_92C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_TSMC_CHIP_92C.\n"));
+			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_92C\n");
 		break;
 	case VERSION_NORMAL_TSMC_CHIP_88C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_TSMC_CHIP_88C.\n"));
+			 "Chip Version ID: VERSION_NORMAL_TSMC_CHIP_88C\n");
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_A_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_UMC_CHIP_i"
-			"92C_1T2R_A_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_i92C_1T2R_A_CUT\n");
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_A_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_UMC_CHIP_"
-			"92C_A_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_92C_A_CUT\n");
 		break;
 	case VERSION_NORMAL_UMC_CHIP_88C_A_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_UMC_CHIP"
-			"_88C_A_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_88C_A_CUT\n");
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_1T2R_B_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_UMC_CHIP"
-			"_92C_1T2R_B_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_92C_1T2R_B_CUT\n");
 		break;
 	case VERSION_NORMAL_UMC_CHIP_92C_B_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_UMC_CHIP"
-			"_92C_B_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_92C_B_CUT\n");
 		break;
 	case VERSION_NORMAL_UMC_CHIP_88C_B_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMAL_UMC_CHIP"
-			"_88C_B_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMAL_UMC_CHIP_88C_B_CUT\n");
 		break;
 	case VERSION_NORMA_UMC_CHIP_8723_1T1R_A_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMA_UMC_CHIP"
-			"_8723_1T1R_A_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMA_UMC_CHIP_8723_1T1R_A_CUT\n");
 		break;
 	case VERSION_NORMA_UMC_CHIP_8723_1T1R_B_CUT:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_NORMA_UMC_CHIP"
-			"_8723_1T1R_B_CUT.\n"));
+			 "Chip Version ID: VERSION_NORMA_UMC_CHIP_8723_1T1R_B_CUT\n");
 		break;
 	case VERSION_TEST_CHIP_92C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_TEST_CHIP_92C.\n"));
+			 "Chip Version ID: VERSION_TEST_CHIP_92C\n");
 		break;
 	case VERSION_TEST_CHIP_88C:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: VERSION_TEST_CHIP_88C.\n"));
+			 "Chip Version ID: VERSION_TEST_CHIP_88C\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			("Chip Version ID: ???????????????.\n"));
+			 "Chip Version ID: ???????????????\n");
 		break;
 	}
 	if (IS_92C_SERIAL(rtlhal->version))
@@ -157,15 +149,15 @@ void rtl92c_read_chip_version(struct ieee80211_hw *hw)
 	else
 		rtlphy->rf_type = RF_1T1R;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("Chip RF Type: %s\n", (rtlphy->rf_type == RF_2T2R) ?
-		  "RF_2T2R" : "RF_1T1R"));
+		 "Chip RF Type: %s\n",
+		 rtlphy->rf_type == RF_2T2R ? "RF_2T2R" : "RF_1T1R");
 	if (get_rf_type(rtlphy) == RF_1T1R)
 		rtlpriv->dm.rfpath_rxenable[0] = true;
 	else
 		rtlpriv->dm.rfpath_rxenable[0] =
 		    rtlpriv->dm.rfpath_rxenable[1] = true;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("VersionID = 0x%4x\n",
-						rtlhal->version));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "VersionID = 0x%4x\n",
+		 rtlhal->version);
 }
 
 /**
@@ -192,9 +184,8 @@ bool rtl92c_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
 			break;
 		if (count > POLLING_LLT_THRESHOLD) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Failed to polling write LLT done at"
-				 " address %d! _LLT_OP_VALUE(%x)\n",
-				 address, _LLT_OP_VALUE(value)));
+				 "Failed to polling write LLT done at address %d! _LLT_OP_VALUE(%x)\n",
+				 address, _LLT_OP_VALUE(value));
 			status = false;
 			break;
 		}
@@ -272,7 +263,7 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_index,
 		u8 cam_offset = 0;
 		u8 clear_number = 5;
 
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("clear_all\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "clear_all\n");
 		for (idx = 0; idx < clear_number; idx++) {
 			rtl_cam_mark_invalid(hw, cam_offset + idx);
 			rtl_cam_empty_entry(hw, cam_offset + idx);
@@ -298,7 +289,7 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_index,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				("iillegal switch case\n"));
+				 "illegal switch case\n");
 			enc_algo = CAM_TKIP;
 			break;
 		}
@@ -317,18 +308,18 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_index,
 		}
 		if (rtlpriv->sec.key_len[key_index] == 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("delete one entry\n"));
+				 "delete one entry\n");
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY length is %d\n",
-				  rtlpriv->sec.key_len[PAIRWISE_KEYIDX]));
+				 "The insert KEY length is %d\n",
+				 rtlpriv->sec.key_len[PAIRWISE_KEYIDX]);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY  is %x %x\n",
-				  rtlpriv->sec.key_buf[0][0],
-				  rtlpriv->sec.key_buf[0][1]));
+				 "The insert KEY is %x %x\n",
+				 rtlpriv->sec.key_buf[0][0],
+				 rtlpriv->sec.key_buf[0][1]);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("add one entry\n"));
+				 "add one entry\n");
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
 					      "Pairwise Key content",
@@ -336,7 +327,7 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_index,
 					      rtlpriv->sec.
 					      key_len[PAIRWISE_KEYIDX]);
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set Pairwiase key\n"));
+					 "set Pairwise key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
 						entry_id, enc_algo,
@@ -345,7 +336,7 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_index,
 						key_buf[key_index]);
 			} else {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set group key\n"));
+					 "set group key\n");
 				if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 					rtl_cam_add_one_entry(hw,
 						rtlefuse->dev_addr,
@@ -421,8 +412,8 @@ void rtl92c_set_qos(struct ieee80211_hw *hw, int aci)
 	    AC_PARAM_ECW_MAX_OFFSET;
 	u4b_ac_param |= (u32) le16_to_cpu(mac->ac[aci].tx_op) <<
 			 AC_PARAM_TXOP_OFFSET;
-	RT_TRACE(rtlpriv, COMP_QOS, DBG_LOUD,
-		 ("queue:%x, ac_param:%x\n", aci, u4b_ac_param));
+	RT_TRACE(rtlpriv, COMP_QOS, DBG_LOUD, "queue:%x, ac_param:%x\n",
+		 aci, u4b_ac_param);
 	switch (aci) {
 	case AC1_BK:
 		rtl_write_dword(rtlpriv, REG_EDCA_BK_PARAM, u4b_ac_param);
@@ -453,14 +444,14 @@ void rtl92c_set_mac_addr(struct ieee80211_hw *hw, const u8 *addr)
 	for (i = 0 ; i < ETH_ALEN ; i++)
 		rtl_write_byte(rtlpriv, (REG_MACID + i), *(addr+i));
 
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, ("MAC Address: %02X-%02X-%02X-"
-		"%02X-%02X-%02X\n",
-		rtl_read_byte(rtlpriv, REG_MACID),
-		rtl_read_byte(rtlpriv, REG_MACID+1),
-		rtl_read_byte(rtlpriv, REG_MACID+2),
-		rtl_read_byte(rtlpriv, REG_MACID+3),
-		rtl_read_byte(rtlpriv, REG_MACID+4),
-		rtl_read_byte(rtlpriv, REG_MACID+5)));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
+		 "MAC Address: %02X-%02X-%02X-%02X-%02X-%02X\n",
+		 rtl_read_byte(rtlpriv, REG_MACID),
+		 rtl_read_byte(rtlpriv, REG_MACID+1),
+		 rtl_read_byte(rtlpriv, REG_MACID+2),
+		 rtl_read_byte(rtlpriv, REG_MACID+3),
+		 rtl_read_byte(rtlpriv, REG_MACID+4),
+		 rtl_read_byte(rtlpriv, REG_MACID+5));
 }
 
 void rtl92c_init_driver_info_size(struct ieee80211_hw *hw, u8 size)
@@ -478,26 +469,26 @@ int rtl92c_set_network_type(struct ieee80211_hw *hw, enum nl80211_iftype type)
 	case NL80211_IFTYPE_UNSPECIFIED:
 		value = NT_NO_LINK;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			("Set Network type to NO LINK!\n"));
+			 "Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		value = NT_LINK_AD_HOC;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			("Set Network type to Ad Hoc!\n"));
+			 "Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
 		value = NT_LINK_AP;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			("Set Network type to STA!\n"));
+			 "Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
 		value = NT_AS_AP;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			("Set Network type to AP!\n"));
+			 "Set Network type to AP!\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			("Network type %d not support!\n", type));
+			 "Network type %d not supported!\n", type);
 		return -EOPNOTSUPP;
 	}
 	rtl_write_byte(rtlpriv, (REG_CR + 2), value);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
index df491d3..e7ea2ba 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c
@@ -44,9 +44,9 @@ u32 rtl92cu_phy_query_rf_reg(struct ieee80211_hw *hw,
 	u32 original_value, readback_value, bitshift;
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-					       "rfpath(%#x), bitmask(%#x)\n",
-					       regaddr, rfpath, bitmask));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x)\n",
+		 regaddr, rfpath, bitmask);
 	if (rtlphy->rf_mode != RF_OP_BY_FW) {
 		original_value = _rtl92c_phy_rf_serial_read(hw,
 							    rfpath, regaddr);
@@ -57,9 +57,8 @@ u32 rtl92cu_phy_query_rf_reg(struct ieee80211_hw *hw,
 	bitshift = _rtl92c_phy_calculate_bit_shift(bitmask);
 	readback_value = (original_value & bitmask) >> bitshift;
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 ("regaddr(%#x), rfpath(%#x), "
-		  "bitmask(%#x), original_value(%#x)\n",
-		  regaddr, rfpath, bitmask, original_value));
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
+		 regaddr, rfpath, bitmask, original_value);
 	return readback_value;
 }
 
@@ -72,8 +71,8 @@ void rtl92cu_phy_set_rf_reg(struct ieee80211_hw *hw,
 	u32 original_value, bitshift;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 ("regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
-		  regaddr, bitmask, data, rfpath));
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 	if (rtlphy->rf_mode != RF_OP_BY_FW) {
 		if (bitmask != RFREG_OFFSET_MASK) {
 			original_value = _rtl92c_phy_rf_serial_read(hw,
@@ -97,9 +96,9 @@ void rtl92cu_phy_set_rf_reg(struct ieee80211_hw *hw,
 		}
 		_rtl92c_phy_fw_rf_serial_write(hw, rfpath, regaddr, data);
 	}
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-					       "bitmask(%#x), data(%#x), rfpath(%#x)\n",
-					       regaddr, bitmask, data, rfpath));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 }
 
 bool rtl92cu_phy_mac_config(struct ieee80211_hw *hw)
@@ -152,11 +151,10 @@ bool _rtl92cu_phy_config_mac_with_headerfile(struct ieee80211_hw *hw)
 	u32 arraylength;
 	u32 *ptrarray;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Read Rtl819XMACPHY_Array\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read Rtl819XMACPHY_Array\n");
 	arraylength =  rtlphy->hwparam_tables[MAC_REG].length ;
 	ptrarray = rtlphy->hwparam_tables[MAC_REG].pdata;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Img:RTL8192CEMAC_2T_ARRAY\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Img:RTL8192CEMAC_2T_ARRAY\n");
 	for (i = 0; i < arraylength; i = i + 2)
 		rtl_write_byte(rtlpriv, ptrarray[i], (u8) ptrarray[i + 1]);
 	return true;
@@ -202,10 +200,9 @@ bool _rtl92cu_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 				      phy_regarray_table[i + 1]);
 			udelay(1);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 ("The phy_regarray_table[0] is %x"
-				  " Rtl819XPHY_REGArray[1] is %x\n",
-				  phy_regarray_table[i],
-				  phy_regarray_table[i + 1]));
+				 "The phy_regarray_table[0] is %x Rtl819XPHY_REGArray[1] is %x\n",
+				 phy_regarray_table[i],
+				 phy_regarray_table[i + 1]);
 		}
 	} else if (configtype == BASEBAND_CONFIG_AGC_TAB) {
 		for (i = 0; i < agctab_arraylen; i = i + 2) {
@@ -213,10 +210,9 @@ bool _rtl92cu_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 				      agctab_array_table[i + 1]);
 			udelay(1);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 ("The agctab_array_table[0] is "
-				  "%x Rtl819XPHY_REGArray[1] is %x\n",
-				  agctab_array_table[i],
-				  agctab_array_table[i + 1]));
+				 "The agctab_array_table[0] is %x Rtl819XPHY_REGArray[1] is %x\n",
+				 agctab_array_table[i],
+				 agctab_array_table[i + 1]);
 		}
 	}
 	return true;
@@ -255,7 +251,7 @@ bool _rtl92cu_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
 		}
 	} else {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 ("configtype != BaseBand_Config_PHY_REG\n"));
+			 "configtype != BaseBand_Config_PHY_REG\n");
 	}
 	return true;
 }
@@ -277,20 +273,20 @@ bool rtl92cu_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		radiob_arraylen = rtlphy->hwparam_tables[RADIOB_2T].length;
 		radiob_array_table = rtlphy->hwparam_tables[RADIOB_2T].pdata;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_A:RTL8192CERADIOA_2TARRAY\n"));
+			 "Radio_A:RTL8192CERADIOA_2TARRAY\n");
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_B:RTL8192CE_RADIOB_2TARRAY\n"));
+			 "Radio_B:RTL8192CE_RADIOB_2TARRAY\n");
 	} else {
 		radioa_arraylen = rtlphy->hwparam_tables[RADIOA_1T].length;
 		radioa_array_table = rtlphy->hwparam_tables[RADIOA_1T].pdata;
 		radiob_arraylen = rtlphy->hwparam_tables[RADIOB_1T].length;
 		radiob_array_table = rtlphy->hwparam_tables[RADIOB_1T].pdata;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_A:RTL8192CE_RADIOA_1TARRAY\n"));
+			 "Radio_A:RTL8192CE_RADIOA_1TARRAY\n");
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Radio_B:RTL8192CE_RADIOB_1TARRAY\n"));
+			 "Radio_B:RTL8192CE_RADIOB_1TARRAY\n");
 	}
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Radio No %x\n", rfpath));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Radio No %x\n", rfpath);
 	switch (rfpath) {
 	case RF90_PATH_A:
 		for (i = 0; i < radioa_arraylen; i = i + 2) {
@@ -338,11 +334,11 @@ bool rtl92cu_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		break;
 	case RF90_PATH_C:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	return true;
@@ -357,10 +353,9 @@ void rtl92cu_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 	u8 reg_bw_opmode;
 	u8 reg_prsr_rsc;
 
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
-		 ("Switch to %s bandwidth\n",
-		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
-		  "20MHz" : "40MHz"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "Switch to %s bandwidth\n",
+		 rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
+		 "20MHz" : "40MHz");
 	if (is_hal_stop(rtlhal)) {
 		rtlphy->set_bwmode_inprogress = false;
 		return;
@@ -381,7 +376,7 @@ void rtl92cu_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
 	switch (rtlphy->current_chan_bw) {
@@ -403,12 +398,12 @@ void rtl92cu_phy_set_bw_mode_callback(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
 	rtl92cu_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
 	rtlphy->set_bwmode_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("<==\n"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
 }
 
 void rtl92cu_bb_block_on(struct ieee80211_hw *hw)
@@ -480,7 +475,7 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *hw,
 			do {
 				InitializeCount++;
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-					 ("IPS Set eRf nic enable\n"));
+					 "IPS Set eRf nic enable\n");
 				rtstatus = rtl_ps_enable_nic(hw);
 			} while ((rtstatus != true)
 				 && (InitializeCount < 10));
@@ -488,10 +483,9 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 ("Set ERFON sleeped:%d ms\n",
-				  jiffies_to_msecs(jiffies -
-						   ppsc->
-						   last_sleep_jiffies)));
+				 "Set ERFON sleeped:%d ms\n",
+				 jiffies_to_msecs(jiffies -
+						  ppsc->last_sleep_jiffies));
 			ppsc->last_awake_jiffies = jiffies;
 			rtl92ce_phy_set_rf_on(hw);
 		}
@@ -513,27 +507,25 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				continue;
 			} else {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("eRf Off/Sleep: %d times "
-					  "TcbBusyQueue[%d] "
-					  "=%d before doze!\n", (i + 1),
-					  queue_id,
-					  skb_queue_len(&ring->queue)));
+					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+					 i + 1,
+					 queue_id,
+					 skb_queue_len(&ring->queue));
 				udelay(10);
 				i++;
 			}
 			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("\nERFOFF: %d times "
-					  "TcbBusyQueue[%d] = %d !\n",
-					  MAX_DOZE_WAITING_TIMES_9x,
-					  queue_id,
-					  skb_queue_len(&ring->queue)));
+					 "ERFOFF: %d times TcbBusyQueue[%d] = %d !\n",
+					 MAX_DOZE_WAITING_TIMES_9x,
+					 queue_id,
+					 skb_queue_len(&ring->queue));
 				break;
 			}
 		}
 		if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC) {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 ("IPS Set eRf nic disable\n"));
+				 "IPS Set eRf nic disable\n");
 			rtl_ps_disable_nic(hw);
 			RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
@@ -557,33 +549,30 @@ static bool _rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				continue;
 			} else {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("eRf Off/Sleep: %d times "
-					  "TcbBusyQueue[%d] =%d before "
-					  "doze!\n", (i + 1), queue_id,
-					  skb_queue_len(&ring->queue)));
+					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+					 i + 1, queue_id,
+					 skb_queue_len(&ring->queue));
 				udelay(10);
 				i++;
 			}
 			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("\n ERFSLEEP: %d times "
-					  "TcbBusyQueue[%d] = %d !\n",
-					  MAX_DOZE_WAITING_TIMES_9x,
-					  queue_id,
-					  skb_queue_len(&ring->queue)));
+					 "ERFSLEEP: %d times TcbBusyQueue[%d] = %d !\n",
+					 MAX_DOZE_WAITING_TIMES_9x,
+					 queue_id,
+					 skb_queue_len(&ring->queue));
 				break;
 			}
 		}
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 ("Set ERFSLEEP awaked:%d ms\n",
-			  jiffies_to_msecs(jiffies -
-					   ppsc->last_awake_jiffies)));
+			 "Set ERFSLEEP awaked:%d ms\n",
+			 jiffies_to_msecs(jiffies - ppsc->last_awake_jiffies));
 		ppsc->last_sleep_jiffies = jiffies;
 		_rtl92c_phy_set_rf_sleep(hw);
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		bresult = false;
 		break;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
index 1e851aa..7b48ee9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
@@ -56,7 +56,7 @@ void rtl92cu_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", bandwidth));
+			 "unknown bandwidth: %#X\n", bandwidth);
 		break;
 	}
 }
@@ -482,11 +482,11 @@ static bool _rtl92c_phy_rf6052_config_parafile(struct ieee80211_hw *hw)
 		}
 		if (rtstatus != true) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 ("Radio[%d] Fail!!", rfpath));
+				 "Radio[%d] Fail!!", rfpath);
 			goto phy_rf_cfg_fail;
 		}
 	}
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("<---\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "<---\n");
 	return rtstatus;
 phy_rf_cfg_fail:
 	return rtstatus;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index cf72096..871e15d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -79,7 +79,7 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 	rtl8192cu_firmware = vzalloc(0x4000);
 	if (!rtl8192cu_firmware) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't alloc buffer for fw.\n"));
+			 "Can't alloc buffer for fw\n");
 		return 1;
 	}
 
@@ -88,12 +88,12 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 			rtlpriv->io.dev);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Failed to request firmware!\n"));
+			 "Failed to request firmware!\n");
 		return 1;
 	}
 	if (firmware->size > 0x4000) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Firmware is too big!\n"));
+			 "Firmware is too big!\n");
 		release_firmware(firmware);
 		return 1;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 128cfcd..b875af7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -108,7 +108,7 @@ static void _TwoOutEpMapping(struct ieee80211_hw *hw, bool bIsChipB,
 
 	if (bwificfg) { /* for WMM */
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("USB Chip-B & WMM Setting.....\n"));
+			 "USB Chip-B & WMM Setting.....\n");
 		ep_map->ep_mapping[RTL_TXQ_BE]	= 2;
 		ep_map->ep_mapping[RTL_TXQ_BK]	= 3;
 		ep_map->ep_mapping[RTL_TXQ_VI]	= 3;
@@ -118,7 +118,7 @@ static void _TwoOutEpMapping(struct ieee80211_hw *hw, bool bIsChipB,
 		ep_map->ep_mapping[RTL_TXQ_HI]	= 2;
 	} else { /* typical setting */
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("USB typical Setting.....\n"));
+			 "USB typical Setting.....\n");
 		ep_map->ep_mapping[RTL_TXQ_BE]	= 3;
 		ep_map->ep_mapping[RTL_TXQ_BK]	= 3;
 		ep_map->ep_mapping[RTL_TXQ_VI]	= 2;
@@ -135,7 +135,7 @@ static void _ThreeOutEpMapping(struct ieee80211_hw *hw, bool  bwificfg,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	if (bwificfg) { /* for WMM */
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("USB 3EP Setting for WMM.....\n"));
+			 "USB 3EP Setting for WMM.....\n");
 		ep_map->ep_mapping[RTL_TXQ_BE]	= 5;
 		ep_map->ep_mapping[RTL_TXQ_BK]	= 3;
 		ep_map->ep_mapping[RTL_TXQ_VI]	= 3;
@@ -145,7 +145,7 @@ static void _ThreeOutEpMapping(struct ieee80211_hw *hw, bool  bwificfg,
 		ep_map->ep_mapping[RTL_TXQ_HI]	= 2;
 	} else { /* typical setting */
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("USB 3EP Setting for typical.....\n"));
+			 "USB 3EP Setting for typical.....\n");
 		ep_map->ep_mapping[RTL_TXQ_BE]	= 5;
 		ep_map->ep_mapping[RTL_TXQ_BK]	= 5;
 		ep_map->ep_mapping[RTL_TXQ_VI]	= 3;
@@ -270,23 +270,23 @@ static enum rtl_desc_qsel _rtl8192cu_mq_to_descq(struct ieee80211_hw *hw,
 	case 0:	/* VO */
 		qsel = QSLT_VO;
 		RT_TRACE(rtlpriv, COMP_USB, DBG_DMESG,
-			 ("VO queue, set qsel = 0x%x\n", QSLT_VO));
+			 "VO queue, set qsel = 0x%x\n", QSLT_VO);
 		break;
 	case 1:	/* VI */
 		qsel = QSLT_VI;
 		RT_TRACE(rtlpriv, COMP_USB, DBG_DMESG,
-			 ("VI queue, set qsel = 0x%x\n", QSLT_VI));
+			 "VI queue, set qsel = 0x%x\n", QSLT_VI);
 		break;
 	case 3:	/* BK */
 		qsel = QSLT_BK;
 		RT_TRACE(rtlpriv, COMP_USB, DBG_DMESG,
-			 ("BK queue, set qsel = 0x%x\n", QSLT_BK));
+			 "BK queue, set qsel = 0x%x\n", QSLT_BK);
 		break;
 	case 2:	/* BE */
 	default:
 		qsel = QSLT_BE;
 		RT_TRACE(rtlpriv, COMP_USB, DBG_DMESG,
-			 ("BE queue, set qsel = 0x%x\n", QSLT_BE));
+			 "BE queue, set qsel = 0x%x\n", QSLT_BE);
 		break;
 	}
 out:
@@ -422,17 +422,17 @@ static void _rtl_rx_process(struct ieee80211_hw *hw, struct sk_buff *skb)
 	bv = ieee80211_is_probe_resp(fc);
 	if (bv)
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("Got probe response frame.\n"));
+			 "Got probe response frame\n");
 	if (ieee80211_is_beacon(fc))
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("Got beacon frame.\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Got beacon frame\n");
 	if (ieee80211_is_data(fc))
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Got data frame.\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Got data frame\n");
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("Fram: fc = 0x%X addr1 = 0x%02X:0x%02X:0x%02X:0x%02X:0x%02X:"
-		 "0x%02X\n", fc, (u32)hdr->addr1[0], (u32)hdr->addr1[1],
-		 (u32)hdr->addr1[2], (u32)hdr->addr1[3], (u32)hdr->addr1[4],
-		 (u32)hdr->addr1[5]));
+		 "Fram: fc = 0x%X addr1 = 0x%02X:0x%02X:0x%02X:0x%02X:0x%02X:0x%02X\n",
+		 fc,
+		 (u32)hdr->addr1[0], (u32)hdr->addr1[1],
+		 (u32)hdr->addr1[2], (u32)hdr->addr1[3],
+		 (u32)hdr->addr1[4], (u32)hdr->addr1[5]);
 	memcpy(IEEE80211_SKB_RXCB(skb), rx_status, sizeof(*rx_status));
 	ieee80211_rx_irqsafe(hw, skb);
 }
@@ -594,7 +594,7 @@ void rtl92cu_tx_fill_desc(struct ieee80211_hw *hw,
 	if (ieee80211_is_data_qos(fc)) {
 		if (mac->rdg_en) {
 			RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-				 ("Enable RDG function.\n"));
+				 "Enable RDG function\n");
 			SET_TX_DESC_RDG_ENABLE(txdesc, 1);
 			SET_TX_DESC_HTC(txdesc, 1);
 		}
@@ -620,7 +620,7 @@ void rtl92cu_tx_fill_desc(struct ieee80211_hw *hw,
 		SET_TX_DESC_BMC(txdesc, 1);
 	_rtl_fill_usb_tx_desc(txdesc);
 	_rtl_tx_desc_checksum(txdesc);
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, (" %s ==>\n", __func__));
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, " %s ==>\n", __func__);
 }
 
 void rtl92cu_fill_fake_txdesc(struct ieee80211_hw *hw, u8 * pDesc,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index 3cd0736..32537c4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -246,23 +246,21 @@ static void rtl92d_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 		rtl_set_bbreg(hw, RCCK0_FALSEALARMREPORT, 0x0000c000, 2);
 		rtl92d_release_cckandrw_pagea_ctl(hw, &flag);
 	}
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("Cnt_Fast_Fsync_fail = %x, "
-		 "Cnt_SB_Search_fail = %x\n",
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "Cnt_Fast_Fsync_fail = %x, Cnt_SB_Search_fail = %x\n",
 		 falsealm_cnt->cnt_fast_fsync_fail,
-		 falsealm_cnt->cnt_sb_search_fail));
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("Cnt_Parity_Fail = %x, "
-		 "Cnt_Rate_Illegal = %x, Cnt_Crc8_fail = %x, "
-		 "Cnt_Mcs_fail = %x\n",
+		 falsealm_cnt->cnt_sb_search_fail);
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "Cnt_Parity_Fail = %x, Cnt_Rate_Illegal = %x, Cnt_Crc8_fail = %x, Cnt_Mcs_fail = %x\n",
 		 falsealm_cnt->cnt_parity_fail,
 		 falsealm_cnt->cnt_rate_illegal,
 		 falsealm_cnt->cnt_crc8_fail,
-		 falsealm_cnt->cnt_mcs_fail));
+		 falsealm_cnt->cnt_mcs_fail);
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 ("Cnt_Ofdm_fail = %x, " "Cnt_Cck_fail = %x, "
-		 "Cnt_all = %x\n",
+		 "Cnt_Ofdm_fail = %x, Cnt_Cck_fail = %x, Cnt_all = %x\n",
 		 falsealm_cnt->cnt_ofdm_fail,
 		 falsealm_cnt->cnt_cck_fail,
-		 falsealm_cnt->cnt_all));
+		 falsealm_cnt->cnt_all);
 }
 
 static void rtl92d_dm_find_minimum_rssi(struct ieee80211_hw *hw)
@@ -275,7 +273,7 @@ static void rtl92d_dm_find_minimum_rssi(struct ieee80211_hw *hw)
 	    (rtlpriv->dm.UNDEC_SM_PWDB == 0)) {
 		de_digtable.min_undecorated_pwdb_for_dm = 0;
 		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
-			 ("Not connected to any\n"));
+			 "Not connected to any\n");
 	}
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_AP ||
@@ -283,25 +281,25 @@ static void rtl92d_dm_find_minimum_rssi(struct ieee80211_hw *hw)
 			de_digtable.min_undecorated_pwdb_for_dm =
 			    rtlpriv->dm.UNDEC_SM_PWDB;
 			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
-				 ("AP Client PWDB = 0x%lx\n",
-				  rtlpriv->dm.UNDEC_SM_PWDB));
+				 "AP Client PWDB = 0x%lx\n",
+				 rtlpriv->dm.UNDEC_SM_PWDB);
 		} else {
 			de_digtable.min_undecorated_pwdb_for_dm =
 			    rtlpriv->dm.undecorated_smoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
-				 ("STA Default Port PWDB = 0x%x\n",
-				  de_digtable.min_undecorated_pwdb_for_dm));
+				 "STA Default Port PWDB = 0x%x\n",
+				 de_digtable.min_undecorated_pwdb_for_dm);
 		}
 	} else {
 		de_digtable.min_undecorated_pwdb_for_dm =
 		    rtlpriv->dm.UNDEC_SM_PWDB;
 		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
-			 ("AP Ext Port or disconnet PWDB = 0x%x\n",
-			  de_digtable.min_undecorated_pwdb_for_dm));
+			 "AP Ext Port or disconnet PWDB = 0x%x\n",
+			 de_digtable.min_undecorated_pwdb_for_dm);
 	}
 
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("MinUndecoratedPWDBForDM =%d\n",
-			de_digtable.min_undecorated_pwdb_for_dm));
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "MinUndecoratedPWDBForDM =%d\n",
+		 de_digtable.min_undecorated_pwdb_for_dm);
 }
 
 static void rtl92d_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
@@ -340,14 +338,14 @@ static void rtl92d_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 		}
 		de_digtable.pre_cck_pd_state = de_digtable.cur_cck_pd_state;
 	}
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("CurSTAConnectState=%s\n",
-		 (de_digtable.cursta_connectctate == DIG_STA_CONNECT ?
-		 "DIG_STA_CONNECT " : "DIG_STA_DISCONNECT")));
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("CCKPDStage=%s\n",
-		 (de_digtable.cur_cck_pd_state == CCK_PD_STAGE_LOWRSSI ?
-		 "Low RSSI " : "High RSSI ")));
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("is92d single phy =%x\n",
-		 IS_92D_SINGLEPHY(rtlpriv->rtlhal.version)));
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "CurSTAConnectState=%s\n",
+		 de_digtable.cursta_connectctate == DIG_STA_CONNECT ?
+		 "DIG_STA_CONNECT " : "DIG_STA_DISCONNECT");
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "CCKPDStage=%s\n",
+		 de_digtable.cur_cck_pd_state == CCK_PD_STAGE_LOWRSSI ?
+		 "Low RSSI " : "High RSSI ");
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "is92d single phy =%x\n",
+		 IS_92D_SINGLEPHY(rtlpriv->rtlhal.version));
 
 }
 
@@ -355,12 +353,12 @@ void rtl92d_dm_write_dig(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("cur_igvalue = 0x%x, "
-		 "pre_igvalue = 0x%x, backoff_val = %d\n",
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
+		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, backoff_val = %d\n",
 		 de_digtable.cur_igvalue, de_digtable.pre_igvalue,
-		 de_digtable.backoff_val));
+		 de_digtable.backoff_val);
 	if (de_digtable.dig_enable_flag == false) {
-		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("DIG is disabled\n"));
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "DIG is disabled\n");
 		de_digtable.pre_igvalue = 0x17;
 		return;
 	}
@@ -377,22 +375,21 @@ static void rtl92d_early_mode_enabled(struct rtl_priv *rtlpriv)
 {
 	if ((rtlpriv->mac80211.link_state >= MAC80211_LINKED) &&
 	    (rtlpriv->mac80211.vendor == PEER_CISCO)) {
-		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-			 ("IOT_PEER = CISCO\n"));
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "IOT_PEER = CISCO\n");
 		if (de_digtable.last_min_undecorated_pwdb_for_dm >= 50
 		    && de_digtable.min_undecorated_pwdb_for_dm < 50) {
 			rtl_write_byte(rtlpriv, REG_EARLY_MODE_CONTROL, 0x00);
 			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-				 ("Early Mode Off\n"));
+				 "Early Mode Off\n");
 		} else if (de_digtable.last_min_undecorated_pwdb_for_dm <= 55 &&
 			   de_digtable.min_undecorated_pwdb_for_dm > 55) {
 			rtl_write_byte(rtlpriv, REG_EARLY_MODE_CONTROL, 0x0f);
 			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-				 ("Early Mode On\n"));
+				 "Early Mode On\n");
 		}
 	} else if (!(rtl_read_byte(rtlpriv, REG_EARLY_MODE_CONTROL) & 0xf)) {
 		rtl_write_byte(rtlpriv, REG_EARLY_MODE_CONTROL, 0x0f);
-		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("Early Mode On\n"));
+		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "Early Mode On\n");
 	}
 }
 
@@ -402,7 +399,7 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 	u8 value_igi = de_digtable.cur_igvalue;
 	struct false_alarm_statistics *falsealm_cnt = &(rtlpriv->falsealm_cnt);
 
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("==>\n"));
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "==>\n");
 	if (rtlpriv->rtlhal.earlymode_enable) {
 		rtl92d_early_mode_enabled(rtlpriv);
 		de_digtable.last_min_undecorated_pwdb_for_dm =
@@ -421,7 +418,7 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 	/* Not STA mode return tmp */
 	if (rtlpriv->mac80211.opmode != NL80211_IFTYPE_STATION)
 		return;
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("progress\n"));
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "progress\n");
 	/* Decide the current status and if modify initial gain or not */
 	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
 		de_digtable.cursta_connectctate = DIG_STA_CONNECT;
@@ -438,16 +435,16 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 	else if (falsealm_cnt->cnt_all >= DM_DIG_FA_TH2)
 		value_igi += 2;
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 ("dm_DIG() Before: large_fa_hit=%d, forbidden_igi=%x\n",
-		 de_digtable.large_fa_hit, de_digtable.forbidden_igi));
+		 "dm_DIG() Before: large_fa_hit=%d, forbidden_igi=%x\n",
+		 de_digtable.large_fa_hit, de_digtable.forbidden_igi);
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 ("dm_DIG() Before: Recover_cnt=%d, rx_gain_range_min=%x\n",
-		 de_digtable.recover_cnt, de_digtable.rx_gain_range_min));
+		 "dm_DIG() Before: Recover_cnt=%d, rx_gain_range_min=%x\n",
+		 de_digtable.recover_cnt, de_digtable.rx_gain_range_min);
 
 	/* deal with abnorally large false alarm */
 	if (falsealm_cnt->cnt_all > 10000) {
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-			 ("dm_DIG(): Abnornally false alarm case.\n"));
+			 "dm_DIG(): Abnormally false alarm case\n");
 
 		de_digtable.large_fa_hit++;
 		if (de_digtable.forbidden_igi < de_digtable.cur_igvalue) {
@@ -486,11 +483,11 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 		}
 	}
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 ("dm_DIG() After: large_fa_hit=%d, forbidden_igi=%x\n",
-		  de_digtable.large_fa_hit, de_digtable.forbidden_igi));
+		 "dm_DIG() After: large_fa_hit=%d, forbidden_igi=%x\n",
+		 de_digtable.large_fa_hit, de_digtable.forbidden_igi);
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 ("dm_DIG() After: recover_cnt=%d, rx_gain_range_min=%x\n",
-		  de_digtable.recover_cnt, de_digtable.rx_gain_range_min));
+		 "dm_DIG() After: recover_cnt=%d, rx_gain_range_min=%x\n",
+		 de_digtable.recover_cnt, de_digtable.rx_gain_range_min);
 
 	if (value_igi > DM_DIG_MAX)
 		value_igi = DM_DIG_MAX;
@@ -500,7 +497,7 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 	rtl92d_dm_write_dig(hw);
 	if (rtlpriv->rtlhal.current_bandtype != BAND_ON_5G)
 		rtl92d_dm_cck_packet_detection_thresh(hw);
-	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, ("<<==\n"));
+	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "<<==\n");
 }
 
 static void rtl92d_dm_init_dynamic_txpower(struct ieee80211_hw *hw)
@@ -528,7 +525,7 @@ static void rtl92d_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.UNDEC_SM_PWDB == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("Not connected to any\n"));
+			 "Not connected to any\n");
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		rtlpriv->dm.last_dtp_lvl = TXHIGHPWRLEVEL_NORMAL;
 		return;
@@ -538,40 +535,40 @@ static void rtl92d_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.UNDEC_SM_PWDB;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("IBSS Client PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "IBSS Client PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		} else {
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.undecorated_smoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("STA Default Port PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "STA Default Port PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		}
 	} else {
 		undecorated_smoothed_pwdb =
 		    rtlpriv->dm.UNDEC_SM_PWDB;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("AP Ext Port PWDB = 0x%lx\n",
-			  undecorated_smoothed_pwdb));
+			 "AP Ext Port PWDB = 0x%lx\n",
+			 undecorated_smoothed_pwdb);
 	}
 	if (rtlhal->current_bandtype == BAND_ON_5G) {
 		if (undecorated_smoothed_pwdb >= 0x33) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL2;
 			RT_TRACE(rtlpriv, COMP_HIPWR, DBG_LOUD,
-				 ("5G:TxHighPwrLevel_Level2 (TxPwr=0x0)\n"));
+				 "5G:TxHighPwrLevel_Level2 (TxPwr=0x0)\n");
 		} else if ((undecorated_smoothed_pwdb < 0x33)
 			   && (undecorated_smoothed_pwdb >= 0x2b)) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL1;
 			RT_TRACE(rtlpriv, COMP_HIPWR, DBG_LOUD,
-				 ("5G:TxHighPwrLevel_Level1 (TxPwr=0x10)\n"));
+				 "5G:TxHighPwrLevel_Level1 (TxPwr=0x10)\n");
 		} else if (undecorated_smoothed_pwdb < 0x2b) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_NORMAL;
 			RT_TRACE(rtlpriv, COMP_HIPWR, DBG_LOUD,
-				 ("5G:TxHighPwrLevel_Normal\n"));
+				 "5G:TxHighPwrLevel_Normal\n");
 		}
 	} else {
 		if (undecorated_smoothed_pwdb >=
@@ -579,7 +576,7 @@ static void rtl92d_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL2;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n"));
+				 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
 		} else
 		    if ((undecorated_smoothed_pwdb <
 			 (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3))
@@ -589,19 +586,19 @@ static void rtl92d_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL1;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n"));
+				 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
 		} else if (undecorated_smoothed_pwdb <
 			   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_NORMAL;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("TXHIGHPWRLEVEL_NORMAL\n"));
+				 "TXHIGHPWRLEVEL_NORMAL\n");
 		}
 	}
 	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("PHY_SetTxPowerLevel8192S() Channel = %d\n",
-			  rtlphy->current_channel));
+			 "PHY_SetTxPowerLevel8192S() Channel = %d\n",
+			 rtlphy->current_channel);
 		rtl92d_phy_set_txpower_level(hw, rtlphy->current_channel);
 	}
 	rtlpriv->dm.last_dtp_lvl = rtlpriv->dm.dynamic_txhighpower_lvl;
@@ -717,7 +714,7 @@ static void rtl92d_dm_rxgain_tracking_thermalmeter(struct ieee80211_hw *hw)
 	u4tmp = (index_mapping[(rtlpriv->efuse.eeprom_thermalmeter -
 				rtlpriv->dm.thermalvalue_rxgain)]) << 12;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 ("===> Rx Gain %x\n", u4tmp));
+		 "===> Rx Gain %x\n", u4tmp);
 	for (i = RF90_PATH_A; i < rtlpriv->phy.num_total_rfpath; i++)
 		rtl_set_rfreg(hw, i, 0x3C, BRFREGOFFSETMASK,
 			      (rtlpriv->phy.reg_rf3c[i] & (~(0xF000))) | u4tmp);
@@ -741,27 +738,22 @@ static void rtl92d_bandtype_2_4G(struct ieee80211_hw *hw, long *temp_cckg,
 			if (!memcmp((void *)&temp_cck,
 			    (void *)&cckswing_table_ch14[i][2], 4)) {
 				*cck_index_old = (u8) i;
-				RT_TRACE(rtlpriv,
-					 COMP_POWER_TRACKING,
-					 DBG_LOUD,
-					 ("Initial reg0x%x = 0x%lx, "
-					  "cck_index=0x%x, ch 14 %d\n",
-					  RCCK0_TXFILTER2,
-					  temp_cck, *cck_index_old,
-					  rtlpriv->dm.cck_inch14));
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "Initial reg0x%x = 0x%lx, cck_index=0x%x, ch 14 %d\n",
+					 RCCK0_TXFILTER2, temp_cck,
+					 *cck_index_old,
+					 rtlpriv->dm.cck_inch14);
 				break;
 			}
 		} else {
 			if (!memcmp((void *) &temp_cck,
 			    &cckswing_table_ch1ch13[i][2], 4)) {
 				*cck_index_old = (u8) i;
-				RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
-					 DBG_LOUD,
-					 ("Initial reg0x%x = 0x%lx, "
-					 "cck_index = 0x%x, ch14 %d\n",
-					 RCCK0_TXFILTER2,
-					 temp_cck, *cck_index_old,
-					 rtlpriv->dm.cck_inch14));
+				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
+					 "Initial reg0x%x = 0x%lx, cck_index = 0x%x, ch14 %d\n",
+					 RCCK0_TXFILTER2, temp_cck,
+					 *cck_index_old,
+					 rtlpriv->dm.cck_inch14);
 				break;
 			}
 		}
@@ -884,12 +876,12 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 	};
 
 	rtlpriv->dm.txpower_trackinginit = true;
-	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, ("\n"));
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "\n");
 	thermalvalue = (u8) rtl_get_rfreg(hw, RF90_PATH_A, RF_T_METER, 0xf800);
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 ("Readback Thermal Meter = 0x%x pre thermal meter 0x%x "
-		 "eeprom_thermalmeter 0x%x\n", thermalvalue,
-		 rtlpriv->dm.thermalvalue, rtlefuse->eeprom_thermalmeter));
+		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermalmeter 0x%x\n",
+		 thermalvalue,
+		 rtlpriv->dm.thermalvalue, rtlefuse->eeprom_thermalmeter);
 	rtl92d_phy_ap_calibrate(hw, (thermalvalue -
 				     rtlefuse->eeprom_thermalmeter));
 	if (is2t)
@@ -904,10 +896,9 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 				ofdm_index_old[0] = (u8) i;
 
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("Initial pathA ele_d reg0x%x = 0x%lx,"
-					 " ofdm_index=0x%x\n",
+					 "Initial pathA ele_d reg0x%x = 0x%lx, ofdm_index=0x%x\n",
 					 ROFDM0_XATxIQIMBALANCE,
-					 ele_d, ofdm_index_old[0]));
+					 ele_d, ofdm_index_old[0]);
 				break;
 			}
 		}
@@ -920,11 +911,9 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 					ofdm_index_old[1] = (u8) i;
 					RT_TRACE(rtlpriv, COMP_POWER_TRACKING,
 						 DBG_LOUD,
-						 ("Initial pathB ele_d reg "
-						 "0x%x = 0x%lx, ofdm_index "
-						 "= 0x%x\n",
+						 "Initial pathB ele_d reg 0x%x = 0x%lx, ofdm_index = 0x%x\n",
 						 ROFDM0_XBTxIQIMBALANCE, ele_d,
-						 ofdm_index_old[1]));
+						 ofdm_index_old[1]);
 					break;
 				}
 			}
@@ -952,7 +941,7 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 				rtlpriv->dm.ofdm_index[i] = ofdm_index_old[i];
 			rtlpriv->dm.cck_index = cck_index_old;
 			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-				 ("reload ofdm index for band switch\n"));
+				 "reload ofdm index for band switch\n");
 		}
 		rtlpriv->dm.thermalvalue_avg
 			    [rtlpriv->dm.thermalvalue_avg_index] = thermalvalue;
@@ -995,12 +984,10 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 			(thermalvalue - rtlpriv->dm.thermalvalue_rxgain) :
 			(rtlpriv->dm.thermalvalue_rxgain - thermalvalue);
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 ("Readback Thermal Meter = 0x%x pre thermal meter 0x%x"
-			  " eeprom_thermalmeter 0x%x delta 0x%x "
-			  "delta_lck 0x%x delta_iqk 0x%x\n",
-			  thermalvalue, rtlpriv->dm.thermalvalue,
-			  rtlefuse->eeprom_thermalmeter, delta, delta_lck,
-			  delta_iqk));
+			 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermalmeter 0x%x delta 0x%x delta_lck 0x%x delta_iqk 0x%x\n",
+			 thermalvalue, rtlpriv->dm.thermalvalue,
+			 rtlefuse->eeprom_thermalmeter, delta, delta_lck,
+			 delta_iqk);
 		if ((delta_lck > rtlefuse->delta_lck) &&
 		    (rtlefuse->delta_lck != 0)) {
 			rtlpriv->dm.thermalvalue_lck = thermalvalue;
@@ -1036,17 +1023,15 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 			}
 			if (is2t) {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("temp OFDM_A_index=0x%x, OFDM_B_index"
-					 " = 0x%x,cck_index=0x%x\n",
-					  rtlpriv->dm.ofdm_index[0],
-					  rtlpriv->dm.ofdm_index[1],
-					  rtlpriv->dm.cck_index));
+					 "temp OFDM_A_index=0x%x, OFDM_B_index = 0x%x,cck_index=0x%x\n",
+					 rtlpriv->dm.ofdm_index[0],
+					 rtlpriv->dm.ofdm_index[1],
+					 rtlpriv->dm.cck_index);
 			} else {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("temp OFDM_A_index=0x%x,cck_index = "
-					 "0x%x\n",
-					  rtlpriv->dm.ofdm_index[0],
-							rtlpriv->dm.cck_index));
+					 "temp OFDM_A_index=0x%x,cck_index = 0x%x\n",
+					 rtlpriv->dm.ofdm_index[0],
+					 rtlpriv->dm.cck_index);
 			}
 			for (i = 0; i < rf; i++) {
 				if (ofdm_index[i] > OFDM_TABLE_SIZE_92D - 1)
@@ -1070,15 +1055,13 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 			}
 			if (is2t) {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("new OFDM_A_index=0x%x, OFDM_B_index "
-					 "= 0x%x, cck_index=0x%x\n",
+					 "new OFDM_A_index=0x%x, OFDM_B_index = 0x%x, cck_index=0x%x\n",
 					 ofdm_index[0], ofdm_index[1],
-					 cck_index));
+					 cck_index);
 			} else {
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("new OFDM_A_index=0x%x,cck_index = "
-					 "0x%x\n",
-					  ofdm_index[0], cck_index));
+					 "new OFDM_A_index=0x%x,cck_index = 0x%x\n",
+					 ofdm_index[0], cck_index);
 			}
 			ele_d = (ofdmswing_table[(u8) ofdm_index[0]] &
 						 0xFFC00000) >> 22;
@@ -1124,12 +1107,10 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 			}
 
 			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-				 ("TxPwrTracking for interface %d path A: X ="
-				 " 0x%lx, Y = 0x%lx ele_A = 0x%lx ele_C = "
-				 "0x%lx ele_D = 0x%lx 0xe94 = 0x%lx 0xe9c = "
-				 "0x%lx\n", rtlhal->interfaceindex,
+				 "TxPwrTracking for interface %d path A: X = 0x%lx, Y = 0x%lx ele_A = 0x%lx ele_C = 0x%lx ele_D = 0x%lx 0xe94 = 0x%lx 0xe9c = 0x%lx\n",
+				 rtlhal->interfaceindex,
 				 val_x, val_y, ele_a, ele_c, ele_d,
-				 val_x, val_y));
+				 val_x, val_y);
 
 			if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 				/* Adjust CCK according to IQK result */
@@ -1232,20 +1213,16 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 						      BIT(28), 0x00);
 				}
 				RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-					 ("TxPwrTracking path B: X = 0x%lx, "
-					 "Y = 0x%lx ele_A = 0x%lx ele_C = 0x"
-					 "%lx ele_D = 0x%lx 0xeb4 = 0x%lx "
-					 "0xebc = 0x%lx\n",
-					  val_x, val_y, ele_a, ele_c,
-					  ele_d, val_x, val_y));
+					 "TxPwrTracking path B: X = 0x%lx, Y = 0x%lx ele_A = 0x%lx ele_C = 0x%lx ele_D = 0x%lx 0xeb4 = 0x%lx 0xebc = 0x%lx\n",
+					 val_x, val_y, ele_a, ele_c,
+					 ele_d, val_x, val_y);
 			}
 			RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-				 ("TxPwrTracking 0xc80 = 0x%x, 0xc94 = "
-				 "0x%x RF 0x24 = 0x%x\n",
+				 "TxPwrTracking 0xc80 = 0x%x, 0xc94 = 0x%x RF 0x24 = 0x%x\n",
 				 rtl_get_bbreg(hw, 0xc80, BMASKDWORD),
 				 rtl_get_bbreg(hw, 0xc94, BMASKDWORD),
 				 rtl_get_rfreg(hw, RF90_PATH_A, 0x24,
-				 BRFREGOFFSETMASK)));
+					       BRFREGOFFSETMASK));
 		}
 		if ((delta_iqk > rtlefuse->delta_iqk) &&
 		    (rtlefuse->delta_iqk != 0)) {
@@ -1262,7 +1239,7 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 			rtlpriv->dm.thermalvalue = thermalvalue;
 	}
 
-	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, ("<===\n"));
+	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD, "<===\n");
 }
 
 static void rtl92d_dm_initialize_txpower_tracking(struct ieee80211_hw *hw)
@@ -1273,8 +1250,8 @@ static void rtl92d_dm_initialize_txpower_tracking(struct ieee80211_hw *hw)
 	rtlpriv->dm.txpower_trackinginit = false;
 	rtlpriv->dm.txpower_track_control = true;
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 ("pMgntInfo->txpower_tracking = %d\n",
-		 rtlpriv->dm.txpower_tracking));
+		 "pMgntInfo->txpower_tracking = %d\n",
+		 rtlpriv->dm.txpower_tracking);
 }
 
 void rtl92d_dm_check_txpower_tracking_thermal_meter(struct ieee80211_hw *hw)
@@ -1289,12 +1266,12 @@ void rtl92d_dm_check_txpower_tracking_thermal_meter(struct ieee80211_hw *hw)
 		rtl_set_rfreg(hw, RF90_PATH_A, RF_T_METER, BIT(17) |
 			      BIT(16), 0x03);
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 ("Trigger 92S Thermal Meter!!\n"));
+			 "Trigger 92S Thermal Meter!!\n");
 		tm_trigger = 1;
 		return;
 	} else {
 		RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-			 ("Schedule TxPowerTracking direct call!!\n"));
+			 "Schedule TxPowerTracking direct call!!\n");
 		rtl92d_dm_txpower_tracking_callback_thermalmeter(hw);
 		tm_trigger = 0;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
index db6972f..b84f10d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
@@ -124,14 +124,14 @@ static void _rtl92d_write_fw(struct ieee80211_hw *hw,
 	u32 pagenums, remainSize;
 	u32 page, offset;
 
-	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, ("FW size is %d bytes,\n", size));
+	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "FW size is %d bytes,\n", size);
 	if (rtlhal->hw_type == HARDWARE_TYPE_RTL8192DE)
 		_rtl92d_fill_dummy(bufferPtr, &size);
 	pagenums = size / FW_8192D_PAGE_SIZE;
 	remainSize = size % FW_8192D_PAGE_SIZE;
 	if (pagenums > 8) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Page numbers should not greater then 8\n"));
+			 "Page numbers should not greater then 8\n");
 	}
 	for (page = 0; page < pagenums; page++) {
 		offset = page * FW_8192D_PAGE_SIZE;
@@ -158,12 +158,12 @@ static int _rtl92d_fw_free_to_go(struct ieee80211_hw *hw)
 		 (!(value32 & FWDL_ChkSum_rpt)));
 	if (counter >= FW_8192D_POLLING_TIMEOUT_COUNT) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("chksum report faill ! REG_MCUFWDL:0x%08x .\n",
-			 value32));
+			 "chksum report faill ! REG_MCUFWDL:0x%08x\n",
+			 value32);
 		return -EIO;
 	}
 	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-		 ("Checksum report OK ! REG_MCUFWDL:0x%08x .\n", value32));
+		 "Checksum report OK ! REG_MCUFWDL:0x%08x\n", value32);
 	value32 = rtl_read_dword(rtlpriv, REG_MCUFWDL);
 	value32 |= MCUFWDL_RDY;
 	rtl_write_dword(rtlpriv, REG_MCUFWDL, value32);
@@ -188,7 +188,7 @@ void rtl92d_firmware_selfreset(struct ieee80211_hw *hw)
 	}
 	RT_ASSERT((delay > 0), ("8051 reset failed!\n"));
 	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-		 ("=====> 8051 reset success (%d) .\n", delay));
+		 "=====> 8051 reset success (%d)\n", delay);
 }
 
 static int _rtl92d_fw_init(struct ieee80211_hw *hw)
@@ -197,7 +197,7 @@ static int _rtl92d_fw_init(struct ieee80211_hw *hw)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u32 counter;
 
-	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG, ("FW already have download\n"));
+	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG, "FW already have download\n");
 	/* polling for FW ready */
 	counter = 0;
 	do {
@@ -205,10 +205,9 @@ static int _rtl92d_fw_init(struct ieee80211_hw *hw)
 			if (rtl_read_byte(rtlpriv, FW_MAC0_READY) &
 			    MAC0_READY) {
 				RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-					 ("Polling FW ready success!! "
-					 "REG_MCUFWDL: 0x%x .\n",
+					 "Polling FW ready success!! REG_MCUFWDL: 0x%x\n",
 					 rtl_read_byte(rtlpriv,
-					 FW_MAC0_READY)));
+						       FW_MAC0_READY));
 				return 0;
 			}
 			udelay(5);
@@ -216,10 +215,9 @@ static int _rtl92d_fw_init(struct ieee80211_hw *hw)
 			if (rtl_read_byte(rtlpriv, FW_MAC1_READY) &
 			    MAC1_READY) {
 				RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-					 ("Polling FW ready success!! "
-					 "REG_MCUFWDL: 0x%x .\n",
+					 "Polling FW ready success!! REG_MCUFWDL: 0x%x\n",
 					 rtl_read_byte(rtlpriv,
-						       FW_MAC1_READY)));
+						       FW_MAC1_READY));
 				return 0;
 			}
 			udelay(5);
@@ -228,18 +226,16 @@ static int _rtl92d_fw_init(struct ieee80211_hw *hw)
 
 	if (rtlhal->interfaceindex == 0) {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-			 ("Polling FW ready fail!! MAC0 FW init not ready: "
-			 "0x%x .\n",
-			 rtl_read_byte(rtlpriv, FW_MAC0_READY)));
+			 "Polling FW ready fail!! MAC0 FW init not ready: 0x%x\n",
+			 rtl_read_byte(rtlpriv, FW_MAC0_READY));
 	} else {
 		RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-			 ("Polling FW ready fail!! MAC1 FW init not ready: "
-			 "0x%x .\n",
-			 rtl_read_byte(rtlpriv, FW_MAC1_READY)));
+			 "Polling FW ready fail!! MAC1 FW init not ready: 0x%x\n",
+			 rtl_read_byte(rtlpriv, FW_MAC1_READY));
 	}
 	RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-		 ("Polling FW ready fail!! REG_MCUFWDL:0x%08ul .\n",
-		 rtl_read_dword(rtlpriv, REG_MCUFWDL)));
+		 "Polling FW ready fail!! REG_MCUFWDL:0x%08ul\n",
+		 rtl_read_dword(rtlpriv, REG_MCUFWDL));
 	return -1;
 }
 
@@ -264,13 +260,13 @@ int rtl92d_download_fw(struct ieee80211_hw *hw)
 	pfwdata = (u8 *) rtlhal->pfirmware;
 	rtlhal->fw_version = (u16) GET_FIRMWARE_HDR_VERSION(pfwheader);
 	rtlhal->fw_subversion = (u16) GET_FIRMWARE_HDR_SUB_VER(pfwheader);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, (" FirmwareVersion(%d),"
-		 "FirmwareSubVersion(%d), Signature(%#x)\n",
-		 rtlhal->fw_version,	rtlhal->fw_subversion,
-		 GET_FIRMWARE_HDR_SIGNATURE(pfwheader)));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "FirmwareVersion(%d), FirmwareSubVersion(%d), Signature(%#x)\n",
+		 rtlhal->fw_version, rtlhal->fw_subversion,
+		 GET_FIRMWARE_HDR_SIGNATURE(pfwheader));
 	if (IS_FW_HEADER_EXIST(pfwheader)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("Shift 32 bytes for FW header!!\n"));
+			 "Shift 32 bytes for FW header!!\n");
 		pfwdata = pfwdata + 32;
 		fwsize = fwsize - 32;
 	}
@@ -302,8 +298,7 @@ int rtl92d_download_fw(struct ieee80211_hw *hw)
 				break;
 			else
 				RT_TRACE(rtlpriv, COMP_FW, DBG_DMESG,
-					 ("Wait for another mac "
-					 "download fw\n"));
+					 "Wait for another mac download fw\n");
 		}
 		spin_lock_irqsave(&globalmutex_for_fwdownload, flags);
 		value = rtl_read_byte(rtlpriv, 0x1f);
@@ -337,11 +332,10 @@ int rtl92d_download_fw(struct ieee80211_hw *hw)
 	spin_unlock_irqrestore(&globalmutex_for_fwdownload, flags);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("fw is not ready to run!\n"));
+			 "fw is not ready to run!\n");
 		goto exit;
 	} else {
-		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE,
-			 ("fw is ready to run!\n"));
+		RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "fw is ready to run!\n");
 	}
 exit:
 	err = _rtl92d_fw_init(hw);
@@ -381,24 +375,24 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 
 	if (ppsc->rfpwr_state == ERFOFF || ppsc->inactive_pwrstate == ERFOFF) {
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-			 ("Return as RF is off!!!\n"));
+			 "Return as RF is off!!!\n");
 		return;
 	}
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("come in\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "come in\n");
 	while (true) {
 		spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 		if (rtlhal->h2c_setinprogress) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("H2C set in progress! Wait to set.."
-				 "element_id(%d).\n", element_id));
+				 "H2C set in progress! Wait to set..element_id(%d)\n",
+				 element_id);
 
 			while (rtlhal->h2c_setinprogress) {
 				spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock,
 						       flag);
 				h2c_waitcounter++;
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					 ("Wait 100 us (%d times)...\n",
-					 h2c_waitcounter));
+					 "Wait 100 us (%d times)...\n",
+					 h2c_waitcounter);
 				udelay(100);
 
 				if (h2c_waitcounter > 1000)
@@ -418,8 +412,7 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 		wait_writeh2c_limmit--;
 		if (wait_writeh2c_limmit == 0) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Write H2C fail because no trigger "
-				 "for FW INT!\n"));
+				 "Write H2C fail because no trigger for FW INT!\n");
 			break;
 		}
 		boxnum = rtlhal->last_hmeboxnum;
@@ -442,7 +435,7 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 		isfw_read = _rtl92d_check_fw_read_last_h2c(hw, boxnum);
@@ -450,29 +443,29 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 			wait_h2c_limmit--;
 			if (wait_h2c_limmit == 0) {
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					 ("Wating too long for FW read "
-					 "clear HMEBox(%d)!\n", boxnum));
+					 "Waiting too long for FW read clear HMEBox(%d)!\n",
+					 boxnum);
 				break;
 			}
 			udelay(10);
 			isfw_read = _rtl92d_check_fw_read_last_h2c(hw, boxnum);
 			u1b_tmp = rtl_read_byte(rtlpriv, 0x1BF);
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("Wating for FW read clear HMEBox(%d)!!! "
-				 "0x1BF = %2x\n", boxnum, u1b_tmp));
+				 "Waiting for FW read clear HMEBox(%d)!!! 0x1BF = %2x\n",
+				 boxnum, u1b_tmp);
 		}
 		if (!isfw_read) {
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("Write H2C register BOX[%d] fail!!!!! "
-				 "Fw do not read.\n", boxnum));
+				 "Write H2C register BOX[%d] fail!!!!! Fw do not read.\n",
+				 boxnum);
 			break;
 		}
 		memset(boxcontent, 0, sizeof(boxcontent));
 		memset(boxextcontent, 0, sizeof(boxextcontent));
 		boxcontent[0] = element_id;
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-			 ("Write element_id box_reg(%4x) = %2x\n",
-			 box_reg, element_id));
+			 "Write element_id box_reg(%4x) = %2x\n",
+			 box_reg, element_id);
 		switch (cmd_len) {
 		case 1:
 			boxcontent[0] &= ~(BIT(7));
@@ -519,7 +512,7 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 		bwrite_sucess = true;
@@ -527,13 +520,13 @@ static void _rtl92d_fill_h2c_command(struct ieee80211_hw *hw,
 		if (rtlhal->last_hmeboxnum == 4)
 			rtlhal->last_hmeboxnum = 0;
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-			 ("pHalData->last_hmeboxnum  = %d\n",
-			  rtlhal->last_hmeboxnum));
+			 "pHalData->last_hmeboxnum  = %d\n",
+			 rtlhal->last_hmeboxnum);
 	}
 	spin_lock_irqsave(&rtlpriv->locks.h2c_lock, flag);
 	rtlhal->h2c_setinprogress = false;
 	spin_unlock_irqrestore(&rtlpriv->locks.h2c_lock, flag);
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("go out\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "go out\n");
 }
 
 void rtl92d_fill_h2c_cmd(struct ieee80211_hw *hw,
@@ -559,7 +552,7 @@ void rtl92d_set_fw_pwrmode_cmd(struct ieee80211_hw *hw, u8 mode)
 	u8 u1_h2c_set_pwrmode[3] = { 0 };
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 
-	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, ("FW LPS mode = %d\n", mode));
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "FW LPS mode = %d\n", mode);
 	SET_H2CCMD_PWRMODE_PARM_MODE(u1_h2c_set_pwrmode, mode);
 	SET_H2CCMD_PWRMODE_PARM_SMART_PS(u1_h2c_set_pwrmode, 1);
 	SET_H2CCMD_PWRMODE_PARM_BCN_PASS_TIME(u1_h2c_set_pwrmode,
@@ -771,14 +764,14 @@ void rtl92d_set_fw_rsvdpagepkt(struct ieee80211_hw *hw, bool dl_finished)
 		dlok = true;
 	if (dlok) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			("Set RSVD page location to Fw.\n"));
+			 "Set RSVD page location to Fw\n");
 		RT_PRINT_DATA(rtlpriv, COMP_CMD, DBG_DMESG,
 			      "H2C_RSVDPAGE", u1RsvdPageLoc, 3);
 		rtl92d_fill_h2c_cmd(hw, H2C_RSVDPAGE,
 			sizeof(u1RsvdPageLoc), u1RsvdPageLoc);
 	} else
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			("Set RSVD page location to Fw FAIL!!!!!!.\n"));
+			 "Set RSVD page location to Fw FAIL!!!!!!\n");
 }
 
 void rtl92d_set_fw_joinbss_report_cmd(struct ieee80211_hw *hw, u8 mstatus)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 5c8a639..5eecf40 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -166,7 +166,7 @@ void rtl92de_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 }
@@ -230,7 +230,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		u8 e_aci;
 
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-			 ("HW_VAR_SLOT_TIME %x\n", val[0]));
+			 "HW_VAR_SLOT_TIME %x\n", val[0]);
 		rtl_write_byte(rtlpriv, REG_SLOT, val[0]);
 		for (e_aci = 0; e_aci < AC_MAX; e_aci++)
 			rtlpriv->cfg->ops->set_hw_reg(hw,
@@ -261,8 +261,8 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					      min_spacing_to_set);
 			*val = min_spacing_to_set;
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
-				 mac->min_space_cfg));
+				 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
+				 mac->min_space_cfg);
 			rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 				       mac->min_space_cfg);
 		}
@@ -275,8 +275,8 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		mac->min_space_cfg = rtlpriv->rtlhal.minspace_cfg;
 		mac->min_space_cfg |= (density_to_set << 3);
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-			 ("Set HW_VAR_SHORTGI_DENSITY: %#x\n",
-			 mac->min_space_cfg));
+			 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
+			 mac->min_space_cfg);
 		rtl_write_byte(rtlpriv, REG_AMPDU_MIN_SPACE,
 			       mac->min_space_cfg);
 		break;
@@ -310,8 +310,8 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			}
 			rtl_write_dword(rtlpriv, REG_AGGLEN_LMT, regtoSet);
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("Set HW_VAR_AMPDU_FACTOR: %#x\n",
-				 factor_toset));
+				 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
+				 factor_toset);
 		}
 		break;
 	}
@@ -344,8 +344,8 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("HW_VAR_ACM_CTRL acm set "
-					 "failed: eACI is %d\n", acm));
+					 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
+					 acm);
 				break;
 			}
 		} else {
@@ -361,13 +361,13 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				break;
 			default:
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-					 ("switch case not process\n"));
+					 "switch case not processed\n");
 				break;
 			}
 		}
 		RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
-			 ("SetHwReg8190pci(): [HW_VAR_ACM_CTRL] "
-			 "Write 0x%X\n", acm_ctrl));
+			 "SetHwReg8190pci(): [HW_VAR_ACM_CTRL] Write 0x%X\n",
+			 acm_ctrl);
 		rtl_write_byte(rtlpriv, REG_ACMHWCTRL, acm_ctrl);
 		break;
 	}
@@ -502,7 +502,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 }
@@ -522,8 +522,8 @@ static bool _rtl92de_llt_write(struct ieee80211_hw *hw, u32 address, u32 data)
 			break;
 		if (count > POLLING_LLT_THRESHOLD) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Failed to polling write LLT done at "
-				  "address %d!\n", address));
+				 "Failed to polling write LLT done at address %d!\n",
+				 address);
 			status = false;
 			break;
 		}
@@ -879,12 +879,12 @@ void rtl92de_enable_hw_security_config(struct ieee80211_hw *hw)
 	u8 sec_reg_value;
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
-		  rtlpriv->sec.pairwise_enc_algorithm,
-		  rtlpriv->sec.group_enc_algorithm));
+		 "PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
+		 rtlpriv->sec.pairwise_enc_algorithm,
+		 rtlpriv->sec.group_enc_algorithm);
 	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-			 ("not open hw encryption\n"));
+			 "not open hw encryption\n");
 		return;
 	}
 	sec_reg_value = SCR_TXENCENABLE | SCR_RXENCENABLE;
@@ -895,7 +895,7 @@ void rtl92de_enable_hw_security_config(struct ieee80211_hw *hw)
 	sec_reg_value |= (SCR_RXBCUSEDK | SCR_TXBCUSEDK);
 	rtl_write_byte(rtlpriv, REG_CR + 1, 0x02);
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-		 ("The SECR-value %x\n", sec_reg_value));
+		 "The SECR-value %x\n", sec_reg_value);
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
 }
 
@@ -921,7 +921,7 @@ int rtl92de_hw_init(struct ieee80211_hw *hw)
 	/* rtlpriv->intf_ops->disable_aspm(hw); */
 	rtstatus = _rtl92de_init_mac(hw);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Init MAC failed\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Init MAC failed\n");
 		err = 1;
 		spin_unlock_irqrestore(&globalmutex_for_power_and_efuse, flags);
 		return err;
@@ -930,8 +930,7 @@ int rtl92de_hw_init(struct ieee80211_hw *hw)
 	spin_unlock_irqrestore(&globalmutex_for_power_and_efuse, flags);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Failed to download FW. Init HW "
-			 "without FW..\n"));
+			 "Failed to download FW. Init HW without FW..\n");
 		rtlhal->fw_ready = false;
 		return 1;
 	} else {
@@ -946,7 +945,7 @@ int rtl92de_hw_init(struct ieee80211_hw *hw)
 
 	if (rtlhal->earlymode_enable) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("EarlyMode Enabled!!!\n"));
+			 "EarlyMode Enabled!!!\n");
 
 		tmp_u1b = rtl_read_byte(rtlpriv, 0x4d0);
 		tmp_u1b = tmp_u1b | 0x1f;
@@ -1064,10 +1063,10 @@ static enum version_8192d _rtl92de_read_chip_version(struct ieee80211_hw *hw)
 	value32 = rtl_read_dword(rtlpriv, REG_SYS_CFG);
 	if (!(value32 & 0x000f0000)) {
 		version = VERSION_TEST_CHIP_92D_SINGLEPHY;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("TEST CHIP!!!\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "TEST CHIP!!!\n");
 	} else {
 		version = VERSION_NORMAL_CHIP_92D_SINGLEPHY;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Normal CHIP!!!\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Normal CHIP!!!\n");
 	}
 	return version;
 }
@@ -1092,8 +1091,8 @@ static int _rtl92de_set_media_status(struct ieee80211_hw *hw,
 		_rtl92de_disable_bcn_sub_func(hw);
 	} else {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Set HW_VAR_MEDIA_STATUS: No such media "
-			 "status(%x).\n", type));
+			 "Set HW_VAR_MEDIA_STATUS: No such media status(%x)\n",
+			 type);
 	}
 	bcnfunc_enable = rtl_read_byte(rtlpriv, REG_BCN_CTRL);
 	switch (type) {
@@ -1102,30 +1101,30 @@ static int _rtl92de_set_media_status(struct ieee80211_hw *hw,
 		ledaction = LED_CTL_LINK;
 		bcnfunc_enable &= 0xF7;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to NO LINK!\n"));
+			 "Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		bt_msr |= MSR_ADHOC;
 		bcnfunc_enable |= 0x08;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to Ad Hoc!\n"));
+			 "Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
 		bt_msr |= MSR_INFRA;
 		ledaction = LED_CTL_LINK;
 		bcnfunc_enable &= 0xF7;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to STA!\n"));
+			 "Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
 		bt_msr |= MSR_AP;
 		bcnfunc_enable |= 0x08;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to AP!\n"));
+			 "Set Network type to AP!\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Network type %d not support!\n", type));
+			 "Network type %d not supported!\n", type);
 		return 1;
 		break;
 
@@ -1189,7 +1188,7 @@ void rtl92d_linked_set_reg(struct ieee80211_hw *hw)
 	indexforchannel = rtl92d_get_rightchnlplace_for_iqk(channel);
 	if (!rtlphy->iqk_matrix_regsetting[indexforchannel].iqk_done) {
 		RT_TRACE(rtlpriv, COMP_SCAN | COMP_INIT, DBG_DMESG,
-				("Do IQK for channel:%d.\n", channel));
+			 "Do IQK for channel:%d\n", channel);
 		rtl92d_phy_iq_calibrate(hw);
 	}
 }
@@ -1305,8 +1304,8 @@ static void _rtl92de_poweroff_adapter(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_APS_FSMCO + 1, 0x10);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("In PowerOff,reg0x%x=%X\n", REG_SPS0_CTRL,
-		  rtl_read_byte(rtlpriv, REG_SPS0_CTRL)));
+		 "In PowerOff,reg0x%x=%X\n",
+		 REG_SPS0_CTRL, rtl_read_byte(rtlpriv, REG_SPS0_CTRL));
 	/* r.   Note: for PCIe interface, PON will not turn */
 	/* off m-bias and BandGap in PCIe suspend mode.  */
 
@@ -1319,7 +1318,7 @@ static void _rtl92de_poweroff_adapter(struct ieee80211_hw *hw)
 		spin_unlock_irqrestore(&globalmutex_power, flags);
 	}
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("<=======\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "<=======\n");
 }
 
 void rtl92de_card_disable(struct ieee80211_hw *hw)
@@ -1377,7 +1376,7 @@ void rtl92de_card_disable(struct ieee80211_hw *hw)
 	rtl_write_byte(rtlpriv, REG_PCIE_CTRL_REG + 1, 0xff);
 	udelay(50);
 	rtl_write_byte(rtlpriv, REG_CR, 0x0);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("==> Do power off.......\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "==> Do power off.......\n");
 	if (rtl92d_phy_check_poweroff(hw))
 		_rtl92de_poweroff_adapter(hw);
 	return;
@@ -1425,7 +1424,7 @@ void rtl92de_set_beacon_interval(struct ieee80211_hw *hw)
 	u16 bcn_interval = mac->beacon_interval;
 
 	RT_TRACE(rtlpriv, COMP_BEACON, DBG_DMESG,
-		 ("beacon_interval:%d\n", bcn_interval));
+		 "beacon_interval:%d\n", bcn_interval);
 	/* rtl92de_disable_interrupt(hw); */
 	rtl_write_word(rtlpriv, REG_BCN_INTERVAL, bcn_interval);
 	/* rtl92de_enable_interrupt(hw); */
@@ -1437,8 +1436,8 @@ void rtl92de_update_interrupt_mask(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
-	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
-		 ("add_msr:%x, rm_msr:%x\n", add_msr, rm_msr));
+	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD, "add_msr:%x, rm_msr:%x\n",
+		 add_msr, rm_msr);
 	if (add_msr)
 		rtlpci->irq_mask[0] |= add_msr;
 	if (rm_msr)
@@ -1615,9 +1614,9 @@ static void _rtl92de_read_txpower_info(struct ieee80211_hw *hw,
 			rtlefuse->internal_pa_5g[1] =
 				!((hwinfo[EEPROM_TSSI_B_5G] & BIT(6)) >> 6);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-				 ("Is D cut,Internal PA0 %d Internal PA1 %d\n",
+				 "Is D cut,Internal PA0 %d Internal PA1 %d\n",
 				 rtlefuse->internal_pa_5g[0],
-				 rtlefuse->internal_pa_5g[1]));
+				 rtlefuse->internal_pa_5g[1]);
 		}
 		rtlefuse->eeprom_c9 = hwinfo[EEPROM_RF_OPT6];
 		rtlefuse->eeprom_cc = hwinfo[EEPROM_RF_OPT7];
@@ -1667,14 +1666,14 @@ static void _rtl92de_read_txpower_info(struct ieee80211_hw *hw,
 	if (rtlefuse->eeprom_c9 == 0xFF)
 		rtlefuse->eeprom_c9 = 0x00;
 	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
-		 ("EEPROMRegulatory = 0x%x\n", rtlefuse->eeprom_regulatory));
+		 "EEPROMRegulatory = 0x%x\n", rtlefuse->eeprom_regulatory);
 	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
-		 ("ThermalMeter = 0x%x\n", rtlefuse->eeprom_thermalmeter));
+		 "ThermalMeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
 	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
-		 ("CrystalCap = 0x%x\n", rtlefuse->crystalcap));
+		 "CrystalCap = 0x%x\n", rtlefuse->crystalcap);
 	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
-		 ("Delta_IQK = 0x%x Delta_LCK = 0x%x\n", rtlefuse->delta_iqk,
-		 rtlefuse->delta_lck));
+		 "Delta_IQK = 0x%x Delta_LCK = 0x%x\n",
+		 rtlefuse->delta_iqk, rtlefuse->delta_lck);
 
 	for (rfPath = 0; rfPath < RF6052_MAX_PATH; rfPath++) {
 		for (ch = 0; ch < CHANNEL_MAX_NUMBER; ch++) {
@@ -1710,11 +1709,11 @@ static void _rtl92de_read_macphymode_from_prom(struct ieee80211_hw *hw,
 	if (macphy_crvalue & BIT(3)) {
 		rtlhal->macphymode = SINGLEMAC_SINGLEPHY;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("MacPhyMode SINGLEMAC_SINGLEPHY\n"));
+			 "MacPhyMode SINGLEMAC_SINGLEPHY\n");
 	} else {
 		rtlhal->macphymode = DUALMAC_DUALPHY;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("MacPhyMode DUALMAC_DUALPHY\n"));
+			 "MacPhyMode DUALMAC_DUALPHY\n");
 	}
 }
 
@@ -1741,15 +1740,15 @@ static void _rtl92de_efuse_update_chip_version(struct ieee80211_hw *hw)
 	switch (chipvalue) {
 	case 0xAA55:
 		chipver |= CHIP_92D_C_CUT;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("C-CUT!!!\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "C-CUT!!!\n");
 		break;
 	case 0x9966:
 		chipver |= CHIP_92D_D_CUT;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("D-CUT!!!\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "D-CUT!!!\n");
 		break;
 	default:
 		chipver |= CHIP_92D_D_CUT;
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, ("Unkown CUT!\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Unkown CUT!\n");
 		break;
 	}
 	rtlpriv->rtlhal.version = chipver;
@@ -1775,7 +1774,7 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 		       HWSET_MAX_SIZE);
 	} else if (rtlefuse->epromtype == EEPROM_93C46) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("RTL819X Not boot from eeprom, check it !!"));
+			 "RTL819X Not boot from eeprom, check it !!\n");
 	}
 	RT_PRINT_DATA(rtlpriv, COMP_INIT, DBG_DMESG, "MAP",
 		      hwinfo, HWSET_MAX_SIZE);
@@ -1783,15 +1782,15 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 	eeprom_id = *((u16 *)&hwinfo[0]);
 	if (eeprom_id != RTL8190_EEPROM_ID) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("EEPROM ID(%#x) is invalid!!\n", eeprom_id));
+			 "EEPROM ID(%#x) is invalid!!\n", eeprom_id);
 		rtlefuse->autoload_failflag = true;
 	} else {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
 	}
 	if (rtlefuse->autoload_failflag) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("RTL819X Not boot from eeprom, check it !!"));
+			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 	}
 	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
@@ -1802,16 +1801,15 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->eeprom_did = *(u16 *)&hwinfo[EEPROM_DID];
 	rtlefuse->eeprom_svid = *(u16 *)&hwinfo[EEPROM_SVID];
 	rtlefuse->eeprom_smid = *(u16 *)&hwinfo[EEPROM_SMID];
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "EEPROMId = 0x%4x\n", eeprom_id);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROMId = 0x%4x\n", eeprom_id));
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROM VID = 0x%4x\n", rtlefuse->eeprom_vid));
+		 "EEPROM VID = 0x%4x\n", rtlefuse->eeprom_vid);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROM DID = 0x%4x\n", rtlefuse->eeprom_did));
+		 "EEPROM DID = 0x%4x\n", rtlefuse->eeprom_did);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROM SVID = 0x%4x\n", rtlefuse->eeprom_svid));
+		 "EEPROM SVID = 0x%4x\n", rtlefuse->eeprom_svid);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROM SMID = 0x%4x\n", rtlefuse->eeprom_smid));
+		 "EEPROM SMID = 0x%4x\n", rtlefuse->eeprom_smid);
 
 	/* Read Permanent MAC address */
 	if (rtlhal->interfaceindex == 0) {
@@ -1827,8 +1825,7 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 	}
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ETHER_ADDR,
 				      rtlefuse->dev_addr);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("%pM\n", rtlefuse->dev_addr));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "%pM\n", rtlefuse->dev_addr);
 	_rtl92de_read_txpower_info(hw, rtlefuse->autoload_failflag, hwinfo);
 
 	/* Read Channel Plan */
@@ -1849,7 +1846,7 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->eeprom_version = *(u16 *)&hwinfo[EEPROM_VERSION];
 	rtlefuse->txpwr_fromeprom = true;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid));
+		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
 }
 
 void rtl92de_read_eeprom_info(struct ieee80211_hw *hw)
@@ -1863,19 +1860,19 @@ void rtl92de_read_eeprom_info(struct ieee80211_hw *hw)
 	tmp_u1b = rtl_read_byte(rtlpriv, REG_9346CR);
 	rtlefuse->autoload_status = tmp_u1b;
 	if (tmp_u1b & BIT(4)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Boot from EEPROM\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EEPROM\n");
 		rtlefuse->epromtype = EEPROM_93C46;
 	} else {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Boot from EFUSE\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EFUSE\n");
 		rtlefuse->epromtype = EEPROM_BOOT_EFUSE;
 	}
 	if (tmp_u1b & BIT(5)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 
 		rtlefuse->autoload_failflag = false;
 		_rtl92de_read_adapter_info(hw);
 	} else {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Autoload ERR!!\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Autoload ERR!!\n");
 	}
 	return;
 }
@@ -1958,8 +1955,8 @@ static void rtl92de_update_hal_rate_table(struct ieee80211_hw *hw,
 		    (shortgi_rate << 4) | (shortgi_rate);
 	}
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-		 ("%x\n", rtl_read_dword(rtlpriv, REG_ARFR0)));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
+		 rtl_read_dword(rtlpriv, REG_ARFR0));
 }
 
 static void rtl92de_update_hal_rate_mask(struct ieee80211_hw *hw,
@@ -2092,8 +2089,8 @@ static void rtl92de_update_hal_rate_mask(struct ieee80211_hw *hw,
 	value[0] = (ratr_bitmap & 0x0fffffff) | (ratr_index << 28);
 	value[1] = macid | (shortgi ? 0x20 : 0x00) | 0x80;
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-		 ("ratr_bitmap :%x value0:%x value1:%x\n",
-		  ratr_bitmap, value[0], value[1]));
+		 "ratr_bitmap :%x value0:%x value1:%x\n",
+		 ratr_bitmap, value[0], value[1]);
 	rtl92d_fill_h2c_cmd(hw, H2C_RA_MASK, 5, (u8 *) value);
 	if (macid != 0)
 		sta_entry->ratr_index = ratr_index;
@@ -2153,14 +2150,14 @@ bool rtl92de_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 	e_rfpowerstate_toset = (u1tmp & BIT(3)) ? ERFON : ERFOFF;
 	if (ppsc->hwradiooff && (e_rfpowerstate_toset == ERFON)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 ("GPIOChangeRF  - HW Radio ON, RF ON\n"));
+			 "GPIOChangeRF  - HW Radio ON, RF ON\n");
 		e_rfpowerstate_toset = ERFON;
 		ppsc->hwradiooff = false;
 		actuallyset = true;
 	} else if ((ppsc->hwradiooff == false)
 		&& (e_rfpowerstate_toset == ERFOFF)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 ("GPIOChangeRF  - HW Radio OFF, RF OFF\n"));
+			 "GPIOChangeRF  - HW Radio OFF, RF OFF\n");
 		e_rfpowerstate_toset = ERFOFF;
 		ppsc->hwradiooff = true;
 		actuallyset = true;
@@ -2204,7 +2201,7 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 		u8 idx;
 		u8 cam_offset = 0;
 		u8 clear_number = 5;
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("clear_all\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "clear_all\n");
 		for (idx = 0; idx < clear_number; idx++) {
 			rtl_cam_mark_invalid(hw, cam_offset + idx);
 			rtl_cam_empty_entry(hw, cam_offset + idx);
@@ -2230,8 +2227,8 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 			enc_algo = CAM_AES;
 			break;
 		default:
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("switch case "
-						"not process\n"));
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+				 "switch case not processed\n");
 			enc_algo = CAM_TKIP;
 			break;
 		}
@@ -2248,9 +2245,8 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 								 p_macaddr);
 					if (entry_id >=  TOTAL_CAM_ENTRY) {
 						RT_TRACE(rtlpriv, COMP_SEC,
-							 DBG_EMERG, ("Can not "
-							 "find free hw security"
-							 " cam entry\n"));
+							 DBG_EMERG,
+							 "Can not find free hw security cam entry\n");
 						return;
 					}
 				} else {
@@ -2262,21 +2258,21 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 		}
 		if (rtlpriv->sec.key_len[key_index] == 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("delete one entry, entry_id is %d\n",
-				 entry_id));
+				 "delete one entry, entry_id is %d\n",
+				 entry_id);
 			if (mac->opmode == NL80211_IFTYPE_AP)
 				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY length is %d\n",
-				  rtlpriv->sec.key_len[PAIRWISE_KEYIDX]));
+				 "The insert KEY length is %d\n",
+				 rtlpriv->sec.key_len[PAIRWISE_KEYIDX]);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY  is %x %x\n",
-				  rtlpriv->sec.key_buf[0][0],
-				  rtlpriv->sec.key_buf[0][1]));
+				 "The insert KEY is %x %x\n",
+				 rtlpriv->sec.key_buf[0][0],
+				 rtlpriv->sec.key_buf[0][1]);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("add one entry\n"));
+				 "add one entry\n");
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
 					      "Pairwise Key content",
@@ -2284,7 +2280,7 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 					      rtlpriv->
 					      sec.key_len[PAIRWISE_KEYIDX]);
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set Pairwiase key\n"));
+					 "set Pairwise key\n");
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
 						      entry_id, enc_algo,
 						      CAM_CONFIG_NO_USEDK,
@@ -2292,7 +2288,7 @@ void rtl92de_set_key(struct ieee80211_hw *hw, u32 key_index,
 						      sec.key_buf[key_index]);
 			} else {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set group key\n"));
+					 "set group key\n");
 				if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 					rtl_cam_add_one_entry(hw,
 						rtlefuse->dev_addr,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/led.c b/drivers/net/wireless/rtlwifi/rtl8192de/led.c
index f1552f4..f2358f2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/led.c
@@ -45,8 +45,8 @@ void rtl92de_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 	u8 ledcfg;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 REG_LEDCFG2, pled->ledpin);
 
 	switch (pled->ledpin) {
 	case LED_PIN_GPIO0:
@@ -71,7 +71,7 @@ void rtl92de_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = true;
@@ -83,8 +83,8 @@ void rtl92de_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	u8 ledcfg;
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", REG_LEDCFG2, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 REG_LEDCFG2, pled->ledpin);
 
 	ledcfg = rtl_read_byte(rtlpriv, REG_LEDCFG2);
 
@@ -106,7 +106,7 @@ void rtl92de_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = false;
@@ -153,7 +153,7 @@ void rtl92de_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction)
 	     ledaction == LED_CTL_POWER_ON)) {
 		return;
 	}
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, ("ledaction %d,\n", ledaction));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d,\n", ledaction);
 
 	_rtl92ce_sw_led_control(hw, ledaction);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
index 0883349..82cc052 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -204,8 +204,8 @@ u32 rtl92d_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 	u32 returnvalue, originalvalue, bitshift;
 	u8 dbi_direct;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-		"bitmask(%#x)\n", regaddr, bitmask));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "regaddr(%#x), bitmask(%#x)\n",
+		 regaddr, bitmask);
 	if (rtlhal->during_mac1init_radioa || rtlhal->during_mac0init_radiob) {
 		/* mac1 use phy0 read radio_b. */
 		/* mac0 use phy1 read radio_b. */
@@ -220,8 +220,9 @@ u32 rtl92d_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 	}
 	bitshift = _rtl92d_phy_calculate_bit_shift(bitmask);
 	returnvalue = (originalvalue & bitmask) >> bitshift;
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("BBR MASK=0x%x "
-		"Addr[0x%x]=0x%x\n", bitmask, regaddr, originalvalue));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "BBR MASK=0x%x Addr[0x%x]=0x%x\n",
+		 bitmask, regaddr, originalvalue);
 	return returnvalue;
 }
 
@@ -233,8 +234,9 @@ void rtl92d_phy_set_bb_reg(struct ieee80211_hw *hw,
 	u8 dbi_direct = 0;
 	u32 originalvalue, bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x),"
-		" data(%#x)\n", regaddr, bitmask, data));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
 	if (rtlhal->during_mac1init_radioa)
 		dbi_direct = BIT(3);
 	else if (rtlhal->during_mac0init_radiob)
@@ -255,8 +257,9 @@ void rtl92d_phy_set_bb_reg(struct ieee80211_hw *hw,
 		rtl92de_write_dword_dbi(hw, (u16) regaddr, data, dbi_direct);
 	else
 		rtl_write_dword(rtlpriv, regaddr, data);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x),"
-		 " data(%#x)\n", regaddr, bitmask, data));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
 }
 
 static u32 _rtl92d_phy_rf_serial_read(struct ieee80211_hw *hw,
@@ -300,8 +303,8 @@ static u32 _rtl92d_phy_rf_serial_read(struct ieee80211_hw *hw,
 	else
 		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
 			BLSSIREADBACKDATA);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("RFR-%d Addr[0x%x] = 0x%x\n",
-		 rfpath, pphyreg->rflssi_readback, retvalue));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x] = 0x%x\n",
+		 rfpath, pphyreg->rflssi_readback, retvalue);
 	return retvalue;
 }
 
@@ -319,8 +322,8 @@ static void _rtl92d_phy_rf_serial_write(struct ieee80211_hw *hw,
 	/* T65 RF */
 	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
 	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, BMASKDWORD, data_and_addr);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("RFW-%d Addr[0x%x]=0x%x\n",
-		rfpath, pphyreg->rf3wire_offset, data_and_addr));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFW-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rf3wire_offset, data_and_addr);
 }
 
 u32 rtl92d_phy_query_rf_reg(struct ieee80211_hw *hw,
@@ -330,17 +333,17 @@ u32 rtl92d_phy_query_rf_reg(struct ieee80211_hw *hw,
 	u32 original_value, readback_value, bitshift;
 	unsigned long flags;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-		"rfpath(%#x), bitmask(%#x)\n",
-		regaddr, rfpath, bitmask));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x)\n",
+		 regaddr, rfpath, bitmask);
 	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
 	original_value = _rtl92d_phy_rf_serial_read(hw, rfpath, regaddr);
 	bitshift = _rtl92d_phy_calculate_bit_shift(bitmask);
 	readback_value = (original_value & bitmask) >> bitshift;
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), rfpath(%#x), "
-		"bitmask(%#x), original_value(%#x)\n",
-		regaddr, rfpath, bitmask, original_value));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
+		 regaddr, rfpath, bitmask, original_value);
 	return readback_value;
 }
 
@@ -353,8 +356,8 @@ void rtl92d_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 	unsigned long flags;
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		("regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
-		regaddr, bitmask, data, rfpath));
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 	if (bitmask == 0)
 		return;
 	spin_lock_irqsave(&rtlpriv->locks.rf_lock, flags);
@@ -369,9 +372,9 @@ void rtl92d_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 		_rtl92d_phy_rf_serial_write(hw, rfpath, regaddr, data);
 	}
 	spin_unlock_irqrestore(&rtlpriv->locks.rf_lock, flags);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), "
-		"bitmask(%#x), data(%#x), rfpath(%#x)\n",
-		regaddr, bitmask, data, rfpath));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 }
 
 bool rtl92d_phy_mac_config(struct ieee80211_hw *hw)
@@ -381,10 +384,10 @@ bool rtl92d_phy_mac_config(struct ieee80211_hw *hw)
 	u32 arraylength;
 	u32 *ptrarray;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Read Rtl819XMACPHY_Array\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Read Rtl819XMACPHY_Array\n");
 	arraylength = MAC_2T_ARRAYLENGTH;
 	ptrarray = rtl8192de_mac_2tarray;
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Img:Rtl819XMAC_Array\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Img:Rtl819XMAC_Array\n");
 	for (i = 0; i < arraylength; i = i + 2)
 		rtl_write_byte(rtlpriv, ptrarray[i], (u8) ptrarray[i + 1]);
 	if (rtlpriv->rtlhal.macphymode == SINGLEMAC_SINGLEPHY) {
@@ -561,25 +564,25 @@ static bool _rtl92d_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 		agctab_arraylen = AGCTAB_ARRAYLENGTH;
 		agctab_array_table = rtl8192de_agctab_array;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 (" ===> phy:MAC0, Rtl819XAGCTAB_Array\n"));
+			 " ===> phy:MAC0, Rtl819XAGCTAB_Array\n");
 	} else {
 		if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 			agctab_arraylen = AGCTAB_2G_ARRAYLENGTH;
 			agctab_array_table = rtl8192de_agctab_2garray;
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 (" ===> phy:MAC1, Rtl819XAGCTAB_2GArray\n"));
+				 " ===> phy:MAC1, Rtl819XAGCTAB_2GArray\n");
 		} else {
 			agctab_5garraylen = AGCTAB_5G_ARRAYLENGTH;
 			agctab_5garray_table = rtl8192de_agctab_5garray;
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 (" ===> phy:MAC1, Rtl819XAGCTAB_5GArray\n"));
+				 " ===> phy:MAC1, Rtl819XAGCTAB_5GArray\n");
 
 		}
 	}
 	phy_reg_arraylen = PHY_REG_2T_ARRAYLENGTH;
 	phy_regarray_table = rtl8192de_phy_reg_2tarray;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 (" ===> phy:Rtl819XPHY_REG_Array_PG\n"));
+		 " ===> phy:Rtl819XPHY_REG_Array_PG\n");
 	if (configtype == BASEBAND_CONFIG_PHY_REG) {
 		for (i = 0; i < phy_reg_arraylen; i = i + 2) {
 			if (phy_regarray_table[i] == 0xfe)
@@ -598,10 +601,9 @@ static bool _rtl92d_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 				      phy_regarray_table[i + 1]);
 			udelay(1);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				 ("The phy_regarray_table[0] is %x"
-				  " Rtl819XPHY_REGArray[1] is %x\n",
-				  phy_regarray_table[i],
-				  phy_regarray_table[i + 1]));
+				 "The phy_regarray_table[0] is %x Rtl819XPHY_REGArray[1] is %x\n",
+				 phy_regarray_table[i],
+				 phy_regarray_table[i + 1]);
 		}
 	} else if (configtype == BASEBAND_CONFIG_AGC_TAB) {
 		if (rtlhal->interfaceindex == 0) {
@@ -613,15 +615,12 @@ static bool _rtl92d_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 				 * setting. */
 				udelay(1);
 				RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-					 ("The Rtl819XAGCTAB_Array_"
-					 "Table[0] is %ul "
-					 "Rtl819XPHY_REGArray[1] is %ul\n",
+					 "The Rtl819XAGCTAB_Array_Table[0] is %ul Rtl819XPHY_REGArray[1] is %ul\n",
 					 agctab_array_table[i],
-					 agctab_array_table[i + 1]));
+					 agctab_array_table[i + 1]);
 			}
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 ("Normal Chip, MAC0, load "
-				 "Rtl819XAGCTAB_Array\n"));
+				 "Normal Chip, MAC0, load Rtl819XAGCTAB_Array\n");
 		} else {
 			if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 				for (i = 0; i < agctab_arraylen; i = i + 2) {
@@ -632,14 +631,12 @@ static bool _rtl92d_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 					 * setting. */
 					udelay(1);
 					RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-						 ("The Rtl819XAGCTAB_Array_"
-						 "Table[0] is %ul Rtl819XPHY_"
-						 "REGArray[1] is %ul\n",
+						 "The Rtl819XAGCTAB_Array_Table[0] is %ul Rtl819XPHY_REGArray[1] is %ul\n",
 						 agctab_array_table[i],
-						 agctab_array_table[i + 1]));
+						 agctab_array_table[i + 1]);
 				}
 				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-					 ("Load Rtl819XAGCTAB_2GArray\n"));
+					 "Load Rtl819XAGCTAB_2GArray\n");
 			} else {
 				for (i = 0; i < agctab_5garraylen; i = i + 2) {
 					rtl_set_bbreg(hw,
@@ -650,14 +647,12 @@ static bool _rtl92d_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
 					 * setting. */
 					udelay(1);
 					RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-						 ("The Rtl819XAGCTAB_5GArray_"
-						 "Table[0] is %ul Rtl819XPHY_"
-						 "REGArray[1] is %ul\n",
+						 "The Rtl819XAGCTAB_5GArray_Table[0] is %ul Rtl819XPHY_REGArray[1] is %ul\n",
 						 agctab_5garray_table[i],
-						 agctab_5garray_table[i + 1]));
+						 agctab_5garray_table[i + 1]);
 				}
 				RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-					("Load Rtl819XAGCTAB_5GArray\n"));
+					 "Load Rtl819XAGCTAB_5GArray\n");
 			}
 		}
 	}
@@ -675,145 +670,145 @@ static void _rtl92d_store_pwrindex_diffrate_offset(struct ieee80211_hw *hw,
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][0] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][0] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][0] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][0]));
+			 [rtlphy->pwrgroup_cnt][0]);
 	}
 	if (regaddr == RTXAGC_A_RATE54_24) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][1] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][1] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][1] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][1]));
+			 [rtlphy->pwrgroup_cnt][1]);
 	}
 	if (regaddr == RTXAGC_A_CCK1_MCS32) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][6] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][6] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][6] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][6]));
+			 [rtlphy->pwrgroup_cnt][6]);
 	}
 	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0xffffff00) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][7] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][7] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][7] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][7]));
+			 [rtlphy->pwrgroup_cnt][7]);
 	}
 	if (regaddr == RTXAGC_A_MCS03_MCS00) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][2] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][2] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][2] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][2]));
+			 [rtlphy->pwrgroup_cnt][2]);
 	}
 	if (regaddr == RTXAGC_A_MCS07_MCS04) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][3] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][3] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][3] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][3]));
+			 [rtlphy->pwrgroup_cnt][3]);
 	}
 	if (regaddr == RTXAGC_A_MCS11_MCS08) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][4] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][4] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][4] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][4]));
+			 [rtlphy->pwrgroup_cnt][4]);
 	}
 	if (regaddr == RTXAGC_A_MCS15_MCS12) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][5] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][5] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][5] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][5]));
+			 [rtlphy->pwrgroup_cnt][5]);
 	}
 	if (regaddr == RTXAGC_B_RATE18_06) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][8] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][8] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][8] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][8]));
+			 [rtlphy->pwrgroup_cnt][8]);
 	}
 	if (regaddr == RTXAGC_B_RATE54_24) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][9] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][9] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][9] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][9]));
+			 [rtlphy->pwrgroup_cnt][9]);
 	}
 	if (regaddr == RTXAGC_B_CCK1_55_MCS32) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][14] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][14] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][14] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][14]));
+			 [rtlphy->pwrgroup_cnt][14]);
 	}
 	if (regaddr == RTXAGC_B_CCK11_A_CCK2_11 && bitmask == 0x000000ff) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][15] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][15] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][15] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][15]));
+			 [rtlphy->pwrgroup_cnt][15]);
 	}
 	if (regaddr == RTXAGC_B_MCS03_MCS00) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][10] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][10] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][10] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][10]));
+			 [rtlphy->pwrgroup_cnt][10]);
 	}
 	if (regaddr == RTXAGC_B_MCS07_MCS04) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][11] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][11] = 0x%ulx\n",
+			 "MCSTxPowerLevelOriginalOffset[%d][11] = 0x%ulx\n",
 			 rtlphy->pwrgroup_cnt,
 			 rtlphy->mcs_txpwrlevel_origoffset
-			 [rtlphy->pwrgroup_cnt][11]));
+			 [rtlphy->pwrgroup_cnt][11]);
 	}
 	if (regaddr == RTXAGC_B_MCS11_MCS08) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][12] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][12] = 0x%ulx\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->mcs_txpwrlevel_origoffset
-					[rtlphy->pwrgroup_cnt][12]));
+			 "MCSTxPowerLevelOriginalOffset[%d][12] = 0x%ulx\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->mcs_txpwrlevel_origoffset
+			 [rtlphy->pwrgroup_cnt][12]);
 	}
 	if (regaddr == RTXAGC_B_MCS15_MCS12) {
 		rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][13] =
 									 data;
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("MCSTxPowerLevelOriginalOffset[%d][13] = 0x%ulx\n",
-			  rtlphy->pwrgroup_cnt,
-			  rtlphy->mcs_txpwrlevel_origoffset
-					[rtlphy->pwrgroup_cnt][13]));
+			 "MCSTxPowerLevelOriginalOffset[%d][13] = 0x%ulx\n",
+			 rtlphy->pwrgroup_cnt,
+			 rtlphy->mcs_txpwrlevel_origoffset
+			 [rtlphy->pwrgroup_cnt][13]);
 		rtlphy->pwrgroup_cnt++;
 	}
 }
@@ -849,7 +844,7 @@ static bool _rtl92d_phy_config_bb_with_pgheaderfile(struct ieee80211_hw *hw,
 		}
 	} else {
 		RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-			 ("configtype != BaseBand_Config_PHY_REG\n"));
+			 "configtype != BaseBand_Config_PHY_REG\n");
 	}
 	return true;
 }
@@ -861,17 +856,17 @@ static bool _rtl92d_phy_bb_config(struct ieee80211_hw *hw)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	bool rtstatus = true;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("==>\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "==>\n");
 	rtstatus = _rtl92d_phy_config_bb_with_headerfile(hw,
 		BASEBAND_CONFIG_PHY_REG);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Write BB Reg Fail!!"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Write BB Reg Fail!!\n");
 		return false;
 	}
 
 	/* if (rtlphy->rf_type == RF_1T2R) {
 	 *      _rtl92c_phy_bb_config_1t(hw);
-	 *     RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Config to 1T!!\n"));
+	 *     RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Config to 1T!!\n");
 	 *} */
 
 	if (rtlefuse->autoload_failflag == false) {
@@ -880,13 +875,13 @@ static bool _rtl92d_phy_bb_config(struct ieee80211_hw *hw)
 			BASEBAND_CONFIG_PHY_REG);
 	}
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("BB_PG Reg Fail!!"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "BB_PG Reg Fail!!\n");
 		return false;
 	}
 	rtstatus = _rtl92d_phy_config_bb_with_headerfile(hw,
 		BASEBAND_CONFIG_AGC_TAB);
 	if (rtstatus != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("AGC Table Fail\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "AGC Table Fail\n");
 		return false;
 	}
 	rtlphy->cck_high_power = (bool) (rtl_get_bbreg(hw,
@@ -951,19 +946,17 @@ bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		radiob_array_table = rtl8192de_radiob_2t_int_paarray;
 	}
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("PHY_ConfigRFWithHeaderFile() "
-		 "Radio_A:Rtl819XRadioA_1TArray\n"));
+		 "PHY_ConfigRFWithHeaderFile() Radio_A:Rtl819XRadioA_1TArray\n");
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("PHY_ConfigRFWithHeaderFile() "
-		 "Radio_B:Rtl819XRadioB_1TArray\n"));
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("Radio No %x\n", rfpath));
+		 "PHY_ConfigRFWithHeaderFile() Radio_B:Rtl819XRadioB_1TArray\n");
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "Radio No %x\n", rfpath);
 
 	/* this only happens when DMDP, mac0 start on 2.4G,
 	 * mac1 start on 5G, mac 0 has to set phy0&phy1
 	 * pathA or mac1 has to set phy0&phy1 pathA */
 	if ((content == radiob_txt) && (rfpath == RF90_PATH_A)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 (" ===> althougth Path A, we load radiob.txt\n"));
+			 " ===> althougth Path A, we load radiob.txt\n");
 		radioa_arraylen = radiob_arraylen;
 		radioa_array_table = radiob_array_table;
 	}
@@ -1022,11 +1015,11 @@ bool rtl92d_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
 		break;
 	case RF90_PATH_C:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	case RF90_PATH_D:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	return true;
@@ -1046,19 +1039,18 @@ void rtl92d_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 	rtlphy->default_initialgain[3] =
 	    (u8) rtl_get_bbreg(hw, ROFDM0_XDAGCCORE1, BMASKBYTE0);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Default initial gain (c50=0x%x, "
-		  "c58=0x%x, c60=0x%x, c68=0x%x\n",
-		  rtlphy->default_initialgain[0],
-		  rtlphy->default_initialgain[1],
-		  rtlphy->default_initialgain[2],
-		  rtlphy->default_initialgain[3]));
+		 "Default initial gain (c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x\n",
+		 rtlphy->default_initialgain[0],
+		 rtlphy->default_initialgain[1],
+		 rtlphy->default_initialgain[2],
+		 rtlphy->default_initialgain[3]);
 	rtlphy->framesync = (u8)rtl_get_bbreg(hw, ROFDM0_RXDETECTOR3,
 					      BMASKBYTE0);
 	rtlphy->framesync_c34 = rtl_get_bbreg(hw, ROFDM0_RXDETECTOR2,
 					      BMASKDWORD);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-		 ("Default framesync (0x%x) = 0x%x\n",
-		  ROFDM0_RXDETECTOR3, rtlphy->framesync));
+		 "Default framesync (0x%x) = 0x%x\n",
+		 ROFDM0_RXDETECTOR3, rtlphy->framesync);
 }
 
 static void _rtl92d_get_txpower_index(struct ieee80211_hw *hw, u8 channel,
@@ -1172,7 +1164,7 @@ void rtl92d_phy_scan_operation_backup(struct ieee80211_hw *hw, u8 operation)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Unknown Scan Backup operation.\n"));
+				 "Unknown Scan Backup operation\n");
 			break;
 		}
 	}
@@ -1193,14 +1185,13 @@ void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
 		return;
 	if ((is_hal_stop(rtlhal)) || (RT_CANNOT_IO(hw))) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("FALSE driver sleep or unload\n"));
+			 "FALSE driver sleep or unload\n");
 		return;
 	}
 	rtlphy->set_bwmode_inprogress = true;
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
-		 ("Switch to %s bandwidth\n",
-		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
-		  "20MHz" : "40MHz"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "Switch to %s bandwidth\n",
+		 rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
+		 "20MHz" : "40MHz");
 	reg_bw_opmode = rtl_read_byte(rtlpriv, REG_BWOPMODE);
 	reg_prsr_rsc = rtl_read_byte(rtlpriv, REG_RRSR + 2);
 	switch (rtlphy->current_chan_bw) {
@@ -1218,7 +1209,7 @@ void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
 	switch (rtlphy->current_chan_bw) {
@@ -1250,13 +1241,13 @@ void rtl92d_phy_set_bw_mode(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 
 	}
 	rtl92d_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
 	rtlphy->set_bwmode_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("<==\n"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
 }
 
 static void _rtl92d_phy_stop_trx_before_changeband(struct ieee80211_hw *hw)
@@ -1273,7 +1264,7 @@ static void rtl92d_phy_switch_wirelessband(struct ieee80211_hw *hw, u8 band)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	u8 value8;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("==>\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "==>\n");
 	rtlhal->bandset = band;
 	rtlhal->current_bandtype = band;
 	if (IS_92D_SINGLEPHY(rtlhal->version))
@@ -1283,13 +1274,13 @@ static void rtl92d_phy_switch_wirelessband(struct ieee80211_hw *hw, u8 band)
 	/* reconfig BB/RF according to wireless mode */
 	if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 		/* BB & RF Config */
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, ("====>2.4G\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "====>2.4G\n");
 		if (rtlhal->interfaceindex == 1)
 			_rtl92d_phy_config_bb_with_headerfile(hw,
 				BASEBAND_CONFIG_AGC_TAB);
 	} else {
 		/* 5G band */
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, ("====>5G\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "====>5G\n");
 		if (rtlhal->interfaceindex == 1)
 			_rtl92d_phy_config_bb_with_headerfile(hw,
 				BASEBAND_CONFIG_AGC_TAB);
@@ -1317,7 +1308,7 @@ static void rtl92d_phy_switch_wirelessband(struct ieee80211_hw *hw, u8 band)
 			0 ? REG_MAC0 : REG_MAC1), value8);
 	}
 	mdelay(1);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("<==Switch Band OK.\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "<==Switch Band OK\n");
 }
 
 static void _rtl92d_phy_reload_imr_setting(struct ieee80211_hw *hw,
@@ -1329,9 +1320,9 @@ static void _rtl92d_phy_reload_imr_setting(struct ieee80211_hw *hw,
 	u8 group, i;
 	unsigned long flag = 0;
 
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("====>path %d\n", rfpath));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>path %d\n", rfpath);
 	if (rtlpriv->rtlhal.current_bandtype == BAND_ON_5G) {
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("====>5G\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>5G\n");
 		rtl_set_bbreg(hw, RFPGA0_RFMOD, BIT(25) | BIT(24), 0);
 		rtl_set_bbreg(hw, RFPGA0_ANALOGPARAMETER4, 0x00f00000, 0xf);
 		/* fc area 0xd2c */
@@ -1353,14 +1344,13 @@ static void _rtl92d_phy_reload_imr_setting(struct ieee80211_hw *hw,
 	} else {
 		/* G band. */
 		RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
-			 ("Load RF IMR parameters for G band. IMR already "
-			 "setting %d\n",
-			  rtlpriv->rtlhal.load_imrandiqk_setting_for2g));
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("====>2.4G\n"));
+			 "Load RF IMR parameters for G band. IMR already setting %d\n",
+			 rtlpriv->rtlhal.load_imrandiqk_setting_for2g);
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>2.4G\n");
 		if (!rtlpriv->rtlhal.load_imrandiqk_setting_for2g) {
 			RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
-				("Load RF IMR parameters "
-				"for G band. %d\n", rfpath));
+				 "Load RF IMR parameters for G band. %d\n",
+				 rfpath);
 			rtl92d_acquire_cckandrw_pagea_ctl(hw, &flag);
 			rtl_set_bbreg(hw, RFPGA0_RFMOD, BIT(25) | BIT(24), 0);
 			rtl_set_bbreg(hw, RFPGA0_ANALOGPARAMETER4,
@@ -1378,7 +1368,7 @@ static void _rtl92d_phy_reload_imr_setting(struct ieee80211_hw *hw,
 			rtl92d_release_cckandrw_pagea_ctl(hw, &flag);
 		}
 	}
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("<====\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "<====\n");
 }
 
 static void _rtl92d_phy_enable_rf_env(struct ieee80211_hw *hw,
@@ -1388,7 +1378,7 @@ static void _rtl92d_phy_enable_rf_env(struct ieee80211_hw *hw,
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("====>\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "====>\n");
 	/*----Store original RFENV control type----*/
 	switch (rfpath) {
 	case RF90_PATH_A:
@@ -1414,7 +1404,7 @@ static void _rtl92d_phy_enable_rf_env(struct ieee80211_hw *hw,
 	/*Set 0 to 12 bits for 8255 */
 	rtl_set_bbreg(hw, pphyreg->rfhssi_para2, B3WIREDATALENGTH, 0x0);
 	udelay(1);
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("<====\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "<====\n");
 }
 
 static void _rtl92d_phy_restore_rf_env(struct ieee80211_hw *hw, u8 rfpath,
@@ -1424,7 +1414,7 @@ static void _rtl92d_phy_restore_rf_env(struct ieee80211_hw *hw, u8 rfpath,
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct bb_reg_def *pphyreg = &rtlphy->phyreg_def[rfpath];
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("=====>\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "=====>\n");
 	/*----Restore RFENV control type----*/ ;
 	switch (rfpath) {
 	case RF90_PATH_A:
@@ -1437,7 +1427,7 @@ static void _rtl92d_phy_restore_rf_env(struct ieee80211_hw *hw, u8 rfpath,
 			      *pu4_regval);
 		break;
 	}
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("<=====\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "<=====\n");
 }
 
 static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
@@ -1451,10 +1441,10 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 	bool need_pwr_down = false, internal_pa = false;
 	u32 u4regvalue, mask = 0x1C000, value = 0, u4tmp, u4tmp2;
 
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("====>\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>\n");
 	/* config path A for 5G */
 	if (rtlhal->current_bandtype == BAND_ON_5G) {
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("====>5G\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>5G\n");
 		u4tmp = curveindex_5g[channel - 1];
 		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("ver 1 set RF-A, 5G, "
 			"0x28 = 0x%x !!\n", u4tmp));
@@ -1503,12 +1493,13 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 					      rf_reg_pram_c_5g[index][i]);
 			}
 			RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-				("offset 0x%x value 0x%x "
-				"path %d index %d readback 0x%x\n",
-				rf_reg_for_c_cut_5g[i],
-				rf_reg_pram_c_5g[index][i], path,
-				index, rtl_get_rfreg(hw, (enum radio_path)path,
-				rf_reg_for_c_cut_5g[i], BRFREGOFFSETMASK)));
+				 "offset 0x%x value 0x%x path %d index %d readback 0x%x\n",
+				 rf_reg_for_c_cut_5g[i],
+				 rf_reg_pram_c_5g[index][i],
+				 path, index,
+				 rtl_get_rfreg(hw, (enum radio_path)path,
+					       rf_reg_for_c_cut_5g[i],
+					       BRFREGOFFSETMASK));
 		}
 		if (need_pwr_down)
 			_rtl92d_phy_restore_rf_env(hw, path, &u4regvalue);
@@ -1541,11 +1532,10 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 						BRFREGOFFSETMASK,
 						rf_pram_c_5g_int_pa[index][i]);
 					RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD,
-						 ("offset 0x%x value 0x%x "
-						 "path %d index %d\n",
+						 "offset 0x%x value 0x%x path %d index %d\n",
 						 rf_for_c_cut_5g_internal_pa[i],
 						 rf_pram_c_5g_int_pa[index][i],
-						 rfpath, index));
+						 rfpath, index);
 				}
 			} else {
 				rtl_set_rfreg(hw, (enum radio_path)rfpath, 0x0B,
@@ -1553,7 +1543,7 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 			}
 		}
 	} else if (rtlhal->current_bandtype == BAND_ON_2_4G) {
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("====>2.4G\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "====>2.4G\n");
 		u4tmp = curveindex_2g[channel - 1];
 		RTPRINT(rtlpriv, FINIT, INIT_IQK, ("ver 3 set RF-B, 2G, "
 			"0x28 = 0x%x !!\n", u4tmp));
@@ -1590,14 +1580,13 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 					      rf_reg_param_for_c_cut_2g
 					      [index][i]);
 			RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-				("offset 0x%x value 0x%x mak 0x%x path %d "
-				"index %d readback 0x%x\n",
-				rf_reg_for_c_cut_2g[i],
-				rf_reg_param_for_c_cut_2g[index][i],
-				rf_reg_mask_for_c_cut_2g[i], path, index,
-				rtl_get_rfreg(hw, (enum radio_path)path,
-				rf_reg_for_c_cut_2g[i],
-				BRFREGOFFSETMASK)));
+				 "offset 0x%x value 0x%x mak 0x%x path %d index %d readback 0x%x\n",
+				 rf_reg_for_c_cut_2g[i],
+				 rf_reg_param_for_c_cut_2g[index][i],
+				 rf_reg_mask_for_c_cut_2g[i], path, index,
+				 rtl_get_rfreg(hw, (enum radio_path)path,
+					       rf_reg_for_c_cut_2g[i],
+					       BRFREGOFFSETMASK));
 		}
 		RTPRINT(rtlpriv, FINIT, INIT_IQK,
 			("cosa ver 3 set RF-B, 2G, 0x28 = 0x%x !!\n",
@@ -1611,7 +1600,7 @@ static void _rtl92d_phy_switch_rf_setting(struct ieee80211_hw *hw, u8 channel)
 		if (rtlhal->during_mac0init_radiob)
 			rtl92d_phy_powerdown_anotherphy(hw, true);
 	}
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("<====\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "<====\n");
 }
 
 u8 rtl92d_get_rightchnlplace_for_iqk(u8 chnl)
@@ -2618,7 +2607,7 @@ void rtl92d_phy_iq_calibrate(struct ieee80211_hw *hw)
 			true;
 
 		RT_TRACE(rtlpriv, COMP_SCAN | COMP_MLME, DBG_LOUD,
-			 ("\nIQK OK indexforchannel %d.\n", indexforchannel));
+			 "IQK OK indexforchannel %d\n", indexforchannel);
 	}
 }
 
@@ -2629,17 +2618,17 @@ void rtl92d_phy_reload_iqk_setting(struct ieee80211_hw *hw, u8 channel)
 	struct rtl_hal *rtlhal = &(rtlpriv->rtlhal);
 	u8 indexforchannel;
 
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("channel %d\n", channel));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "channel %d\n", channel);
 	/*------Do IQK for normal chip and test chip 5G band------- */
 	indexforchannel = rtl92d_get_rightchnlplace_for_iqk(channel);
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-		("indexforchannel %d done %d\n", indexforchannel,
-		rtlphy->iqk_matrix_regsetting[indexforchannel].iqk_done));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "indexforchannel %d done %d\n",
+		 indexforchannel,
+		 rtlphy->iqk_matrix_regsetting[indexforchannel].iqk_done);
 	if (0 && !rtlphy->iqk_matrix_regsetting[indexforchannel].iqk_done &&
 		rtlphy->need_iqk) {
 		/* Re Do IQK. */
 		RT_TRACE(rtlpriv, COMP_SCAN | COMP_INIT, DBG_LOUD,
-			 ("Do IQK Matrix reg for channel:%d....\n", channel));
+			 "Do IQK Matrix reg for channel:%d....\n", channel);
 		rtl92d_phy_iq_calibrate(hw);
 	} else {
 		/* Just load the value. */
@@ -2647,8 +2636,8 @@ void rtl92d_phy_reload_iqk_setting(struct ieee80211_hw *hw, u8 channel)
 		if (((!rtlhal->load_imrandiqk_setting_for2g) &&
 		    indexforchannel == 0) || indexforchannel > 0) {
 			RT_TRACE(rtlpriv, COMP_SCAN, DBG_LOUD,
-				 ("Just Read IQK Matrix reg for channel:%d"
-				 "....\n", channel));
+				 "Just Read IQK Matrix reg for channel:%d....\n",
+				 channel);
 			if ((rtlphy->iqk_matrix_regsetting[indexforchannel].
 			     value[0] != NULL)
 				/*&&(regea4 != 0) */)
@@ -2672,7 +2661,7 @@ void rtl92d_phy_reload_iqk_setting(struct ieee80211_hw *hw, u8 channel)
 		}
 	}
 	rtlphy->need_iqk = false;
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("<====\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "<====\n");
 }
 
 static u32 _rtl92d_phy_get_abs(u32 val1, u32 val2)
@@ -2743,7 +2732,7 @@ static void _rtl92d_phy_reload_lck_setting(struct ieee80211_hw *hw,
 	u32 u4tmp = 0, u4regvalue = 0;
 	bool bneed_powerdown_radio = false;
 
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("path %d\n", erfpath));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "path %d\n", erfpath);
 	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("band type = %d\n",
 		rtlpriv->rtlhal.current_bandtype));
 	RTPRINT(rtlpriv, FINIT, INIT_IQK, ("channel = %d\n", channel));
@@ -2788,7 +2777,7 @@ static void _rtl92d_phy_reload_lck_setting(struct ieee80211_hw *hw,
 		if (rtlpriv->rtlhal.during_mac0init_radiob)
 			rtl92d_phy_powerdown_anotherphy(hw, true);
 	}
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("<====\n"));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "<====\n");
 }
 
 static void _rtl92d_phy_lc_calibrate_sw(struct ieee80211_hw *hw, bool is2t)
@@ -2962,10 +2951,10 @@ void rtl92d_phy_reset_iqk_result(struct ieee80211_hw *hw)
 	u8 i;
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			("settings regs %d default regs %d\n",
-			(int)(sizeof(rtlphy->iqk_matrix_regsetting) /
-			sizeof(struct iqk_matrix_regs)),
-			IQK_MATRIX_REG_NUM));
+		 "settings regs %d default regs %d\n",
+		 (int)(sizeof(rtlphy->iqk_matrix_regsetting) /
+		       sizeof(struct iqk_matrix_regs)),
+		 IQK_MATRIX_REG_NUM);
 	/* 0xe94, 0xe9c, 0xea4, 0xeac, 0xeb4, 0xebc, 0xec4, 0xecc */
 	for (i = 0; i < IQK_MATRIX_SETTINGS_NUM; i++) {
 		rtlphy->iqk_matrix_regsetting[i].value[0][0] = 0x100;
@@ -3084,7 +3073,7 @@ static bool _rtl92d_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 		break;
@@ -3111,7 +3100,7 @@ u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw)
 
 	if ((is_hal_stop(rtlhal)) || (RT_CANNOT_IO(hw))) {
 		RT_TRACE(rtlpriv, COMP_CHAN, DBG_LOUD,
-			 ("sw_chnl_inprogress false driver sleep or unload\n"));
+			 "sw_chnl_inprogress false driver sleep or unload\n");
 		return 0;
 	}
 	while (rtlphy->lck_inprogress && timecount < timeout) {
@@ -3154,7 +3143,7 @@ u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw)
 	rtlphy->sw_chnl_stage = 0;
 	rtlphy->sw_chnl_step = 0;
 	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
-		 ("switch to channel%d\n", rtlphy->current_channel));
+		 "switch to channel%d\n", rtlphy->current_channel);
 
 	do {
 		if (!rtlphy->sw_chnl_inprogress)
@@ -3171,7 +3160,7 @@ u8 rtl92d_phy_sw_chnl(struct ieee80211_hw *hw)
 		}
 		break;
 	} while (true);
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("<==\n"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
 	rtlphy->sw_chnl_inprogress = false;
 	return 1;
 }
@@ -3182,8 +3171,8 @@ static void rtl92d_phy_set_io(struct ieee80211_hw *hw)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 ("--->Cmd(%#x), set_io_inprogress(%d)\n",
-		 rtlphy->current_io_type, rtlphy->set_io_inprogress));
+		 "--->Cmd(%#x), set_io_inprogress(%d)\n",
+		 rtlphy->current_io_type, rtlphy->set_io_inprogress);
 	switch (rtlphy->current_io_type) {
 	case IO_CMD_RESUME_DM_BY_SCAN:
 		de_digtable.cur_igvalue = rtlphy->initgain_backup.xaagccore1;
@@ -3197,12 +3186,12 @@ static void rtl92d_phy_set_io(struct ieee80211_hw *hw)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	rtlphy->set_io_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 ("<---(%#x)\n", rtlphy->current_io_type));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "<---(%#x)\n",
+		 rtlphy->current_io_type);
 }
 
 bool rtl92d_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
@@ -3212,23 +3201,23 @@ bool rtl92d_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 	bool postprocessing = false;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-		 ("-->IO Cmd(%#x), set_io_inprogress(%d)\n",
-		 iotype, rtlphy->set_io_inprogress));
+		 "-->IO Cmd(%#x), set_io_inprogress(%d)\n",
+		 iotype, rtlphy->set_io_inprogress);
 	do {
 		switch (iotype) {
 		case IO_CMD_RESUME_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-				 ("[IO CMD] Resume DM after scan.\n"));
+				 "[IO CMD] Resume DM after scan\n");
 			postprocessing = true;
 			break;
 		case IO_CMD_PAUSE_DM_BY_SCAN:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE,
-				 ("[IO CMD] Pause DM before scan.\n"));
+				 "[IO CMD] Pause DM before scan\n");
 			postprocessing = true;
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 	} while (false);
@@ -3239,7 +3228,7 @@ bool rtl92d_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype)
 		return false;
 	}
 	rtl92d_phy_set_io(hw);
-	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, ("<--IO Type(%#x)\n", iotype));
+	RT_TRACE(rtlpriv, COMP_CMD, DBG_TRACE, "<--IO Type(%#x)\n", iotype);
 	return true;
 }
 
@@ -3297,7 +3286,7 @@ static void _rtl92d_phy_set_rfsleep(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, REG_SYS_FUNC_EN, 0xE3);
 		rtl_write_byte(rtlpriv, REG_TXPAUSE, 0x00);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			("Fail !!! Switch RF timeout.\n"));
+			 "Fail !!! Switch RF timeout\n");
 		return;
 	}
 	/* e.   For PCIE: SYS_FUNC_EN 0x02[7:0] = 0xE2 reset BB TRX function */
@@ -3332,7 +3321,7 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
 			do {
 				InitializeCount++;
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-					 ("IPS Set eRf nic enable\n"));
+					 "IPS Set eRf nic enable\n");
 				rtstatus = rtl_ps_enable_nic(hw);
 			} while ((rtstatus != true) &&
 				 (InitializeCount < 10));
@@ -3341,11 +3330,10 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					  RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-				 ("awake, sleeped:%d ms state_"
-				 "inap:%x\n",
+				 "awake, sleeped:%d ms state_inap:%x\n",
 				 jiffies_to_msecs(jiffies -
-				 ppsc->last_sleep_jiffies),
-				 rtlpriv->psc.state_inap));
+						  ppsc->last_sleep_jiffies),
+				 rtlpriv->psc.state_inap);
 			ppsc->last_awake_jiffies = jiffies;
 			_rtl92d_phy_set_rfon(hw);
 		}
@@ -3360,7 +3348,7 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
 	case ERFOFF:
 		if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC) {
 			RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-				 ("IPS Set eRf nic disable\n"));
+				 "IPS Set eRf nic disable\n");
 			rtl_ps_disable_nic(hw);
 			RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 		} else {
@@ -3385,41 +3373,40 @@ bool rtl92d_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				continue;
 			} else if (rtlpci->pdev->current_state != PCI_D0) {
 				RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-					 ("eRf Off/Sleep: %d times TcbBusyQueu"
-					 "e[%d] !=0 but lower power state!\n",
-					 (i + 1), queue_id));
+					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] !=0 but lower power state!\n",
+					 i + 1, queue_id);
 				break;
 			} else {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("eRf Off/Sleep: %d times TcbBusyQueu"
-					 "e[%d] =%d "
-					 "before doze!\n", (i + 1), queue_id,
-					  skb_queue_len(&ring->queue)));
+					 "eRf Off/Sleep: %d times TcbBusyQueue[%d] =%d before doze!\n",
+					 i + 1, queue_id,
+					 skb_queue_len(&ring->queue));
 				udelay(10);
 				i++;
 			}
 
 			if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 				RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-					 ("\nERFOFF: %d times TcbBusyQueue[%d] "
-					 "= %d !\n",
-					  MAX_DOZE_WAITING_TIMES_9x, queue_id,
-					  skb_queue_len(&ring->queue)));
+					 "ERFOFF: %d times TcbBusyQueue[%d] = %d !\n",
+					 MAX_DOZE_WAITING_TIMES_9x, queue_id,
+					 skb_queue_len(&ring->queue));
 				break;
 			}
 		}
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-			 ("Set rfsleep awaked:%d ms\n",
-			 jiffies_to_msecs(jiffies - ppsc->last_awake_jiffies)));
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG, ("sleep awaked:%d ms "
-			 "state_inap:%x\n", jiffies_to_msecs(jiffies -
-			 ppsc->last_awake_jiffies), rtlpriv->psc.state_inap));
+			 "Set rfsleep awaked:%d ms\n",
+			 jiffies_to_msecs(jiffies - ppsc->last_awake_jiffies));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
+			 "sleep awaked:%d ms state_inap:%x\n",
+			 jiffies_to_msecs(jiffies -
+					  ppsc->last_awake_jiffies),
+			 rtlpriv->psc.state_inap);
 		ppsc->last_sleep_jiffies = jiffies;
 		_rtl92d_phy_set_rfsleep(hw);
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		bresult = false;
 		break;
 	}
@@ -3437,17 +3424,17 @@ void rtl92d_phy_config_macphymode(struct ieee80211_hw *hw)
 	switch (rtlhal->macphymode) {
 	case DUALMAC_DUALPHY:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("MacPhyMode: DUALMAC_DUALPHY\n"));
+			 "MacPhyMode: DUALMAC_DUALPHY\n");
 		rtl_write_byte(rtlpriv, offset, 0xF3);
 		break;
 	case SINGLEMAC_SINGLEPHY:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("MacPhyMode: SINGLEMAC_SINGLEPHY\n"));
+			 "MacPhyMode: SINGLEMAC_SINGLEPHY\n");
 		rtl_write_byte(rtlpriv, offset, 0xF4);
 		break;
 	case DUALMAC_SINGLEPHY:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("MacPhyMode: DUALMAC_SINGLEPHY\n"));
+			 "MacPhyMode: DUALMAC_SINGLEPHY\n");
 		rtl_write_byte(rtlpriv, offset, 0xF1);
 		break;
 	}
@@ -3615,7 +3602,7 @@ void rtl92d_update_bbrf_configuration(struct ieee80211_hw *hw)
 	struct rtl_efuse *rtlefuse = rtl_efuse(rtl_priv(hw));
 	u8 rfpath, i;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("==>\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "==>\n");
 	/* r_select_5G for path_A/B 0 for 2.4G, 1 for 5G */
 	if (rtlhal->current_bandtype == BAND_ON_2_4G) {
 		/* r_select_5G for path_A/B,0x878 */
@@ -3764,7 +3751,7 @@ void rtl92d_update_bbrf_configuration(struct ieee80211_hw *hw)
 		} else {
 			rtl92d_phy_enable_anotherphy(hw, false);
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				 ("MAC1 use DBI to update 0x888"));
+				 "MAC1 use DBI to update 0x888\n");
 			/* 0x888 */
 			rtl92de_write_dword_dbi(hw, RFPGA0_ADDALLOCKEN,
 						rtl92de_read_dword_dbi(hw,
@@ -3789,9 +3776,9 @@ void rtl92d_update_bbrf_configuration(struct ieee80211_hw *hw)
 			BRFREGOFFSETMASK);
 	}
 	for (i = 0; i < 2; i++)
-		RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("RF 0x18 = 0x%x\n",
-			  rtlphy->rfreg_chnlval[i]));
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("<==\n"));
+		RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "RF 0x18 = 0x%x\n",
+			 rtlphy->rfreg_chnlval[i]);
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "<==\n");
 
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
index db27ceb..3bf21c2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
@@ -50,8 +50,8 @@ void rtl92d_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 				      BIT(11), 0x01);
 
 			RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD,
-				 ("20M RF 0x18 = 0x%x\n",
-				 rtlphy->rfreg_chnlval[rfpath]));
+				 "20M RF 0x18 = 0x%x\n",
+				 rtlphy->rfreg_chnlval[rfpath]);
 		}
 
 		break;
@@ -62,13 +62,13 @@ void rtl92d_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 			rtl_set_rfreg(hw, rfpath, RF_CHNLBW, BIT(10) | BIT(11),
 				      0x00);
 			RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD,
-				 ("40M RF 0x18 = 0x%x\n",
-				 rtlphy->rfreg_chnlval[rfpath]));
+				 "40M RF 0x18 = 0x%x\n",
+				 rtlphy->rfreg_chnlval[rfpath]);
 		}
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", bandwidth));
+			 "unknown bandwidth: %#X\n", bandwidth);
 		break;
 	}
 }
@@ -423,11 +423,11 @@ bool rtl92d_phy_enable_anotherphy(struct ieee80211_hw *hw, bool bmac0)
 
 	rtlhal->during_mac0init_radiob = false;
 	rtlhal->during_mac1init_radioa = false;
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("===>\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "===>\n");
 	/* MAC0 Need PHY1 load radio_b.txt . Driver use DBI to write. */
 	u1btmp = rtl_read_byte(rtlpriv, mac_reg);
 	if (!(u1btmp & mac_on_bit)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("enable BB & RF\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "enable BB & RF\n");
 		/* Enable BB and RF power */
 		rtl92de_write_dword_dbi(hw, REG_SYS_ISO_CTRL,
 			rtl92de_read_dword_dbi(hw, REG_SYS_ISO_CTRL, direct) |
@@ -437,7 +437,7 @@ bool rtl92d_phy_enable_anotherphy(struct ieee80211_hw *hw, bool bmac0)
 		 * and radio_b.txt has been load. */
 		bresult = false;
 	}
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("<===\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "<===\n");
 	return bresult;
 
 }
@@ -453,17 +453,17 @@ void rtl92d_phy_powerdown_anotherphy(struct ieee80211_hw *hw, bool bmac0)
 
 	rtlhal->during_mac0init_radiob = false;
 	rtlhal->during_mac1init_radioa = false;
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("====>\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "====>\n");
 	/* check MAC0 enable or not again now, if
 	 * enabled, not power down radio A. */
 	u1btmp = rtl_read_byte(rtlpriv, mac_reg);
 	if (!(u1btmp & mac_on_bit)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("power down\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "power down\n");
 		/* power down RF radio A according to YuNan's advice. */
 		rtl92de_write_dword_dbi(hw, RFPGA0_XA_LSSIPARAMETER,
 					0x00000000, direct);
 	}
-	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, ("<====\n"));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_LOUD, "<====\n");
 }
 
 bool rtl92d_phy_rf6052_config(struct ieee80211_hw *hw)
@@ -606,7 +606,7 @@ bool rtl92d_phy_rf6052_config(struct ieee80211_hw *hw)
 		}
 		if (rtstatus != true) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-				("Radio[%d] Fail!!", rfpath));
+				 "Radio[%d] Fail!!", rfpath);
 			goto phy_rf_cfg_fail;
 		}
 
@@ -620,7 +620,7 @@ bool rtl92d_phy_rf6052_config(struct ieee80211_hw *hw)
 		rtl92d_phy_powerdown_anotherphy(hw, false);
 	else if (need_pwrdown_radiob)
 		rtl92d_phy_powerdown_anotherphy(hw, true);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, ("<---\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE, "<---\n");
 	return rtstatus;
 
 phy_rf_cfg_fail:
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
index 7911c9c..db75796 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -174,7 +174,7 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->rtlhal.pfirmware = vzalloc(0x8000);
 	if (!rtlpriv->rtlhal.pfirmware) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't alloc buffer for fw.\n"));
+			 "Can't alloc buffer for fw\n");
 		return 1;
 	}
 
@@ -188,12 +188,12 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 			       rtlpriv->io.dev);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Failed to request firmware!\n"));
+			 "Failed to request firmware!\n");
 		return 1;
 	}
 	if (firmware->size > 0x8000) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Firmware is too big!\n"));
+			 "Firmware is too big!\n");
 		release_firmware(firmware);
 		return 1;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index e84b8d5..f6ec0a1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -602,8 +602,8 @@ void rtl92de_tx_fill_desc(struct ieee80211_hw *hw,
 					   EM_HDR_LEN);
 			if (ptcb_desc->empkt_num) {
 				RT_TRACE(rtlpriv, COMP_SEND, DBG_LOUD,
-					 ("Insert 8 byte.pTcb->EMPktNum:%d\n",
-					  ptcb_desc->empkt_num));
+					 "Insert 8 byte.pTcb->EMPktNum:%d\n",
+					 ptcb_desc->empkt_num);
 				_rtl92de_insert_emcontent(ptcb_desc,
 							  (u8 *)(skb->data));
 			}
@@ -700,7 +700,7 @@ void rtl92de_tx_fill_desc(struct ieee80211_hw *hw,
 		if (ieee80211_is_data_qos(fc)) {
 			if (mac->rdg_en) {
 				RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE,
-					("Enable RDG function.\n"));
+					 "Enable RDG function\n");
 				SET_TX_DESC_RDG_ENABLE(pdesc, 1);
 				SET_TX_DESC_HTC(pdesc, 1);
 			}
@@ -726,7 +726,7 @@ void rtl92de_tx_fill_desc(struct ieee80211_hw *hw,
 		SET_TX_DESC_PKT_ID(pdesc, 8);
 	}
 	SET_TX_DESC_MORE_FRAG(pdesc, (lastseg ? 0 : 1));
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, ("\n"));
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
 }
 
 void rtl92de_tx_fill_cmddesc(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
index 4203a85..4a5e3a9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
@@ -170,9 +170,9 @@ static void _rtl92s_dm_txpowertracking_callback_thermalmeter(
 	thermalvalue = (u8)rtl_get_rfreg(hw, RF90_PATH_A, RF_T_METER, 0x1f);
 
 	RT_TRACE(rtlpriv, COMP_POWER_TRACKING, DBG_LOUD,
-		 ("Readback Thermal Meter = 0x%x pre thermal meter 0x%x "
-		  "eeprom_thermalmeter 0x%x\n", thermalvalue,
-		  rtlpriv->dm.thermalvalue, rtlefuse->eeprom_thermalmeter));
+		 "Readback Thermal Meter = 0x%x pre thermal meter 0x%x eeprom_thermal meter 0x%x\n",
+		 thermalvalue,
+		 rtlpriv->dm.thermalvalue, rtlefuse->eeprom_thermalmeter);
 
 	if (thermalvalue) {
 		rtlpriv->dm.thermalvalue = thermalvalue;
@@ -282,11 +282,11 @@ static void _rtl92s_dm_refresh_rateadaptive_mask(struct ieee80211_hw *hw)
 		}
 
 		if (ra->pre_ratr_state != ra->ratr_state) {
-			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD, ("RSSI = %ld "
-				"RSSI_LEVEL = %d PreState = %d, CurState = %d\n",
-				rtlpriv->dm.undecorated_smoothed_pwdb,
-				ra->ratr_state,
-				ra->pre_ratr_state, ra->ratr_state));
+			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
+				 "RSSI = %ld RSSI_LEVEL = %d PreState = %d, CurState = %d\n",
+				 rtlpriv->dm.undecorated_smoothed_pwdb,
+				 ra->ratr_state,
+				 ra->pre_ratr_state, ra->ratr_state);
 
 			rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
 							   ra->ratr_state);
@@ -586,7 +586,7 @@ static void _rtl92s_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
-			 ("Not connected to any\n"));
+			 "Not connected to any\n");
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TX_HIGHPWR_LEVEL_NORMAL;
 
@@ -599,22 +599,22 @@ static void _rtl92s_dm_dynamic_txpower(struct ieee80211_hw *hw)
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("AP Client PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "AP Client PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		} else {
 			undecorated_smoothed_pwdb =
 			    rtlpriv->dm.undecorated_smoothed_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("STA Default Port PWDB = 0x%lx\n",
-				  undecorated_smoothed_pwdb));
+				 "STA Default Port PWDB = 0x%lx\n",
+				 undecorated_smoothed_pwdb);
 		}
 	} else {
 		undecorated_smoothed_pwdb =
 		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("AP Ext Port PWDB = 0x%lx\n",
-			  undecorated_smoothed_pwdb));
+			 "AP Ext Port PWDB = 0x%lx\n",
+			 undecorated_smoothed_pwdb);
 	}
 
 	txpwr_threshold_lv2 = TX_POWER_NEAR_FIELD_THRESH_LVL2;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
index 6f91a14..311768d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/fw.c
@@ -66,7 +66,7 @@ static bool _rtl92s_firmware_enable_cpu(struct ieee80211_hw *hw)
 		cpustatus = rtl_read_byte(rtlpriv, TCR);
 		if (cpustatus & IMEM_RDY) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				("IMEM Ready after CPU has refilled.\n"));
+				 "IMEM Ready after CPU has refilled\n");
 			break;
 		}
 
@@ -120,9 +120,8 @@ static u8 _rtl92s_firmware_header_map_rftype(struct ieee80211_hw *hw)
 		return 0x22;
 		break;
 	default:
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-			 ("Unknown RF type(%x)\n",
-			 rtlphy->rf_type));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "Unknown RF type(%x)\n",
+			 rtlphy->rf_type);
 		break;
 	}
 	return 0x22;
@@ -177,7 +176,7 @@ static bool _rtl92s_firmware_downloadcode(struct ieee80211_hw *hw,
 
 	if (buffer_len >= MAX_FIRMWARE_CODE_SIZE) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			("Size over FIRMWARE_CODE_SIZE!\n"));
+			 "Size over FIRMWARE_CODE_SIZE!\n");
 
 		return false;
 	}
@@ -229,8 +228,8 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 	short pollingcnt = 1000;
 	bool rtstatus = true;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("LoadStaus(%d)\n",
-		 loadfw_status));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "LoadStaus(%d)\n", loadfw_status);
 
 	firmware->fwstatus = (enum fw_status)loadfw_status;
 
@@ -246,8 +245,8 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 
 		if (!(cpustatus & IMEM_CHK_RPT) || (pollingcnt <= 0)) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("FW_STATUS_LOAD_IMEM"
-				 " FAIL CPU, Status=%x\r\n", cpustatus));
+				 "FW_STATUS_LOAD_IMEM FAIL CPU, Status=%x\n",
+				 cpustatus);
 			goto status_check_fail;
 		}
 		break;
@@ -264,8 +263,8 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 
 		if (!(cpustatus & EMEM_CHK_RPT) || (pollingcnt <= 0)) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("FW_STATUS_LOAD_EMEM"
-				 " FAIL CPU, Status=%x\r\n", cpustatus));
+				 "FW_STATUS_LOAD_EMEM FAIL CPU, Status=%x\n",
+				 cpustatus);
 			goto status_check_fail;
 		}
 
@@ -273,7 +272,7 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 		rtstatus = _rtl92s_firmware_enable_cpu(hw);
 		if (rtstatus != true) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Enable CPU fail!\n"));
+				 "Enable CPU fail!\n");
 			goto status_check_fail;
 		}
 		break;
@@ -289,14 +288,14 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 
 		if (!(cpustatus & DMEM_CODE_DONE) || (pollingcnt <= 0)) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Polling  DMEM code done"
-				 " fail ! cpustatus(%#x)\n", cpustatus));
+				 "Polling DMEM code done fail ! cpustatus(%#x)\n",
+				 cpustatus);
 			goto status_check_fail;
 		}
 
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("DMEM code download success,"
-			" cpustatus(%#x)\n", cpustatus));
+			 "DMEM code download success, cpustatus(%#x)\n",
+			 cpustatus);
 
 		/* Prevent Delay too much and being scheduled out */
 		/* Polling Load Firmware ready */
@@ -309,14 +308,14 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 		} while (pollingcnt--);
 
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("Polling Load Firmware ready,"
-			" cpustatus(%x)\n",	cpustatus));
+			 "Polling Load Firmware ready, cpustatus(%x)\n",
+			 cpustatus);
 
 		if (((cpustatus & LOAD_FW_READY) != LOAD_FW_READY) ||
 		    (pollingcnt <= 0)) {
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Polling Load Firmware"
-				" ready fail ! cpustatus(%x)\n", cpustatus));
+				 "Polling Load Firmware ready fail ! cpustatus(%x)\n",
+				 cpustatus);
 			goto status_check_fail;
 		}
 
@@ -330,7 +329,7 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 				RCR_APP_ICV | RCR_APP_MIC));
 
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			 ("Current RCR settings(%#x)\n", tmpu4b));
+			 "Current RCR settings(%#x)\n", tmpu4b);
 
 		/* Set to normal mode. */
 		rtl_write_byte(rtlpriv, LBKMD_SEL, LBK_NORMAL);
@@ -338,14 +337,15 @@ static bool _rtl92s_firmware_checkready(struct ieee80211_hw *hw,
 
 	default:
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-			 ("Unknown status check!\n"));
+			 "Unknown status check!\n");
 		rtstatus = false;
 		break;
 	}
 
 status_check_fail:
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("loadfw_status(%d), "
-		 "rtstatus(%x)\n", loadfw_status, rtstatus));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "loadfw_status(%d), rtstatus(%x)\n",
+		 loadfw_status, rtstatus);
 	return rtstatus;
 }
 
@@ -376,17 +376,17 @@ int rtl92s_download_fw(struct ieee80211_hw *hw)
 	firmware->firmwareversion =  byte(pfwheader->version, 0);
 	firmware->pfwheader->fwpriv.hci_sel = 1;/* pcie */
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("signature:%x, version:"
-		 "%x, size:%x,"
-		 "imemsize:%x, sram size:%x\n", pfwheader->signature,
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "signature:%x, version:%x, size:%x, imemsize:%x, sram size:%x\n",
+		 pfwheader->signature,
 		 pfwheader->version, pfwheader->dmem_size,
-		 pfwheader->img_imem_size, pfwheader->img_sram_size));
+		 pfwheader->img_imem_size, pfwheader->img_sram_size);
 
 	/* 2. Retrieve IMEM image. */
 	if ((pfwheader->img_imem_size == 0) || (pfwheader->img_imem_size >
 	    sizeof(firmware->fw_imem))) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			("memory for data image is less than IMEM required\n"));
+			 "memory for data image is less than IMEM required\n");
 		goto fail;
 	} else {
 		puc_mappedfile += fwhdr_size;
@@ -399,7 +399,7 @@ int rtl92s_download_fw(struct ieee80211_hw *hw)
 	/* 3. Retriecve EMEM image. */
 	if (pfwheader->img_sram_size > sizeof(firmware->fw_emem)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			("memory for data image is less than EMEM required\n"));
+			 "memory for data image is less than EMEM required\n");
 		goto fail;
 	} else {
 		puc_mappedfile += firmware->fw_imem_len;
@@ -434,7 +434,7 @@ int rtl92s_download_fw(struct ieee80211_hw *hw)
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-					("Unexpected Download step!!\n"));
+				 "Unexpected Download step!!\n");
 			goto fail;
 			break;
 		}
@@ -444,14 +444,14 @@ int rtl92s_download_fw(struct ieee80211_hw *hw)
 				ul_filelength);
 
 		if (rtstatus != true) {
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("fail!\n"));
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "fail!\n");
 			goto fail;
 		}
 
 		/* <3> Check whether load FW process is ready */
 		rtstatus = _rtl92s_firmware_checkready(hw, fwstatus);
 		if (rtstatus != true) {
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("fail!\n"));
+			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "fail!\n");
 			goto fail;
 		}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index f9ba077..dffcafe 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -80,8 +80,8 @@ void rtl92se_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	default: {
-			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
+			 "switch case not processed\n");
 			break;
 		}
 	}
@@ -140,7 +140,7 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			u8 e_aci;
 
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("HW_VAR_SLOT_TIME %x\n", val[0]));
+				 "HW_VAR_SLOT_TIME %x\n", val[0]);
 
 			rtl_write_byte(rtlpriv, SLOT_TIME, val[0]);
 
@@ -185,8 +185,8 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				*val = min_spacing_to_set;
 
 				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-					 ("Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
-					  mac->min_space_cfg));
+					 "Set HW_VAR_AMPDU_MIN_SPACE: %#x\n",
+					 mac->min_space_cfg);
 
 				rtl_write_byte(rtlpriv, AMPDU_MIN_SPACE,
 					       mac->min_space_cfg);
@@ -201,8 +201,8 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			mac->min_space_cfg |= (density_to_set << 3);
 
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-				 ("Set HW_VAR_SHORTGI_DENSITY: %#x\n",
-				  mac->min_space_cfg));
+				 "Set HW_VAR_SHORTGI_DENSITY: %#x\n",
+				 mac->min_space_cfg);
 
 			rtl_write_byte(rtlpriv, AMPDU_MIN_SPACE,
 				       mac->min_space_cfg);
@@ -244,8 +244,8 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				rtl_write_byte(rtlpriv, AGGLEN_LMT_H, regtoset);
 
 				RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
-					 ("Set HW_VAR_AMPDU_FACTOR: %#x\n",
-					  factor_toset));
+					 "Set HW_VAR_AMPDU_FACTOR: %#x\n",
+					 factor_toset);
 			}
 			break;
 		}
@@ -282,8 +282,8 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-						 ("HW_VAR_ACM_CTRL acm set "
-						  "failed: eACI is %d\n", acm));
+						 "HW_VAR_ACM_CTRL acm set failed: eACI is %d\n",
+						 acm);
 					break;
 				}
 			} else {
@@ -299,13 +299,13 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 					break;
 				default:
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-						 ("switch case not process\n"));
+						 "switch case not processed\n");
 					break;
 				}
 			}
 
 			RT_TRACE(rtlpriv, COMP_QOS, DBG_TRACE,
-				 ("HW_VAR_ACM_CTRL Write 0x%X\n", acm_ctrl));
+				 "HW_VAR_ACM_CTRL Write 0x%X\n", acm_ctrl);
 			rtl_write_byte(rtlpriv, AcmHwCtrl, acm_ctrl);
 			break;
 		}
@@ -404,7 +404,7 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 
@@ -415,14 +415,14 @@ void rtl92se_enable_hw_security_config(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 sec_reg_value = 0x0;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("PairwiseEncAlgorithm = %d "
-		 "GroupEncAlgorithm = %d\n",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "PairwiseEncAlgorithm = %d GroupEncAlgorithm = %d\n",
 		 rtlpriv->sec.pairwise_enc_algorithm,
-		 rtlpriv->sec.group_enc_algorithm));
+		 rtlpriv->sec.group_enc_algorithm);
 
 	if (rtlpriv->cfg->mod_params->sw_crypto || rtlpriv->sec.use_sw_sec) {
 		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-			 ("not open hw encryption\n"));
+			 "not open hw encryption\n");
 		return;
 	}
 
@@ -433,8 +433,8 @@ void rtl92se_enable_hw_security_config(struct ieee80211_hw *hw)
 		sec_reg_value |= SCR_RXUSEDK;
 	}
 
-	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, ("The SECR-value %x\n",
-			sec_reg_value));
+	RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD, "The SECR-value %x\n",
+		 sec_reg_value);
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_WPA_CONFIG, &sec_reg_value);
 
@@ -718,8 +718,8 @@ static void _rtl92se_macconfig_before_fwdownload(struct ieee80211_hw *hw)
 
 	if (pollingcnt <= 0) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Polling TXDMA_INIT_VALUE "
-			 "timeout!! Current TCR(%#x)\n", tmpu1b));
+			 "Polling TXDMA_INIT_VALUE timeout!! Current TCR(%#x)\n",
+			 tmpu1b);
 		tmpu1b = rtl_read_byte(rtlpriv, CMDR);
 		rtl_write_byte(rtlpriv, CMDR, tmpu1b & (~TXDMA_EN));
 		udelay(2);
@@ -870,10 +870,10 @@ static void _rtl92se_macconfig_after_fwdownload(struct ieee80211_hw *hw)
 
 		/* Change Program timing */
 		rtl_write_byte(rtlpriv, REG_EFUSE_CTRL + 3, 0x72);
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("EFUSE CONFIG OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "EFUSE CONFIG OK\n");
 	}
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("OK\n"));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "OK\n");
 
 }
 
@@ -951,9 +951,7 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 	rtstatus = rtl92s_download_fw(hw);
 	if (!rtstatus) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("Failed to download FW. "
-			 "Init HW without FW now.., Please copy FW into"
-			 "/lib/firmware/rtlwifi\n"));
+			 "Failed to download FW. Init HW without FW now... Please copy FW into /lib/firmware/rtlwifi\n");
 		rtlhal->fw_ready = false;
 	} else {
 		rtlhal->fw_ready = true;
@@ -968,7 +966,7 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 
 	/* 3. Initialize MAC/PHY Config by MACPHY_reg.txt */
 	if (rtl92s_phy_mac_config(hw) != true) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("MAC Config failed\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "MAC Config failed\n");
 		return rtstatus;
 	}
 
@@ -978,7 +976,7 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 
 	/* 4. Initialize BB After MAC Config PHY_reg.txt, AGC_Tab.txt */
 	if (rtl92s_phy_bb_config(hw) != true) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, ("BB Config failed\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG, "BB Config failed\n");
 		return rtstatus;
 	}
 
@@ -1014,7 +1012,7 @@ int rtl92se_hw_init(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, RF_CTRL, 0x07);
 
 	if (rtl92s_phy_rf_config(hw) != true) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("RF Config failed\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "RF Config failed\n");
 		return rtstatus;
 	}
 
@@ -1129,26 +1127,26 @@ static int _rtl92se_set_media_status(struct ieee80211_hw *hw,
 	case NL80211_IFTYPE_UNSPECIFIED:
 		bt_msr |= (MSR_LINK_NONE << MSR_LINK_SHIFT);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to NO LINK!\n"));
+			 "Set Network type to NO LINK!\n");
 		break;
 	case NL80211_IFTYPE_ADHOC:
 		bt_msr |= (MSR_LINK_ADHOC << MSR_LINK_SHIFT);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to Ad Hoc!\n"));
+			 "Set Network type to Ad Hoc!\n");
 		break;
 	case NL80211_IFTYPE_STATION:
 		bt_msr |= (MSR_LINK_MANAGED << MSR_LINK_SHIFT);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to STA!\n"));
+			 "Set Network type to STA!\n");
 		break;
 	case NL80211_IFTYPE_AP:
 		bt_msr |= (MSR_LINK_MASTER << MSR_LINK_SHIFT);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
-			 ("Set Network type to AP!\n"));
+			 "Set Network type to AP!\n");
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Network type %d not support!\n", type));
+			 "Network type %d not supported!\n", type);
 		return 1;
 		break;
 
@@ -1583,8 +1581,8 @@ void rtl92se_update_interrupt_mask(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 
-	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD,
-		 ("add_msr:%x, rm_msr:%x\n", add_msr, rm_msr));
+	RT_TRACE(rtlpriv, COMP_INTR, DBG_LOUD, "add_msr:%x, rm_msr:%x\n",
+		 add_msr, rm_msr);
 
 	if (add_msr)
 		rtlpci->irq_mask[0] |= add_msr;
@@ -1627,7 +1625,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 
 	if (rtlefuse->epromtype == EEPROM_93C46) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("RTL819X Not boot from eeprom, check it !!"));
+			 "RTL819X Not boot from eeprom, check it !!\n");
 	} else if (rtlefuse->epromtype == EEPROM_BOOT_EFUSE) {
 		rtl_efuse_shadow_map_update(hw);
 
@@ -1642,10 +1640,10 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	eeprom_id = *((u16 *)&hwinfo[0]);
 	if (eeprom_id != RTL8190_EEPROM_ID) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-			 ("EEPROM ID(%#x) is invalid!!\n", eeprom_id));
+			 "EEPROM ID(%#x) is invalid!!\n", eeprom_id);
 		rtlefuse->autoload_failflag = true;
 	} else {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
 	}
 
@@ -1663,15 +1661,15 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->eeprom_version = *(u16 *)&hwinfo[EEPROM_VERSION];
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			("EEPROMId = 0x%4x\n", eeprom_id));
+		 "EEPROMId = 0x%4x\n", eeprom_id);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			("EEPROM VID = 0x%4x\n", rtlefuse->eeprom_vid));
+		 "EEPROM VID = 0x%4x\n", rtlefuse->eeprom_vid);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			("EEPROM DID = 0x%4x\n", rtlefuse->eeprom_did));
+		 "EEPROM DID = 0x%4x\n", rtlefuse->eeprom_did);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			("EEPROM SVID = 0x%4x\n", rtlefuse->eeprom_svid));
+		 "EEPROM SVID = 0x%4x\n", rtlefuse->eeprom_svid);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-			("EEPROM SMID = 0x%4x\n", rtlefuse->eeprom_smid));
+		 "EEPROM SMID = 0x%4x\n", rtlefuse->eeprom_smid);
 
 	for (i = 0; i < 6; i += 2) {
 		usvalue = *(u16 *)&hwinfo[EEPROM_MAC_ADDR + i];
@@ -1681,8 +1679,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	for (i = 0; i < 6; i++)
 		rtl_write_byte(rtlpriv, MACIDR0 + i, rtlefuse->dev_addr[i]);
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 ("%pM\n", rtlefuse->dev_addr));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "%pM\n", rtlefuse->dev_addr);
 
 	/* Get Tx Power Level by Channel */
 	/* Read Tx power of Channel 1 ~ 14 from EEPROM. */
@@ -1937,14 +1934,14 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 		if (!(tempval & BIT(0))) {
 			rtlefuse->b1x1_recvcombine = true;
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-				("RF_TYPE=1T2R but only 1SS\n"));
+				 "RF_TYPE=1T2R but only 1SS\n");
 		}
 	}
 	rtlefuse->b1ss_support = rtlefuse->b1x1_recvcombine;
 	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMID];
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("EEPROM Customer ID: 0x%2x",
-			rtlefuse->eeprom_oemid));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "EEPROM Customer ID: 0x%2x",
+		 rtlefuse->eeprom_oemid);
 
 	/* set channel paln to world wide 13 */
 	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
@@ -1959,19 +1956,19 @@ void rtl92se_read_eeprom_info(struct ieee80211_hw *hw)
 	tmp_u1b = rtl_read_byte(rtlpriv, EPROM_CMD);
 
 	if (tmp_u1b & BIT(4)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Boot from EEPROM\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EEPROM\n");
 		rtlefuse->epromtype = EEPROM_93C46;
 	} else {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("Boot from EFUSE\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "Boot from EFUSE\n");
 		rtlefuse->epromtype = EEPROM_BOOT_EFUSE;
 	}
 
 	if (tmp_u1b & BIT(5)) {
-		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Autoload OK\n"));
+		RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Autoload OK\n");
 		rtlefuse->autoload_failflag = false;
 		_rtl92se_read_adapter_info(hw);
 	} else {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Autoload ERR!!\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Autoload ERR!!\n");
 		rtlefuse->autoload_failflag = true;
 	}
 }
@@ -2071,8 +2068,8 @@ static void rtl92se_update_hal_rate_table(struct ieee80211_hw *hw,
 	else
 		rtl92s_phy_set_fw_cmd(hw, FW_CMD_RA_REFRESH_BG);
 
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
-		 ("%x\n", rtl_read_dword(rtlpriv, ARFR0)));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
+		 rtl_read_dword(rtlpriv, ARFR0));
 }
 
 static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
@@ -2224,8 +2221,8 @@ static void rtl92se_update_hal_rate_mask(struct ieee80211_hw *hw,
 
 	mask |= (bmulticast ? 1 : 0) << 9 | (macid & 0x1f) << 4 | (band & 0xf);
 
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_TRACE, ("mask = %x, bitmap = %x\n",
-			mask, ratr_bitmap));
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_TRACE, "mask = %x, bitmap = %x\n",
+		 mask, ratr_bitmap);
 	rtl_write_dword(rtlpriv, 0x2c4, ratr_bitmap);
 	rtl_write_dword(rtlpriv, WFM5, (FW_RA_UPDATE_MASK | (mask << 8)));
 
@@ -2301,14 +2298,14 @@ bool rtl92se_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 *valid)
 
 	if ((ppsc->hwradiooff) && (rfpwr_toset == ERFON)) {
 		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 ("RFKILL-HW Radio ON, RF ON\n"));
+			 "RFKILL-HW Radio ON, RF ON\n");
 
 		rfpwr_toset = ERFON;
 		ppsc->hwradiooff = false;
 		actuallyset = true;
 	} else if ((ppsc->hwradiooff == false) && (rfpwr_toset == ERFOFF)) {
-		RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-			 ("RFKILL-HW Radio OFF, RF OFF\n"));
+		RT_TRACE(rtlpriv, COMP_RF,
+			 DBG_DMESG, "RFKILL-HW Radio OFF, RF OFF\n");
 
 		rfpwr_toset = ERFOFF;
 		ppsc->hwradiooff = true;
@@ -2372,7 +2369,7 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 		u8 cam_offset = 0;
 		u8 clear_number = 5;
 
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, ("clear_all\n"));
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "clear_all\n");
 
 		for (idx = 0; idx < clear_number; idx++) {
 			rtl_cam_mark_invalid(hw, cam_offset + idx);
@@ -2401,7 +2398,7 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-					("switch case not process\n"));
+				 "switch case not processed\n");
 			enc_algo = CAM_TKIP;
 			break;
 		}
@@ -2419,9 +2416,8 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 								 p_macaddr);
 					if (entry_id >=  TOTAL_CAM_ENTRY) {
 						RT_TRACE(rtlpriv,
-						   COMP_SEC, DBG_EMERG,
-						   ("Can not find free hw"
-						   " security cam entry\n"));
+							 COMP_SEC, DBG_EMERG,
+							 "Can not find free hw security cam entry\n");
 						return;
 					}
 				} else {
@@ -2435,30 +2431,31 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 
 		if (rtlpriv->sec.key_len[key_index] == 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("delete one entry, entry_id is %d\n",
-				 entry_id));
+				 "delete one entry, entry_id is %d\n",
+				 entry_id);
 			if (mac->opmode == NL80211_IFTYPE_AP)
 				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY length is %d\n",
-				  rtlpriv->sec.key_len[PAIRWISE_KEYIDX]));
+				 "The insert KEY length is %d\n",
+				 rtlpriv->sec.key_len[PAIRWISE_KEYIDX]);
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
-				 ("The insert KEY  is %x %x\n",
-				  rtlpriv->sec.key_buf[0][0],
-				  rtlpriv->sec.key_buf[0][1]));
+				 "The insert KEY is %x %x\n",
+				 rtlpriv->sec.key_buf[0][0],
+				 rtlpriv->sec.key_buf[0][1]);
 
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-				 ("add one entry\n"));
+				 "add one entry\n");
 			if (is_pairwise) {
 				RT_PRINT_DATA(rtlpriv, COMP_SEC, DBG_LOUD,
-				      "Pairwise Key content",
-				       rtlpriv->sec.pairwise_key,
-				       rtlpriv->sec.key_len[PAIRWISE_KEYIDX]);
+					      "Pairwise Key content",
+					      rtlpriv->sec.pairwise_key,
+					      rtlpriv->sec.
+					      key_len[PAIRWISE_KEYIDX]);
 
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set Pairwiase key\n"));
+					 "set Pairwise key\n");
 
 				rtl_cam_add_one_entry(hw, macaddr, key_index,
 					entry_id, enc_algo,
@@ -2466,7 +2463,7 @@ void rtl92se_set_key(struct ieee80211_hw *hw, u32 key_index, u8 *p_macaddr,
 					rtlpriv->sec.key_buf[key_index]);
 			} else {
 				RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
-					 ("set group key\n"));
+					 "set group key\n");
 
 				if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 					rtl_cam_add_one_entry(hw,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/led.c b/drivers/net/wireless/rtlwifi/rtl8192se/led.c
index e3fe7c9..1a6b0ca 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/led.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/led.c
@@ -52,8 +52,8 @@ void rtl92se_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 	u8 ledcfg;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", LEDCFG, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 LEDCFG, pled->ledpin);
 
 	ledcfg = rtl_read_byte(rtlpriv, LEDCFG);
 
@@ -68,7 +68,7 @@ void rtl92se_sw_led_on(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = true;
@@ -80,8 +80,8 @@ void rtl92se_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	u8 ledcfg;
 
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD,
-		 ("LedAddr:%X ledpin=%d\n", LEDCFG, pled->ledpin));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "LedAddr:%X ledpin=%d\n",
+		 LEDCFG, pled->ledpin);
 
 	ledcfg = rtl_read_byte(rtlpriv, LEDCFG);
 
@@ -101,7 +101,7 @@ void rtl92se_sw_led_off(struct ieee80211_hw *hw, struct rtl_led *pled)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		break;
 	}
 	pled->ledon = false;
@@ -141,8 +141,7 @@ void rtl92se_led_control(struct ieee80211_hw *hw, enum led_ctl_mode ledaction)
 	    ledaction == LED_CTL_POWER_ON)) {
 		return;
 	}
-	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, ("ledaction %d,\n",
-		 ledaction));
+	RT_TRACE(rtlpriv, COMP_LED, DBG_LOUD, "ledaction %d\n", ledaction);
 
 	_rtl92se_sw_led_control(hw, ledaction);
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index f10ac1a..ec5520e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -58,16 +58,15 @@ u32 rtl92s_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 returnvalue = 0, originalvalue, bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x)\n",
-			regaddr, bitmask));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "regaddr(%#x), bitmask(%#x)\n",
+		 regaddr, bitmask);
 
 	originalvalue = rtl_read_dword(rtlpriv, regaddr);
 	bitshift = _rtl92s_phy_calculate_bit_shift(bitmask);
 	returnvalue = (originalvalue & bitmask) >> bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
-		 ("BBR MASK=0x%x Addr[0x%x]=0x%x\n",
-		 bitmask, regaddr, originalvalue));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "BBR MASK=0x%x Addr[0x%x]=0x%x\n",
+		 bitmask, regaddr, originalvalue);
 
 	return returnvalue;
 
@@ -79,8 +78,9 @@ void rtl92s_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 originalvalue, bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x),"
-			" data(%#x)\n", regaddr, bitmask, data));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
 
 	if (bitmask != MASKDWORD) {
 		originalvalue = rtl_read_dword(rtlpriv, regaddr);
@@ -90,8 +90,9 @@ void rtl92s_phy_set_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask,
 
 	rtl_write_dword(rtlpriv, regaddr, data);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x),"
-			" data(%#x)\n",	regaddr, bitmask, data));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x)\n",
+		 regaddr, bitmask, data);
 
 }
 
@@ -149,8 +150,8 @@ static u32 _rtl92s_phy_rf_serial_read(struct ieee80211_hw *hw,
 	retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
 				 BLSSI_READBACK_DATA);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("RFR-%d Addr[0x%x]=0x%x\n",
-		 rfpath, pphyreg->rflssi_readback, retvalue));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rflssi_readback, retvalue);
 
 	return retvalue;
 
@@ -172,8 +173,8 @@ static void _rtl92s_phy_rf_serial_write(struct ieee80211_hw *hw,
 	data_and_addr = ((newoffset << 20) | (data & 0x000fffff)) & 0x0fffffff;
 	rtl_set_bbreg(hw, pphyreg->rf3wire_offset, MASKDWORD, data_and_addr);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("RFW-%d Addr[0x%x]=0x%x\n",
-		 rfpath, pphyreg->rf3wire_offset, data_and_addr));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFW-%d Addr[0x%x]=0x%x\n",
+		 rfpath, pphyreg->rf3wire_offset, data_and_addr);
 }
 
 
@@ -183,8 +184,9 @@ u32 rtl92s_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u32 original_value, readback_value, bitshift;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), rfpath(%#x), "
-		 "bitmask(%#x)\n", regaddr, rfpath, bitmask));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x)\n",
+		 regaddr, rfpath, bitmask);
 
 	spin_lock(&rtlpriv->locks.rf_lock);
 
@@ -195,9 +197,9 @@ u32 rtl92s_phy_query_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 
 	spin_unlock(&rtlpriv->locks.rf_lock);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), rfpath(%#x), "
-		 "bitmask(%#x), original_value(%#x)\n", regaddr, rfpath,
-		 bitmask, original_value));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), rfpath(%#x), bitmask(%#x), original_value(%#x)\n",
+		 regaddr, rfpath, bitmask, original_value);
 
 	return readback_value;
 }
@@ -212,8 +214,9 @@ void rtl92s_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 	if (!((rtlphy->rf_pathmap >> rfpath) & 0x1))
 		return;
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x),"
-		 " data(%#x), rfpath(%#x)\n", regaddr, bitmask, data, rfpath));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 
 	spin_lock(&rtlpriv->locks.rf_lock);
 
@@ -228,8 +231,9 @@ void rtl92s_phy_set_rf_reg(struct ieee80211_hw *hw, enum radio_path rfpath,
 
 	spin_unlock(&rtlpriv->locks.rf_lock);
 
-	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, ("regaddr(%#x), bitmask(%#x), "
-		 "data(%#x), rfpath(%#x)\n", regaddr, bitmask, data, rfpath));
+	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE,
+		 "regaddr(%#x), bitmask(%#x), data(%#x), rfpath(%#x)\n",
+		 regaddr, bitmask, data, rfpath);
 
 }
 
@@ -249,7 +253,7 @@ void rtl92s_phy_scan_operation_backup(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("Unknown operation.\n"));
+				 "Unknown operation\n");
 			break;
 		}
 	}
@@ -264,9 +268,9 @@ void rtl92s_phy_set_bw_mode(struct ieee80211_hw *hw,
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	u8 reg_bw_opmode;
 
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("Switch to %s bandwidth\n",
-		  rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
-		  "20MHz" : "40MHz"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "Switch to %s bandwidth\n",
+		 rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20 ?
+		 "20MHz" : "40MHz");
 
 	if (rtlphy->set_bwmode_inprogress)
 		return;
@@ -290,8 +294,7 @@ void rtl92s_phy_set_bw_mode(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n",
-			 rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
 
@@ -316,13 +319,13 @@ void rtl92s_phy_set_bw_mode(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n", rtlphy->current_chan_bw));
+			 "unknown bandwidth: %#X\n", rtlphy->current_chan_bw);
 		break;
 	}
 
 	rtl92s_phy_rf6052_set_bandwidth(hw, rtlphy->current_chan_bw);
 	rtlphy->set_bwmode_inprogress = false;
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("<==\n"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
 }
 
 static bool _rtl92s_phy_set_sw_chnl_cmdarray(struct swchnlcmd *cmdtable,
@@ -438,7 +441,7 @@ static bool _rtl92s_phy_sw_chnl_step_by_step(struct ieee80211_hw *hw,
 			break;
 		default:
 			RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-				 ("switch case not process\n"));
+				 "switch case not processed\n");
 			break;
 		}
 
@@ -458,9 +461,8 @@ u8 rtl92s_phy_sw_chnl(struct ieee80211_hw *hw)
 	u32 delay;
 	bool ret;
 
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE,
-		 ("switch to channel%d\n",
-		 rtlphy->current_channel));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "switch to channel%d\n",
+		 rtlphy->current_channel);
 
 	if (rtlphy->sw_chnl_inprogress)
 		return 0;
@@ -496,7 +498,7 @@ u8 rtl92s_phy_sw_chnl(struct ieee80211_hw *hw)
 
 	rtlphy->sw_chnl_inprogress = false;
 
-	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, ("<==\n"));
+	RT_TRACE(rtlpriv, COMP_SCAN, DBG_TRACE, "<==\n");
 
 	return 1;
 }
@@ -556,7 +558,7 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 				do {
 					InitializeCount++;
 					RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-						 ("IPS Set eRf nic enable\n"));
+						 "IPS Set eRf nic enable\n");
 					rtstatus = rtl_ps_enable_nic(hw);
 				} while ((rtstatus != true) &&
 					 (InitializeCount < 10));
@@ -565,11 +567,11 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 						  RT_RF_OFF_LEVL_HALT_NIC);
 			} else {
 				RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-					 ("awake, sleeped:%d ms "
-					"state_inap:%x\n",
-					jiffies_to_msecs(jiffies -
-					ppsc->last_sleep_jiffies),
-					rtlpriv->psc.state_inap));
+					 "awake, sleeped:%d ms state_inap:%x\n",
+					 jiffies_to_msecs(jiffies -
+							  ppsc->
+							  last_sleep_jiffies),
+					 rtlpriv->psc.state_inap);
 				ppsc->last_awake_jiffies = jiffies;
 				rtl_write_word(rtlpriv, CMDR, 0x37FC);
 				rtl_write_byte(rtlpriv, TXPAUSE, 0x00);
@@ -587,7 +589,7 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 	case ERFOFF:{
 			if (ppsc->reg_rfps_level & RT_RF_OFF_LEVL_HALT_NIC) {
 				RT_TRACE(rtlpriv, COMP_RF, DBG_DMESG,
-					 ("IPS Set eRf nic disable\n"));
+					 "IPS Set eRf nic disable\n");
 				rtl_ps_disable_nic(hw);
 				RT_SET_PS_LEVEL(ppsc, RT_RF_OFF_LEVL_HALT_NIC);
 			} else {
@@ -613,11 +615,9 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 					continue;
 				} else {
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-						 ("eRf Off/Sleep: "
-						 "%d times TcbBusyQueue[%d] = "
-						 "%d before doze!\n",
-						 (i + 1), queue_id,
-						 skb_queue_len(&ring->queue)));
+						 "eRf Off/Sleep: %d times TcbBusyQueue[%d] = %d before doze!\n",
+						 i + 1, queue_id,
+						 skb_queue_len(&ring->queue));
 
 					udelay(10);
 					i++;
@@ -625,31 +625,30 @@ bool rtl92s_phy_set_rf_power_state(struct ieee80211_hw *hw,
 
 				if (i >= MAX_DOZE_WAITING_TIMES_9x) {
 					RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
-						 ("\nERFOFF: %d times"
-						 "TcbBusyQueue[%d] = %d !\n",
+						 "ERFOFF: %d times TcbBusyQueue[%d] = %d !\n",
 						 MAX_DOZE_WAITING_TIMES_9x,
 						 queue_id,
-						 skb_queue_len(&ring->queue)));
+						 skb_queue_len(&ring->queue));
 					break;
 				}
 			}
 
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-				 ("Set ERFSLEEP awaked:%d ms\n",
+				 "Set ERFSLEEP awaked:%d ms\n",
 				 jiffies_to_msecs(jiffies -
-				 ppsc->last_awake_jiffies)));
+						  ppsc->last_awake_jiffies));
 
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_DMESG,
-				 ("sleep awaked:%d ms "
-				"state_inap:%x\n", jiffies_to_msecs(jiffies -
-				ppsc->last_awake_jiffies),
-				rtlpriv->psc.state_inap));
+				 "sleep awaked:%d ms state_inap:%x\n",
+				 jiffies_to_msecs(jiffies -
+						  ppsc->last_awake_jiffies),
+				 rtlpriv->psc.state_inap);
 			ppsc->last_sleep_jiffies = jiffies;
 			_rtl92se_phy_set_rf_sleep(hw);
 	    break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("switch case not process\n"));
+			 "switch case not processed\n");
 		bresult = false;
 		break;
 	}
@@ -995,7 +994,7 @@ static bool _rtl92s_phy_bb_config_parafile(struct ieee80211_hw *hw)
 
 	if (rtstatus != true) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-			 ("Write BB Reg Fail!!"));
+			 "Write BB Reg Fail!!\n");
 		goto phy_BB8190_Config_ParaFile_Fail;
 	}
 
@@ -1009,8 +1008,7 @@ static bool _rtl92s_phy_bb_config_parafile(struct ieee80211_hw *hw)
 	}
 	if (rtstatus != true) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-			 ("_rtl92s_phy_bb_config_parafile(): "
-			 "BB_PG Reg Fail!!"));
+			 "_rtl92s_phy_bb_config_parafile(): BB_PG Reg Fail!!\n");
 		goto phy_BB8190_Config_ParaFile_Fail;
 	}
 
@@ -1053,7 +1051,7 @@ u8 rtl92s_phy_config_rf(struct ieee80211_hw *hw, enum radio_path rfpath)
 		radio_b_tblen = RADIOB_ARRAYLENGTH;
 	}
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Radio No %x\n", rfpath));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "Radio No %x\n", rfpath);
 	rtstatus = true;
 
 	switch (rfpath) {
@@ -1175,11 +1173,11 @@ bool rtl92s_phy_bb_config(struct ieee80211_hw *hw)
 	    (rtlphy->rf_type == RF_2T2R && rf_num != 2) ||
 	    (rtlphy->rf_type == RF_2T2R_GREEN && rf_num != 2)) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-			 ("RF_Type(%x) does not match "
-			 "RF_Num(%x)!!\n", rtlphy->rf_type, rf_num));
+			 "RF_Type(%x) does not match RF_Num(%x)!!\n",
+			 rtlphy->rf_type, rf_num);
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-			 ("path1 0x%x, path2 0x%x, pathmap "
-			  "0x%x\n", path1, path2, pathmap));
+			 "path1 0x%x, path2 0x%x, pathmap 0x%x\n",
+			 path1, path2, pathmap);
 	}
 
 	return rtstatus;
@@ -1214,20 +1212,20 @@ void rtl92s_phy_get_hw_reg_originalvalue(struct ieee80211_hw *hw)
 			ROFDM0_XCAGCCORE1, MASKBYTE0);
 	rtlphy->default_initialgain[3] = rtl_get_bbreg(hw,
 			ROFDM0_XDAGCCORE1, MASKBYTE0);
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, ("Default initial gain "
-		 "(c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x)\n",
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
+		 "Default initial gain (c50=0x%x, c58=0x%x, c60=0x%x, c68=0x%x)\n",
 		 rtlphy->default_initialgain[0],
 		 rtlphy->default_initialgain[1],
 		 rtlphy->default_initialgain[2],
-		 rtlphy->default_initialgain[3]));
+		 rtlphy->default_initialgain[3]);
 
 	/* read framesync */
 	rtlphy->framesync = rtl_get_bbreg(hw, ROFDM0_RXDETECTOR3, MASKBYTE0);
 	rtlphy->framesync_c34 = rtl_get_bbreg(hw, ROFDM0_RXDETECTOR2,
 					      MASKDWORD);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
-		 ("Default framesync (0x%x) = 0x%x\n",
-		 ROFDM0_RXDETECTOR3, rtlphy->framesync));
+		 "Default framesync (0x%x) = 0x%x\n",
+		 ROFDM0_RXDETECTOR3, rtlphy->framesync);
 
 }
 
@@ -1287,10 +1285,9 @@ void rtl92s_phy_set_txpower(struct ieee80211_hw *hw, u8	channel)
 			&ofdmpowerLevel[0]);
 
 	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			("Channel-%d, cckPowerLevel (A / B) = "
-			"0x%x / 0x%x,   ofdmPowerLevel (A / B) = 0x%x / 0x%x\n",
-			channel, cckpowerlevel[0], cckpowerlevel[1],
-			ofdmpowerLevel[0], ofdmpowerLevel[1]));
+		 "Channel-%d, cckPowerLevel (A / B) = 0x%x / 0x%x, ofdmPowerLevel (A / B) = 0x%x / 0x%x\n",
+		 channel, cckpowerlevel[0], cckpowerlevel[1],
+		 ofdmpowerLevel[0], ofdmpowerLevel[1]);
 
 	_rtl92s_phy_ccxpower_indexcheck(hw, channel, &cckpowerlevel[0],
 			&ofdmpowerLevel[0]);
@@ -1316,7 +1313,7 @@ void rtl92s_phy_chk_fwcmd_iodone(struct ieee80211_hw *hw)
 	} while (--pollingcnt);
 
 	if (pollingcnt == 0)
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, ("Set FW Cmd fail!!\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Set FW Cmd fail!!\n");
 }
 
 
@@ -1345,20 +1342,17 @@ static void _rtl92s_phy_set_fwcmd_io(struct ieee80211_hw *hw)
 
 	switch (rtlhal->current_fwcmd_io) {
 	case FW_CMD_RA_RESET:
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_RA_RESET\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_RA_RESET\n");
 		rtl_write_dword(rtlpriv, WFM5, FW_RA_RESET);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
 	case FW_CMD_RA_ACTIVE:
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_RA_ACTIVE\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_RA_ACTIVE\n");
 		rtl_write_dword(rtlpriv, WFM5, FW_RA_ACTIVE);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
 	case FW_CMD_RA_REFRESH_N:
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_RA_REFRESH_N\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_RA_REFRESH_N\n");
 		input = FW_RA_REFRESH;
 		rtl_write_dword(rtlpriv, WFM5, input);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
@@ -1367,7 +1361,7 @@ static void _rtl92s_phy_set_fwcmd_io(struct ieee80211_hw *hw)
 		break;
 	case FW_CMD_RA_REFRESH_BG:
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_RA_REFRESH_BG\n"));
+			 "FW_CMD_RA_REFRESH_BG\n");
 		rtl_write_dword(rtlpriv, WFM5, FW_RA_REFRESH);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		rtl_write_dword(rtlpriv, WFM5, FW_RA_DISABLE_RSSI_MASK);
@@ -1375,21 +1369,20 @@ static void _rtl92s_phy_set_fwcmd_io(struct ieee80211_hw *hw)
 		break;
 	case FW_CMD_RA_REFRESH_N_COMB:
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_RA_REFRESH_N_COMB\n"));
+			 "FW_CMD_RA_REFRESH_N_COMB\n");
 		input = FW_RA_IOT_N_COMB;
 		rtl_write_dword(rtlpriv, WFM5, input);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
 	case FW_CMD_RA_REFRESH_BG_COMB:
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_RA_REFRESH_BG_COMB\n"));
+			 "FW_CMD_RA_REFRESH_BG_COMB\n");
 		input = FW_RA_IOT_BG_COMB;
 		rtl_write_dword(rtlpriv, WFM5, input);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
 	case FW_CMD_IQK_ENABLE:
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_IQK_ENABLE\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_IQK_ENABLE\n");
 		rtl_write_dword(rtlpriv, WFM5, FW_IQK_ENABLE);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
@@ -1424,8 +1417,7 @@ static void _rtl92s_phy_set_fwcmd_io(struct ieee80211_hw *hw)
 		rtl_set_bbreg(hw, RCCK0_CCA, MASKBYTE2, 0xcd);
 		break;
 	case FW_CMD_LPS_ENTER:
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_LPS_ENTER\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_LPS_ENTER\n");
 		current_aid = rtlpriv->mac80211.assoc_id;
 		rtl_write_dword(rtlpriv, WFM5, (FW_LPS_ENTER |
 				((current_aid | 0xc000) << 8)));
@@ -1434,20 +1426,18 @@ static void _rtl92s_phy_set_fwcmd_io(struct ieee80211_hw *hw)
 		 * turbo mode until driver leave LPS */
 		break;
 	case FW_CMD_LPS_LEAVE:
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_LPS_LEAVE\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_LPS_LEAVE\n");
 		rtl_write_dword(rtlpriv, WFM5, FW_LPS_LEAVE);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
 	case FW_CMD_ADD_A2_ENTRY:
-		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG,
-			 ("FW_CMD_ADD_A2_ENTRY\n"));
+		RT_TRACE(rtlpriv, COMP_CMD, DBG_DMESG, "FW_CMD_ADD_A2_ENTRY\n");
 		rtl_write_dword(rtlpriv, WFM5, FW_ADD_A2_ENTRY);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
 	case FW_CMD_CTRL_DM_BY_DRIVER:
 		RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-			 ("FW_CMD_CTRL_DM_BY_DRIVER\n"));
+			 "FW_CMD_CTRL_DM_BY_DRIVER\n");
 		rtl_write_dword(rtlpriv, WFM5, FW_CTRL_DM_BY_DRIVER);
 		rtl92s_phy_chk_fwcmd_iodone(hw);
 		break;
@@ -1472,8 +1462,8 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 	bool bPostProcessing = false;
 
 	RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-			("Set FW Cmd(%#x), set_fwcmd_inprogress(%d)\n",
-			fw_cmdio, rtlhal->set_fwcmd_inprogress));
+		 "Set FW Cmd(%#x), set_fwcmd_inprogress(%d)\n",
+		 fw_cmdio, rtlhal->set_fwcmd_inprogress);
 
 	do {
 		/* We re-map to combined FW CMD ones if firmware version */
@@ -1501,7 +1491,7 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 		 * DM map table in the future. */
 		switch (fw_cmdio) {
 		case FW_CMD_RA_INIT:
-			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, ("RA init!!\n"));
+			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD, "RA init!!\n");
 			fw_cmdmap |= FW_RA_INIT_CTL;
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
 			/* Clear control flag to sync with FW. */
@@ -1509,7 +1499,7 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 			break;
 		case FW_CMD_DIG_DISABLE:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("Set DIG disable!!\n"));
+				 "Set DIG disable!!\n");
 			fw_cmdmap &= ~FW_DIG_ENABLE_CTL;
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
 			break;
@@ -1517,14 +1507,14 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 		case FW_CMD_DIG_RESUME:
 			if (!(rtlpriv->dm.dm_flag & HAL_DM_DIG_DISABLE)) {
 				RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-					("Set DIG enable or resume!!\n"));
+					 "Set DIG enable or resume!!\n");
 				fw_cmdmap |= (FW_DIG_ENABLE_CTL | FW_SS_CTL);
 				FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
 			}
 			break;
 		case FW_CMD_DIG_HALT:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("Set DIG halt!!\n"));
+				 "Set DIG halt!!\n");
 			fw_cmdmap &= ~(FW_DIG_ENABLE_CTL | FW_SS_CTL);
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
 			break;
@@ -1540,9 +1530,8 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 				     (rtlefuse->thermalmeter[0] << 16));
 
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("Set TxPwr tracking!! "
-				 "FwCmdMap(%#x), FwParam(%#x)\n",
-				 fw_cmdmap, fw_param));
+				 "Set TxPwr tracking!! FwCmdMap(%#x), FwParam(%#x)\n",
+				 fw_cmdmap, fw_param);
 
 			FW_CMD_PARA_SET(rtlpriv, fw_param);
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
@@ -1563,9 +1552,8 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 			fw_param &= FW_RA_PARAM_CLR;
 
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("[FW CMD] [New Version] "
-				 "Set RA/IOT Comb in n mode!! FwCmdMap(%#x), "
-				 "FwParam(%#x)\n", fw_cmdmap, fw_param));
+				 "[FW CMD] [New Version] Set RA/IOT Comb in n mode!! FwCmdMap(%#x), FwParam(%#x)\n",
+				 fw_cmdmap, fw_param);
 
 			FW_CMD_PARA_SET(rtlpriv, fw_param);
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
@@ -1652,7 +1640,7 @@ bool rtl92s_phy_set_fw_cmd(struct ieee80211_hw *hw, enum fwcmd_iotype fw_cmdio)
 			break;
 		case FW_CMD_PAPE_CONTROL:
 			RT_TRACE(rtlpriv, COMP_CMD, DBG_LOUD,
-				 ("[FW CMD] Set PAPE Control\n"));
+				 "[FW CMD] Set PAPE Control\n");
 			fw_cmdmap &= ~FW_PAPE_CTL_BY_SW_HW;
 
 			FW_CMD_IO_SET(rtlpriv, fw_cmdmap);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
index 0ad50fe..8966b73 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
@@ -123,13 +123,13 @@ static void _rtl92s_get_powerbase(struct ieee80211_hw *hw, u8 *p_pwrlevel,
 	}
 
 	if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, ("40MHz finalpwr_idx "
-			"(A / B) = 0x%x / 0x%x\n", p_final_pwridx[0],
-			p_final_pwridx[1]));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "40MHz finalpwr_idx (A / B) = 0x%x / 0x%x\n",
+			 p_final_pwridx[0], p_final_pwridx[1]);
 	} else {
-		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, ("20MHz finalpwr_idx "
-			"(A / B) = 0x%x / 0x%x\n", p_final_pwridx[0],
-			 p_final_pwridx[1]));
+		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
+			 "20MHz finalpwr_idx (A / B) = 0x%x / 0x%x\n",
+			 p_final_pwridx[0], p_final_pwridx[1]);
 	}
 }
 
@@ -153,9 +153,8 @@ static void _rtl92s_set_antennadiff(struct ieee80211_hw *hw,
 			ant_pwr_diff = -8;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("Antenna Diff from RF-B "
-			"to RF-A = %d (0x%x)\n", ant_pwr_diff,
-			 ant_pwr_diff & 0xf));
+			 "Antenna Diff from RF-B to RF-A = %d (0x%x)\n",
+			 ant_pwr_diff, ant_pwr_diff & 0xf);
 
 		ant_pwr_diff &= 0xf;
 	}
@@ -172,9 +171,8 @@ static void _rtl92s_set_antennadiff(struct ieee80211_hw *hw,
 	rtl_set_bbreg(hw, RFPGA0_TXGAINSTAGE, (BXBTXAGC | BXCTXAGC | BXDTXAGC),
 		      u4reg_val);
 
-	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-		 ("Write BCD-Diff(0x%x) = 0x%x\n",
-		 RFPGA0_TXGAINSTAGE, u4reg_val));
+	RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD, "Write BCD-Diff(0x%x) = 0x%x\n",
+		 RFPGA0_TXGAINSTAGE, u4reg_val);
 }
 
 static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
@@ -201,8 +199,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 				((index < 2) ? pwrbase0 : pwrbase1);
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("RTK better performance, "
-			 "writeval = 0x%x\n", writeval));
+			 "RTK better performance, writeval = 0x%x\n", writeval);
 		break;
 	case 1:
 		/* Realtek regulatory increase power diff defined
@@ -211,8 +208,8 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 			writeval = ((index < 2) ? pwrbase0 : pwrbase1);
 
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("Realtek regulatory, "
-				 "40MHz, writeval = 0x%x\n", writeval));
+				 "Realtek regulatory, 40MHz, writeval = 0x%x\n",
+				 writeval);
 		} else {
 			if (rtlphy->pwrgroup_cnt == 1)
 				chnlgroup = 0;
@@ -234,16 +231,15 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 					pwrbase0 : pwrbase1);
 
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				 ("Realtek regulatory, "
-				 "20MHz, writeval = 0x%x\n", writeval));
+				 "Realtek regulatory, 20MHz, writeval = 0x%x\n",
+				 writeval);
 		}
 		break;
 	case 2:
 		/* Better regulatory don't increase any power diff */
 		writeval = ((index < 2) ? pwrbase0 : pwrbase1);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("Better regulatory, "
-			 "writeval = 0x%x\n", writeval));
+			 "Better regulatory, writeval = 0x%x\n", writeval);
 		break;
 	case 3:
 		/* Customer defined power diff. increase power diff
@@ -252,14 +248,14 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 
 		if (rtlphy->current_chan_bw == HT_CHANNEL_WIDTH_20_40) {
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				("customer's limit, 40MHz = 0x%x\n",
-				rtlefuse->pwrgroup_ht40
-				[RF90_PATH_A][chnl - 1]));
+				 "customer's limit, 40MHz = 0x%x\n",
+				 rtlefuse->pwrgroup_ht40
+				 [RF90_PATH_A][chnl - 1]);
 		} else {
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-				("customer's limit, 20MHz = 0x%x\n",
-				rtlefuse->pwrgroup_ht20
-				[RF90_PATH_A][chnl - 1]));
+				 "customer's limit, 20MHz = 0x%x\n",
+				 rtlefuse->pwrgroup_ht20
+				 [RF90_PATH_A][chnl - 1]);
 		}
 
 		for (i = 0; i < 4; i++) {
@@ -293,22 +289,19 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 				(pwrdiff_limit[1] << 8) |
 				(pwrdiff_limit[0]);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("Customer's limit = 0x%x\n",
-			 customer_limit));
+			 "Customer's limit = 0x%x\n", customer_limit);
 
 		writeval = customer_limit + ((index < 2) ?
 					     pwrbase0 : pwrbase1);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("Customer, writeval = "
-			 "0x%x\n", writeval));
+			 "Customer, writeval = 0x%x\n", writeval);
 		break;
 	default:
 		chnlgroup = 0;
 		writeval = rtlphy->mcs_txpwrlevel_origoffset[chnlgroup][index] +
 				((index < 2) ? pwrbase0 : pwrbase1);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
-			 ("RTK better performance, "
-			 "writeval = 0x%x\n", writeval));
+			 "RTK better performance, writeval = 0x%x\n", writeval);
 		break;
 	}
 
@@ -541,8 +534,7 @@ void rtl92s_phy_rf6052_set_bandwidth(struct ieee80211_hw *hw, u8 bandwidth)
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("unknown bandwidth: %#X\n",
-			 bandwidth));
+			 "unknown bandwidth: %#X\n", bandwidth);
 		break;
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 78723cf..bc4b6fa 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -188,7 +188,7 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->rtlhal.pfirmware = vzalloc(sizeof(struct rt_firmware));
 	if (!rtlpriv->rtlhal.pfirmware) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't alloc buffer for fw.\n"));
+			 "Can't alloc buffer for fw\n");
 		return 1;
 	}
 
@@ -199,12 +199,12 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 			rtlpriv->io.dev);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Failed to request firmware!\n"));
+			 "Failed to request firmware!\n");
 		return 1;
 	}
 	if (firmware->size > sizeof(struct rt_firmware)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Firmware is too big!\n"));
+			 "Firmware is too big!\n");
 		release_firmware(firmware);
 		return 1;
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index fbebe3e..1f266d1d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -756,7 +756,7 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 	/* DOWRD 8 */
 	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, cpu_to_le32(mapping));
 
-	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, ("\n"));
+	RT_TRACE(rtlpriv, COMP_SEND, DBG_TRACE, "\n");
 }
 
 void rtl92se_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index 1b8e68e..d670e68 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -276,14 +276,14 @@ static int _rtl_usb_init_tx(struct ieee80211_hw *hw)
 						    ? USB_HIGH_SPEED_BULK_SIZE
 						    : USB_FULL_SPEED_BULK_SIZE;
 
-	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, ("USB Max Bulk-out Size=%d\n",
-		 rtlusb->max_bulk_out_size));
+	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, "USB Max Bulk-out Size=%d\n",
+		 rtlusb->max_bulk_out_size);
 
 	for (i = 0; i < __RTL_TXQ_NUM; i++) {
 		u32 ep_num = rtlusb->ep_map.ep_mapping[i];
 		if (!ep_num) {
 			RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-				 ("Invalid endpoint map setting!\n"));
+				 "Invalid endpoint map setting!\n");
 			return -EINVAL;
 		}
 	}
@@ -345,9 +345,9 @@ static int _rtl_usb_init(struct ieee80211_hw *hw)
 			rtlusb->out_ep_nums++;
 
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-			 ("USB EP(0x%02x), MaxPacketSize=%d ,Interval=%d.\n",
+			 "USB EP(0x%02x), MaxPacketSize=%d, Interval=%d\n",
 			 pep_desc->bEndpointAddress, pep_desc->wMaxPacketSize,
-			 pep_desc->bInterval));
+			 pep_desc->bInterval);
 	}
 	if (rtlusb->in_ep_nums <  rtlpriv->cfg->usb_interface_cfg->in_ep_num)
 		return -EINVAL ;
@@ -414,7 +414,7 @@ static struct sk_buff *_rtl_prep_rx_urb(struct ieee80211_hw *hw,
 			       gfp_mask);
 	if (!skb) {
 		RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-			 ("Failed to __dev_alloc_skb!!\n"));
+			 "Failed to __dev_alloc_skb!!\n");
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -575,7 +575,7 @@ static void _rtl_rx_completed(struct urb *_urb)
 			if (IS_ERR(_skb)) {
 				err = PTR_ERR(_skb);
 				RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-					("Can't allocate skb for bulk IN!\n"));
+					 "Can't allocate skb for bulk IN!\n");
 				return;
 			}
 			skb = _skb;
@@ -632,14 +632,14 @@ static int _rtl_usb_receive(struct ieee80211_hw *hw)
 		urb = usb_alloc_urb(0, GFP_KERNEL);
 		if (!urb) {
 			RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-				 ("Failed to alloc URB!!\n"));
+				 "Failed to alloc URB!!\n");
 			goto err_out;
 		}
 
 		skb = _rtl_prep_rx_urb(hw, rtlusb, urb, GFP_KERNEL);
 		if (IS_ERR(skb)) {
 			RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-				 ("Failed to prep_rx_urb!!\n"));
+				 "Failed to prep_rx_urb!!\n");
 			err = PTR_ERR(skb);
 			goto err_out;
 		}
@@ -745,7 +745,7 @@ static void _rtl_submit_tx_urb(struct ieee80211_hw *hw, struct urb *_urb)
 		struct sk_buff *skb;
 
 		RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-			 ("Failed to submit urb.\n"));
+			 "Failed to submit urb\n");
 		usb_unanchor_urb(_urb);
 		skb = (struct sk_buff *)_urb->context;
 		kfree_skb(skb);
@@ -768,7 +768,7 @@ static int _usb_tx_post(struct ieee80211_hw *hw, struct urb *urb,
 
 	if (urb->status) {
 		RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-			 ("Urb has error status 0x%X\n", urb->status));
+			 "Urb has error status 0x%X\n", urb->status);
 		goto out;
 	}
 	/*  TODO:	statistics */
@@ -805,7 +805,7 @@ static struct urb *_rtl_usb_tx_urb_setup(struct ieee80211_hw *hw,
 	_urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!_urb) {
 		RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-			 ("Can't allocate URB for bulk out!\n"));
+			 "Can't allocate URB for bulk out!\n");
 		kfree_skb(skb);
 		return NULL;
 	}
@@ -830,7 +830,7 @@ static void _rtl_usb_transmit(struct ieee80211_hw *hw, struct sk_buff *skb,
 	WARN_ON(NULL == rtlusb->usb_tx_aggregate_hdl);
 	if (unlikely(IS_USB_STOP(rtlusb))) {
 		RT_TRACE(rtlpriv, COMP_USB, DBG_EMERG,
-			 ("USB device is stopping...\n"));
+			 "USB device is stopping...\n");
 		kfree_skb(skb);
 		return;
 	}
@@ -840,7 +840,7 @@ static void _rtl_usb_transmit(struct ieee80211_hw *hw, struct sk_buff *skb,
 	_urb = _rtl_usb_tx_urb_setup(hw, _skb, ep_num);
 	if (unlikely(!_urb)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't allocate urb. Drop skb!\n"));
+			 "Can't allocate urb. Drop skb!\n");
 		return;
 	}
 	urb_list = &rtlusb->tx_pending[ep_num];
@@ -865,7 +865,7 @@ static void _rtl_usb_tx_preprocess(struct ieee80211_hw *hw, struct sk_buff *skb,
 
 	memset(&tcb_desc, 0, sizeof(struct rtl_tcb_desc));
 	if (ieee80211_is_auth(fc)) {
-		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, ("MAC80211_LINKING\n"));
+		RT_TRACE(rtlpriv, COMP_SEND, DBG_DMESG, "MAC80211_LINKING\n");
 		rtl_ips_nic_on(hw);
 	}
 
@@ -969,8 +969,7 @@ int __devinit rtl_usb_probe(struct usb_interface *intf,
 	/*like read eeprom and so on */
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
 	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't init_sw_vars.\n"));
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
 		goto error_out;
 	}
 	rtlpriv->cfg->ops->init_sw_leds(hw);
@@ -980,7 +979,7 @@ int __devinit rtl_usb_probe(struct usb_interface *intf,
 	err = rtl_init_core(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 ("Can't allocate sw for mac80211.\n"));
+			 "Can't allocate sw for mac80211\n");
 		goto error_out;
 	}
 
@@ -990,7 +989,7 @@ int __devinit rtl_usb_probe(struct usb_interface *intf,
 	err = ieee80211_register_hw(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_EMERG,
-			 ("Can't register mac80211 hw.\n"));
+			 "Can't register mac80211 hw\n");
 		goto error_out;
 	} else {
 		rtlpriv->mac80211.mac80211_registered = 1;
-- 
1.7.8.111.gad25c.dirty
