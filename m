From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/3] can: gs_usb: Add Basic support for the bytewerk.org candleLight interface
Date: Mon, 20 Jun 2016 10:00:30 +0200
Message-ID: <1466409630-6268-4-git-send-email-mkl@pengutronix.de>
References: <1466409630-6268-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Maximilian Schneider <max@schneidersoft.net>,
	Hubert Denkmair <hubert@denkmair.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1466409630-6268-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Maximilian Schneider <max@schneidersoft.net>

This patchs adds basic support for the bytewerk.org candleLight interfa=
ce,
a open hardware (CERN OHL) USB CAN adapter.

Signed-off-by: Hubert Denkmair <hubert@denkmair.de>
Signed-off-by: Maximilian Schneider <max@schneidersoft.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/Kconfig  |  3 ++-
 drivers/net/can/usb/gs_usb.c | 14 +++++++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/usb/Kconfig b/drivers/net/can/usb/Kconfig
index bcb272f6c68a..2ff0df32b3d1 100644
--- a/drivers/net/can/usb/Kconfig
+++ b/drivers/net/can/usb/Kconfig
@@ -16,7 +16,8 @@ config CAN_ESD_USB2
 config CAN_GS_USB
 	tristate "Geschwister Schneider UG interfaces"
 	---help---
-	  This driver supports the Geschwister Schneider USB/CAN devices.
+	  This driver supports the Geschwister Schneider and bytewerk.org
+	  candleLight USB CAN interfaces USB/CAN devices
 	  If unsure choose N,
 	  choose Y for built in support,
 	  M to compile as module (module will be named: gs_usb).
diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.=
c
index 1556d4286235..acb0c8490673 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -1,7 +1,9 @@
-/* CAN driver for Geschwister Schneider USB/CAN devices.
+/* CAN driver for Geschwister Schneider USB/CAN devices
+ * and bytewerk.org candleLight USB CAN interfaces.
  *
- * Copyright (C) 2013 Geschwister Schneider Technologie-,
+ * Copyright (C) 2013-2016 Geschwister Schneider Technologie-,
  * Entwicklungs- und Vertriebs UG (Haftungsbeschr=C3=A4nkt).
+ * Copyright (C) 2016 Hubert Denkmair
  *
  * Many thanks to all socketcan devs!
  *
@@ -29,6 +31,9 @@
 #define USB_GSUSB_1_VENDOR_ID      0x1d50
 #define USB_GSUSB_1_PRODUCT_ID     0x606f
=20
+#define USB_CANDLELIGHT_VENDOR_ID  0x1209
+#define USB_CANDLELIGHT_PRODUCT_ID 0x2323
+
 #define GSUSB_ENDPOINT_IN          1
 #define GSUSB_ENDPOINT_OUT         2
=20
@@ -952,6 +957,8 @@ static void gs_usb_disconnect(struct usb_interface =
*intf)
 static const struct usb_device_id gs_usb_table[] =3D {
 	{ USB_DEVICE_INTERFACE_NUMBER(USB_GSUSB_1_VENDOR_ID,
 				      USB_GSUSB_1_PRODUCT_ID, 0) },
+	{ USB_DEVICE_INTERFACE_NUMBER(USB_CANDLELIGHT_VENDOR_ID,
+				      USB_CANDLELIGHT_PRODUCT_ID, 0) },
 	{} /* Terminating entry */
 };
=20
@@ -969,5 +976,6 @@ module_usb_driver(gs_usb_driver);
 MODULE_AUTHOR("Maximilian Schneider <mws@schneidersoft.net>");
 MODULE_DESCRIPTION(
 "Socket CAN device driver for Geschwister Schneider Technologie-, "
-"Entwicklungs- und Vertriebs UG. USB2.0 to CAN interfaces.");
+"Entwicklungs- und Vertriebs UG. USB2.0 to CAN interfaces\n"
+"and bytewerk.org candleLight USB CAN interfaces.");
 MODULE_LICENSE("GPL v2");
--=20
2.8.1

