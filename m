From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 1/2] net: make ndo_get_stats64 a void function
Date: Fri,  6 Jan 2017 19:12:52 -0800
Message-ID: <20170107031253.2739-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:32862 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932654AbdAGDNE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 22:13:04 -0500
Received: by mail-pf0-f170.google.com with SMTP id d2so97556836pfd.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 19:13:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The network device operation for reading statistics is only called
in one place, and it ignores the return value. Having a structure
return value is potentially confusing because some future driver could
incorrectly assume that the return value was used.

Fix all drivers with ndo_get_stats64 to have a void function.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
v2 - fix a couple of warnings

 drivers/net/bonding/bond_main.c                      | 10 ++++------
 drivers/net/dummy.c                                  |  5 ++---
 drivers/net/ethernet/alacritech/slicoss.c            |  6 ++----
 drivers/net/ethernet/amazon/ena/ena_netdev.c         | 10 ++++------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c             |  6 ++----
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c     |  4 +---
 drivers/net/ethernet/atheros/alx/main.c              |  6 ++----
 drivers/net/ethernet/broadcom/b44.c                  |  5 ++---
 drivers/net/ethernet/broadcom/bnx2.c                 |  5 ++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c            |  6 ++----
 drivers/net/ethernet/broadcom/tg3.c                  |  8 +++-----
 drivers/net/ethernet/brocade/bna/bnad.c              |  6 ++----
 drivers/net/ethernet/calxeda/xgmac.c                 |  5 ++---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c     |  5 ++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |  7 +++----
 drivers/net/ethernet/cisco/enic/enic_main.c          |  8 +++-----
 drivers/net/ethernet/ec_bhf.c                        |  4 +---
 drivers/net/ethernet/emulex/benet/be_main.c          |  5 ++---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c       |  6 ++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.c        |  6 ++----
 drivers/net/ethernet/ibm/ehea/ehea_main.c            |  5 ++---
 drivers/net/ethernet/intel/e1000e/e1000.h            |  4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c           |  5 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c      |  6 ++----
 drivers/net/ethernet/intel/i40e/i40e.h               |  5 ++---
 drivers/net/ethernet/intel/i40e/i40e_main.c          | 18 ++++++------------
 drivers/net/ethernet/intel/igb/igb_main.c            | 10 ++++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |  7 ++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |  6 ++----
 drivers/net/ethernet/marvell/mvneta.c                |  4 +---
 drivers/net/ethernet/marvell/mvpp2.c                 |  4 +---
 drivers/net/ethernet/marvell/sky2.c                  |  6 ++----
 drivers/net/ethernet/mediatek/mtk_eth_soc.c          |  6 ++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c       |  4 +---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c    |  3 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c     |  3 +--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c       |  4 +---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c       |  3 +--
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c     |  9 ++++-----
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |  4 +---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c  |  6 ++----
 drivers/net/ethernet/nvidia/forcedeth.c              |  4 +---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 10 ++++------
 drivers/net/ethernet/qlogic/qede/qede_main.c         |  7 ++-----
 drivers/net/ethernet/qualcomm/emac/emac.c            |  6 ++----
 drivers/net/ethernet/realtek/8139too.c               |  9 +++------
 drivers/net/ethernet/realtek/r8169.c                 |  4 +---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c      |  8 ++------
 drivers/net/ethernet/sfc/efx.c                       |  6 ++----
 drivers/net/ethernet/sfc/falcon/efx.c                |  6 ++----
 drivers/net/ethernet/sun/niu.c                       |  6 ++----
 drivers/net/ethernet/synopsys/dwc_eth_qos.c          |  4 +---
 drivers/net/ethernet/tile/tilepro.c                  |  4 ++--
 drivers/net/ethernet/via/via-rhine.c                 |  8 +++-----
 drivers/net/fjes/fjes_main.c                         |  7 ++-----
 drivers/net/hyperv/netvsc_drv.c                      |  6 ++----
 drivers/net/ifb.c                                    |  6 ++----
 drivers/net/ipvlan/ipvlan_main.c                     |  5 ++---
 drivers/net/loopback.c                               |  5 ++---
 drivers/net/macsec.c                                 |  8 +++-----
 drivers/net/macvlan.c                                |  5 ++---
 drivers/net/nlmon.c                                  |  4 +---
 drivers/net/ppp/ppp_generic.c                        |  4 +---
 drivers/net/slip/slip.c                              |  3 +--
 drivers/net/team/team.c                              |  3 +--
 drivers/net/tun.c                                    |  3 +--
 drivers/net/veth.c                                   |  6 ++----
 drivers/net/virtio_net.c                             |  6 ++----
 drivers/net/vmxnet3/vmxnet3_ethtool.c                |  4 +---
 drivers/net/vmxnet3/vmxnet3_int.h                    |  4 ++--
 drivers/net/vrf.c                                    |  5 ++---
 drivers/net/xen-netfront.c                           |  6 ++----
 drivers/staging/netlogic/xlr_net.c                   | 10 +---------
 include/linux/netdevice.h                            |  8 ++++----
 include/net/ip_tunnels.h                             |  4 ++--
 net/8021q/vlan_dev.c                                 |  5 ++---
 net/bridge/br_device.c                               |  6 ++----
 net/ipv4/ip_tunnel_core.c                            |  6 ++----
 net/l2tp/l2tp_eth.c                                  |  6 ++----
 net/mac80211/iface.c                                 |  4 +---
 net/openvswitch/vport-internal_dev.c                 |  4 +---
 net/sched/sch_teql.c                                 |  5 ++---
 82 files changed, 166 insertions(+), 309 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8029dd4912b6..36919221b3f0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -211,8 +211,8 @@ static int lacp_fast;
 
 static int bond_init(struct net_device *bond_dev);
 static void bond_uninit(struct net_device *bond_dev);
-static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
-						struct rtnl_link_stats64 *stats);
+static void bond_get_stats(struct net_device *bond_dev,
+			   struct rtnl_link_stats64 *stats);
 static void bond_slave_arr_handler(struct work_struct *work);
 static bool bond_time_in_interval(struct bonding *bond, unsigned long last_act,
 				  int mod);
@@ -3337,8 +3337,8 @@ static void bond_fold_stats(struct rtnl_link_stats64 *_res,
 	}
 }
 
-static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
-						struct rtnl_link_stats64 *stats)
+static void bond_get_stats(struct net_device *bond_dev,
+			   struct rtnl_link_stats64 *stats)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct rtnl_link_stats64 temp;
@@ -3362,8 +3362,6 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 
 	memcpy(&bond->bond_stats, stats, sizeof(*stats));
 	spin_unlock(&bond->stats_lock);
-
-	return stats;
 }
 
 static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd)
diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 6421835f11b7..1f2de4e8207c 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -54,8 +54,8 @@ struct pcpu_dstats {
 	struct u64_stats_sync	syncp;
 };
 
-static struct rtnl_link_stats64 *dummy_get_stats64(struct net_device *dev,
-						   struct rtnl_link_stats64 *stats)
+static void dummy_get_stats64(struct net_device *dev,
+			      struct rtnl_link_stats64 *stats)
 {
 	int i;
 
@@ -73,7 +73,6 @@ static struct rtnl_link_stats64 *dummy_get_stats64(struct net_device *dev,
 		stats->tx_bytes += tbytes;
 		stats->tx_packets += tpackets;
 	}
-	return stats;
 }
 
 static netdev_tx_t dummy_xmit(struct sk_buff *skb, struct net_device *dev)
diff --git a/drivers/net/ethernet/alacritech/slicoss.c b/drivers/net/ethernet/alacritech/slicoss.c
index b21d8aa8d653..15a8096c60df 100644
--- a/drivers/net/ethernet/alacritech/slicoss.c
+++ b/drivers/net/ethernet/alacritech/slicoss.c
@@ -1471,8 +1471,8 @@ static netdev_tx_t slic_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static struct rtnl_link_stats64 *slic_get_stats(struct net_device *dev,
-						struct rtnl_link_stats64 *lst)
+static void slic_get_stats(struct net_device *dev,
+			   struct rtnl_link_stats64 *lst)
 {
 	struct slic_device *sdev = netdev_priv(dev);
 	struct slic_stats *stats = &sdev->stats;
@@ -1489,8 +1489,6 @@ static struct rtnl_link_stats64 *slic_get_stats(struct net_device *dev,
 	SLIC_GET_STATS_COUNTER(lst->rx_crc_errors, stats, rx_crc);
 	SLIC_GET_STATS_COUNTER(lst->rx_fifo_errors, stats, rx_oflow802);
 	SLIC_GET_STATS_COUNTER(lst->tx_carrier_errors, stats, tx_carrier);
-
-	return lst;
 }
 
 static int slic_get_sset_count(struct net_device *dev, int sset)
diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index cc8b13ebfa75..aca95b397393 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2165,19 +2165,19 @@ static void ena_config_debug_area(struct ena_adapter *adapter)
 	ena_com_delete_debug_area(adapter->ena_dev);
 }
 
