From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/42] cassini: update to net_device_ops
Date: Tue, 06 Jan 2009 16:33:21 -0800
Message-ID: <20090107003345.992109753@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58984 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754697AbZAGAxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:53:07 -0500
Content-Disposition: inline; filename=cassini.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/cassini.c	2009-01-03 21:36:30.471764781 -0800
+++ b/drivers/net/cassini.c	2009-01-03 21:39:40.431264020 -0800
@@ -4977,6 +4977,22 @@ static void __devinit cas_program_bridge
 	pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0xff);
 }
 
+static const struct net_device_ops cas_netdev_ops = {
+	.ndo_open		= cas_open,
+	.ndo_stop		= cas_close,
+	.ndo_start_xmit		= cas_start_xmit,
+	.ndo_get_stats 		= cas_get_stats,
+	.ndo_set_multicast_list = cas_set_multicast,
+	.ndo_do_ioctl		= cas_ioctl,
+	.ndo_tx_timeout		= cas_tx_timeout,
+	.ndo_change_mtu		= cas_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= cas_netpoll,
+#endif
+};
+
 static int __devinit cas_init_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -5165,23 +5181,14 @@ static int __devinit cas_init_one(struct
 
 	for (i = 0; i < N_RX_FLOWS; i++)
 		skb_queue_head_init(&cp->rx_flows[i]);
-
-	dev->open = cas_open;
-	dev->stop = cas_close;
-	dev->hard_start_xmit = cas_start_xmit;
-	dev->get_stats = cas_get_stats;
-	dev->set_multicast_list = cas_set_multicast;
-	dev->do_ioctl = cas_ioctl;
+
+	dev->netdev_ops = &cas_netdev_ops;
 	dev->ethtool_ops = &cas_ethtool_ops;
-	dev->tx_timeout = cas_tx_timeout;
 	dev->watchdog_timeo = CAS_TX_TIMEOUT;
-	dev->change_mtu = cas_change_mtu;
+
 #ifdef USE_NAPI
 	netif_napi_add(dev, &cp->napi, cas_poll, 64);
 #endif
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = cas_netpoll;
-#endif
 	dev->irq = pdev->irq;
 	dev->dma = 0;
 

-- 

