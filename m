From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 12/33] arcnet: Move EXPORT_SYMBOL after declarations
Date: Tue, 22 Sep 2015 11:01:53 +0200
Message-ID: <1442912534-10821-13-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46933 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516AbbIVJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:41 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use the normal kernel style for EXPORT_SYMBOL.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcnet.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index 2be8ab6..a9535ec 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -68,8 +68,17 @@ static void arcnet_rx(struct net_device *dev, int bufnum);
  * arc_proto_default instead.  It also must not be NULL; if you would like
  * to set it to NULL, set it to &arc_proto_null instead.
  */
-struct ArcProto *arc_proto_map[256], *arc_proto_default,
-	*arc_bcast_proto, *arc_raw_proto;
+struct ArcProto *arc_proto_map[256];
+EXPORT_SYMBOL(arc_proto_map);
+
+struct ArcProto *arc_proto_default;
+EXPORT_SYMBOL(arc_proto_default);
+
+struct ArcProto *arc_bcast_proto;
+EXPORT_SYMBOL(arc_bcast_proto);
+
+struct ArcProto *arc_raw_proto;
+EXPORT_SYMBOL(arc_raw_proto);
 
 static struct ArcProto arc_proto_null = {
 	.suffix		= '?',
@@ -84,19 +93,7 @@ static struct ArcProto arc_proto_null = {
 
 /* Exported function prototypes */
 int arcnet_debug = ARCNET_DEBUG;
-
-EXPORT_SYMBOL(arc_proto_map);
-EXPORT_SYMBOL(arc_proto_default);
-EXPORT_SYMBOL(arc_bcast_proto);
-EXPORT_SYMBOL(arc_raw_proto);
-EXPORT_SYMBOL(arcnet_unregister_proto);
 EXPORT_SYMBOL(arcnet_debug);
-EXPORT_SYMBOL(alloc_arcdev);
-EXPORT_SYMBOL(arcnet_interrupt);
-EXPORT_SYMBOL(arcnet_open);
-EXPORT_SYMBOL(arcnet_close);
-EXPORT_SYMBOL(arcnet_send_packet);
-EXPORT_SYMBOL(arcnet_timeout);
 
 /* Internal function prototypes */
 static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
@@ -151,7 +148,6 @@ void arcnet_dump_skb(struct net_device *dev,
 	print_hex_dump(KERN_DEBUG, hdr, DUMP_PREFIX_OFFSET,
 		       16, 1, skb->data, skb->len, true);
 }
-
 EXPORT_SYMBOL(arcnet_dump_skb);
 #endif
 
@@ -211,6 +207,7 @@ void arcnet_unregister_proto(struct ArcProto *proto)
 			arc_proto_map[count] = arc_proto_default;
 	}
 }
+EXPORT_SYMBOL(arcnet_unregister_proto);
 
 /* Add a buffer to the queue.  Only the interrupt handler is allowed to do
  * this, unless interrupts are disabled.
@@ -330,6 +327,7 @@ struct net_device *alloc_arcdev(const char *name)
 
 	return dev;
 }
+EXPORT_SYMBOL(alloc_arcdev);
 
 /* Open/initialize the board.  This is called sometime after booting when
  * the 'ifconfig' program is run.
@@ -431,6 +429,7 @@ int arcnet_open(struct net_device *dev)
 	module_put(lp->hw.owner);
 	return error;
 }
+EXPORT_SYMBOL(arcnet_open);
 
 /* The inverse routine to arcnet_open - shuts down the card. */
 int arcnet_close(struct net_device *dev)
@@ -450,6 +449,7 @@ int arcnet_close(struct net_device *dev)
 	module_put(lp->hw.owner);
 	return 0;
 }
+EXPORT_SYMBOL(arcnet_close);
 
 static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 			 unsigned short type, const void *daddr,
@@ -592,6 +592,7 @@ netdev_tx_t arcnet_send_packet(struct sk_buff *skb,
 
 	return retval;		/* no need to try again */
 }
+EXPORT_SYMBOL(arcnet_send_packet);
 
 /* Actually start transmitting a packet that was loaded into a buffer
  * by prepare_tx.  This should _only_ be called by the interrupt handler.
@@ -659,6 +660,7 @@ void arcnet_timeout(struct net_device *dev)
 	if (lp->cur_tx == -1)
 		netif_wake_queue(dev);
 }
+EXPORT_SYMBOL(arcnet_timeout);
 
 /* The typical workload of the driver: Handle the network interface
  * interrupts. Establish which device needs attention, and call the correct
@@ -902,6 +904,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	spin_unlock(&lp->lock);
 	return retval;
 }
+EXPORT_SYMBOL(arcnet_interrupt);
 
 /* This is a generic packet receiver that calls arcnet??_rx depending on the
  * protocol ID found.
-- 
2.5.1