-static struct rtnl_link_stats64 *ena_get_stats64(struct net_device *netdev,
-						 struct rtnl_link_stats64 *stats)
+static void ena_get_stats64(struct net_device *netdev,
+			    struct rtnl_link_stats64 *stats)
 {
 	struct ena_adapter *adapter = netdev_priv(netdev);
 	struct ena_admin_basic_stats ena_stats;
 	int rc;
 
 	if (!test_bit(ENA_FLAG_DEV_UP, &adapter->flags))
-		return NULL;
+		return;
 
 	rc = ena_com_get_dev_basic_stats(adapter->ena_dev, &ena_stats);
 	if (rc)
-		return NULL;
+		return;
 
 	stats->tx_bytes = ((u64)ena_stats.tx_bytes_high << 32) |
 		ena_stats.tx_bytes_low;
@@ -2204,8 +2204,6 @@ static struct rtnl_link_stats64 *ena_get_stats64(struct net_device *netdev,
 
 	stats->rx_errors = 0;
 	stats->tx_errors = 0;
-
-	return stats;
 }
 
 static const struct net_device_ops ena_netdev_ops = {
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 155190db682d..130de11fa553 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1759,8 +1759,8 @@ static void xgbe_tx_timeout(struct net_device *netdev)
 	schedule_work(&pdata->restart_work);
 }
 
-static struct rtnl_link_stats64 *xgbe_get_stats64(struct net_device *netdev,
-						  struct rtnl_link_stats64 *s)
+static void xgbe_get_stats64(struct net_device *netdev,
+			     struct rtnl_link_stats64 *s)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	struct xgbe_mmc_stats *pstats = &pdata->mmc_stats;
@@ -1786,8 +1786,6 @@ static struct rtnl_link_stats64 *xgbe_get_stats64(struct net_device *netdev,
 	s->tx_dropped = netdev->stats.tx_dropped;
 
 	DBGPR("<--%s\n", __func__);
-
-	return s;
 }
 
 static int xgbe_vlan_rx_add_vid(struct net_device *netdev, __be16 proto,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 523b8eff6d7b..45f2204e6695 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1453,7 +1453,7 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	return ret;
 }
 
-static struct rtnl_link_stats64 *xgene_enet_get_stats64(
+static void xgene_enet_get_stats64(
 			struct net_device *ndev,
 			struct rtnl_link_stats64 *storage)
 {
@@ -1484,8 +1484,6 @@ static struct rtnl_link_stats64 *xgene_enet_get_stats64(
 		}
 	}
 	memcpy(storage, stats, sizeof(struct rtnl_link_stats64));
-
-	return storage;
 }
 
 static int xgene_enet_set_mac_address(struct net_device *ndev, void *addr)
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c8f525574d68..c66195d00ed4 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1643,8 +1643,8 @@ static void alx_poll_controller(struct net_device *netdev)
 }
 #endif
 
-static struct rtnl_link_stats64 *alx_get_stats64(struct net_device *dev,
-					struct rtnl_link_stats64 *net_stats)
+static void alx_get_stats64(struct net_device *dev,
+			    struct rtnl_link_stats64 *net_stats)
 {
 	struct alx_priv *alx = netdev_priv(dev);
 	struct alx_hw_stats *hw_stats = &alx->hw.stats;
@@ -1688,8 +1688,6 @@ static struct rtnl_link_stats64 *alx_get_stats64(struct net_device *dev,
 	net_stats->rx_packets = hw_stats->rx_ok + net_stats->rx_errors;
 
 	spin_unlock(&alx->stats_lock);
-
-	return net_stats;
 }
 
 static const struct net_device_ops alx_netdev_ops = {
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 48707ed76ffc..7aef70f7d8ef 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1674,8 +1674,8 @@ static int b44_close(struct net_device *dev)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *b44_get_stats64(struct net_device *dev,
-					struct rtnl_link_stats64 *nstat)
+static void b44_get_stats64(struct net_device *dev,
+			    struct rtnl_link_stats64 *nstat)
 {
 	struct b44 *bp = netdev_priv(dev);
 	struct b44_hw_stats *hwstat = &bp->hw_stats;
@@ -1718,7 +1718,6 @@ static struct rtnl_link_stats64 *b44_get_stats64(struct net_device *dev,
 #endif
 	} while (u64_stats_fetch_retry_irq(&hwstat->syncp, start));
 
-	return nstat;
 }
 
 static int __b44_load_mcast(struct b44 *bp, struct net_device *dev)
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index d5d1026be4b7..de1d07c08495 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6821,13 +6821,13 @@ bnx2_save_stats(struct bnx2 *bp)
 	(unsigned long) (bp->stats_blk->ctr +			\
 			 bp->temp_stats_blk->ctr)
 
-static struct rtnl_link_stats64 *
+static void
 bnx2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
 	if (bp->stats_blk == NULL)
-		return net_stats;
+		return;
 
 	net_stats->rx_packets =
 		GET_64BIT_NET_STATS(stat_IfHCInUcastPkts) +
@@ -6891,7 +6891,6 @@ bnx2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		GET_32BIT_NET_STATS(stat_IfInMBUFDiscards) +
 		GET_32BIT_NET_STATS(stat_FwRxDrop);
 
-	return net_stats;
 }
 
 /* All ethtool functions called with rtnl_lock */
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 98e948489700..e5f458396e1a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5879,7 +5879,7 @@ static int bnxt_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EOPNOTSUPP;
 }
 
-static struct rtnl_link_stats64 *
+static void
 bnxt_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	u32 i;
@@ -5888,7 +5888,7 @@ bnxt_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	memset(stats, 0, sizeof(struct rtnl_link_stats64));
 
 	if (!bp->bnapi)
-		return stats;
+		return;
 
 	/* TODO check if we need to synchronize with bnxt_close path */
 	for (i = 0; i < bp->cp_nr_rings; i++) {
@@ -5935,8 +5935,6 @@ bnxt_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->tx_fifo_errors = le64_to_cpu(tx->tx_fifo_underruns);
 		stats->tx_errors = le64_to_cpu(tx->tx_err);
 	}
-
-	return stats;
 }
 
 static bool bnxt_mc_list_updated(struct bnxt *bp, u32 *rx_mask)
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 185e9e047aa9..800328f562fa 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -14142,8 +14142,8 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_link_ksettings	= tg3_set_link_ksettings,
 };
 
-static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
-						struct rtnl_link_stats64 *stats)
+static void tg3_get_stats64(struct net_device *dev,
+			    struct rtnl_link_stats64 *stats)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
@@ -14151,13 +14151,11 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
 	if (!tp->hw_stats) {
 		*stats = tp->net_stats_prev;
 		spin_unlock_bh(&tp->lock);
-		return stats;
+		return;
 	}
 
 	tg3_get_nstats(tp, stats);
 	spin_unlock_bh(&tp->lock);
-
-	return stats;
 }
 
 static void tg3_set_rx_mode(struct net_device *dev)
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 112030828c4b..73a94113db1f 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3111,7 +3111,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
  * Used spin_lock to synchronize reading of stats structures, which
  * is written by BNA under the same lock.
  */
-static struct rtnl_link_stats64 *
+static void
 bnad_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
 	struct bnad *bnad = netdev_priv(netdev);
@@ -3123,8 +3123,6 @@ bnad_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 	bnad_netdev_hwstats_fill(bnad, stats);
 
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-
-	return stats;
 }
 
 static void
@@ -3427,7 +3425,7 @@ static const struct net_device_ops bnad_netdev_ops = {
 	.ndo_open		= bnad_open,
 	.ndo_stop		= bnad_stop,
 	.ndo_start_xmit		= bnad_start_xmit,
-	.ndo_get_stats64		= bnad_get_stats64,
+	.ndo_get_stats64	= bnad_get_stats64,
 	.ndo_set_rx_mode	= bnad_set_rx_mode,
 	.ndo_validate_addr      = eth_validate_addr,
 	.ndo_set_mac_address    = bnad_set_mac_address,
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index ce7de6f72512..b0540658afad 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1446,9 +1446,9 @@ static void xgmac_poll_controller(struct net_device *dev)
 }
 #endif
 
-static struct rtnl_link_stats64 *
+static void
 xgmac_get_stats64(struct net_device *dev,
-		       struct rtnl_link_stats64 *storage)
+		  struct rtnl_link_stats64 *storage)
 {
 	struct xgmac_priv *priv = netdev_priv(dev);
 	void __iomem *base = priv->base;
@@ -1476,7 +1476,6 @@ xgmac_get_stats64(struct net_device *dev,
 
 	writel(0, base + XGMAC_MMC_CTRL);
 	spin_unlock_bh(&priv->stats_lock);
-	return storage;
 }
 
 static int xgmac_set_mac_address(struct net_device *dev, void *p)
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 2006f58b14b1..273eafdb1c57 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1461,8 +1461,8 @@ void nicvf_update_stats(struct nicvf *nic)
 		nicvf_update_sq_stats(nic, qidx);
 }
 
