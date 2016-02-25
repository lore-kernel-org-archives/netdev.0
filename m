From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 1/4] lan78xx: replace devid to chipid & chiprev
Date: Thu, 25 Feb 2016 23:33:07 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404B83D2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:63321 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752176AbcBYXdI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 18:33:08 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace devid to chipid & chiprev for easy access.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 20 +++++++++++---------
 drivers/net/usb/lan78xx.h |  1 +
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 1c299b8..4ec25e8 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -278,7 +278,8 @@ struct lan78xx_net {
 	int			link_on;
 	u8			mdix_ctrl;
 
-	u32			devid;
+	u32			chipid;
+	u32			chiprev;
 	struct mii_bus		*mdiobus;
 };
 
@@ -471,7 +472,7 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	 */
 	ret = lan78xx_read_reg(dev, HW_CFG, &val);
 	saved = val;
-	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000) {
+	if (dev->chipid == ID_REV_CHIP_ID_7800_) {
 		val &= ~(HW_CFG_LED1_EN_ | HW_CFG_LED0_EN_);
 		ret = lan78xx_write_reg(dev, HW_CFG, val);
 	}
@@ -505,7 +506,7 @@ static int lan78xx_read_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 
 	retval = 0;
 exit:
-	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000)
+	if (dev->chipid == ID_REV_CHIP_ID_7800_)
 		ret = lan78xx_write_reg(dev, HW_CFG, saved);
 
 	return retval;
@@ -539,7 +540,7 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 	 */
 	ret = lan78xx_read_reg(dev, HW_CFG, &val);
 	saved = val;
-	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000) {
+	if (dev->chipid == ID_REV_CHIP_ID_7800_) {
 		val &= ~(HW_CFG_LED1_EN_ | HW_CFG_LED0_EN_);
 		ret = lan78xx_write_reg(dev, HW_CFG, val);
 	}
@@ -587,7 +588,7 @@ static int lan78xx_write_raw_eeprom(struct lan78xx_net *dev, u32 offset,
 
 	retval = 0;
 exit:
-	if ((dev->devid & ID_REV_CHIP_ID_MASK_) == 0x78000000)
+	if (dev->chipid == ID_REV_CHIP_ID_7800_)
 		ret = lan78xx_write_reg(dev, HW_CFG, saved);
 
 	return retval;
@@ -1555,9 +1556,9 @@ static int lan78xx_mdio_init(struct lan78xx_net *dev)
 	snprintf(dev->mdiobus->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",
 		 dev->udev->bus->busnum, dev->udev->devnum);
 
-	switch (dev->devid & ID_REV_CHIP_ID_MASK_) {
-	case 0x78000000:
-	case 0x78500000:
+	switch (dev->chipid) {
+	case ID_REV_CHIP_ID_7800_:
+	case ID_REV_CHIP_ID_7850_:
 		/* set to internal PHY id */
 		dev->mdiobus->phy_mask = ~(1 << 1);
 		break;
@@ -1918,7 +1919,8 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 
 	/* save DEVID for later usage */
 	ret = lan78xx_read_reg(dev, ID_REV, &buf);
-	dev->devid = buf;
+	dev->chipid = (buf & ID_REV_CHIP_ID_MASK_) >> 16;
+	dev->chiprev = buf & ID_REV_CHIP_REV_MASK_;
 
 	/* Respond to the IN token with a NAK */
 	ret = lan78xx_read_reg(dev, USB_CFG0, &buf);
diff --git a/drivers/net/usb/lan78xx.h b/drivers/net/usb/lan78xx.h
index a93fb65..4092790 100644
--- a/drivers/net/usb/lan78xx.h
+++ b/drivers/net/usb/lan78xx.h
@@ -107,6 +107,7 @@
 #define ID_REV_CHIP_ID_MASK_		(0xFFFF0000)
 #define ID_REV_CHIP_REV_MASK_		(0x0000FFFF)
 #define ID_REV_CHIP_ID_7800_		(0x7800)
+#define ID_REV_CHIP_ID_7850_		(0x7850)
 
 #define FPGA_REV			(0x04)
 #define FPGA_REV_MINOR_MASK_		(0x0000FF00)
-- 
2.7.0
