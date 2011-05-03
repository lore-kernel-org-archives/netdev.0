From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] usbnet: Convert dbg to dev_dbg and neatening
Date: Tue,  3 May 2011 11:17:58 -0700
Message-ID: <f86364fbdc335fadad003081d010843579e95765.1304445019.git.joe@perches.com>
References: <cover.1304445019.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1192 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754404Ab1ECSSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 14:18:03 -0400
In-Reply-To: <cover.1304445019.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the more standard logging form.
Add a bit more tidying style.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/usbnet.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 28aecbb..b803085 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -192,8 +192,8 @@ static int init_status(struct usbnet *dev, struct usb_interface *intf)
 		return 0;
 
 	pipe = usb_rcvintpipe(dev->udev,
-			      dev->status->desc.bEndpointAddress
-			      & USB_ENDPOINT_NUMBER_MASK);
+			      (dev->status->desc.bEndpointAddress
+			       & USB_ENDPOINT_NUMBER_MASK));
 	maxp = usb_maxpacket(dev->udev, pipe, 0);
 
 	/* avoid 1 msec chatter:  min 8 msec poll rate */
@@ -1066,7 +1066,8 @@ netdev_tx_t usbnet_start_xmit(struct sk_buff *skb,
 		skb = info->tx_fixup(dev, skb, GFP_ATOMIC);
 		if (!skb) {
 			if (netif_msg_tx_err(dev)) {
-				netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
+				netif_dbg(dev, tx_err, dev->net,
+					  "can't tx_fixup skb\n");
 				goto drop;
 			} else {
 				/* cdc_ncm collected packet; waits for more */
@@ -1333,7 +1334,7 @@ usbnet_probe(struct usb_interface *udev, const struct usb_device_id *prod)
 	/* set up our own records */
 	net = alloc_etherdev(sizeof(*dev));
 	if (!net) {
-		dbg("can't kmalloc dev");
+		dev_dbg(&udev->dev, "can't alloc_etherdev\n");
 		goto out;
 	}
 
@@ -1345,8 +1346,9 @@ usbnet_probe(struct usb_interface *udev, const struct usb_device_id *prod)
 	dev->intf = udev;
 	dev->driver_info = info;
 	dev->driver_name = name;
-	dev->msg_enable = netif_msg_init(msg_level, NETIF_MSG_DRV
-					 | NETIF_MSG_PROBE | NETIF_MSG_LINK);
+	dev->msg_enable = netif_msg_init(msg_level, (NETIF_MSG_DRV |
+						     NETIF_MSG_PROBE |
+						     NETIF_MSG_LINK));
 	skb_queue_head_init(&dev->rxq);
 	skb_queue_head_init(&dev->txq);
 	skb_queue_head_init(&dev->done);
@@ -1466,8 +1468,7 @@ EXPORT_SYMBOL_GPL(usbnet_probe);
 
 /*-------------------------------------------------------------------------*/
 
-/*
- * suspend the whole driver as soon as the first interface is suspended
+/* suspend the whole driver as soon as the first interface is suspended
  * resume only when the last interface is resumed
  */
 
@@ -1485,16 +1486,14 @@ int usbnet_suspend(struct usb_interface *intf, pm_message_t message)
 			set_bit(EVENT_DEV_ASLEEP, &dev->flags);
 			spin_unlock_irq(&dev->txq.lock);
 		}
-		/*
-		 * accelerate emptying of the rx and queues, to avoid
+		/* accelerate emptying of the rx and queues, to avoid
 		 * having everything error out.
 		 */
 		netif_device_detach(dev->net);
 		usbnet_terminate_urbs(dev);
 		usb_kill_urb(dev->interrupt);
 
-		/*
-		 * reattach so runtime management can use and
+		/* reattach so runtime management can use and
 		 * wake the device
 		 */
 		netif_device_attach(dev->net);
-- 
1.7.5.rc3.dirty

