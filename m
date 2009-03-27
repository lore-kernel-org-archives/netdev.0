From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 20/30] netdev: convert eexpress to net_device_ops
Date: Thu, 26 Mar 2009 18:11:34 -0700
Message-ID: <20090327011256.405174887@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49180 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763241AbZC0BcA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:32:00 -0400
Content-Disposition: inline; filename=eexpress.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/eexpress.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/eexpress.c	2009-03-26 16:15:08.615344476 -0700
@@ -1043,6 +1043,17 @@ static void eexp_hw_tx_pio(struct net_de
 	lp->last_tx = jiffies;
 }
 
+static const struct net_device_ops eexp_netdev_ops = {
+	.ndo_open 		= eexp_open,
+	.ndo_stop 		= eexp_close,
+	.ndo_start_xmit		= eexp_xmit,
+	.ndo_set_multicast_list = eexp_set_multicast,
+	.ndo_tx_timeout		= eexp_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*
  * Sanity check the suspected EtherExpress card
  * Read hardware address, reset card, size memory and initialize buffer
@@ -1163,11 +1174,7 @@ static int __init eexp_hw_probe(struct n
 	lp->rx_buf_start = TX_BUF_START + (lp->num_tx_bufs*TX_BUF_SIZE);
 	lp->width = buswidth;
 
-	dev->open = eexp_open;
-	dev->stop = eexp_close;
-	dev->hard_start_xmit = eexp_xmit;
-	dev->set_multicast_list = &eexp_set_multicast;
-	dev->tx_timeout = eexp_timeout;
+	dev->netdev_ops = &eexp_netdev_ops;
 	dev->watchdog_timeo = 2*HZ;
 
 	return register_netdev(dev);


