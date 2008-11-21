From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/22] sis900: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:51 -0800
Message-ID: <20081121232239.995241413@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57045 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986AbYKUXX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:26 -0500
Content-Disposition: inline; filename=sis900.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sis900.c	2008-11-21 14:17:26.000000000 -0800
+++ b/drivers/net/sis900.c	2008-11-21 14:20:36.000000000 -0800
@@ -381,6 +381,21 @@ static int __devinit sis96x_get_mac_addr
 	return 0;
 }
 
+static const struct net_device_ops sis900_netdev_ops = {
+	.ndo_open		 = sis900_open,
+	.ndo_stop		= sis900_close,
+	.ndo_start_xmit		= sis900_start_xmit,
+	.ndo_set_config		= sis900_set_config,
+	.ndo_set_multicast_list	= set_rx_mode,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= mii_ioctl,
+	.ndo_tx_timeout		= sis900_tx_timeout,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+        .ndo_poll_controller	= sis900_poll,
+#endif
+};
+
 /**
  *	sis900_probe - Probe for sis900 device
  *	@pci_dev: the sis900 pci device
@@ -461,20 +476,10 @@ static int __devinit sis900_probe(struct
 	sis_priv->rx_ring_dma = ring_dma;
 
 	/* The SiS900-specific entries in the device structure. */
-	net_dev->open = &sis900_open;
-	net_dev->hard_start_xmit = &sis900_start_xmit;
-	net_dev->stop = &sis900_close;
-	net_dev->set_config = &sis900_set_config;
-	net_dev->set_multicast_list = &set_rx_mode;
-	net_dev->do_ioctl = &mii_ioctl;
-	net_dev->tx_timeout = sis900_tx_timeout;
+	net_dev->netdev_ops = &sis900_netdev_ops;
 	net_dev->watchdog_timeo = TX_TIMEOUT;
 	net_dev->ethtool_ops = &sis900_ethtool_ops;
 
-#ifdef CONFIG_NET_POLL_CONTROLLER
-        net_dev->poll_controller = &sis900_poll;
-#endif
-
 	if (sis900_debug > 0)
 		sis_priv->msg_enable = sis900_debug;
 	else

-- 

