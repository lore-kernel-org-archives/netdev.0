From: Tushar Behera <tushar.behera@linaro.org>
Subject: [PATCH] usbnet: dm9601: Fix incorrect command
Date: Tue, 15 Jan 2013 11:09:01 +0530
Message-ID: <1358228341-2104-1-git-send-email-tushar.behera@linaro.org>
Cc: gregkh@linuxfoundation.org, jacmet@sunsite.dk, patches@linaro.org,
	Ming Lei <ming.lei@canonical.com>
To: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 24b1042c4eb2 ("usbnet: dm9601: apply introduced usb command
APIs") removes the distiction between DM_WRITE_REG and DM_WRITE_REGS
command. The distiction is reintroduced to the driver so that the
functionality of the driver remains same.

CC: Ming Lei <ming.lei@canonical.com>
Signed-off-by: Tushar Behera <tushar.behera@linaro.org>
---
 drivers/net/usb/dm9601.c |   22 ++++++----------------
 1 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 3f554c1..011410f 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -53,7 +53,6 @@
 #define DM_RX_OVERHEAD	7	/* 3 byte header + 4 byte crc tail */
 #define DM_TIMEOUT	1000
 
-
 static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
 	int err;
@@ -84,32 +83,23 @@ static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 
 static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
 {
-	return usbnet_write_cmd(dev, DM_WRITE_REGS,
+	return usbnet_write_cmd(dev, DM_WRITE_REG,
 				USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 				value, reg, NULL, 0);
 }
 
-static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
-				  u16 length, void *data)
+static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
 	usbnet_write_cmd_async(dev, DM_WRITE_REGS,
 			       USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-			       value, reg, data, length);
-}
-
-static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
-{
-	netdev_dbg(dev->net, "dm_write_async() reg=0x%02x length=%d\n", reg, length);
-
-	dm_write_async_helper(dev, reg, 0, length, data);
+			       0, reg, data, length);
 }
 
 static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
 {
-	netdev_dbg(dev->net, "dm_write_reg_async() reg=0x%02x value=0x%02x\n",
-		   reg, value);
-
-	dm_write_async_helper(dev, reg, value, 0, NULL);
+	usbnet_write_cmd_async(dev, DM_WRITE_REG,
+			       USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       value, reg, NULL, 0);
 }
 
 static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *value)
-- 
1.7.4.1
