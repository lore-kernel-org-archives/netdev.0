From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 3/5] rtlwifi: rtl8192ee: Apply the regulatory changes to driver
Date: Fri, 15 May 2015 16:33:01 -0500
Message-ID: <1431725583-7324-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1431725583-7324-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1431725583-7324-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>

The driver was setting a channel plan for the world. Now it reads it fromi
EEPROM.

In addition, a typo was fixed.

Signed-off-by: Shao Fu <shaofu-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192ee/hw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
index da0a612..0705e7e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/hw.c
@@ -2194,8 +2194,8 @@ static void _rtl92ee_read_adapter_info(struct ieee80211_hw *hw)
 		 "dev_addr: %pM\n", rtlefuse->dev_addr);
 	/*channel plan */
 	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
-	/* set channel paln to world wide 13 */
-	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
+	/* set channel plan from efuse */
+	rtlefuse->channel_plan = rtlefuse->eeprom_channelplan;
 	/*tx power*/
 	_rtl92ee_read_txpower_info_from_hwpg(hw, rtlefuse->autoload_failflag,
 					     hwinfo);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
