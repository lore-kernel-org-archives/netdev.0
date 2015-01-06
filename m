From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 04/11 V2] rtlwifi: rtl8188ee: Convert driver to use the common DM table init routine
Date: Tue,  6 Jan 2015 09:58:05 -0600
Message-ID: <1420559892-12384-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:49619 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455AbbAFP61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 10:58:27 -0500
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous patch created a routine in rtlwifi to initialize dm_digtable.
Driver rtl8188ee is converted to use that routine.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

V2 - unchanged from V1
---

 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c | 35 ++---------------------------
 1 file changed, 2 insertions(+), 33 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
index 7ebf6e0..d930c1f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
@@ -342,38 +342,6 @@ static void dm_tx_pwr_track_set_pwr(struct ieee80211_hw *hw,
 	}
 }
 
-static void rtl88e_dm_diginit(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_dig = &rtlpriv->dm_digtable;
-
-	dm_dig->dig_enable_flag = true;
-	dm_dig->cur_igvalue = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f);
-	dm_dig->pre_igvalue = 0;
-	dm_dig->cur_sta_cstate = DIG_STA_DISCONNECT;
-	dm_dig->presta_cstate = DIG_STA_DISCONNECT;
-	dm_dig->curmultista_cstate = DIG_MULTISTA_DISCONNECT;
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
-	dm_dig->dig_min_0 = 0x25;
-	dm_dig->dig_min_1 = 0x25;
-	dm_dig->media_connect_0 = false;
-	dm_dig->media_connect_1 = false;
-	rtlpriv->dm.dm_initialgain_enable = true;
-}
-
 static u8 rtl88e_dm_initial_gain_min_pwdb(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
@@ -1797,9 +1765,10 @@ static void rtl88e_dm_antenna_diversity(struct ieee80211_hw *hw)
 void rtl88e_dm_init(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	u32 cur_igvalue = rtl_get_bbreg(hw, ROFDM0_XAAGCCORE1, 0x7f);
 
 	rtlpriv->dm.dm_type = DM_TYPE_BYDRIVER;
-	rtl88e_dm_diginit(hw);
+	rtl_dm_diginit(hw, cur_igvalue);
 	rtl88e_dm_init_dynamic_txpower(hw);
 	rtl88e_dm_init_edca_turbo(hw);
 	rtl88e_dm_init_rate_adaptive_mask(hw);
-- 
2.1.2
