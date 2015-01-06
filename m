From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 01/11 V2] rtlwifi: Unify variable naming for all drivers
Date: Tue,  6 Jan 2015 09:58:02 -0600
Message-ID: <1420559892-12384-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some drivers refer to a particular quantity in the driver's private
are by one name, while others use a different name. These differences
are removed.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

V2 - unchanged from V1
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c       | 26 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8723be/dm.c       | 26 ++++++++++----------
 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c       | 30 +++++++++++------------
 drivers/net/wireless/rtlwifi/wifi.h               |  2 --
 5 files changed, 42 insertions(+), 44 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index f6cb5ae..c3aad76 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -221,7 +221,7 @@ static void rtl92c_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->forbidden_igi = DM_DIG_MIN;
 	dm_digtable->large_fa_hit = 0;
 	dm_digtable->recover_cnt = 0;
-	dm_digtable->dig_dynamic_min  = 0x25;
+	dm_digtable->dig_min_0  = 0x25;
 }
 
 static u8 rtl92c_dm_initial_gain_min_pwdb(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
index 77deedf..2fa4c45 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
@@ -172,8 +172,8 @@ static void rtl92ee_dm_diginit(struct ieee80211_hw *hw)
 	dm_dig->forbidden_igi = DM_DIG_MIN;
 	dm_dig->large_fa_hit = 0;
 	dm_dig->recover_cnt = 0;
-	dm_dig->dig_dynamic_min = DM_DIG_MIN;
-	dm_dig->dig_dynamic_min_1 = DM_DIG_MIN;
+	dm_dig->dig_min_0 = DM_DIG_MIN;
+	dm_dig->dig_min_1 = DM_DIG_MIN;
 	dm_dig->media_connect_0 = false;
 	dm_dig->media_connect_1 = false;
 	rtlpriv->dm.dm_initialgain_enable = true;
@@ -298,7 +298,7 @@ static void rtl92ee_dm_dig(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
-	u8 dig_dynamic_min , dig_maxofmin;
+	u8 dig_min_0, dig_maxofmin;
 	bool bfirstconnect , bfirstdisconnect;
 	u8 dm_dig_max, dm_dig_min;
 	u8 current_igi = dm_dig->cur_igvalue;
@@ -308,7 +308,7 @@ static void rtl92ee_dm_dig(struct ieee80211_hw *hw)
 	if (mac->act_scanning)
 		return;
 
-	dig_dynamic_min = dm_dig->dig_dynamic_min;
+	dig_min_0 = dm_dig->dig_min_0;
 	bfirstconnect = (mac->link_state >= MAC80211_LINKED) &&
 			!dm_dig->media_connect_0;
 	bfirstdisconnect = (mac->link_state < MAC80211_LINKED) &&
@@ -329,19 +329,19 @@ static void rtl92ee_dm_dig(struct ieee80211_hw *hw)
 		if (rtlpriv->dm.one_entry_only) {
 			offset = 0;
 			if (dm_dig->rssi_val_min - offset < dm_dig_min)
-				dig_dynamic_min = dm_dig_min;
+				dig_min_0 = dm_dig_min;
 			else if (dm_dig->rssi_val_min - offset >
 				 dig_maxofmin)
-				dig_dynamic_min = dig_maxofmin;
+				dig_min_0 = dig_maxofmin;
 			else
-				dig_dynamic_min = dm_dig->rssi_val_min - offset;
+				dig_min_0 = dm_dig->rssi_val_min - offset;
 		} else {
-			dig_dynamic_min = dm_dig_min;
+			dig_min_0 = dm_dig_min;
 		}
 
 	} else {
 		dm_dig->rx_gain_max = dm_dig_max;
-		dig_dynamic_min = dm_dig_min;
+		dig_min_0 = dm_dig_min;
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "no link\n");
 	}
 
