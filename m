From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH 11/11] eth_v10: convert to net_device_ops
Date: Sat, 11 Apr 2009 21:45:55 +0400
Message-ID: <20090411174555.GK16999@orion>
References: <20090411173019.GA16999@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:20446 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbZDKRqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 13:46:02 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1587258ywb.1
        for <netdev@vger.kernel.org>; Sat, 11 Apr 2009 10:46:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090411173019.GA16999@orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/cris/eth_v10.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index c9806c5..7a18dc7 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -257,6 +257,23 @@ struct transceiver_ops transceivers[] =
 
 struct transceiver_ops* transceiver = &transceivers[0];
 
+static const struct net_device_ops e100_netdev_ops = {
+	.ndo_open		= e100_open,
+	.ndo_stop		= e100_close,
+	.ndo_start_xmit		= e100_send_packet,
+	.ndo_tx_timeout		= e100_tx_timeout,
+	.ndo_get_stats		= e100_get_stats,
+	.ndo_set_multicast_list	= set_multicast_list,
+	.ndo_do_ioctl		= e100_ioctl,
+	.ndo_set_mac_address	= e100_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_config		= e100_set_config,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= e100_netpoll,
+#endif
+};
+
 #define tx_done(dev) (*R_DMA_CH0_CMD == 0)
 
 /*
@@ -300,19 +317,8 @@ etrax_ethernet_init(void)
 
 	/* fill in our handlers so the network layer can talk to us in the future */
 
-	dev->open               = e100_open;
-	dev->hard_start_xmit    = e100_send_packet;
-	dev->stop               = e100_close;
-	dev->get_stats          = e100_get_stats;
-	dev->set_multicast_list = set_multicast_list;
-	dev->set_mac_address    = e100_set_mac_address;
 	dev->ethtool_ops	= &e100_ethtool_ops;
-	dev->do_ioctl           = e100_ioctl;
-	dev->set_config		= e100_set_config;
-	dev->tx_timeout         = e100_tx_timeout;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = e100_netpoll;
-#endif
+	dev->netdev_ops		= &e100_netdev_ops;
 
 	spin_lock_init(&np->lock);
 	spin_lock_init(&np->led_lock);
