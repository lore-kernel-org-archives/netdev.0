From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 01/30] 3c503, smc-ultra: netdev_ops bugs
Date: Thu, 26 Mar 2009 18:11:15 -0700
Message-ID: <20090327011255.025012534@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39787 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751686AbZC0BUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:20:24 -0400
Content-Disposition: inline; filename=poll-controller.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of drivers have leftovers from netdev ops conversion.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/3c503.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/3c503.c	2009-03-26 15:59:32.550403332 -0700
@@ -353,9 +353,6 @@ el2_probe1(struct net_device *dev, int i
 
     dev->netdev_ops = &el2_netdev_ops;
     dev->ethtool_ops = &netdev_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-    dev->poll_controller = eip_poll;
-#endif
 
     retval = register_netdev(dev);
     if (retval)
--- a/drivers/net/smc-ultra.c	2009-03-21 12:37:00.000000000 -0700
+++ b/drivers/net/smc-ultra.c	2009-03-26 17:03:51.633589602 -0700
@@ -142,9 +142,6 @@ static int __init do_ultra_probe(struct 
 	int base_addr = dev->base_addr;
 	int irq = dev->irq;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = &ultra_poll;
-#endif
 	if (base_addr > 0x1ff)		/* Check a single specified location. */
 		return ultra_probe1(dev, base_addr);
 	else if (base_addr != 0)	/* Don't probe at all. */