@@ -368,10 +368,10 @@ static void rtl92ee_dm_dig(struct ieee80211_hw *hw)
 		} else {
 			if (dm_dig->large_fa_hit < 3) {
 				if ((dm_dig->forbidden_igi - 1) <
-				    dig_dynamic_min) {
-					dm_dig->forbidden_igi = dig_dynamic_min;
+				    dig_min_0) {
+					dm_dig->forbidden_igi = dig_min_0;
 					dm_dig->rx_gain_min =
-								dig_dynamic_min;
+								dig_min_0;
 				} else {
 					dm_dig->forbidden_igi--;
 					dm_dig->rx_gain_min =
@@ -430,7 +430,7 @@ static void rtl92ee_dm_dig(struct ieee80211_hw *hw)
 	rtl92ee_dm_write_dig(hw , current_igi);
 	dm_dig->media_connect_0 = ((mac->link_state >= MAC80211_LINKED) ?
 				   true : false);
-	dm_dig->dig_dynamic_min = dig_dynamic_min;
+	dm_dig->dig_min_0 = dig_min_0;
 }
 
 void rtl92ee_dm_write_cck_cca_thres(struct ieee80211_hw *hw, u8 cur_thres)
diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
index dd7eb43..b92c521e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
@@ -232,8 +232,8 @@ static void rtl8723be_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->forbidden_igi = DM_DIG_MIN;
 	dm_digtable->large_fa_hit = 0;
 	dm_digtable->recover_cnt = 0;
-	dm_digtable->dig_dynamic_min = DM_DIG_MIN;
-	dm_digtable->dig_dynamic_min_1 = DM_DIG_MIN;
+	dm_digtable->dig_min_0 = DM_DIG_MIN;
+	dm_digtable->dig_min_1 = DM_DIG_MIN;
 	dm_digtable->media_connect_0 = false;
 	dm_digtable->media_connect_1 = false;
 	rtlpriv->dm.dm_initialgain_enable = true;
@@ -424,7 +424,7 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	u8 dig_dynamic_min, dig_maxofmin;
+	u8 dig_min_0, dig_maxofmin;
 	bool bfirstconnect, bfirstdisconnect;
 	u8 dm_dig_max, dm_dig_min;
 	u8 current_igi = dm_digtable->cur_igvalue;
@@ -434,7 +434,7 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 	if (mac->act_scanning)
 		return;
 
-	dig_dynamic_min = dm_digtable->dig_dynamic_min;
+	dig_min_0 = dm_digtable->dig_min_0;
 	bfirstconnect = (mac->link_state >= MAC80211_LINKED) &&
 			!dm_digtable->media_connect_0;
 	bfirstdisconnect = (mac->link_state < MAC80211_LINKED) &&
@@ -456,20 +456,20 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 		if (rtlpriv->dm.one_entry_only) {
 			offset = 12;
 			if (dm_digtable->rssi_val_min - offset < dm_dig_min)
-				dig_dynamic_min = dm_dig_min;
+				dig_min_0 = dm_dig_min;
 			else if (dm_digtable->rssi_val_min - offset >
 							dig_maxofmin)
-				dig_dynamic_min = dig_maxofmin;
+				dig_min_0 = dig_maxofmin;
 			else
-				dig_dynamic_min =
+				dig_min_0 =
 					dm_digtable->rssi_val_min - offset;
 		} else {
-			dig_dynamic_min = dm_dig_min;
+			dig_min_0 = dm_dig_min;
 		}
 
 	} else {
 		dm_digtable->rx_gain_max = dm_dig_max;
-		dig_dynamic_min = dm_dig_min;
+		dig_min_0 = dm_dig_min;
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "no link\n");
 	}
 
