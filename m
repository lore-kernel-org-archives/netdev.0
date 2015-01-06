From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: [PATCH] b43legacy: Remove unused function
Date: Tue,  6 Jan 2015 18:59:35 +0100
Message-ID: <1420567175-17323-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>,
	Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Remove the function b43legacy_radio_set_tx_iq() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
---
 drivers/net/wireless/b43legacy/radio.c |   19 -------------------
 drivers/net/wireless/b43legacy/radio.h |    1 -
 2 files changed, 20 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/radio.c b/drivers/net/wireless/b43legacy/radio.c
index 8961776..9501420 100644
--- a/drivers/net/wireless/b43legacy/radio.c
+++ b/drivers/net/wireless/b43legacy/radio.c
@@ -1743,25 +1743,6 @@ u16 freq_r3A_value(u16 frequency)
 	return value;
 }
 
-void b43legacy_radio_set_tx_iq(struct b43legacy_wldev *dev)
-{
-	static const u8 data_high[5] = { 0x00, 0x40, 0x80, 0x90, 0xD0 };
-	static const u8 data_low[5]  = { 0x00, 0x01, 0x05, 0x06, 0x0A };
-	u16 tmp = b43legacy_radio_read16(dev, 0x001E);
-	int i;
-	int j;
-
-	for (i = 0; i < 5; i++) {
-		for (j = 0; j < 5; j++) {
-			if (tmp == (data_high[i] | data_low[j])) {
-				b43legacy_phy_write(dev, 0x0069, (i - j) << 8 |
-						    0x00C0);
-				return;
-			}
-		}
-	}
-}
