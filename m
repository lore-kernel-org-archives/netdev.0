From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/2 V3 3.18] rtlwifi: rtl8821ae: Fix 5G detection problem
Date: Tue, 25 Nov 2014 14:28:48 -0600
Message-ID: <1416947328-5431-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Valerio Passini <valerio.passini@unicam.it>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:48778 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaKYUaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 15:30:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The changes associated with moving this driver from staging to the regular
tree missed one section setting the allowable rates for the 5GHz band.

This patch is needed to fix the regression reported in Bug #88811
(https://bugzilla.kernel.org/show_bug.cgi?id=88811).

Reported-by: Valerio Passini <valerio.passini@unicam.it>
Tested-by: Valerio Passini <valerio.passini@unicam.it>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Valerio Passini <valerio.passini@unicam.it>
---

V2 - removed extra parentheses as suggested by John Linville.
V3 - Add spaces around the << operator
---
 drivers/net/wireless/rtlwifi/rtl8821ae/hw.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
index 310d316..18f34f7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8821ae/hw.c
@@ -3672,8 +3672,9 @@ static void rtl8821ae_update_hal_rate_mask(struct ieee80211_hw *hw,
 		mac->opmode == NL80211_IFTYPE_ADHOC)
 		macid = sta->aid + 1;
 	if (wirelessmode == WIRELESS_MODE_N_5G ||
-	    wirelessmode == WIRELESS_MODE_AC_5G)
-		ratr_bitmap = sta->supp_rates[NL80211_BAND_5GHZ];
+	    wirelessmode == WIRELESS_MODE_AC_5G ||
+	    wirelessmode == WIRELESS_MODE_A)
+		ratr_bitmap = sta->supp_rates[NL80211_BAND_5GHZ] << 4;
 	else
 		ratr_bitmap = sta->supp_rates[NL80211_BAND_2GHZ];
 
-- 
2.1.2
