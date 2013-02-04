From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/8] drivers: net: usb: Remove unnecessary alloc/OOM messages
Date: Sun,  3 Feb 2013 19:28:11 -0800
Message-ID: <821617b66116470eb036324879d584fea2bf8a70.1359939013.git.joe@perches.com>
References: <cover.1359939012.git.joe@perches.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jan Dumon <j.dumon@option.com>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Oliver Neukum <oneukum@suse.de>, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53466 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753952Ab3BDD3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2013 22:29:31 -0500
In-Reply-To: <cover.1359939012.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc failures already get standardized OOM
messages and a dump_stack.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/ax88172a.c   |  6 ++----
 drivers/net/usb/hso.c        | 25 +++++++------------------
 drivers/net/usb/sierra_net.c | 10 +++-------
 drivers/net/usb/smsc75xx.c   |  6 ++----
 drivers/net/usb/smsc95xx.c   |  6 ++----
 drivers/net/usb/usbnet.c     |  5 +----
 6 files changed, 17 insertions(+), 41 deletions(-)

diff --git a/drivers/net/usb/ax88172a.c b/drivers/net/usb/ax88172a.c
index 76ee541..d012203 100644
--- a/drivers/net/usb/ax88172a.c
+++ b/drivers/net/usb/ax88172a.c
@@ -117,7 +117,6 @@ static int ax88172a_init_mdio(struct usbnet *dev)
 
 	priv->mdio->irq = kzalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KERNEL);
 	if (!priv->mdio->irq) {
-		netdev_err(dev->net, "Could not allocate mdio->irq\n");
 		ret = -ENOMEM;
 		goto mfree;
 	}
@@ -236,10 +235,9 @@ static int ax88172a_bind(struct usbnet *dev, struct usb_interface *intf)
 	usbnet_get_endpoints(dev, intf);
 
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv) {
-		netdev_err(dev->net, "Could not allocate memory for private data\n");
+	if (!priv)
 		return -ENOMEM;
-	}
+
 	dev->driver_priv = priv;
 
 	/* Get the MAC address */
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index f902a14..e2dd324 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -2315,10 +2315,8 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 		serial->rx_urb[i]->transfer_buffer_length = 0;
 		serial->rx_data[i] = kzalloc(serial->rx_data_length,
 					     GFP_KERNEL);
-		if (!serial->rx_data[i]) {
-			dev_err(dev, "%s - Out of memory\n", __func__);
+		if (!serial->rx_data[i])
 			goto exit;
-		}
 	}
 
 	/* TX, allocate urb and initialize */
@@ -2334,15 +2332,12 @@ static int hso_serial_common_create(struct hso_serial *serial, int num_urbs,
 	serial->tx_buffer_count = 0;
 	serial->tx_data_length = tx_size;
 	serial->tx_data = kzalloc(serial->tx_data_length, GFP_KERNEL);
-	if (!serial->tx_data) {
-		dev_err(dev, "%s - Out of memory\n", __func__);
+	if (!serial->tx_data)
 		goto exit;
-	}
+
 	serial->tx_buffer = kzalloc(serial->tx_data_length, GFP_KERNEL);
-	if (!serial->tx_buffer) {
-		dev_err(dev, "%s - Out of memory\n", __func__);
+	if (!serial->tx_buffer)
 		goto exit;
-	}
 
 	return 0;
 exit:
@@ -2578,10 +2573,8 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
 		}
 		hso_net->mux_bulk_rx_buf_pool[i] = kzalloc(MUX_BULK_RX_BUF_SIZE,
 							   GFP_KERNEL);
-		if (!hso_net->mux_bulk_rx_buf_pool[i]) {
-			dev_err(&interface->dev, "Could not allocate rx buf\n");
+		if (!hso_net->mux_bulk_rx_buf_pool[i])
 			goto exit;
-		}
 	}
 	hso_net->mux_bulk_tx_urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!hso_net->mux_bulk_tx_urb) {
@@ -2589,10 +2582,8 @@ static struct hso_device *hso_create_net_device(struct usb_interface *interface,
 		goto exit;
 	}
 	hso_net->mux_bulk_tx_buf = kzalloc(MUX_BULK_TX_BUF_SIZE, GFP_KERNEL);
-	if (!hso_net->mux_bulk_tx_buf) {
-		dev_err(&interface->dev, "Could not allocate tx buf\n");
+	if (!hso_net->mux_bulk_tx_buf)
 		goto exit;
-	}
 
 	add_net_device(hso_dev);
 
@@ -2816,10 +2807,8 @@ struct hso_shared_int *hso_create_shared_int(struct usb_interface *interface)
 	mux->shared_intr_buf =
 		kzalloc(le16_to_cpu(mux->intr_endp->wMaxPacketSize),
 			GFP_KERNEL);
-	if (!mux->shared_intr_buf) {
-		dev_err(&interface->dev, "Could not allocate intr buf?\n");
+	if (!mux->shared_intr_buf)
 		goto exit;
-	}
 
 	mutex_init(&mux->shared_int_lock);
 
diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index 453aa6c..79ab243 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -459,11 +459,9 @@ static void sierra_net_kevent(struct work_struct *work)
 
 		/* Query the modem for the LSI message */
 		buf = kzalloc(SIERRA_NET_USBCTL_BUF_LEN, GFP_KERNEL);
-		if (!buf) {
-			netdev_err(dev->net,
-				"failed to allocate buf for LS msg\n");
+		if (!buf)
 			return;
-		}
+
 		ifnum = priv->ifnum;
 		len = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
 				USB_CDC_GET_ENCAPSULATED_RESPONSE,
@@ -686,10 +684,8 @@ static int sierra_net_bind(struct usbnet *dev, struct usb_interface *intf)
 	}
 	/* Initialize sierra private data */
 	priv = kzalloc(sizeof *priv, GFP_KERNEL);
-	if (!priv) {
-		dev_err(&dev->udev->dev, "No memory");
+	if (!priv)
 		return -ENOMEM;
-	}
 
 	priv->usbnet = dev;
 	priv->ifnum = ifacenum;
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 251a335..9abe517 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1393,13 +1393,11 @@ static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	}
 
 	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc75xx_priv),
-		GFP_KERNEL);
+					      GFP_KERNEL);
 
 	pdata = (struct smsc75xx_priv *)(dev->data[0]);
-	if (!pdata) {
-		netdev_warn(dev->net, "Unable to allocate smsc75xx_priv\n");
+	if (!pdata)
 		return -ENOMEM;
-	}
 
 	pdata->dev = dev;
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 6a74a68..ff4fa37 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1116,13 +1116,11 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	}
 
 	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc95xx_priv),
-		GFP_KERNEL);
+					      GFP_KERNEL);
 
 	pdata = (struct smsc95xx_priv *)(dev->data[0]);
-	if (!pdata) {
-		netdev_warn(dev->net, "Unable to allocate struct smsc95xx_priv\n");
+	if (!pdata)
 		return -ENOMEM;
-	}
 
 	spin_lock_init(&pdata->mac_cr_lock);
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9778377..c879442 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1815,11 +1815,8 @@ int usbnet_write_cmd_async(struct usbnet *dev, u8 cmd, u8 reqtype,
 	}
 
 	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
-	if (!req) {
-		netdev_err(dev->net, "Failed to allocate memory for %s\n",
-			   __func__);
+	if (!req)
 		goto fail_free_buf;
-	}
 
 	req->bRequestType = reqtype;
 	req->bRequest = cmd;
-- 
1.8.0.dirty