-static struct rtnl_link_stats64 *nicvf_get_stats64(struct net_device *netdev,
-					    struct rtnl_link_stats64 *stats)
+static void nicvf_get_stats64(struct net_device *netdev,
+			      struct rtnl_link_stats64 *stats)
 {
 	struct nicvf *nic = netdev_priv(netdev);
 	struct nicvf_hw_stats *hw_stats = &nic->hw_stats;
@@ -1478,7 +1478,6 @@ static struct rtnl_link_stats64 *nicvf_get_stats64(struct net_device *netdev,
 	stats->tx_packets = hw_stats->tx_frames;
 	stats->tx_dropped = hw_stats->tx_drops;
 
-	return stats;
 }
 
 static void nicvf_tx_timeout(struct net_device *dev)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6f951877430b..fc7d6cf41ee4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2369,8 +2369,8 @@ int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
 }
 EXPORT_SYMBOL(cxgb4_remove_server_filter);
 
-static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
-						struct rtnl_link_stats64 *ns)
+static void cxgb_get_stats(struct net_device *dev,
+			   struct rtnl_link_stats64 *ns)
 {
 	struct port_stats stats;
 	struct port_info *p = netdev_priv(dev);
@@ -2383,7 +2383,7 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
 	spin_lock(&adapter->stats_lock);
 	if (!netif_device_present(dev)) {
 		spin_unlock(&adapter->stats_lock);
-		return ns;
+		return;
 	}
 	t4_get_port_stats_offset(adapter, p->tx_chan, &stats,
 				 &p->stats_base);
@@ -2417,7 +2417,6 @@ static struct rtnl_link_stats64 *cxgb_get_stats(struct net_device *dev,
 	ns->tx_errors = stats.tx_error_frames;
 	ns->rx_errors = stats.rx_symbol_err + stats.rx_fcs_err +
 		ns->rx_length_errors + stats.rx_len_err + ns->rx_fifo_errors;
-	return ns;
 }
 
 static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index cdd7a1a59aa7..c5842c525eed 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -680,8 +680,8 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 }
 
 /* dev_base_lock rwlock held, nominally process context */
-static struct rtnl_link_stats64 *enic_get_stats(struct net_device *netdev,
-						struct rtnl_link_stats64 *net_stats)
+static void enic_get_stats(struct net_device *netdev,
+			   struct rtnl_link_stats64 *net_stats)
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_stats *stats;
@@ -693,7 +693,7 @@ static struct rtnl_link_stats64 *enic_get_stats(struct net_device *netdev,
 	 * recorded stats.
 	 */
 	if (err == -ENOMEM)
-		return net_stats;
+		return;
 
 	net_stats->tx_packets = stats->tx.tx_frames_ok;
 	net_stats->tx_bytes = stats->tx.tx_bytes_ok;
@@ -707,8 +707,6 @@ static struct rtnl_link_stats64 *enic_get_stats(struct net_device *netdev,
 	net_stats->rx_over_errors = enic->rq_truncated_pkts;
 	net_stats->rx_crc_errors = enic->rq_bad_fcs;
 	net_stats->rx_dropped = stats->rx.rx_no_bufs + stats->rx.rx_drop;
-
-	return net_stats;
 }
 
 static int enic_mc_sync(struct net_device *netdev, const u8 *mc_addr)
diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index 7bf78a0d322c..278f139f2a22 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -457,7 +457,7 @@ static int ec_bhf_stop(struct net_device *net_dev)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *
+static void
 ec_bhf_get_stats(struct net_device *net_dev,
 		 struct rtnl_link_stats64 *stats)
 {
@@ -472,8 +472,6 @@ ec_bhf_get_stats(struct net_device *net_dev,
 
 	stats->tx_bytes = priv->stat_tx_bytes;
 	stats->rx_bytes = priv->stat_rx_bytes;
-
-	return stats;
 }
 
 static const struct net_device_ops ec_bhf_netdev_ops = {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 225e9a4877d7..0a679d2eaeee 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -639,8 +639,8 @@ void be_parse_stats(struct be_adapter *adapter)
 	}
 }
 
-static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
-						struct rtnl_link_stats64 *stats)
+static void be_get_stats64(struct net_device *netdev,
+			   struct rtnl_link_stats64 *stats)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 	struct be_drv_stats *drvs = &adapter->drv_stats;
@@ -704,7 +704,6 @@ static struct rtnl_link_stats64 *be_get_stats64(struct net_device *netdev,
 	stats->rx_fifo_errors = drvs->rxpp_fifo_overflow_drop +
 				drvs->rx_input_fifo_overflow_drop +
 				drvs->rx_drops_no_pbuf;
-	return stats;
 }
 
 void be_link_status_update(struct be_adapter *adapter, u8 link_status)
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index c9b7ad65e563..b7cbc26a0911 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -313,8 +313,8 @@ static void dpaa_tx_timeout(struct net_device *net_dev)
 /* Calculates the statistics for the given device by adding the statistics
  * collected by each CPU.
  */
-static struct rtnl_link_stats64 *dpaa_get_stats64(struct net_device *net_dev,
-						  struct rtnl_link_stats64 *s)
+static void dpaa_get_stats64(struct net_device *net_dev,
+			     struct rtnl_link_stats64 *s)
 {
 	int numstats = sizeof(struct rtnl_link_stats64) / sizeof(u64);
 	struct dpaa_priv *priv = netdev_priv(net_dev);
@@ -332,8 +332,6 @@ static struct rtnl_link_stats64 *dpaa_get_stats64(struct net_device *net_dev,
 		for (j = 0; j < numstats; j++)
 			netstats[j] += cpustats[j];
 	}
-
-	return s;
 }
 
 static struct mac_device *dpaa_mac_dev_get(struct platform_device *pdev)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 672b64606321..b7cb61385ad8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1625,8 +1625,8 @@ void hns_nic_set_rx_mode(struct net_device *ndev)
 		netdev_err(ndev, "sync uc address fail\n");
 }
 
-struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
-					      struct rtnl_link_stats64 *stats)
+static void hns_nic_get_stats64(struct net_device *ndev,
+				struct rtnl_link_stats64 *stats)
 {
 	int idx = 0;
 	u64 tx_bytes = 0;
@@ -1668,8 +1668,6 @@ struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
 	stats->tx_window_errors = ndev->stats.tx_window_errors;
 	stats->rx_compressed = ndev->stats.rx_compressed;
 	stats->tx_compressed = ndev->stats.tx_compressed;
-
-	return stats;
 }
 
 static u16
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 702446a93697..1e53d7a82675 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -328,8 +328,8 @@ static void ehea_update_bcmc_registrations(void)
 	spin_unlock_irqrestore(&ehea_bcmc_regs.lock, flags);
 }
 
-static struct rtnl_link_stats64 *ehea_get_stats64(struct net_device *dev,
-					struct rtnl_link_stats64 *stats)
+static void ehea_get_stats64(struct net_device *dev,
+			     struct rtnl_link_stats64 *stats)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	u64 rx_packets = 0, tx_packets = 0, rx_bytes = 0, tx_bytes = 0;
@@ -352,7 +352,6 @@ static struct rtnl_link_stats64 *ehea_get_stats64(struct net_device *dev,
 
 	stats->multicast = port->stats.multicast;
 	stats->rx_errors = port->stats.rx_errors;
-	return stats;
 }
 
 static void ehea_update_stats(struct work_struct *work)
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 879cca47b021..a29b12e80855 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -493,8 +493,8 @@ int e1000e_setup_rx_resources(struct e1000_ring *ring);
 int e1000e_setup_tx_resources(struct e1000_ring *ring);
 void e1000e_free_rx_resources(struct e1000_ring *ring);
 void e1000e_free_tx_resources(struct e1000_ring *ring);
-struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
-					     struct rtnl_link_stats64 *stats);
+void e1000e_get_stats64(struct net_device *netdev,
+			struct rtnl_link_stats64 *stats);
 void e1000e_set_interrupt_capability(struct e1000_adapter *adapter);
 void e1000e_reset_interrupt_capability(struct e1000_adapter *adapter);
 void e1000e_get_hw_control(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index eccf1da9356b..bd09e5f79742 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5920,8 +5920,8 @@ static void e1000_reset_task(struct work_struct *work)
  *
  * Returns the address of the device statistics structure.
  **/
-struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
-					     struct rtnl_link_stats64 *stats)
+void e1000e_get_stats64(struct net_device *netdev,
+			struct rtnl_link_stats64 *stats)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -5958,7 +5958,6 @@ struct rtnl_link_stats64 *e1000e_get_stats64(struct net_device *netdev,
 	/* Tx Dropped needs to be maintained elsewhere */
 
 	spin_unlock(&adapter->stats64_lock);
-	return stats;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index bc5ef6eb3dd6..01db688cf539 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1118,8 +1118,8 @@ void fm10k_reset_rx_state(struct fm10k_intfc *interface)
  * Returns 64bit statistics, for use in the ndo_get_stats64 callback. This
  * function replaces fm10k_get_stats for kernels which support it.
  */
-static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
-						   struct rtnl_link_stats64 *stats)
+static void fm10k_get_stats64(struct net_device *netdev,
+			      struct rtnl_link_stats64 *stats)
 {
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_ring *ring;
@@ -1164,8 +1164,6 @@ static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
 
 	/* following stats updated by fm10k_service_task() */
 	stats->rx_missed_errors	= netdev->stats.rx_missed_errors;
-
-	return stats;
 }
 
 int fm10k_setup_tc(struct net_device *dev, u8 tc)
diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ba8d30984bee..342007df4663 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -834,9 +834,8 @@ static inline void i40e_irq_dynamic_enable(struct i40e_vsi *vsi, int vector)
 void i40e_irq_dynamic_disable_icr0(struct i40e_pf *pf);
 void i40e_irq_dynamic_enable_icr0(struct i40e_pf *pf, bool clearpba);
 #ifdef I40E_FCOE
-struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
-					     struct net_device *netdev,
-					     struct rtnl_link_stats64 *storage);
+void i40e_get_netdev_stats_struct(struct net_device *netdev,
+				  struct rtnl_link_stats64 *storage);
 int i40e_set_mac(struct net_device *netdev, void *p);
 void i40e_set_rx_mode(struct net_device *netdev);
 #endif
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ad4cf639430e..b2f76d24000d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -409,15 +409,11 @@ struct rtnl_link_stats64 *i40e_get_vsi_stats_struct(struct i40e_vsi *vsi)
  * Returns the address of the device statistics structure.
  * The statistics are actually updated from the service task.
  **/
-#ifdef I40E_FCOE
-struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
-					     struct net_device *netdev,
-					     struct rtnl_link_stats64 *stats)
-#else
-static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
-					     struct net_device *netdev,
-					     struct rtnl_link_stats64 *stats)
+#ifndef I40E_FCOE
+static
 #endif
+void i40e_get_netdev_stats_struct(struct net_device *netdev,
+				  struct rtnl_link_stats64 *stats)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_ring *tx_ring, *rx_ring;
@@ -426,10 +422,10 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
 	int i;
 
 	if (test_bit(__I40E_DOWN, &vsi->state))
-		return stats;
+		return;
 
 	if (!vsi->tx_rings)
-		return stats;
+		return;
 
 	rcu_read_lock();
 	for (i = 0; i < vsi->num_queue_pairs; i++) {
@@ -469,8 +465,6 @@ static struct rtnl_link_stats64 *i40e_get_netdev_stats_struct(
 	stats->rx_dropped	= vsi_stats->rx_dropped;
 	stats->rx_crc_errors	= vsi_stats->rx_crc_errors;
 	stats->rx_length_errors	= vsi_stats->rx_length_errors;
-
-	return stats;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a761001308dc..a2058c2b317a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -137,8 +137,8 @@ static void igb_update_phy_info(unsigned long);
 static void igb_watchdog(unsigned long);
 static void igb_watchdog_task(struct work_struct *);
 static netdev_tx_t igb_xmit_frame(struct sk_buff *skb, struct net_device *);
-static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *dev,
-					  struct rtnl_link_stats64 *stats);
+static void igb_get_stats64(struct net_device *dev,
+			    struct rtnl_link_stats64 *stats);
 static int igb_change_mtu(struct net_device *, int);
 static int igb_set_mac(struct net_device *, void *);
 static void igb_set_uta(struct igb_adapter *adapter, bool set);
@@ -5402,8 +5402,8 @@ static void igb_reset_task(struct work_struct *work)
  *  @netdev: network interface device structure
  *  @stats: rtnl_link_stats64 pointer
  **/
-static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *netdev,
-						struct rtnl_link_stats64 *stats)
+static void igb_get_stats64(struct net_device *netdev,
+			    struct rtnl_link_stats64 *stats)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
@@ -5411,8 +5411,6 @@ static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *netdev,
 	igb_update_stats(adapter, &adapter->stats64);
 	memcpy(stats, &adapter->stats64, sizeof(*stats));
 	spin_unlock(&adapter->stats64_lock);
-
-	return stats;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0c6eca570791..ffe7d940d9ff 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8173,8 +8173,9 @@ static void ixgbe_netpoll(struct net_device *netdev)
 }
 
 #endif
-static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
-						   struct rtnl_link_stats64 *stats)
+
+static void ixgbe_get_stats64(struct net_device *netdev,
+			      struct rtnl_link_stats64 *stats)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int i;
@@ -8212,13 +8213,13 @@ static struct rtnl_link_stats64 *ixgbe_get_stats64(struct net_device *netdev,
 		}
 	}
 	rcu_read_unlock();
+
 	/* following stats updated by ixgbe_watchdog_task() */
 	stats->multicast	= netdev->stats.multicast;
 	stats->rx_errors	= netdev->stats.rx_errors;
 	stats->rx_length_errors	= netdev->stats.rx_length_errors;
 	stats->rx_crc_errors	= netdev->stats.rx_crc_errors;
 	stats->rx_missed_errors	= netdev->stats.rx_missed_errors;
-	return stats;
 }
 
 #ifdef CONFIG_IXGBE_DCB
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1a28349114f8..b06863560c7d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3896,8 +3896,8 @@ static void ixgbevf_shutdown(struct pci_dev *pdev)
 	ixgbevf_suspend(pdev, PMSG_SUSPEND);
 }
 
-static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
-						struct rtnl_link_stats64 *stats)
+static void ixgbevf_get_stats(struct net_device *netdev,
+			      struct rtnl_link_stats64 *stats)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	unsigned int start;
@@ -3930,8 +3930,6 @@ static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
 		stats->tx_bytes += bytes;
 		stats->tx_packets += packets;
 	}
-
-	return stats;
 }
 
 #define IXGBEVF_MAX_MAC_HDR_LEN		127
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e05e22705cf7..3607d8febbcf 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -652,7 +652,7 @@ static void mvneta_mib_counters_clear(struct mvneta_port *pp)
 }
 
 /* Get System Network Statistics */
-static struct rtnl_link_stats64 *
+static void
 mvneta_get_stats64(struct net_device *dev,
 		   struct rtnl_link_stats64 *stats)
 {
@@ -686,8 +686,6 @@ mvneta_get_stats64(struct net_device *dev,
 	stats->rx_dropped	= dev->stats.rx_dropped;
 
 	stats->tx_dropped	= dev->stats.tx_dropped;
-
-	return stats;
 }
 
 /* Rx descriptors helper methods */
diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4fe430ceb194..69db40e1a4e1 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5739,7 +5739,7 @@ static int mvpp2_change_mtu(struct net_device *dev, int mtu)
 	return err;
 }
 
-static struct rtnl_link_stats64 *
+static void
 mvpp2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mvpp2_port *port = netdev_priv(dev);
@@ -5771,8 +5771,6 @@ mvpp2_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->rx_errors	= dev->stats.rx_errors;
 	stats->rx_dropped	= dev->stats.rx_dropped;
 	stats->tx_dropped	= dev->stats.tx_dropped;
-
-	return stats;
 }
 
 static int mvpp2_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index b60ad0e56a9f..18d6336fa162 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3888,8 +3888,8 @@ static void sky2_set_multicast(struct net_device *dev)
 	gma_write16(hw, port, GM_RX_CTRL, reg);
 }
 
-static struct rtnl_link_stats64 *sky2_get_stats(struct net_device *dev,
-						struct rtnl_link_stats64 *stats)
+static void sky2_get_stats(struct net_device *dev,
+			   struct rtnl_link_stats64 *stats)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
@@ -3929,8 +3929,6 @@ static struct rtnl_link_stats64 *sky2_get_stats(struct net_device *dev,
 	stats->rx_dropped = dev->stats.rx_dropped;
 	stats->rx_fifo_errors = dev->stats.rx_fifo_errors;
 	stats->tx_fifo_errors = dev->stats.tx_fifo_errors;
-
-	return stats;
 }
 
 /* Can have one global because blinking is controlled by
diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 3dd87889e67e..25ae0c5bce3a 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -462,8 +462,8 @@ static void mtk_stats_update(struct mtk_eth *eth)
 	}
 }
 
-static struct rtnl_link_stats64 *mtk_get_stats64(struct net_device *dev,
-					struct rtnl_link_stats64 *storage)
+static void mtk_get_stats64(struct net_device *dev,
+			    struct rtnl_link_stats64 *storage)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
 	struct mtk_hw_stats *hw_stats = mac->hw_stats;
@@ -494,8 +494,6 @@ static struct rtnl_link_stats64 *mtk_get_stats64(struct net_device *dev,
 	storage->tx_errors = dev->stats.tx_errors;
 	storage->rx_dropped = dev->stats.rx_dropped;
 	storage->tx_dropped = dev->stats.tx_dropped;
-
-	return storage;
 }
 
 static inline int mtk_max_frag_size(int mtu)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index edbe200ac2fa..06ef23f040a4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1321,7 +1321,7 @@ static void mlx4_en_tx_timeout(struct net_device *dev)
 }
 
 
-static struct rtnl_link_stats64 *
+static void
 mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -1330,8 +1330,6 @@ mlx4_en_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	mlx4_en_fold_software_stats(dev);
 	netdev_stats_to_stats64(stats, &dev->stats);
 	spin_unlock_bh(&priv->stats_lock);
-
-	return stats;
 }
 
 static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 88dd731bb8cb..60e5670452a1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -2686,7 +2686,7 @@ static int mlx5e_ndo_setup_tc(struct net_device *dev, u32 handle,
 	return mlx5e_setup_tc(dev, tc->tc);
 }
 
-static struct rtnl_link_stats64 *
+static void
 mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -2729,7 +2729,6 @@ mlx5e_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->multicast =
 		VPORT_COUNTER_GET(vstats, received_eth_multicast.packets);
 
-	return stats;
 }
 
 static void mlx5e_set_rx_mode(struct net_device *dev)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 850378893b25..2c864574a9d5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -374,13 +374,12 @@ int mlx5e_get_offload_stats(int attr_id, const struct net_device *dev,
 	return -EINVAL;
 }
 
-static struct rtnl_link_stats64 *
+static void
 mlx5e_rep_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
 	memcpy(stats, &priv->stats.vf_vport, sizeof(*stats));
-	return stats;
 }
 
 static const struct switchdev_ops mlx5e_rep_switchdev_ops = {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index d768c7b6c6d6..46c53a042e6b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -947,15 +947,13 @@ static void update_stats_cache(struct work_struct *work)
 /* Return the stats from a cache that is updated periodically,
  * as this function might get called in an atomic context.
  */
