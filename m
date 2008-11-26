From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 11/14] apne: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:30 -0800
Message-ID: <20081126011546.032495820@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55264 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbYKZBSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:54 -0500
Content-Disposition: inline; filename=apne-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yet another driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/apne.c	2008-11-25 14:33:02.000000000 -0800
+++ b/drivers/net/apne.c	2008-11-25 14:34:43.000000000 -0800
@@ -78,9 +78,6 @@
 struct net_device * __init apne_probe(int unit);
 static int apne_probe1(struct net_device *dev, int ioaddr);
 
-static int apne_open(struct net_device *dev);
-static int apne_close(struct net_device *dev);
-
 static void apne_reset_8390(struct net_device *dev);
 static void apne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 			  int ring_page);
@@ -314,6 +311,7 @@ static int __init apne_probe1(struct net
 
     dev->base_addr = ioaddr;
     dev->irq = IRQ_AMIGA_PORTS;
+    dev->netdev_ops = &ei_netdev_ops;
 
     /* Install the Interrupt handler */
     i = request_irq(dev->irq, apne_interrupt, IRQF_SHARED, DRV_NAME, dev);
@@ -337,11 +335,7 @@ static int __init apne_probe1(struct net
     ei_status.block_input = &apne_block_input;
     ei_status.block_output = &apne_block_output;
     ei_status.get_8390_hdr = &apne_get_8390_hdr;
-    dev->open = &apne_open;
-    dev->stop = &apne_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = ei_poll;
-#endif
+
     NS8390_init(dev, 0);
 
     pcmcia_ack_int(pcmcia_get_intreq());		/* ack PCMCIA int req */
@@ -352,22 +346,6 @@ static int __init apne_probe1(struct net
     return 0;
 }
 
-static int
-apne_open(struct net_device *dev)
-{
-    ei_open(dev);
-    return 0;
-}
-
-static int
-apne_close(struct net_device *dev)
-{
-    if (ei_debug > 1)
-	printk("%s: Shutting down ethercard.\n", dev->name);
-    ei_close(dev);
-    return 0;
-}
-
 /* Hard reset the card.  This used to pause for the same period that a
    8390 reset command required, but that shouldn't be necessary. */
 static void


