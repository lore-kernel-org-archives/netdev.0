From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] usbnet: add support for some Huawei modems with cdc-ether
 ports
Date: Wed, 27 Apr 2011 14:54:28 -0500
Message-ID: <1303934071.25456.2.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some newer Huawei devices (T-Mobile Rocket, others) have cdc-ether
compatible ports, so recognize and expose them.

Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---

--- a/drivers/net/usb/cdc_ether.c	2011-04-25 13:49:56.928255316 -0500
+++ b/drivers/net/usb/cdc_ether.c	2011-04-25 13:50:05.487148317 -0500
@@ -458,7 +458,7 @@
 	.manage_power =	cdc_manage_power,
 };
 
-static const struct driver_info mbm_info = {
+static const struct driver_info wwan_info = {
 	.description =	"Mobile Broadband Network Device",
 	.flags =	FLAG_WWAN,
 	.bind = 	cdc_bind,
@@ -469,6 +469,7 @@
 
 /*-------------------------------------------------------------------------*/
 
+#define HUAWEI_VENDOR_ID	0x12D1
 
 static const struct usb_device_id	products [] = {
 /*
@@ -578,8 +579,17 @@
 }, {
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_MDLM,
 			USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long)&mbm_info,
+	.driver_info = (unsigned long)&wwan_info,
 
+}, {
+	/* Various Huawei modems with a network port like the UMG1831 */
+	.match_flags    =   USB_DEVICE_ID_MATCH_VENDOR
+		 | USB_DEVICE_ID_MATCH_INT_INFO,
+	.idVendor               = HUAWEI_VENDOR_ID,
+	.bInterfaceClass	= USB_CLASS_COMM,
+	.bInterfaceSubClass	= USB_CDC_SUBCLASS_ETHERNET,
+	.bInterfaceProtocol	= 255,
+	.driver_info = (unsigned long)&wwan_info,
 },
 	{ },		// END
 };


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
