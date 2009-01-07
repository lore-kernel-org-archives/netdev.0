From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 19/42] sb1000: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:35 -0800
Message-ID: <20090107003347.452521519@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59034 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756085AbZAGAxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:43 -0500
Content-Disposition: inline; filename=sb1000.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sb1000.c	2009-01-05 11:11:10.425571186 -0800
+++ b/drivers/net/sb1000.c	2009-01-05 11:12:59.757816689 -0800
@@ -134,6 +134,16 @@ static const struct pnp_device_id sb1000
 };
 MODULE_DEVICE_TABLE(pnp, sb1000_pnp_ids);
 
+static const struct net_device_ops sb1000_netdev_ops = {
+	.ndo_open		= sb1000_open,
+	.ndo_start_xmit		= sb1000_start_xmit,
+	.ndo_do_ioctl		= sb1000_dev_ioctl,
+	.ndo_stop		= sb1000_close,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int
 sb1000_probe_one(struct pnp_dev *pdev, const struct pnp_device_id *id)
 {
@@ -192,11 +202,7 @@ sb1000_probe_one(struct pnp_dev *pdev, c
 	if (sb1000_debug > 0)
 		printk(KERN_NOTICE "%s", version);
 
-	/* The SB1000-specific entries in the device structure. */
-	dev->open		= sb1000_open;
-	dev->do_ioctl		= sb1000_dev_ioctl;
-	dev->hard_start_xmit	= sb1000_start_xmit;
-	dev->stop		= sb1000_close;
+	dev->netdev_ops	= &sb1000_netdev_ops;
 
 	/* hardware address is 0:0:serial_number */
 	dev->dev_addr[2]	= serial_number >> 24 & 0xff;

-- 

