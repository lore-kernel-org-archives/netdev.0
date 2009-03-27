From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 30/30] netdev: convert eth16i to net_device_ops
Date: Thu, 26 Mar 2009 18:11:44 -0700
Message-ID: <20090327011257.104894196@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46976 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763401AbZC0BhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:37:12 -0400
Content-Disposition: inline; filename=eth16i.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also, get rid of unnecessary memset.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/eth16i.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/eth16i.c	2009-03-26 17:38:41.176599608 -0700
@@ -475,6 +475,17 @@ out:
 }
 #endif
 
+static const struct net_device_ops eth16i_netdev_ops = {
+	.ndo_open               = eth16i_open,
+	.ndo_stop               = eth16i_close,
+	.ndo_start_xmit    	= eth16i_tx,
+	.ndo_set_multicast_list = eth16i_multicast,
+	.ndo_tx_timeout 	= eth16i_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init eth16i_probe1(struct net_device *dev, int ioaddr)
 {
 	struct eth16i_local *lp = netdev_priv(dev);
@@ -549,12 +560,7 @@ static int __init eth16i_probe1(struct n
 	BITCLR(ioaddr + CONFIG_REG_1, POWERUP);
 
 	/* Initialize the device structure */
-	memset(lp, 0, sizeof(struct eth16i_local));
-	dev->open               = eth16i_open;
-	dev->stop               = eth16i_close;
-	dev->hard_start_xmit    = eth16i_tx;
-	dev->set_multicast_list = eth16i_multicast;
-	dev->tx_timeout 	= eth16i_timeout;
+	dev->netdev_ops         = &eth16i_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 	spin_lock_init(&lp->lock);
 


