From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 05/11] usbnet: asix: apply usbnet_link_change
Date: Thu, 11 Apr 2013 22:40:34 +0800
Message-ID: <1365691240-816-6-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:43359 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932712Ab3DKOl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:26 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use usbnet_link_change to handle link change centrally.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/asix_devices.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 7097534..ad5d1e4 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -55,11 +55,7 @@ static void asix_status(struct usbnet *dev, struct urb *urb)
 	event = urb->transfer_buffer;
 	link = event->link & 0x01;
 	if (netif_carrier_ok(dev->net) != link) {
-		if (link) {
-			netif_carrier_on(dev->net);
-			usbnet_defer_kevent (dev, EVENT_LINK_RESET );
-		} else
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, link, 1);
 		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
-- 
1.7.9.5
