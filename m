From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/6] can: peak_usb: fix product-id endianness in error message
Date: Fri,  9 Jun 2017 14:55:10 +0200
Message-ID: <20170609125513.24436-4-mkl@pengutronix.de>
References: <20170609125513.24436-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Johan Hovold <johan@kernel.org>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48155 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751623AbdFIMzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 08:55:21 -0400
In-Reply-To: <20170609125513.24436-1-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johan Hovold <johan@kernel.org>

Make sure to use the USB device product-id stored in host-byte order in
a probe error message.

Also remove a redundant reassignment of the local usb_dev variable which
had already been used to retrieve the product id.

Signed-off-by: Johan Hovold <johan@kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
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
2.11.0
