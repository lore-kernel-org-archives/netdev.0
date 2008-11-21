From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/22] bnx2: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:21:46 -0800
Message-ID: <20081121232239.572502963@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57025 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676AbYKUXXT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:19 -0500
Content-Disposition: inline; filename=bnx2-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bnx2.c	2008-11-21 13:51:09.000000000 -0800
+++ b/drivers/net/bnx2.c	2008-11-21 13:52:13.000000000 -0800
@@ -7707,6 +7707,25 @@ bnx2_init_napi(struct bnx2 *bp)
 	}
 }
 
+static const struct net_device_ops bnx2_netdev_ops = {
+	.ndo_open		= bnx2_open,
+	.ndo_start_xmit		= bnx2_start_xmit,
+	.ndo_stop		= bnx2_close,
+	.ndo_get_stats		= bnx2_get_stats,
+	.ndo_set_rx_mode	= bnx2_set_rx_mode,
+	.ndo_do_ioctl		= bnx2_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= bnx2_change_mac_addr,
+	.ndo_change_mtu		= bnx2_change_mtu,
+	.ndo_tx_timeout		= bnx2_tx_timeout,
+#ifdef BCM_VLAN
+	.ndo_vlan_rx_register	= bnx2_vlan_rx_register,
+#endif
+#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
+	.ndo_poll_controller	= poll_bnx2,
+#endif
+};
+
 static int __devinit
 bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -7731,28 +7750,13 @@ bnx2_init_one(struct pci_dev *pdev, cons
 		return rc;
 	}
 
-	dev->open = bnx2_open;
-	dev->hard_start_xmit = bnx2_start_xmit;
-	dev->stop = bnx2_close;
-	dev->get_stats = bnx2_get_stats;
-	dev->set_rx_mode = bnx2_set_rx_mode;
-	dev->do_ioctl = bnx2_ioctl;
-	dev->set_mac_address = bnx2_change_mac_addr;
-	dev->change_mtu = bnx2_change_mtu;
-	dev->tx_timeout = bnx2_tx_timeout;
+	dev->netdev_ops = &bnx2_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-#ifdef BCM_VLAN
-	dev->vlan_rx_register = bnx2_vlan_rx_register;
-#endif
 	dev->ethtool_ops = &bnx2_ethtool_ops;
 
 	bp = netdev_priv(dev);
 	bnx2_init_napi(bp);
 
-#if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
-	dev->poll_controller = poll_bnx2;
-#endif
-
 	pci_set_drvdata(pdev, dev);
 
 	memcpy(dev->dev_addr, bp->mac_addr, 6);

-- 

