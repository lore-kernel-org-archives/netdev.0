From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw-d80211: changed GFP_NOFS to GFP_KERNEL
Date: Sun, 18 Feb 2007 01:34:43 +0000 (GMT)
Message-ID: <20070218013443.785267B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:6935 "EHLO
	mtaout03-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030283AbXBRBej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Feb 2007 20:34:39 -0500
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Kunitz <kune@deine-taler.de>

Michael Buesch commented that GFP_NOFS should not be used in a
network driver. This patch implements it for zd1211rw-d80211.

Signed-off-by: Ulrich Kunitz <kune@deine-taler.de>
Signed-off-by: Daniel Drake <dsd@gentoo.org>
---
 drivers/net/wireless/d80211/zd1211rw/zd_chip.c |    4 ++--
 drivers/net/wireless/d80211/zd1211rw/zd_usb.c  |   20 ++++++++++----------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_chip.c b/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
index daec7b6..93e3ed1 100644
--- a/drivers/net/wireless/zd1211rw/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/drivers/net/wireless/d80211/zd1211rw/zd_chip.c
@@ -102,7 +102,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
 	/* Allocate a single memory block for values and addresses. */
 	count16 = 2*count;
 	a16 = (zd_addr_t *)kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
-		                   GFP_NOFS);
+		                   GFP_KERNEL);
 	if (!a16) {
 		dev_dbg_f(zd_chip_dev(chip),
 			  "error ENOMEM in allocation of a16\n");
@@ -151,7 +151,7 @@ int _zd_iowrite32v_locked(struct zd_chip *chip, const struct zd_ioreq32 *ioreqs,
 
 	/* Allocate a single memory block for values and addresses. */
 	count16 = 2*count;
-	ioreqs16 = kmalloc(count16 * sizeof(struct zd_ioreq16), GFP_NOFS);
+	ioreqs16 = kmalloc(count16 * sizeof(struct zd_ioreq16), GFP_KERNEL);
 	if (!ioreqs16) {
 		r = -ENOMEM;
 		dev_dbg_f(zd_chip_dev(chip),
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c b/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
index 0500bc3..b6aa4d2 100644
--- a/drivers/net/wireless/zd1211rw/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
@@ -490,7 +490,7 @@ int zd_usb_enable_int(struct zd_usb *usb)
 
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
-	urb = usb_alloc_urb(0, GFP_NOFS);
+	urb = usb_alloc_urb(0, GFP_KERNEL);
 	if (!urb) {
 		r = -ENOMEM;
 		goto out;
@@ -508,7 +508,7 @@ int zd_usb_enable_int(struct zd_usb *usb)
 
 	/* TODO: make it a DMA buffer */
 	r = -ENOMEM;
-	transfer_buffer = kmalloc(USB_MAX_EP_INT_BUFFER, GFP_NOFS);
+	transfer_buffer = kmalloc(USB_MAX_EP_INT_BUFFER, GFP_KERNEL);
 	if (!transfer_buffer) {
 		dev_dbg_f(zd_usb_dev(usb),
 			"couldn't allocate transfer_buffer\n");
@@ -522,7 +522,7 @@ int zd_usb_enable_int(struct zd_usb *usb)
 			 intr->interval);
 
 	dev_dbg_f(zd_usb_dev(usb), "submit urb %p\n", intr->urb);
-	r = usb_submit_urb(urb, GFP_NOFS);
+	r = usb_submit_urb(urb, GFP_KERNEL);
 	if (r) {
 		dev_dbg_f(zd_usb_dev(usb),
 			 "Couldn't submit urb. Error number %d\n", r);
@@ -667,10 +667,10 @@ static struct urb *alloc_urb(struct zd_usb *usb)
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
@@ -703,7 +703,7 @@ int zd_usb_enable_rx(struct zd_usb *usb)
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
 	r = -ENOMEM;
-	urbs = kcalloc(URBS_COUNT, sizeof(struct urb *), GFP_NOFS);
+	urbs = kcalloc(URBS_COUNT, sizeof(struct urb *), GFP_KERNEL);
 	if (!urbs)
 		goto error;
 	for (i = 0; i < URBS_COUNT; i++) {
@@ -724,7 +724,7 @@ int zd_usb_enable_rx(struct zd_usb *usb)
 	spin_unlock_irq(&rx->lock);
 
 	for (i = 0; i < URBS_COUNT; i++) {
-		r = usb_submit_urb(urbs[i], GFP_NOFS);
+		r = usb_submit_urb(urbs[i], GFP_KERNEL);
 		if (r)
 			goto error_submit;
 	}
@@ -1247,7 +1247,7 @@ int zd_usb_ioread16v(struct zd_usb *usb, u16 *values,
 	}
 
 	req_len = sizeof(struct usb_req_read_regs) + count * sizeof(__le16);
-	req = kmalloc(req_len, GFP_NOFS);
+	req = kmalloc(req_len, GFP_KERNEL);
 	if (!req)
 		return -ENOMEM;
 	req->id = cpu_to_le16(USB_REQ_READ_REGS);
@@ -1310,7 +1310,7 @@ int zd_usb_iowrite16v(struct zd_usb *usb, const struct zd_ioreq16 *ioreqs,
 
 	req_len = sizeof(struct usb_req_write_regs) +
 		  count * sizeof(struct reg_data);
-	req = kmalloc(req_len, GFP_NOFS);
+	req = kmalloc(req_len, GFP_KERNEL);
 	if (!req)
 		return -ENOMEM;
 
@@ -1390,7 +1390,7 @@ int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits)
 	bit_value_template &= ~(RF_IF_LE|RF_CLK|RF_DATA);
 
 	req_len = sizeof(struct usb_req_rfwrite) + bits * sizeof(__le16);
-	req = kmalloc(req_len, GFP_NOFS);
+	req = kmalloc(req_len, GFP_KERNEL);
 	if (!req)
 		return -ENOMEM;
 
-- 
1.5.0

