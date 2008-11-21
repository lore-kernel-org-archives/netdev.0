From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 20/22] sc92031: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:58 -0800
Message-ID: <20081121232240.588502223@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57073 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755242AbYKUXXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:37 -0500
Content-Disposition: inline; filename=sc92031.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert this driver to net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sc92031.c	2008-11-21 14:41:41.000000000 -0800
+++ b/drivers/net/sc92031.c	2008-11-21 14:43:39.000000000 -0800
@@ -1386,7 +1386,7 @@ static void sc92031_ethtool_get_ethtool_
 	spin_unlock_bh(&priv->lock);
 }
 
-static struct ethtool_ops sc92031_ethtool_ops = {
+static const struct ethtool_ops sc92031_ethtool_ops = {
 	.get_settings		= sc92031_ethtool_get_settings,
 	.set_settings		= sc92031_ethtool_set_settings,
 	.get_drvinfo		= sc92031_ethtool_get_drvinfo,
@@ -1399,6 +1399,21 @@ static struct ethtool_ops sc92031_ethtoo
 	.get_ethtool_stats	= sc92031_ethtool_get_ethtool_stats,
 };
 
+
+static const struct net_device_ops sc92031_netdev_ops = {
+	.ndo_get_stats		= sc92031_get_stats,
+	.ndo_start_xmit		= sc92031_start_xmit,
+	.ndo_open		= sc92031_open,
+	.ndo_stop		= sc92031_stop,
+	.ndo_set_multicast_list	= sc92031_set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_tx_timeout		= sc92031_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= sc92031_poll_controller,
+#endif
+};
+
 static int __devinit sc92031_probe(struct pci_dev *pdev,
 		const struct pci_device_id *id)
 {
@@ -1452,17 +1467,9 @@ static int __devinit sc92031_probe(struc
 	/* faked with skb_copy_and_csum_dev */
 	dev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
 
-	dev->get_stats		= sc92031_get_stats;
-	dev->ethtool_ops	= &sc92031_ethtool_ops;
-	dev->hard_start_xmit	= sc92031_start_xmit;
+	dev->netdev_ops		= &sc92031_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
-	dev->open		= sc92031_open;
-	dev->stop		= sc92031_stop;
-	dev->set_multicast_list	= sc92031_set_multicast_list;
-	dev->tx_timeout		= sc92031_tx_timeout;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller	= sc92031_poll_controller;
-#endif
+	dev->ethtool_ops	= &sc92031_ethtool_ops;
 
 	priv = netdev_priv(dev);
 	spin_lock_init(&priv->lock);

-- 

