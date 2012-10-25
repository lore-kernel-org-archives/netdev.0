From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH NEXT 02/17] rtlwifi: rtl8192c: rtl8192ce: rtl8192cu: rtl8192se: rtl8192de: Shorten some variable names
Date: Thu, 25 Oct 2012 13:46:31 -0500
Message-ID: <1351190806-4258-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1351190806-4258-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351190806-4258-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The private data areas for these drivers contain some very long variable
names that cause difficulty in fitting source lines to an 80-character
limit.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  227 +++++++++-----------
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   69 +++---
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |   30 ++-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   27 ++-
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |   23 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   42 ++--
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |   30 ++-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   25 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   22 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   95 ++++----
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   65 ++----
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   39 ++--
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   89 ++++----
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   64 ++----
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   21 +-
 drivers/net/wireless/rtlwifi/wifi.h                |   53 ++---
 20 files changed, 418 insertions(+), 548 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index 1ca4e25..1cdf5a2 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -43,8 +43,8 @@
 #define GET_UNDECORATED_AVERAGE_RSSI(_priv)	\
 	((RTLPRIV(_priv))->mac80211.opmode == \
 			     NL80211_IFTYPE_ADHOC) ?	\
-	((RTLPRIV(_priv))->dm.entry_min_undecoratedsmoothed_pwdb) : \
-	((RTLPRIV(_priv))->dm.undecorated_smoothed_pwdb)
+	((RTLPRIV(_priv))->dm.entry_min_undec_sm_pwdb) : \
+	((RTLPRIV(_priv))->dm.undec_sm_pwdb)
 
 static const u32 ofdmswing_table[OFDM_TABLE_SIZE] = {
 	0x7f8001fe,
@@ -167,18 +167,18 @@ static void rtl92c_dm_diginit(struct ieee80211_hw *hw)
 	dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 	dm_digtable->cur_igvalue = 0x20;
 	dm_digtable->pre_igvalue = 0x0;
-	dm_digtable->cursta_connectstate = DIG_STA_DISCONNECT;
-	dm_digtable->presta_connectstate = DIG_STA_DISCONNECT;
-	dm_digtable->curmultista_connectstate = DIG_MULTISTA_DISCONNECT;
+	dm_digtable->cursta_cstate = DIG_STA_DISCONNECT;
+	dm_digtable->presta_cstate = DIG_STA_DISCONNECT;
+	dm_digtable->curmultista_cstate = DIG_MULTISTA_DISCONNECT;
 	dm_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
 	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
 	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
 	dm_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
 	dm_digtable->rx_gain_range_max = DM_DIG_MAX;
 	dm_digtable->rx_gain_range_min = DM_DIG_MIN;
-	dm_digtable->backoff_val = DM_DIG_BACKOFF_DEFAULT;
-	dm_digtable->backoff_val_range_max = DM_DIG_BACKOFF_MAX;
-	dm_digtable->backoff_val_range_min = DM_DIG_BACKOFF_MIN;
+	dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
+	dm_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
+	dm_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
 	dm_digtable->pre_cck_pd_state = CCK_PD_STAGE_MAX;
 	dm_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
 }
@@ -189,22 +189,21 @@ static u8 rtl92c_dm_initial_gain_min_pwdb(struct ieee80211_hw *hw)
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 	long rssi_val_min = 0;
 
-	if ((dm_digtable->curmultista_connectstate == DIG_MULTISTA_CONNECT) &&
-	    (dm_digtable->cursta_connectstate == DIG_STA_CONNECT)) {
-		if (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb != 0)
+	if ((dm_digtable->curmultista_cstate == DIG_MULTISTA_CONNECT) &&
+	    (dm_digtable->cursta_cstate == DIG_STA_CONNECT)) {
+		if (rtlpriv->dm.entry_min_undec_sm_pwdb != 0)
 			rssi_val_min =
-			    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb >
-			     rtlpriv->dm.undecorated_smoothed_pwdb) ?
-			    rtlpriv->dm.undecorated_smoothed_pwdb :
-			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			    (rtlpriv->dm.entry_min_undec_sm_pwdb >
+			     rtlpriv->dm.undec_sm_pwdb) ?
+			    rtlpriv->dm.undec_sm_pwdb :
+			    rtlpriv->dm.entry_min_undec_sm_pwdb;
 		else
-			rssi_val_min = rtlpriv->dm.undecorated_smoothed_pwdb;
-	} else if (dm_digtable->cursta_connectstate == DIG_STA_CONNECT ||
-		   dm_digtable->cursta_connectstate == DIG_STA_BEFORE_CONNECT) {
-		rssi_val_min = rtlpriv->dm.undecorated_smoothed_pwdb;
-	} else if (dm_digtable->curmultista_connectstate ==
-		   DIG_MULTISTA_CONNECT) {
-		rssi_val_min = rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			rssi_val_min = rtlpriv->dm.undec_sm_pwdb;
+	} else if (dm_digtable->cursta_cstate == DIG_STA_CONNECT ||
+		   dm_digtable->cursta_cstate == DIG_STA_BEFORE_CONNECT) {
+		rssi_val_min = rtlpriv->dm.undec_sm_pwdb;
+	} else if (dm_digtable->curmultista_cstate == DIG_MULTISTA_CONNECT) {
+		rssi_val_min = rtlpriv->dm.entry_min_undec_sm_pwdb;
 	}
 
 	return (u8) rssi_val_min;
@@ -286,37 +285,33 @@ static void rtl92c_dm_ctrl_initgain_by_fa(struct ieee80211_hw *hw)
 static void rtl92c_dm_ctrl_initgain_by_rssi(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
+	struct dig_t *digtable = &rtlpriv->dm_digtable;
 
-	if (rtlpriv->falsealm_cnt.cnt_all > dm_digtable->fa_highthresh) {
-		if ((dm_digtable->backoff_val - 2) <
-		    dm_digtable->backoff_val_range_min)
-			dm_digtable->backoff_val =
-			    dm_digtable->backoff_val_range_min;
+	if (rtlpriv->falsealm_cnt.cnt_all > digtable->fa_highthresh) {
+		if ((digtable->back_val - 2) < digtable->back_range_min)
+			digtable->back_val = digtable->back_range_min;
 		else
-			dm_digtable->backoff_val -= 2;
-	} else if (rtlpriv->falsealm_cnt.cnt_all < dm_digtable->fa_lowthresh) {
-		if ((dm_digtable->backoff_val + 2) >
-		    dm_digtable->backoff_val_range_max)
-			dm_digtable->backoff_val =
-			    dm_digtable->backoff_val_range_max;
+			digtable->back_val -= 2;
+	} else if (rtlpriv->falsealm_cnt.cnt_all < digtable->fa_lowthresh) {
+		if ((digtable->back_val + 2) > digtable->back_range_max)
+			digtable->back_val = digtable->back_range_max;
 		else
-			dm_digtable->backoff_val += 2;
+			digtable->back_val += 2;
 	}
 
-	if ((dm_digtable->rssi_val_min + 10 - dm_digtable->backoff_val) >
-	    dm_digtable->rx_gain_range_max)
-		dm_digtable->cur_igvalue = dm_digtable->rx_gain_range_max;
-	else if ((dm_digtable->rssi_val_min + 10 -
-		  dm_digtable->backoff_val) < dm_digtable->rx_gain_range_min)
-		dm_digtable->cur_igvalue = dm_digtable->rx_gain_range_min;
+	if ((digtable->rssi_val_min + 10 - digtable->back_val) >
+	    digtable->rx_gain_range_max)
+		digtable->cur_igvalue = digtable->rx_gain_range_max;
+	else if ((digtable->rssi_val_min + 10 -
+		  digtable->back_val) < digtable->rx_gain_range_min)
+		digtable->cur_igvalue = digtable->rx_gain_range_min;
 	else
-		dm_digtable->cur_igvalue = dm_digtable->rssi_val_min + 10 -
-		    dm_digtable->backoff_val;
+		digtable->cur_igvalue = digtable->rssi_val_min + 10 -
+		    digtable->back_val;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "rssi_val_min = %x backoff_val %x\n",
-		 dm_digtable->rssi_val_min, dm_digtable->backoff_val);
+		 "rssi_val_min = %x back_val %x\n",
+		 digtable->rssi_val_min, digtable->back_val);
 
 	rtl92c_dm_write_dig(hw);
 }
@@ -327,14 +322,14 @@ static void rtl92c_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long rssi_strength = rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+	long rssi_strength = rtlpriv->dm.entry_min_undec_sm_pwdb;
 	bool multi_sta = false;
 
 	if (mac->opmode == NL80211_IFTYPE_ADHOC)
 		multi_sta = true;
 
 	if (!multi_sta ||
-	    dm_digtable->cursta_connectstate != DIG_STA_DISCONNECT) {
+	    dm_digtable->cursta_cstate != DIG_STA_DISCONNECT) {
 		initialized = false;
 		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 		return;
@@ -345,7 +340,7 @@ static void rtl92c_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 		rtl92c_dm_write_dig(hw);
 	}
 
-	if (dm_digtable->curmultista_connectstate == DIG_MULTISTA_CONNECT) {
+	if (dm_digtable->curmultista_cstate == DIG_MULTISTA_CONNECT) {
 		if ((rssi_strength < dm_digtable->rssi_lowthresh) &&
 		    (dm_digtable->dig_ext_port_stage != DIG_EXT_PORT_STAGE_1)) {
 
@@ -367,8 +362,8 @@ static void rtl92c_dm_initial_gain_multi_sta(struct ieee80211_hw *hw)
 	}
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "curmultista_connectstate = %x dig_ext_port_stage %x\n",
-		 dm_digtable->curmultista_connectstate,
+		 "curmultista_cstate = %x dig_ext_port_stage %x\n",
+		 dm_digtable->curmultista_cstate,
 		 dm_digtable->dig_ext_port_stage);
 }
 
@@ -378,15 +373,14 @@ static void rtl92c_dm_initial_gain_sta(struct ieee80211_hw *hw)
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_TRACE,
-		 "presta_connectstate = %x, cursta_connectstate = %x\n",
-		 dm_digtable->presta_connectstate,
-		 dm_digtable->cursta_connectstate);
+		 "presta_cstate = %x, cursta_cstate = %x\n",
+		 dm_digtable->presta_cstate, dm_digtable->cursta_cstate);
 
