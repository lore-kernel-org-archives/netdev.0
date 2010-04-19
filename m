From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCHv2 3/7] X25: Use identifiers for x25 async device to x25
 interface
Date: Tue, 20 Apr 2010 09:29:47 +1000
Message-ID: <1271719787.2802.84.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:64699 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140Ab0DSX3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 19:29:52 -0400
Received: by mail-pv0-f174.google.com with SMTP id 18so3526406pva.19
        for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 16:29:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change magic numbers to identifiers for X25 interface.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 drivers/net/wan/x25_asy.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 80d5c58..166e77d 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -29,12 +29,12 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
-#include <linux/x25.h>
 #include <linux/lapb.h>
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/compat.h>
 #include <linux/slab.h>
+#include <net/x25device.h>
 #include "x25_asy.h"
 
 #include <net/x25device.h>
@@ -315,15 +315,15 @@ static netdev_tx_t x25_asy_xmit(struct sk_buff *skb,
 	}
 
 	switch (skb->data[0]) {
-	case 0x00:
+	case X25_IFACE_DATA:
 		break;
-	case 0x01: /* Connection request .. do nothing */
+	case X25_IFACE_CONNECT: /* Connection request .. do nothing */
 		err = lapb_connect_request(dev);
 		if (err != LAPB_OK)
 			printk(KERN_ERR "x25_asy: lapb_connect_request error - %d\n", err);
 		kfree_skb(skb);
 		return NETDEV_TX_OK;
-	case 0x02: /* Disconnect request .. do nothing - hang up ?? */
+	case X25_IFACE_DISCONNECT: /* do nothing - hang up ?? */
 		err = lapb_disconnect_request(dev);
 		if (err != LAPB_OK)
 			printk(KERN_ERR "x25_asy: lapb_disconnect_request error - %d\n", err);
@@ -411,7 +411,7 @@ static void x25_asy_connected(struct net_device *dev, int reason)
 	}
 
 	ptr  = skb_put(skb, 1);
-	*ptr = 0x01;
+	*ptr = X25_IFACE_CONNECT;
 
 	skb->protocol = x25_type_trans(skb, sl->dev);
 	netif_rx(skb);
@@ -430,7 +430,7 @@ static void x25_asy_disconnected(struct net_device *dev, int reason)
 	}
 
 	ptr  = skb_put(skb, 1);
-	*ptr = 0x02;
+	*ptr = X25_IFACE_DISCONNECT;
 
 	skb->protocol = x25_type_trans(skb, sl->dev);
 	netif_rx(skb);
-- 
1.5.6.5



