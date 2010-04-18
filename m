From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 4/6] X25: Use identifiers for lapbether device to x25
 interface
Date: Sun, 18 Apr 2010 19:53:19 +1000
Message-ID: <1271584399.6280.432.camel@ibex>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:37498 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756220Ab0DRJxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Apr 2010 05:53:23 -0400
Received: by mail-pz0-f204.google.com with SMTP id 42so2815000pzk.4
        for <netdev@vger.kernel.org>; Sun, 18 Apr 2010 02:53:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Change magic numbers to identifiers for X25 interface.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 drivers/net/wan/lapbether.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index 98e2f99..4d4dc38 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -139,7 +139,7 @@ static int lapbeth_data_indication(struct net_device *dev, struct sk_buff *skb)
 		return NET_RX_DROP;
 
 	ptr  = skb->data;
-	*ptr = 0x00;
+	*ptr = X25_IFACE_DATA;
 
 	skb->protocol = x25_type_trans(skb, dev);
 	return netif_rx(skb);
@@ -161,14 +161,14 @@ static netdev_tx_t lapbeth_xmit(struct sk_buff *skb,
 		goto drop;
 
 	switch (skb->data[0]) {
-	case 0x00:
+	case X25_IFACE_DATA:
 		break;
-	case 0x01:
+	case X25_IFACE_CONNECT:
 		if ((err = lapb_connect_request(dev)) != LAPB_OK)
 			printk(KERN_ERR "lapbeth: lapb_connect_request "
 			       "error: %d\n", err);
 		goto drop;
-	case 0x02:
+	case X25_IFACE_DISCONNECT:
 		if ((err = lapb_disconnect_request(dev)) != LAPB_OK)
 			printk(KERN_ERR "lapbeth: lapb_disconnect_request "
 			       "err: %d\n", err);
@@ -225,7 +225,7 @@ static void lapbeth_connected(struct net_device *dev, int reason)
 	}
 
 	ptr  = skb_put(skb, 1);
-	*ptr = 0x01;
+	*ptr = X25_IFACE_CONNECT;
 
 	skb->protocol = x25_type_trans(skb, dev);
 	netif_rx(skb);
@@ -242,7 +242,7 @@ static void lapbeth_disconnected(struct net_device *dev, int reason)
 	}
 
 	ptr  = skb_put(skb, 1);
-	*ptr = 0x02;
+	*ptr = X25_IFACE_DISCONNECT;
 
 	skb->protocol = x25_type_trans(skb, dev);
 	netif_rx(skb);
-- 
1.5.6.5



