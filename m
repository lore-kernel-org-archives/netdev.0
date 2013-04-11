From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 02/11] usbnet: mcs7830: don't reset link
Date: Thu, 11 Apr 2013 22:40:31 +0800
Message-ID: <1365691240-816-3-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:41191 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932712Ab3DKOlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:07 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver doesn't implement link_reset() callback, so it needn't
to send link reset event.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/mcs7830.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 3f3f566..e1c00e9 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -576,10 +576,9 @@ static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 		 */
 		if (data->link_counter > 20) {
 			data->link_counter = 0;
-			if (link) {
+			if (link)
 				netif_carrier_on(dev->net);
-				usbnet_defer_kevent(dev, EVENT_LINK_RESET);
-			} else
+			else
 				netif_carrier_off(dev->net);
 			netdev_dbg(dev->net, "Link Status is: %d\n", link);
 		}
-- 
1.7.9.5
