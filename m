From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 10/14] ne2: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:29 -0800
Message-ID: <20081126011545.956586522@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58808 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689AbYKZBSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:54 -0500
Content-Disposition: inline; filename=ne2-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Almost there.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ne2.c	2008-11-25 14:47:37.000000000 -0800
+++ b/drivers/net/ne2.c	2008-11-25 16:46:52.000000000 -0800
@@ -492,11 +492,7 @@ static int __init ne2_probe1(struct net_
 
 	ei_status.priv = slot;
 
-	dev->open = &ne_open;
-	dev->stop = &ne_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = eip_poll;
-#endif
+	dev->netdev_ops = &eip_netdev_ops;
 	NS8390p_init(dev, 0);
 
 	retval = register_netdev(dev);
@@ -511,20 +507,6 @@ out:
 	return retval;
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
-		printk("%s: Shutting down ethercard.\n", dev->name);
-	eip_close(dev);
-	return 0;
-}
-
 /* Hard reset the card.  This used to pause for the same period that a
    8390 reset command required, but that shouldn't be necessary. */
 static void ne_reset_8390(struct net_device *dev)