-	if (dm_digtable->presta_connectstate == dm_digtable->cursta_connectstate
-	    || dm_digtable->cursta_connectstate == DIG_STA_BEFORE_CONNECT
-	    || dm_digtable->cursta_connectstate == DIG_STA_CONNECT) {
+	if (dm_digtable->presta_cstate == dm_digtable->cursta_cstate ||
+	    dm_digtable->cursta_cstate == DIG_STA_BEFORE_CONNECT ||
+	    dm_digtable->cursta_cstate == DIG_STA_CONNECT) {
 
-		if (dm_digtable->cursta_connectstate != DIG_STA_DISCONNECT) {
+		if (dm_digtable->cursta_cstate != DIG_STA_DISCONNECT) {
 			dm_digtable->rssi_val_min =
 			    rtl92c_dm_initial_gain_min_pwdb(hw);
 			rtl92c_dm_ctrl_initgain_by_rssi(hw);
@@ -394,7 +388,7 @@ static void rtl92c_dm_initial_gain_sta(struct ieee80211_hw *hw)
 	} else {
 		dm_digtable->rssi_val_min = 0;
 		dm_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
-		dm_digtable->backoff_val = DM_DIG_BACKOFF_DEFAULT;
+		dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
 		dm_digtable->cur_igvalue = 0x20;
 		dm_digtable->pre_igvalue = 0;
 		rtl92c_dm_write_dig(hw);
@@ -407,7 +401,7 @@ static void rtl92c_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
-	if (dm_digtable->cursta_connectstate == DIG_STA_CONNECT) {
+	if (dm_digtable->cursta_cstate == DIG_STA_CONNECT) {
 		dm_digtable->rssi_val_min = rtl92c_dm_initial_gain_min_pwdb(hw);
 
 		if (dm_digtable->pre_cck_pd_state == CCK_PD_STAGE_LowRssi) {
@@ -484,15 +478,15 @@ static void rtl92c_dm_ctrl_initgain_by_twoport(struct ieee80211_hw *hw)
 		return;
 
 	if (mac->link_state >= MAC80211_LINKED)
-		dm_digtable->cursta_connectstate = DIG_STA_CONNECT;
+		dm_digtable->cursta_cstate = DIG_STA_CONNECT;
 	else
-		dm_digtable->cursta_connectstate = DIG_STA_DISCONNECT;
+		dm_digtable->cursta_cstate = DIG_STA_DISCONNECT;
 
 	rtl92c_dm_initial_gain_sta(hw);
 	rtl92c_dm_initial_gain_multi_sta(hw);
 	rtl92c_dm_cck_packet_detection_thresh(hw);
 
-	dm_digtable->presta_connectstate = dm_digtable->cursta_connectstate;
+	dm_digtable->presta_cstate = dm_digtable->cursta_cstate;
 
 }
 
@@ -526,9 +520,9 @@ void rtl92c_dm_write_dig(struct ieee80211_hw *hw)
 	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, backoff_val = %d\n",
+		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, back_val = %d\n",
 		 dm_digtable->cur_igvalue, dm_digtable->pre_igvalue,
-		 dm_digtable->backoff_val);
+		 dm_digtable->back_val);
 
 	dm_digtable->cur_igvalue += 2;
 	if (dm_digtable->cur_igvalue > 0x3f)
@@ -555,20 +549,18 @@ static void rtl92c_dm_pwdb_monitor(struct ieee80211_hw *hw)
 	return;
 
 	if (tmpentry_max_pwdb != 0) {
-		rtlpriv->dm.entry_max_undecoratedsmoothed_pwdb =
-		    tmpentry_max_pwdb;
+		rtlpriv->dm.entry_max_undec_sm_pwdb = tmpentry_max_pwdb;
 	} else {
-		rtlpriv->dm.entry_max_undecoratedsmoothed_pwdb = 0;
+		rtlpriv->dm.entry_max_undec_sm_pwdb = 0;
 	}
 
 	if (tmpentry_min_pwdb != 0xff) {
-		rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb =
-		    tmpentry_min_pwdb;
+		rtlpriv->dm.entry_min_undec_sm_pwdb = tmpentry_min_pwdb;
 	} else {
-		rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb = 0;
+		rtlpriv->dm.entry_min_undec_sm_pwdb = 0;
 	}
 
-	h2c_parameter[2] = (u8) (rtlpriv->dm.undecorated_smoothed_pwdb & 0xFF);
+	h2c_parameter[2] = (u8) (rtlpriv->dm.undec_sm_pwdb & 0xFF);
 	h2c_parameter[0] = 0;
 
 	rtl92c_fill_h2c_cmd(hw, H2C_RSSI_REPORT, 3, h2c_parameter);
@@ -1160,7 +1152,7 @@ static void rtl92c_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
 	struct rate_adaptive *p_ra = &(rtlpriv->ra);
-	u32 low_rssithresh_for_ra, high_rssithresh_for_ra;
+	u32 low_rssi_thresh, high_rssi_thresh;
 	struct ieee80211_sta *sta = NULL;
 
 	if (is_hal_stop(rtlhal)) {
@@ -1179,35 +1171,33 @@ static void rtl92c_dm_refresh_rate_adaptive_mask(struct ieee80211_hw *hw)
 	    mac->opmode == NL80211_IFTYPE_STATION) {
 		switch (p_ra->pre_ratr_state) {
 		case DM_RATR_STA_HIGH:
-			high_rssithresh_for_ra = 50;
-			low_rssithresh_for_ra = 20;
+			high_rssi_thresh = 50;
+			low_rssi_thresh = 20;
 			break;
 		case DM_RATR_STA_MIDDLE:
-			high_rssithresh_for_ra = 55;
-			low_rssithresh_for_ra = 20;
+			high_rssi_thresh = 55;
+			low_rssi_thresh = 20;
 			break;
 		case DM_RATR_STA_LOW:
-			high_rssithresh_for_ra = 50;
-			low_rssithresh_for_ra = 25;
+			high_rssi_thresh = 50;
+			low_rssi_thresh = 25;
 			break;
 		default:
-			high_rssithresh_for_ra = 50;
-			low_rssithresh_for_ra = 20;
+			high_rssi_thresh = 50;
+			low_rssi_thresh = 20;
 			break;
 		}
 
-		if (rtlpriv->dm.undecorated_smoothed_pwdb >
-		    (long)high_rssithresh_for_ra)
+		if (rtlpriv->dm.undec_sm_pwdb > (long)high_rssi_thresh)
 			p_ra->ratr_state = DM_RATR_STA_HIGH;
-		else if (rtlpriv->dm.undecorated_smoothed_pwdb >
-			 (long)low_rssithresh_for_ra)
+		else if (rtlpriv->dm.undec_sm_pwdb > (long)low_rssi_thresh)
 			p_ra->ratr_state = DM_RATR_STA_MIDDLE;
 		else
 			p_ra->ratr_state = DM_RATR_STA_LOW;
 
 		if (p_ra->pre_ratr_state != p_ra->ratr_state) {
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD, "RSSI = %ld\n",
-				 rtlpriv->dm.undecorated_smoothed_pwdb);
+				 rtlpriv->dm.undec_sm_pwdb);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
 				 "RSSI_LEVEL = %d\n", p_ra->ratr_state);
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
@@ -1315,7 +1305,7 @@ static void rtl92c_dm_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 
 	if (((mac->link_state == MAC80211_NOLINK)) &&
-	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+	    (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)) {
 		dm_pstable->rssi_val_min = 0;
 		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD, "Not connected to any\n");
 	}
@@ -1323,20 +1313,19 @@ static void rtl92c_dm_dynamic_bb_powersaving(struct ieee80211_hw *hw)
 	if (mac->link_state == MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 			dm_pstable->rssi_val_min =
-			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			    rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
 				 dm_pstable->rssi_val_min);
 		} else {
-			dm_pstable->rssi_val_min =
-			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			dm_pstable->rssi_val_min = rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
 				 dm_pstable->rssi_val_min);
 		}
 	} else {
 		dm_pstable->rssi_val_min =
-		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+		    rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, DBG_LOUD, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
@@ -1368,7 +1357,7 @@ void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 
 	if (!rtlpriv->dm.dynamic_txpower_enable)
 		return;
@@ -1379,7 +1368,7 @@ void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	}
 
 	if ((mac->link_state < MAC80211_LINKED) &&
-	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+	    (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
 			 "Not connected to any\n");
 
@@ -1391,41 +1380,35 @@ void rtl92c_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		} else {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		}
 	} else {
-		undecorated_smoothed_pwdb =
-		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+		undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
-			 undecorated_smoothed_pwdb);
+			 undec_sm_pwdb);
 	}
 
-	if (undecorated_smoothed_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
+	if (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
-	} else if ((undecorated_smoothed_pwdb <
-		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
-		   (undecorated_smoothed_pwdb >=
-		    TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
+	} else if ((undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
+		   (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
-	} else if (undecorated_smoothed_pwdb <
-		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
+	} else if (undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_NORMAL\n");
@@ -1473,48 +1456,46 @@ u8 rtl92c_bt_rssi_state_change(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 	u8 curr_bt_rssi_state = 0x00;
 
 	if (rtlpriv->mac80211.link_state == MAC80211_LINKED) {
-		undecorated_smoothed_pwdb =
-				 GET_UNDECORATED_AVERAGE_RSSI(rtlpriv);
+		undec_sm_pwdb = GET_UNDECORATED_AVERAGE_RSSI(rtlpriv);
 	} else {
-		if (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)
-			undecorated_smoothed_pwdb = 100;
+		if (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)
+			undec_sm_pwdb = 100;
 		else
-			undecorated_smoothed_pwdb =
-				rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 	}
 
 	/* Check RSSI to determine HighPower/NormalPower state for
 	 * BT coexistence. */
-	if (undecorated_smoothed_pwdb >= 67)
+	if (undec_sm_pwdb >= 67)
 		curr_bt_rssi_state &= (~BT_RSSI_STATE_NORMAL_POWER);
-	else if (undecorated_smoothed_pwdb < 62)
+	else if (undec_sm_pwdb < 62)
 		curr_bt_rssi_state |= BT_RSSI_STATE_NORMAL_POWER;
 
 	/* Check RSSI to determine AMPDU setting for BT coexistence. */
-	if (undecorated_smoothed_pwdb >= 40)
+	if (undec_sm_pwdb >= 40)
 		curr_bt_rssi_state &= (~BT_RSSI_STATE_AMDPU_OFF);
-	else if (undecorated_smoothed_pwdb <= 32)
+	else if (undec_sm_pwdb <= 32)
 		curr_bt_rssi_state |= BT_RSSI_STATE_AMDPU_OFF;
 
 	/* Marked RSSI state. It will be used to determine BT coexistence
 	 * setting later. */
-	if (undecorated_smoothed_pwdb < 35)
+	if (undec_sm_pwdb < 35)
 		curr_bt_rssi_state |=  BT_RSSI_STATE_SPECIAL_LOW;
 	else
 		curr_bt_rssi_state &= (~BT_RSSI_STATE_SPECIAL_LOW);
 
 	/* Set Tx Power according to BT status. */
-	if (undecorated_smoothed_pwdb >= 30)
+	if (undec_sm_pwdb >= 30)
 		curr_bt_rssi_state |=  BT_RSSI_STATE_TXPOWER_LOW;
-	else if (undecorated_smoothed_pwdb < 25)
+	else if (undec_sm_pwdb < 25)
 		curr_bt_rssi_state &= (~BT_RSSI_STATE_TXPOWER_LOW);
 
 	/* Check BT state related to BT_Idle in B/G mode. */
-	if (undecorated_smoothed_pwdb < 15)
+	if (undec_sm_pwdb < 15)
 		curr_bt_rssi_state |=  BT_RSSI_STATE_BG_EDCA_LOW;
 	else
 		curr_bt_rssi_state &= (~BT_RSSI_STATE_BG_EDCA_LOW);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
index 6ae2268..1d5d360 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c
@@ -34,9 +34,6 @@
 #include "dm_common.h"
 #include "phy_common.h"
 
-/* Define macro to shorten lines */
-#define MCS_TXPWR	mcs_txpwrlevel_origoffset
-
 u32 rtl92c_phy_query_bb_reg(struct ieee80211_hw *hw, u32 regaddr, u32 bitmask)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -138,13 +135,13 @@ u32 _rtl92c_phy_rf_serial_read(struct ieee80211_hw *hw,
 		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XB_HSSIPARAMETER1,
 						 BIT(8));
 	if (rfpi_enable)
-		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readbackpi,
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rbpi,
 					 BLSSIREADBACKDATA);
 	else
-		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rb,
 					 BLSSIREADBACKDATA);
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x]=0x%x\n",
-		 rfpath, pphyreg->rflssi_readback, retvalue);
+		 rfpath, pphyreg->rf_rb, retvalue);
 	return retvalue;
 }
 EXPORT_SYMBOL(_rtl92c_phy_rf_serial_read);
@@ -290,11 +287,11 @@ void _rtl92c_store_pwrIndex_diffrate_offset(struct ieee80211_hw *hw,
 	else
 		return;
 
-	rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][index] = data;
+	rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][index] = data;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 		 "MCSTxPowerLevelOriginalOffset[%d][%d] = 0x%x\n",
 		 rtlphy->pwrgroup_cnt, index,
-		 rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][index]);
+		 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][index]);
 
 	if (index == 13)
 		rtlphy->pwrgroup_cnt++;
@@ -374,14 +371,10 @@ void _rtl92c_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_A].rfhssi_para2 = RFPGA0_XA_HSSIPARAMETER2;
 	rtlphy->phyreg_def[RF90_PATH_B].rfhssi_para2 = RFPGA0_XB_HSSIPARAMETER2;
 
-	rtlphy->phyreg_def[RF90_PATH_A].rfswitch_control =
-	    RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_B].rfswitch_control =
-	    RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_C].rfswitch_control =
-	    RFPGA0_XCD_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_D].rfswitch_control =
-	    RFPGA0_XCD_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_A].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_B].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_C].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_D].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
 
 	rtlphy->phyreg_def[RF90_PATH_A].rfagc_control1 = ROFDM0_XAAGCCORE1;
 	rtlphy->phyreg_def[RF90_PATH_B].rfagc_control1 = ROFDM0_XBAGCCORE1;
@@ -393,47 +386,33 @@ void _rtl92c_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_C].rfagc_control2 = ROFDM0_XCAGCCORE2;
 	rtlphy->phyreg_def[RF90_PATH_D].rfagc_control2 = ROFDM0_XDAGCCORE2;
 
-	rtlphy->phyreg_def[RF90_PATH_A].rfrxiq_imbalance =
-	    ROFDM0_XARXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_B].rfrxiq_imbalance =
-	    ROFDM0_XBRXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbalance =
-	    ROFDM0_XCRXIQIMBANLANCE;
-	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbalance =
-	    ROFDM0_XDRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_A].rfrxiq_imbal = ROFDM0_XARXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfrxiq_imbal = ROFDM0_XBRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbal = ROFDM0_XCRXIQIMBANLANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbal = ROFDM0_XDRXIQIMBALANCE;
 
 	rtlphy->phyreg_def[RF90_PATH_A].rfrx_afe = ROFDM0_XARXAFE;
 	rtlphy->phyreg_def[RF90_PATH_B].rfrx_afe = ROFDM0_XBRXAFE;
 	rtlphy->phyreg_def[RF90_PATH_C].rfrx_afe = ROFDM0_XCRXAFE;
 	rtlphy->phyreg_def[RF90_PATH_D].rfrx_afe = ROFDM0_XDRXAFE;
 
