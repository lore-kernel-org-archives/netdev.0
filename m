From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 30/45] znet: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:27 -0800
Message-ID: <20090109230138.926785388@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42226 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754267AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=znet.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/znet.c	2009-01-08 08:30:16.000000000 -0800
+++ b/drivers/net/znet.c	2009-01-09 10:01:35.000000000 -0800
@@ -358,6 +358,17 @@ static void znet_set_multicast_list (str
 	 * multicast address configured isn't equal to IFF_ALLMULTI */
 }
 
+static const struct net_device_ops znet_netdev_ops = {
+	.ndo_open		= znet_open,
+	.ndo_stop		= znet_close,
+	.ndo_start_xmit		= znet_send_packet,
+	.ndo_set_multicast_list = znet_set_multicast_list,
+	.ndo_tx_timeout		= znet_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /* The Z-Note probe is pretty easy.  The NETIDBLK exists in the safe-to-probe
    BIOS area.  We just scan for the signature, and pull the vital parameters
    out of the structure. */
@@ -440,11 +451,7 @@ static int __init znet_probe (void)
 	znet->tx_end = znet->tx_start + znet->tx_buf_len;
 
 	/* The ZNET-specific entries in the device structure. */
-	dev->open = &znet_open;
-	dev->hard_start_xmit = &znet_send_packet;
-	dev->stop = &znet_close;
-	dev->set_multicast_list = &znet_set_multicast_list;
-	dev->tx_timeout = znet_tx_timeout;
+	dev->netdev_ops = &znet_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	err = register_netdev(dev);
 	if (err)


