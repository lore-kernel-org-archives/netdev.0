From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 3/3] NET: white space/coding style cleanup of asix driver
Date: Tue,  4 Oct 2011 12:55:18 -0700
Message-ID: <1317758118-24052-3-git-send-email-grundler@chromium.org>
References: <1317758118-24052-1-git-send-email-grundler@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	allan@asix.com.tw, Grant Grundler <grundler@chromium.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317758118-24052-1-git-send-email-grundler@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

check patch was complaining...mostly replaced:
   if ((ret = asix_foo(xx)) < 0) ...
with
   ret = asix_foo(xx);
   if (ret < 0) ...

Signed-off-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/asix.c |  153 ++++++++++++++++++++++++++----------------------
 1 files changed, 82 insertions(+), 71 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 23ee22d..66e5ccb 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -37,7 +37,7 @@
 #include <linux/slab.h>
 
 #define DRIVER_VERSION "26-Sep-2011"
-static const char driver_name [] = "asix";
+#define DRIVER_NAME "asix"
 
 /* ASIX AX8817X based USB 2.0 Ethernet Devices */
 
@@ -115,28 +115,27 @@ static const char driver_name [] = "asix";
 #define AX88178_MEDIUM_DEFAULT	\
 	(AX_MEDIUM_PS | AX_MEDIUM_FD | AX_MEDIUM_AC | \
 	 AX_MEDIUM_RFC | AX_MEDIUM_TFC | AX_MEDIUM_JFE | \
-	 AX_MEDIUM_RE )
+	 AX_MEDIUM_RE)
 
 #define AX88772_MEDIUM_DEFAULT	\
 	(AX_MEDIUM_FD | AX_MEDIUM_RFC | \
 	 AX_MEDIUM_TFC | AX_MEDIUM_PS | \
-	 AX_MEDIUM_AC | AX_MEDIUM_RE )
+	 AX_MEDIUM_AC | AX_MEDIUM_RE)
 
 /* AX88772 & AX88178 RX_CTL values */
-#define AX_RX_CTL_SO			0x0080
-#define AX_RX_CTL_AP			0x0020
-#define AX_RX_CTL_AM			0x0010
-#define AX_RX_CTL_AB			0x0008
-#define AX_RX_CTL_SEP			0x0004
-#define AX_RX_CTL_AMALL			0x0002
-#define AX_RX_CTL_PRO			0x0001
-#define AX_RX_CTL_MFB_2048		0x0000
-#define AX_RX_CTL_MFB_4096		0x0100
-#define AX_RX_CTL_MFB_8192		0x0200
-#define AX_RX_CTL_MFB_16384		0x0300
-
-#define AX_DEFAULT_RX_CTL	\
-	(AX_RX_CTL_SO | AX_RX_CTL_AB )
+#define AX_RX_CTL_SO		0x0080
+#define AX_RX_CTL_AP		0x0020
+#define AX_RX_CTL_AM		0x0010
+#define AX_RX_CTL_AB		0x0008
+#define AX_RX_CTL_SEP		0x0004
+#define AX_RX_CTL_AMALL		0x0002
+#define AX_RX_CTL_PRO		0x0001
+#define AX_RX_CTL_MFB_2048	0x0000
+#define AX_RX_CTL_MFB_4096	0x0100
+#define AX_RX_CTL_MFB_8192	0x0200
+#define AX_RX_CTL_MFB_16384	0x0300
+
+#define AX_DEFAULT_RX_CTL	(AX_RX_CTL_SO | AX_RX_CTL_AB)
 
 /* GPIO 0 .. 2 toggles */
 #define AX_GPIO_GPO0EN		0x01	/* GPIO0 Output enable */
@@ -270,12 +269,15 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 
 	netdev_dbg(dev->net, "asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
 		   cmd, value, index, size);
