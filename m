From: Aleksander Morgado <aleksander@aleksander.es>
Subject: [PATCH] cdc_ether: flag the u-blox TOBY-L2 and SARA-U2 as wwan
Date: Mon,  9 Oct 2017 14:05:12 +0200
Message-ID: <20171009120512.16681-1-aleksander@aleksander.es>
Cc: davem@davemloft.net, marco.demarco@u-blox.com,
        stefano.godeas@u-blox.com, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Aleksander Morgado <aleksander@aleksander.es>
To: oliver@neukum.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The u-blox TOBY-L2 is a LTE Cat 4 module with HSPA+ and 2G fallback.
This module allows switching to different USB profiles with the
'AT+UUSBCONF' command, and provides a ECM network interface when the
'AT+UUSBCONF=2' profile is selected.

The u-blox SARA-U2 is a HSPA module with 2G fallback. The default USB
configuration includes a ECM network interface.

Both these modules are controlled via AT commands through one of the
TTYs exposed. Connecting these modules may be done just by activating
the desired PDP context with 'AT+CGACT=1,<cid>' and then running DHCP
on the ECM interface.

Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
---
 drivers/net/usb/cdc_ether.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 29c7e2ec0dcb..52ea80bcd639 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -560,6 +560,7 @@ static const struct driver_info wwan_info = {
 #define NVIDIA_VENDOR_ID	0x0955
 #define HP_VENDOR_ID		0x03f0
 #define MICROSOFT_VENDOR_ID	0x045e
+#define UBLOX_VENDOR_ID		0x1546
 
 static const struct usb_device_id	products[] = {
 /* BLACKLIST !!
@@ -868,6 +869,18 @@ static const struct usb_device_id	products[] = {
 				      USB_CDC_SUBCLASS_ETHERNET,
 				      USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long)&zte_cdc_info,
+}, {
+	/* U-blox TOBY-L2 */
+	USB_DEVICE_AND_INTERFACE_INFO(UBLOX_VENDOR_ID, 0x1143, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long)&wwan_info,
+}, {
+	/* U-blox SARA-U2 */
+	USB_DEVICE_AND_INTERFACE_INFO(UBLOX_VENDOR_ID, 0x1104, USB_CLASS_COMM,
+				      USB_CDC_SUBCLASS_ETHERNET,
+				      USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long)&wwan_info,
 }, {
 	USB_INTERFACE_INFO(USB_CLASS_COMM, USB_CDC_SUBCLASS_ETHERNET,
 			USB_CDC_PROTO_NONE),
-- 
2.14.1
