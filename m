From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/2 V2 3.18] rtlwifi: rtl8821ae: Fix 5G detection problem
Date: Tue, 25 Nov 2014 14:02:07 -0600
Message-ID: <1416945727-10743-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Valerio Passini <valerio.passini-vbqOIlEVYMdeoWH0uzbU5w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The changes associated with moving this driver from staging to the regular
tree missed one section setting the allowable rates for the 5GHz band.

This patch is needed to fix the regression reported in Bug #88811
(https://bugzilla.kernel.org/show_bug.cgi?id=88811).

Reported-by: Valerio Passini <valerio.passini-vbqOIlEVYMdeoWH0uzbU5w@public.gmane.org>
Tested-by: Valerio Passini <valerio.passini-vbqOIlEVYMdeoWH0uzbU5w@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Valerio Passini <valerio.passini-vbqOIlEVYMdeoWH0uzbU5w@public.gmane.org>
---

V2 - removed extra parentheses as suggested by John Linville.

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
+		ratr_bitmap = sta->supp_rates[NL80211_BAND_5GHZ]<<4;
 	else
 		ratr_bitmap = sta->supp_rates[NL80211_BAND_2GHZ];
 
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
