From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/5] rtlwifi: rtl8188ee: Apply the new regulatory information
Date: Fri, 15 May 2015 16:33:00 -0500
Message-ID: <1431725583-7324-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1431725583-7324-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org, Shao Fu <shaofu@realtek.com>,
	netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34335 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932217AbbEOVdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:33:15 -0400
In-Reply-To: <1431725583-7324-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shao Fu <shaofu@realtek.com>

The driver was setting a channel plan for the world. Now it reads it from
EEPROM.

Signed-off-by: Shao Fu <shaofu@realtek.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
index 86ce5b1..40c65b7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
@@ -1919,8 +1919,8 @@ static void _rtl88ee_read_adapter_info(struct ieee80211_hw *hw)
 		 "dev_addr: %pM\n", rtlefuse->dev_addr);
 	/*channel plan */
 	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
-	/* set channel paln to world wide 13 */
-	rtlefuse->channel_plan = COUNTRY_CODE_WORLD_WIDE_13;
+	/* set channel plan from efuse */
+	rtlefuse->channel_plan = rtlefuse->eeprom_channelplan;
 	/*tx power*/
 	_rtl88ee_read_txpower_info_from_hwpg(hw,
 					     rtlefuse->autoload_failflag,
-- 
2.1.4
