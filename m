From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 04/11] rtlwifi: rtl8188ee: Convert driver to use the common DM table init routine
Date: Fri,  2 Jan 2015 10:58:21 -0600
Message-ID: <1420217908-1382-5-git-send-email-Larry.Finger@lwfinger.net>
References: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420217908-1382-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The previous patch created a routine in rtlwifi to initialize dm_digtable.
Driver rtl8188ee is converted to use that routine.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
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
