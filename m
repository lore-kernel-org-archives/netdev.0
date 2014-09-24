From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: [PATCH] usb: gadget: f_rndis: fix usb_interface_descriptor for rndis
Date: Wed, 24 Sep 2014 08:48:59 +0200
Message-ID: <1411541339-32400-1-git-send-email-hs@denx.de>
Cc: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>, Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>,
	Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Macpaul Lin <macpaul-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

use the values for RNDIS over Ethernet as defined in
http://www.usb.org/developers/defined_class
(search for RDNIS):

- baseclass: 0xef (miscellaneous)
- subclass: 0x04
- protocol: 0x01

with this setings the file in Documentation/usb/linux.inf is
obsolete.

Signed-off-by: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>

---

Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Cc: Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>
Cc: Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Cc: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: Macpaul Lin <macpaul-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Tested with the "USB Compliance test suite which runs Windows", see:
http://www.usb.org/developers/tools/usb20_tools/#usb20cv

 drivers/net/usb/cdc_ether.c           | 6 +++---
 drivers/usb/core/generic.c            | 6 +++---
 drivers/usb/gadget/function/f_rndis.c | 6 +++---
 include/uapi/linux/usb/cdc.h          | 3 +++
 4 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 2a32d91..9c216c2 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -35,9 +35,9 @@
 
 static int is_rndis(struct usb_interface_descriptor *desc)
 {
-	return (desc->bInterfaceClass == USB_CLASS_COMM &&
-		desc->bInterfaceSubClass == 2 &&
-		desc->bInterfaceProtocol == 0xff);
+	return (desc->bInterfaceClass == USB_CLASS_MISC &&
+		desc->bInterfaceSubClass == USB_CDC_SUBCLASS_RNDIS &&
+		desc->bInterfaceProtocol == USB_CDC_RNDIS_PROTO_ETH);
 }
 
 static int is_activesync(struct usb_interface_descriptor *desc)
diff --git a/drivers/usb/core/generic.c b/drivers/usb/core/generic.c
index 358ca8d..a2a4e05 100644
--- a/drivers/usb/core/generic.c
+++ b/drivers/usb/core/generic.c
@@ -28,9 +28,9 @@ static inline const char *plural(int n)
 
 static int is_rndis(struct usb_interface_descriptor *desc)
 {
-	return desc->bInterfaceClass == USB_CLASS_COMM
-		&& desc->bInterfaceSubClass == 2
-		&& desc->bInterfaceProtocol == 0xff;
+	return desc->bInterfaceClass == USB_CLASS_MISC
+		&& desc->bInterfaceSubClass == USB_CDC_SUBCLASS_RNDIS
+		&& desc->bInterfaceProtocol == USB_CDC_RNDIS_PROTO_ETH;
 }
 
 static int is_activesync(struct usb_interface_descriptor *desc)
diff --git a/drivers/usb/gadget/function/f_rndis.c b/drivers/usb/gadget/function/f_rndis.c
index ddb09dc..cc06046 100644
--- a/drivers/usb/gadget/function/f_rndis.c
+++ b/drivers/usb/gadget/function/f_rndis.c
@@ -117,9 +117,9 @@ static struct usb_interface_descriptor rndis_control_intf = {
 	/* .bInterfaceNumber = DYNAMIC */
 	/* status endpoint is optional; this could be patched later */
 	.bNumEndpoints =	1,
-	.bInterfaceClass =	USB_CLASS_COMM,
-	.bInterfaceSubClass =   USB_CDC_SUBCLASS_ACM,
-	.bInterfaceProtocol =   USB_CDC_ACM_PROTO_VENDOR,
+	.bInterfaceClass =	USB_CLASS_MISC,
+	.bInterfaceSubClass =   USB_CDC_SUBCLASS_RNDIS,
+	.bInterfaceProtocol =   USB_CDC_RNDIS_PROTO_ETH,
 	/* .iInterface = DYNAMIC */
 };
 
diff --git a/include/uapi/linux/usb/cdc.h b/include/uapi/linux/usb/cdc.h
index b6a9cdd..8e8fc85 100644
--- a/include/uapi/linux/usb/cdc.h
+++ b/include/uapi/linux/usb/cdc.h
@@ -12,6 +12,7 @@
 #include <linux/types.h>
 
 #define USB_CDC_SUBCLASS_ACM			0x02
+#define USB_CDC_SUBCLASS_RNDIS			0x04
 #define USB_CDC_SUBCLASS_ETHERNET		0x06
 #define USB_CDC_SUBCLASS_WHCM			0x08
 #define USB_CDC_SUBCLASS_DMM			0x09
@@ -31,6 +32,8 @@
 #define USB_CDC_ACM_PROTO_AT_CDMA		6
 #define USB_CDC_ACM_PROTO_VENDOR		0xff
 
+#define USB_CDC_RNDIS_PROTO_ETH			1
+
 #define USB_CDC_PROTO_EEM			7
 
 #define USB_CDC_NCM_PROTO_NTB			1
-- 
1.8.3.1