-static struct rtnl_link_stats64 *
+static void
 mlxsw_sp_port_get_stats64(struct net_device *dev,
 			  struct rtnl_link_stats64 *stats)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
 
 	memcpy(stats, mlxsw_sp_port->hw_stats.cache, sizeof(*stats));
-
-	return stats;
 }
 
 int mlxsw_sp_port_vlan_set(struct mlxsw_sp_port *mlxsw_sp_port, u16 vid_begin,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 150ccf5192a9..696d40612d28 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -381,7 +381,7 @@ static int mlxsw_sx_port_change_mtu(struct net_device *dev, int mtu)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *
+static void
 mlxsw_sx_port_get_stats64(struct net_device *dev,
 			  struct rtnl_link_stats64 *stats)
 {
@@ -410,7 +410,6 @@ mlxsw_sx_port_get_stats64(struct net_device *dev,
 		tx_dropped	+= p->tx_dropped;
 	}
 	stats->tx_dropped	= tx_dropped;
-	return stats;
 }
 
 static int mlxsw_sx_port_get_phys_port_name(struct net_device *dev, char *name,
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index e506ca876d0d..db297cfce6f4 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -378,8 +378,8 @@ static inline void put_be32(__be32 val, __be32 __iomem * p)
 	__raw_writel((__force __u32) val, (__force void __iomem *)p);
 }
 
-static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_device *dev,
-						    struct rtnl_link_stats64 *stats);
+static void myri10ge_get_stats(struct net_device *dev,
+			       struct rtnl_link_stats64 *stats);
 
 static void set_fw_name(struct myri10ge_priv *mgp, char *name, bool allocated)
 {
@@ -3119,8 +3119,8 @@ static netdev_tx_t myri10ge_sw_tso(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_device *dev,
-						    struct rtnl_link_stats64 *stats)
+static void myri10ge_get_stats(struct net_device *dev,
+			       struct rtnl_link_stats64 *stats)
 {
 	const struct myri10ge_priv *mgp = netdev_priv(dev);
 	const struct myri10ge_slice_netstats *slice_stats;
@@ -3135,7 +3135,6 @@ static struct rtnl_link_stats64 *myri10ge_get_stats(struct net_device *dev,
 		stats->rx_dropped += slice_stats->rx_dropped;
 		stats->tx_dropped += slice_stats->tx_dropped;
 	}
-	return stats;
 }
 
 static void myri10ge_set_multicast_list(struct net_device *dev)
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index e07b936f64ec..f364502229db 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -3111,7 +3111,7 @@ static int vxge_change_mtu(struct net_device *dev, int new_mtu)
  * @stats: pointer to struct rtnl_link_stats64
  *
  */
-static struct rtnl_link_stats64 *
+static void
 vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 {
 	struct vxgedev *vdev = netdev_priv(dev);
@@ -3150,8 +3150,6 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		net_stats->tx_bytes += bytes;
 		net_stats->tx_errors += txstats->tx_errors;
 	}
-
-	return net_stats;
 }
 
 static enum vxge_hw_status vxge_timestamp_config(struct __vxge_hw_device *devh)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index e8d448109e03..67afd95ffb93 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2638,8 +2638,8 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	return nfp_net_ring_reconfig(nn, &nn->xdp_prog, &rx, NULL);
 }
 
-static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
-						struct rtnl_link_stats64 *stats)
+static void nfp_net_stat64(struct net_device *netdev,
+			   struct rtnl_link_stats64 *stats)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	int r;
@@ -2669,8 +2669,6 @@ static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
 		stats->tx_bytes += data[1];
 		stats->tx_errors += data[2];
 	}
-
-	return stats;
 }
 
 static bool nfp_net_ebpf_capable(struct nfp_net *nn)
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 3913f07279d2..dfc2c8149d22 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1733,7 +1733,7 @@ static void nv_update_stats(struct net_device *dev)
  * Called with read_lock(&dev_base_lock) held for read -
  * only synchronized against unregister_netdevice.
  */
-static struct rtnl_link_stats64*
+static void
 nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 	__acquires(&netdev_priv(dev)->hwstats_lock)
 	__releases(&netdev_priv(dev)->hwstats_lock)
@@ -1793,8 +1793,6 @@ nv_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *storage)
 
 		spin_unlock_bh(&np->hwstats_lock);
 	}
-
-	return storage;
 }
 
 /*
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 561fb94c7267..86fb9d3df700 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -90,8 +90,8 @@ static irqreturn_t netxen_msix_intr(int irq, void *data);
 
 static void netxen_free_ip_list(struct netxen_adapter *, bool);
 static void netxen_restore_indev_addr(struct net_device *dev, unsigned long);
-static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *dev,
-						      struct rtnl_link_stats64 *stats);
+static void netxen_nic_get_stats(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats);
 static int netxen_nic_set_mac(struct net_device *netdev, void *p);
 
 /*  PCI Device ID Table  */
@@ -2302,8 +2302,8 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
-static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *netdev,
-						      struct rtnl_link_stats64 *stats)
+static void netxen_nic_get_stats(struct net_device *netdev,
+				 struct rtnl_link_stats64 *stats)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 
@@ -2313,8 +2313,6 @@ static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *netdev,
 	stats->tx_bytes = adapter->stats.txbytes;
 	stats->rx_dropped = adapter->stats.rxdropped;
 	stats->tx_dropped = adapter->stats.txdropped;
-
-	return stats;
 }
 
 static irqreturn_t netxen_intr(int irq, void *data)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index b58509feecd5..40a76a1d5973 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -398,9 +398,8 @@ void qede_fill_by_demand_stats(struct qede_dev *edev)
 	edev->stats.tx_mac_ctrl_frames = stats.tx_mac_ctrl_frames;
 }
 
-static
-struct rtnl_link_stats64 *qede_get_stats64(struct net_device *dev,
-					   struct rtnl_link_stats64 *stats)
+static void qede_get_stats64(struct net_device *dev,
+			     struct rtnl_link_stats64 *stats)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 
@@ -430,8 +429,6 @@ struct rtnl_link_stats64 *qede_get_stats64(struct net_device *dev,
 	stats->collisions = edev->stats.tx_total_collisions;
 	stats->rx_crc_errors = edev->stats.rx_crc_errors;
 	stats->rx_frame_errors = edev->stats.rx_align_errors;
-
-	return stats;
 }
 
 #ifdef CONFIG_QED_SRIOV
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 422289c232bc..40ebe010b06f 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -312,8 +312,8 @@ static int emac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 }
 
 /* Provide network statistics info for the interface */
-static struct rtnl_link_stats64 *emac_get_stats64(struct net_device *netdev,
-						  struct rtnl_link_stats64 *net_stats)
+static void emac_get_stats64(struct net_device *netdev,
+			     struct rtnl_link_stats64 *net_stats)
 {
 	struct emac_adapter *adpt = netdev_priv(netdev);
 	unsigned int addr = REG_MAC_RX_STATUS_BIN;
@@ -377,8 +377,6 @@ static struct rtnl_link_stats64 *emac_get_stats64(struct net_device *netdev,
 	net_stats->tx_window_errors = stats->tx_late_col;
 
 	spin_unlock(&stats->lock);
-
-	return net_stats;
 }
 
 static const struct net_device_ops emac_netdev_ops = {
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 9bc047ac883b..5ad59c6d29a4 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -653,9 +653,8 @@ static int rtl8139_poll(struct napi_struct *napi, int budget);
 static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance);
 static int rtl8139_close (struct net_device *dev);
 static int netdev_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
-static struct rtnl_link_stats64 *rtl8139_get_stats64(struct net_device *dev,
-						    struct rtnl_link_stats64
-						    *stats);
+static void rtl8139_get_stats64(struct net_device *dev,
+				struct rtnl_link_stats64 *stats);
 static void rtl8139_set_rx_mode (struct net_device *dev);
 static void __set_rx_mode (struct net_device *dev);
 static void rtl8139_hw_start (struct net_device *dev);
@@ -2516,7 +2515,7 @@ static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 }
 
 
-static struct rtnl_link_stats64 *
+static void
 rtl8139_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8139_private *tp = netdev_priv(dev);
