From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 09/11 V2] rtlwifi: rtl8723be: Convert driver to use common DM table initialization
Date: Tue,  6 Jan 2015 09:58:10 -0600
Message-ID: <1420559892-12384-10-git-send-email-Larry.Finger@lwfinger.net>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:52552 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756041AbbAFP6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:58:32 -0500
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver rtl8723be to use routine rtl_dm_diginit().

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - unchanged from V1
---

 drivers/net/wireless/rtlwifi/rtl8723be/dm.c | 32 ++---------------------------
 1 file changed, 2 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
index ddf45d9..2367e8f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/dm.c
@@ -212,35 +212,6 @@ void rtl8723be_dm_txpower_track_adjust(struct ieee80211_hw *hw, u8 type,
 		(pwr_val << 16) | (pwr_val << 24);
 }
 
-static void rtl8723be_dm_diginit(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
-
-	dm_digtable->dig_enable_flag = true;
-	dm_digtable->cur_igvalue = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f);
-	dm_digtable->rssi_lowthresh = DM_DIG_THRESH_LOW;
-	dm_digtable->rssi_highthresh = DM_DIG_THRESH_HIGH;
-	dm_digtable->fa_lowthresh = DM_FALSEALARM_THRESH_LOW;
-	dm_digtable->fa_highthresh = DM_FALSEALARM_THRESH_HIGH;
-	dm_digtable->rx_gain_max = DM_DIG_MAX;
-	dm_digtable->rx_gain_min = DM_DIG_MIN;
-	dm_digtable->back_val = DM_DIG_BACKOFF_DEFAULT;
-	dm_digtable->back_range_max = DM_DIG_BACKOFF_MAX;
-	dm_digtable->back_range_min = DM_DIG_BACKOFF_MIN;
-	dm_digtable->pre_cck_cca_thres = 0xff;
-	dm_digtable->cur_cck_cca_thres = 0x83;
-	dm_digtable->forbidden_igi = DM_DIG_MIN;
-	dm_digtable->large_fa_hit = 0;
-	dm_digtable->recover_cnt = 0;
-	dm_digtable->dig_min_0 = DM_DIG_MIN;
-	dm_digtable->dig_min_1 = DM_DIG_MIN;
-	dm_digtable->media_connect_0 = false;
-	dm_digtable->media_connect_1 = false;
-	rtlpriv->dm.dm_initialgain_enable = true;
-	dm_digtable->bt30_cur_igi = 0x32;
-}
-
 void rtl8723be_dm_init_rate_adaptive_mask(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -294,9 +265,10 @@ static void rtl8723be_dm_init_dynamic_atc_switch(struct ieee80211_hw *hw)
 void rtl8723be_dm_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 cur_igvalue = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f);
 
 	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
-	rtl8723be_dm_diginit(hw);
+	rtl_dm_diginit(hw, cur_igvalue);
 	rtl8723be_dm_init_rate_adaptive_mask(hw);
 	rtl8723_dm_init_edca_turbo(hw);
 	rtl8723_dm_init_dynamic_bb_powersaving(hw);
-- 
2.1.2
