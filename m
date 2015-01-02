From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 06/11] rtlwifi: rtl8192de: Convert driver to use common DM table initialization
Date: Fri,  2 Jan 2015 10:58:23 -0600
Message-ID: <1420217908-1382-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:57597 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbbABQ6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 11:58:39 -0500
In-Reply-To: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts driver rtl8192de to use the common routine to
initialize dm_digtable.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c | 32 +++--------------------------
 1 file changed, 3 insertions(+), 29 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index 75643ab..a1be5a6 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -156,34 +156,6 @@ static const u8 cckswing_table_ch14[CCK_TABLE_SIZE][8] = {
 	{0x09, 0x08, 0x07, 0x04, 0x00, 0x00, 0x00, 0x00}     /* 32, -16.0dB */
 };
 
-static void rtl92d_dm_diginit(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *de_digtable = &rtlpriv->dm_digtable;
-
-	de_digtable->dig_enable_flag = true;
-	de_digtable->dig_ext_port_stage = DIG_EXT_PORT_STAGE_MAX;
-	de_digtable->cur_igvalue = 0x20;
-	de_digtable->pre_igvalue = 0x0;
-	de_digtable->cursta_cstate = DIG_STA_DISCONNECT;
-	de_digtable->presta_cstate = DIG_STA_DISCONNECT;
-	de_digtable->curmultista_cstate = DIG_MULTISTA_DISCONNECT;
-	de_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
-	de_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
-	de_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
-	de_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
-	de_digtable->rx_gain_max = DM_DIG_FA_UPPER;
-	de_digtable->rx_gain_min = DM_DIG_FA_LOWER;
-	de_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
-	de_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
-	de_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
-	de_digtable->pre_cck_pd_state = CCK_PD_STAGE_LOWRSSI;
-	de_digtable->cur_cck_pd_state = CCK_PD_STAGE_MAX;
-	de_digtable->large_fa_hit = 0;
-	de_digtable->recover_cnt = 0;
-	de_digtable->forbidden_igi = DM_DIG_FA_LOWER;
-}
-
 static void rtl92d_dm_false_alarm_counter_statistics(struct ieee80211_hw *hw)
 {
 	u32 ret_value;
@@ -1306,7 +1278,9 @@ void rtl92d_dm_init(struct ieee80211_hw *hw)
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
 	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
-	rtl92d_dm_diginit(hw);
+	rtl_dm_diginit(hw, 0x20);
+	rtlpriv->dm_digtable.rx_gain_max = DM_DIG_FA_UPPER;
+	rtlpriv->dm_digtable.rx_gain_min = DM_DIG_FA_LOWER;
 	rtl92d_dm_init_dynamic_txpower(hw);
 	rtl92d_dm_init_edca_turbo(hw);
 	rtl92d_dm_init_rate_adaptive_mask(hw);
-- 
2.1.2
