From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 2/4] lan78xx: replace devid to chipid & chiprev
Date: Mon, 25 Jan 2016 23:02:25 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049DED4@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:51676 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933489AbcAYXC0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:02:26 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace devid of struct lan78xx_net to chipid & chiprev for easy access.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 11 +++++++----
 drivers/net/usb/lan78xx.h |  1 +
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 027ee37..7a8391b 100644
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
 
@@ -1511,8 +1512,9 @@ static int lan78xx_mdio_init(struct lan78xx_net *dev)
 	snprintf(dev->mdiobus->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",
 		 dev->udev->bus->busnum, dev->udev->devnum);
 
-	switch (dev->devid & ID_REV_CHIP_ID_MASK_) {
-	case 0x78000000:
+	switch (dev->chipid) {
+	case ID_REV_CHIP_ID_7800_:
+	case ID_REV_CHIP_ID_7850_:
 	case 0x78500000:
 		/* set to internal PHY id */
 		dev->mdiobus->phy_mask = ~(1 << 1);
@@ -1874,7 +1876,8 @@ static int lan78xx_reset(struct lan78xx_net *dev)
 
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
2.1.4
