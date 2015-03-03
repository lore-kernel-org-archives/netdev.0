From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 02/14] ethernet: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:47 -0800
Message-ID: <86d963752051ae24a93c9a26da1e847459723aed.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org, Don Fry <pcnet32@frontier.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/amd/pcnet32.c                  | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c   | 2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c         | 8 ++++----
 drivers/net/ethernet/emulex/benet/be_cmds.c         | 2 +-
 drivers/net/ethernet/emulex/benet/be_main.c         | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c      | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c    | 2 +-
 drivers/net/ethernet/micrel/ksz884x.c               | 2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c  | 2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c        | 2 +-
 drivers/net/ethernet/smsc/smsc911x.c                | 2 +-
 drivers/net/ethernet/ti/netcp_core.c                | 2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c   | 4 ++--
 drivers/net/ethernet/xscale/ixp4xx_eth.c            | 2 +-
 17 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 11d6e65..8eb37e0 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1708,7 +1708,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 
 	/* if the ethernet address is not valid, force to 00:00:00:00:00:00 */
 	if (!is_valid_ether_addr(dev->dev_addr))
-		memset(dev->dev_addr, 0, ETH_ALEN);
+		eth_zero_addr(dev->dev_addr);
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
 		pr_cont(" %pM", dev->dev_addr);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index ffe4e00..e3d853c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -2446,7 +2446,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 	}
 	packet = skb_put(skb, pkt_size);
 	memcpy(packet, bp->dev->dev_addr, ETH_ALEN);
-	memset(packet + ETH_ALEN, 0, ETH_ALEN);
+	eth_zero_addr(packet + ETH_ALEN);
 	memset(packet + 2*ETH_ALEN, 0x77, (ETH_HLEN - 2*ETH_ALEN));
 	for (i = ETH_HLEN; i < pkt_size; i++)
 		packet[i] = (unsigned char) (i & 0xff);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 7155e1d..98dcb03 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11546,13 +11546,13 @@ static void bnx2x_get_cnic_mac_hwinfo(struct bnx2x *bp)
 	/* Disable iSCSI OOO if MAC configuration is invalid. */
 	if (!is_valid_ether_addr(iscsi_mac)) {
 		bp->flags |= NO_ISCSI_OOO_FLAG | NO_ISCSI_FLAG;
-		memset(iscsi_mac, 0, ETH_ALEN);
+		eth_zero_addr(iscsi_mac);
 	}
 
 	/* Disable FCoE if MAC configuration is invalid. */
 	if (!is_valid_ether_addr(fip_mac)) {
 		bp->flags |= NO_FCOE_FLAG;
-		memset(bp->fip_mac, 0, ETH_ALEN);
+		eth_zero_addr(bp->fip_mac);
 	}
 }
 
@@ -11563,7 +11563,7 @@ static void bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 	int port = BP_PORT(bp);
 
 	/* Zero primary MAC configuration */
-	memset(bp->dev->dev_addr, 0, ETH_ALEN);
+	eth_zero_addr(bp->dev->dev_addr);
 
 	if (BP_NOMCP(bp)) {
 		BNX2X_ERROR("warning: random MAC workaround active\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index e5aca2d..8638d6c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -2693,7 +2693,7 @@ int bnx2x_get_vf_config(struct net_device *dev, int vfidx,
 			memcpy(&ivi->mac, bulletin->mac, ETH_ALEN);
 		else
 			/* function has not been loaded yet. Show mac as 0s */
-			memset(&ivi->mac, 0, ETH_ALEN);
+			eth_zero_addr(ivi->mac);
 
 		/* vlan */
 		if (bulletin->valid_bitmap & (1 << VLAN_VALID))
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 9cbe038..a368c0a 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -893,7 +893,7 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 		} else {
 			memset(pp, 0, sizeof(*pp));
 			if (vf == PORT_SELF_VF)
-				memset(netdev->dev_addr, 0, ETH_ALEN);
+				eth_zero_addr(netdev->dev_addr);
 		}
 	} else {
 		/* Set flag to indicate that the port assoc/disassoc
@@ -903,14 +903,14 @@ static int enic_set_vf_port(struct net_device *netdev, int vf,
 
 		/* If DISASSOCIATE, clean up all assigned/saved macaddresses */
 		if (pp->request == PORT_REQUEST_DISASSOCIATE) {
-			memset(pp->mac_addr, 0, ETH_ALEN);
+			eth_zero_addr(pp->mac_addr);
 			if (vf == PORT_SELF_VF)
-				memset(netdev->dev_addr, 0, ETH_ALEN);
+				eth_zero_addr(netdev->dev_addr);
 		}
 	}
 
 	if (vf == PORT_SELF_VF)
