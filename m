From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 04/11] usbnet: cdc_ncm: apply usbnet_link_change
Date: Thu, 11 Apr 2013 22:40:33 +0800
Message-ID: <1365691240-816-5-git-send-email-ming.lei@canonical.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:44223 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932712Ab3DKOlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 10:41:19 -0400
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the introduced usbnet_link_change to handle link change.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/cdc_ncm.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 67012cb..43afde8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -610,7 +610,7 @@ static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf)
 	 * (carrier is OFF) during attach, so the IP network stack does not
 	 * start IPv6 negotiation and more.
 	 */
-	netif_carrier_off(dev->net);
+	usbnet_link_change(dev, 0, 0);
 	return ret;
 }
 
@@ -1106,12 +1106,9 @@ static void cdc_ncm_status(struct usbnet *dev, struct urb *urb)
 			" %sconnected\n",
 			ctx->netdev->name, ctx->connected ? "" : "dis");
 
-		if (ctx->connected)
-			netif_carrier_on(dev->net);
-		else {
-			netif_carrier_off(dev->net);
+		usbnet_link_change(dev, ctx->connected, 0);
+		if (!ctx->connected)
 			ctx->tx_speed = ctx->rx_speed = 0;
-		}
 		break;
 
 	case USB_CDC_NOTIFY_SPEED_CHANGE:
-- 
1.7.9.5
