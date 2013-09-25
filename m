From: Fabio Porcedda <fabio.porcedda@gmail.com>
Subject: [PATCH 2/2] net: qmi_wwan: fix checkpatch warnings
Date: Wed, 25 Sep 2013 11:21:26 +0200
Message-ID: <1380100886-16531-2-git-send-email-fabio.porcedda@gmail.com>
References: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com>
Cc: linux-usb@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:41161 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab3IYJVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 05:21:35 -0400
In-Reply-To: <1380100886-16531-1-git-send-email-fabio.porcedda@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabio Porcedda <fabio.porcedda@gmail.com>
---
 drivers/net/usb/qmi_wwan.c | 56 +++++++++++++++++++++++++++++-----------------
 1 file changed, 36 insertions(+), 20 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 5f6b6fa..0e59f9e 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -143,16 +143,22 @@ static const struct net_device_ops qmi_wwan_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
-/* using a counter to merge subdriver requests with our own into a combined state */
+/* using a counter to merge subdriver requests with our own into a
+ * combined state
+ */
 static int qmi_wwan_manage_power(struct usbnet *dev, int on)
 {
 	struct qmi_wwan_state *info = (void *)&dev->data;
 	int rv = 0;
 
-	dev_dbg(&dev->intf->dev, "%s() pmcount=%d, on=%d\n", __func__, atomic_read(&info->pmcount), on);
+	dev_dbg(&dev->intf->dev, "%s() pmcount=%d, on=%d\n", __func__,
+		atomic_read(&info->pmcount), on);
 
-	if ((on && atomic_add_return(1, &info->pmcount) == 1) || (!on && atomic_dec_and_test(&info->pmcount))) {
-		/* need autopm_get/put here to ensure the usbcore sees the new value */
+	if ((on && atomic_add_return(1, &info->pmcount) == 1) ||
+	    (!on && atomic_dec_and_test(&info->pmcount))) {
+		/* need autopm_get/put here to ensure the usbcore sees
+		 * the new value
+		 */
 		rv = usb_autopm_get_interface(dev->intf);
 		if (rv < 0)
 			goto err;
@@ -199,7 +205,8 @@ static int qmi_wwan_register_subdriver(struct usbnet *dev)
 	atomic_set(&info->pmcount, 0);
 
 	/* register subdriver */
-	subdriver = usb_cdc_wdm_register(info->control, &dev->status->desc, 4096, &qmi_wwan_cdc_wdm_manage_power);
+	subdriver = usb_cdc_wdm_register(info->control, &dev->status->desc,
+					 4096, &qmi_wwan_cdc_wdm_manage_power);
 	if (IS_ERR(subdriver)) {
 		dev_err(&info->control->dev, "subdriver registration failed\n");
 		rv = PTR_ERR(subdriver);
@@ -228,7 +235,8 @@ static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *intf)
 	struct usb_driver *driver = driver_of(intf);
 	struct qmi_wwan_state *info = (void *)&dev->data;
 
-	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) < sizeof(struct qmi_wwan_state)));
+	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data) <
+		      sizeof(struct qmi_wwan_state)));
 
 	/* set up initial state */
 	info->control = intf;
@@ -250,7 +258,8 @@ static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *intf)
 				goto err;
 			}
 			if (h->bLength != sizeof(struct usb_cdc_header_desc)) {
-				dev_dbg(&intf->dev, "CDC header len %u\n", h->bLength);
+				dev_dbg(&intf->dev, "CDC header len %u\n",
+					h->bLength);
 				goto err;
 			}
 			break;
@@ -260,7 +269,8 @@ static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *intf)
 				goto err;
 			}
 			if (h->bLength != sizeof(struct usb_cdc_union_desc)) {
-				dev_dbg(&intf->dev, "CDC union len %u\n", h->bLength);
+				dev_dbg(&intf->dev, "CDC union len %u\n",
+					h->bLength);
 				goto err;
 			}
 			cdc_union = (struct usb_cdc_union_desc *)buf;
@@ -271,15 +281,15 @@ static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *intf)
 				goto err;
 			}
 			if (h->bLength != sizeof(struct usb_cdc_ether_desc)) {
-				dev_dbg(&intf->dev, "CDC ether len %u\n",  h->bLength);
+				dev_dbg(&intf->dev, "CDC ether len %u\n",
+					h->bLength);
 				goto err;
 			}
 			cdc_ether = (struct usb_cdc_ether_desc *)buf;
 			break;
 		}
 
-		/*
-		 * Remember which CDC functional descriptors we've seen.  Works
+		/* Remember which CDC functional descriptors we've seen.  Works
 		 * for all types we care about, of which USB_CDC_ETHERNET_TYPE
 		 * (0x0f) is the highest numbered
 		 */
@@ -293,10 +303,14 @@ next_desc:
 
 	/* Use separate control and data interfaces if we found a CDC Union */
 	if (cdc_union) {
-		info->data = usb_ifnum_to_if(dev->udev, cdc_union->bSlaveInterface0);
-		if (desc->bInterfaceNumber != cdc_union->bMasterInterface0 || !info->data) {
-			dev_err(&intf->dev, "bogus CDC Union: master=%u, slave=%u\n",
-				cdc_union->bMasterInterface0, cdc_union->bSlaveInterface0);
+		info->data = usb_ifnum_to_if(dev->udev,
+					     cdc_union->bSlaveInterface0);
+		if (desc->bInterfaceNumber != cdc_union->bMasterInterface0 ||
+		    !info->data) {
+			dev_err(&intf->dev,
+				"bogus CDC Union: master=%u, slave=%u\n",
+				cdc_union->bMasterInterface0,
+				cdc_union->bSlaveInterface0);
 			goto err;
 		}
 	}
@@ -374,8 +388,7 @@ static int qmi_wwan_suspend(struct usb_interface *intf, pm_message_t message)
 	struct qmi_wwan_state *info = (void *)&dev->data;
 	int ret;
 
-	/*
-	 * Both usbnet_suspend() and subdriver->suspend() MUST return 0
+	/* Both usbnet_suspend() and subdriver->suspend() MUST return 0
 	 * in system sleep context, otherwise, the resume callback has
 	 * to recover device from previous suspend failure.
 	 */
@@ -383,7 +396,8 @@ static int qmi_wwan_suspend(struct usb_interface *intf, pm_message_t message)
 	if (ret < 0)
 		goto err;
 
-	if (intf == info->control && info->subdriver && info->subdriver->suspend)
+	if (intf == info->control && info->subdriver &&
+	    info->subdriver->suspend)
 		ret = info->subdriver->suspend(intf, message);
 	if (ret < 0)
 		usbnet_resume(intf);
@@ -396,7 +410,8 @@ static int qmi_wwan_resume(struct usb_interface *intf)
 	struct usbnet *dev = usb_get_intfdata(intf);
 	struct qmi_wwan_state *info = (void *)&dev->data;
 	int ret = 0;
-	bool callsub = (intf == info->control && info->subdriver && info->subdriver->resume);
+	bool callsub = (intf == info->control && info->subdriver &&
+			info->subdriver->resume);
 
 	if (callsub)
 		ret = info->subdriver->resume(intf);
@@ -777,7 +792,8 @@ static const struct usb_device_id products[] = {
 };
 MODULE_DEVICE_TABLE(usb, products);
 
-static int qmi_wwan_probe(struct usb_interface *intf, const struct usb_device_id *prod)
+static int qmi_wwan_probe(struct usb_interface *intf,
+			  const struct usb_device_id *prod)
 {
 	struct usb_device_id *id = (struct usb_device_id *)prod;
 
-- 
1.8.4
