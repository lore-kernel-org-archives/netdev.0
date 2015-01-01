From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: wireless: b43legacy: radio.c:  Remove unused function
Date: Thu,  1 Jan 2015 16:46:10 +0100
Message-ID: <1420127170-28421-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Kalle Valo <kvalo@adurom.com>, linux-wireless@vger.kernel.org,
	b43-dev@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the function b43legacy_radio_set_tx_iq() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
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
-
 int b43legacy_radio_selectchannel(struct b43legacy_wldev *dev,
 				  u8 channel,
 				  int synthetic_pu_workaround)
diff --git a/drivers/net/wireless/b43legacy/radio.h b/drivers/net/wireless/b43legacy/radio.h
index bccb3d7..dd2976d 100644
--- a/drivers/net/wireless/b43legacy/radio.h
+++ b/drivers/net/wireless/b43legacy/radio.h
@@ -92,7 +92,6 @@ void b43legacy_nrssi_hw_write(struct b43legacy_wldev *dev, u16 offset, s16 val);
 void b43legacy_nrssi_hw_update(struct b43legacy_wldev *dev, u16 val);
 void b43legacy_nrssi_mem_update(struct b43legacy_wldev *dev);
 
-void b43legacy_radio_set_tx_iq(struct b43legacy_wldev *dev);
 u16 b43legacy_radio_calibrationvalue(struct b43legacy_wldev *dev);
 
 #endif /* B43legacy_RADIO_H_ */
-- 
1.7.10.4
