From: akpm@linux-foundation.org
Subject: [patch 16/28] drivers/net/irda/irda-usb.c: mostly kmalloc + memset conversion to k[cz]alloc
Date: Fri, 10 Aug 2007 14:12:00 -0700
Message-ID: <200708102112.l7ALC0EM009421@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	m.kozlowski@tuxland.pl, samuel@sortiz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49986 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942178AbXHJVMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/irda/irda-usb.c | 59694 -> 59541 (-153 bytes)
 drivers/net/irda/irda-usb.o | 170588 -> 169256 (-1332 bytes)

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/irda-usb.c |   24 ++++++++++--------------
 1 files changed, 10 insertions(+), 14 deletions(-)

diff -puN drivers/net/irda/irda-usb.c~drivers-net-irda-irda-usbc-mostly-kmalloc-memset-conversion-to-kalloc drivers/net/irda/irda-usb.c
--- a/drivers/net/irda/irda-usb.c~drivers-net-irda-irda-usbc-mostly-kmalloc-memset-conversion-to-kalloc
+++ a/drivers/net/irda/irda-usb.c
@@ -1561,10 +1561,9 @@ static inline struct irda_class_desc *ir
 	struct irda_class_desc *desc;
 	int ret;
 
-	desc = kmalloc(sizeof (*desc), GFP_KERNEL);
-	if (desc == NULL) 
+	desc = kzalloc(sizeof(*desc), GFP_KERNEL);
+	if (!desc)
 		return NULL;
-	memset(desc, 0, sizeof(*desc));
 
 	/* USB-IrDA class spec 1.0:
 	 *	6.1.3: Standard "Get Descriptor" Device Request is not
@@ -1617,7 +1616,7 @@ static int irda_usb_probe(struct usb_int
 {
 	struct net_device *net;
 	struct usb_device *dev = interface_to_usbdev(intf);
-	struct irda_usb_cb *self = NULL;
+	struct irda_usb_cb *self;
 	struct usb_host_interface *interface;
 	struct irda_class_desc *irda_desc;
 	int ret = -ENOMEM;
@@ -1655,7 +1654,7 @@ static int irda_usb_probe(struct usb_int
 		self->header_length = USB_IRDA_HEADER;
 	}
 
-	self->rx_urb = kzalloc(self->max_rx_urb * sizeof(struct urb *),
+	self->rx_urb = kcalloc(self->max_rx_urb, sizeof(struct urb *),
 				GFP_KERNEL);
 
 	for (i = 0; i < self->max_rx_urb; i++) {
@@ -1715,7 +1714,7 @@ static int irda_usb_probe(struct usb_int
 	/* Find IrDA class descriptor */
 	irda_desc = irda_usb_find_class_desc(intf);
 	ret = -ENODEV;
-	if (irda_desc == NULL)
+	if (!irda_desc)
 		goto err_out_3;
 
 	if (self->needspatch) {
@@ -1738,15 +1737,13 @@ static int irda_usb_probe(struct usb_int
 	/* Don't change this buffer size and allocation without doing
 	 * some heavy and complete testing. Don't ask why :-(
 	 * Jean II */
-	self->speed_buff = kmalloc(IRDA_USB_SPEED_MTU, GFP_KERNEL);
-	if (self->speed_buff == NULL) 
+	self->speed_buff = kzalloc(IRDA_USB_SPEED_MTU, GFP_KERNEL);
+	if (!self->speed_buff)
 		goto err_out_3;
 
-	memset(self->speed_buff, 0, IRDA_USB_SPEED_MTU);
-
 	self->tx_buff = kzalloc(IRDA_SKB_MAX_MTU + self->header_length,
 				GFP_KERNEL);
-	if (self->tx_buff == NULL)
+	if (!self->tx_buff)
 		goto err_out_4;
 
 	ret = irda_usb_open(self);
@@ -1767,12 +1764,11 @@ static int irda_usb_probe(struct usb_int
 
 		/* replace IrDA class descriptor with what patched device is now reporting */
 		irda_desc = irda_usb_find_class_desc (self->usbintf);
-		if (irda_desc == NULL) {
+		if (!irda_desc) {
 			ret = -ENODEV;
 			goto err_out_6;
 		}
-		if (self->irda_desc)
-			kfree (self->irda_desc);
+		kfree(self->irda_desc);
 		self->irda_desc = irda_desc;
 		irda_usb_init_qos(self);
 	}
_
