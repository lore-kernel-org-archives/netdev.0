From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 06/11] usbnet: ax88179_1781: apply usbnet_link_change
Date: Thu, 11 Apr 2013 22:40:35 +0800
Message-ID: <1365691240-816-7-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:38758 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161236Ab3DKOlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:32 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use usbnet_link_change to handle link change centrally.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/ax88179_178a.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index 71c27d8..bd8758f 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -352,11 +352,7 @@ static void ax88179_status(struct usbnet *dev, struct urb *urb)
 	link = (((__force u32)event->intdata1) & AX_INT_PPLS_LINK) >> 16;
 
 	if (netif_carrier_ok(dev->net) != link) {
-		if (link)
-			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
-		else
-			netif_carrier_off(dev->net);
-
+		usbnet_link_change(dev, link, 1);
 		netdev_info(dev->net, "ax88179 - Link status is: %d\n", link);
 	}
 }
@@ -455,7 +451,7 @@ static int ax88179_resume(struct usb_interface *intf)
 	u16 tmp16;
 	u8 tmp8;
 
-	netif_carrier_off(dev->net);
+	usbnet_link_change(dev, 0, 0);
 
 	/* Power up ethernet PHY */
 	tmp16 = 0;
@@ -1068,7 +1064,7 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* Restart autoneg */
 	mii_nway_restart(&dev->mii);
 
-	netif_carrier_off(dev->net);
+	usbnet_link_change(dev, 0, 0);
 
 	return 0;
 }
@@ -1356,7 +1352,7 @@ static int ax88179_reset(struct usbnet *dev)
 	/* Restart autoneg */
 	mii_nway_restart(&dev->mii);
 
-	netif_carrier_off(dev->net);
+	usbnet_link_change(dev, 0, 0);
 
 	return 0;
 }
-- 
1.7.9.5
