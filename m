From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/2] r8152: redefine REALTEK_USB_DEVICE
Date: Mon, 24 Nov 2014 11:09:48 +0800
Message-ID: <1394712342-15778-102-Taiwan-albertk@realtek.com>
References: <1394712342-15778-101-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-101-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Redefine REALTEK_USB_DEVICE for the desired USB interface for probe().
There are three USB interfaces for the device. USB_CLASS_COMM and
USB_CLASS_CDC_DATA are for ECM mode (config #2). USB_CLASS_VENDOR_SPEC
is for the vendor mode (config #1). However, we are not interesting
in USB_CLASS_CDC_DATA for probe(), so redefine REALTEK_USB_DEVICE
to ignore the USB interface class of USB_CLASS_CDC_DATA.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4a9ece0..2d1c77e 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -24,6 +24,7 @@
 #include <net/ip6_checksum.h>
 #include <uapi/linux/mdio.h>
 #include <linux/mdio.h>
+#include <linux/usb/cdc.h>
 
 /* Version Information */
 #define DRIVER_VERSION "v1.07.0 (2014/10/09)"
@@ -466,9 +467,6 @@ enum rtl8152_flags {
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
 
-#define REALTEK_USB_DEVICE(vend, prod)	\
-	USB_DEVICE_INTERFACE_CLASS(vend, prod, USB_CLASS_VENDOR_SPEC)
-
 struct tally_counter {
 	__le64	tx_packets;
 	__le64	rx_packets;
@@ -3915,11 +3913,27 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 	}
 }
 
+#define REALTEK_USB_DEVICE(vend, prod)	\
+	.match_flags = USB_DEVICE_ID_MATCH_DEVICE | \
+		       USB_DEVICE_ID_MATCH_INT_CLASS, \
+	.idVendor = (vend), \
+	.idProduct = (prod), \
+	.bInterfaceClass = USB_CLASS_VENDOR_SPEC \
+}, \
+{ \
+	.match_flags = USB_DEVICE_ID_MATCH_INT_INFO | \
+		       USB_DEVICE_ID_MATCH_DEVICE, \
+	.idVendor = (vend), \
+	.idProduct = (prod), \
+	.bInterfaceClass = USB_CLASS_COMM, \
+	.bInterfaceSubClass = USB_CDC_SUBCLASS_ETHERNET, \
+	.bInterfaceProtocol = USB_CDC_PROTO_NONE
+
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
-	{USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
-	{USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
-	{USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8152)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
+	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
 	{}
 };
 
-- 
1.9.3
