From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 10/11 V2] rtlwifi: rtl8821ae: Convert driver to use common DM table initialization
Date: Tue,  6 Jan 2015 09:58:11 -0600
Message-ID: <1420559892-12384-11-git-send-email-Larry.Finger@lwfinger.net>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert driver to use routine rtl_dm_diginit().

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

V2 - unchanged from V1
---

 drivers/net/wireless/rtlwifi/rtl8821ae/dm.c | 31 ++---------------------------
 1 file changed, 2 insertions(+), 29 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
index 4af4613..0b2082d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/dm.c
@@ -520,34 +520,6 @@ void rtl8821ae_dm_initialize_txpower_tracking_thermalmeter(
 	}
 }
 
-static void rtl8821ae_dm_diginit(struct ieee80211_hw *hw)
-{
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct dig_t *dm_digtable = &rtlpriv->dm_digtable;
-
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
