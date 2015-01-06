From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/11 V2] rtlwifi: rtl8192ee: Convert driver to use common DM table initialization
Date: Tue,  6 Jan 2015 09:58:08 -0600
Message-ID: <1420559892-12384-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:61782 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756139AbbAFP63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:58:29 -0500
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver rtl8192ee to use the common routine to initialize
dm_digtable.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - unchanged from V1
---

 drivers/net/wireless/rtlwifi/rtl8192ee/dm.c | 32 ++---------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
index 70e58d1..459f3d0 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/dm.c
@@ -152,35 +152,6 @@ static const u8 cckswing_table_ch14[CCK_TABLE_SIZE][8] = {
 	{0x09, 0x08, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00}  /* 32, -16.0dB */
 };
 
-static void rtl92ee_dm_diginit(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
-
-	dm_dig->cur_igvalue = rtl_get_bbreg(hw, DM_REG_IGI_A_11N,
-					    DM_BIT_IGI_11N);
-	dm_dig->rssi_lowthresh = DM_DIG_THRESH_LOW;
-	dm_dig->rssi_highthresh = DM_DIG_THRESH_HIGH;
-	dm_dig->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
-	dm_dig->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
-	dm_dig->rx_gain_max = DM_DIG_MAX;
-	dm_dig->rx_gain_min = DM_DIG_MIN;
-	dm_dig->back_val = DM_DIG_BACKOFF_DEFAULT;
-	dm_dig->back_range_max = DM_DIG_BACKOFF_MAX;
-	dm_dig->back_range_min = DM_DIG_BACKOFF_MIN;
-	dm_dig->pre_cck_cca_thres = 0xff;
-	dm_dig->cur_cck_cca_thres = 0x83;
-	dm_dig->forbidden_igi = DM_DIG_MIN;
-	dm_dig->large_fa_hit = 0;
-	dm_dig->recover_cnt = 0;
-	dm_dig->dig_min_0 = DM_DIG_MIN;
-	dm_dig->dig_min_1 = DM_DIG_MIN;
-	dm_dig->media_connect_0 = false;
-	dm_dig->media_connect_1 = false;
-	rtlpriv->dm.dm_initialgain_enable = true;
-	dm_dig->bt30_cur_igi = 0x32;
-}
-
 static void rtl92ee_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 {
 	u32 ret_value;
@@ -1089,10 +1060,11 @@ static void rtl92ee_dm_init_dynamic_atc_switch(struct ieee80211_hw *hw)
 void rtl92ee_dm_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 cur_igvalue = rtl_get_bbreg(hw, DM_REG_IGI_A_11N, DM_BIT_IGI_11N);
 
 	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
 
-	rtl92ee_dm_diginit(hw);
+	rtl_dm_diginit(hw, cur_igvalue);
 	rtl92ee_dm_init_rate_adaptive_mask(hw);
 	rtl92ee_dm_init_primary_cca_check(hw);
 	rtl92ee_dm_init_edca_turbo(hw);
-- 
2.1.2
