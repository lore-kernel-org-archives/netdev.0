From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/22] jme: convert driver to net_device_ops
Date: Fri, 21 Nov 2008 15:21:39 -0800
Message-ID: <20081121232238.979325307@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57001 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753386AbYKUXXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:14 -0500
Content-Disposition: inline; filename=jme-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/jme.c	2008-11-20 20:54:33.000000000 -0800
+++ b/drivers/net/jme.c	2008-11-20 21:29:40.000000000 -0800
@@ -2625,6 +2625,18 @@ jme_check_hw_ver(struct jme_adapter *jme
 	jme->chiprev = (chipmode & CM_CHIPREV_MASK) >> CM_CHIPREV_SHIFT;
 }
 
+static const struct net_device_ops jme_netdev_ops = {
+	.ndo_open		= jme_open,
+	.ndo_stop		= jme_close,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_start_xmit		= jme_start_xmit,
+	.ndo_set_mac_address	= jme_set_macaddr,
+	.ndo_set_multicast_list	= jme_set_multi,
+	.ndo_change_mtu		= jme_change_mtu,
+	.ndo_tx_timeout		= jme_tx_timeout,
+	.ndo_vlan_rx_register	= jme_vlan_rx_register,
+};
+
 static int __devinit
 jme_init_one(struct pci_dev *pdev,
 	     const struct pci_device_id *ent)
@@ -2674,17 +2686,9 @@ jme_init_one(struct pci_dev *pdev,
 		rc = -ENOMEM;
 		goto err_out_release_regions;
 	}
-	netdev->open			= jme_open;
-	netdev->stop			= jme_close;
-	netdev->hard_start_xmit		= jme_start_xmit;
-	netdev->set_mac_address		= jme_set_macaddr;
-	netdev->set_multicast_list	= jme_set_multi;
-	netdev->change_mtu		= jme_change_mtu;
+	netdev->netdev_ops = &jme_netdev_ops;
 	netdev->ethtool_ops		= &jme_ethtool_ops;
-	netdev->tx_timeout		= jme_tx_timeout;
 	netdev->watchdog_timeo		= TX_TIMEOUT;
-	netdev->vlan_rx_register	= jme_vlan_rx_register;
-	NETDEV_GET_STATS(netdev, &jme_get_stats);
 	netdev->features		=	NETIF_F_HW_CSUM |
 						NETIF_F_SG |
 						NETIF_F_TSO |

-- 

