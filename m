From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 05/14] ne3210: convert to net_device_ops
Date: Tue, 25 Nov 2008 17:14:24 -0800
Message-ID: <20081126011545.581939605@linux-foundation.org>
References: <20081126011419.402319779@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58792 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687AbYKZBSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 20:18:48 -0500
Content-Disposition: inline; filename=ne3210-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By having common code in 8390.o don't need net_dev_ops in
the driver.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ne3210.c	2008-11-25 16:23:37.000000000 -0800
+++ b/drivers/net/ne3210.c	2008-11-25 16:41:37.000000000 -0800
@@ -45,9 +45,6 @@
 
 #define DRV_NAME "ne3210"
 
-static int ne3210_open(struct net_device *dev);
-static int ne3210_close(struct net_device *dev);
-
 static void ne3210_reset_8390(struct net_device *dev);
 
 static void ne3210_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr, int ring_page);
@@ -199,11 +196,8 @@ static int __init ne3210_eisa_probe (str
 	ei_status.block_output = &ne3210_block_output;
 	ei_status.get_8390_hdr = &ne3210_get_8390_hdr;
 
-	dev->open = &ne3210_open;
-	dev->stop = &ne3210_close;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
+	dev->netdev_ops = &ei_netdev_ops;
+
 	dev->if_port = ifmap_val[port_index];
 
 	if ((retval = register_netdev (dev)))
@@ -320,22 +314,6 @@ static void ne3210_block_output(struct n
 	memcpy_toio(shmem, buf, count);
 }
 
-static int ne3210_open(struct net_device *dev)
-{
-	ei_open(dev);
-	return 0;
-}
-
-static int ne3210_close(struct net_device *dev)
-{
-
-	if (ei_debug > 1)
-		printk("%s: Shutting down ethercard.\n", dev->name);
-
-	ei_close(dev);
-	return 0;
-}
-
 static struct eisa_device_id ne3210_ids[] = {
 	{ "EGL0101" },
 	{ "NVL1801" },


