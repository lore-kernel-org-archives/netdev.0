From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 5/5] net-next:asix: update VERSION and white space changes
Date: Mon, 14 Nov 2011 15:22:01 -0800
Message-ID: <1321312921-7748-5-git-send-email-grundler@chromium.org>
References: <1321312921-7748-1-git-send-email-grundler@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>,
	Grant Grundler <grundler@chromium.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:54100 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756688Ab1KNXXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 18:23:24 -0500
In-Reply-To: <1321312921-7748-1-git-send-email-grundler@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional changes. Three things targeted:
o update VERSION to reflect previous changes.
o fix up white space/formatting of some lines
o define 150 to be AX_SWRESET_MDELAY (self documenting code)

Signed-off-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/asix.c |   46 +++++++++++++++++++++-------------------------
 1 files changed, 21 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index c07dd26..29598dc 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -36,7 +36,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
 
-#define DRIVER_VERSION "26-Sep-2011"
+#define DRIVER_VERSION "08-Nov-2011"
 #define DRIVER_NAME "asix"
 
 /* ASIX AX8817X based USB 2.0 Ethernet Devices */
@@ -94,6 +94,8 @@
 #define AX_SWRESET_IPRL			0x20
 #define AX_SWRESET_IPPD			0x40
 
+#define AX_SWRESET_MDELAY	150
+
 #define AX88772_IPG0_DEFAULT		0x15
 #define AX88772_IPG1_DEFAULT		0x0c
 #define AX88772_IPG2_DEFAULT		0x12
@@ -494,9 +496,9 @@ static int asix_sw_reset(struct usbnet *dev, u8 flags)
 {
 	int ret;
 
-        ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
+	ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
 	if (ret < 0)
-		netdev_err(dev->net, "Failed to send software reset: %02x\n", ret);
+		netdev_err(dev->net, "Failed to send SW_RESET: %02x\n", ret);
 
 	return ret;
 }
@@ -540,7 +542,6 @@ static u16 asix_read_medium_status(struct usbnet *dev)
 	}
 
 	return le16_to_cpu(v);
-
 }
 
 static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
@@ -792,9 +793,9 @@ static int asix_set_mac_address(struct net_device *net, void *p)
 	return 0;
 }
 
-/* We need to override some ethtool_ops so we require our
-   own structure so we don't interfere with other usbnet
-   devices that may be connected at the same time. */
+/* We override some ethtool_ops to access per device data.
+ * Multiple usbnet devices may be connected at the same time.
+ */
 static const struct ethtool_ops ax88172_ethtool_ops = {
 	.get_drvinfo		= asix_get_drvinfo,
 	.get_link		= asix_get_link,
@@ -994,25 +995,20 @@ static int ax88772_reset(struct usbnet *dev)
 	if (ret < 0)
 		goto out;
 
-	msleep(150);
+	msleep(AX_SWRESET_MDELAY);
 
 	ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
 	if (ret < 0)
 		goto out;
 
-	msleep(150);
+	msleep(AX_SWRESET_MDELAY);
 
-	if (embd_phy) {
-		ret = asix_sw_reset(dev, AX_SWRESET_IPRL);
-		if (ret < 0)
-			goto out;
-	} else {
-		ret = asix_sw_reset(dev, AX_SWRESET_PRTE);
-		if (ret < 0)
-			goto out;
-	}
+	ret = asix_sw_reset(dev, embd_phy ? AX_SWRESET_IPRL : AX_SWRESET_PRTE);
+	if (ret < 0)
+		goto out;
+
+	msleep(AX_SWRESET_MDELAY);
 
-	msleep(150);
 	rx_ctl = asix_read_rx_ctl(dev);
 	dbg("RX_CTL is 0x%04x after software reset", rx_ctl);
 	ret = asix_write_rx_ctl(dev, 0x0000);
@@ -1026,13 +1022,13 @@ static int ax88772_reset(struct usbnet *dev)
 	if (ret < 0)
 		goto out;
 
-	msleep(150);
+	msleep(AX_SWRESET_MDELAY);
 
 	ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL);
 	if (ret < 0)
 		goto out;
 
-	msleep(150);
+	msleep(AX_SWRESET_MDELAY);
 
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
@@ -1290,10 +1286,10 @@ static int ax88178_reset(struct usbnet *dev)
 	asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, 0, 0, 0, NULL);
 
 	asix_sw_reset(dev, 0);
-	msleep(150);
+	msleep(AX_SWRESET_MDELAY);
 
 	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
-	msleep(150);
+	msleep(AX_SWRESET_MDELAY);
 
 	asix_write_rx_ctl(dev, 0);
 
@@ -1672,13 +1668,13 @@ static struct usb_driver asix_driver = {
 
 static int __init asix_init(void)
 {
- 	return usb_register(&asix_driver);
+	return usb_register(&asix_driver);
 }
 module_init(asix_init);
 
 static void __exit asix_exit(void)
 {
- 	usb_deregister(&asix_driver);
+	usb_deregister(&asix_driver);
 }
 module_exit(asix_exit);
 
-- 
1.7.3.1
