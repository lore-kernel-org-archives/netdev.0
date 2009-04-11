From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 06/11] macsonic: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:41:28 +0400
Message-ID: <20090411174128.GF16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:6160 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756953AbZDKRlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:41:35 -0400
Received: by an-out-0708.google.com with SMTP id d14so1350170and.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:41:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/macsonic.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macsonic.c b/drivers/net/macsonic.c
index 527166e..acd143d 100644
--- a/drivers/net/macsonic.c
+++ b/drivers/net/macsonic.c
@@ -167,6 +167,18 @@ static int macsonic_close(struct net_device* dev)
 	return err;
 }
 
+static const struct net_device_ops macsonic_netdev_ops = {
+	.ndo_open		= macsonic_open,
+	.ndo_stop		= macsonic_close,
+	.ndo_start_xmit		= sonic_send_packet,
+	.ndo_set_multicast_list	= sonic_multicast_list,
+	.ndo_tx_timeout		= sonic_tx_timeout,
+	.ndo_get_stats		= sonic_get_stats,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+};
+
 static int __init macsonic_init(struct net_device *dev)
 {
 	struct sonic_local* lp = netdev_priv(dev);
@@ -198,12 +210,7 @@ static int __init macsonic_init(struct net_device *dev)
 	lp->rra_laddr = lp->rda_laddr + (SIZEOF_SONIC_RD * SONIC_NUM_RDS
 	                     * SONIC_BUS_SCALE(lp->dma_bitmode));
 
-	dev->open = macsonic_open;
-	dev->stop = macsonic_close;
-	dev->hard_start_xmit = sonic_send_packet;
-	dev->get_stats = sonic_get_stats;
-	dev->set_multicast_list = &sonic_multicast_list;
-	dev->tx_timeout = sonic_tx_timeout;
+	dev->netdev_ops = &macsonic_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	/*
