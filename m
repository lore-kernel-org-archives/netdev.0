From: Fabio Porcedda <fabio.porcedda@gmail.com>
Subject: [PATCH 2/3] net: usb: cdc_ether: fix checkpatch errors and warnings
Date: Mon, 16 Sep 2013 11:47:51 +0200
Message-ID: <1379324872-15944-3-git-send-email-fabio.porcedda@gmail.com>
References: <1379324872-15944-1-git-send-email-fabio.porcedda@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:58754 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932126Ab3IPJsE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 05:48:04 -0400
In-Reply-To: <1379324872-15944-1-git-send-email-fabio.porcedda@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabio Porcedda <fabio.porcedda@gmail.com>
---
 drivers/net/usb/cdc_ether.c | 47 +++++++++++++++++++--------------------------
 1 file changed, 20 insertions(+), 27 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 98aef3b..c36b1c3 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -33,7 +33,7 @@
 #include <linux/usb/usbnet.h>
 
 
-#if defined(CONFIG_USB_NET_RNDIS_HOST) || defined(CONFIG_USB_NET_RNDIS_HOST_MODULE)
+#if IS_ENABLED(CONFIG_USB_NET_RNDIS_HOST)
 
 static int is_rndis(struct usb_interface_descriptor *desc)
 {
@@ -69,8 +69,7 @@ static const u8 mbm_guid[16] = {
 	0xa6, 0x07, 0xc0, 0xff, 0xcb, 0x7e, 0x39, 0x2a,
 };
 
-/*
- * probes control interface, claims data interface, collects the bulk
+/* probes control interface, claims data interface, collects the bulk
  * endpoints, activates data interface (if needed), maybe sets MTU.
  * all pure cdc, except for certain firmware workarounds, and knowing
  * that rndis uses one different rule.
@@ -88,7 +87,7 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 	struct usb_cdc_mdlm_desc	*desc = NULL;
 	struct usb_cdc_mdlm_detail_desc *detail = NULL;
 
-	if (sizeof dev->data < sizeof *info)
+	if (sizeof(dev->data) < sizeof(*info))
 		return -EDOM;
 
 	/* expect strict spec conformance for the descriptors, but
@@ -126,10 +125,10 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 		 is_activesync(&intf->cur_altsetting->desc) ||
 		 is_wireless_rndis(&intf->cur_altsetting->desc));
 
-	memset(info, 0, sizeof *info);
+	memset(info, 0, sizeof(*info));
 	info->control = intf;
 	while (len > 3) {
-		if (buf [1] != USB_DT_CS_INTERFACE)
+		if (buf[1] != USB_DT_CS_INTERFACE)
 			goto next_desc;
 
 		/* use bDescriptorSubType to identify the CDC descriptors.
@@ -139,14 +138,14 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 		 * in favor of a complicated OID-based RPC scheme doing what
 		 * CDC Ethernet achieves with a simple descriptor.
 		 */
-		switch (buf [2]) {
+		switch (buf[2]) {
 		case USB_CDC_HEADER_TYPE:
 			if (info->header) {
 				dev_dbg(&intf->dev, "extra CDC header\n");
 				goto bad_desc;
 			}
 			info->header = (void *) buf;
-			if (info->header->bLength != sizeof *info->header) {
+			if (info->header->bLength != sizeof(*info->header)) {
 				dev_dbg(&intf->dev, "CDC header len %u\n",
 					info->header->bLength);
 				goto bad_desc;
@@ -175,7 +174,7 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 				goto bad_desc;
 			}
 			info->u = (void *) buf;
-			if (info->u->bLength != sizeof *info->u) {
+			if (info->u->bLength != sizeof(*info->u)) {
 				dev_dbg(&intf->dev, "CDC union len %u\n",
 					info->u->bLength);
 				goto bad_desc;
@@ -233,7 +232,7 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 				goto bad_desc;
 			}
 			info->ether = (void *) buf;
-			if (info->ether->bLength != sizeof *info->ether) {
+			if (info->ether->bLength != sizeof(*info->ether)) {
 				dev_dbg(&intf->dev, "CDC ether len %u\n",
 					info->ether->bLength);
 				goto bad_desc;
@@ -274,8 +273,8 @@ int usbnet_generic_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
 			break;
 		}
 next_desc:
-		len -= buf [0];	/* bLength */
-		buf += buf [0];
+		len -= buf[0];	/* bLength */
+		buf += buf[0];
 	}
 
 	/* Microsoft ActiveSync based and some regular RNDIS devices lack the
@@ -379,9 +378,7 @@ void usbnet_cdc_unbind(struct usbnet *dev, struct usb_interface *intf)
 }
 EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
 
-/*-------------------------------------------------------------------------
- *
- * Communications Device Class, Ethernet Control model
+/* Communications Device Class, Ethernet Control model
  *
  * Takes two interfaces.  The DATA interface is inactive till an altsetting
  * is selected.  Configuration data includes class descriptors.  There's
@@ -389,8 +386,7 @@ EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
  *
  * This should interop with whatever the 2.4 "CDCEther.c" driver
  * (by Brad Hards) talked with, with more functionality.
- *
- *-------------------------------------------------------------------------*/
+ */
 
 static void dumpspeed(struct usbnet *dev, __le32 *speeds)
 {
@@ -404,7 +400,7 @@ void usbnet_cdc_status(struct usbnet *dev, struct urb *urb)
 {
 	struct usb_cdc_notification	*event;
 
-	if (urb->actual_length < sizeof *event)
+	if (urb->actual_length < sizeof(*event))
 		return;
 
 	/* SPEED_CHANGE can get split into two 8-byte packets */
@@ -423,7 +419,7 @@ void usbnet_cdc_status(struct usbnet *dev, struct urb *urb)
 	case USB_CDC_NOTIFY_SPEED_CHANGE:	/* tx/rx rates */
 		netif_dbg(dev, timer, dev->net, "CDC: speed change (len %d)\n",
 			  urb->actual_length);
-		if (urb->actual_length != (sizeof *event + 8))
+		if (urb->actual_length != (sizeof(*event) + 8))
 			set_bit(EVENT_STS_SPLIT, &dev->flags);
 		else
 			dumpspeed(dev, (__le32 *) &event[1]);
@@ -469,7 +465,6 @@ EXPORT_SYMBOL_GPL(usbnet_cdc_bind);
 static const struct driver_info	cdc_info = {
 	.description =	"CDC Ethernet Device",
 	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
-	// .check_connect = cdc_check_connect,
 	.bind =		usbnet_cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
 	.status =	usbnet_cdc_status,
@@ -493,9 +488,8 @@ static const struct driver_info wwan_info = {
 #define DELL_VENDOR_ID		0x413C
 #define REALTEK_VENDOR_ID	0x0bda
 
-static const struct usb_device_id	products [] = {
-/*
- * BLACKLIST !!
+static const struct usb_device_id	products[] = {
+/* BLACKLIST !!
  *
  * First blacklist any products that are egregiously nonconformant
  * with the CDC Ethernet specs.  Minor braindamage we cope with; when
@@ -542,7 +536,7 @@ static const struct usb_device_id	products [] = {
 	.driver_info		= 0,
 }, {
 	.match_flags    =   USB_DEVICE_ID_MATCH_INT_INFO
-	          | USB_DEVICE_ID_MATCH_DEVICE,
+			  | USB_DEVICE_ID_MATCH_DEVICE,
 	.idVendor		= 0x04DD,
 	.idProduct		= 0x8007,	/* C-700 */
 	ZAURUS_MASTER_INTERFACE,
@@ -659,8 +653,7 @@ static const struct usb_device_id	products [] = {
 	.driver_info = 0,
 },
 
-/*
- * WHITELIST!!!
+/* WHITELIST!!!
  *
  * CDC Ether uses two interfaces, not necessarily consecutive.
  * We match the main interface, ignoring the optional device
@@ -749,7 +742,7 @@ static const struct usb_device_id	products [] = {
 	.bInterfaceProtocol	= 255,
 	.driver_info = (unsigned long)&wwan_info,
 },
-	{ },		// END
+	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
 
-- 
1.8.4