@@ -497,11 +497,11 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 		} else {
 			if (dm_digtable->large_fa_hit < 3) {
 				if ((dm_digtable->forbidden_igi - 1) <
-				     dig_dynamic_min) {
+				     dig_min_0) {
 					dm_digtable->forbidden_igi =
-							dig_dynamic_min;
+							dig_min_0;
 					dm_digtable->rx_gain_min =
-							dig_dynamic_min;
+							dig_min_0;
 				} else {
 					dm_digtable->forbidden_igi--;
 					dm_digtable->rx_gain_min =
@@ -552,7 +552,7 @@ static void rtl8723be_dm_dig(struct ieee80211_hw *hw)
 	rtl8723be_dm_write_dig(hw, current_igi);
 	dm_digtable->media_connect_0 =
 		((mac->link_state >= MAC80211_LINKED) ? true : false);
-	dm_digtable->dig_dynamic_min = dig_dynamic_min;
+	dm_digtable->dig_min_0 = dig_min_0;
 }
 
 static void rtl8723be_dm_false_alarm_counter_statistics(
diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
index ba30b0d..8b0bfb2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
@@ -539,8 +539,8 @@ static void rtl8821ae_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->forbidden_igi = DM_DIG_MIN;
 	dm_digtable->large_fa_hit = 0;
 	dm_digtable->recover_cnt = 0;
-	dm_digtable->dig_dynamic_min = DM_DIG_MIN;
-	dm_digtable->dig_dynamic_min_1 = DM_DIG_MIN;
+	dm_digtable->dig_min_0 = DM_DIG_MIN;
+	dm_digtable->dig_min_1 = DM_DIG_MIN;
 	dm_digtable->media_connect_0 = false;
 	dm_digtable->media_connect_1 = false;
 	rtlpriv->dm.dm_initialgain_enable = true;
@@ -822,7 +822,7 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u8 dig_dynamic_min;
+	u8 dig_min_0;
 	u8 dig_max_of_min;
 	bool first_connect, first_disconnect;
 	u8 dm_dig_max, dm_dig_min, offset;
@@ -837,7 +837,7 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
 	}
 
 	/*add by Neil Chen to avoid PSD is processing*/
-	dig_dynamic_min = dm_digtable->dig_dynamic_min;
+	dig_min_0 = dm_digtable->dig_min_0;
 	first_connect = (mac->link_state >= MAC80211_LINKED) &&
 			(!dm_digtable->media_connect_0);
 	first_disconnect = (mac->link_state < MAC80211_LINKED) &&
@@ -876,23 +876,23 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
 			offset = 0;
 
 			if (dm_digtable->rssi_val_min - offset < dm_dig_min)
-				dig_dynamic_min = dm_dig_min;
+				dig_min_0 = dm_dig_min;
 			else if (dm_digtable->rssi_val_min -
 				offset > dig_max_of_min)
-				dig_dynamic_min = dig_max_of_min;
+				dig_min_0 = dig_max_of_min;
 			else
-				dig_dynamic_min =
+				dig_min_0 =
 					dm_digtable->rssi_val_min - offset;
 
 			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-				 "bOneEntryOnly=TRUE, dig_dynamic_min=0x%x\n",
-				 dig_dynamic_min);
+				 "bOneEntryOnly=TRUE, dig_min_0=0x%x\n",
+				 dig_min_0);
 		} else {
-			dig_dynamic_min = dm_dig_min;
+			dig_min_0 = dm_dig_min;
 		}
 	} else {
 		dm_digtable->rx_gain_max = dm_dig_max;
-		dig_dynamic_min = dm_dig_min;
+		dig_min_0 = dm_dig_min;
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
 			 "No Link\n");
 	}
@@ -925,11 +925,11 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
 		} else {
 			if (dm_digtable->large_fa_hit < 3) {
 				if ((dm_digtable->forbidden_igi - 1) <
-				    dig_dynamic_min) {
+				    dig_min_0) {
 					dm_digtable->forbidden_igi =
-						dig_dynamic_min;
+						dig_min_0;
 					dm_digtable->rx_gain_min =
-						dig_dynamic_min;
+						dig_min_0;
 					RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
 						 "Normal Case: At Lower Bound\n");
 				} else {
@@ -1024,7 +1024,7 @@ static void rtl8821ae_dm_dig(struct ieee80211_hw *hw)
 	rtl8821ae_dm_write_dig(hw, current_igi);
 	dm_digtable->media_connect_0 =
 		((mac->link_state >= MAC80211_LINKED) ? true : false);
-	dm_digtable->dig_dynamic_min = dig_dynamic_min;
+	dm_digtable->dig_min_0 = dig_min_0;
 }
 
 static void rtl8821ae_dm_common_info_self_update(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 7a718fd..b53d9dd 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -2412,8 +2412,6 @@ struct dig_t {
 	u8 pre_ccastate;
 	u8 cur_ccasate;
 	u8 large_fa_hit;
-	u8 dig_dynamic_min;
-	u8 dig_dynamic_min_1;
 	u8 forbidden_igi;
 	u8 dig_state;
 	u8 dig_highpwrstate;
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
