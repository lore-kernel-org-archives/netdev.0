From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [ofa-general] [PATCH 2/3] infiniband: nes_nic convert to
	net_device_ops
Date: Mon, 5 Jan 2009 13:22:54 -0800
Message-ID: <20090105132254.052633d7@extreme>
References: <20090105201442.749889072@vyatta.com>
	<20090105201514.828840735@vyatta.com> <adawsd9mppk.fsf@cisco.com>
	<20090105132211.70baefb9@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hal@lists.openfabrics.org, netdev@vger.kernel.org,
	Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20090105132211.70baefb9@extreme>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/infiniband/hw/nes/nes_nic.c	2009-01-05 13:14:21.022323208 -0800
+++ b/drivers/infiniband/hw/nes/nes_nic.c	2009-01-05 13:18:32.554124317 -0800
@@ -1568,6 +1568,18 @@ static void nes_netdev_vlan_rx_register(
 	spin_unlock_irqrestore(&nesadapter->phy_lock, flags);
 }
 
+static const struct net_device_ops nes_netdev_ops = {
+	.ndo_open		= nes_netdev_open,
+	.ndo_stop		= nes_netdev_stop,
+	.ndo_start_xmit		= nes_netdev_start_xmit,
+	.ndo_get_stats		= nes_netdev_get_stats,
+	.ndo_tx_timeout		= nes_netdev_tx_timeout,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= nes_netdev_set_mac_address,
+	.ndo_set_multicast_list = nes_netdev_set_multicast_list,
+	.ndo_change_mtu 	= nes_netdev_change_mtu,
+	.ndo_vlan_rx_register   = nes_netdev_vlan_rx_register,
+};
 
 /**
  * nes_netdev_init - initialize network device
@@ -1596,14 +1608,7 @@ struct net_device *nes_netdev_init(struc
 	nesvnic = netdev_priv(netdev);
 	memset(nesvnic, 0, sizeof(*nesvnic));
 
-	netdev->open = nes_netdev_open;
-	netdev->stop = nes_netdev_stop;
-	netdev->hard_start_xmit = nes_netdev_start_xmit;
-	netdev->get_stats = nes_netdev_get_stats;
-	netdev->tx_timeout = nes_netdev_tx_timeout;
-	netdev->set_mac_address = nes_netdev_set_mac_address;
-	netdev->set_multicast_list = nes_netdev_set_multicast_list;
-	netdev->change_mtu = nes_netdev_change_mtu;
+	netdev->netdev_ops = &nes_netdev_ops;
 	netdev->watchdog_timeo = NES_TX_TIMEOUT;
 	netdev->irq = nesdev->pcidev->irq;
 	netdev->mtu = ETH_DATA_LEN;
@@ -1615,7 +1620,6 @@ struct net_device *nes_netdev_init(struc
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
 	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	netdev->vlan_rx_register = nes_netdev_vlan_rx_register;
 	netdev->features |= NETIF_F_LLTX;
 
 	/* Fill in the port structure */
