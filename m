From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 10/12 NEXT] rtlwifi: rtl8192cu: Fix some code in RF handling
Date: Mon, 18 Nov 2013 11:11:34 -0600
Message-ID: <1384794696-20314-11-git-send-email-Larry.Finger@lwfinger.net>
References: <1384794696-20314-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384794696-20314-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

Index: wireless-testing/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
===================================================================
--- wireless-testing.orig/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
+++ wireless-testing/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c
@@ -85,17 +85,15 @@ void rtl92cu_phy_rf6052_set_cck_txpower(
 	if (mac->act_scanning) {
 		tx_agc[RF90_PATH_A] = 0x3f3f3f3f;
 		tx_agc[RF90_PATH_B] = 0x3f3f3f3f;
-		if (turbo_scanoff) {
-			for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
-				tx_agc[idx1] = ppowerlevel[idx1] |
-				    (ppowerlevel[idx1] << 8) |
-				    (ppowerlevel[idx1] << 16) |
-				    (ppowerlevel[idx1] << 24);
-				if (rtlhal->interface == INTF_USB) {
-					if (tx_agc[idx1] > 0x20 &&
-					    rtlefuse->external_pa)
-						tx_agc[idx1] = 0x20;
-				}
+		for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
+			tx_agc[idx1] = ppowerlevel[idx1] |
+			    (ppowerlevel[idx1] << 8) |
+			    (ppowerlevel[idx1] << 16) |
+			    (ppowerlevel[idx1] << 24);
+			if (rtlhal->interface == INTF_USB) {
+				if (tx_agc[idx1] > 0x20 &&
+				    rtlefuse->external_pa)
+					tx_agc[idx1] = 0x20;
 			}
 		}
 	} else {
@@ -107,7 +105,7 @@ void rtl92cu_phy_rf6052_set_cck_txpower(
 			   TXHIGHPWRLEVEL_LEVEL2) {
 			tx_agc[RF90_PATH_A] = 0x00000000;
 			tx_agc[RF90_PATH_B] = 0x00000000;
-		} else{
+		} else {
 			for (idx1 = RF90_PATH_A; idx1 <= RF90_PATH_B; idx1++) {
 				tx_agc[idx1] = ppowerlevel[idx1] |
 				    (ppowerlevel[idx1] << 8) |
@@ -373,7 +371,12 @@ static void _rtl92c_write_ofdm_power_reg
 			    regoffset == RTXAGC_B_MCS07_MCS04)
 				regoffset = 0xc98;
 			for (i = 0; i < 3; i++) {
-				writeVal = (writeVal > 6) ? (writeVal - 6) : 0;
+				if (i != 2)
+					writeVal = (writeVal > 8) ?
+						   (writeVal - 8) : 0;
+				else
+					writeVal = (writeVal > 6) ?
+						   (writeVal - 6) : 0;
 				rtl_write_byte(rtlpriv, (u32)(regoffset + i),
 					      (u8)writeVal);
 			}
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
