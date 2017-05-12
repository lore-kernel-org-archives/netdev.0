From: Johan Hovold <johan@kernel.org>
Subject: [PATCH] net: can: peak: fix product-id endianness in error message
Date: Fri, 12 May 2017 12:09:25 +0200
Message-ID: <20170512100925.1841-1-johan@kernel.org>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to use the USB device product-id stored in host-byte order in
a probe error message.

Also remove a redundant reassignment of the local usb_dev variable which
had already been used to retrieve the product id.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index 57913dbbae0a..1ca76e03e965 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -908,8 +908,6 @@ static int peak_usb_probe(struct usb_interface *intf,
 	const struct peak_usb_adapter *peak_usb_adapter = NULL;
 	int i, err = -ENOMEM;
 
-	usb_dev = interface_to_usbdev(intf);
-
 	/* get corresponding PCAN-USB adapter */
 	for (i = 0; i < ARRAY_SIZE(peak_usb_adapters_list); i++)
 		if (peak_usb_adapters_list[i]->device_id == usb_id_product) {
@@ -920,7 +918,7 @@ static int peak_usb_probe(struct usb_interface *intf,
 	if (!peak_usb_adapter) {
 		/* should never come except device_id bad usage in this file */
 		pr_err("%s: didn't find device id. 0x%x in devices list\n",
-			PCAN_USB_DRIVER_NAME, usb_dev->descriptor.idProduct);
+			PCAN_USB_DRIVER_NAME, usb_id_product);
 		return -ENODEV;
 	}
 
-- 
2.13.0

