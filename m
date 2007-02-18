From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw: changed GFP_NOFS to GFP_KERNEL
Date: Sun, 18 Feb 2007 20:28:23 +0000 (GMT)
Message-ID: <20070218202823.9C4A07B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>

Michael Buesch commented that GFP_NOFS should not be used in a
network driver. This patch implements it for zd1211rw-d80211.

Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 zd_chip.c |    4 ++--
 zd_usb.c  |   20 ++++++++++----------
 2 files changed, 12 insertions(+), 12 deletions(-)

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -114,7 +114,7 @@ int zd_ioread32v_locked(struct zd_chip *
 	/* Allocate a single memory block for values and addresses. */
 	count16 = 2*count;
 	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
-		                   GFP_NOFS);
+		                   GFP_KERNEL);
 	if (!a16) {
 		dev_dbg_f(zd_chip_dev(chip),
 			  "error ENOMEM in allocation of a16\n");
@@ -163,7 +163,7 @@ int _zd_iowrite32v_locked(struct zd_chip
 
 	/* Allocate a single memory block for values and addresses. */
 	count16 = 2*count;
-	ioreqs16 = kmalloc(count16 * sizeof(struct zd_ioreq16), GFP_NOFS);
+	ioreqs16 = kmalloc(count16 * sizeof(struct zd_ioreq16), GFP_KERNEL);
 	if (!ioreqs16) {
 		r = -ENOMEM;
 		dev_dbg_f(zd_chip_dev(chip),
Index: linux/drivers/net/wireless/zd1211rw/zd_usb.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_usb.c
+++ linux/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -412,7 +412,7 @@ int zd_usb_enable_int(struct zd_usb *usb
 
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
-	urb = usb_alloc_urb(0, GFP_NOFS);
+	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb) {
 		r = -ENOMEM;
 		goto out;
@@ -430,7 +430,7 @@ int zd_usb_enable_int(struct zd_usb *usb
 
 	/* TODO: make it a DMA buffer */
 	r = -ENOMEM;
-	transfer_buffer = kmalloc(USB_MAX_EP_INT_BUFFER, GFP_NOFS);
+	transfer_buffer = kmalloc(USB_MAX_EP_INT_BUFFER, GFP_KERNEL);
 	if (!transfer_buffer) {
 		dev_dbg_f(zd_usb_dev(usb),
 			"couldn't allocate transfer_buffer\n");
@@ -444,7 +444,7 @@ int zd_usb_enable_int(struct zd_usb *usb
 			 intr->interval);
 
 	dev_dbg_f(zd_usb_dev(usb), "submit urb %p\n", intr->urb);
-	r = usb_submit_urb(urb, GFP_NOFS);
+	r = usb_submit_urb(urb, GFP_KERNEL);
 	if (r) {
 		dev_dbg_f(zd_usb_dev(usb),
 			 "Couldn't submit urb. Error number %d\n", r);
@@ -593,10 +593,10 @@ static struct urb *alloc_urb(struct zd_u
 	struct urb *urb;
 	void *buffer;
 
-	urb = usb_alloc_urb(0, GFP_NOFS);
+	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb)
 		return NULL;
-	buffer = usb_buffer_alloc(udev, USB_MAX_RX_SIZE, GFP_NOFS,
+	buffer = usb_buffer_alloc(udev, USB_MAX_RX_SIZE, GFP_KERNEL,
 		                  &urb->transfer_dma);
 	if (!buffer) {
 		usb_free_urb(urb);
@@ -629,7 +629,7 @@ int zd_usb_enable_rx(struct zd_usb *usb)
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
 	r = -ENOMEM;
-	urbs = kcalloc(URBS_COUNT, sizeof(struct urb *), GFP_NOFS);
+	urbs = kcalloc(URBS_COUNT, sizeof(struct urb *), GFP_KERNEL);
 	if (!urbs)
 		goto error;
 	for (i = 0; i < URBS_COUNT; i++) {
@@ -650,7 +650,7 @@ int zd_usb_enable_rx(struct zd_usb *usb)
 	spin_unlock_irq(&rx->lock);
 
 	for (i = 0; i < URBS_COUNT; i++) {
-		r = usb_submit_urb(urbs[i], GFP_NOFS);
+		r = usb_submit_urb(urbs[i], GFP_KERNEL);
 		if (r)
 			goto error_submit;
 	}
@@ -1156,7 +1156,7 @@ int zd_usb_ioread16v(struct zd_usb *usb,
 	}
 
 	req_len = sizeof(struct usb_req_read_regs) + count * sizeof(__le16);
-	req = kmalloc(req_len, GFP_NOFS);
+	req = kmalloc(req_len, GFP_KERNEL);
 	if (!req)
 		return -ENOMEM;
 	req->id = cpu_to_le16(USB_REQ_READ_REGS);
@@ -1219,7 +1219,7 @@ int zd_usb_iowrite16v(struct zd_usb *usb
 
 	req_len = sizeof(struct usb_req_write_regs) +
 		  count * sizeof(struct reg_data);
-	req = kmalloc(req_len, GFP_NOFS);
+	req = kmalloc(req_len, GFP_KERNEL);
 	if (!req)
 		return -ENOMEM;
 
@@ -1299,7 +1299,7 @@ int zd_usb_rfwrite(struct zd_usb *usb, u
 	bit_value_template &= ~(RF_IF_LE|RF_CLK|RF_DATA);
 
 	req_len = sizeof(struct usb_req_rfwrite) + bits * sizeof(__le16);
-	req = kmalloc(req_len, GFP_NOFS);
+	req = kmalloc(req_len, GFP_KERNEL);
 	if (!req)
 		return -ENOMEM;
 
