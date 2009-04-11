From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 01/11] xtsonic: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:30:19 +0400
Message-ID: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:33057 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbZDKRad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:30:33 -0400
Received: by yx-out-2324.google.com with SMTP id 31so1590243yxl.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:30:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/xtsonic.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xtsonic.c b/drivers/net/xtsonic.c
index a12a721..5a4ad15 100644
--- a/drivers/net/xtsonic.c
+++ b/drivers/net/xtsonic.c
@@ -108,6 +108,18 @@ static int xtsonic_close(struct net_device *dev)
 	return err;
 }
 
+static const struct net_device_ops xtsonic_netdev_ops = {
+	.ndo_open		= xtsonic_open,
+	.ndo_stop		= xtsonic_close,
+	.ndo_start_xmit		= sonic_send_packet,
+	.ndo_get_stats		= sonic_get_stats,
+	.ndo_set_multicast_list	= sonic_multicast_list,
+	.ndo_tx_timeout		= sonic_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __init sonic_probe1(struct net_device *dev)
 {
 	static unsigned version_printed = 0;
@@ -205,12 +217,7 @@ static int __init sonic_probe1(struct net_device *dev)
 	lp->rra_laddr = lp->rda_laddr + (SIZEOF_SONIC_RD * SONIC_NUM_RDS
 					 * SONIC_BUS_SCALE(lp->dma_bitmode));
 
-	dev->open = xtsonic_open;
-	dev->stop = xtsonic_close;
-	dev->hard_start_xmit	= sonic_send_packet;
-	dev->get_stats		= sonic_get_stats;
-	dev->set_multicast_list	= &sonic_multicast_list;
-	dev->tx_timeout		= sonic_tx_timeout;
+	dev->netdev_ops		= &xtsonic_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 
 	/*
