From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 08/14] lne390: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:27 -0800
Message-ID: <20081126011545.818829628@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58802 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752803AbYKZBSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:51 -0500
Content-Disposition: inline; filename=lne390-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/lne390.c	2008-11-25 14:45:17.000000000 -0800
+++ b/drivers/net/lne390.c	2008-11-25 14:45:42.000000000 -0800
@@ -53,9 +53,6 @@ static const char *version =
 
 static int lne390_probe1(struct net_device *dev, int ioaddr);
 
-static int lne390_open(struct net_device *dev);
-static int lne390_close(struct net_device *dev);
-
 static void lne390_reset_8390(struct net_device *dev);
 
 static void lne390_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page);
@@ -278,11 +275,7 @@ static int __init lne390_probe1(struct n
 	ei_status.block_output = &lne390_block_output;
 	ei_status.get_8390_hdr = &lne390_get_8390_hdr;
 
-	dev->open = &lne390_open;
-	dev->stop = &lne390_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+	dev->netdev_ops = &ei_netdev_ops;
 	NS8390_init(dev, 0);
 
 	ret = register_netdev(dev);
@@ -374,21 +367,6 @@ static void lne390_block_output(struct n
 	memcpy_toio(shmem, buf, count);
 }
 
-static int lne390_open(struct net_device *dev)
-{
-	ei_open(dev);
-	return 0;
-}
-
-static int lne390_close(struct net_device *dev)
-{
-
-	if (ei_debug > 1)
-		printk("%s: Shutting down ethercard.\n", dev->name);
-
-	ei_close(dev);
-	return 0;
-}
 
 #ifdef MODULE
 #define MAX_LNE_CARDS	4	/* Max number of LNE390 cards per module */


