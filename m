From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 09/14] hp: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:28 -0800
Message-ID: <20081126011545.885003052@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58804 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752539AbYKZBSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:52 -0500
Content-Disposition: inline; filename=hp-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another old EISA driver converted.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/hp.c	2008-11-25 14:47:37.000000000 -0800
+++ b/drivers/net/hp.c	2008-11-25 16:47:46.000000000 -0800
@@ -59,8 +59,6 @@ static unsigned int hppclan_portlist[] _
 
 static int hp_probe1(struct net_device *dev, int ioaddr);
 
-static int hp_open(struct net_device *dev);
-static int hp_close(struct net_device *dev);
 static void hp_reset_8390(struct net_device *dev);
 static void hp_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 					int ring_page);
@@ -198,11 +196,7 @@ static int __init hp_probe1(struct net_d
 
 	/* Set the base address to point to the NIC, not the "real" base! */
 	dev->base_addr = ioaddr + NIC_OFFSET;
-	dev->open = &hp_open;
-	dev->stop = &hp_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = eip_poll;
-#endif
+	dev->netdev_ops = &eip_netdev_ops;
 
 	ei_status.name = name;
 	ei_status.word16 = wordmode;
@@ -227,20 +221,6 @@ out:
 	return retval;
 }
 
-static int
-hp_open(struct net_device *dev)
-{
-	eip_open(dev);
-	return 0;
-}
-
-static int
-hp_close(struct net_device *dev)
-{
-	eip_close(dev);
-	return 0;
-}
-
 static void
 hp_reset_8390(struct net_device *dev)
 {


