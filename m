From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 4/4] Ethtool: convert get_tx_csum/set_tx_csum calls to hw_features flags
Date: Sun, 31 Oct 2010 02:09:31 +0200
Message-ID: <904bc8c98062fc793573ee6bc120ed0b8af292d2.1288496405.git.mirq-linux@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49494 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750734Ab0JaEAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 00:00:32 -0400
In-Reply-To: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/infiniband/hw/nes/nes_nic.c     |    3 +-
 drivers/net/8139cp.c                    |    2 +-
 drivers/net/atl1c/atl1c_ethtool.c       |    6 ---
 drivers/net/atl1e/atl1e_ethtool.c       |    2 +-
 drivers/net/atlx/atl1.c                 |    2 +-
 drivers/net/atlx/atl2.c                 |    6 ---
 drivers/net/benet/be_ethtool.c          |    2 -
 drivers/net/benet/be_main.c             |    1 +
 drivers/net/bna/bnad_ethtool.c          |   20 +---------
 drivers/net/bnx2.c                      |   15 +------
 drivers/net/bnx2x/bnx2x_ethtool.c       |    4 +-
 drivers/net/bonding/bond_main.c         |    1 -
 drivers/net/chelsio/cxgb2.c             |    3 +-
 drivers/net/cxgb3/cxgb3_main.c          |    2 +-
 drivers/net/cxgb4/cxgb4_main.c          |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c      |    2 +-
 drivers/net/dm9000.c                    |   17 +-------
 drivers/net/e1000/e1000_ethtool.c       |   28 +------------
 drivers/net/e1000e/ethtool.c            |   19 +---------
 drivers/net/enic/enic_main.c            |    9 +---
 drivers/net/forcedeth.c                 |   13 +------
 drivers/net/fs_enet/fs_enet-main.c      |    3 +-
 drivers/net/gianfar.c                   |    1 +
 drivers/net/gianfar_ethtool.c           |   31 ---------------
 drivers/net/greth.c                     |   16 +-------
 drivers/net/ibm_newemac/core.c          |    1 -
 drivers/net/ibmveth.c                   |    4 +-
 drivers/net/igb/igb_ethtool.c           |   28 ++-----------
 drivers/net/igbvf/ethtool.c             |   17 +--------
 drivers/net/ioc3-eth.c                  |    3 +-
 drivers/net/ixgb/ixgb_ethtool.c         |   20 +---------
 drivers/net/ixgbe/ixgbe_ethtool.c       |   30 +++-----------
 drivers/net/ixgbevf/ethtool.c           |    3 +-
 drivers/net/jme.c                       |    8 ++--
 drivers/net/ksz884x.c                   |    3 +-
 drivers/net/loopback.c                  |    1 -
 drivers/net/mlx4/en_ethtool.c           |    2 -
 drivers/net/mlx4/en_netdev.c            |    1 +
 drivers/net/mv643xx_eth.c               |    3 +-
 drivers/net/myri10ge/myri10ge.c         |    3 +-
 drivers/net/netxen/netxen_nic_ethtool.c |    7 ---
 drivers/net/netxen/netxen_nic_main.c    |    1 +
 drivers/net/pch_gbe/pch_gbe_ethtool.c   |   20 +---------
 drivers/net/ps3_gelic_net.c             |    3 +-
 drivers/net/ps3_gelic_wireless.c        |    3 +-
 drivers/net/qlcnic/qlcnic_ethtool.c     |   21 ----------
 drivers/net/qlcnic/qlcnic_main.c        |    2 +
 drivers/net/qlge/qlge_ethtool.c         |    2 -
 drivers/net/qlge/qlge_main.c            |    1 +
 drivers/net/r8169.c                     |    2 +-
 drivers/net/s2io.c                      |   13 +------
 drivers/net/sfc/efx.c                   |    1 +
 drivers/net/sfc/ethtool.c               |   16 --------
 drivers/net/skge.c                      |   14 +------
 drivers/net/sky2.c                      |    5 +-
 drivers/net/spider_net.c                |    1 +
 drivers/net/spider_net_ethtool.c        |    1 -
 drivers/net/stmmac/stmmac_ethtool.c     |   13 +------
 drivers/net/tehuti.c                    |   10 -----
 drivers/net/tg3.c                       |   26 +++---------
 drivers/net/typhoon.c                   |    2 +-
 drivers/net/usb/smsc75xx.c              |    6 +-
 drivers/net/usb/smsc95xx.c              |   16 ++------
 drivers/net/veth.c                      |   18 +--------
 drivers/net/via-velocity.c              |    4 +-
 drivers/net/virtio_net.c                |    7 ++-
 drivers/net/vmxnet3/vmxnet3_ethtool.c   |    3 +-
 drivers/net/vxge/vxge-ethtool.c         |    3 +-
 drivers/net/xen-netfront.c              |    2 +-
 drivers/s390/net/qeth_l3_main.c         |   13 ++----
 drivers/staging/octeon/ethernet-mdio.c  |    1 -
 include/linux/ethtool.h                 |   10 +----
 net/bridge/br_device.c                  |    5 +-
 net/core/ethtool.c                      |   64 ++++++++++-------------=
--------
 74 files changed, 118 insertions(+), 535 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/h=
