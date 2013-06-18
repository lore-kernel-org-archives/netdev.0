From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2] rtlwifi: rtl8192cu: Fix duplicate if test
Date: Tue, 18 Jun 2013 13:25:05 -0500
Message-ID: <1371579905-15613-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:41684 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933041Ab3FRSZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 14:25:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A typo causes routine rtl92cu_phy_rf6052_set_cck_txpower() to test the
same condition twice. The problem was found using cppcheck-1.49, and the
proper fix was verified against the pre-mac80211 version of the code.

This patch was originally included as commit 1288aa4, but was accidentally
reverted in a later patch.

Reported-by: David Binderman <dcb314@hotmail.com> [original report]
Reported-by: Andrea Morello <andrea.merello@gmail.com> [report of accidental reversion]
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: stable <stable@vger.kernel.org>  [back to 2.6.39]
---

John,

Although this patch is trivial and could be included in the 3.10 stream,
I think we should not burden DaveM nor Linus with it this late in the 3.10
cycle. Please push it into the 3.11 stream.

Thanks,

Larry
---

V2 - Fix error in stable mailing address
---
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
index 953f1a0..2119313 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
@@ -104,7 +104,7 @@ void rtl92cu_phy_rf6052_set_cck_txpower(struct ieee80211_hw *hw,
 			tx_agc[RF90_PATH_A] = 0x10101010;
 			tx_agc[RF90_PATH_B] = 0x10101010;
 		} else if (rtlpriv->dm.dynamic_txhighpower_lvl ==
-			   TXHIGHPWRLEVEL_LEVEL1) {
+			   TXHIGHPWRLEVEL_LEVEL2) {
 			tx_agc[RF90_PATH_A] = 0x00000000;
 			tx_agc[RF90_PATH_B] = 0x00000000;
 		} else{
-- 
1.8.1.4
