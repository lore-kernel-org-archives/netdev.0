From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 03/11] usbnet: mcs7830: apply usbnet_link_change
Date: Thu, 11 Apr 2013 22:40:32 +0800
Message-ID: <1365691240-816-4-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:38244 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932712Ab3DKOlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:14 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses the introduced usbnet_link_change() to handle
link change.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/mcs7830.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index e1c00e9..03832d3 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -576,10 +576,7 @@ static void mcs7830_status(struct usbnet *dev, struct urb *urb)
 		 */
 		if (data->link_counter > 20) {
 			data->link_counter = 0;
-			if (link)
-				netif_carrier_on(dev->net);
-			else
-				netif_carrier_off(dev->net);
+			usbnet_link_change(dev, link, 0);
 			netdev_dbg(dev->net, "Link Status is: %d\n", link);
 		}
 	} else
-- 
1.7.9.5
