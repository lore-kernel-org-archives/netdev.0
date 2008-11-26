From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 14/14] ne2000: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:33 -0800
Message-ID: <20081126011546.250159239@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55271 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752919AbYKZBS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:56 -0500
Content-Disposition: inline; filename=ne2000-netdev-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Last driver for today.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ne.c	2008-11-25 14:47:37.000000000 -0800
+++ b/drivers/net/ne.c	2008-11-25 17:02:06.000000000 -0800
@@ -174,9 +174,6 @@ bad_clone_list[] __initdata = {
 static int ne_probe1(struct net_device *dev, unsigned long ioaddr);
 static int ne_probe_isapnp(struct net_device *dev);
 
-static int ne_open(struct net_device *dev);
-static int ne_close(struct net_device *dev);
-
 static void ne_reset_8390(struct net_device *dev);
 static void ne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 			  int ring_page);
@@ -536,11 +533,8 @@ static int __init ne_probe1(struct net_d
 	ei_status.block_output = &ne_block_output;
 	ei_status.get_8390_hdr = &ne_get_8390_hdr;
 	ei_status.priv = 0;
-	dev->open = &ne_open;
-	dev->stop = &ne_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = eip_poll;
-#endif
+
+	dev->netdev_ops = &eip_netdev_ops;
 	NS8390p_init(dev, 0);
 
 	ret = register_netdev(dev);
@@ -557,20 +551,6 @@ err_out:
 	return ret;
 }
 
-static int ne_open(struct net_device *dev)
-{
-	eip_open(dev);
-	return 0;
-}
-
-static int ne_close(struct net_device *dev)
-{
-	if (ei_debug > 1)
-		printk(KERN_DEBUG "%s: Shutting down ethercard.\n", dev->name);
-	eip_close(dev);
-	return 0;
-}
-
 /* Hard reset the card.  This used to pause for the same period that a
    8390 reset command required, but that shouldn't be necessary. */
 