-	if ((urb = usb_alloc_urb(0, GFP_ATOMIC)) == NULL) {
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
 		netdev_err(dev->net, "Error allocating URB in write_cmd_async!\n");
 		return;
 	}
 
-	if ((req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC)) == NULL) {
+	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
+	if (!req) {
 		netdev_err(dev->net, "Failed to allocate memory for control request\n");
 		usb_free_urb(urb);
 		return;
@@ -292,7 +294,8 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			     (void *)req, data, size,
 			     asix_async_cmd_callback, req);
 
-	if((status = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
+	status = usb_submit_urb(urb, GFP_ATOMIC);
+	if (status < 0) {
 		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
 			   status);
 		kfree(req);
@@ -534,11 +537,11 @@ static u16 asix_read_medium_status(struct usbnet *dev)
 	if (ret < 0) {
 		netdev_err(dev->net, "Error reading Medium Status register: %02x\n",
 			   ret);
-		goto out;
+		return ret;	/* TODO: callers not checking for error ret */
 	}
-	ret = le16_to_cpu(v);
-out:
-	return ret;
+
+	return le16_to_cpu(v);
+
 }
 
 static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
@@ -739,7 +742,7 @@ static void asix_get_drvinfo (struct net_device *net,
 
 	/* Inherit standard device info */
 	usbnet_get_drvinfo(net, info);
-	strncpy (info->driver, driver_name, sizeof info->driver);
+	strncpy (info->driver, DRIVER_NAME, sizeof info->driver);
 	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
 	info->eedump_len = data->eeprom_len;
 }
@@ -884,19 +887,20 @@ static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	/* Toggle the GPIOs in a manufacturer/model specific way */
 	for (i = 2; i >= 0; i--) {
-		if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS,
-					(gpio_bits >> (i * 8)) & 0xff, 0, 0,
-					NULL)) < 0)
+		ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS,
+				(gpio_bits >> (i * 8)) & 0xff, 0, 0, NULL);
+		if (ret < 0)
 			goto out;
 		msleep(5);
 	}
 
-	if ((ret = asix_write_rx_ctl(dev, 0x80)) < 0)
+	ret = asix_write_rx_ctl(dev, 0x80);
+	if (ret < 0)
 		goto out;
 
 	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
+	ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
+	if (ret < 0) {
 		dbg("read AX_CMD_READ_NODE_ID failed: %d", ret);
 		goto out;
 	}
@@ -967,51 +971,59 @@ static int ax88772_reset(struct usbnet *dev)
 	int ret, embd_phy;
 	u16 rx_ctl;
 
-	if ((ret = asix_write_gpio(dev,
-			AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5)) < 0)
+	ret = asix_write_gpio(dev,
+			AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5);
+	if (ret < 0)
 		goto out;
 
 	embd_phy = ((asix_get_phy_addr(dev) & 0x1f) == 0x10 ? 1 : 0);
 
-	if ((ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT,
-				embd_phy, 0, 0, NULL)) < 0) {
+	ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
+	if (ret < 0) {
 		dbg("Select PHY #1 failed: %d", ret);
 		goto out;
 	}
 
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL)) < 0)
+	ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL);
+	if (ret < 0)
 		goto out;
 
 	msleep(150);
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_CLEAR)) < 0)
+
+	ret = asix_sw_reset(dev, AX_SWRESET_CLEAR);
+	if (ret < 0)
 		goto out;
 
 	msleep(150);
 
 	if (embd_phy) {
-		if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
+		ret = asix_sw_reset(dev, AX_SWRESET_IPRL);
+		if (ret < 0)
 			goto out;
-	}
-	else {
-		if ((ret = asix_sw_reset(dev, AX_SWRESET_PRTE)) < 0)
+	} else {
+		ret = asix_sw_reset(dev, AX_SWRESET_PRTE);
+		if (ret < 0)
 			goto out;
 	}
 
 	msleep(150);
 	rx_ctl = asix_read_rx_ctl(dev);
 	dbg("RX_CTL is 0x%04x after software reset", rx_ctl);