w/nes/nes_nic.c
index 04af96a..c9bdf27 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1583,7 +1583,6 @@ static const struct ethtool_ops nes_ethtool_ops =3D=
 {
 	.get_link =3D ethtool_op_get_link,
 	.get_settings =3D nes_netdev_get_settings,
 	.set_settings =3D nes_netdev_set_settings,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.get_rx_csum =3D nes_netdev_get_rx_csum,
 	.get_strings =3D nes_netdev_get_strings,
 	.get_sset_count =3D nes_netdev_get_sset_count,
@@ -1593,7 +1592,6 @@ static const struct ethtool_ops nes_ethtool_ops =3D=
 {
 	.set_coalesce =3D nes_netdev_set_coalesce,
 	.get_pauseparam =3D nes_netdev_get_pauseparam,
 	.set_pauseparam =3D nes_netdev_set_pauseparam,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.set_rx_csum =3D nes_netdev_set_rx_csum,
 	.get_flags =3D ethtool_op_get_flags,
 	.set_flags =3D nes_netdev_set_flags,
@@ -1668,6 +1666,7 @@ struct net_device *nes_netdev_init(struct nes_dev=
ice *nesdev,
 	netdev->type =3D ARPHRD_ETHER;
 	netdev->features =3D NETIF_F_HIGHDMA;
 	netdev->netdev_ops =3D &nes_netdev_ops;
+	netdev->hw_features |=3D NETIF_F_IP_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	netdev->ethtool_ops =3D &nes_ethtool_ops;
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 0fd2867..ca86398 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1558,7 +1558,6 @@ static const struct ethtool_ops cp_ethtool_ops =3D=
 {
 	.set_msglevel		=3D cp_set_msglevel,
 	.get_rx_csum		=3D cp_get_rx_csum,
 	.set_rx_csum		=3D cp_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum, /* local! */
 	.get_regs		=3D cp_get_regs,
 	.get_wol		=3D cp_get_wol,
 	.set_wol		=3D cp_set_wol,
@@ -1956,6 +1955,7 @@ static int cp_init_one (struct pci_dev *pdev, con=
st struct pci_device_id *ent)
=20
 	dev->netdev_ops =3D &cp_netdev_ops;
 	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
+	dev->hw_features |=3D NETIF_F_IP_CSUM;
 	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	dev->ethtool_ops =3D &cp_ethtool_ops;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
diff --git a/drivers/net/atl1c/atl1c_ethtool.c b/drivers/net/atl1c/atl1=
c_ethtool.c
index d517223..67d3d36 100644
--- a/drivers/net/atl1c/atl1c_ethtool.c
+++ b/drivers/net/atl1c/atl1c_ethtool.c
@@ -113,11 +113,6 @@ static int atl1c_set_settings(struct net_device *n=
etdev,
 	return 0;
 }
=20
-static u32 atl1c_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
 static u32 atl1c_get_msglevel(struct net_device *netdev)
 {
 	struct atl1c_adapter *adapter =3D netdev_priv(netdev);
@@ -307,7 +302,6 @@ static const struct ethtool_ops atl1c_ethtool_ops =3D=
 {
 	.get_link               =3D ethtool_op_get_link,
 	.get_eeprom_len         =3D atl1c_get_eeprom_len,
 	.get_eeprom             =3D atl1c_get_eeprom,
-	.get_tx_csum            =3D atl1c_get_tx_csum,
 };
=20
 void atl1c_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1=
e_ethtool.c
index 1485797..8164e8c 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -382,11 +382,11 @@ static const struct ethtool_ops atl1e_ethtool_ops=
 =3D {
 	.get_eeprom_len         =3D atl1e_get_eeprom_len,
 	.get_eeprom             =3D atl1e_get_eeprom,
 	.set_eeprom             =3D atl1e_set_eeprom,
-	.set_tx_csum            =3D ethtool_op_set_tx_hw_csum,
 };
=20
 void atl1e_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &atl1e_ethtool_ops);
 }
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 814a06c..1abf8ce 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2993,6 +2993,7 @@ static int __devinit atl1_probe(struct pci_dev *p=
dev,
=20
 	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->hw_features |=3D NETIF_F_TSO;
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->ethtool_ops =3D &atl1_ethtool_ops;
 	adapter->bd_number =3D cards_found;
=20
@@ -3677,7 +3678,6 @@ static const struct ethtool_ops atl1_ethtool_ops =
=3D {
 	.get_pauseparam		=3D atl1_get_pauseparam,
 	.set_pauseparam		=3D atl1_set_pauseparam,
 	.get_rx_csum		=3D atl1_get_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
 	.get_link		=3D ethtool_op_get_link,
 	.get_strings		=3D atl1_get_strings,
 	.nway_reset		=3D atl1_nway_reset,
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 0d9b688..76635ec 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -1840,11 +1840,6 @@ static int atl2_set_settings(struct net_device *=
netdev,
 	return 0;
 }
=20
-static u32 atl2_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
 static u32 atl2_get_msglevel(struct net_device *netdev)
 {
 	return 0;
@@ -2106,7 +2101,6 @@ static const struct ethtool_ops atl2_ethtool_ops =
=3D {
 	.get_eeprom_len		=3D atl2_get_eeprom_len,
 	.get_eeprom		=3D atl2_get_eeprom,
 	.set_eeprom		=3D atl2_set_eeprom,
-	.get_tx_csum		=3D atl2_get_tx_csum,
 };
=20
 static void atl2_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_etht=
ool.c
index 8c1eaee..727cce9 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -696,8 +696,6 @@ const struct ethtool_ops be_ethtool_ops =3D {
 	.set_pauseparam =3D be_set_pauseparam,
 	.get_rx_csum =3D be_get_rx_csum,
 	.set_rx_csum =3D be_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
 	.get_strings =3D be_get_stat_strings,
 	.phys_id =3D be_phys_id,
 	.get_sset_count =3D be_get_sset_count,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index b8a164f..1081e32 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2554,6 +2554,7 @@ static void be_netdev_init(struct net_device *net=
dev)
=20
 	BE_SET_NETDEV_OPS(netdev, &be_netdev_ops);
=20
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
=20
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_etht=
ool.c
index f8bdebf..fe90c2a 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -831,23 +831,6 @@ bnad_set_rx_csum(struct net_device *netdev, u32 rx=
_csum)
 	return 0;
 }
=20
-static int
-bnad_set_tx_csum(struct net_device *netdev, u32 tx_csum)
-{
-	struct bnad *bnad =3D netdev_priv(netdev);
-
-	mutex_lock(&bnad->conf_mutex);
-	if (tx_csum) {
-		netdev->features |=3D NETIF_F_IP_CSUM;
-		netdev->features |=3D NETIF_F_IPV6_CSUM;
-	} else {
-		netdev->features &=3D ~NETIF_F_IP_CSUM;
-		netdev->features &=3D ~NETIF_F_IPV6_CSUM;
-	}
-	mutex_unlock(&bnad->conf_mutex);
-	return 0;
-}
-
 static void
 bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string=
)
 {
@@ -1242,8 +1225,6 @@ static struct ethtool_ops bnad_ethtool_ops =3D {
 	.set_pauseparam =3D bnad_set_pauseparam,
 	.get_rx_csum =3D bnad_get_rx_csum,
 	.set_rx_csum =3D bnad_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D bnad_set_tx_csum,
 	.get_strings =3D bnad_get_strings,
 	.get_ethtool_stats =3D bnad_get_ethtool_stats,
 	.get_sset_count =3D bnad_get_sset_count
@@ -1254,5 +1235,6 @@ bnad_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
+	netdev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
 	SET_ETHTOOL_OPS(netdev, &bnad_ethtool_ops);
 }
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8a63a8b..c2a1d3e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7495,17 +7495,6 @@ bnx2_phys_id(struct net_device *dev, u32 data)
 }
=20
 static int
-bnx2_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct bnx2 *bp =3D netdev_priv(dev);
-
-	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-		return ethtool_op_set_tx_ipv6_csum(dev, data);
-	else
-		return ethtool_op_set_tx_csum(dev, data);
-}
-
-static int
 bnx2_set_flags(struct net_device *dev, u32 data)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
@@ -7553,7 +7542,6 @@ static const struct ethtool_ops bnx2_ethtool_ops =
=3D {
 	.set_pauseparam		=3D bnx2_set_pauseparam,
 	.get_rx_csum		=3D bnx2_get_rx_csum,
 	.set_rx_csum		=3D bnx2_set_rx_csum,
-	.set_tx_csum		=3D bnx2_set_tx_csum,
 	.self_test		=3D bnx2_self_test,
 	.get_strings		=3D bnx2_get_strings,
 	.phys_id		=3D bnx2_phys_id,
@@ -8303,7 +8291,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct =
pci_device_id *ent)
=20
 	dev->netdev_ops =3D &bnx2_netdev_ops;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_IP_CSUM;
 	dev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO_ECN;
 	dev->ethtool_ops =3D &bnx2_ethtool_ops;
=20
@@ -8322,6 +8310,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct =
pci_device_id *ent)
 			 NETIF_F_RXHASH;
 	vlan_features_add(dev, NETIF_F_IP_CSUM | NETIF_F_SG);
 	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
+		dev->hw_features |=3D NETIF_F_IPV6_CSUM;
 		dev->features |=3D NETIF_F_IPV6_CSUM;
 		vlan_features_add(dev, NETIF_F_IPV6_CSUM);
 	}
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2=
x_ethtool.c
index 3d08714..6b15243 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -2065,8 +2065,6 @@ static const struct ethtool_ops bnx2x_ethtool_ops=
 =3D {
 	.set_pauseparam		=3D bnx2x_set_pauseparam,
 	.get_rx_csum		=3D bnx2x_get_rx_csum,
 	.set_rx_csum		=3D bnx2x_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
 	.set_flags		=3D bnx2x_set_flags,
 	.get_flags		=3D ethtool_op_get_flags,
 	.self_test		=3D bnx2x_self_test,
@@ -2078,7 +2076,7 @@ static const struct ethtool_ops bnx2x_ethtool_ops=
 =3D {
=20
 void bnx2x_set_ethtool_ops(struct net_device *netdev)
 {
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO_ECN|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &bnx2x_ethtool_ops);
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 4e030c5..29b0ea8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4650,7 +4650,6 @@ static void bond_ethtool_get_drvinfo(struct net_d=
evice *bond_dev,
 static const struct ethtool_ops bond_ethtool_ops =3D {
 	.get_drvinfo		=3D bond_ethtool_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
 	.get_ufo		=3D ethtool_op_get_ufo,
 	.get_flags		=3D ethtool_op_get_flags,
 };
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 712c413..c8acac9 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -824,7 +824,6 @@ static const struct ethtool_ops t1_ethtool_ops =3D =
{
 	.set_pauseparam    =3D set_pauseparam,
 	.get_rx_csum       =3D get_rx_csum,
 	.set_rx_csum       =3D set_rx_csum,
-	.set_tx_csum       =3D ethtool_op_set_tx_csum,
 	.get_link          =3D ethtool_op_get_link,
 	.get_strings       =3D get_strings,
 	.get_sset_count	   =3D get_sset_count,
@@ -1120,7 +1119,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
=20
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
=20
-		netdev->hw_features |=3D NETIF_F_SG;
+		netdev->hw_features |=3D NETIF_F_SG|NETIF_F_IP_CSUM;
 		if (adapter->flags & TSO_CAPABLE)
 			netdev->hw_features |=3D NETIF_F_TSO;
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_m=
ain.c
index 1d45f7d..1110364 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2096,7 +2096,6 @@ static const struct ethtool_ops cxgb_ethtool_ops =
=3D {
 	.set_pauseparam =3D set_pauseparam,
 	.get_rx_csum =3D get_rx_csum,
 	.set_rx_csum =3D set_rx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.get_link =3D ethtool_op_get_link,
 	.get_strings =3D get_strings,
 	.phys_id =3D cxgb3_phys_id,
@@ -3309,6 +3308,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
=20
 		netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->netdev_ops =3D &cxgb_netdev_ops;
+		netdev->hw_features |=3D NETIF_F_IP_CSUM;
 		netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_m=
ain.c
index 700bb37..41f14b1 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2001,7 +2001,6 @@ static struct ethtool_ops cxgb_ethtool_ops =3D {
 	.set_pauseparam    =3D set_pauseparam,
 	.get_rx_csum       =3D get_rx_csum,
 	.set_rx_csum       =3D set_rx_csum,
-	.set_tx_csum       =3D ethtool_op_set_tx_ipv6_csum,
 	.get_link          =3D ethtool_op_get_link,
 	.get_strings       =3D get_strings,
 	.phys_id           =3D identify_port,
@@ -3663,6 +3662,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 		netdev->vlan_features =3D netdev->features & VLAN_FEAT;
=20
 		netdev->netdev_ops =3D &cxgb4_netdev_ops;
+		netdev->hw_features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 		netdev->hw_features |=3D NETIF_F_SG | TSO_FLAGS;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/c=
xgb4vf_main.c
index 61cc28c..a6b1a5f 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1551,7 +1551,6 @@ static struct ethtool_ops cxgb4vf_ethtool_ops =3D=
 {
 	.get_pauseparam		=3D cxgb4vf_get_pauseparam,
 	.get_rx_csum		=3D cxgb4vf_get_rx_csum,
 	.set_rx_csum		=3D cxgb4vf_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_ipv6_csum,
 	.get_link		=3D ethtool_op_get_link,
 	.get_strings		=3D cxgb4vf_get_strings,
 	.phys_id		=3D cxgb4vf_phys_id,
@@ -2616,6 +2615,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci=
_dev *pdev,
 		netdev->poll_controller =3D cxgb4vf_poll_controller;
 #endif
 #endif
+		netdev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
 		netdev->hw_features |=3D NETIF_F_SG;
 		netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 		SET_ETHTOOL_OPS(netdev, &cxgb4vf_ethtool_ops);
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 9f6aeef..5ba4535 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -132,7 +132,6 @@ typedef struct board_info {
 	u32		wake_state;
=20
 	int		rx_csum;
-	int		can_csum;
 	int		ip_summed;
 } board_info_t;
=20
@@ -480,7 +479,7 @@ static int dm9000_set_rx_csum_unlocked(struct net_d=
evice *dev, uint32_t data)
 {
 	board_info_t *dm =3D to_dm9000_board(dev);
=20
-	if (dm->can_csum) {
+	if (dev->hw_features & NETIF_F_IP_CSUM) {
 		dm->rx_csum =3D data;
 		iow(dm, DM9000_RCSR, dm->rx_csum ? RCSR_CSUM : 0);
=20
@@ -503,16 +502,6 @@ static int dm9000_set_rx_csum(struct net_device *d=
ev, uint32_t data)
 	return ret;
 }
=20
-static int dm9000_set_tx_csum(struct net_device *dev, uint32_t data)
-{
-	board_info_t *dm =3D to_dm9000_board(dev);
-	int ret =3D -EOPNOTSUPP;
-
-	if (dm->can_csum)
-		ret =3D ethtool_op_set_tx_csum(dev, data);
-	return ret;
-}
-
 static u32 dm9000_get_link(struct net_device *dev)
 {
 	board_info_t *dm =3D to_dm9000_board(dev);
@@ -645,8 +634,6 @@ static const struct ethtool_ops dm9000_ethtool_ops =
=3D {
  	.set_eeprom		=3D dm9000_set_eeprom,
 	.get_rx_csum		=3D dm9000_get_rx_csum,
 	.set_rx_csum		=3D dm9000_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D dm9000_set_tx_csum,
 };
=20
 static void dm9000_show_carrier(board_info_t *db,
@@ -1550,9 +1537,9 @@ dm9000_probe(struct platform_device *pdev)
=20
 	/* dm9000a/b are capable of hardware checksum offload */
 	if (db->type =3D=3D TYPE_DM9000A || db->type =3D=3D TYPE_DM9000B) {
-		db->can_csum =3D 1;
 		db->rx_csum =3D 1;
 		ndev->features |=3D NETIF_F_IP_CSUM;
+		ndev->hw_features |=3D NETIF_F_IP_CSUM;
 	}
=20
 	/* from this point we assume that we have found a DM9000 */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e100=
0_ethtool.c
index fcde1b2..ddcb371 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -306,30 +306,6 @@ static int e1000_set_rx_csum(struct net_device *ne=
tdev, u32 data)
 	return 0;
 }
=20
-static u32 e1000_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	struct e1000_hw *hw =3D &adapter->hw;
-
-	if (hw->mac_type < e1000_82543) {
-		if (!data)
-			return -EINVAL;
-		return 0;
-	}
-
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
 static u32 e1000_get_msglevel(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
@@ -1902,8 +1878,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.set_pauseparam         =3D e1000_set_pauseparam,
 	.get_rx_csum            =3D e1000_get_rx_csum,
 	.set_rx_csum            =3D e1000_set_rx_csum,
-	.get_tx_csum            =3D e1000_get_tx_csum,
-	.set_tx_csum            =3D e1000_set_tx_csum,
 	.self_test              =3D e1000_diag_test,
 	.get_strings            =3D e1000_get_strings,
 	.phys_id                =3D e1000_phys_id,
@@ -1917,6 +1891,8 @@ void e1000_set_ethtool_ops(struct net_device *net=
dev)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
=20
+	if (!(adapter->hw.mac_type < e1000_82543))
+		netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG;
 	if (!(adapter->hw.mac_type < e1000_82544) &&
 	    !(adapter->hw.mac_type =3D=3D e1000_82547))
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.=
c
index 579ed4b..8e7b312 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -387,21 +387,6 @@ static int e1000_set_rx_csum(struct net_device *ne=
tdev, u32 data)
 	return 0;
 }
=20
-static u32 e1000_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
 static int e1000_set_tso(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
@@ -2026,8 +2011,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.set_pauseparam		=3D e1000_set_pauseparam,
 	.get_rx_csum		=3D e1000_get_rx_csum,
 	.set_rx_csum		=3D e1000_set_rx_csum,
-	.get_tx_csum		=3D e1000_get_tx_csum,
-	.set_tx_csum		=3D e1000_set_tx_csum,
 	.hw_set_tso		=3D e1000_set_tso,
 	.self_test		=3D e1000_diag_test,
 	.get_strings		=3D e1000_get_strings,
@@ -2041,7 +2024,7 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
=20
 void e1000e_set_ethtool_ops(struct net_device *netdev)
 {
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &e1000_ethtool_ops);
 }
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.=
c
index 88e4a99..e1077e6 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -297,11 +297,6 @@ static int enic_set_tx_csum(struct net_device *net=
dev, u32 data)
 	if (data && !ENIC_SETTING(enic, TXCSUM))
 		return -EINVAL;
=20
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
 	return 0;
 }
=20
@@ -404,8 +399,7 @@ static const struct ethtool_ops enic_ethtool_ops =3D=
 {
 	.get_ethtool_stats =3D enic_get_ethtool_stats,
 	.get_rx_csum =3D enic_get_rx_csum,
 	.set_rx_csum =3D enic_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D enic_set_tx_csum,
+	.hw_set_tx_csum =3D enic_set_tx_csum,
 	.hw_set_tso =3D enic_set_tso,
 	.get_coalesce =3D enic_get_coalesce,
 	.set_coalesce =3D enic_set_coalesce,
@@ -2628,6 +2622,7 @@ static int __devinit enic_probe(struct pci_dev *p=
dev,
 		netdev->netdev_ops =3D &enic_netdev_ops;
=20
 	netdev->watchdog_timeo =3D 2 * HZ;
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6|NETIF_F_TSO_ECN;
 	netdev->ethtool_ops =3D &enic_ethtool_ops;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 8aabb6a..3d5a9af 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4638,16 +4638,6 @@ static int nv_set_rx_csum(struct net_device *dev=
, u32 data)
 	return retcode;
 }
=20
-static int nv_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct fe_priv *np =3D netdev_priv(dev);
-
-	if (np->driver_data & DEV_HAS_CHECKSUM)
-		return ethtool_op_set_tx_csum(dev, data);
-	else
-		return -EOPNOTSUPP;
-}
-
 static int nv_get_sset_count(struct net_device *dev, int sset)
 {
 	struct fe_priv *np =3D netdev_priv(dev);
@@ -5025,7 +5015,6 @@ static const struct ethtool_ops ops =3D {
 	.set_pauseparam =3D nv_set_pauseparam,
 	.get_rx_csum =3D nv_get_rx_csum,
 	.set_rx_csum =3D nv_set_rx_csum,
-	.set_tx_csum =3D nv_set_tx_csum,
 	.get_strings =3D nv_get_strings,
 	.get_ethtool_stats =3D nv_get_ethtool_stats,
 	.get_sset_count =3D nv_get_sset_count,
@@ -5554,7 +5543,7 @@ static int __devinit nv_probe(struct pci_dev *pci=
_dev, const struct pci_device_i
=20
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
 	if (np->driver_data & DEV_HAS_CHECKSUM)
-		dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
+		dev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->watchdog_timeo =3D NV_WATCHDOG_TIMEO;
=20
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/f=
s_enet-main.c
index 4f1adcb..9e12457 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -955,7 +955,6 @@ static const struct ethtool_ops fs_ethtool_ops =3D =
{
 	.get_link =3D ethtool_op_get_link,
 	.get_msglevel =3D fs_get_msglevel,
 	.set_msglevel =3D fs_set_msglevel,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,	/* local! */
 	.get_regs =3D fs_get_regs,
 };
=20
@@ -1077,7 +1076,7 @@ static int __devinit fs_enet_probe(struct platfor=
m_device *ofdev,
 		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
 		               fpi->napi_weight);
=20
-	ndev->hw_features |=3D NETIF_F_SG;
+	ndev->hw_features |=3D NETIF_F_SG|NETIF_F_IP_CSUM;
 	ndev->ethtool_ops =3D &fs_ethtool_ops;
=20
 	init_timer(&fep->phy_timer_list);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c34b1cc..f597080 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1030,6 +1030,7 @@ static int gfar_probe(struct platform_device *ofd=
ev,
=20
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		priv->rx_csum_enable =3D 1;
+		dev->hw_features |=3D NETIF_F_IP_CSUM;
 		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HIGHDMA;
 	} else
 		priv->rx_csum_enable =3D 0;
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtoo=
l.c
index cf4a87a..79c7a9e 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -569,35 +569,6 @@ static uint32_t gfar_get_rx_csum(struct net_device=
 *dev)
 	return priv->rx_csum_enable;
 }
=20
-static int gfar_set_tx_csum(struct net_device *dev, uint32_t data)
-{
-	struct gfar_private *priv =3D netdev_priv(dev);
-
-	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
-		return -EOPNOTSUPP;
-
-	netif_tx_lock_bh(dev);
-
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-
-	netif_tx_unlock_bh(dev);
-
-	return 0;
-}
-
-static uint32_t gfar_get_tx_csum(struct net_device *dev)
-{
-	struct gfar_private *priv =3D netdev_priv(dev);
-
-	if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
-		return 0;
-
-	return (dev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
 static uint32_t gfar_get_msglevel(struct net_device *dev)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
@@ -894,9 +865,7 @@ const struct ethtool_ops gfar_ethtool_ops =3D {
 	.get_sset_count =3D gfar_sset_count,
 	.get_ethtool_stats =3D gfar_fill_stats,
 	.get_rx_csum =3D gfar_get_rx_csum,
-	.get_tx_csum =3D gfar_get_tx_csum,
 	.set_rx_csum =3D gfar_set_rx_csum,
-	.set_tx_csum =3D gfar_set_tx_csum,
 	.get_msglevel =3D gfar_get_msglevel,
 	.set_msglevel =3D gfar_set_msglevel,
 #ifdef CONFIG_PM
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 27d6960..bc3b25e 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1123,19 +1123,6 @@ static int greth_set_rx_csum(struct net_device *=
dev, u32 data)
 	return 0;
 }
=20
-static u32 greth_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int greth_set_tx_csum(struct net_device *dev, u32 data)
-{
-	netif_tx_lock_bh(dev);
-	ethtool_op_set_tx_csum(dev, data);
-	netif_tx_unlock_bh(dev);
-	return 0;
-}
-
 static const struct ethtool_ops greth_ethtool_ops =3D {
 	.get_msglevel		=3D greth_get_msglevel,
 	.set_msglevel		=3D greth_set_msglevel,
@@ -1146,8 +1133,6 @@ static const struct ethtool_ops greth_ethtool_ops=
 =3D {
 	.get_regs               =3D greth_get_regs,
 	.get_rx_csum		=3D greth_get_rx_csum,
 	.set_rx_csum		=3D greth_set_rx_csum,
-	.get_tx_csum		=3D greth_get_tx_csum,
-	.set_tx_csum		=3D greth_set_tx_csum,
 	.get_link		=3D ethtool_op_get_link,
 };
=20
@@ -1546,6 +1531,7 @@ static int __devinit greth_of_probe(struct platfo=
rm_device *ofdev, const struct
=20
 	dev->netdev_ops =3D &greth_netdev_ops;
 	dev->ethtool_ops =3D &greth_ethtool_ops;
+	dev->hw_features =3D NETIF_F_IP_CSUM;
=20
 	err =3D register_netdev(dev);
 	if (err) {
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/c=
ore.c
index 7f3ccc2..b07474b 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2210,7 +2210,6 @@ static const struct ethtool_ops emac_ethtool_ops =
=3D {
 	.get_ethtool_stats =3D emac_ethtool_get_ethtool_stats,
=20
 	.get_link =3D ethtool_op_get_link,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
 };
=20
 static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int c=
md)
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 7e96672..eafb61f 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -875,7 +875,7 @@ static int ibmveth_set_tx_csum(struct net_device *d=
ev, u32 data)
 	else
 		ibmveth_set_tx_csum_flags(dev, data);
=20
-	return rc;
+	return rc ? rc : 1;
 }
=20
 static u32 ibmveth_get_rx_csum(struct net_device *dev)
@@ -919,7 +919,7 @@ static const struct ethtool_ops netdev_ethtool_ops =
=3D {
 	.get_drvinfo		=3D netdev_get_drvinfo,
 	.get_settings		=3D netdev_get_settings,
 	.get_link		=3D netdev_get_link,
-	.set_tx_csum		=3D ibmveth_set_tx_csum,
+	.hw_set_tx_csum		=3D ibmveth_set_tx_csum,
 	.get_rx_csum		=3D ibmveth_get_rx_csum,
 	.set_rx_csum		=3D ibmveth_set_rx_csum,
 	.get_strings		=3D ibmveth_get_strings,
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtoo=
l.c
index de257e4..e73b7eb 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -334,27 +334,6 @@ static int igb_set_rx_csum(struct net_device *netd=
ev, u32 data)
 	return 0;
 }
=20
-static u32 igb_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int igb_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct igb_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		if (adapter->hw.mac.type >=3D e1000_82576)
-			netdev->features |=3D NETIF_F_SCTP_CSUM;
-	} else {
-		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		                      NETIF_F_SCTP_CSUM);
-	}
-
-	return 0;
-}
-
 static u32 igb_get_msglevel(struct net_device *netdev)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
@@ -2174,8 +2153,6 @@ static const struct ethtool_ops igb_ethtool_ops =3D=
 {
 	.set_pauseparam         =3D igb_set_pauseparam,
 	.get_rx_csum            =3D igb_get_rx_csum,
 	.set_rx_csum            =3D igb_set_rx_csum,
-	.get_tx_csum            =3D igb_get_tx_csum,
-	.set_tx_csum            =3D igb_set_tx_csum,
 	.self_test              =3D igb_diag_test,
 	.get_strings            =3D igb_get_strings,
 	.phys_id                =3D igb_phys_id,
@@ -2187,7 +2164,12 @@ static const struct ethtool_ops igb_ethtool_ops =
=3D {
=20
 void igb_set_ethtool_ops(struct net_device *netdev)
 {
+	struct igb_adapter *adapter =3D netdev_priv(netdev);
+
 	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
+	netdev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
+	if (adapter->hw.mac.type >=3D e1000_82576)
+		netdev->hw_features |=3D NETIF_F_SCTP_CSUM;
 	SET_ETHTOOL_OPS(netdev, &igb_ethtool_ops);
 }
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 56f77b6..469f00f 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -151,20 +151,6 @@ static int igbvf_set_rx_csum(struct net_device *ne=
tdev, u32 data)
 	return 0;
 }
=20
-static u32 igbvf_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int igbvf_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	else
-		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	return 0;
-}
-
 static u32 igbvf_get_msglevel(struct net_device *netdev)
 {
 	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
@@ -508,8 +494,6 @@ static const struct ethtool_ops igbvf_ethtool_ops =3D=
 {
 	.set_pauseparam		=3D igbvf_set_pauseparam,
 	.get_rx_csum            =3D igbvf_get_rx_csum,
 	.set_rx_csum            =3D igbvf_set_rx_csum,
-	.get_tx_csum		=3D igbvf_get_tx_csum,
-	.set_tx_csum		=3D igbvf_set_tx_csum,
 	.self_test		=3D igbvf_diag_test,
 	.get_sset_count		=3D igbvf_get_sset_count,
 	.get_strings		=3D igbvf_get_strings,
@@ -521,6 +505,7 @@ static const struct ethtool_ops igbvf_ethtool_ops =3D=
 {
=20
 void igbvf_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	/* have to "undeclare" const on this struct to remove warnings */
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index c8ee8d2..0792963 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1327,6 +1327,7 @@ static int __devinit ioc3_probe(struct pci_dev *p=
dev,
 	/* The IOC3-specific entries in the device structure. */
 	dev->watchdog_timeo	=3D 5 * HZ;
 	dev->netdev_ops		=3D &ioc3_netdev_ops;
+	dev->hw_features	=3D NETIF_F_IP_CSUM;
 	dev->ethtool_ops	=3D &ioc3_ethtool_ops;
 	dev->features		=3D NETIF_F_IP_CSUM;
=20
@@ -1647,8 +1648,6 @@ static const struct ethtool_ops ioc3_ethtool_ops =
=3D {
 	.get_link		=3D ioc3_get_link,
 	.get_rx_csum		=3D ioc3_get_rx_csum,
 	.set_rx_csum		=3D ioc3_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum
 };
=20
 static int ioc3_ioctl(struct net_device *dev, struct ifreq *rq, int cm=
d)
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_et=
htool.c
index b8b38ef..1d9c232 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -218,23 +218,6 @@ ixgb_set_rx_csum(struct net_device *netdev, u32 da=
ta)
 }
=20
 static u32
-ixgb_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-static int
-ixgb_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
-static u32
 ixgb_get_msglevel(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
@@ -712,8 +695,6 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
 	.set_pauseparam	=3D ixgb_set_pauseparam,
 	.get_rx_csum =3D ixgb_get_rx_csum,
 	.set_rx_csum =3D ixgb_set_rx_csum,
-	.get_tx_csum =3D ixgb_get_tx_csum,
-	.set_tx_csum =3D ixgb_set_tx_csum,
 	.get_msglevel =3D ixgb_get_msglevel,
 	.set_msglevel =3D ixgb_set_msglevel,
 	.get_strings =3D ixgb_get_strings,
@@ -724,6 +705,7 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
=20
 void ixgb_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
 }
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 561a74d..d14c0eb 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -420,28 +420,6 @@ static int ixgbe_set_rx_csum(struct net_device *ne=
tdev, u32 data)
 	return 0;
 }
=20
-static u32 ixgbe_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
-{
-	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		if (adapter->hw.mac.type =3D=3D ixgbe_mac_82599EB)
-			netdev->features |=3D NETIF_F_SCTP_CSUM;
-	} else {
-		netdev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-		if (adapter->hw.mac.type =3D=3D ixgbe_mac_82599EB)
-			netdev->features &=3D ~NETIF_F_SCTP_CSUM;
-	}
-
-	return 0;
-}
-
 static u32 ixgbe_get_msglevel(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
@@ -2273,8 +2251,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops=
 =3D {
 	.set_pauseparam         =3D ixgbe_set_pauseparam,
 	.get_rx_csum            =3D ixgbe_get_rx_csum,
 	.set_rx_csum            =3D ixgbe_set_rx_csum,
-	.get_tx_csum            =3D ixgbe_get_tx_csum,
-	.set_tx_csum            =3D ixgbe_set_tx_csum,
 	.get_msglevel           =3D ixgbe_get_msglevel,
 	.set_msglevel           =3D ixgbe_set_msglevel,
 	.self_test              =3D ixgbe_diag_test,
@@ -2291,7 +2267,13 @@ static const struct ethtool_ops ixgbe_ethtool_op=
s =3D {
=20
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
 {
+	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
+
+	netdev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
+	if (adapter->hw.mac.type =3D=3D ixgbe_mac_82599EB)
+		netdev->hw_features |=3D NETIF_F_SCTP_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
+
 	SET_ETHTOOL_OPS(netdev, &ixgbe_ethtool_ops);
 }
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtoo=
l.c
index 58ae092..673dedd 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -702,8 +702,6 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D {
 	.set_ringparam          =3D ixgbevf_set_ringparam,
 	.get_rx_csum            =3D ixgbevf_get_rx_csum,
 	.set_rx_csum            =3D ixgbevf_set_rx_csum,
-	.get_tx_csum            =3D ethtool_op_get_tx_csum,
-	.set_tx_csum            =3D ethtool_op_set_tx_ipv6_csum,
 	.get_msglevel           =3D ixgbevf_get_msglevel,
 	.set_msglevel           =3D ixgbevf_set_msglevel,
 	.self_test              =3D ixgbevf_diag_test,
@@ -714,6 +712,7 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D {
=20
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &ixgbevf_ethtool_ops);
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index f837c3f..96feccd 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2513,11 +2513,10 @@ jme_set_tx_csum(struct net_device *netdev, u32 =
on)
=20
 	if (on) {
 		set_bit(JME_FLAG_TXCSUM, &jme->flags);
-		if (netdev->mtu <=3D 1900)
-			netdev->features |=3D NETIF_F_HW_CSUM;
+		if (netdev->mtu > 1900)
+			return 1;
 	} else {
 		clear_bit(JME_FLAG_TXCSUM, &jme->flags);
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
 	}
=20
 	return 0;
@@ -2682,7 +2681,7 @@ static const struct ethtool_ops jme_ethtool_ops =3D=
 {
 	.set_msglevel           =3D jme_set_msglevel,
 	.get_rx_csum		=3D jme_get_rx_csum,
 	.set_rx_csum		=3D jme_set_rx_csum,
-	.set_tx_csum		=3D jme_set_tx_csum,
+	.hw_set_tx_csum		=3D jme_set_tx_csum,
 	.hw_set_tso		=3D jme_set_tso,
 	.nway_reset             =3D jme_nway_reset,
 	.get_eeprom_len		=3D jme_get_eeprom_len,
@@ -2793,6 +2792,7 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_release_regions;
 	}
 	netdev->netdev_ops =3D &jme_netdev_ops;
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6;
 	netdev->ethtool_ops		=3D &jme_ethtool_ops;
 	netdev->watchdog_timeo		=3D TX_TIMEOUT;
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index ea69576..f8669d2 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -6660,8 +6660,6 @@ static struct ethtool_ops netdev_ethtool_ops =3D =
{
 	.get_ethtool_stats	=3D netdev_get_ethtool_stats,
 	.get_rx_csum		=3D netdev_get_rx_csum,
 	.set_rx_csum		=3D netdev_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 };
=20
 /*
@@ -7148,6 +7146,7 @@ static int __init pcidev_init(struct pci_dev *pde=
v,
 		}
=20
 		dev->netdev_ops =3D &netdev_ops;
+		dev->hw_features |=3D NETIF_F_IP_CSUM;
 		dev->hw_features |=3D NETIF_F_SG;
 		SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 		if (register_netdev(dev))
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 76e900c..411a4d9 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -129,7 +129,6 @@ static u32 always_on(struct net_device *dev)
=20
 static const struct ethtool_ops loopback_ethtool_ops =3D {
 	.get_link		=3D always_on,
-	.get_tx_csum		=3D always_on,
 	.get_rx_csum		=3D always_on,
 };
=20
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtoo=
l.c
index a963bcd..84ee1c8 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -422,8 +422,6 @@ const struct ethtool_ops mlx4_en_ethtool_ops =3D {
 	.get_link =3D ethtool_op_get_link,
 	.get_rx_csum =3D mlx4_en_get_rx_csum,
 	.set_rx_csum =3D mlx4_en_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_ipv6_csum,
 	.get_strings =3D mlx4_en_get_strings,
 	.get_sset_count =3D mlx4_en_get_sset_count,
 	.get_ethtool_stats =3D mlx4_en_get_ethtool_stats,
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.=
c
index b867b34..ecf1710 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1038,6 +1038,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev,=
 int port,
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
=20
+	dev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
 	dev->hw_features |=3D NETIF_F_SG;
 	dev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index aa3b981..95d2393 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1665,7 +1665,6 @@ static const struct ethtool_ops mv643xx_eth_ethto=
ol_ops =3D {
 	.set_ringparam		=3D mv643xx_eth_set_ringparam,
 	.get_rx_csum		=3D mv643xx_eth_get_rx_csum,
 	.set_rx_csum		=3D mv643xx_eth_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 	.get_strings		=3D mv643xx_eth_get_strings,
 	.get_ethtool_stats	=3D mv643xx_eth_get_ethtool_stats,
 	.get_flags		=3D ethtool_op_get_flags,
@@ -2909,7 +2908,7 @@ static int mv643xx_eth_probe(struct platform_devi=
ce *pdev)
 	if (mp->phy !=3D NULL)
 		phy_init(mp, pd->speed, pd->duplex);
=20
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_IP_CSUM;
 	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
=20
 	init_pscr(mp, pd->speed, pd->duplex);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index 4f8b838..5ac8dd7 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1938,7 +1938,6 @@ static const struct ethtool_ops myri10ge_ethtool_=
ops =3D {
 	.get_ringparam =3D myri10ge_get_ringparam,
 	.get_rx_csum =3D myri10ge_get_rx_csum,
 	.set_rx_csum =3D myri10ge_set_rx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
 	.get_link =3D ethtool_op_get_link,
 	.get_strings =3D myri10ge_get_strings,
 	.get_sset_count =3D myri10ge_get_sset_count,
@@ -3984,7 +3983,7 @@ static int myri10ge_probe(struct pci_dev *pdev, c=
onst struct pci_device_id *ent)
 		    (unsigned long)mgp);
=20
 	spin_lock_init(&mgp->stats_lock);
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &myri10ge_ethtool_ops);
 	INIT_WORK(&mgp->watchdog_work, myri10ge_watchdog);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netx=
en/netxen_nic_ethtool.c
index 9244bb1..c8cdbba 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -706,11 +706,6 @@ netxen_nic_get_ethtool_stats(struct net_device *de=
v,
 	}
 }
=20
-static u32 netxen_nic_get_tx_csum(struct net_device *dev)
-{
-	return dev->features & NETIF_F_IP_CSUM;
-}
-
 static u32 netxen_nic_get_rx_csum(struct net_device *dev)
 {
 	struct netxen_adapter *adapter =3D netdev_priv(dev);
@@ -900,8 +895,6 @@ const struct ethtool_ops netxen_nic_ethtool_ops =3D=
 {
 	.set_ringparam =3D netxen_nic_set_ringparam,
 	.get_pauseparam =3D netxen_nic_get_pauseparam,
 	.set_pauseparam =3D netxen_nic_set_pauseparam,
-	.get_tx_csum =3D netxen_nic_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.get_wol =3D netxen_nic_get_wol,
 	.set_wol =3D netxen_nic_set_wol,
 	.self_test =3D netxen_nic_diag_test,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index 573e51f..06672e5 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1210,6 +1210,7 @@ netxen_setup_netdev(struct netxen_adapter *adapte=
r,
=20
 	netxen_nic_change_mtu(netdev, netdev->mtu);
=20
+	netdev->hw_features |=3D NETIF_F_IP_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netdev->hw_features |=3D NETIF_F_TSO6;
diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gb=
e/pch_gbe_ethtool.c
index c8cc32c..2575c72 100644
--- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
@@ -469,18 +469,6 @@ static int pch_gbe_set_rx_csum(struct net_device *=
netdev, u32 data)
 }
=20
 /**
- * pch_gbe_get_tx_csum - Report whether transmit checksums are turned =
on or off
- * @netdev:  Network interface device structure
- * Returns
- *	true(1):  Checksum On
- *	false(0): Checksum Off
- */
-static u32 pch_gbe_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) !=3D 0;
-}
-
-/**
  * pch_gbe_set_tx_csum - Turn transmit checksums on or off
  * @netdev: Network interface device structure
  * @data:   Checksum on[true] or off[false]
@@ -493,10 +481,6 @@ static int pch_gbe_set_tx_csum(struct net_device *=
netdev, u32 data)
 	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
=20
 	adapter->tx_csum =3D data;
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
 	return 0;
 }
=20
@@ -572,8 +556,7 @@ static const struct ethtool_ops pch_gbe_ethtool_ops=
 =3D {
 	.set_pauseparam =3D pch_gbe_set_pauseparam,
 	.get_rx_csum =3D pch_gbe_get_rx_csum,
 	.set_rx_csum =3D pch_gbe_set_rx_csum,
-	.get_tx_csum =3D pch_gbe_get_tx_csum,
-	.set_tx_csum =3D pch_gbe_set_tx_csum,
+	.hw_set_tx_csum =3D pch_gbe_set_tx_csum,
 	.get_strings =3D pch_gbe_get_strings,
 	.get_ethtool_stats =3D pch_gbe_get_ethtool_stats,
 	.get_sset_count =3D pch_gbe_get_sset_count,
@@ -581,5 +564,6 @@ static const struct ethtool_ops pch_gbe_ethtool_ops=
 =3D {
=20
 void pch_gbe_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	SET_ETHTOOL_OPS(netdev, &pch_gbe_ethtool_ops);
 }
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 5ecfa4b..ec2f5a5 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -1411,8 +1411,6 @@ static const struct ethtool_ops gelic_ether_ethto=
ol_ops =3D {
 	.get_settings	=3D gelic_ether_get_settings,
 	.set_settings	=3D gelic_ether_set_settings,
 	.get_link	=3D ethtool_op_get_link,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum	=3D ethtool_op_set_tx_csum,
 	.get_rx_csum	=3D gelic_net_get_rx_csum,
 	.set_rx_csum	=3D gelic_net_set_rx_csum,
 	.get_wol	=3D gelic_net_get_wol,
@@ -1492,6 +1490,7 @@ static void __devinit gelic_ether_setup_netdev_op=
s(struct net_device *netdev,
 	/* NAPI */
 	netif_napi_add(netdev, napi,
 		       gelic_net_poll, GELIC_NET_NAPI_WEIGHT);
+	netdev->hw_features |=3D NETIF_F_IP_CSUM;
 	netdev->ethtool_ops =3D &gelic_ether_ethtool_ops;
 	netdev->netdev_ops =3D &gelic_netdevice_ops;
 }
diff --git a/drivers/net/ps3_gelic_wireless.c b/drivers/net/ps3_gelic_w=
ireless.c
index 4a624a2..6e3a41e 100644
--- a/drivers/net/ps3_gelic_wireless.c
+++ b/drivers/net/ps3_gelic_wireless.c
@@ -2581,8 +2581,6 @@ static const struct net_device_ops gelic_wl_netde=
vice_ops =3D {
 static const struct ethtool_ops gelic_wl_ethtool_ops =3D {
 	.get_drvinfo	=3D gelic_net_get_drvinfo,
 	.get_link	=3D gelic_wl_get_link,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum	=3D ethtool_op_set_tx_csum,
 	.get_rx_csum	=3D gelic_net_get_rx_csum,
 	.set_rx_csum	=3D gelic_net_set_rx_csum,
 };
@@ -2594,6 +2592,7 @@ static void __devinit gelic_wl_setup_netdev_ops(s=
truct net_device *netdev)
 	BUG_ON(!wl);
 	netdev->watchdog_timeo =3D GELIC_NET_WATCHDOG_TIMEOUT;
=20
+	netdev->hw_features |=3D NETIF_F_IP_CSUM;
 	netdev->ethtool_ops =3D &gelic_wl_ethtool_ops;
 	netdev->netdev_ops =3D &gelic_wl_netdevice_ops;
 	netdev->wireless_data =3D &wl->wireless_data;
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/q=
lcnic_ethtool.c
index abf89ba..0da9461 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -883,25 +883,6 @@ qlcnic_get_ethtool_stats(struct net_device *dev,
 	qlcnic_fill_device_stats(&index, data, &port_stats.tx);
 }
=20
-static int qlcnic_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
-
-	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED))
-		return -EOPNOTSUPP;
-	if (data)
-		dev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	else
-		dev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-
-	return 0;
-
-}
-static u32 qlcnic_get_tx_csum(struct net_device *dev)
-{
-	return dev->features & NETIF_F_IP_CSUM;
-}
-
 static u32 qlcnic_get_rx_csum(struct net_device *dev)
 {
 	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
@@ -1146,8 +1127,6 @@ const struct ethtool_ops qlcnic_ethtool_ops =3D {
 	.set_ringparam =3D qlcnic_set_ringparam,
 	.get_pauseparam =3D qlcnic_get_pauseparam,
 	.set_pauseparam =3D qlcnic_set_pauseparam,
-	.get_tx_csum =3D qlcnic_get_tx_csum,
-	.set_tx_csum =3D qlcnic_set_tx_csum,
 	.get_wol =3D qlcnic_get_wol,
 	.set_wol =3D qlcnic_set_wol,
 	.self_test =3D qlcnic_diag_test,
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcn=
ic_main.c
index 53e07ed..f5236cb 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1425,6 +1425,8 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapte=
r,
=20
 	qlcnic_change_mtu(netdev, netdev->mtu);
=20
+	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
+		netdev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
=20
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_et=
htool.c
index 9b7bddf..a0905de 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -683,8 +683,6 @@ const struct ethtool_ops qlge_ethtool_ops =3D {
 	.set_pauseparam		 =3D ql_set_pauseparam,
 	.get_rx_csum =3D ql_get_rx_csum,
 	.set_rx_csum =3D ql_set_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.get_coalesce =3D ql_get_coalesce,
 	.set_coalesce =3D ql_set_coalesce,
 	.get_sset_count =3D ql_get_sset_count,
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index fb36da6..5b8a2bd 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4713,6 +4713,7 @@ static int __devinit qlge_probe(struct pci_dev *p=
dev,
 	ndev->irq =3D pdev->irq;
=20
 	ndev->netdev_ops =3D &qlge_netdev_ops;
+	ndev->hw_features |=3D NETIF_F_IP_CSUM;
 	ndev->hw_features |=3D NETIF_F_SG;
 	ndev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(ndev, &qlge_ethtool_ops);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 999a713..9f45f47 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1276,7 +1276,6 @@ static const struct ethtool_ops rtl8169_ethtool_o=
ps =3D {
 	.set_msglevel		=3D rtl8169_set_msglevel,
 	.get_rx_csum		=3D rtl8169_get_rx_csum,
 	.set_rx_csum		=3D rtl8169_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 	.get_regs		=3D rtl8169_get_regs,
 	.get_wol		=3D rtl8169_get_wol,
 	.set_wol		=3D rtl8169_set_wol,
@@ -3171,6 +3170,7 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 		dev->dev_addr[i] =3D RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
=20
+	dev->hw_features |=3D NETIF_F_IP_CSUM;
 	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->watchdog_timeo =3D RTL8169_TX_TIMEOUT;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index ef63529..6eb63bc 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6694,16 +6694,6 @@ static void s2io_ethtool_get_strings(struct net_=
device *dev,
 	}
 }
=20
-static int s2io_ethtool_op_set_tx_csum(struct net_device *dev, u32 dat=
a)
-{
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-
 static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
 {
 	struct s2io_nic *sp =3D netdev_priv(dev);
@@ -6751,7 +6741,6 @@ static const struct ethtool_ops netdev_ethtool_op=
s =3D {
 	.set_pauseparam =3D s2io_ethtool_setpause_data,
 	.get_rx_csum =3D s2io_ethtool_get_rx_csum,
 	.set_rx_csum =3D s2io_ethtool_set_rx_csum,
-	.set_tx_csum =3D s2io_ethtool_op_set_tx_csum,
 	.set_flags =3D s2io_ethtool_set_flags,
 	.get_flags =3D ethtool_op_get_flags,
 	.set_ufo =3D ethtool_op_set_ufo,
@@ -8016,7 +8005,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct =
pci_device_id *pre)
=20
 	/*  Driver entry points */
 	dev->netdev_ops =3D &s2io_netdev_ops;
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_IP_CSUM;
 	dev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 26bb98b..f50737a 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1885,6 +1885,7 @@ static int efx_register_netdev(struct efx_nic *ef=
x)
 	net_dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	if (efx->type->offload_features & NETIF_F_V6_CSUM)
 		net_dev->hw_features |=3D NETIF_F_TSO6;
+	net_dev->hw_features |=3D efx->type->offload_features & NETIF_F_ALL_C=
SUM;
 	SET_ETHTOOL_OPS(net_dev, &efx_ethtool_ops);
=20
 	/* Clear MAC statistics */
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index dd2b271..2ef2225 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -500,19 +500,6 @@ static void efx_ethtool_get_stats(struct net_devic=
e *net_dev,
 	}
 }
=20
-static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 ena=
ble)
-{
-	struct efx_nic *efx =3D netdev_priv(net_dev);
-	unsigned long features =3D efx->type->offload_features & NETIF_F_ALL_=
CSUM;
-
-	if (enable)
-		net_dev->features |=3D features;
-	else
-		net_dev->features &=3D ~features;
-
-	return 0;
-}
-
 static int efx_ethtool_set_rx_csum(struct net_device *net_dev, u32 ena=
ble)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
@@ -1110,9 +1097,6 @@ const struct ethtool_ops efx_ethtool_ops =3D {
 	.set_pauseparam         =3D efx_ethtool_set_pauseparam,
 	.get_rx_csum		=3D efx_ethtool_get_rx_csum,
 	.set_rx_csum		=3D efx_ethtool_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	/* Need to enable/disable IPv6 too */
-	.set_tx_csum		=3D efx_ethtool_set_tx_csum,
 	.get_flags		=3D ethtool_op_get_flags,
 	.set_flags		=3D efx_ethtool_set_flags,
 	.get_sset_count		=3D efx_ethtool_get_sset_count,
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index ac153bd..7cabfa2 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -537,17 +537,6 @@ static int skge_nway_reset(struct net_device *dev)
 	return 0;
 }
=20
-static int skge_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct skge_port *skge =3D netdev_priv(dev);
-	struct skge_hw *hw =3D skge->hw;
-
-	if (hw->chip_id =3D=3D CHIP_ID_GENESIS && data)
-		return -EOPNOTSUPP;
-
-	return ethtool_op_set_tx_csum(dev, data);
-}
-
 static u32 skge_get_rx_csum(struct net_device *dev)
 {
 	struct skge_port *skge =3D netdev_priv(dev);
@@ -915,7 +904,6 @@ static const struct ethtool_ops skge_ethtool_ops =3D=
 {
 	.set_pauseparam =3D skge_set_pauseparam,
 	.get_coalesce	=3D skge_get_coalesce,
 	.set_coalesce	=3D skge_set_coalesce,
-	.set_tx_csum	=3D skge_set_tx_csum,
 	.get_rx_csum	=3D skge_get_rx_csum,
 	.set_rx_csum	=3D skge_set_rx_csum,
 	.get_strings	=3D skge_get_strings,
@@ -3801,7 +3789,7 @@ static struct net_device *skge_devinit(struct skg=
e_hw *hw, int port,
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->netdev_ops =3D &skge_netdev_ops;
 	if (hw->chip_id !=3D CHIP_ID_GENESIS)
-		dev->hw_features |=3D NETIF_F_SG;
+		dev->hw_features |=3D NETIF_F_SG|NETIF_F_IP_CSUM;
 	dev->ethtool_ops =3D &skge_ethtool_ops;
 	dev->watchdog_timeo =3D TX_WATCHDOG;
 	dev->irq =3D hw->pdev->irq;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 98534ef..2f8b615 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4071,7 +4071,7 @@ static int sky2_set_tx_csum(struct net_device *de=
v, u32 data)
 	if (data && no_tx_offload(dev))
 		return -EINVAL;
=20
-	return ethtool_op_set_tx_csum(dev, data);
+	return 0;
 }
=20
=20
@@ -4216,7 +4216,7 @@ static const struct ethtool_ops sky2_ethtool_ops =
=3D {
 	.get_eeprom_len	=3D sky2_get_eeprom_len,
 	.get_eeprom	=3D sky2_get_eeprom,
 	.set_eeprom	=3D sky2_set_eeprom,
-	.set_tx_csum	=3D sky2_set_tx_csum,
+	.hw_set_tx_csum	=3D sky2_set_tx_csum,
 	.hw_set_tso	=3D sky2_set_tso,
 	.get_rx_csum	=3D sky2_get_rx_csum,
 	.set_rx_csum	=3D sky2_set_rx_csum,
@@ -4549,6 +4549,7 @@ static __devinit struct net_device *sky2_init_net=
dev(struct sky2_hw *hw,
=20
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->irq =3D hw->pdev->irq;
+	dev->hw_features |=3D NETIF_F_IP_CSUM;
 	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &sky2_ethtool_ops);
 	dev->watchdog_timeo =3D TX_WATCHDOG;
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index cb6bcca..2476ef5 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -2287,6 +2287,7 @@ spider_net_setup_netdev_ops(struct net_device *ne=
tdev)
 	netdev->netdev_ops =3D &spider_net_ops;
 	netdev->watchdog_timeo =3D SPIDER_NET_WATCHDOG_TIMEOUT;
 	/* ethtool ops */
+	netdev->hw_features |=3D NETIF_F_IP_CSUM;
 	netdev->ethtool_ops =3D &spider_net_ethtool_ops;
 }
=20
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_=
ethtool.c
index 5bae728..912098d 100644
--- a/drivers/net/spider_net_ethtool.c
+++ b/drivers/net/spider_net_ethtool.c
@@ -191,7 +191,6 @@ const struct ethtool_ops spider_net_ethtool_ops =3D=
 {
 	.nway_reset		=3D spider_net_ethtool_nway_reset,
 	.get_rx_csum		=3D spider_net_ethtool_get_rx_csum,
 	.set_rx_csum		=3D spider_net_ethtool_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 	.get_ringparam          =3D spider_net_ethtool_get_ringparam,
 	.get_strings		=3D spider_net_get_strings,
 	.get_sset_count		=3D spider_net_get_sset_count,
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/s=
tmmac_ethtool.c
index 0674ebb..285fdb6 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -197,16 +197,6 @@ static void stmmac_ethtool_gregs(struct net_device=
 *dev,
 	}
 }
=20
-static int stmmac_ethtool_set_tx_csum(struct net_device *netdev, u32 d=
ata)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_HW_CSUM;
-	else
-		netdev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-
 static u32 stmmac_ethtool_get_rx_csum(struct net_device *dev)
 {
 	struct stmmac_priv *priv =3D netdev_priv(dev);
@@ -369,8 +359,6 @@ static struct ethtool_ops stmmac_ethtool_ops =3D {
 	.get_regs_len =3D stmmac_ethtool_get_regs_len,
 	.get_link =3D ethtool_op_get_link,
 	.get_rx_csum =3D stmmac_ethtool_get_rx_csum,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D stmmac_ethtool_set_tx_csum,
 	.get_pauseparam =3D stmmac_get_pauseparam,
 	.set_pauseparam =3D stmmac_set_pauseparam,
 	.get_ethtool_stats =3D stmmac_get_ethtool_stats,
@@ -382,6 +370,7 @@ static struct ethtool_ops stmmac_ethtool_ops =3D {
=20
 void stmmac_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &stmmac_ethtool_ops);
 }
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 42913bf..f4a7a33 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2197,15 +2197,6 @@ static u32 bdx_get_rx_csum(struct net_device *ne=
tdev)
 }
=20
 /*
- * bdx_get_tx_csum - report whether transmit checksums are turned on o=
r off
- * @netdev
- */
-static u32 bdx_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_IP_CSUM) !=3D 0;
-}
-
-/*
  * bdx_get_coalesce - get interrupt coalescing parameters
  * @netdev
  * @ecoal
@@ -2425,7 +2416,6 @@ static void bdx_set_ethtool_ops(struct net_device=
 *netdev)
 		.get_ringparam =3D bdx_get_ringparam,
 		.set_ringparam =3D bdx_set_ringparam,
 		.get_rx_csum =3D bdx_get_rx_csum,
-		.get_tx_csum =3D bdx_get_tx_csum,
 		.get_strings =3D bdx_get_strings,
 		.get_sset_count =3D bdx_get_sset_count,
 		.get_ethtool_stats =3D bdx_get_ethtool_stats,
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c08172d..71ffc2e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10249,24 +10249,6 @@ static int tg3_set_rx_csum(struct net_device *=
dev, u32 data)
 	return 0;
 }
=20
-static int tg3_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct tg3 *tp =3D netdev_priv(dev);
-
-	if (tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) {
-		if (data !=3D 0)
-			return -EINVAL;
-		return 0;
-	}
-
-	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
-		ethtool_op_set_tx_ipv6_csum(dev, data);
-	else
-		ethtool_op_set_tx_csum(dev, data);
-
-	return 0;
-}
-
 static int tg3_get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
@@ -11306,7 +11288,6 @@ static const struct ethtool_ops tg3_ethtool_ops=
 =3D {
 	.set_pauseparam		=3D tg3_set_pauseparam,
 	.get_rx_csum		=3D tg3_get_rx_csum,
 	.set_rx_csum		=3D tg3_set_rx_csum,
-	.set_tx_csum		=3D tg3_set_tx_csum,
 	.hw_set_tso		=3D tg3_set_tso,
 	.self_test		=3D tg3_self_test,
 	.get_strings		=3D tg3_get_strings,
@@ -14694,6 +14675,13 @@ static int __devinit tg3_init_one(struct pci_d=
ev *pdev,
 		goto err_out_iounmap;
 	}
=20
+	if (!(tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS)) {
+		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+			dev->hw_features |=3D NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM;
+		else
+			dev->hw_features |=3D NETIF_F_IP_CSUM;
+	}
+
 	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) !=3D ASIC_REV_5717 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) !=3D ASIC_REV_5719)
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index cc2f811..0f83e9f 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1190,7 +1190,6 @@ static const struct ethtool_ops typhoon_ethtool_o=
ps =3D {
 	.set_wol		=3D typhoon_set_wol,
 	.get_link		=3D ethtool_op_get_link,
 	.get_rx_csum		=3D typhoon_get_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_csum,
 	.get_ringparam		=3D typhoon_get_ringparam,
 	.set_flags		=3D typhoon_set_flags,
 	.get_flags		=3D ethtool_op_get_flags,
@@ -2478,6 +2477,7 @@ typhoon_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 	netif_napi_add(dev, &tp->napi, typhoon_poll, 16);
 	dev->watchdog_timeo	=3D TX_TIMEOUT;
=20
+	dev->hw_features |=3D NETIF_F_IP_CSUM;
 	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &typhoon_ethtool_ops);
=20
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 466ed50..3373490 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -628,8 +628,6 @@ static const struct ethtool_ops smsc75xx_ethtool_op=
s =3D {
 	.get_eeprom_len	=3D smsc75xx_ethtool_get_eeprom_len,
 	.get_eeprom	=3D smsc75xx_ethtool_get_eeprom,
 	.set_eeprom	=3D smsc75xx_ethtool_set_eeprom,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum	=3D ethtool_op_set_tx_hw_csum,
 	.get_rx_csum	=3D smsc75xx_ethtool_get_rx_csum,
 	.set_rx_csum	=3D smsc75xx_ethtool_set_rx_csum,
 };
@@ -948,7 +946,6 @@ static int smsc75xx_reset(struct usbnet *dev)
 	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x", pdata->rfe_ct=
l);
=20
 	/* Enable or disable checksum offload engines */
-	ethtool_op_set_tx_hw_csum(dev->net, DEFAULT_TX_CSUM_ENABLE);
 	ret =3D smsc75xx_set_rx_csum_offload(dev);
 	check_warn_return(ret, "Failed to set rx csum offload: %d", ret);
=20
@@ -1057,12 +1054,15 @@ static int smsc75xx_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
 	dev->net->features |=3D NETIF_F_SG;
 	if (DEFAULT_TSO_ENABLE)
 		dev->net->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
+	if (DEFAULT_TX_CSUM_ENABLE)
+		dev->net->features |=3D NETIF_F_HW_CSUM;
=20
 	/* Init all registers */
 	ret =3D smsc75xx_reset(dev);
=20
 	dev->net->netdev_ops =3D &smsc75xx_netdev_ops;
 	dev->net->hw_features |=3D NETIF_F_TSO | NETIF_F_TSO6;
+	dev->net->hw_features |=3D NETIF_F_HW_CSUM;
 	dev->net->ethtool_ops =3D &smsc75xx_ethtool_ops;
 	dev->net->flags |=3D IFF_MULTICAST;
 	dev->net->hard_header_len +=3D SMSC75XX_TX_OVERHEAD;
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 65cb1ab..09d0dbe 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -591,14 +591,6 @@ static int smsc95xx_ethtool_set_rx_csum(struct net=
_device *netdev, u32 val)
 	return smsc95xx_set_csums(dev);
 }
=20
-static u32 smsc95xx_ethtool_get_tx_csum(struct net_device *netdev)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]=
);
-
-	return pdata->use_tx_csum;
-}
-
 static int smsc95xx_ethtool_set_tx_csum(struct net_device *netdev, u32=
 val)
 {
 	struct usbnet *dev =3D netdev_priv(netdev);
@@ -606,7 +598,6 @@ static int smsc95xx_ethtool_set_tx_csum(struct net_=
device *netdev, u32 val)
=20
 	pdata->use_tx_csum =3D !!val;
=20
-	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
 	return smsc95xx_set_csums(dev);
 }
=20
@@ -621,8 +612,7 @@ static const struct ethtool_ops smsc95xx_ethtool_op=
s =3D {
 	.get_eeprom_len	=3D smsc95xx_ethtool_get_eeprom_len,
 	.get_eeprom	=3D smsc95xx_ethtool_get_eeprom,
 	.set_eeprom	=3D smsc95xx_ethtool_set_eeprom,
-	.get_tx_csum	=3D smsc95xx_ethtool_get_tx_csum,
-	.set_tx_csum	=3D smsc95xx_ethtool_set_tx_csum,
+	.hw_set_tx_csum	=3D smsc95xx_ethtool_set_tx_csum,
 	.get_rx_csum	=3D smsc95xx_ethtool_get_rx_csum,
 	.set_rx_csum	=3D smsc95xx_ethtool_set_rx_csum,
 };
@@ -972,7 +962,8 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
=20
 	/* Enable or disable checksum offload engines */
-	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
+	if (pdata->use_tx_csum)
+		dev->net->features |=3D NETIF_F_HW_CSUM;
 	ret =3D smsc95xx_set_csums(dev);
 	if (ret < 0) {
 		netdev_warn(dev->net, "Failed to set csum offload: %d\n", ret);
@@ -1051,6 +1042,7 @@ static int smsc95xx_bind(struct usbnet *dev, stru=
ct usb_interface *intf)
 	ret =3D smsc95xx_reset(dev);
=20
 	dev->net->netdev_ops =3D &smsc95xx_netdev_ops;
+	dev->net->hw_features =3D NETIF_F_HW_CSUM;
 	dev->net->ethtool_ops =3D &smsc95xx_ethtool_ops;
 	dev->net->flags |=3D IFF_MULTICAST;
 	dev->net->hard_header_len +=3D SMSC95XX_TX_OVERHEAD;
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index d00db8a..72c278b 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -116,28 +116,12 @@ static int veth_set_rx_csum(struct net_device *de=
v, u32 data)
 	return 0;
 }
=20
-static u32 veth_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_NO_CSUM) !=3D 0;
-}
-
-static int veth_set_tx_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_NO_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_NO_CSUM;
-	return 0;
-}
-
 static const struct ethtool_ops veth_ethtool_ops =3D {
 	.get_settings		=3D veth_get_settings,
 	.get_drvinfo		=3D veth_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
 	.get_rx_csum		=3D veth_get_rx_csum,
 	.set_rx_csum		=3D veth_set_rx_csum,
-	.get_tx_csum		=3D veth_get_tx_csum,
-	.set_tx_csum		=3D veth_set_tx_csum,
 	.get_strings		=3D veth_get_strings,
 	.get_sset_count		=3D veth_get_sset_count,
 	.get_ethtool_stats	=3D veth_get_ethtool_stats,
@@ -297,7 +281,7 @@ static void veth_setup(struct net_device *dev)
 	ether_setup(dev);
=20
 	dev->netdev_ops =3D &veth_netdev_ops;
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_NO_CSUM;
 	dev->ethtool_ops =3D &veth_ethtool_ops;
 	dev->features |=3D NETIF_F_LLTX;
 	dev->destructor =3D veth_dev_free;
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index a6389ef..4e817c2 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2838,7 +2838,7 @@ static int __devinit velocity_found1(struct pci_d=
ev *pdev, const struct pci_devi
=20
 	dev->irq =3D pdev->irq;
 	dev->netdev_ops =3D &velocity_netdev_ops;
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_IP_CSUM;
 	dev->ethtool_ops =3D &velocity_ethtool_ops;
 	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT)=
;
=20
@@ -3449,8 +3449,6 @@ static const struct ethtool_ops velocity_ethtool_=
ops =3D {
 	.get_settings	=3D	velocity_get_settings,
 	.set_settings	=3D	velocity_set_settings,
 	.get_drvinfo	=3D	velocity_get_drvinfo,
-	.set_tx_csum	=3D	ethtool_op_set_tx_csum,
-	.get_tx_csum	=3D	ethtool_op_get_tx_csum,
 	.get_wol	=3D	velocity_ethtool_get_wol,
 	.set_wol	=3D	velocity_ethtool_set_wol,
 	.get_msglevel	=3D	velocity_get_msglevel,
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 037913f..c783b1e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -711,9 +711,9 @@ static int virtnet_set_tx_csum(struct net_device *d=
ev, u32 data)
 	struct virtio_device *vdev =3D vi->vdev;
=20
 	if (data && !virtio_has_feature(vdev, VIRTIO_NET_F_CSUM))
-		return -ENOSYS;
+		return -EINVAL;
=20
-	return ethtool_op_set_tx_hw_csum(dev, data);
+	return 0;
 }
=20
 static void virtnet_set_rx_mode(struct net_device *dev)
@@ -817,7 +817,7 @@ static void virtnet_vlan_rx_kill_vid(struct net_dev=
ice *dev, u16 vid)
 }
=20
 static const struct ethtool_ops virtnet_ethtool_ops =3D {
-	.set_tx_csum =3D virtnet_set_tx_csum,
+	.hw_set_tx_csum =3D virtnet_set_tx_csum,
 	.set_ufo =3D ethtool_op_set_ufo,
 	.get_link =3D ethtool_op_get_link,
 };
@@ -901,6 +901,7 @@ static int virtnet_probe(struct virtio_device *vdev=
)
 	/* Set up network device as normal. */
 	dev->netdev_ops =3D &virtnet_netdev;
 	dev->features =3D NETIF_F_HIGHDMA;
+	dev->hw_features |=3D NETIF_F_HW_CSUM;
 	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet=
3/vmxnet3_ethtool.c
index a43c5fb..1cdfe63 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -545,8 +545,6 @@ static struct ethtool_ops vmxnet3_ethtool_ops =3D {
 	.get_link          =3D ethtool_op_get_link,
 	.get_rx_csum       =3D vmxnet3_get_rx_csum,
 	.set_rx_csum       =3D vmxnet3_set_rx_csum,
-	.get_tx_csum       =3D ethtool_op_get_tx_csum,
-	.set_tx_csum       =3D ethtool_op_set_tx_hw_csum,
 	.get_strings       =3D vmxnet3_get_strings,
 	.get_flags	   =3D ethtool_op_get_flags,
 	.set_flags	   =3D vmxnet3_set_flags,
@@ -558,6 +556,7 @@ static struct ethtool_ops vmxnet3_ethtool_ops =3D {
=20
 void vmxnet3_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_HW_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &vmxnet3_ethtool_ops);
 }
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-et=
htool.c
index df9e500..2da14e3 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1120,8 +1120,6 @@ static const struct ethtool_ops vxge_ethtool_ops =
=3D {
 	.set_pauseparam		=3D vxge_ethtool_setpause_data,
 	.get_rx_csum		=3D vxge_get_rx_csum,
 	.set_rx_csum		=3D vxge_set_rx_csum,
-	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
 	.get_strings		=3D vxge_ethtool_get_strings,
 	.phys_id		=3D vxge_ethtool_idnic,
 	.get_sset_count		=3D vxge_ethtool_get_sset_count,
@@ -1130,6 +1128,7 @@ static const struct ethtool_ops vxge_ethtool_ops =
=3D {
=20
 void vxge_initialize_ethtool_ops(struct net_device *ndev)
 {
+	ndev->hw_features |=3D NETIF_F_HW_CSUM;
 	ndev->hw_features |=3D NETIF_F_SG;
 	ndev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(ndev, &vxge_ethtool_ops);
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 5715ba6..913d36f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1178,6 +1178,7 @@ static struct net_device * __devinit xennet_creat=
e_dev(struct xenbus_device *dev
 	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
 	netdev->features        =3D NETIF_F_IP_CSUM;
=20
+	netdev->hw_features |=3D NETIF_F_IP_CSUM;
 	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
@@ -1639,7 +1640,6 @@ static void netback_changed(struct xenbus_device =
*dev,
=20
 static const struct ethtool_ops xennet_ethtool_ops =3D
 {
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.hw_set_sg =3D xennet_set_sg,
 	.hw_set_tso =3D xennet_set_tso,
 	.get_link =3D ethtool_op_get_link,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3=
_main.c
index efd49c9..a9c403b 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3237,21 +3237,15 @@ static int qeth_l3_ethtool_set_tx_csum(struct n=
et_device *dev, u32 data)
 {
 	struct qeth_card *card =3D dev->ml_priv;
=20
-	if (data) {
-		if (qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
-			dev->features |=3D NETIF_F_IP_CSUM;
-		else
-			return -EPERM;
-	} else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
+	if (data && !qeth_is_supported(card, IPA_OUTBOUND_CHECKSUM))
+		return -EINVAL;
=20
 	return 0;
 }
=20
 static const struct ethtool_ops qeth_l3_ethtool_ops =3D {
 	.get_link =3D ethtool_op_get_link,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.set_tx_csum =3D qeth_l3_ethtool_set_tx_csum,
+	.hw_set_tx_csum =3D qeth_l3_ethtool_set_tx_csum,
 	.get_rx_csum =3D qeth_l3_ethtool_get_rx_csum,
 	.set_rx_csum =3D qeth_l3_ethtool_set_rx_csum,
 	.hw_set_tso  =3D qeth_l3_ethtool_set_tso,
@@ -3354,6 +3348,7 @@ static int qeth_l3_setup_netdev(struct qeth_card =
*card)
 	card->dev->ml_priv =3D card;
 	card->dev->watchdog_timeo =3D QETH_TX_TIMEOUT;
 	card->dev->mtu =3D card->info.initial_mtu;
+	card->dev->hw_features |=3D NETIF_F_IP_CSUM;
 	card->dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
 	card->dev->features |=3D	NETIF_F_HW_VLAN_TX |
diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/o=
cteon/ethernet-mdio.c
index 7ad58bf..8a11ffc 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -91,7 +91,6 @@ const struct ethtool_ops cvm_oct_ethtool_ops =3D {
 	.set_settings =3D cvm_oct_set_settings,
 	.nway_reset =3D cvm_oct_nway_reset,
 	.get_link =3D ethtool_op_get_link,
-	.get_tx_csum =3D ethtool_op_get_tx_csum,
 };
=20
 /**
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 0efb1c9..2270479 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -544,10 +544,6 @@ struct net_device;
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
 u32 ethtool_op_get_rx_csum(struct net_device *dev);
-u32 ethtool_op_get_tx_csum(struct net_device *dev);
-int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
-int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
-int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
 u32 ethtool_op_get_flags(struct net_device *dev);
@@ -576,8 +572,7 @@ void ethtool_ntuple_flush(struct net_device *dev);
  * set_pauseparam: Set pause parameters
  * get_rx_csum: Report whether receive checksums are turned on or off
  * set_rx_csum: Turn receive checksum on or off
- * get_tx_csum: Report whether transmit checksums are turned on or off
- * set_tx_csum: Turn transmit checksums on or off
+ * hw_set_tx_csum: Turn transmit checksums on or off
  * hw_set_sg: Turn scatter-gather on or off
  * hw_set_tso: Turn TCP segmentation offload on or off
  * get_ufo: Report whether UDP fragmentation offload is enabled
@@ -640,8 +635,7 @@ struct ethtool_ops {
 				  struct ethtool_pauseparam*);
 	u32	(*get_rx_csum)(struct net_device *);
 	int	(*set_rx_csum)(struct net_device *, u32);
-	u32	(*get_tx_csum)(struct net_device *);
-	int	(*set_tx_csum)(struct net_device *, u32);
+	int	(*hw_set_tx_csum)(struct net_device *, u32);
 	int	(*hw_set_sg)(struct net_device *, u32);
 	int	(*hw_set_tso)(struct net_device *, u32);
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index dbda588..c7ce04e 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -209,7 +209,7 @@ static int br_set_tx_csum(struct net_device *dev, u=
32 data)
 		br->feature_mask &=3D ~NETIF_F_ALL_CSUM;
=20
 	br_features_recompute(br);
-	return 0;
+	return 1;
 }
=20
 static int br_set_flags(struct net_device *netdev, u32 data)
@@ -300,8 +300,7 @@ void br_netpoll_disable(struct net_bridge_port *p)
 static const struct ethtool_ops br_ethtool_ops =3D {
 	.get_drvinfo    =3D br_getinfo,
 	.get_link	=3D ethtool_op_get_link,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum 	=3D br_set_tx_csum,
+	.hw_set_tx_csum	=3D br_set_tx_csum,
 	.hw_set_sg	=3D br_set_sg,
 	.hw_set_tso	=3D br_set_tso,
 	.get_ufo	=3D ethtool_op_get_ufo,
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 9b0e598..95e8b7a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -40,44 +40,6 @@ u32 ethtool_op_get_rx_csum(struct net_device *dev)
 }
 EXPORT_SYMBOL(ethtool_op_get_rx_csum);
=20
-u32 ethtool_op_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_ALL_CSUM) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_tx_csum);
-
-int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-
-int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_HW_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
-
-int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	else
-		dev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
-
 u32 ethtool_op_get_ufo(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_UFO) !=3D 0;
@@ -1077,12 +1039,18 @@ static int __ethtool_set_sg(struct net_device *=
dev, u32 data)
 	return 0;
 }
=20
+static u32 ethtool_get_tx_csum(struct net_device *dev)
+{
+	return (dev->features & (NETIF_F_ALL_CSUM|NETIF_F_SCTP_CSUM)) !=3D 0;
+}
+
 static int ethtool_set_tx_csum(struct net_device *dev, char __user *us=
eraddr)
 {
+	unsigned long mask =3D dev->hw_features & (NETIF_F_ALL_CSUM|NETIF_F_S=
CTP_CSUM);
 	struct ethtool_value edata;
 	int err;
=20
-	if (!dev->ethtool_ops->set_tx_csum)
+	if (!mask)
 		return -EOPNOTSUPP;
=20
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
@@ -1094,9 +1062,19 @@ static int ethtool_set_tx_csum(struct net_device=
 *dev, char __user *useraddr)
 			return err;
 	}
=20
-	return dev->ethtool_ops->set_tx_csum(dev, edata.data);
+	if (dev->ethtool_ops->hw_set_tx_csum) {
+		err =3D dev->ethtool_ops->hw_set_tx_csum(dev, edata.data);
+		if (err)
+			return min(err, 0);
+	}
+
+	if (edata.data)
+		dev->features |=3D mask;
+	else
+		dev->features &=3D ~mask;
+
+	return 0;
 }
-EXPORT_SYMBOL(ethtool_op_set_tx_csum);
=20
 static int ethtool_set_rx_csum(struct net_device *dev, char __user *us=
eraddr)
 {
@@ -1568,9 +1546,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		break;
 	case ETHTOOL_GTXCSUM:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_tx_csum ?
-					dev->ethtool_ops->get_tx_csum :
-					ethtool_op_get_tx_csum));
+					ethtool_get_tx_csum);
 		break;
 	case ETHTOOL_STXCSUM:
 		rc =3D ethtool_set_tx_csum(dev, useraddr);
--=20
1.7.1

