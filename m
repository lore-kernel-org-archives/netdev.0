From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 5/5] rtlwifi: rtl8821ae: Fix problem with regulatory information
Date: Fri, 15 May 2015 16:33:03 -0500
Message-ID: <1431725583-7324-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1431725583-7324-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1431725583-7324-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>

The driver was not setting a channel plan. Now it gets it from EEPROM.

Signed-off-by: Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
index 8704eee..450bd4d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -3232,8 +3232,8 @@ static void _rtl8821ae_read_adapter_info(struct ieee80211_hw *hw, bool b_pseudo_
 	if (rtlefuse->eeprom_channelplan == 0xff)
 		rtlefuse->eeprom_channelplan = 0x7F;
 
-	/* set channel paln to world wide 13 */
-	/* rtlefuse->channel_plan = (u8)rtlefuse->eeprom_channelplan; */
+	/* set channel plan from efuse */
+	rtlefuse->channel_plan = rtlefuse->eeprom_channelplan;
 
 	/*parse xtal*/
 	rtlefuse->crystalcap = hwinfo[EEPROM_XTAL_8821AE];
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
