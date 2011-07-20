From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH 1/3] wireless: rtlwifi: throw away MAC_FMT and use %pM instead
Date: Wed, 20 Jul 2011 16:34:29 +0300
Message-ID: <fddeabc04a1b81a5c1f51a4164d93366dccf5f8e.1311162926.git.andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/base.c         |   11 +++++------
 drivers/net/wireless/rtlwifi/cam.c          |    4 ++--
 drivers/net/wireless/rtlwifi/core.c         |    6 +++---
 drivers/net/wireless/rtlwifi/debug.h        |    5 -----
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c |    2 +-
 7 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index bc13533..5f46efd 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -756,18 +756,17 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 				return false;
 
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-				 ("%s ACT_ADDBAREQ From :" MAC_FMT "\n",
-				  is_tx ? "Tx" : "Rx", MAC_ARG(hdr->addr2)));
+				 ("%s ACT_ADDBAREQ From :%pM\n",
+				  is_tx ? "Tx" : "Rx", hdr->addr2));
 			break;
 		case ACT_ADDBARSP:
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-				 ("%s ACT_ADDBARSP From :" MAC_FMT "\n",
-				  is_tx ? "Tx" : "Rx", MAC_ARG(hdr->addr2)));
+				 ("%s ACT_ADDBARSP From :%pM\n",
+				  is_tx ? "Tx" : "Rx", hdr->addr2));
 			break;
 		case ACT_DELBA:
 			RT_TRACE(rtlpriv, (COMP_SEND | COMP_RECV), DBG_DMESG,
-				 ("ACT_ADDBADEL From :" MAC_FMT "\n",
-				  MAC_ARG(hdr->addr2)));
+				 ("ACT_ADDBADEL From :%pM\n", hdr->addr2));
 			break;
 		}
 		break;
diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 7295af0..66588c2 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -131,9 +131,9 @@ u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 		 ("EntryNo:%x, ulKeyId=%x, ulEncAlg=%x, "
-		  "ulUseDK=%x MacAddr" MAC_FMT "\n",
+		  "ulUseDK=%x MacAddr %pM\n",
 		  ul_entry_idx, ul_key_id, ul_enc_alg,
-		  ul_default_key, MAC_ARG(mac_addr)));
+		  ul_default_key, mac_addr));
 
 	if (ul_key_id == TOTAL_CAM_ENTRY) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_WARNING,
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 03ce696..1bdc1aa 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -456,7 +456,7 @@ static int rtl_op_sta_add(struct ieee80211_hw *hw,
 			sta_entry->wireless_mode = WIRELESS_MODE_G;
 
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-			("Add sta addr is "MAC_FMT"\n", MAC_ARG(sta->addr)));
+			("Add sta addr is %pM\n", sta->addr));
 		rtlpriv->cfg->ops->update_rate_tbl(hw, sta, 0);
 	}
 	return 0;
@@ -469,7 +469,7 @@ static int rtl_op_sta_remove(struct ieee80211_hw *hw,
 	struct rtl_sta_info *sta_entry;
 	if (sta) {
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-			("Remove sta addr is "MAC_FMT"\n", MAC_ARG(sta->addr)));
+			("Remove sta addr is %pM\n", sta->addr));
 		sta_entry = (struct rtl_sta_info *) sta->drv_priv;
 		sta_entry->wireless_mode = 0;
 		sta_entry->ratr_index = 0;
@@ -678,7 +678,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 					      (u8 *) bss_conf->bssid);
 
 		RT_TRACE(rtlpriv, COMP_MAC80211, DBG_DMESG,
-			 (MAC_FMT "\n", MAC_ARG(bss_conf->bssid)));
+			 ("%pM\n", bss_conf->bssid));
 
 		mac->vendor = PEER_UNKNOWN;
 		memcpy(mac->bssid, bss_conf->bssid, 6);
diff --git a/drivers/net/wireless/rtlwifi/debug.h b/drivers/net/wireless/rtlwifi/debug.h
index e4aa868..160dd06 100644
--- a/drivers/net/wireless/rtlwifi/debug.h
+++ b/drivers/net/wireless/rtlwifi/debug.h
@@ -204,10 +204,5 @@ enum dbgp_flag_e {
 		} \
 	} while (0);
 
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-#define MAC_ARG(x) \
-	((u8 *)(x))[0], ((u8 *)(x))[1], ((u8 *)(x))[2],\
-	((u8 *)(x))[3], ((u8 *)(x))[4], ((u8 *)(x))[5]
-
 void rtl_dbgp_flag_init(struct ieee80211_hw *hw);
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 9e2a9e3..a3deaef 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1592,7 +1592,7 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 	}
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 (MAC_FMT "\n", MAC_ARG(rtlefuse->dev_addr)));
+		 ("%pM\n", rtlefuse->dev_addr));
 
 	_rtl92ce_read_txpower_info_from_hwpg(hw,
 					     rtlefuse->autoload_failflag,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 5a65bea..0073cf1 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1829,7 +1829,7 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ETHER_ADDR,
 				      rtlefuse->dev_addr);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 (MAC_FMT "\n", MAC_ARG(rtlefuse->dev_addr)));
+		 ("%pM\n", rtlefuse->dev_addr));
 	_rtl92de_read_txpower_info(hw, rtlefuse->autoload_failflag, hwinfo);
 
 	/* Read Channel Plan */
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index b1d0213..fe2b0b9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1682,7 +1682,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 		rtl_write_byte(rtlpriv, MACIDR0 + i, rtlefuse->dev_addr[i]);
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
-		 (MAC_FMT "\n", MAC_ARG(rtlefuse->dev_addr)));
+		 ("%pM\n", rtlefuse->dev_addr));
 
 	/* Get Tx Power Level by Channel */
 	/* Read Tx power of Channel 1 ~ 14 from EEPROM. */
-- 
1.7.5.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
