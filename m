From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 23/30] netdev: convert depca to net_device_ops
Date: Thu, 26 Mar 2009 18:11:37 -0700
Message-ID: <20090327011256.618184851@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49189 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755284AbZC0Bda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:33:30 -0400
Content-Disposition: inline; filename=depca.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/depca.c	2009-03-26 16:37:15.652590411 -0700
+++ b/drivers/net/depca.c	2009-03-26 16:41:08.258349313 -0700
@@ -566,6 +566,18 @@ MODULE_LICENSE("GPL");
     outw(CSR0, DEPCA_ADDR);\
     outw(STOP, DEPCA_DATA)
 
+static const struct net_device_ops depca_netdev_ops = {
+	.ndo_open 		= depca_open,
+	.ndo_start_xmit 	= depca_start_xmit,
+	.ndo_stop 		= depca_close,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_do_ioctl 		= depca_ioctl,
+	.ndo_tx_timeout 	= depca_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init depca_hw_init (struct net_device *dev, struct device *device)
 {
 	struct depca_private *lp;
@@ -793,12 +805,7 @@ static int __init depca_hw_init (struct 
 	}
 
 	/* The DEPCA-specific entries in the device structure. */
-	dev->open = &depca_open;
-	dev->hard_start_xmit = &depca_start_xmit;
-	dev->stop = &depca_close;
-	dev->set_multicast_list = &set_multicast_list;
-	dev->do_ioctl = &depca_ioctl;
-	dev->tx_timeout = depca_tx_timeout;
+	dev->netdev_ops = &depca_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	dev->mem_start = 0;