-	if ((ret = asix_write_rx_ctl(dev, 0x0000)) < 0)
+	ret = asix_write_rx_ctl(dev, 0x0000);
+	if (ret < 0)
 		goto out;
 
 	rx_ctl = asix_read_rx_ctl(dev);
 	dbg("RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
 
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_PRL)) < 0)
+	ret = asix_sw_reset(dev, AX_SWRESET_PRL);
+	if (ret < 0)
 		goto out;
 
 	msleep(150);
 
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL)) < 0)
+	ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL);
+	if (ret < 0)
 		goto out;
 
 	msleep(150);
@@ -1021,18 +1033,21 @@ static int ax88772_reset(struct usbnet *dev)
 			ADVERTISE_ALL | ADVERTISE_CSMA);
 	mii_nway_restart(&dev->mii);
 
-	if ((ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT)) < 0)
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
+	if (ret < 0)
 		goto out;
 
-	if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
 				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
-				AX88772_IPG2_DEFAULT, 0, NULL)) < 0) {
+				AX88772_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
 		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
 		goto out;
 	}
 
 	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
-	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
+	ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
+	if (ret < 0)
 		goto out;
 
 	rx_ctl = asix_read_rx_ctl(dev);
@@ -1072,10 +1087,10 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	usbnet_get_endpoints(dev,intf);
 
 	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
+	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
+	if (ret < 0) {
 		dbg("Failed to read MAC address: %d", ret);
-		goto out;
+		return ret;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
 
@@ -1093,8 +1108,9 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->netdev_ops = &ax88772_netdev_ops;
 	dev->net->ethtool_ops = &ax88772_ethtool_ops;
 
-	if ((ret = ax88772_reset(dev)) < 0)
-		goto out;
+	ret = ax88772_reset(dev);
+	if (ret < 0)
+		return ret;
 
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
@@ -1102,9 +1118,8 @@ static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 		   jumbo eth frames */
 		dev->rx_urb_size = 2048;
 	}
+
 	return 0;
-out:
-	return ret;
 }
 
 static struct ethtool_ops ax88178_ethtool_ops = {
@@ -1262,17 +1277,15 @@ static int ax88178_reset(struct usbnet *dev)
 
 	mii_nway_restart(&dev->mii);
 
-	if ((ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT)) < 0)
-		goto out;
+	ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT);
+	if (ret < 0)
+		return ret;
 
-	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
-		goto out;
+	ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL);
+	if (ret < 0)
+		return ret;
 
 	return 0;
-
-out:
-	return ret;
-
 }
 
 static int ax88178_link_reset(struct usbnet *dev)
@@ -1390,10 +1403,10 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 	usbnet_get_endpoints(dev,intf);
 
 	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
+	ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID, 0, 0, ETH_ALEN, buf);
+	if (ret < 0) {
 		dbg("Failed to read MAC address: %d", ret);
-		goto out;
+		return ret;
 	}
 	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
 
@@ -1414,7 +1427,7 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	ret = ax88178_reset(dev);
 	if (ret < 0)
-		goto out;
+		return ret;
 
 	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
 	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
@@ -1422,10 +1435,8 @@ static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
 		   jumbo eth frames */
 		dev->rx_urb_size = 2048;
 	}
-	return 0;
 
-out:
-	return ret;
+	return 0;
 }
 
 static const struct driver_info ax8817x_info = {
@@ -1609,7 +1620,7 @@ static const struct usb_device_id	products [] = {
 MODULE_DEVICE_TABLE(usb, products);
 
 static struct usb_driver asix_driver = {
-	.name =		"asix",
+	.name =		DRIVER_NAME,
 	.id_table =	products,
 	.probe =	usbnet_probe,
 	.suspend =	usbnet_suspend,
-- 
1.7.2.3