@@ -2544,8 +2543,6 @@ rtl8139_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->tx_packets = tp->tx_stats.packets;
 		stats->tx_bytes = tp->tx_stats.bytes;
 	} while (u64_stats_fetch_retry_irq(&tp->tx_stats.syncp, start));
-
-	return stats;
 }
 
 /* Set or clear the multicast filter for this adaptor.
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 44389c90056a..858f4554de11 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7755,7 +7755,7 @@ static int rtl_open(struct net_device *dev)
 	goto out;
 }
 
-static struct rtnl_link_stats64 *
+static void
 rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -7809,8 +7809,6 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		le16_to_cpu(tp->tc_offset.tx_aborted);
 
 	pm_runtime_put_noidle(&pdev->dev);
-
-	return stats;
 }
 
 static void rtl8169_net_suspend(struct net_device *dev)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index cddcff5a00a7..07074d9bc45d 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1706,11 +1706,9 @@ static inline u64 sxgbe_get_stat64(void __iomem *ioaddr, int reg_lo, int reg_hi)
  *  This function is a driver entry point whenever ifconfig command gets
  *  executed to see device statistics. Statistics are number of
  *  bytes sent or received, errors occurred etc.
- *  Return value:
- *  This function returns various statistical information of device.
  */
-static struct rtnl_link_stats64 *sxgbe_get_stats64(struct net_device *dev,
-						   struct rtnl_link_stats64 *stats)
+static void sxgbe_get_stats64(struct net_device *dev,
+			      struct rtnl_link_stats64 *stats)
 {
 	struct sxgbe_priv_data *priv = netdev_priv(dev);
 	void __iomem *ioaddr = priv->ioaddr;
@@ -1761,8 +1759,6 @@ static struct rtnl_link_stats64 *sxgbe_get_stats64(struct net_device *dev,
 						 SXGBE_MMC_TXUFLWHI_GBCNT_REG);
 	writel(0, ioaddr + SXGBE_MMC_CTL_REG);
 	spin_unlock(&priv->stats_lock);
-
-	return stats;
 }
 
 /*  sxgbe_set_features - entry point to set offload features of the device.
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index bbbed2e84de8..ebeecb8fed45 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2219,16 +2219,14 @@ int efx_net_stop(struct net_device *net_dev)
 }
 
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
-static struct rtnl_link_stats64 *efx_net_stats(struct net_device *net_dev,
-					       struct rtnl_link_stats64 *stats)
+static void efx_net_stats(struct net_device *net_dev,
+			  struct rtnl_link_stats64 *stats)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
 	spin_lock_bh(&efx->stats_lock);
 	efx->type->update_stats(efx, NULL, stats);
 	spin_unlock_bh(&efx->stats_lock);
-
-	return stats;
 }
 
 /* Context: netif_tx_lock held, BHs disabled. */
diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index ec3ac0e45cc9..8cfbe01e1ddf 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -2158,16 +2158,14 @@ int ef4_net_stop(struct net_device *net_dev)
 }
 
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
-static struct rtnl_link_stats64 *ef4_net_stats(struct net_device *net_dev,
-					       struct rtnl_link_stats64 *stats)
+static void ef4_net_stats(struct net_device *net_dev,
+			  struct rtnl_link_stats64 *stats)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
 
 	spin_lock_bh(&efx->stats_lock);
 	efx->type->update_stats(efx, NULL, stats);
 	spin_unlock_bh(&efx->stats_lock);
-
-	return stats;
 }
 
 /* Context: netif_tx_lock held, BHs disabled. */
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index f90d1af6d390..e557a3290a25 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -6294,8 +6294,8 @@ static void niu_get_tx_stats(struct niu *np,
 	stats->tx_errors = errors;
 }
 
-static struct rtnl_link_stats64 *niu_get_stats(struct net_device *dev,
-					       struct rtnl_link_stats64 *stats)
+static void niu_get_stats(struct net_device *dev,
+			  struct rtnl_link_stats64 *stats)
 {
 	struct niu *np = netdev_priv(dev);
 
@@ -6303,8 +6303,6 @@ static struct rtnl_link_stats64 *niu_get_stats(struct net_device *dev,
 		niu_get_rx_stats(np, stats);
 		niu_get_tx_stats(np, stats);
 	}
-
-	return stats;
 }
 
 static void niu_load_hash_xmac(struct niu *np, u16 *hash)
diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 09f5a67da35e..467dcc53f5e1 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -2490,7 +2490,7 @@ static void dwceqos_read_mmc_counters(struct net_local *lp, u32 rx_mask,
 			dwceqos_read(lp, DWC_MMC_RXPACKETCOUNT_GB);
 }
 
-static struct rtnl_link_stats64*
+static void
 dwceqos_get_stats64(struct net_device *ndev, struct rtnl_link_stats64 *s)
 {
 	unsigned long flags;
@@ -2522,8 +2522,6 @@ dwceqos_get_stats64(struct net_device *ndev, struct rtnl_link_stats64 *s)
 	else
 		s->tx_errors = hwstats->txunderflowerror +
 			hwstats->txcarriererror;
-
-	return s;
 }
 
 static void
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index 0a3b7dafa3ba..30cfea62a356 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -2047,8 +2047,8 @@ static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
  *
  * Returns the address of the device statistics structure.
  */
-static struct rtnl_link_stats64 *tile_net_get_stats64(struct net_device *dev,
-		struct rtnl_link_stats64 *stats)
+static void tile_net_get_stats64(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats)
 {
 	struct tile_net_priv *priv = netdev_priv(dev);
 	u64 rx_packets = 0, tx_packets = 0;
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 0a6c4e804eed..453a1fad560c 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -513,8 +513,8 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
 static void rhine_tx(struct net_device *dev);
 static int rhine_rx(struct net_device *dev, int limit);
 static void rhine_set_rx_mode(struct net_device *dev);
-static struct rtnl_link_stats64 *rhine_get_stats64(struct net_device *dev,
-	       struct rtnl_link_stats64 *stats);
+static void rhine_get_stats64(struct net_device *dev,
+			      struct rtnl_link_stats64 *stats);
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static const struct ethtool_ops netdev_ethtool_ops;
 static int  rhine_close(struct net_device *dev);
@@ -2221,7 +2221,7 @@ static void rhine_slow_event_task(struct work_struct *work)
 	mutex_unlock(&rp->task_lock);
 }
 
-static struct rtnl_link_stats64 *
+static void
 rhine_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -2244,8 +2244,6 @@ rhine_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->tx_packets = rp->tx_stats.packets;
 		stats->tx_bytes = rp->tx_stats.bytes;
 	} while (u64_stats_fetch_retry_irq(&rp->tx_stats.syncp, start));
-
-	return stats;
 }
 
 static void rhine_set_rx_mode(struct net_device *dev)
diff --git a/drivers/net/fjes/fjes_main.c b/drivers/net/fjes/fjes_main.c
index b77e4ecf3cf2..5028001429c7 100644
--- a/drivers/net/fjes/fjes_main.c
+++ b/drivers/net/fjes/fjes_main.c
@@ -57,8 +57,7 @@ static void fjes_raise_intr_rxdata_task(struct work_struct *);
 static void fjes_tx_stall_task(struct work_struct *);
 static void fjes_force_close_task(struct work_struct *);
 static irqreturn_t fjes_intr(int, void*);
-static struct rtnl_link_stats64 *
-fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
+static void fjes_get_stats64(struct net_device *, struct rtnl_link_stats64 *);
 static int fjes_change_mtu(struct net_device *, int);
 static int fjes_vlan_rx_add_vid(struct net_device *, __be16 proto, u16);
 static int fjes_vlan_rx_kill_vid(struct net_device *, __be16 proto, u16);
@@ -782,14 +781,12 @@ static void fjes_tx_retry(struct net_device *netdev)
 	netif_tx_wake_queue(queue);
 }
 
-static struct rtnl_link_stats64 *
+static void
 fjes_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
 {
 	struct fjes_adapter *adapter = netdev_priv(netdev);
 
 	memcpy(stats, &adapter->stats64, sizeof(struct rtnl_link_stats64));
-
-	return stats;
 }
 
 static int fjes_change_mtu(struct net_device *netdev, int new_mtu)
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c9414c054852..05374fce7da4 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -908,8 +908,8 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	return ret;
 }
 
-static struct rtnl_link_stats64 *netvsc_get_stats64(struct net_device *net,
-						    struct rtnl_link_stats64 *t)
+static void netvsc_get_stats64(struct net_device *net,
+			       struct rtnl_link_stats64 *t)
 {
 	struct net_device_context *ndev_ctx = netdev_priv(net);
 	int cpu;
@@ -947,8 +947,6 @@ static struct rtnl_link_stats64 *netvsc_get_stats64(struct net_device *net,
 
 	t->rx_dropped	= net->stats.rx_dropped;
 	t->rx_errors	= net->stats.rx_errors;
-
-	return t;
 }
 
 static int netvsc_set_mac_addr(struct net_device *ndev, void *p)
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 66c0eeafcb5d..082534e187fc 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -129,8 +129,8 @@ static void ifb_ri_tasklet(unsigned long _txp)
 
 }
 
