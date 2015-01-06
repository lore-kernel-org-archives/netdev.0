From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 06/11 V2] rtlwifi: rtl8192de: Convert driver to use common DM table initialization
Date: Tue,  6 Jan 2015 09:58:07 -0600
Message-ID: <1420559892-12384-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1420559892-12384-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420559892-12384-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch converts driver rtl8192de to use the common routine to
initialize dm_digtable.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

V2 - unchanged from V1
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
