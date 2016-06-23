From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] can: kvaser_usb: Add support for more Kvaser Leaf v2 devices
Date: Thu, 23 Jun 2016 11:22:21 +0200
Message-ID: <1466673741-23115-4-git-send-email-mkl@pengutronix.de>
References: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de, Jimmy Assarsson <jimmyassarsson@gmail.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:54938 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185AbcFWJWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 05:22:30 -0400
In-Reply-To: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jimmy Assarsson <jimmyassarsson@gmail.com>

This patch adds support for Kvaser Leaf Light HS v2 OEM, Mini PCI
Express 2xHS and USBcan Light 2xHS.

Signed-off-by: Jimmy Assarsson <jimmyassarsson@gmail.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/Kconfig      | 2 ++
 drivers/net/can/usb/kvaser_usb.c | 8 +++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/usb/Kconfig b/drivers/net/can/usb/Kconfig
index 2ff0df32b3d1..8483a40e7e9e 100644
--- a/drivers/net/can/usb/Kconfig
+++ b/drivers/net/can/usb/Kconfig
@@ -47,6 +47,8 @@ config CAN_KVASER_USB
 	    - Kvaser USBcan R
 	    - Kvaser Leaf Light v2
 	    - Kvaser Mini PCI Express HS
+	    - Kvaser Mini PCI Express 2xHS
+	    - Kvaser USBcan Light 2xHS
 	    - Kvaser USBcan II HS/HS
 	    - Kvaser USBcan II HS/LS
 	    - Kvaser USBcan Rugged ("USBcan Rev B")
diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index 022bfa13ebfa..6f1f3b675ff5 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -59,11 +59,14 @@
 #define USB_CAN_R_PRODUCT_ID		39
 #define USB_LEAF_LITE_V2_PRODUCT_ID	288
 #define USB_MINI_PCIE_HS_PRODUCT_ID	289
+#define USB_LEAF_LIGHT_HS_V2_OEM_PRODUCT_ID 290
+#define USB_USBCAN_LIGHT_2HS_PRODUCT_ID	291
+#define USB_MINI_PCIE_2HS_PRODUCT_ID	292
 
 static inline bool kvaser_is_leaf(const struct usb_device_id *id)
 {
 	return id->idProduct >= USB_LEAF_DEVEL_PRODUCT_ID &&
-	       id->idProduct <= USB_MINI_PCIE_HS_PRODUCT_ID;
+	       id->idProduct <= USB_MINI_PCIE_2HS_PRODUCT_ID;
 }
 
 /* Kvaser USBCan-II devices */
@@ -537,6 +540,9 @@ static const struct usb_device_id kvaser_usb_table[] = {
 		.driver_info = KVASER_HAS_TXRX_ERRORS },
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LITE_V2_PRODUCT_ID) },
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MINI_PCIE_HS_PRODUCT_ID) },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_LEAF_LIGHT_HS_V2_OEM_PRODUCT_ID) },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN_LIGHT_2HS_PRODUCT_ID) },
+	{ USB_DEVICE(KVASER_VENDOR_ID, USB_MINI_PCIE_2HS_PRODUCT_ID) },
 
 	/* USBCANII family IDs */
 	{ USB_DEVICE(KVASER_VENDOR_ID, USB_USBCAN2_PRODUCT_ID),
-- 
2.8.1