-	rtlphy->phyreg_def[RF90_PATH_A].rftxiq_imbalance =
-	    ROFDM0_XATXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_B].rftxiq_imbalance =
-	    ROFDM0_XBTXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbalance =
-	    ROFDM0_XCTXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbalance =
-	    ROFDM0_XDTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_A].rftxiq_imbal = ROFDM0_XATXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rftxiq_imbal = ROFDM0_XBTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbal = ROFDM0_XCTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbal = ROFDM0_XDTXIQIMBALANCE;
 
 	rtlphy->phyreg_def[RF90_PATH_A].rftx_afe = ROFDM0_XATXAFE;
 	rtlphy->phyreg_def[RF90_PATH_B].rftx_afe = ROFDM0_XBTXAFE;
 	rtlphy->phyreg_def[RF90_PATH_C].rftx_afe = ROFDM0_XCTXAFE;
 	rtlphy->phyreg_def[RF90_PATH_D].rftx_afe = ROFDM0_XDTXAFE;
 
-	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readback =
-	    RFPGA0_XA_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readback =
-	    RFPGA0_XB_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_C].rflssi_readback =
-	    RFPGA0_XC_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_D].rflssi_readback =
-	    RFPGA0_XD_LSSIREADBACK;
-
-	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readbackpi =
-	    TRANSCEIVEA_HSPI_READBACK;
-	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readbackpi =
-	    TRANSCEIVEB_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rb = RFPGA0_XA_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rb = RFPGA0_XB_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_C].rf_rb = RFPGA0_XC_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_D].rf_rb = RFPGA0_XD_LSSIREADBACK;
+
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rbpi = TRANSCEIVEA_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rbpi = TRANSCEIVEB_HSPI_READBACK;
 
 }
 EXPORT_SYMBOL(_rtl92c_phy_init_bb_rf_register_definition);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
index 27b3af8..74f9c08 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c
@@ -41,7 +41,7 @@ void rtl92ce_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 
 	if (!rtlpriv->dm.dynamic_txpower_enable)
 		return;
@@ -52,7 +52,7 @@ void rtl92ce_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	}
 
 	if ((mac->link_state < MAC80211_LINKED) &&
-	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+	    (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
 			 "Not connected to any\n");
 
@@ -64,41 +64,35 @@ void rtl92ce_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		} else {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		}
 	} else {
-		undecorated_smoothed_pwdb =
-		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+		undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
-			 undecorated_smoothed_pwdb);
+			 undec_sm_pwdb);
 	}
 
-	if (undecorated_smoothed_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
+	if (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
-	} else if ((undecorated_smoothed_pwdb <
-		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
-		   (undecorated_smoothed_pwdb >=
-		    TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
+	} else if ((undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
+		   (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
-	} else if (undecorated_smoothed_pwdb <
-		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
+	} else if (undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_NORMAL\n");
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 7dc7ac8..d1f34f6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -1403,9 +1403,9 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			tempval = hwinfo[EEPROM_TXPOWERHT40_2SDIFF + i];
 		else
 			tempval = EEPROM_DEFAULT_HT40_2SDIFF;
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_A][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_A][i] =
 		    (tempval & 0xf);
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_B][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_B][i] =
 		    ((tempval & 0xf0) >> 4);
 	}
 
@@ -1429,7 +1429,7 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
 				rtlefuse->
-				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
+				eprom_chnl_txpwr_ht40_2sdf[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
@@ -1444,14 +1444,14 @@ static void _rtl92ce_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			if ((rtlefuse->
 			     eeprom_chnlarea_txpwr_ht40_1s[rf_path][index] -
 			     rtlefuse->
-			     eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][index])
+			     eprom_chnl_txpwr_ht40_2sdf[rf_path][index])
 			    > 0) {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
 				    rtlefuse->
 				    eeprom_chnlarea_txpwr_ht40_1s[rf_path]
 				    [index] -
 				    rtlefuse->
-				    eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
+				    eprom_chnl_txpwr_ht40_2sdf[rf_path]
 				    [index];
 			} else {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] = 0;
@@ -2224,7 +2224,7 @@ static void rtl8192ce_bt_var_init(struct ieee80211_hw *hw)
 
 	if (rtlpcipriv->bt_coexist.reg_bt_iso == 2)
 		rtlpcipriv->bt_coexist.bt_ant_isolation =
-			rtlpcipriv->bt_coexist.eeprom_bt_ant_isolation;
+			rtlpcipriv->bt_coexist.eeprom_bt_ant_isol;
 	else
 		rtlpcipriv->bt_coexist.bt_ant_isolation =
 			rtlpcipriv->bt_coexist.reg_bt_iso;
@@ -2255,23 +2255,22 @@ void rtl8192ce_read_bt_coexist_info_from_hwpg(struct ieee80211_hw *hw,
 					      bool auto_load_fail, u8 *hwinfo)
 {
 	struct rtl_pci_priv *rtlpcipriv = rtl_pcipriv(hw);
-	u8 value;
+	u8 val;
 
 	if (!auto_load_fail) {
 		rtlpcipriv->bt_coexist.eeprom_bt_coexist =
 					((hwinfo[RF_OPTION1] & 0xe0) >> 5);
-		value = hwinfo[RF_OPTION4];
-		rtlpcipriv->bt_coexist.eeprom_bt_type = ((value & 0xe) >> 1);
-		rtlpcipriv->bt_coexist.eeprom_bt_ant_num = (value & 0x1);
-		rtlpcipriv->bt_coexist.eeprom_bt_ant_isolation =
-							 ((value & 0x10) >> 4);
+		val = hwinfo[RF_OPTION4];
+		rtlpcipriv->bt_coexist.eeprom_bt_type = ((val & 0xe) >> 1);
+		rtlpcipriv->bt_coexist.eeprom_bt_ant_num = (val & 0x1);
+		rtlpcipriv->bt_coexist.eeprom_bt_ant_isol = ((val & 0x10) >> 4);
 		rtlpcipriv->bt_coexist.eeprom_bt_radio_shared =
-							 ((value & 0x20) >> 5);
+							 ((val & 0x20) >> 5);
 	} else {
 		rtlpcipriv->bt_coexist.eeprom_bt_coexist = 0;
 		rtlpcipriv->bt_coexist.eeprom_bt_type = BT_2WIRE;
 		rtlpcipriv->bt_coexist.eeprom_bt_ant_num = ANT_X2;
-		rtlpcipriv->bt_coexist.eeprom_bt_ant_isolation = 0;
+		rtlpcipriv->bt_coexist.eeprom_bt_ant_isol = 0;
 		rtlpcipriv->bt_coexist.eeprom_bt_radio_shared = BT_RADIO_SHARED;
 	}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
index 54c7614..a9c406f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c
@@ -97,15 +97,12 @@ void rtl92ce_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 		}
 
 		if (rtlefuse->eeprom_regulatory == 0) {
-			tmpval =
-			    (rtlphy->mcs_txpwrlevel_origoffset[0][6]) +
-			    (rtlphy->mcs_txpwrlevel_origoffset[0][7] <<
-			     8);
+			tmpval = (rtlphy->mcs_offset[0][6]) +
+			    (rtlphy->mcs_offset[0][7] << 8);
 			tx_agc[RF90_PATH_A] += tmpval;
 
-			tmpval = (rtlphy->mcs_txpwrlevel_origoffset[0][14]) +
-				 (rtlphy->mcs_txpwrlevel_origoffset[0][15] <<
-				 24);
+			tmpval = (rtlphy->mcs_offset[0][14]) +
+				 (rtlphy->mcs_offset[0][15] << 24);
 			tx_agc[RF90_PATH_B] += tmpval;
 		}
 	}
@@ -209,8 +206,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 		case 0:
 			chnlgroup = 0;
 
-			writeVal =
-			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup][index +
+			writeVal = rtlphy->mcs_offset[chnlgroup][index +
 			    (rf ? 8 : 0)]
 			    + ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 
@@ -240,8 +236,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 						chnlgroup++;
 				}
 
-				writeVal =
-				    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+				writeVal = rtlphy->mcs_offset[chnlgroup]
 				    [index + (rf ? 8 : 0)] + ((index < 2) ?
 							      powerBase0[rf] :
 							      powerBase1[rf]);
@@ -276,8 +271,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 								    1]);
 			}
 			for (i = 0; i < 4; i++) {
-				pwr_diff_limit[i] =
-				    (u8) ((rtlphy->mcs_txpwrlevel_origoffset
+				pwr_diff_limit[i] = (u8) ((rtlphy->mcs_offset
 					  [chnlgroup][index +
 					  (rf ? 8 : 0)] & (0x7f << (i * 8))) >>
 					  (i * 8));
@@ -317,8 +311,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			break;
 		default:
 			chnlgroup = 0;
-			writeVal =
-			    rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+			writeVal = rtlphy->mcs_offset[chnlgroup]
 			    [index + (rf ? 8 : 0)]
 			    + ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index b8a3c03..d7e1f0a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -140,8 +140,8 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 	pstats->is_cck = is_cck_rate;
 	pstats->packet_beacon = packet_beacon;
 	pstats->is_cck = is_cck_rate;
-	pstats->rx_mimo_signalquality[0] = -1;
-	pstats->rx_mimo_signalquality[1] = -1;
+	pstats->rx_mimo_sig_qual[0] = -1;
+	pstats->rx_mimo_sig_qual[1] = -1;
 
 	if (is_cck_rate) {
 		u8 report, cck_highpwr;
@@ -211,8 +211,8 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 			}
 
 			pstats->signalquality = sq;
-			pstats->rx_mimo_signalquality[0] = sq;
-			pstats->rx_mimo_signalquality[1] = -1;
+			pstats->rx_mimo_sig_qual[0] = sq;
+			pstats->rx_mimo_sig_qual[1] = -1;
 		}
 	} else {
 		rtlpriv->dm.rfpath_rxenable[0] =
@@ -251,8 +251,7 @@ static void _rtl92ce_query_rxphystatus(struct ieee80211_hw *hw,
 				if (i == 0)
 					pstats->signalquality =
 					    (u8) (evm & 0xff);
-				pstats->rx_mimo_signalquality[i] =
-				    (u8) (evm & 0xff);
+				pstats->rx_mimo_sig_qual[i] = (u8) (evm & 0xff);
 			}
 		}
 	}
