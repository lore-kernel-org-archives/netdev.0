From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: 16-bit writes for physical control registers
Date: Wed, 13 Sep 2006 02:41:02 +0100 (BST)
Message-ID: <20060913014102.68AF97B40A0@zog.reactivated.net>
Cc: kune@deine-taler.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout02-winn.ispmail.ntl.com ([81.103.221.48]:44986 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751482AbWIMBgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 21:36:14 -0400
To: linville@tuxdriver.com
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Caused by the fact that physical control registers appear to have
only a width of 16 bit, 32-bit writes are not required.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 zd_chip.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

Index: linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux-2.6/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -1181,7 +1181,7 @@ static int update_pwr_int(struct zd_chip
 	u8 value = chip->pwr_int_values[channel - 1];
 	dev_dbg_f(zd_chip_dev(chip), "channel %d pwr_int %#04x\n",
 		 channel, value);
-	return zd_iowrite32_locked(chip, value, CR31);
+	return zd_iowrite16_locked(chip, value, CR31);
 }
 
 static int update_pwr_cal(struct zd_chip *chip, u8 channel)
@@ -1189,12 +1189,12 @@ static int update_pwr_cal(struct zd_chip
 	u8 value = chip->pwr_cal_values[channel-1];
 	dev_dbg_f(zd_chip_dev(chip), "channel %d pwr_cal %#04x\n",
 		 channel, value);
-	return zd_iowrite32_locked(chip, value, CR68);
+	return zd_iowrite16_locked(chip, value, CR68);
 }
 
 static int update_ofdm_cal(struct zd_chip *chip, u8 channel)
 {
-	struct zd_ioreq32 ioreqs[3];
+	struct zd_ioreq16 ioreqs[3];
 
 	ioreqs[0].addr = CR67;
 	ioreqs[0].value = chip->ofdm_cal_values[OFDM_36M_INDEX][channel-1];
@@ -1206,7 +1206,7 @@ static int update_ofdm_cal(struct zd_chi
 	dev_dbg_f(zd_chip_dev(chip),
 		"channel %d ofdm_cal 36M %#04x 48M %#04x 54M %#04x\n",
 		channel, ioreqs[0].value, ioreqs[1].value, ioreqs[2].value);
-	return zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
 }
 
 static int update_channel_integration_and_calibration(struct zd_chip *chip,
@@ -1218,7 +1218,7 @@ static int update_channel_integration_an
 	if (r)
 		return r;
 	if (chip->is_zd1211b) {
-		static const struct zd_ioreq32 ioreqs[] = {
+		static const struct zd_ioreq16 ioreqs[] = {
 			{ CR69, 0x28 },
 			{},
 			{ CR69, 0x2a },
@@ -1230,7 +1230,7 @@ static int update_channel_integration_an
 		r = update_pwr_cal(chip, channel);
 		if (r)
 			return r;
-		r = zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+		r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
 		if (r)
 			return r;
 	}
@@ -1252,7 +1252,7 @@ static int patch_cck_gain(struct zd_chip
 	if (r)
 		return r;
 	dev_dbg_f(zd_chip_dev(chip), "patching value %x\n", value & 0xff);
-	return zd_iowrite32_locked(chip, value & 0xff, CR47);
+	return zd_iowrite16_locked(chip, value & 0xff, CR47);
 }
 
 int zd_chip_set_channel(struct zd_chip *chip, u8 channel)
