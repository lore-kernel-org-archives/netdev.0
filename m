From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 16/45] 3c507: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:13 -0800
Message-ID: <20090109230137.892583975@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42191 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754029AbZAIXR4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:56 -0500
Content-Disposition: inline; filename=3c507.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/3c507.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

--- a/drivers/net/3c507.c	2009-01-08 10:17:35.858507335 -0800
+++ b/drivers/net/3c507.c	2009-01-08 10:23:53.408662597 -0800
@@ -352,6 +352,16 @@ out:
 	return ERR_PTR(err);
 }
 
+static const struct net_device_ops netdev_ops = {
+ 	.ndo_open		= el16_open,
+ 	.ndo_stop		= el16_close,
+	.ndo_start_xmit 	= el16_send_packet,
+	.ndo_tx_timeout 	= el16_tx_timeout,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 static int __init el16_probe1(struct net_device *dev, int ioaddr)
 {
 	static unsigned char init_ID_done, version_printed;
@@ -449,10 +459,7 @@ static int __init el16_probe1(struct net
 		goto out1;
 	}
 
- 	dev->open = el16_open;
- 	dev->stop = el16_close;
-	dev->hard_start_xmit = el16_send_packet;
-	dev->tx_timeout = el16_tx_timeout;
+	dev->netdev_ops = &netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->ethtool_ops = &netdev_ethtool_ops;
  	dev->flags &= ~IFF_MULTICAST;	/* Multicast doesn't work */