@@ -362,36 +361,31 @@ static void _rtl92ce_process_pwdb(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 
 	if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 		return;
 	} else {
-		undecorated_smoothed_pwdb =
-		    rtlpriv->dm.undecorated_smoothed_pwdb;
+		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
 	}
 
 	if (pstats->packet_toself || pstats->packet_beacon) {
-		if (undecorated_smoothed_pwdb < 0)
-			undecorated_smoothed_pwdb = pstats->rx_pwdb_all;
+		if (undec_sm_pwdb < 0)
+			undec_sm_pwdb = pstats->rx_pwdb_all;
 
-		if (pstats->rx_pwdb_all > (u32) undecorated_smoothed_pwdb) {
-			undecorated_smoothed_pwdb =
-			    (((undecorated_smoothed_pwdb) *
+		if (pstats->rx_pwdb_all > (u32) undec_sm_pwdb) {
+			undec_sm_pwdb = (((undec_sm_pwdb) *
 			      (RX_SMOOTH_FACTOR - 1)) +
 			     (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
 
-			undecorated_smoothed_pwdb = undecorated_smoothed_pwdb
-			    + 1;
+			undec_sm_pwdb += 1;
 		} else {
-			undecorated_smoothed_pwdb =
-			    (((undecorated_smoothed_pwdb) *
+			undec_sm_pwdb = (((undec_sm_pwdb) *
 			      (RX_SMOOTH_FACTOR - 1)) +
 			     (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
 		}
 
-		rtlpriv->dm.undecorated_smoothed_pwdb =
-		    undecorated_smoothed_pwdb;
+		rtlpriv->dm.undec_sm_pwdb = undec_sm_pwdb;
 		_rtl92ce_update_rxsignalstatistics(hw, pstats);
 	}
 }
@@ -438,15 +432,14 @@ static void _rtl92ce_process_ui_link_quality(struct ieee80211_hw *hw,
 			for (n_spatialstream = 0; n_spatialstream < 2;
 			     n_spatialstream++) {
 				if (pstats->
-				    rx_mimo_signalquality[n_spatialstream] !=
-				    -1) {
+				    rx_mimo_sig_qual[n_spatialstream] != -1) {
 					if (rtlpriv->stats.
 					    rx_evm_percentage[n_spatialstream]
 					    == 0) {
 						rtlpriv->stats.
 						   rx_evm_percentage
 						   [n_spatialstream] =
-						   pstats->rx_mimo_signalquality
+						   pstats->rx_mimo_sig_qual
 						   [n_spatialstream];
 					}
 
@@ -456,8 +449,7 @@ static void _rtl92ce_process_ui_link_quality(struct ieee80211_hw *hw,
 					      stats.rx_evm_percentage
 					      [n_spatialstream] *
 					      (RX_SMOOTH_FACTOR - 1)) +
-					     (pstats->
-					      rx_mimo_signalquality
+					     (pstats->rx_mimo_sig_qual
 					      [n_spatialstream] * 1)) /
 					    (RX_SMOOTH_FACTOR);
 				}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c b/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
index 6fd39ea..16a0b9e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c
@@ -39,7 +39,7 @@ void rtl92cu_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 
 	if (!rtlpriv->dm.dynamic_txpower_enable)
 		return;
@@ -50,7 +50,7 @@ void rtl92cu_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	}
 
 	if ((mac->link_state < MAC80211_LINKED) &&
-	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+	    (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
 			 "Not connected to any\n");
 
@@ -62,41 +62,35 @@ void rtl92cu_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		} else {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		}
 	} else {
-		undecorated_smoothed_pwdb =
-		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+		undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
-			 undecorated_smoothed_pwdb);
+			 undec_sm_pwdb);
 	}
 
-	if (undecorated_smoothed_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
+	if (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL2) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
-	} else if ((undecorated_smoothed_pwdb <
-		    (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
-		   (undecorated_smoothed_pwdb >=
-		    TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
+	} else if ((undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3)) &&
+		   (undec_sm_pwdb >= TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
 
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_LEVEL1;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
-	} else if (undecorated_smoothed_pwdb <
-		   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
+	} else if (undec_sm_pwdb < (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 		rtlpriv->dm.dynamic_txhighpower_lvl = TXHIGHPWRLEVEL_NORMAL;
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "TXHIGHPWRLEVEL_NORMAL\n");
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 7d36a94..b1ccff4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -152,9 +152,9 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			tempval = hwinfo[EEPROM_TXPOWERHT40_2SDIFF + i];
 		else
 			tempval = EEPROM_DEFAULT_HT40_2SDIFF;
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_A][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_A][i] =
 		    (tempval & 0xf);
-		rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[RF90_PATH_B][i] =
+		rtlefuse->eprom_chnl_txpwr_ht40_2sdf[RF90_PATH_B][i] =
 		    ((tempval & 0xf0) >> 4);
 	}
 	for (rf_path = 0; rf_path < 2; rf_path++)
@@ -177,7 +177,7 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
 				rtlefuse->
-				eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]);
+				eprom_chnl_txpwr_ht40_2sdf[rf_path][i]);
 	for (rf_path = 0; rf_path < 2; rf_path++) {
 		for (i = 0; i < 14; i++) {
 			index = _rtl92c_get_chnl_group((u8) i);
@@ -189,13 +189,13 @@ static void _rtl92cu_read_txpower_info_from_hwpg(struct ieee80211_hw *hw,
 			if ((rtlefuse->
 			     eeprom_chnlarea_txpwr_ht40_1s[rf_path][index] -
 			     rtlefuse->
-			     eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][index])
+			     eprom_chnl_txpwr_ht40_2sdf[rf_path][index])
 			    > 0) {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] =
 				    rtlefuse->
 				    eeprom_chnlarea_txpwr_ht40_1s[rf_path]
 				    [index] - rtlefuse->
-				    eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path]
+				    eprom_chnl_txpwr_ht40_2sdf[rf_path]
 				    [index];
 			} else {
 				rtlefuse->txpwrlevel_ht40_2s[rf_path][i] = 0;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
index 7e91c76..32ff959 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -46,7 +46,7 @@
 
 #define LINK_Q	ui_link_quality
 #define RX_EVM	rx_evm_percentage
-#define RX_SIGQ	rx_mimo_signalquality
+#define RX_SIGQ	rx_mimo_sig_qual
 
 
 void rtl92c_read_chip_version(struct ieee80211_hw *hw)
@@ -982,32 +982,27 @@ static void _rtl92c_process_pwdb(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb = 0;
+	long undec_sm_pwdb = 0;
 
 	if (mac->opmode == NL80211_IFTYPE_ADHOC) {
 		return;
 	} else {
-		undecorated_smoothed_pwdb =
-		    rtlpriv->dm.undecorated_smoothed_pwdb;
+		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
 	}
 	if (pstats->packet_toself || pstats->packet_beacon) {
-		if (undecorated_smoothed_pwdb < 0)
-			undecorated_smoothed_pwdb = pstats->rx_pwdb_all;
-		if (pstats->rx_pwdb_all > (u32) undecorated_smoothed_pwdb) {
-			undecorated_smoothed_pwdb =
-			    (((undecorated_smoothed_pwdb) *
+		if (undec_sm_pwdb < 0)
+			undec_sm_pwdb = pstats->rx_pwdb_all;
+		if (pstats->rx_pwdb_all > (u32) undec_sm_pwdb) {
+			undec_sm_pwdb = (((undec_sm_pwdb) *
 			      (RX_SMOOTH_FACTOR - 1)) +
 			     (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
-			undecorated_smoothed_pwdb = undecorated_smoothed_pwdb
-			    + 1;
+			undec_sm_pwdb += 1;
 		} else {
-			undecorated_smoothed_pwdb =
-			    (((undecorated_smoothed_pwdb) *
+			undec_sm_pwdb = (((undec_sm_pwdb) *
 			      (RX_SMOOTH_FACTOR - 1)) +
 			     (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
 		}
-		rtlpriv->dm.undecorated_smoothed_pwdb =
-		    undecorated_smoothed_pwdb;
+		rtlpriv->dm.undec_sm_pwdb = undec_sm_pwdb;
 		_rtl92c_update_rxsignalstatistics(hw, pstats);
 	}
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
index 506b9a0..953f1a0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
@@ -115,15 +115,11 @@ void rtl92cu_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 				    (ppowerlevel[idx1] << 24);
 			}
 			if (rtlefuse->eeprom_regulatory == 0) {
-				tmpval = (rtlphy->mcs_txpwrlevel_origoffset
-					[0][6]) +
-					(rtlphy->mcs_txpwrlevel_origoffset
-					[0][7] <<  8);
+				tmpval = (rtlphy->mcs_offset[0][6]) +
+					(rtlphy->mcs_offset[0][7] <<  8);
 				tx_agc[RF90_PATH_A] += tmpval;
-				tmpval = (rtlphy->mcs_txpwrlevel_origoffset
-					[0][14]) +
-					(rtlphy->mcs_txpwrlevel_origoffset
-					[0][15] << 24);
+				tmpval = (rtlphy->mcs_offset[0][14]) +
+					(rtlphy->mcs_offset[0][15] << 24);
 				tx_agc[RF90_PATH_B] += tmpval;
 			}
 		}
@@ -215,7 +211,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 		switch (rtlefuse->eeprom_regulatory) {
 		case 0:
 			chnlgroup = 0;
-			writeVal = rtlphy->mcs_txpwrlevel_origoffset
+			writeVal = rtlphy->mcs_offset
 			    [chnlgroup][index + (rf ? 8 : 0)]
 			    + ((index < 2) ? powerBase0[rf] : powerBase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
@@ -238,8 +234,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 				else
 					chnlgroup += 4;
 			}
-			writeVal = rtlphy->mcs_txpwrlevel_origoffset
-					[chnlgroup][index +
+			writeVal = rtlphy->mcs_offset[chnlgroup][index +
 					(rf ? 8 : 0)] +
 					((index < 2) ? powerBase0[rf] :
 					powerBase1[rf]);
@@ -271,8 +266,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 					[channel - 1]);
 			}
 			for (i = 0; i < 4; i++) {
-				pwr_diff_limit[i] =
-				    (u8) ((rtlphy->mcs_txpwrlevel_origoffset
+				pwr_diff_limit[i] = (u8) ((rtlphy->mcs_offset
 				    [chnlgroup][index + (rf ? 8 : 0)]
 				    & (0x7f << (i * 8))) >> (i * 8));
 				if (rtlphy->current_chan_bw ==
@@ -306,7 +300,7 @@ static void _rtl92c_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			break;
 		default:
 			chnlgroup = 0;
-			writeVal = rtlphy->mcs_txpwrlevel_origoffset[chnlgroup]
+			writeVal = rtlphy->mcs_offset[chnlgroup]
 				   [index + (rf ? 8 : 0)] + ((index < 2) ?
 				   powerBase0[rf] : powerBase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index ed868c3..fd8df23 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -35,7 +35,7 @@
 #include "dm.h"
 #include "fw.h"
 
-#define UNDEC_SM_PWDB	entry_min_undecoratedsmoothed_pwdb
+#define UNDEC_SM_PWDB	entry_min_undec_sm_pwdb
 
 static const u32 ofdmswing_table[OFDM_TABLE_SIZE_92D] = {
 	0x7f8001fe,		/* 0, +6.0dB */
@@ -164,18 +164,18 @@ static void rtl92d_dm_diginit(struct ieee80211_hw *hw)
 	de_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 	de_digtable->cur_igvalue = 0x20;
 	de_digtable->pre_igvalue = 0x0;
-	de_digtable->cursta_connectstate = DIG_STA_DISCONNECT;
-	de_digtable->presta_connectstate = DIG_STA_DISCONNECT;
-	de_digtable->curmultista_connectstate = DIG_MULTISTA_DISCONNECT;
+	de_digtable->cursta_cstate = DIG_STA_DISCONNECT;
+	de_digtable->presta_cstate = DIG_STA_DISCONNECT;
+	de_digtable->curmultista_cstate = DIG_MULTISTA_DISCONNECT;
 	de_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
 	de_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
 	de_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
 	de_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
 	de_digtable->rx_gain_range_max = DM_DIG_FA_UPPER;
 	de_digtable->rx_gain_range_min = DM_DIG_FA_LOWER;
-	de_digtable->backoff_val = DM_DIG_BACKOFF_DEFAULT;
-	de_digtable->backoff_val_range_max = DM_DIG_BACKOFF_MAX;
-	de_digtable->backoff_val_range_min = DM_DIG_BACKOFF_MIN;
+	de_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
+	de_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
+	de_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
 	de_digtable->pre_cck_pd_state = CCK_PD_STAGE_LOWRSSI;
 	de_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
 	de_digtable->large_fa_hit = 0;
@@ -273,35 +273,34 @@ static void rtl92d_dm_find_minimum_rssi(struct ieee80211_hw *hw)
 	/* Determine the minimum RSSI  */
 	if ((mac->link_state < MAC80211_LINKED) &&
 	    (rtlpriv->dm.UNDEC_SM_PWDB == 0)) {
-		de_digtable->min_undecorated_pwdb_for_dm = 0;
+		de_digtable->min_undec_pwdb_for_dm = 0;
 		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
 			 "Not connected to any\n");
 	}
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_AP ||
 		    mac->opmode == NL80211_IFTYPE_ADHOC) {
-			de_digtable->min_undecorated_pwdb_for_dm =
+			de_digtable->min_undec_pwdb_for_dm =
 			    rtlpriv->dm.UNDEC_SM_PWDB;
 			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
 				 rtlpriv->dm.UNDEC_SM_PWDB);
 		} else {
-			de_digtable->min_undecorated_pwdb_for_dm =
-			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			de_digtable->min_undec_pwdb_for_dm =
+			    rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%x\n",
-				 de_digtable->min_undecorated_pwdb_for_dm);
+				 de_digtable->min_undec_pwdb_for_dm);
 		}
 	} else {
-		de_digtable->min_undecorated_pwdb_for_dm =
-		    rtlpriv->dm.UNDEC_SM_PWDB;
+		de_digtable->min_undec_pwdb_for_dm = rtlpriv->dm.UNDEC_SM_PWDB;
 		RT_TRACE(rtlpriv, COMP_BB_POWERSAVING, DBG_LOUD,
 			 "AP Ext Port or disconnect PWDB = 0x%x\n",
-			 de_digtable->min_undecorated_pwdb_for_dm);
+			 de_digtable->min_undec_pwdb_for_dm);
 	}
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "MinUndecoratedPWDBForDM =%d\n",
-		 de_digtable->min_undecorated_pwdb_for_dm);
+		 de_digtable->min_undec_pwdb_for_dm);
 }
 
 static void rtl92d_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
@@ -310,16 +309,16 @@ static void rtl92d_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 	struct dig_t *de_digtable = &rtlpriv->dm_digtable;
 	unsigned long flag = 0;
 
-	if (de_digtable->cursta_connectstate == DIG_STA_CONNECT) {
+	if (de_digtable->cursta_cstate == DIG_STA_CONNECT) {
 		if (de_digtable->pre_cck_pd_state == CCK_PD_STAGE_LOWRSSI) {
-			if (de_digtable->min_undecorated_pwdb_for_dm <= 25)
+			if (de_digtable->min_undec_pwdb_for_dm <= 25)
 				de_digtable->cur_cck_pd_state =
 							 CCK_PD_STAGE_LOWRSSI;
 			else
 				de_digtable->cur_cck_pd_state =
 							 CCK_PD_STAGE_HIGHRSSI;
 		} else {
-			if (de_digtable->min_undecorated_pwdb_for_dm <= 20)
+			if (de_digtable->min_undec_pwdb_for_dm <= 20)
 				de_digtable->cur_cck_pd_state =
 							 CCK_PD_STAGE_LOWRSSI;
 			else
@@ -342,7 +341,7 @@ static void rtl92d_dm_cck_packet_detection_thresh(struct ieee80211_hw *hw)
 		de_digtable->pre_cck_pd_state = de_digtable->cur_cck_pd_state;
 	}
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "CurSTAConnectState=%s\n",
-		 de_digtable->cursta_connectstate == DIG_STA_CONNECT ?
+		 de_digtable->cursta_cstate == DIG_STA_CONNECT ?
 		 "DIG_STA_CONNECT " : "DIG_STA_DISCONNECT");
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "CCKPDStage=%s\n",
 		 de_digtable->cur_cck_pd_state == CCK_PD_STAGE_LOWRSSI ?
@@ -358,9 +357,9 @@ void rtl92d_dm_write_dig(struct ieee80211_hw *hw)
 	struct dig_t *de_digtable = &rtlpriv->dm_digtable;
 
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
-		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, backoff_val = %d\n",
+		 "cur_igvalue = 0x%x, pre_igvalue = 0x%x, back_val = %d\n",
 		 de_digtable->cur_igvalue, de_digtable->pre_igvalue,
-		 de_digtable->backoff_val);
+		 de_digtable->back_val);
 	if (de_digtable->dig_enable_flag == false) {
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "DIG is disabled\n");
 		de_digtable->pre_igvalue = 0x17;
@@ -382,13 +381,13 @@ static void rtl92d_early_mode_enabled(struct rtl_priv *rtlpriv)
 	if ((rtlpriv->mac80211.link_state >= MAC80211_LINKED) &&
 	    (rtlpriv->mac80211.vendor == PEER_CISCO)) {
 		RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "IOT_PEER = CISCO\n");
-		if (de_digtable->last_min_undecorated_pwdb_for_dm >= 50
-		    && de_digtable->min_undecorated_pwdb_for_dm < 50) {
+		if (de_digtable->last_min_undec_pwdb_for_dm >= 50
+		    && de_digtable->min_undec_pwdb_for_dm < 50) {
 			rtl_write_byte(rtlpriv, REG_EARLY_MODE_CONTROL, 0x00);
 			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
 				 "Early Mode Off\n");
-		} else if (de_digtable->last_min_undecorated_pwdb_for_dm <= 55 &&
-			   de_digtable->min_undecorated_pwdb_for_dm > 55) {
+		} else if (de_digtable->last_min_undec_pwdb_for_dm <= 55 &&
+			   de_digtable->min_undec_pwdb_for_dm > 55) {
 			rtl_write_byte(rtlpriv, REG_EARLY_MODE_CONTROL, 0x0f);
 			RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD,
 				 "Early Mode On\n");
@@ -409,8 +408,8 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "==>\n");
 	if (rtlpriv->rtlhal.earlymode_enable) {
 		rtl92d_early_mode_enabled(rtlpriv);
-		de_digtable->last_min_undecorated_pwdb_for_dm =
-				 de_digtable->min_undecorated_pwdb_for_dm;
+		de_digtable->last_min_undec_pwdb_for_dm =
+				 de_digtable->min_undec_pwdb_for_dm;
 	}
 	if (!rtlpriv->dm.dm_initialgain_enable)
 		return;
@@ -428,9 +427,9 @@ static void rtl92d_dm_dig(struct ieee80211_hw *hw)
 	RT_TRACE(rtlpriv, COMP_DIG, DBG_LOUD, "progress\n");
 	/* Decide the current status and if modify initial gain or not */
 	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED)
-		de_digtable->cursta_connectstate = DIG_STA_CONNECT;
+		de_digtable->cursta_cstate = DIG_STA_CONNECT;
 	else
-		de_digtable->cursta_connectstate = DIG_STA_DISCONNECT;
+		de_digtable->cursta_cstate = DIG_STA_DISCONNECT;
 
 	/* adjust initial gain according to false alarm counter */
 	if (falsealm_cnt->cnt_all < DM_DIG_FA_TH0)
@@ -522,7 +521,7 @@ static void rtl92d_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 
 	if ((!rtlpriv->dm.dynamic_txpower_enable)
 	    || rtlpriv->dm.dm_flag & HAL_DM_HIPWR_DISABLE) {
@@ -539,62 +538,62 @@ static void rtl92d_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	}
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-			undecorated_smoothed_pwdb =
+			undec_sm_pwdb =
 			    rtlpriv->dm.UNDEC_SM_PWDB;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "IBSS Client PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		} else {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			undec_sm_pwdb =
+			    rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		}
 	} else {
-		undecorated_smoothed_pwdb =
+		undec_sm_pwdb =
 		    rtlpriv->dm.UNDEC_SM_PWDB;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
-			 undecorated_smoothed_pwdb);
+			 undec_sm_pwdb);
 	}
 	if (rtlhal->current_bandtype == BAND_ON_5G) {
-		if (undecorated_smoothed_pwdb >= 0x33) {
+		if (undec_sm_pwdb >= 0x33) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL2;
 			RT_TRACE(rtlpriv, COMP_HIPWR, DBG_LOUD,
 				 "5G:TxHighPwrLevel_Level2 (TxPwr=0x0)\n");
-		} else if ((undecorated_smoothed_pwdb < 0x33)
-			   && (undecorated_smoothed_pwdb >= 0x2b)) {
+		} else if ((undec_sm_pwdb < 0x33)
+			   && (undec_sm_pwdb >= 0x2b)) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL1;
 			RT_TRACE(rtlpriv, COMP_HIPWR, DBG_LOUD,
 				 "5G:TxHighPwrLevel_Level1 (TxPwr=0x10)\n");
-		} else if (undecorated_smoothed_pwdb < 0x2b) {
+		} else if (undec_sm_pwdb < 0x2b) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_NORMAL;
 			RT_TRACE(rtlpriv, COMP_HIPWR, DBG_LOUD,
 				 "5G:TxHighPwrLevel_Normal\n");
 		}
 	} else {
-		if (undecorated_smoothed_pwdb >=
+		if (undec_sm_pwdb >=
 		    TX_POWER_NEAR_FIELD_THRESH_LVL2) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL2;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x0)\n");
 		} else
