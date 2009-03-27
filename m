From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 22/30] netdev: convert at1700 to net_device_ops
Date: Thu, 26 Mar 2009 18:11:36 -0700
Message-ID: <20090327011256.531097944@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49186 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763172AbZC0BdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:33:02 -0400
Content-Disposition: inline; filename=at1700.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unneeded memset (alloc_etherdev does it already).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/at1700.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/at1700.c	2009-03-26 16:37:45.521599392 -0700
@@ -249,6 +249,17 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops at1700_netdev_ops = {
+	.ndo_open		= net_open,
+	.ndo_stop		= net_close,
+	.ndo_start_xmit 	= net_send_packet,
+	.ndo_set_multicast_list = set_rx_mode,
+	.ndo_tx_timeout 	= net_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* The Fujitsu datasheet suggests that the NIC be probed for by checking its
    "signature", the default bit pattern after a reset.  This *doesn't* work --
    there is no way to reset the bus interface without a complete power-cycle!
@@ -448,13 +459,7 @@ found:
 	if (net_debug)
 		printk(version);
 
-	memset(lp, 0, sizeof(struct net_local));
-
-	dev->open		= net_open;
-	dev->stop		= net_close;
-	dev->hard_start_xmit = net_send_packet;
-	dev->set_multicast_list = &set_rx_mode;
-	dev->tx_timeout = net_tx_timeout;
+	dev->netdev_ops = &at1700_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	spin_lock_init(&lp->lock);