-static struct rtnl_link_stats64 *ifb_stats64(struct net_device *dev,
-					     struct rtnl_link_stats64 *stats)
+static void ifb_stats64(struct net_device *dev,
+			struct rtnl_link_stats64 *stats)
 {
 	struct ifb_dev_private *dp = netdev_priv(dev);
 	struct ifb_q_private *txp = dp->tx_private;
@@ -157,8 +157,6 @@ static struct rtnl_link_stats64 *ifb_stats64(struct net_device *dev,
 	}
 	stats->rx_dropped = dev->stats.rx_dropped;
 	stats->tx_dropped = dev->stats.tx_dropped;
-
-	return stats;
 }
 
 static int ifb_dev_init(struct net_device *dev)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index ce7ca6a5aa8a..1cdb8c5ec403 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -303,8 +303,8 @@ static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
 	dev_mc_sync(ipvlan->phy_dev, dev);
 }
 
-static struct rtnl_link_stats64 *ipvlan_get_stats64(struct net_device *dev,
-						    struct rtnl_link_stats64 *s)
+static void ipvlan_get_stats64(struct net_device *dev,
+			       struct rtnl_link_stats64 *s)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 
@@ -341,7 +341,6 @@ static struct rtnl_link_stats64 *ipvlan_get_stats64(struct net_device *dev,
 		s->rx_dropped = rx_errs;
 		s->tx_dropped = tx_drps;
 	}
-	return s;
 }
 
 static int ipvlan_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 1e05b7c2d157..30a493936e63 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -97,8 +97,8 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev,
-						      struct rtnl_link_stats64 *stats)
+static void loopback_get_stats64(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats)
 {
 	u64 bytes = 0;
 	u64 packets = 0;
@@ -122,7 +122,6 @@ static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev,
 	stats->tx_packets = packets;
 	stats->rx_bytes   = bytes;
 	stats->tx_bytes   = bytes;
-	return stats;
 }
 
 static u32 always_on(struct net_device *dev)
diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index f83cf6696820..778a77303c49 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2888,13 +2888,13 @@ static int macsec_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *macsec_get_stats64(struct net_device *dev,
-						    struct rtnl_link_stats64 *s)
+static void macsec_get_stats64(struct net_device *dev,
+			       struct rtnl_link_stats64 *s)
 {
 	int cpu;
 
 	if (!dev->tstats)
-		return s;
+		return;
 
 	for_each_possible_cpu(cpu) {
 		struct pcpu_sw_netstats *stats;
@@ -2918,8 +2918,6 @@ static struct rtnl_link_stats64 *macsec_get_stats64(struct net_device *dev,
 
 	s->rx_dropped = dev->stats.rx_dropped;
 	s->tx_dropped = dev->stats.tx_dropped;
-
-	return s;
 }
 
 static int macsec_get_iflink(const struct net_device *dev)
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 20b3fdf282c5..440ab3d8adf7 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -855,8 +855,8 @@ static void macvlan_uninit(struct net_device *dev)
 		macvlan_port_destroy(port->dev);
 }
 
-static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
-							 struct rtnl_link_stats64 *stats)
+static void macvlan_dev_get_stats64(struct net_device *dev,
+				    struct rtnl_link_stats64 *stats)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
 
@@ -893,7 +893,6 @@ static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
 		stats->rx_dropped	= rx_errors;
 		stats->tx_dropped	= tx_dropped;
 	}
-	return stats;
 }
 
 static int macvlan_vlan_rx_add_vid(struct net_device *dev,
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index 2de7faee9b19..b91603835d26 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -58,7 +58,7 @@ static int nlmon_close(struct net_device *dev)
 	return netlink_remove_tap(&nlmon->nt);
 }
 
-static struct rtnl_link_stats64 *
+static void
 nlmon_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	int i;
@@ -86,8 +86,6 @@ nlmon_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 
 	stats->rx_bytes = bytes;
 	stats->tx_bytes = 0;
-
-	return stats;
 }
 
 static u32 always_on(struct net_device *dev)
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 3d3b1f4339ef..a411b43a69eb 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1297,7 +1297,7 @@ ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
-static struct rtnl_link_stats64*
+static void
 ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
 {
 	struct ppp *ppp = netdev_priv(dev);
@@ -1317,8 +1317,6 @@ ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
 	stats64->rx_dropped       = dev->stats.rx_dropped;
 	stats64->tx_dropped       = dev->stats.tx_dropped;
 	stats64->rx_length_errors = dev->stats.rx_length_errors;
-
-	return stats64;
 }
 
 static int ppp_dev_init(struct net_device *dev)
diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index 9841f3dc0682..08db4d687533 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -566,7 +566,7 @@ static int sl_change_mtu(struct net_device *dev, int new_mtu)
 
 /* Netdevice get statistics request */
 
-static struct rtnl_link_stats64 *
+static void
 sl_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct net_device_stats *devstats = &dev->stats;
@@ -597,7 +597,6 @@ sl_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->collisions     += comp->sls_o_misses;
 	}
 #endif
-	return stats;
 }
 
 /* Netdevice register callback */
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index bdc58567d10e..a3711769544b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1798,7 +1798,7 @@ static int team_change_mtu(struct net_device *dev, int new_mtu)
 	return err;
 }
 
-static struct rtnl_link_stats64 *
+static void
 team_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct team *team = netdev_priv(dev);
@@ -1835,7 +1835,6 @@ team_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->rx_dropped	= rx_dropped;
 	stats->tx_dropped	= tx_dropped;
 	stats->rx_nohandler	= rx_nohandler;
-	return stats;
 }
 
 static int team_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index cd8e02c94be0..8c1d3bd6b4d0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -953,7 +953,7 @@ static void tun_set_headroom(struct net_device *dev, int new_hr)
 	tun->align = new_hr;
 }
 
-static struct rtnl_link_stats64 *
+static void
 tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	u32 rx_dropped = 0, tx_dropped = 0, rx_frame_errors = 0;
@@ -987,7 +987,6 @@ tun_net_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->rx_dropped  = rx_dropped;
 	stats->rx_frame_errors = rx_frame_errors;
 	stats->tx_dropped = tx_dropped;
-	return stats;
 }
 
 static const struct net_device_ops tun_netdev_ops = {
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0520952aa096..8c39d6d690e5 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -158,8 +158,8 @@ static u64 veth_stats_one(struct pcpu_vstats *result, struct net_device *dev)
 	return atomic64_read(&priv->dropped);
 }
 
-static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
-						  struct rtnl_link_stats64 *tot)
+static void veth_get_stats64(struct net_device *dev,
+			     struct rtnl_link_stats64 *tot)
 {
 	struct veth_priv *priv = netdev_priv(dev);
 	struct net_device *peer;
@@ -177,8 +177,6 @@ static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
 		tot->rx_packets = one.packets;
 	}
 	rcu_read_unlock();
-
-	return tot;
 }
 
 /* fake multicast ability */
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2cea022e6e6e..37db91d1a0a3 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1272,8 +1272,8 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 	return ret;
 }
 
-static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
-					       struct rtnl_link_stats64 *tot)
+static void virtnet_stats(struct net_device *dev,
+			  struct rtnl_link_stats64 *tot)
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	int cpu;
@@ -1306,8 +1306,6 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 	tot->rx_dropped = dev->stats.rx_dropped;
 	tot->rx_length_errors = dev->stats.rx_length_errors;
 	tot->rx_frame_errors = dev->stats.rx_frame_errors;
-
-	return tot;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index aabc6ef366b4..f88ffafebfbf 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -113,7 +113,7 @@ vmxnet3_global_stats[] = {
 };
 
 
-struct rtnl_link_stats64 *
+void
 vmxnet3_get_stats64(struct net_device *netdev,
 		   struct rtnl_link_stats64 *stats)
 {
@@ -160,8 +160,6 @@ vmxnet3_get_stats64(struct net_device *netdev,
 		stats->rx_dropped += drvRxStats->drop_total;
 		stats->multicast +=  devRxStats->mcastPktsRxOK;
 	}
-
-	return stats;
 }
 
 static int
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 59e077be8829..ba1c9f93592b 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -465,8 +465,8 @@ vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
 
 void vmxnet3_set_ethtool_ops(struct net_device *netdev);
 
-struct rtnl_link_stats64 *
-vmxnet3_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats);
+void vmxnet3_get_stats64(struct net_device *dev,
+			 struct rtnl_link_stats64 *stats);
 
 extern char vmxnet3_driver_name[];
 #endif
diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 23dfb0eac098..895e3e258543 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -77,8 +77,8 @@ static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
-static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
-						 struct rtnl_link_stats64 *stats)
+static void vrf_get_stats64(struct net_device *dev,
+			    struct rtnl_link_stats64 *stats)
 {
 	int i;
 
@@ -102,7 +102,6 @@ static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
 		stats->rx_bytes += rbytes;
 		stats->rx_packets += rpkts;
 	}
-	return stats;
 }
 
 /* Local traffic destined to local address. Reinsert the packet to rx
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a479cd99911d..40f26b69beb1 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1073,8 +1073,8 @@ static int xennet_change_mtu(struct net_device *dev, int mtu)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
-						    struct rtnl_link_stats64 *tot)
+static void xennet_get_stats64(struct net_device *dev,
+			       struct rtnl_link_stats64 *tot)
 {
 	struct netfront_info *np = netdev_priv(dev);
 	int cpu;
@@ -1105,8 +1105,6 @@ static struct rtnl_link_stats64 *xennet_get_stats64(struct net_device *dev,
 
 	tot->rx_errors  = dev->stats.rx_errors;
 	tot->tx_dropped = dev->stats.tx_dropped;
-
-	return tot;
 }
 
 static void xennet_release_tx_bufs(struct netfront_queue *queue)
diff --git a/drivers/staging/netlogic/xlr_net.c b/drivers/staging/netlogic/xlr_net.c
index fb0928a4fb97..f84069ffa8c6 100644
--- a/drivers/staging/netlogic/xlr_net.c
+++ b/drivers/staging/netlogic/xlr_net.c
@@ -397,14 +397,6 @@ static void xlr_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)
 			TX_DROP_FRAME_COUNTER);
 }
 
-static struct rtnl_link_stats64 *xlr_get_stats64(struct net_device *ndev,
-						 struct rtnl_link_stats64 *stats
-						 )
-{
-	xlr_stats(ndev, stats);
-	return stats;
-}
-
 static const struct net_device_ops xlr_netdev_ops = {
 	.ndo_open = xlr_net_open,
 	.ndo_stop = xlr_net_stop,
@@ -412,7 +404,7 @@ static const struct net_device_ops xlr_netdev_ops = {
 	.ndo_select_queue = xlr_net_select_queue,
 	.ndo_set_mac_address = xlr_net_set_mac_addr,
 	.ndo_set_rx_mode = xlr_set_rx_mode,
-	.ndo_get_stats64 = xlr_get_stats64,
+	.ndo_get_stats64 = xlr_stats,
 };
 
 /*
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ecd78b3c9aba..b14ad9c139d7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -913,8 +913,8 @@ struct netdev_xdp {
  *	Callback used when the transmitter has not made any progress
  *	for dev->watchdog ticks.
  *
- * struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
- *                      struct rtnl_link_stats64 *storage);
+ * void (*ndo_get_stats64)(struct net_device *dev,
+ *                         struct rtnl_link_stats64 *storage);
  * struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
  *	Called when a user wants to get the network device usage
  *	statistics. Drivers must do one of the following:
@@ -1165,8 +1165,8 @@ struct net_device_ops {
 						   struct neigh_parms *);
 	void			(*ndo_tx_timeout) (struct net_device *dev);
 
-	struct rtnl_link_stats64* (*ndo_get_stats64)(struct net_device *dev,
-						     struct rtnl_link_stats64 *storage);
+	void			(*ndo_get_stats64)(struct net_device *dev,
+						   struct rtnl_link_stats64 *storage);
 	bool			(*ndo_has_offload_stats)(const struct net_device *dev, int attr_id);
 	int			(*ndo_get_offload_stats)(int attr_id,
 							 const struct net_device *dev,
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index e893fe43dd13..3d4ca4df1209 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -261,8 +261,8 @@ int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
 int __ip_tunnel_change_mtu(struct net_device *dev, int new_mtu, bool strict);
 int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
 
-struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
-						struct rtnl_link_stats64 *tot);
+void ip_tunnel_get_stats64(struct net_device *dev,
+			   struct rtnl_link_stats64 *tot);
 struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 				   int link, __be16 flags,
 				   __be32 remote, __be32 local,
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 10da6c588bf8..116455ac3db5 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -671,7 +671,8 @@ static int vlan_ethtool_get_ts_info(struct net_device *dev,
 	return 0;
 }
 
-static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
+static void vlan_dev_get_stats64(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats)
 {
 	struct vlan_pcpu_stats *p;
 	u32 rx_errors = 0, tx_dropped = 0;
@@ -702,8 +703,6 @@ static struct rtnl_link_stats64 *vlan_dev_get_stats64(struct net_device *dev, st
 	}
 	stats->rx_errors  = rx_errors;
 	stats->tx_dropped = tx_dropped;
-
-	return stats;
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ed3b3192fb00..6c46d1b4cdbb 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -153,8 +153,8 @@ static int br_dev_stop(struct net_device *dev)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
-						struct rtnl_link_stats64 *stats)
+static void br_get_stats64(struct net_device *dev,
+			   struct rtnl_link_stats64 *stats)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	struct pcpu_sw_netstats tmp, sum = { 0 };
@@ -178,8 +178,6 @@ static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
 	stats->tx_packets = sum.tx_packets;
 	stats->rx_bytes   = sum.rx_bytes;
 	stats->rx_packets = sum.rx_packets;
-
-	return stats;
 }
 
 static int br_change_mtu(struct net_device *dev, int new_mtu)
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index fed3d29f9eb3..5476110598f7 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -188,8 +188,8 @@ int iptunnel_handle_offloads(struct sk_buff *skb,
 EXPORT_SYMBOL_GPL(iptunnel_handle_offloads);
 
 /* Often modified stats are per cpu, other are shared (netdev->stats) */
-struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
-						struct rtnl_link_stats64 *tot)
+void ip_tunnel_get_stats64(struct net_device *dev,
+			   struct rtnl_link_stats64 *tot)
 {
 	int i;
 
@@ -214,8 +214,6 @@ struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
 		tot->rx_bytes   += rx_bytes;
 		tot->tx_bytes   += tx_bytes;
 	}
-
-	return tot;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_get_stats64);
 
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index e2c6ae024565..8bf18a5f66e0 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -106,8 +106,8 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-static struct rtnl_link_stats64 *l2tp_eth_get_stats64(struct net_device *dev,
-						      struct rtnl_link_stats64 *stats)
+static void l2tp_eth_get_stats64(struct net_device *dev,
+				 struct rtnl_link_stats64 *stats)
 {
 	struct l2tp_eth *priv = netdev_priv(dev);
 
@@ -117,10 +117,8 @@ static struct rtnl_link_stats64 *l2tp_eth_get_stats64(struct net_device *dev,
 	stats->rx_bytes   = atomic_long_read(&priv->rx_bytes);
 	stats->rx_packets = atomic_long_read(&priv->rx_packets);
 	stats->rx_errors  = atomic_long_read(&priv->rx_errors);
-	return stats;
 }
 
-
 static const struct net_device_ops l2tp_eth_netdev_ops = {
 	.ndo_init		= l2tp_eth_dev_init,
 	.ndo_uninit		= l2tp_eth_dev_uninit,
diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 41497b670e2b..77e8a42225f9 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -1122,7 +1122,7 @@ static u16 ieee80211_netdev_select_queue(struct net_device *dev,
 	return ieee80211_select_queue(IEEE80211_DEV_TO_SUB_IF(dev), skb);
 }
 
-static struct rtnl_link_stats64 *
+static void
 ieee80211_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	int i;
@@ -1147,8 +1147,6 @@ ieee80211_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->rx_bytes   += rx_bytes;
 		stats->tx_bytes   += tx_bytes;
 	}
-
-	return stats;
 }
 
 static const struct net_device_ops ieee80211_dataif_ops = {
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index d5d6caecd072..09141a18ee2d 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -97,7 +97,7 @@ static void internal_dev_destructor(struct net_device *dev)
 	free_netdev(dev);
 }
 
-static struct rtnl_link_stats64 *
+static void
 internal_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	int i;
@@ -125,8 +125,6 @@ internal_get_stats(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->tx_bytes         += local_stats.tx_bytes;
 		stats->tx_packets       += local_stats.tx_packets;
 	}
-
-	return stats;
 }
 
 static void internal_set_rx_headroom(struct net_device *dev, int new_hr)
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index b0196366d58d..9fe6b427afed 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -401,8 +401,8 @@ static int teql_master_close(struct net_device *dev)
 	return 0;
 }
 
-static struct rtnl_link_stats64 *teql_master_stats64(struct net_device *dev,
-						     struct rtnl_link_stats64 *stats)
+static void teql_master_stats64(struct net_device *dev,
+				struct rtnl_link_stats64 *stats)
 {
 	struct teql_master *m = netdev_priv(dev);
 
@@ -410,7 +410,6 @@ static struct rtnl_link_stats64 *teql_master_stats64(struct net_device *dev,
 	stats->tx_bytes		= m->tx_bytes;
 	stats->tx_errors	= m->tx_errors;
 	stats->tx_dropped	= m->tx_dropped;
-	return stats;
 }
 
 static int teql_master_mtu(struct net_device *dev, int new_mtu)
-- 
2.11.0
