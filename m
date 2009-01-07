From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 40/42] amd8111e: convert to net_device_ops
Date: Tue, 06 Jan 2009 16:33:56 -0800
Message-ID: <20090107003349.806107126@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60725 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757038AbZAGAyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:16 -0500
Content-Disposition: inline; filename=amd8111e.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/amd8111e.c	2009-01-05 16:51:26.431069139 -0800
+++ b/drivers/net/amd8111e.c	2009-01-05 16:53:51.933650831 -0800
@@ -1813,6 +1813,25 @@ static void __devinit amd8111e_probe_ext
 	lp->ext_phy_addr = 1;
 }
 
+static const struct net_device_ops amd8111e_netdev_ops = {
+	.ndo_open		= amd8111e_open,
+	.ndo_stop		= amd8111e_close,
+	.ndo_start_xmit		= amd8111e_start_xmit,
+	.ndo_tx_timeout		= amd8111e_tx_timeout,
+	.ndo_get_stats		= amd8111e_get_stats,
+	.ndo_set_multicast_list = amd8111e_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= amd8111e_set_mac_address,
+	.ndo_do_ioctl		= amd8111e_ioctl,
+	.ndo_change_mtu		= amd8111e_change_mtu,
+#if AMD8111E_VLAN_TAG_USED
+	.ndo_vlan_rx_register	= amd8111e_vlan_rx_register,
+#endif
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	 = amd8111e_poll,
+#endif
+};
+
 static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 				  const struct pci_device_id *ent)
 {
@@ -1872,7 +1891,6 @@ static int __devinit amd8111e_probe_one(
 
 #if AMD8111E_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX ;
-	dev->vlan_rx_register =amd8111e_vlan_rx_register;
 #endif
 
 	lp = netdev_priv(dev);
@@ -1901,27 +1919,16 @@ static int __devinit amd8111e_probe_one(
 	if(dynamic_ipg[card_idx++])
 		lp->options |= OPTION_DYN_IPG_ENABLE;
 
+
 	/* Initialize driver entry points */
-	dev->open = amd8111e_open;
-	dev->hard_start_xmit = amd8111e_start_xmit;
-	dev->stop = amd8111e_close;
-	dev->get_stats = amd8111e_get_stats;
-	dev->set_multicast_list = amd8111e_set_multicast_list;
-	dev->set_mac_address = amd8111e_set_mac_address;
-	dev->do_ioctl = amd8111e_ioctl;
-	dev->change_mtu = amd8111e_change_mtu;
+	dev->netdev_ops = &amd8111e_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->irq =pdev->irq;
-	dev->tx_timeout = amd8111e_tx_timeout;
 	dev->watchdog_timeo = AMD8111E_TX_TIMEOUT;
 	netif_napi_add(dev, &lp->napi, amd8111e_rx_poll, 32);
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = amd8111e_poll;
-#endif
 
 #if AMD8111E_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register =amd8111e_vlan_rx_register;
 #endif
 	/* Probe the external PHY */
 	amd8111e_probe_ext_phy(dev);

-- 