-		    if ((undecorated_smoothed_pwdb <
+		    if ((undec_sm_pwdb <
 			 (TX_POWER_NEAR_FIELD_THRESH_LVL2 - 3))
-			&& (undecorated_smoothed_pwdb >=
+			&& (undec_sm_pwdb >=
 			    TX_POWER_NEAR_FIELD_THRESH_LVL1)) {
 
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_LEVEL1;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "TXHIGHPWRLEVEL_LEVEL1 (TxPwr=0x10)\n");
-		} else if (undecorated_smoothed_pwdb <
+		} else if (undec_sm_pwdb <
 			   (TX_POWER_NEAR_FIELD_THRESH_LVL1 - 5)) {
 			rtlpriv->dm.dynamic_txhighpower_lvl =
 						 TXHIGHPWRLEVEL_NORMAL;
@@ -620,7 +619,7 @@ static void rtl92d_dm_pwdb_monitor(struct ieee80211_hw *hw)
 		return;
 	/* Indicate Rx signal strength to FW. */
 	if (rtlpriv->dm.useramask) {
-		u32 temp = rtlpriv->dm.undecorated_smoothed_pwdb;
+		u32 temp = rtlpriv->dm.undec_sm_pwdb;
 
 		temp <<= 16;
 		temp |= 0x100;
@@ -629,7 +628,7 @@ static void rtl92d_dm_pwdb_monitor(struct ieee80211_hw *hw)
 		rtl92d_fill_h2c_cmd(hw, H2C_RSSI_REPORT, 3, (u8 *) (&temp));
 	} else {
 		rtl_write_byte(rtlpriv, 0x4fe,
-			       (u8) rtlpriv->dm.undecorated_smoothed_pwdb);
+			       (u8) rtlpriv->dm.undec_sm_pwdb);
 	}
 }
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
index db00860..33041bd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/phy.c
@@ -298,13 +298,13 @@ static u32 _rtl92d_phy_rf_serial_read(struct ieee80211_hw *hw,
 		rfpi_enable = (u8) rtl_get_bbreg(hw, RFPGA0_XB_HSSIPARAMETER1,
 			      BIT(8));
 	if (rfpi_enable)
-		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readbackpi,
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rbpi,
 			BLSSIREADBACKDATA);
 	else
-		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rb,
 			BLSSIREADBACKDATA);
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x] = 0x%x\n",
-		 rfpath, pphyreg->rflssi_readback, retvalue);
+		 rfpath, pphyreg->rf_rb, retvalue);
 	return retvalue;
 }
 
@@ -478,14 +478,10 @@ static void _rtl92d_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
 
 	/* RF switch Control */
 	/* TR/Ant switch control */
-	rtlphy->phyreg_def[RF90_PATH_A].rfswitch_control =
-		RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_B].rfswitch_control =
-	    RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_C].rfswitch_control =
-	    RFPGA0_XCD_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_D].rfswitch_control =
-	    RFPGA0_XCD_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_A].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_B].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_C].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_D].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
 
 	/* AGC control 1 */
 	rtlphy->phyreg_def[RF90_PATH_A].rfagc_control1 = ROFDM0_XAAGCCORE1;
@@ -500,14 +496,10 @@ static void _rtl92d_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_D].rfagc_control2 = ROFDM0_XDAGCCORE2;
 
 	/* RX AFE control 1 */
-	rtlphy->phyreg_def[RF90_PATH_A].rfrxiq_imbalance =
-	    ROFDM0_XARXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_B].rfrxiq_imbalance =
-	    ROFDM0_XBRXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbalance =
-	    ROFDM0_XCRXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbalance =
-	    ROFDM0_XDRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_A].rfrxiq_imbal = ROFDM0_XARXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfrxiq_imbal = ROFDM0_XBRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbal = ROFDM0_XCRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbal = ROFDM0_XDRXIQIMBALANCE;
 
 	/*RX AFE control 1 */
 	rtlphy->phyreg_def[RF90_PATH_A].rfrx_afe = ROFDM0_XARXAFE;
@@ -516,14 +508,10 @@ static void _rtl92d_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_D].rfrx_afe = ROFDM0_XDRXAFE;
 
 	/* Tx AFE control 1 */
-	rtlphy->phyreg_def[RF90_PATH_A].rftxiq_imbalance =
-	    ROFDM0_XATxIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_B].rftxiq_imbalance =
-	    ROFDM0_XBTxIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbalance =
-	    ROFDM0_XCTxIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbalance =
-	    ROFDM0_XDTxIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_A].rftxiq_imbal = ROFDM0_XATxIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rftxiq_imbal = ROFDM0_XBTxIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbal = ROFDM0_XCTxIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbal = ROFDM0_XDTxIQIMBALANCE;
 
 	/* Tx AFE control 2 */
 	rtlphy->phyreg_def[RF90_PATH_A].rftx_afe = ROFDM0_XATxAFE;
@@ -532,20 +520,14 @@ static void _rtl92d_phy_init_bb_rf_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_D].rftx_afe = ROFDM0_XDTxAFE;
 
 	/* Tranceiver LSSI Readback SI mode */
-	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readback =
-	    RFPGA0_XA_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readback =
-	    RFPGA0_XB_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_C].rflssi_readback =
-	    RFPGA0_XC_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_D].rflssi_readback =
-	    RFPGA0_XD_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rb = RFPGA0_XA_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rb = RFPGA0_XB_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_C].rf_rb = RFPGA0_XC_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_D].rf_rb = RFPGA0_XD_LSSIREADBACK;
 
 	/* Tranceiver LSSI Readback PI mode */
-	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readbackpi =
-	    TRANSCEIVERA_HSPI_READBACK;
-	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readbackpi =
-	    TRANSCEIVERB_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rbpi = TRANSCEIVERA_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rbpi = TRANSCEIVERB_HSPI_READBACK;
 }
 
 static bool _rtl92d_phy_config_bb_with_headerfile(struct ieee80211_hw *hw,
@@ -702,12 +684,11 @@ static void _rtl92d_store_pwrindex_diffrate_offset(struct ieee80211_hw *hw,
 	else
 		return;
 
-	rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][index] = data;
+	rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][index] = data;
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
 		 "MCSTxPowerLevelOriginalOffset[%d][%d] = 0x%ulx\n",
 		 rtlphy->pwrgroup_cnt, index,
-		 rtlphy->mcs_txpwrlevel_origoffset
-		 [rtlphy->pwrgroup_cnt][index]);
+		 rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][index]);
 	if (index == 13)
 		rtlphy->pwrgroup_cnt++;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
