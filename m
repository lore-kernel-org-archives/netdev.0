From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 12/14] stnic: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:31 -0800
Message-ID: <20081126011546.105584230@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55266 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882AbYKZBSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:54 -0500
Content-Disposition: inline; filename=stnic-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can just use common ei_netdev_ops definition.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/stnic.c	2008-11-25 14:33:02.000000000 -0800
+++ b/drivers/net/stnic.c	2008-11-25 14:34:28.000000000 -0800
@@ -60,8 +60,6 @@ static byte stnic_eadr[6] =
 
 static struct net_device *stnic_dev;
 
-static int stnic_open (struct net_device *dev);
-static int stnic_close (struct net_device *dev);
 static void stnic_reset (struct net_device *dev);
 static void stnic_get_hdr (struct net_device *dev, struct e8390_pkt_hdr *hdr,
 			   int ring_page);
@@ -122,11 +120,7 @@ static int __init stnic_probe(void)
   /* Set the base address to point to the NIC, not the "real" base! */
   dev->base_addr = 0x1000;
   dev->irq = IRQ_STNIC;
-  dev->open = &stnic_open;
-  dev->stop = &stnic_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-  dev->poll_controller = ei_poll;
-#endif
+  dev->netdev_ops = &ei_netdev_ops;
 
   /* Snarf the interrupt now.  There's no point in waiting since we cannot
      share and the board will usually be enabled. */
@@ -168,23 +162,6 @@ static int __init stnic_probe(void)
   return 0;
 }
 
-static int
-stnic_open (struct net_device *dev)
-{
-#if 0
-  printk (KERN_DEBUG "stnic open\n");
-#endif
-  ei_open (dev);
-  return 0;
-}
-
-static int
-stnic_close (struct net_device *dev)
-{
-  ei_close (dev);
-  return 0;
-}
-
 static void
 stnic_reset (struct net_device *dev)
 {


