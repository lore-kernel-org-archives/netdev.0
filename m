From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 08/11] usbnet: dm9601: apply usbnet_link_change
Date: Thu, 11 Apr 2013 22:40:37 +0800
Message-ID: <1365691240-816-9-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>,
	Peter Korsgaard <jacmet@sunsite.dk>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:64053 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161236Ab3DKOlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:45 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use usbnet_link_change to handle link change centrally.

Cc: Peter Korsgaard <jacmet@sunsite.dk>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/dm9601.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 174e5ec..2dbb946 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -524,12 +524,7 @@ static void dm9601_status(struct usbnet *dev, struct urb *urb)
 
 	link = !!(buf[0] & 0x40);
 	if (netif_carrier_ok(dev->net) != link) {
-		if (link) {
-			netif_carrier_on(dev->net);
-			usbnet_defer_kevent (dev, EVENT_LINK_RESET);
-		}
-		else
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, link, 1);
 		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
-- 
1.7.9.5