-		memset(pp->vf_mac, 0, ETH_ALEN);
+		eth_zero_addr(pp->vf_mac);
 
 	return err;
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index f6db7b3..be00695 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3076,7 +3076,7 @@ int be_cmd_get_perm_mac(struct be_adapter *adapter, u8 *mac)
 	int status;
 	bool pmac_valid = false;
 
-	memset(mac, 0, ETH_ALEN);
+	eth_zero_addr(mac);
 
 	if (BEx_chip(adapter)) {
 		if (be_physfn(adapter))
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index b2277a4..7eccebc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3218,7 +3218,7 @@ static int be_setup_wol(struct be_adapter *adapter, bool enable)
 	int status = 0;
 	u8 mac[ETH_ALEN];
 
-	memset(mac, 0, ETH_ALEN);
+	eth_zero_addr(mac);
 
 	cmd.size = sizeof(struct be_cmd_req_acpi_wol_magic_config);
 	cmd.va = dma_zalloc_coherent(&adapter->pdev->dev, cmd.size, &cmd.dma,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 70cc4c5..903664f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3924,7 +3924,7 @@ static void ixgbe_flush_sw_mac_table(struct ixgbe_adapter *adapter)
 	for (i = 0; i < hw->mac.num_rar_entries; i++) {
 		adapter->mac_table[i].state |= IXGBE_MAC_STATE_MODIFIED;
 		adapter->mac_table[i].state &= ~IXGBE_MAC_STATE_IN_USE;
-		memset(adapter->mac_table[i].addr, 0, ETH_ALEN);
+		eth_zero_addr(adapter->mac_table[i].addr);
 		adapter->mac_table[i].queue = 0;
 	}
 	ixgbe_sync_mac_table(adapter);
@@ -3992,7 +3992,7 @@ int ixgbe_del_mac_filter(struct ixgbe_adapter *adapter, u8 *addr, u16 queue)
 		    adapter->mac_table[i].queue == queue) {
 			adapter->mac_table[i].state |= IXGBE_MAC_STATE_MODIFIED;
 			adapter->mac_table[i].state &= ~IXGBE_MAC_STATE_IN_USE;
-			memset(adapter->mac_table[i].addr, 0, ETH_ALEN);
+			eth_zero_addr(adapter->mac_table[i].addr);
 			adapter->mac_table[i].queue = 0;
 			ixgbe_sync_mac_table(adapter);
 			return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2a210c4..c59ed92 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1685,7 +1685,7 @@ int mlx4_en_start_port(struct net_device *dev)
 	}
 
 	/* Attach rx QP to bradcast address */
-	memset(&mc_list[10], 0xff, ETH_ALEN);
+	eth_broadcast_addr(&mc_list[10]);
 	mc_list[5] = priv->port; /* needed for B0 steering support */
 	if (mlx4_multicast_attach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
 				  priv->port, 0, MLX4_PROT_ETH,
@@ -1788,7 +1788,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	}
 
 	/* Detach All multicasts */
-	memset(&mc_list[10], 0xff, ETH_ALEN);
+	eth_broadcast_addr(&mc_list[10]);
 	mc_list[5] = priv->port; /* needed for B0 steering support */
 	mlx4_multicast_detach(mdev->dev, &priv->rss_map.indir_qp, mc_list,
 			      MLX4_PROT_ETH, priv->broadcast_id);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
index 2d8ee66..4e78947 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
@@ -66,7 +66,7 @@ static int mlx4_en_test_loopback_xmit(struct mlx4_en_priv *priv)
 	ethh = (struct ethhdr *)skb_put(skb, sizeof(struct ethhdr));
 	packet	= (unsigned char *)skb_put(skb, packet_size);
 	memcpy(ethh->h_dest, priv->dev->dev_addr, ETH_ALEN);
-	memset(ethh->h_source, 0, ETH_ALEN);
+	eth_zero_addr(ethh->h_source);
 	ethh->h_proto = htons(ETH_P_ARP);
 	skb_set_mac_header(skb, 0);
 	for (i = 0; i < packet_size; ++i)	/* fill our packet */
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 10988fb..6f332eb 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4144,7 +4144,7 @@ static int hw_del_addr(struct ksz_hw *hw, u8 *mac_addr)
 
 	for (i = 0; i < hw->addr_list_size; i++) {
 		if (ether_addr_equal(hw->address[i], mac_addr)) {
-			memset(hw->address[i], 0, ETH_ALEN);
+			eth_zero_addr(hw->address[i]);
 			writel(0, hw->io + ADD_ADDR_INCR * i +
 				KS_ADD_ADDR_0_HI);
 			return 0;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 716fc37..db80eb1 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -537,7 +537,7 @@ static void netxen_p2_nic_set_multi(struct net_device *netdev)
 	u8 null_addr[ETH_ALEN];
 	int i;
 
-	memset(null_addr, 0, ETH_ALEN);
+	eth_zero_addr(null_addr);
 
 	if (netdev->flags & IFF_PROMISC) {
 
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 8011ef3..25800a1 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -460,7 +460,7 @@ static int ql_set_mac_addr(struct ql_adapter *qdev, int set)
 		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
 			     "Set Mac addr %pM\n", addr);
 	} else {
-		memset(zero_mac_addr, 0, ETH_ALEN);
+		eth_zero_addr(zero_mac_addr);
 		addr = &zero_mac_addr[0];
 		netif_printk(qdev, ifup, KERN_DEBUG, qdev->ndev,
 			     "Clearing MAC address\n");
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 2965c6a..41047c9 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -843,7 +843,7 @@ static int smsc911x_phy_loopbacktest(struct net_device *dev)
 	unsigned long flags;
 
 	/* Initialise tx packet using broadcast destination address */
-	memset(pdata->loopback_tx_pkt, 0xff, ETH_ALEN);
+	eth_broadcast_addr(pdata->loopback_tx_pkt);
 
 	/* Use incrementing source address */
 	for (i = 6; i < 12; i++)
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index a31a8c3..9f14d8b 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1320,7 +1320,7 @@ static struct netcp_addr *netcp_addr_add(struct netcp_intf *netcp,
 	if (addr)
 		ether_addr_copy(naddr->addr, addr);
 	else
-		memset(naddr->addr, 0, ETH_ALEN);
+		eth_zero_addr(naddr->addr);
 	list_add_tail(&naddr->node, &netcp->addr_list);
 
 	return naddr;
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index 0a7f2e7..13214a6 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1167,7 +1167,7 @@ static int gelic_wl_set_ap(struct net_device *netdev,
 	} else {
 		pr_debug("%s: clear bssid\n", __func__);
 		clear_bit(GELIC_WL_STAT_BSSID_SET, &wl->stat);
-		memset(wl->bssid, 0, ETH_ALEN);
+		eth_zero_addr(wl->bssid);
 	}
 	spin_unlock_irqrestore(&wl->lock, irqflag);
 	pr_debug("%s: ->\n", __func__);
@@ -1189,7 +1189,7 @@ static int gelic_wl_get_ap(struct net_device *netdev,
 		memcpy(data->ap_addr.sa_data, wl->active_bssid,
 		       ETH_ALEN);
 	} else
-		memset(data->ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(data->ap_addr.sa_data);
 
 	spin_unlock_irqrestore(&wl->lock, irqflag);
 	mutex_unlock(&wl->assoc_stat_lock);
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index f7e0f0f..44ff8d7 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -954,7 +954,7 @@ static void eth_set_mcast_list(struct net_device *dev)
 		return;
 	}
 
-	memset(diffs, 0, ETH_ALEN);
+	eth_zero_addr(diffs);
 
 	addr = NULL;
 	netdev_for_each_mc_addr(ha, dev) {
-- 
2.1.2
