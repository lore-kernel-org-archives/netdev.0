From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 06/14] es3210: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:25 -0800
Message-ID: <20081126011545.679174239@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58795 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752750AbYKZBSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:49 -0500
Content-Disposition: inline; filename=es3210-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/es3210.c	2008-11-25 16:23:37.000000000 -0800
+++ b/drivers/net/es3210.c	2008-11-25 16:41:39.000000000 -0800
@@ -64,9 +64,6 @@ static const char version[] =
 
 static int es_probe1(struct net_device *dev, int ioaddr);
 
-static int es_open(struct net_device *dev);
-static int es_close(struct net_device *dev);
-
 static void es_reset_8390(struct net_device *dev);
 
 static void es_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page);
@@ -289,11 +286,7 @@ static int __init es_probe1(struct net_d
 	ei_status.block_output = &es_block_output;
 	ei_status.get_8390_hdr = &es_get_8390_hdr;
 
-	dev->open = &es_open;
-	dev->stop = &es_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+	dev->netdev_ops = &ei_netdev_ops;
 	NS8390_init(dev, 0);
 
 	retval = register_netdev(dev);
@@ -385,22 +378,6 @@ static void es_block_output(struct net_d
 	memcpy_toio(shmem, buf, count);
 }
 
-static int es_open(struct net_device *dev)
-{
-	ei_open(dev);
-	return 0;
-}
-
-static int es_close(struct net_device *dev)
-{
-
-	if (ei_debug > 1)
-		printk("%s: Shutting down ethercard.\n", dev->name);
-
-	ei_close(dev);
-	return 0;
-}
-
 #ifdef MODULE
 #define MAX_ES_CARDS	4	/* Max number of ES3210 cards per module */
 #define NAMELEN		8	/* # of chars for storing dev->name */


