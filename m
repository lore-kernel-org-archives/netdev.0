From: Oliver Neukum <oneukum@suse.de>
Subject: [PATCH] usbnet: rename work handler
Date: Thu,  9 Apr 2015 10:09:04 +0200
Message-ID: <1428566944-21376-1-git-send-email-oneukum@suse.de>
Cc: Oliver Neukum <oneukum@suse.de>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56218 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893AbbDIIJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 04:09:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"kevent" is an extremely generic name that causes trouble
if debugging for work queues is used. So change it to
something clear.

Signed-off-by: Oliver Neukum <oneukum@suse.de>
---
 drivers/net/usb/usbnet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 777757a..733f4fe 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1072,7 +1072,7 @@ static void __handle_set_rx_mode(struct usbnet *dev)
  * especially now that control transfers can be queued.
  */
 static void
-kevent (struct work_struct *work)
+usbnet_deferred_kevent (struct work_struct *work)
 {
 	struct usbnet		*dev =
 		container_of(work, struct usbnet, kevent);
@@ -1626,7 +1626,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	skb_queue_head_init(&dev->rxq_pause);
 	dev->bh.func = usbnet_bh;
 	dev->bh.data = (unsigned long) dev;
-	INIT_WORK (&dev->kevent, kevent);
+	INIT_WORK (&dev->kevent, usbnet_deferred_kevent);
 	init_usb_anchor(&dev->deferred);
 	dev->delay.function = usbnet_bh;
 	dev->delay.data = (unsigned long) dev;
-- 
2.1.4
