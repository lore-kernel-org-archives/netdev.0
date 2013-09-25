From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH  2/8 V4] rtlwifi: rtl8192de: Fix smatch warnings in rtl8192de/hw.c
Date: Wed, 25 Sep 2013 13:00:53 -0500
Message-ID: <1380132053-19290-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:46634 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309Ab3IYSBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 14:01:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch lists the following:
  CHECK   drivers/net/wireless/rtlwifi/rtl8192de/hw.c
drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.
drivers/net/wireless/rtlwifi/rtl8192de/hw.c:1200 rtl92de_set_qos() info: ignoring unreachable code.

The dead code is deleted.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Previous send had messed up subject.

Larry
---
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c | 18 ------------------
 1 file changed, 18 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index 7dd8f6d..c4a7db9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -1194,25 +1194,7 @@ void rtl92d_linked_set_reg(struct ieee80211_hw *hw)
  * mac80211 will send pkt when scan */
 void rtl92de_set_qos(struct ieee80211_hw *hw, int aci)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	rtl92d_dm_init_edca_turbo(hw);
-	return;
-	switch (aci) {
-	case AC1_BK:
-		rtl_write_dword(rtlpriv, REG_EDCA_BK_PARAM, 0xa44f);
-		break;
-	case AC0_BE:
-		break;
-	case AC2_VI:
-		rtl_write_dword(rtlpriv, REG_EDCA_VI_PARAM, 0x5e4322);
-		break;
-	case AC3_VO:
-		rtl_write_dword(rtlpriv, REG_EDCA_VO_PARAM, 0x2f3222);
-		break;
-	default:
-		RT_ASSERT(false, "invalid aci: %d !\n", aci);
-		break;
-	}
 }
 
 void rtl92de_enable_interrupt(struct ieee80211_hw *hw)
-- 
1.8.1.4
