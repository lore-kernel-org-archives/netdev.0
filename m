From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] usbnet: avoid integer overflow in start_xmit
Date: Wed,  6 May 2015 15:09:40 +0200
Message-ID: <1430917780-12431-1-git-send-email-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: oneukum@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:33376 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbbEFNPz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 09:15:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

transfer_buffer_length is of type u32. It's therefore wrong to assign it
to a signed integer. This patch avoids the overflow.

It's worth noting that entry->length here is a long; perhaps it would be
beneficial at somepoint to change this to be unsigned as well, if
nothing else relies on its signedness for error conditions or the like.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 drivers/net/usb/usbnet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 733f4fe..3c86b10 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1285,7 +1285,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 				     struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
-	int			length;
+	unsigned int			length;
 	struct urb		*urb = NULL;
 	struct skb_data		*entry;
 	struct driver_info	*info = dev->driver_info;
@@ -1413,7 +1413,7 @@ not_drop:
 		}
 	} else
 		netif_dbg(dev, tx_queued, dev->net,
-			  "> tx, len %d, type 0x%x\n", length, skb->protocol);
+			  "> tx, len %u, type 0x%x\n", length, skb->protocol);
 #ifdef CONFIG_PM
 deferred:
 #endif
-- 
2.3.6