index 3066a7f..20144e0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/rf.c
@@ -106,11 +106,11 @@ void rtl92d_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 			    (ppowerlevel[idx1] << 24);
 		}
 		if (rtlefuse->eeprom_regulatory == 0) {
-			tmpval = (rtlphy->mcs_txpwrlevel_origoffset[0][6]) +
-			    (rtlphy->mcs_txpwrlevel_origoffset[0][7] << 8);
+			tmpval = (rtlphy->mcs_offset[0][6]) +
+			    (rtlphy->mcs_offset[0][7] << 8);
 			tx_agc[RF90_PATH_A] += tmpval;
-			tmpval = (rtlphy->mcs_txpwrlevel_origoffset[0][14]) +
-			    (rtlphy->mcs_txpwrlevel_origoffset[0][15] << 24);
+			tmpval = (rtlphy->mcs_offset[0][14]) +
+			    (rtlphy->mcs_offset[0][15] << 24);
 			tx_agc[RF90_PATH_B] += tmpval;
 		}
 	}
@@ -227,7 +227,7 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 		switch (rtlefuse->eeprom_regulatory) {
 		case 0:
 			chnlgroup = 0;
-			writeval = rtlphy->mcs_txpwrlevel_origoffset
+			writeval = rtlphy->mcs_offset
 					[chnlgroup][index +
 					(rf ? 8 : 0)] + ((index < 2) ?
 					powerbase0[rf] :
@@ -247,7 +247,7 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 					chnlgroup++;
 				else
 					chnlgroup += 4;
-				writeval = rtlphy->mcs_txpwrlevel_origoffset
+				writeval = rtlphy->mcs_offset
 						[chnlgroup][index +
 						(rf ? 8 : 0)] + ((index < 2) ?
 						powerbase0[rf] :
@@ -280,8 +280,7 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 					[channel - 1]);
 			}
 			for (i = 0; i < 4; i++) {
-				pwr_diff_limit[i] =
-					(u8)((rtlphy->mcs_txpwrlevel_origoffset
+				pwr_diff_limit[i] = (u8)((rtlphy->mcs_offset
 					[chnlgroup][index + (rf ? 8 : 0)] &
 					(0x7f << (i * 8))) >> (i * 8));
 				if (rtlphy->current_chan_bw ==
@@ -316,8 +315,7 @@ static void _rtl92d_get_txpower_writeval_by_regulatory(struct ieee80211_hw *hw,
 			break;
 		default:
 			chnlgroup = 0;
-			writeval = rtlphy->mcs_txpwrlevel_origoffset
-				   [chnlgroup][index +
+			writeval = rtlphy->mcs_offset[chnlgroup][index +
 				   (rf ? 8 : 0)] + ((index < 2) ?
 				   powerbase0[rf] : powerbase1[rf]);
 			RTPRINT(rtlpriv, FPHY, PHY_TXPWR,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 4686f34..35bb9da 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -132,8 +132,8 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 	pstats->packet_toself = packet_toself;
 	pstats->packet_beacon = packet_beacon;
 	pstats->is_cck = is_cck_rate;
-	pstats->rx_mimo_signalquality[0] = -1;
-	pstats->rx_mimo_signalquality[1] = -1;
+	pstats->rx_mimo_sig_qual[0] = -1;
+	pstats->rx_mimo_sig_qual[1] = -1;
 
 	if (is_cck_rate) {
 		u8 report, cck_highpwr;
@@ -212,8 +212,8 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 					sq = ((64 - sq) * 100) / 44;
 			}
 			pstats->signalquality = sq;
-			pstats->rx_mimo_signalquality[0] = sq;
-			pstats->rx_mimo_signalquality[1] = -1;
+			pstats->rx_mimo_sig_qual[0] = sq;
+			pstats->rx_mimo_sig_qual[1] = -1;
 		}
 	} else {
 		rtlpriv->dm.rfpath_rxenable[0] = true;
@@ -246,7 +246,7 @@ static void _rtl92de_query_rxphystatus(struct ieee80211_hw *hw,
 				if (i == 0)
 					pstats->signalquality =
 						 (u8)(evm & 0xff);
-				pstats->rx_mimo_signalquality[i] =
+				pstats->rx_mimo_sig_qual[i] =
 						 (u8)(evm & 0xff);
 			}
 		}
@@ -345,33 +345,28 @@ static void _rtl92de_process_pwdb(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 
 	if (mac->opmode == NL80211_IFTYPE_ADHOC	||
 		mac->opmode == NL80211_IFTYPE_AP)
 		return;
 	else
-		undecorated_smoothed_pwdb =
-		    rtlpriv->dm.undecorated_smoothed_pwdb;
+		undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
 
 	if (pstats->packet_toself || pstats->packet_beacon) {
-		if (undecorated_smoothed_pwdb < 0)
-			undecorated_smoothed_pwdb = pstats->rx_pwdb_all;
-		if (pstats->rx_pwdb_all > (u32) undecorated_smoothed_pwdb) {
-			undecorated_smoothed_pwdb =
-			      (((undecorated_smoothed_pwdb) *
+		if (undec_sm_pwdb < 0)
+			undec_sm_pwdb = pstats->rx_pwdb_all;
+		if (pstats->rx_pwdb_all > (u32) undec_sm_pwdb) {
+			undec_sm_pwdb = (((undec_sm_pwdb) *
 			      (RX_SMOOTH_FACTOR - 1)) +
 			      (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
-			undecorated_smoothed_pwdb =
-			      undecorated_smoothed_pwdb + 1;
+			undec_sm_pwdb = undec_sm_pwdb + 1;
 		} else {
-			undecorated_smoothed_pwdb =
-			      (((undecorated_smoothed_pwdb) *
+			undec_sm_pwdb = (((undec_sm_pwdb) *
 			      (RX_SMOOTH_FACTOR - 1)) +
 			      (pstats->rx_pwdb_all)) / (RX_SMOOTH_FACTOR);
 		}
-		rtlpriv->dm.undecorated_smoothed_pwdb =
-				 undecorated_smoothed_pwdb;
+		rtlpriv->dm.undec_sm_pwdb = undec_sm_pwdb;
 		_rtl92de_update_rxsignalstatistics(hw, pstats);
 	}
 }
@@ -383,15 +378,15 @@ static void rtl92d_loop_over_streams(struct ieee80211_hw *hw,
 	int stream;
 
 	for (stream = 0; stream < 2; stream++) {
-		if (pstats->rx_mimo_signalquality[stream] != -1) {
+		if (pstats->rx_mimo_sig_qual[stream] != -1) {
 			if (rtlpriv->stats.rx_evm_percentage[stream] == 0) {
 				rtlpriv->stats.rx_evm_percentage[stream] =
-				    pstats->rx_mimo_signalquality[stream];
+				    pstats->rx_mimo_sig_qual[stream];
 			}
 			rtlpriv->stats.rx_evm_percentage[stream] =
 			    ((rtlpriv->stats.rx_evm_percentage[stream]
 			      * (RX_SMOOTH_FACTOR - 1)) +
-			     (pstats->rx_mimo_signalquality[stream] * 1)) /
+			     (pstats->rx_mimo_sig_qual[stream] * 1)) /
 			    (RX_SMOOTH_FACTOR);
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
index 465f581..bf79a52 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
@@ -267,13 +267,12 @@ static void _rtl92s_dm_refresh_rateadaptive_mask(struct ieee80211_hw *hw)
 			break;
 		}
 
-		if (rtlpriv->dm.undecorated_smoothed_pwdb >
-		    (long)high_rssi_thresh) {
+		if (rtlpriv->dm.undec_sm_pwdb > (long)high_rssi_thresh) {
 			ra->ratr_state = DM_RATR_STA_HIGH;
-		} else if (rtlpriv->dm.undecorated_smoothed_pwdb >
+		} else if (rtlpriv->dm.undec_sm_pwdb >
 			   (long)middle_rssi_thresh) {
 			ra->ratr_state = DM_RATR_STA_LOW;
-		} else if (rtlpriv->dm.undecorated_smoothed_pwdb >
+		} else if (rtlpriv->dm.undec_sm_pwdb >
 			   (long)low_rssi_thresh) {
 			ra->ratr_state = DM_RATR_STA_LOW;
 		} else {
@@ -283,8 +282,7 @@ static void _rtl92s_dm_refresh_rateadaptive_mask(struct ieee80211_hw *hw)
 		if (ra->pre_ratr_state != ra->ratr_state) {
 			RT_TRACE(rtlpriv, COMP_RATE, DBG_LOUD,
 				 "RSSI = %ld RSSI_LEVEL = %d PreState = %d, CurState = %d\n",
-				 rtlpriv->dm.undecorated_smoothed_pwdb,
-				 ra->ratr_state,
+				 rtlpriv->dm.undec_sm_pwdb, ra->ratr_state,
 				 ra->pre_ratr_state, ra->ratr_state);
 
 			rtlpriv->cfg->ops->update_rate_tbl(hw, sta,
@@ -316,7 +314,7 @@ static void _rtl92s_dm_switch_baseband_mrc(struct ieee80211_hw *hw)
 	rtlpriv->cfg->ops->get_hw_reg(hw, HW_VAR_MRC, (u8 *)(&current_mrc));
 
 	if (mac->link_state >= MAC80211_LINKED) {
-		if (rtlpriv->dm.undecorated_smoothed_pwdb > tmpentry_maxpwdb) {
+		if (rtlpriv->dm.undec_sm_pwdb > tmpentry_maxpwdb) {
 			rssi_a = rtlpriv->stats.rx_rssi_percentage[RF90_PATH_A];
 			rssi_b = rtlpriv->stats.rx_rssi_percentage[RF90_PATH_B];
 		}
@@ -424,18 +422,18 @@ static void rtl92s_backoff_enable_flag(struct ieee80211_hw *hw)
 	struct false_alarm_statistics *falsealm_cnt = &(rtlpriv->falsealm_cnt);
 
 	if (falsealm_cnt->cnt_all > digtable->fa_highthresh) {
-		if ((digtable->backoff_val - 6) <
+		if ((digtable->back_val - 6) <
 			digtable->backoffval_range_min)
-			digtable->backoff_val = digtable->backoffval_range_min;
+			digtable->back_val = digtable->backoffval_range_min;
 		else
-			digtable->backoff_val -= 6;
+			digtable->back_val -= 6;
 	} else if (falsealm_cnt->cnt_all < digtable->fa_lowthresh) {
-		if ((digtable->backoff_val + 6) >
+		if ((digtable->back_val + 6) >
 			digtable->backoffval_range_max)
-			digtable->backoff_val =
+			digtable->back_val =
 				 digtable->backoffval_range_max;
 		else
-			digtable->backoff_val += 6;
+			digtable->back_val += 6;
 	}
 }
 
@@ -447,28 +445,28 @@ static void _rtl92s_dm_initial_gain_sta_beforeconnect(struct ieee80211_hw *hw)
 	static u8 initialized, force_write;
 	u8 initial_gain = 0;
 
-	if ((digtable->pre_sta_connectstate == digtable->cur_sta_connectstate) ||
-		(digtable->cur_sta_connectstate == DIG_STA_BEFORE_CONNECT)) {
-		if (digtable->cur_sta_connectstate == DIG_STA_BEFORE_CONNECT) {
+	if ((digtable->pre_sta_cstate == digtable->cur_sta_cstate) ||
+	    (digtable->cur_sta_cstate == DIG_STA_BEFORE_CONNECT)) {
+		if (digtable->cur_sta_cstate == DIG_STA_BEFORE_CONNECT) {
 			if (rtlpriv->psc.rfpwr_state != ERFON)
 				return;
 
 			if (digtable->backoff_enable_flag)
 				rtl92s_backoff_enable_flag(hw);
 			else
-				digtable->backoff_val = DM_DIG_BACKOFF;
+				digtable->back_val = DM_DIG_BACKOFF;
 
-			if ((digtable->rssi_val + 10 - digtable->backoff_val) >
+			if ((digtable->rssi_val + 10 - digtable->back_val) >
 				digtable->rx_gain_range_max)
 				digtable->cur_igvalue =
 						digtable->rx_gain_range_max;
-			else if ((digtable->rssi_val + 10 - digtable->backoff_val)
+			else if ((digtable->rssi_val + 10 - digtable->back_val)
 				 < digtable->rx_gain_range_min)
 				digtable->cur_igvalue =
 						digtable->rx_gain_range_min;
 			else
 				digtable->cur_igvalue = digtable->rssi_val + 10 -
-						digtable->backoff_val;
+						digtable->back_val;
 
 			if (falsealm_cnt->cnt_all > 10000)
 				digtable->cur_igvalue =
@@ -490,7 +488,7 @@ static void _rtl92s_dm_initial_gain_sta_beforeconnect(struct ieee80211_hw *hw)
 		digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
 		rtl92s_phy_set_fw_cmd(hw, FW_CMD_DIG_ENABLE);
 
-		digtable->backoff_val = DM_DIG_BACKOFF;
+		digtable->back_val = DM_DIG_BACKOFF;
 		digtable->cur_igvalue = rtlpriv->phy.default_initialgain[0];
 		digtable->pre_igvalue = 0;
 		return;
@@ -528,14 +526,14 @@ static void _rtl92s_dm_ctrl_initgain_bytwoport(struct ieee80211_hw *hw)
 	/* Decide the current status and if modify initial gain or not */
 	if (rtlpriv->mac80211.link_state >= MAC80211_LINKED ||
 	    rtlpriv->mac80211.opmode == NL80211_IFTYPE_ADHOC)
-		digtable->cur_sta_connectstate = DIG_STA_CONNECT;
+		digtable->cur_sta_cstate = DIG_STA_CONNECT;
 	else
-		digtable->cur_sta_connectstate = DIG_STA_DISCONNECT;
+		digtable->cur_sta_cstate = DIG_STA_DISCONNECT;
 
-	digtable->rssi_val = rtlpriv->dm.undecorated_smoothed_pwdb;
+	digtable->rssi_val = rtlpriv->dm.undec_sm_pwdb;
 
 	/* Change dig mode to rssi */
-	if (digtable->cur_sta_connectstate != DIG_STA_DISCONNECT) {
+	if (digtable->cur_sta_cstate != DIG_STA_DISCONNECT) {
 		if (digtable->dig_twoport_algorithm ==
 		    DIG_TWO_PORT_ALGO_FALSE_ALARM) {
 			digtable->dig_twoport_algorithm = DIG_TWO_PORT_ALGO_RSSI;
@@ -546,7 +544,7 @@ static void _rtl92s_dm_ctrl_initgain_bytwoport(struct ieee80211_hw *hw)
 	_rtl92s_dm_false_alarm_counter_statistics(hw);
 	_rtl92s_dm_initial_gain_sta_beforeconnect(hw);
 
-	digtable->pre_sta_connectstate = digtable->cur_sta_connectstate;
+	digtable->pre_sta_cstate = digtable->cur_sta_cstate;
 }
 
 static void _rtl92s_dm_ctrl_initgain_byrssi(struct ieee80211_hw *hw)
@@ -573,7 +571,7 @@ static void _rtl92s_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_phy *rtlphy = &(rtlpriv->phy);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 	long txpwr_threshold_lv1, txpwr_threshold_lv2;
 
 	/* 2T2R TP issue */
@@ -587,7 +585,7 @@ static void _rtl92s_dm_dynamic_txpower(struct ieee80211_hw *hw)
 	}
 
 	if ((mac->link_state < MAC80211_LINKED) &&
-	    (rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb == 0)) {
+	    (rtlpriv->dm.entry_min_undec_sm_pwdb == 0)) {
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_TRACE,
 			 "Not connected to any\n");
 
@@ -599,25 +597,22 @@ static void _rtl92s_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 	if (mac->link_state >= MAC80211_LINKED) {
 		if (mac->opmode == NL80211_IFTYPE_ADHOC) {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "AP Client PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		} else {
-			undecorated_smoothed_pwdb =
-			    rtlpriv->dm.undecorated_smoothed_pwdb;
+			undec_sm_pwdb = rtlpriv->dm.undec_sm_pwdb;
 			RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 				 "STA Default Port PWDB = 0x%lx\n",
-				 undecorated_smoothed_pwdb);
+				 undec_sm_pwdb);
 		}
 	} else {
-		undecorated_smoothed_pwdb =
-		    rtlpriv->dm.entry_min_undecoratedsmoothed_pwdb;
+		undec_sm_pwdb = rtlpriv->dm.entry_min_undec_sm_pwdb;
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "AP Ext Port PWDB = 0x%lx\n",
-			 undecorated_smoothed_pwdb);
+			 undec_sm_pwdb);
 	}
 
 	txpwr_threshold_lv2 = TX_POWER_NEAR_FIELD_THRESH_LVL2;
@@ -625,12 +620,12 @@ static void _rtl92s_dm_dynamic_txpower(struct ieee80211_hw *hw)
 
 	if (rtl_get_bbreg(hw, 0xc90, MASKBYTE0) == 1)
 		rtlpriv->dm.dynamic_txhighpower_lvl = TX_HIGHPWR_LEVEL_NORMAL;
-	else if (undecorated_smoothed_pwdb >= txpwr_threshold_lv2)
+	else if (undec_sm_pwdb >= txpwr_threshold_lv2)
 		rtlpriv->dm.dynamic_txhighpower_lvl = TX_HIGHPWR_LEVEL_NORMAL2;
-	else if ((undecorated_smoothed_pwdb < (txpwr_threshold_lv2 - 3)) &&
-		(undecorated_smoothed_pwdb >= txpwr_threshold_lv1))
+	else if ((undec_sm_pwdb < (txpwr_threshold_lv2 - 3)) &&
+		(undec_sm_pwdb >= txpwr_threshold_lv1))
 		rtlpriv->dm.dynamic_txhighpower_lvl = TX_HIGHPWR_LEVEL_NORMAL1;
-	else if (undecorated_smoothed_pwdb < (txpwr_threshold_lv1 - 3))
+	else if (undec_sm_pwdb < (txpwr_threshold_lv1 - 3))
 		rtlpriv->dm.dynamic_txhighpower_lvl = TX_HIGHPWR_LEVEL_NORMAL;
 
 	if ((rtlpriv->dm.dynamic_txhighpower_lvl != rtlpriv->dm.last_dtp_lvl))
@@ -665,10 +660,10 @@ static void _rtl92s_dm_init_dig(struct ieee80211_hw *hw)
 	digtable->dig_state = DM_STA_DIG_MAX;
 	digtable->dig_highpwrstate = DM_STA_DIG_MAX;
 
-	digtable->cur_sta_connectstate = DIG_STA_DISCONNECT;
-	digtable->pre_sta_connectstate = DIG_STA_DISCONNECT;
-	digtable->cur_ap_connectstate = DIG_AP_DISCONNECT;
-	digtable->pre_ap_connectstate = DIG_AP_DISCONNECT;
+	digtable->cur_sta_cstate = DIG_STA_DISCONNECT;
+	digtable->pre_sta_cstate = DIG_STA_DISCONNECT;
+	digtable->cur_ap_cstate = DIG_AP_DISCONNECT;
+	digtable->pre_ap_cstate = DIG_AP_DISCONNECT;
 
 	digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
 	digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
@@ -681,7 +676,7 @@ static void _rtl92s_dm_init_dig(struct ieee80211_hw *hw)
 
 	/* for dig debug rssi value */
 	digtable->rssi_val = 50;
-	digtable->backoff_val = DM_DIG_BACKOFF;
+	digtable->back_val = DM_DIG_BACKOFF;
 	digtable->rx_gain_range_max = DM_DIG_MAX;
 
 	digtable->rx_gain_range_min = DM_DIG_MIN;
@@ -709,7 +704,7 @@ void rtl92s_dm_init(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
-	rtlpriv->dm.undecorated_smoothed_pwdb = -1;
+	rtlpriv->dm.undec_sm_pwdb = -1;
 
 	_rtl92s_dm_init_dynamic_txpower(hw);
 	rtl92s_dm_init_edca_turbo(hw);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index 4542e69..1d72779 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1697,7 +1697,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 			hwinfo[EEPROM_TXPOWERBASE + 6 + rf_path * 3 + i];
 
 			/* Read OFDM RF A & B Tx power for 2T */
-			rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif[rf_path][i]
+			rtlefuse->eprom_chnl_txpwr_ht40_2sdf[rf_path][i]
 				 = hwinfo[EEPROM_TXPOWERBASE + 12 +
 				   rf_path * 3 + i];
 		}
@@ -1722,7 +1722,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 			RTPRINT(rtlpriv, FINIT, INIT_EEPROM,
 				"RF(%d) EEPROM HT40 2S Diff Area(%d) = 0x%x\n",
 				rf_path, i,
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
+				rtlefuse->eprom_chnl_txpwr_ht40_2sdf
 				[rf_path][i]);
 
 	for (rf_path = 0; rf_path < 2; rf_path++) {
@@ -1748,7 +1748,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 				rtlefuse->eeprom_chnlarea_txpwr_ht40_1s
 							[rf_path][index];
 			rtlefuse->txpwrlevel_ht40_2s[rf_path][i]  =
-				rtlefuse->eeprom_chnlarea_txpwr_ht40_2sdiif
+				rtlefuse->eprom_chnl_txpwr_ht40_2sdf
 							[rf_path][index];
 		}
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
index b917a2a..6740497 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -139,17 +139,17 @@ static u32 _rtl92s_phy_rf_serial_read(struct ieee80211_hw *hw,
 						BIT(8));
 
 	if (rfpi_enable)
-		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readbackpi,
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rbpi,
 					 BLSSI_READBACK_DATA);
 	else
-		retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
+		retvalue = rtl_get_bbreg(hw, pphyreg->rf_rb,
 					 BLSSI_READBACK_DATA);
 
-	retvalue = rtl_get_bbreg(hw, pphyreg->rflssi_readback,
+	retvalue = rtl_get_bbreg(hw, pphyreg->rf_rb,
 				 BLSSI_READBACK_DATA);
 
 	RT_TRACE(rtlpriv, COMP_RF, DBG_TRACE, "RFR-%d Addr[0x%x]=0x%x\n",
-		 rfpath, pphyreg->rflssi_readback, retvalue);
+		 rfpath, pphyreg->rf_rb, retvalue);
 
 	return retvalue;
 
@@ -696,7 +696,7 @@ static void _rtl92s_store_pwrindex_diffrate_offset(struct ieee80211_hw *hw,
 	else
 		return;
 
-	rtlphy->mcs_txpwrlevel_origoffset[rtlphy->pwrgroup_cnt][index] = data;
+	rtlphy->mcs_offset[rtlphy->pwrgroup_cnt][index] = data;
 	if (index == 5)
 		rtlphy->pwrgroup_cnt++;
 }
@@ -765,14 +765,10 @@ static void _rtl92s_phy_init_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_D].rfhssi_para2 = RFPGA0_XD_HSSIPARAMETER2;
 
 	/* RF switch Control */
-	rtlphy->phyreg_def[RF90_PATH_A].rfswitch_control =
-						 RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_B].rfswitch_control =
-						 RFPGA0_XAB_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_C].rfswitch_control =
-						 RFPGA0_XCD_SWITCHCONTROL;
-	rtlphy->phyreg_def[RF90_PATH_D].rfswitch_control =
-						 RFPGA0_XCD_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_A].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_B].rfsw_ctrl = RFPGA0_XAB_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_C].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
+	rtlphy->phyreg_def[RF90_PATH_D].rfsw_ctrl = RFPGA0_XCD_SWITCHCONTROL;
 
 	/* AGC control 1  */
 	rtlphy->phyreg_def[RF90_PATH_A].rfagc_control1 = ROFDM0_XAAGCCORE1;
@@ -787,14 +783,10 @@ static void _rtl92s_phy_init_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_D].rfagc_control2 = ROFDM0_XDAGCCORE2;
 
 	/* RX AFE control 1  */
-	rtlphy->phyreg_def[RF90_PATH_A].rfrxiq_imbalance =
-						 ROFDM0_XARXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_B].rfrxiq_imbalance =
-						 ROFDM0_XBRXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbalance =
-						 ROFDM0_XCRXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbalance =
-						 ROFDM0_XDRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_A].rfrxiq_imbal = ROFDM0_XARXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rfrxiq_imbal = ROFDM0_XBRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rfrxiq_imbal = ROFDM0_XCRXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rfrxiq_imbal = ROFDM0_XDRXIQIMBALANCE;
 
 	/* RX AFE control 1   */
 	rtlphy->phyreg_def[RF90_PATH_A].rfrx_afe = ROFDM0_XARXAFE;
@@ -803,14 +795,10 @@ static void _rtl92s_phy_init_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_D].rfrx_afe = ROFDM0_XDRXAFE;
 
 	/* Tx AFE control 1  */
-	rtlphy->phyreg_def[RF90_PATH_A].rftxiq_imbalance =
-						 ROFDM0_XATXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_B].rftxiq_imbalance =
-						 ROFDM0_XBTXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbalance =
-						 ROFDM0_XCTXIQIMBALANCE;
-	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbalance =
-						 ROFDM0_XDTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_A].rftxiq_imbal = ROFDM0_XATXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_B].rftxiq_imbal = ROFDM0_XBTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_C].rftxiq_imbal = ROFDM0_XCTXIQIMBALANCE;
+	rtlphy->phyreg_def[RF90_PATH_D].rftxiq_imbal = ROFDM0_XDTXIQIMBALANCE;
 
 	/* Tx AFE control 2  */
 	rtlphy->phyreg_def[RF90_PATH_A].rftx_afe = ROFDM0_XATXAFE;
@@ -819,20 +807,14 @@ static void _rtl92s_phy_init_register_definition(struct ieee80211_hw *hw)
 	rtlphy->phyreg_def[RF90_PATH_D].rftx_afe = ROFDM0_XDTXAFE;
 
 	/* Tranceiver LSSI Readback */
-	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readback =
-			 RFPGA0_XA_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readback =
-			 RFPGA0_XB_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_C].rflssi_readback =
-			 RFPGA0_XC_LSSIREADBACK;
-	rtlphy->phyreg_def[RF90_PATH_D].rflssi_readback =
-			 RFPGA0_XD_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rb = RFPGA0_XA_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rb = RFPGA0_XB_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_C].rf_rb = RFPGA0_XC_LSSIREADBACK;
+	rtlphy->phyreg_def[RF90_PATH_D].rf_rb = RFPGA0_XD_LSSIREADBACK;
 
 	/* Tranceiver LSSI Readback PI mode  */
-	rtlphy->phyreg_def[RF90_PATH_A].rflssi_readbackpi =
-			 TRANSCEIVERA_HSPI_READBACK;
-	rtlphy->phyreg_def[RF90_PATH_B].rflssi_readbackpi =
-			 TRANSCEIVERB_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_A].rf_rbpi = TRANSCEIVERA_HSPI_READBACK;
+	rtlphy->phyreg_def[RF90_PATH_B].rf_rbpi = TRANSCEIVERB_HSPI_READBACK;
 }
 
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
index 08c2f56..5061f1d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/rf.c
@@ -192,8 +192,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 		 * defined by Realtek for large power */
 		chnlgroup = 0;
 
-		writeval = rtlphy->mcs_txpwrlevel_origoffset
-				[chnlgroup][index] +
+		writeval = rtlphy->mcs_offset[chnlgroup][index] +
 				((index < 2) ? pwrbase0 : pwrbase1);
 
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
@@ -223,8 +222,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 					chnlgroup++;
 			}
 
-			writeval = rtlphy->mcs_txpwrlevel_origoffset
-					[chnlgroup][index]
+			writeval = rtlphy->mcs_offset[chnlgroup][index]
 					+ ((index < 2) ?
 					pwrbase0 : pwrbase1);
 
@@ -257,8 +255,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 		}
 
 		for (i = 0; i < 4; i++) {
-			pwrdiff_limit[i] =
-				(u8)((rtlphy->mcs_txpwrlevel_origoffset
+			pwrdiff_limit[i] = (u8)((rtlphy->mcs_offset
 				[chnlgroup][index] & (0x7f << (i * 8)))
 				>> (i * 8));
 
@@ -296,7 +293,7 @@ static void _rtl92s_get_txpower_writeval_byregulatory(struct ieee80211_hw *hw,
 		break;
 	default:
 		chnlgroup = 0;
-		writeval = rtlphy->mcs_txpwrlevel_origoffset[chnlgroup][index] +
+		writeval = rtlphy->mcs_offset[chnlgroup][index] +
 				((index < 2) ? pwrbase0 : pwrbase1);
 		RT_TRACE(rtlpriv, COMP_POWER, DBG_LOUD,
 			 "RTK better performance, writeval = 0x%x\n", writeval);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index e3cf4c0..1ad51e7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -129,8 +129,8 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 	pstats->packet_matchbssid = packet_match_bssid;
 	pstats->packet_toself = packet_toself;
 	pstats->packet_beacon = packet_beacon;
-	pstats->rx_mimo_signalquality[0] = -1;
-	pstats->rx_mimo_signalquality[1] = -1;
+	pstats->rx_mimo_sig_qual[0] = -1;
+	pstats->rx_mimo_sig_qual[1] = -1;
 
 	if (is_cck) {
 		u8 report, cck_highpwr;
@@ -216,8 +216,8 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 			}
 
 			pstats->signalquality = sq;
-			pstats->rx_mimo_signalquality[0] = sq;
-			pstats->rx_mimo_signalquality[1] = -1;
+			pstats->rx_mimo_sig_qual[0] = sq;
+			pstats->rx_mimo_sig_qual[1] = -1;
 		}
 	} else {
 		rtlpriv->dm.rfpath_rxenable[0] =
@@ -256,8 +256,7 @@ static void _rtl92se_query_rxphystatus(struct ieee80211_hw *hw,
 				if (i == 0)
 					pstats->signalquality = (u8)(evm &
 								 0xff);
-				pstats->rx_mimo_signalquality[i] =
-							 (u8) (evm & 0xff);
+				pstats->rx_mimo_sig_qual[i] = (u8) (evm & 0xff);
 			}
 		}
 	}
@@ -366,7 +365,7 @@ static void _rtl92se_process_pwdb(struct ieee80211_hw *hw,
 		return;
 	} else {
 		undec_sm_pwdb =
-		    rtlpriv->dm.undecorated_smoothed_pwdb;
+		    rtlpriv->dm.undec_sm_pwdb;
 	}
 
 	if (pstats->packet_toself || pstats->packet_beacon) {
@@ -386,7 +385,7 @@ static void _rtl92se_process_pwdb(struct ieee80211_hw *hw,
 			      (RX_SMOOTH_FACTOR);
 		}
 
-		rtlpriv->dm.undecorated_smoothed_pwdb = undec_sm_pwdb;
+		rtlpriv->dm.undec_sm_pwdb = undec_sm_pwdb;
 		_rtl92se_update_rxsignalstatistics(hw, pstats);
 	}
 }
@@ -398,16 +397,16 @@ static void rtl_92s_process_streams(struct ieee80211_hw *hw,
 	u32 stream;
 
 	for (stream = 0; stream < 2; stream++) {
-		if (pstats->rx_mimo_signalquality[stream] != -1) {
+		if (pstats->rx_mimo_sig_qual[stream] != -1) {
 			if (rtlpriv->stats.rx_evm_percentage[stream] == 0) {
 				rtlpriv->stats.rx_evm_percentage[stream] =
-				    pstats->rx_mimo_signalquality[stream];
+				    pstats->rx_mimo_sig_qual[stream];
 			}
 
 			rtlpriv->stats.rx_evm_percentage[stream] =
 			    ((rtlpriv->stats.rx_evm_percentage[stream] *
 					(RX_SMOOTH_FACTOR - 1)) +
-			     (pstats->rx_mimo_signalquality[stream] *
+			     (pstats->rx_mimo_sig_qual[stream] *
 					1)) / (RX_SMOOTH_FACTOR);
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index f1b6bc6..6794b68 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -198,15 +198,15 @@ struct bb_reg_def {
 	u32 rftxgain_stage;
 	u32 rfhssi_para1;
 	u32 rfhssi_para2;
-	u32 rfswitch_control;
+	u32 rfsw_ctrl;
 	u32 rfagc_control1;
 	u32 rfagc_control2;
-	u32 rfrxiq_imbalance;
+	u32 rfrxiq_imbal;
 	u32 rfrx_afe;
-	u32 rftxiq_imbalance;
+	u32 rftxiq_imbal;
 	u32 rftx_afe;
-	u32 rflssi_readback;
-	u32 rflssi_readbackpi;
+	u32 rf_rb;		/* rflssi_readback */
+	u32 rf_rbpi;		/* rflssi_readbackpi */
 };
 
 enum io_type {
@@ -885,7 +885,7 @@ struct rtl_phy {
 	u8 pwrgroup_cnt;
 	u8 cck_high_power;
 	/* MAX_PG_GROUP groups of pwr diff by rates */
-	u32 mcs_txpwrlevel_origoffset[MAX_PG_GROUP][16];
+	u32 mcs_offset[MAX_PG_GROUP][16];
 	u8 default_initialgain[4];
 
 	/* the current Tx power level */
@@ -933,7 +933,7 @@ struct rtl_tid_data {
 };
 
 struct rssi_sta {
-	long undecorated_smoothed_pwdb;
+	long undec_sm_pwdb;
 };
 
 struct rtl_sta_info {
@@ -1131,9 +1131,9 @@ struct rtl_security {
 
 struct rtl_dm {
 	/*PHY status for Dynamic Management */
-	long entry_min_undecoratedsmoothed_pwdb;
-	long undecorated_smoothed_pwdb;	/*out dm */
-	long entry_max_undecoratedsmoothed_pwdb;
+	long entry_min_undec_sm_pwdb;
+	long undec_sm_pwdb;	/*out dm */
+	long entry_max_undec_sm_pwdb;
 	bool dm_initialgain_enable;
 	bool dynamic_txpower_enable;
 	bool current_turbo_edca;
@@ -1209,7 +1209,7 @@ struct rtl_efuse {
 	u8 eeprom_pwrlimit_ht40[CHANNEL_GROUP_MAX];
 	u8 eeprom_chnlarea_txpwr_cck[2][CHANNEL_GROUP_MAX_2G];
 	u8 eeprom_chnlarea_txpwr_ht40_1s[2][CHANNEL_GROUP_MAX];
-	u8 eeprom_chnlarea_txpwr_ht40_2sdiif[2][CHANNEL_GROUP_MAX];
+	u8 eprom_chnl_txpwr_ht40_2sdf[2][CHANNEL_GROUP_MAX];
 	u8 txpwrlevel_cck[2][CHANNEL_MAX_NUMBER_2G];
 	u8 txpwrlevel_ht40_1s[2][CHANNEL_MAX_NUMBER];	/*For HT 40MHZ pwr */
 	u8 txpwrlevel_ht40_2s[2][CHANNEL_MAX_NUMBER];	/*For HT 40MHZ pwr */
@@ -1351,7 +1351,7 @@ struct rtl_stats {
 	bool rx_is40Mhzpacket;
 	u32 rx_pwdb_all;
 	u8 rx_mimo_signalstrength[4];	/*in 0~100 index */
-	s8 rx_mimo_signalquality[2];
+	s8 rx_mimo_sig_qual[2];
 	bool packet_matchbssid;
 	bool is_cck;
 	bool is_ht;
@@ -1503,6 +1503,9 @@ struct rtl_hal_ops {
 	void (*phy_lc_calibrate) (struct ieee80211_hw *hw, bool is2t);
 	void (*phy_set_bw_mode_callback) (struct ieee80211_hw *hw);
 	void (*dm_dynamic_txpower) (struct ieee80211_hw *hw);
+	void (*bt_wifi_media_status_notify) (struct ieee80211_hw *hw,
+					     bool mstate);
+	void (*bt_coex_off_before_lps) (struct ieee80211_hw *hw);
 };
 
 struct rtl_intf_ops {
@@ -1679,7 +1682,7 @@ struct dig_t {
 	u32 rssi_highthresh;
 	u32 fa_lowthresh;
 	u32 fa_highthresh;
-	long last_min_undecorated_pwdb_for_dm;
+	long last_min_undec_pwdb_for_dm;
 	long rssi_highpower_lowthresh;
 	long rssi_highpower_highthresh;
 	u32 recover_cnt;
@@ -1692,15 +1695,15 @@ struct dig_t {
 	u8 dig_twoport_algorithm;
 	u8 dig_dbgmode;
 	u8 dig_slgorithm_switch;
-	u8 cursta_connectstate;
-	u8 presta_connectstate;
-	u8 curmultista_connectstate;
-	char backoff_val;
-	char backoff_val_range_max;
-	char backoff_val_range_min;
+	u8 cursta_cstate;
+	u8 presta_cstate;
+	u8 curmultista_cstate;
+	char back_val;
+	char back_range_max;
+	char back_range_min;
 	u8 rx_gain_range_max;
 	u8 rx_gain_range_min;
-	u8 min_undecorated_pwdb_for_dm;
+	u8 min_undec_pwdb_for_dm;
 	u8 rssi_val_min;
 	u8 pre_cck_pd_state;
 	u8 cur_cck_pd_state;
@@ -1712,10 +1715,10 @@ struct dig_t {
 	u8 forbidden_igi;
 	u8 dig_state;
 	u8 dig_highpwrstate;
-	u8 cur_sta_connectstate;
-	u8 pre_sta_connectstate;
-	u8 cur_ap_connectstate;
-	u8 pre_ap_connectstate;
+	u8 cur_sta_cstate;
+	u8 pre_sta_cstate;
+	u8 cur_ap_cstate;
+	u8 pre_ap_cstate;
 	u8 cur_pd_thstate;
 	u8 pre_pd_thstate;
 	u8 cur_cs_ratiostate;
@@ -1846,7 +1849,7 @@ struct bt_coexist_info {
 	u8 eeprom_bt_coexist;
 	u8 eeprom_bt_type;
 	u8 eeprom_bt_ant_num;
-	u8 eeprom_bt_ant_isolation;
+	u8 eeprom_bt_ant_isol;
 	u8 eeprom_bt_radio_shared;
 
 	u8 bt_coexistence;
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
