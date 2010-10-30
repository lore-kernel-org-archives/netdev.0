From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 3/4] Ethtool: convert get_tso/set_tso calls to hw_features flags
Date: Sat, 30 Oct 2010 10:44:17 +0200
Message-ID: <db0a20ab6e4ab3f63d782bd2c4a9f7a873ea4a64.1288496404.git.mirq-linux@rere.qmqm.pl>
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
Received: from rere.qmqm.pl ([89.167.52.164]:49493 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759Ab0JaEAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 00:00:34 -0400
In-Reply-To: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/infiniband/hw/nes/nes_nic.c          |    4 +-
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c |   10 ++--
 drivers/net/8139cp.c                         |    3 +-
 drivers/net/atl1e/atl1e_ethtool.c            |    3 +-
 drivers/net/atlx/atl1.c                      |    2 +-
 drivers/net/atlx/atl2.c                      |    3 -
 drivers/net/benet/be_ethtool.c               |    2 -
 drivers/net/benet/be_main.c                  |    2 +-
 drivers/net/bna/bnad_ethtool.c               |   20 +---------
 drivers/net/bnx2.c                           |   18 +--------
 drivers/net/bnx2x/bnx2x_ethtool.c            |   16 +-------
 drivers/net/bonding/bond_main.c              |    1 -
 drivers/net/chelsio/cxgb2.c                  |   12 +-----
 drivers/net/cxgb3/cxgb3_main.c               |    3 +-
 drivers/net/cxgb4/cxgb4_main.c               |   12 +-----
 drivers/net/cxgb4vf/cxgb4vf_main.c           |   14 +------
 drivers/net/e1000/e1000.h                    |    1 -
 drivers/net/e1000/e1000_ethtool.c            |   28 +++-----------
 drivers/net/e1000e/ethtool.c                 |   12 +-----
 drivers/net/ehea/ehea_ethtool.c              |    2 +-
 drivers/net/enic/enic_main.c                 |   11 +----
 drivers/net/forcedeth.c                      |   13 +------
 drivers/net/igb/igb_ethtool.c                |   20 +---------
 drivers/net/igbvf/ethtool.c                  |   20 +---------
 drivers/net/ixgb/ixgb_ethtool.c              |   13 +------
 drivers/net/ixgbe/ixgbe_ethtool.c            |   15 +-------
 drivers/net/ixgbevf/ethtool.c                |   17 +--------
 drivers/net/jme.c                            |    9 ++--
 drivers/net/loopback.c                       |    2 +-
 drivers/net/mlx4/en_ethtool.c                |   19 ++-------
 drivers/net/mlx4/en_netdev.c                 |    1 +
 drivers/net/myri10ge/myri10ge.c              |   14 +------
 drivers/net/netxen/netxen_nic_ethtool.c      |   26 -------------
 drivers/net/netxen/netxen_nic_main.c         |    4 +-
 drivers/net/qlcnic/qlcnic_ethtool.c          |   20 ----------
 drivers/net/qlcnic/qlcnic_main.c             |    1 +
 drivers/net/qlge/qlge_ethtool.c              |   15 -------
 drivers/net/qlge/qlge_main.c                 |    1 +
 drivers/net/r8169.c                          |    3 +-
 drivers/net/s2io.c                           |   18 +--------
 drivers/net/sfc/efx.c                        |    4 +-
 drivers/net/sfc/ethtool.c                    |   20 ----------
 drivers/net/sky2.c                           |    6 +-
 drivers/net/stmmac/stmmac_ethtool.c          |    4 +-
 drivers/net/tehuti.c                         |    1 -
 drivers/net/tg3.c                            |   38 ++++++++++--------=
-
 drivers/net/typhoon.c                        |    3 +-
 drivers/net/usb/smsc75xx.c                   |   17 +-------
 drivers/net/virtio_net.c                     |    3 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c        |    4 +-
 drivers/net/vxge/vxge-ethtool.c              |   13 +------
 drivers/net/xen-netfront.c                   |    9 ++--
 drivers/s390/net/qeth_l3_main.c              |    7 +--
 include/linux/ethtool.h                      |    8 +---
 include/linux/netdevice.h                    |    2 +
 net/8021q/vlan_dev.c                         |    5 +-
 net/bridge/br_device.c                       |    7 +--
 net/core/ethtool.c                           |   52 +++++++++++++-----=
--------
 58 files changed, 132 insertions(+), 481 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/h=
w/nes/nes_nic.c
index 6056913..04af96a 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1595,8 +1595,6 @@ static const struct ethtool_ops nes_ethtool_ops =3D=
 {
 	.set_pauseparam =3D nes_netdev_set_pauseparam,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.set_rx_csum =3D nes_netdev_set_rx_csum,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ethtool_op_set_tso,
 	.get_flags =3D ethtool_op_get_flags,
 	.set_flags =3D nes_netdev_set_flags,
 };
@@ -1670,7 +1668,7 @@ struct net_device *nes_netdev_init(struct nes_dev=
ice *nesdev,
 	netdev->type =3D ARPHRD_ETHER;
 	netdev->features =3D NETIF_F_HIGHDMA;
 	netdev->netdev_ops =3D &nes_netdev_ops;
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	netdev->ethtool_ops =3D &nes_ethtool_ops;
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c b/drivers/inf=
iniband/ulp/ipoib/ipoib_ethtool.c
index 1a1657c..6fb3cf4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
@@ -58,13 +58,12 @@ static int ipoib_set_tso(struct net_device *dev, u3=
2 data)
 		    (dev->features & NETIF_F_SG) &&
 		    (priv->hca_caps & IB_DEVICE_UD_TSO)) {
 			dev->features |=3D NETIF_F_TSO;
+			return 1;
 		} else {
 			ipoib_warn(priv, "can't set TSO on\n");
-			return -EOPNOTSUPP;
+			return -EINVAL;
 		}
-	} else
-		dev->features &=3D ~NETIF_F_TSO;
-
+	}
 	return 0;
 }
=20
@@ -155,7 +154,7 @@ static int ipoib_set_flags(struct net_device *dev, =
u32 flags)
 static const struct ethtool_ops ipoib_ethtool_ops =3D {
 	.get_drvinfo		=3D ipoib_get_drvinfo,
 	.get_rx_csum		=3D ipoib_get_rx_csum,
-	.set_tso		=3D ipoib_set_tso,
+	.hw_set_tso		=3D ipoib_set_tso,
 	.get_coalesce		=3D ipoib_get_coalesce,
 	.set_coalesce		=3D ipoib_set_coalesce,
 	.get_flags		=3D ethtool_op_get_flags,
@@ -167,5 +166,6 @@ static const struct ethtool_ops ipoib_ethtool_ops =3D=
 {
=20
 void ipoib_set_ethtool_ops(struct net_device *dev)
 {
+	dev->hw_features |=3D NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &ipoib_ethtool_ops);
 }
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e8cc0be..0fd2867 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1559,7 +1559,6 @@ static const struct ethtool_ops cp_ethtool_ops =3D=
 {
 	.get_rx_csum		=3D cp_get_rx_csum,
 	.set_rx_csum		=3D cp_set_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum, /* local! */
-	.set_tso		=3D ethtool_op_set_tso,
 	.get_regs		=3D cp_get_regs,
 	.get_wol		=3D cp_get_wol,
 	.set_wol		=3D cp_set_wol,
@@ -1957,7 +1956,7 @@ static int cp_init_one (struct pci_dev *pdev, con=
st struct pci_device_id *ent)
=20
 	dev->netdev_ops =3D &cp_netdev_ops;
 	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	dev->ethtool_ops =3D &cp_ethtool_ops;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
=20
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1=
e_ethtool.c
index 5beebd5..1485797 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -383,11 +383,10 @@ static const struct ethtool_ops atl1e_ethtool_ops=
 =3D {
 	.get_eeprom             =3D atl1e_get_eeprom,
 	.set_eeprom             =3D atl1e_set_eeprom,
 	.set_tx_csum            =3D ethtool_op_set_tx_hw_csum,
-	.set_tso                =3D ethtool_op_set_tso,
 };
=20
 void atl1e_set_ethtool_ops(struct net_device *netdev)
 {
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &atl1e_ethtool_ops);
 }
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 9e27bd6..814a06c 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2992,6 +2992,7 @@ static int __devinit atl1_probe(struct pci_dev *p=
dev,
 	netdev->watchdog_timeo =3D 5 * HZ;
=20
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO;
 	netdev->ethtool_ops =3D &atl1_ethtool_ops;
 	adapter->bd_number =3D cards_found;
=20
@@ -3682,5 +3683,4 @@ static const struct ethtool_ops atl1_ethtool_ops =
=3D {
 	.nway_reset		=3D atl1_nway_reset,
 	.get_ethtool_stats	=3D atl1_get_ethtool_stats,
 	.get_sset_count		=3D atl1_get_sset_count,
-	.set_tso		=3D ethtool_op_set_tso,
 };
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 1850a00..0d9b688 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -2107,9 +2107,6 @@ static const struct ethtool_ops atl2_ethtool_ops =
=3D {
 	.get_eeprom		=3D atl2_get_eeprom,
 	.set_eeprom		=3D atl2_set_eeprom,
 	.get_tx_csum		=3D atl2_get_tx_csum,
-#ifdef NETIF_F_TSO
-	.get_tso		=3D ethtool_op_get_tso,
-#endif
 };
=20
 static void atl2_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_etht=
ool.c
index 169429c..8c1eaee 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -698,8 +698,6 @@ const struct ethtool_ops be_ethtool_ops =3D {
 	.set_rx_csum =3D be_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ethtool_op_set_tso,
 	.get_strings =3D be_get_stat_strings,
 	.phys_id =3D be_phys_id,
 	.get_sset_count =3D be_get_sset_count,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index dfa231d..b8a164f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2554,7 +2554,7 @@ static void be_netdev_init(struct net_device *net=
dev)
=20
 	BE_SET_NETDEV_OPS(netdev, &be_netdev_ops);
=20
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
=20
 	for_all_rx_queues(adapter, rxo, i)
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_etht=
ool.c
index 207f57b..f8bdebf 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -848,23 +848,6 @@ bnad_set_tx_csum(struct net_device *netdev, u32 tx=
_csum)
 	return 0;
 }
=20
-static int
-bnad_set_tso(struct net_device *netdev, u32 tso)
-{
-	struct bnad *bnad =3D netdev_priv(netdev);
-
-	mutex_lock(&bnad->conf_mutex);
-	if (tso) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-	mutex_unlock(&bnad->conf_mutex);
-	return 0;
-}
-
 static void
 bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string=
)
 {
@@ -1261,8 +1244,6 @@ static struct ethtool_ops bnad_ethtool_ops =3D {
 	.set_rx_csum =3D bnad_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D bnad_set_tx_csum,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D bnad_set_tso,
 	.get_strings =3D bnad_get_strings,
 	.get_ethtool_stats =3D bnad_get_ethtool_stats,
 	.get_sset_count =3D bnad_get_sset_count
@@ -1272,5 +1253,6 @@ void
 bnad_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &bnad_ethtool_ops);
 }
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 50bdafb..8a63a8b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7181,21 +7181,6 @@ bnx2_set_rx_csum(struct net_device *dev, u32 dat=
a)
 	return 0;
 }
=20
-static int
-bnx2_set_tso(struct net_device *dev, u32 data)
-{
-	struct bnx2 *bp =3D netdev_priv(dev);
-
-	if (data) {
-		dev->features |=3D NETIF_F_TSO | NETIF_F_TSO_ECN;
-		if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709)
-			dev->features |=3D NETIF_F_TSO6;
-	} else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6 |
-				   NETIF_F_TSO_ECN);
-	return 0;
-}
-
 static struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2_stats_str_arr[] =3D {
@@ -7569,7 +7554,6 @@ static const struct ethtool_ops bnx2_ethtool_ops =
=3D {
 	.get_rx_csum		=3D bnx2_get_rx_csum,
 	.set_rx_csum		=3D bnx2_set_rx_csum,
 	.set_tx_csum		=3D bnx2_set_tx_csum,
-	.set_tso		=3D bnx2_set_tso,
 	.self_test		=3D bnx2_self_test,
 	.get_strings		=3D bnx2_get_strings,
 	.phys_id		=3D bnx2_phys_id,
@@ -8320,6 +8304,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct =
pci_device_id *ent)
 	dev->netdev_ops =3D &bnx2_netdev_ops;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
 	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO_ECN;
 	dev->ethtool_ops =3D &bnx2_ethtool_ops;
=20
 	bp =3D netdev_priv(dev);
@@ -8344,6 +8329,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct =
pci_device_id *ent)
 	dev->features |=3D NETIF_F_TSO | NETIF_F_TSO_ECN;
 	vlan_features_add(dev, NETIF_F_TSO | NETIF_F_TSO_ECN);
 	if (CHIP_NUM(bp) =3D=3D CHIP_NUM_5709) {
+		dev->hw_features |=3D NETIF_F_TSO6;
 		dev->features |=3D NETIF_F_TSO6;
 		vlan_features_add(dev, NETIF_F_TSO6);
 	}
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2=
x_ethtool.c
index 54955fb..3d08714 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1183,19 +1183,6 @@ static int bnx2x_set_rx_csum(struct net_device *=
dev, u32 data)
 	return rc;
 }
=20
-static int bnx2x_set_tso(struct net_device *dev, u32 data)
-{
-	if (data) {
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO_ECN);
-		dev->features |=3D NETIF_F_TSO6;
-	} else {
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO_ECN);
-		dev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	return 0;
-}
-
 static const struct {
 	char string[ETH_GSTRING_LEN];
 } bnx2x_tests_str_arr[BNX2X_NUM_TESTS] =3D {
@@ -2082,8 +2069,6 @@ static const struct ethtool_ops bnx2x_ethtool_ops=
 =3D {
 	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
 	.set_flags		=3D bnx2x_set_flags,
 	.get_flags		=3D ethtool_op_get_flags,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D bnx2x_set_tso,
 	.self_test		=3D bnx2x_self_test,
 	.get_sset_count		=3D bnx2x_get_sset_count,
 	.get_strings		=3D bnx2x_get_strings,
@@ -2094,5 +2079,6 @@ static const struct ethtool_ops bnx2x_ethtool_ops=
 =3D {
 void bnx2x_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO_ECN|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &bnx2x_ethtool_ops);
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 577b462..4e030c5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4651,7 +4651,6 @@ static const struct ethtool_ops bond_ethtool_ops =
=3D {
 	.get_drvinfo		=3D bond_ethtool_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.get_tso		=3D ethtool_op_get_tso,
 	.get_ufo		=3D ethtool_op_get_ufo,
 	.get_flags		=3D ethtool_op_get_flags,
 };
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 7f63ede..712c413 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -723,15 +723,6 @@ static int set_rx_csum(struct net_device *dev, u32=
 data)
 	return 0;
 }
=20
-static int set_tso(struct net_device *dev, u32 value)
-{
-	struct adapter *adapter =3D dev->ml_priv;
-
-	if (!(adapter->flags & TSO_CAPABLE))
-		return value ? -EOPNOTSUPP : 0;
-	return ethtool_op_set_tso(dev, value);
-}
-
 static void get_sge_param(struct net_device *dev, struct ethtool_ringp=
aram *e)
 {
 	struct adapter *adapter =3D dev->ml_priv;
@@ -840,7 +831,6 @@ static const struct ethtool_ops t1_ethtool_ops =3D =
{
 	.get_ethtool_stats =3D get_stats,
 	.get_regs_len      =3D get_regs_len,
 	.get_regs          =3D get_regs,
-	.set_tso           =3D set_tso,
 };
=20
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd=
)
@@ -1131,6 +1121,8 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
=20
 		netdev->hw_features |=3D NETIF_F_SG;
+		if (adapter->flags & TSO_CAPABLE)
+			netdev->hw_features |=3D NETIF_F_TSO;
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
 	}
=20
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_m=
ain.c
index 2bc7529..1d45f7d 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2106,7 +2106,6 @@ static const struct ethtool_ops cxgb_ethtool_ops =
=3D {
 	.get_regs_len =3D get_regs_len,
 	.get_regs =3D get_regs,
 	.get_wol =3D get_wol,
-	.set_tso =3D ethtool_op_set_tso,
 };
=20
 static int in_range(int val, int lo, int hi)
@@ -3310,7 +3309,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
=20
 		netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->netdev_ops =3D &cxgb_netdev_ops;
-		netdev->hw_features |=3D NETIF_F_SG;
+		netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
=20
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_m=
ain.c
index ac843a3..700bb37 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1870,15 +1870,6 @@ static int set_wol(struct net_device *dev, struc=
t ethtool_wolinfo *wol)
=20
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
=20
-static int set_tso(struct net_device *dev, u32 value)
-{
-	if (value)
-		dev->features |=3D TSO_FLAGS;
-	else
-		dev->features &=3D ~TSO_FLAGS;
-	return 0;
-}
-
 static int set_flags(struct net_device *dev, u32 flags)
 {
 	int err;
@@ -2021,7 +2012,6 @@ static struct ethtool_ops cxgb_ethtool_ops =3D {
 	.get_regs          =3D get_regs,
 	.get_wol           =3D get_wol,
 	.set_wol           =3D set_wol,
-	.set_tso           =3D set_tso,
 	.set_flags         =3D set_flags,
 	.get_rxnfc         =3D get_rxnfc,
 	.get_rxfh_indir    =3D get_rss_table,
@@ -3673,7 +3663,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 		netdev->vlan_features =3D netdev->features & VLAN_FEAT;
=20
 		netdev->netdev_ops =3D &cxgb4_netdev_ops;
-		netdev->hw_features |=3D NETIF_F_SG;
+		netdev->hw_features |=3D NETIF_F_SG | TSO_FLAGS;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
=20
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/c=
xgb4vf_main.c
index ddaba63..61cc28c 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1539,18 +1539,6 @@ static void cxgb4vf_get_wol(struct net_device *d=
ev,
 	memset(&wol->sopass, 0, sizeof(wol->sopass));
 }
=20
-/*
- * Set TCP Segmentation Offloading feature capabilities.
- */
-static int cxgb4vf_set_tso(struct net_device *dev, u32 tso)
-{
-	if (tso)
-		dev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
-	else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-	return 0;
-}
-
 static struct ethtool_ops cxgb4vf_ethtool_ops =3D {
 	.get_settings		=3D cxgb4vf_get_settings,
 	.get_drvinfo		=3D cxgb4vf_get_drvinfo,
@@ -1572,7 +1560,6 @@ static struct ethtool_ops cxgb4vf_ethtool_ops =3D=
 {
 	.get_regs_len		=3D cxgb4vf_get_regs_len,
 	.get_regs		=3D cxgb4vf_get_regs,
 	.get_wol		=3D cxgb4vf_get_wol,
-	.set_tso		=3D cxgb4vf_set_tso,
 };
=20
 /*
@@ -2630,6 +2617,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci=
_dev *pdev,
 #endif
 #endif
 		netdev->hw_features |=3D NETIF_F_SG;
+		netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 		SET_ETHTOOL_OPS(netdev, &cxgb4vf_ethtool_ops);
=20
 		/*
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a881dd0..8f14520 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -299,7 +299,6 @@ struct e1000_adapter {
 	int msg_enable;
=20
 	/* to not mess up cache alignment, always add to the bottom */
-	bool tso_force;
 	bool smart_power_down;	/* phy smart power down */
 	bool quad_port_a;
 	unsigned long flags;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e100=
0_ethtool.c
index 008632c..fcde1b2 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -330,27 +330,6 @@ static int e1000_set_tx_csum(struct net_device *ne=
tdev, u32 data)
 	return 0;
 }
=20
-static int e1000_set_tso(struct net_device *netdev, u32 data)
-{
-	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	struct e1000_hw *hw =3D &adapter->hw;
-
-	if ((hw->mac_type < e1000_82544) ||
-	    (hw->mac_type =3D=3D e1000_82547))
-		return data ? -EINVAL : 0;
-
-	if (data)
-		netdev->features |=3D NETIF_F_TSO;
-	else
-		netdev->features &=3D ~NETIF_F_TSO;
-
-	netdev->features &=3D ~NETIF_F_TSO6;
-
-	e_info(probe, "TSO is %s\n", data ? "Enabled" : "Disabled");
-	adapter->tso_force =3D true;
-	return 0;
-}
-
 static u32 e1000_get_msglevel(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
@@ -1925,7 +1904,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.set_rx_csum            =3D e1000_set_rx_csum,
 	.get_tx_csum            =3D e1000_get_tx_csum,
 	.set_tx_csum            =3D e1000_set_tx_csum,
-	.set_tso                =3D e1000_set_tso,
 	.self_test              =3D e1000_diag_test,
 	.get_strings            =3D e1000_get_strings,
 	.phys_id                =3D e1000_phys_id,
@@ -1937,6 +1915,12 @@ static const struct ethtool_ops e1000_ethtool_op=
s =3D {
=20
 void e1000_set_ethtool_ops(struct net_device *netdev)
 {
+	struct e1000_adapter *adapter =3D netdev_priv(netdev);
+
 	netdev->hw_features |=3D NETIF_F_SG;
+	if (!(adapter->hw.mac_type < e1000_82544) &&
+	    !(adapter->hw.mac_type =3D=3D e1000_82547))
+		netdev->hw_features |=3D NETIF_F_TSO;
+
 	SET_ETHTOOL_OPS(netdev, &e1000_ethtool_ops);
 }
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.=
c
index bb0bcfa..579ed4b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -406,14 +406,6 @@ static int e1000_set_tso(struct net_device *netdev=
, u32 data)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
=20
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-
 	adapter->flags |=3D FLAG_TSO_FORCE;
 	return 0;
 }
@@ -2036,8 +2028,7 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.set_rx_csum		=3D e1000_set_rx_csum,
 	.get_tx_csum		=3D e1000_get_tx_csum,
 	.set_tx_csum		=3D e1000_set_tx_csum,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D e1000_set_tso,
+	.hw_set_tso		=3D e1000_set_tso,
 	.self_test		=3D e1000_diag_test,
 	.get_strings		=3D e1000_get_strings,
 	.phys_id		=3D e1000_phys_id,
@@ -2051,5 +2042,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 void e1000e_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &e1000_ethtool_ops);
 }
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_et=
htool.c
index 75b099c..fb5b9ba 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -267,7 +267,6 @@ const struct ethtool_ops ehea_ethtool_ops =3D {
 	.get_msglevel =3D ehea_get_msglevel,
 	.set_msglevel =3D ehea_set_msglevel,
 	.get_link =3D ethtool_op_get_link,
-	.set_tso =3D ethtool_op_set_tso,
 	.get_strings =3D ehea_get_strings,
 	.get_sset_count =3D ehea_get_sset_count,
 	.get_ethtool_stats =3D ehea_get_ethtool_stats,
@@ -278,5 +277,6 @@ const struct ethtool_ops ehea_ethtool_ops =3D {
=20
 void ehea_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &ehea_ethtool_ops);
 }
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.=
c
index b744fca..88e4a99 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -312,13 +312,6 @@ static int enic_set_tso(struct net_device *netdev,=
 u32 data)
 	if (data && !ENIC_SETTING(enic, TSO))
 		return -EINVAL;
=20
-	if (data)
-		netdev->features |=3D
-			NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN;
-	else
-		netdev->features &=3D
-			~(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN);
-
 	return 0;
 }
=20
@@ -413,8 +406,7 @@ static const struct ethtool_ops enic_ethtool_ops =3D=
 {
 	.set_rx_csum =3D enic_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D enic_set_tx_csum,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D enic_set_tso,
+	.hw_set_tso =3D enic_set_tso,
 	.get_coalesce =3D enic_get_coalesce,
 	.set_coalesce =3D enic_set_coalesce,
 	.get_flags =3D ethtool_op_get_flags,
@@ -2637,6 +2629,7 @@ static int __devinit enic_probe(struct pci_dev *p=
dev,
=20
 	netdev->watchdog_timeo =3D 2 * HZ;
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6|NETIF_F_TSO_ECN;
 	netdev->ethtool_ops =3D &enic_ethtool_ops;
=20
 	netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index fb8c7c9..8aabb6a 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4396,16 +4396,6 @@ static int nv_nway_reset(struct net_device *dev)
 	return ret;
 }
=20
-static int nv_set_tso(struct net_device *dev, u32 value)
-{
-	struct fe_priv *np =3D netdev_priv(dev);
-
-	if ((np->driver_data & DEV_HAS_CHECKSUM))
-		return ethtool_op_set_tso(dev, value);
-	else
-		return -EOPNOTSUPP;
-}
-
 static void nv_get_ringparam(struct net_device *dev, struct ethtool_ri=
ngparam* ring)
 {
 	struct fe_priv *np =3D netdev_priv(dev);
@@ -5029,7 +5019,6 @@ static const struct ethtool_ops ops =3D {
 	.get_regs_len =3D nv_get_regs_len,
 	.get_regs =3D nv_get_regs,
 	.nway_reset =3D nv_nway_reset,
-	.set_tso =3D nv_set_tso,
 	.get_ringparam =3D nv_get_ringparam,
 	.set_ringparam =3D nv_set_ringparam,
 	.get_pauseparam =3D nv_get_pauseparam,
@@ -5565,7 +5554,7 @@ static int __devinit nv_probe(struct pci_dev *pci=
_dev, const struct pci_device_i
=20
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
 	if (np->driver_data & DEV_HAS_CHECKSUM)
-		dev->hw_features |=3D NETIF_F_SG;
+		dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->watchdog_timeo =3D NV_WATCHDOG_TIMEO;
=20
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtoo=
l.c
index 2909af5..de257e4 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -355,23 +355,6 @@ static int igb_set_tx_csum(struct net_device *netd=
ev, u32 data)
 	return 0;
 }
=20
-static int igb_set_tso(struct net_device *netdev, u32 data)
-{
-	struct igb_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	dev_info(&adapter->pdev->dev, "TSO is %s\n",
-		 data ? "Enabled" : "Disabled");
-	return 0;
-}
-
 static u32 igb_get_msglevel(struct net_device *netdev)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
@@ -2193,8 +2176,6 @@ static const struct ethtool_ops igb_ethtool_ops =3D=
 {
 	.set_rx_csum            =3D igb_set_rx_csum,
 	.get_tx_csum            =3D igb_get_tx_csum,
 	.set_tx_csum            =3D igb_set_tx_csum,
-	.get_tso                =3D ethtool_op_get_tso,
-	.set_tso                =3D igb_set_tso,
 	.self_test              =3D igb_diag_test,
 	.get_strings            =3D igb_get_strings,
 	.phys_id                =3D igb_phys_id,
@@ -2207,5 +2188,6 @@ static const struct ethtool_ops igb_ethtool_ops =3D=
 {
 void igb_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &igb_ethtool_ops);
 }
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 9bf5ea0..56f77b6 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -165,23 +165,6 @@ static int igbvf_set_tx_csum(struct net_device *ne=
tdev, u32 data)
 	return 0;
 }
=20
-static int igbvf_set_tso(struct net_device *netdev, u32 data)
-{
-	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
-
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-
-	dev_info(&adapter->pdev->dev, "TSO is %s\n",
-	         data ? "Enabled" : "Disabled");
-	return 0;
-}
-
 static u32 igbvf_get_msglevel(struct net_device *netdev)
 {
 	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
@@ -527,8 +510,6 @@ static const struct ethtool_ops igbvf_ethtool_ops =3D=
 {
 	.set_rx_csum            =3D igbvf_set_rx_csum,
 	.get_tx_csum		=3D igbvf_get_tx_csum,
 	.set_tx_csum		=3D igbvf_set_tx_csum,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D igbvf_set_tso,
 	.self_test		=3D igbvf_diag_test,
 	.get_sset_count		=3D igbvf_get_sset_count,
 	.get_strings		=3D igbvf_get_strings,
@@ -541,6 +522,7 @@ static const struct ethtool_ops igbvf_ethtool_ops =3D=
 {
 void igbvf_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	/* have to "undeclare" const on this struct to remove warnings */
 	SET_ETHTOOL_OPS(netdev, (struct ethtool_ops *)&igbvf_ethtool_ops);
 }
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_et=
htool.c
index 9623e87..b8b38ef 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -234,16 +234,6 @@ ixgb_set_tx_csum(struct net_device *netdev, u32 da=
ta)
 	return 0;
 }
=20
-static int
-ixgb_set_tso(struct net_device *netdev, u32 data)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_TSO;
-	else
-		netdev->features &=3D ~NETIF_F_TSO;
-	return 0;
-}
-
 static u32
 ixgb_get_msglevel(struct net_device *netdev)
 {
@@ -726,7 +716,6 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
 	.set_tx_csum =3D ixgb_set_tx_csum,
 	.get_msglevel =3D ixgb_get_msglevel,
 	.set_msglevel =3D ixgb_set_msglevel,
-	.set_tso =3D ixgb_set_tso,
 	.get_strings =3D ixgb_get_strings,
 	.phys_id =3D ixgb_phys_id,
 	.get_sset_count =3D ixgb_get_sset_count,
@@ -735,6 +724,6 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
=20
 void ixgb_set_ethtool_ops(struct net_device *netdev)
 {
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
 }
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 5f1e17c..561a74d 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -442,18 +442,6 @@ static int ixgbe_set_tx_csum(struct net_device *ne=
tdev, u32 data)
 	return 0;
 }
=20
-static int ixgbe_set_tso(struct net_device *netdev, u32 data)
-{
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-	}
-	return 0;
-}
-
 static u32 ixgbe_get_msglevel(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
@@ -2289,8 +2277,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops=
 =3D {
 	.set_tx_csum            =3D ixgbe_set_tx_csum,
 	.get_msglevel           =3D ixgbe_get_msglevel,
 	.set_msglevel           =3D ixgbe_set_msglevel,
-	.get_tso                =3D ethtool_op_get_tso,
-	.set_tso                =3D ixgbe_set_tso,
 	.self_test              =3D ixgbe_diag_test,
 	.get_strings            =3D ixgbe_get_strings,
 	.phys_id                =3D ixgbe_phys_id,
@@ -2306,5 +2292,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops=
 =3D {
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &ixgbe_ethtool_ops);
 }
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtoo=
l.c
index 624375a..58ae092 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -139,20 +139,6 @@ static int ixgbevf_set_rx_csum(struct net_device *=
netdev, u32 data)
 	return 0;
 }
=20
-static int ixgbevf_set_tso(struct net_device *netdev, u32 data)
-{
-	if (data) {
-		netdev->features |=3D NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_TSO6;
-	} else {
-		netif_tx_stop_all_queues(netdev);
-		netdev->features &=3D ~NETIF_F_TSO;
-		netdev->features &=3D ~NETIF_F_TSO6;
-		netif_tx_start_all_queues(netdev);
-	}
-	return 0;
-}
-
 static u32 ixgbevf_get_msglevel(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
@@ -720,8 +706,6 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D {
 	.set_tx_csum            =3D ethtool_op_set_tx_ipv6_csum,
 	.get_msglevel           =3D ixgbevf_get_msglevel,
 	.set_msglevel           =3D ixgbevf_set_msglevel,
-	.get_tso                =3D ethtool_op_get_tso,
-	.set_tso                =3D ixgbevf_set_tso,
 	.self_test              =3D ixgbevf_diag_test,
 	.get_sset_count         =3D ixgbevf_get_sset_count,
 	.get_strings            =3D ixgbevf_get_strings,
@@ -731,5 +715,6 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D {
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &ixgbevf_ethtool_ops);
 }
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 1f7a0a7..f837c3f 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2530,11 +2530,10 @@ jme_set_tso(struct net_device *netdev, u32 on)
=20
 	if (on) {
 		set_bit(JME_FLAG_TSO, &jme->flags);
-		if (netdev->mtu <=3D 1900)
-			netdev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
+		if (netdev->mtu > 1900)
+			return 1;
 	} else {
 		clear_bit(JME_FLAG_TSO, &jme->flags);
-		netdev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
 	}
=20
 	return 0;
@@ -2684,7 +2683,7 @@ static const struct ethtool_ops jme_ethtool_ops =3D=
 {
 	.get_rx_csum		=3D jme_get_rx_csum,
 	.set_rx_csum		=3D jme_set_rx_csum,
 	.set_tx_csum		=3D jme_set_tx_csum,
-	.set_tso		=3D jme_set_tso,
+	.hw_set_tso		=3D jme_set_tso,
 	.nway_reset             =3D jme_nway_reset,
 	.get_eeprom_len		=3D jme_get_eeprom_len,
 	.get_eeprom		=3D jme_get_eeprom,
@@ -2794,7 +2793,7 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_release_regions;
 	}
 	netdev->netdev_ops =3D &jme_netdev_ops;
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6;
 	netdev->ethtool_ops		=3D &jme_ethtool_ops;
 	netdev->watchdog_timeo		=3D TX_TIMEOUT;
 	netdev->features		=3D	NETIF_F_HW_CSUM |
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 208e9f4..76e900c 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -129,7 +129,6 @@ static u32 always_on(struct net_device *dev)
=20
 static const struct ethtool_ops loopback_ethtool_ops =3D {
 	.get_link		=3D always_on,
-	.set_tso		=3D ethtool_op_set_tso,
 	.get_tx_csum		=3D always_on,
 	.get_rx_csum		=3D always_on,
 };
@@ -174,6 +173,7 @@ static void loopback_setup(struct net_device *dev)
 		| NETIF_F_HIGHDMA
 		| NETIF_F_LLTX
 		| NETIF_F_NETNS_LOCAL;
+	dev->hw_features |=3D NETIF_F_TSO;
 	dev->ethtool_ops	=3D &loopback_ethtool_ops;
 	dev->header_ops		=3D &eth_header_ops;
 	dev->netdev_ops		=3D &loopback_ops;
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtoo=
l.c
index 1b355b7..a963bcd 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -57,21 +57,13 @@ mlx4_en_get_drvinfo(struct net_device *dev, struct =
ethtool_drvinfo *drvinfo)
 	drvinfo->eedump_len =3D 0;
 }
=20
-static u32 mlx4_en_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-
 static int mlx4_en_set_tso(struct net_device *dev, u32 data)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
=20
-	if (data) {
-		if (!priv->mdev->LSO_support)
-			return -EPERM;
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	} else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
+	if (data && !priv->mdev->LSO_support)
+		return -EINVAL;
+
 	return 0;
 }
=20
@@ -426,10 +418,7 @@ const struct ethtool_ops mlx4_en_ethtool_ops =3D {
 	.get_drvinfo =3D mlx4_en_get_drvinfo,
 	.get_settings =3D mlx4_en_get_settings,
 	.set_settings =3D mlx4_en_set_settings,
-#ifdef NETIF_F_TSO
-	.get_tso =3D mlx4_en_get_tso,
-	.set_tso =3D mlx4_en_set_tso,
-#endif
+	.hw_set_tso =3D mlx4_en_set_tso,
 	.get_link =3D ethtool_op_get_link,
 	.get_rx_csum =3D mlx4_en_get_rx_csum,
 	.set_rx_csum =3D mlx4_en_set_rx_csum,
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.=
c
index f496dbc..b867b34 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1039,6 +1039,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev,=
 int port,
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
=20
 	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
=20
 	/* Set defualt MAC */
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index 3696bba..4f8b838 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1773,18 +1773,6 @@ static int myri10ge_set_rx_csum(struct net_devic=
e *netdev, u32 csum_enabled)
 	return err;
 }
=20
-static int myri10ge_set_tso(struct net_device *netdev, u32 tso_enabled=
)
-{
-	struct myri10ge_priv *mgp =3D netdev_priv(netdev);
-	unsigned long flags =3D mgp->features & (NETIF_F_TSO6 | NETIF_F_TSO);
-
-	if (tso_enabled)
-		netdev->features |=3D flags;
-	else
-		netdev->features &=3D ~flags;
-	return 0;
-}
-
 static const char myri10ge_gstrings_main_stats[][ETH_GSTRING_LEN] =3D =
{
 	"rx_packets", "tx_packets", "rx_bytes", "tx_bytes", "rx_errors",
 	"tx_errors", "rx_dropped", "tx_dropped", "multicast", "collisions",
@@ -1951,7 +1939,6 @@ static const struct ethtool_ops myri10ge_ethtool_=
ops =3D {
 	.get_rx_csum =3D myri10ge_get_rx_csum,
 	.set_rx_csum =3D myri10ge_set_rx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
-	.set_tso =3D myri10ge_set_tso,
 	.get_link =3D ethtool_op_get_link,
 	.get_strings =3D myri10ge_get_strings,
 	.get_sset_count =3D myri10ge_get_sset_count,
@@ -3998,6 +3985,7 @@ static int myri10ge_probe(struct pci_dev *pdev, c=
onst struct pci_device_id *ent)
=20
 	spin_lock_init(&mgp->stats_lock);
 	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &myri10ge_ethtool_ops);
 	INIT_WORK(&mgp->watchdog_work, myri10ge_watchdog);
 	status =3D register_netdev(netdev);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netx=
en/netxen_nic_ethtool.c
index f22f0a7..9244bb1 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -724,30 +724,6 @@ static int netxen_nic_set_rx_csum(struct net_devic=
e *dev, u32 data)
 	return 0;
 }
=20
-static u32 netxen_nic_get_tso(struct net_device *dev)
-{
-	struct netxen_adapter *adapter =3D netdev_priv(dev);
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		return (dev->features & (NETIF_F_TSO | NETIF_F_TSO6)) !=3D 0;
-
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-
-static int netxen_nic_set_tso(struct net_device *dev, u32 data)
-{
-	if (data) {
-		struct netxen_adapter *adapter =3D netdev_priv(dev);
-
-		dev->features |=3D NETIF_F_TSO;
-		if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-			dev->features |=3D NETIF_F_TSO6;
-	} else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static void
 netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol=
)
 {
@@ -926,8 +902,6 @@ const struct ethtool_ops netxen_nic_ethtool_ops =3D=
 {
 	.set_pauseparam =3D netxen_nic_set_pauseparam,
 	.get_tx_csum =3D netxen_nic_get_tx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.get_tso =3D netxen_nic_get_tso,
-	.set_tso =3D netxen_nic_set_tso,
 	.get_wol =3D netxen_nic_get_wol,
 	.set_wol =3D netxen_nic_set_wol,
 	.self_test =3D netxen_nic_diag_test,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index 4b2874c..573e51f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1210,7 +1210,9 @@ netxen_setup_netdev(struct netxen_adapter *adapte=
r,
=20
 	netxen_nic_change_mtu(netdev, netdev->mtu);
=20
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netdev->hw_features |=3D NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
=20
 	netdev->features |=3D (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/q=
lcnic_ethtool.c
index ceba22d..abf89ba 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -931,24 +931,6 @@ static int qlcnic_set_rx_csum(struct net_device *d=
ev, u32 data)
 	return 0;
 }
=20
-static u32 qlcnic_get_tso(struct net_device *dev)
-{
-	return (dev->features & (NETIF_F_TSO | NETIF_F_TSO6)) !=3D 0;
-}
-
-static int qlcnic_set_tso(struct net_device *dev, u32 data)
-{
-	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
-	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO))
-		return -EOPNOTSUPP;
-	if (data)
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static int qlcnic_blink_led(struct net_device *dev, u32 val)
 {
 	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
@@ -1166,8 +1148,6 @@ const struct ethtool_ops qlcnic_ethtool_ops =3D {
 	.set_pauseparam =3D qlcnic_set_pauseparam,
 	.get_tx_csum =3D qlcnic_get_tx_csum,
 	.set_tx_csum =3D qlcnic_set_tx_csum,
-	.get_tso =3D qlcnic_get_tso,
-	.set_tso =3D qlcnic_set_tso,
 	.get_wol =3D qlcnic_get_wol,
 	.set_wol =3D qlcnic_set_wol,
 	.self_test =3D qlcnic_diag_test,
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcn=
ic_main.c
index 30ed19a..53e07ed 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1434,6 +1434,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapte=
r,
 		NETIF_F_IPV6_CSUM);
=20
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
+		netdev->hw_features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
 		netdev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
 		netdev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
 	}
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_et=
htool.c
index d8b2d3f..9b7bddf 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -655,19 +655,6 @@ static int ql_set_rx_csum(struct net_device *netde=
v, uint32_t data)
 	return 0;
 }
=20
-static int ql_set_tso(struct net_device *ndev, uint32_t data)
-{
-
-	if (data) {
-		ndev->features |=3D NETIF_F_TSO;
-		ndev->features |=3D NETIF_F_TSO6;
-	} else {
-		ndev->features &=3D ~NETIF_F_TSO;
-		ndev->features &=3D ~NETIF_F_TSO6;
-	}
-	return 0;
-}
-
 static u32 ql_get_msglevel(struct net_device *ndev)
 {
 	struct ql_adapter *qdev =3D netdev_priv(ndev);
@@ -698,8 +685,6 @@ const struct ethtool_ops qlge_ethtool_ops =3D {
 	.set_rx_csum =3D ql_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ql_set_tso,
 	.get_coalesce =3D ql_get_coalesce,
 	.set_coalesce =3D ql_set_coalesce,
 	.get_sset_count =3D ql_get_sset_count,
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index 75b708c..fb36da6 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4714,6 +4714,7 @@ static int __devinit qlge_probe(struct pci_dev *p=
dev,
=20
 	ndev->netdev_ops =3D &qlge_netdev_ops;
 	ndev->hw_features |=3D NETIF_F_SG;
+	ndev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(ndev, &qlge_ethtool_ops);
 	ndev->watchdog_timeo =3D 10 * HZ;
=20
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 746e296..999a713 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1277,7 +1277,6 @@ static const struct ethtool_ops rtl8169_ethtool_o=
ps =3D {
 	.get_rx_csum		=3D rtl8169_get_rx_csum,
 	.set_rx_csum		=3D rtl8169_set_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_tso		=3D ethtool_op_set_tso,
 	.get_regs		=3D rtl8169_get_regs,
 	.get_wol		=3D rtl8169_get_wol,
 	.set_wol		=3D rtl8169_set_wol,
@@ -3172,7 +3171,7 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 		dev->dev_addr[i] =3D RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
=20
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->watchdog_timeo =3D RTL8169_TX_TIMEOUT;
 	dev->irq =3D pdev->irq;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e447a4d..ef63529 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6704,21 +6704,6 @@ static int s2io_ethtool_op_set_tx_csum(struct ne=
t_device *dev, u32 data)
 	return 0;
 }
=20
-static u32 s2io_ethtool_op_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-
-static int s2io_ethtool_op_set_tso(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
 {
 	struct s2io_nic *sp =3D netdev_priv(dev);
@@ -6769,8 +6754,6 @@ static const struct ethtool_ops netdev_ethtool_op=
s =3D {
 	.set_tx_csum =3D s2io_ethtool_op_set_tx_csum,
 	.set_flags =3D s2io_ethtool_set_flags,
 	.get_flags =3D ethtool_op_get_flags,
-	.get_tso =3D s2io_ethtool_op_get_tso,
-	.set_tso =3D s2io_ethtool_op_set_tso,
 	.set_ufo =3D ethtool_op_set_ufo,
 	.self_test =3D s2io_ethtool_test,
 	.get_strings =3D s2io_ethtool_get_strings,
@@ -8034,6 +8017,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct =
pci_device_id *pre)
 	/*  Driver entry points */
 	dev->netdev_ops =3D &s2io_netdev_ops;
 	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->features |=3D NETIF_F_LRO;
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b6b0f5d..26bb98b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1882,7 +1882,9 @@ static int efx_register_netdev(struct efx_nic *ef=
x)
 	net_dev->watchdog_timeo =3D 5 * HZ;
 	net_dev->irq =3D efx->pci_dev->irq;
 	net_dev->netdev_ops =3D &efx_netdev_ops;
-	net_dev->hw_features |=3D NETIF_F_SG;
+	net_dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
+	if (efx->type->offload_features & NETIF_F_V6_CSUM)
+		net_dev->hw_features |=3D NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(net_dev, &efx_ethtool_ops);
=20
 	/* Clear MAC statistics */
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index c994666..dd2b271 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -500,23 +500,6 @@ static void efx_ethtool_get_stats(struct net_devic=
e *net_dev,
 	}
 }
=20
-static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
-{
-	struct efx_nic *efx __attribute__ ((unused)) =3D netdev_priv(net_dev)=
;
-	unsigned long features;
-
-	features =3D NETIF_F_TSO;
-	if (efx->type->offload_features & NETIF_F_V6_CSUM)
-		features |=3D NETIF_F_TSO6;
-
-	if (enable)
-		net_dev->features |=3D features;
-	else
-		net_dev->features &=3D ~features;
-
-	return 0;
-}
-
 static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 ena=
ble)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
@@ -1130,9 +1113,6 @@ const struct ethtool_ops efx_ethtool_ops =3D {
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
 	/* Need to enable/disable IPv6 too */
 	.set_tx_csum		=3D efx_ethtool_set_tx_csum,
-	.get_tso		=3D ethtool_op_get_tso,
-	/* Need to enable/disable TSO-IPv6 too */
-	.set_tso		=3D efx_ethtool_set_tso,
 	.get_flags		=3D ethtool_op_get_flags,
 	.set_flags		=3D efx_ethtool_set_flags,
 	.get_sset_count		=3D efx_ethtool_get_sset_count,
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a06bb6e..98534ef 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4080,7 +4080,7 @@ static int sky2_set_tso(struct net_device *dev, u=
32 data)
 	if (data && no_tx_offload(dev))
 		return -EINVAL;
=20
-	return ethtool_op_set_tso(dev, data);
+	return 0;
 }
=20
 static int sky2_get_eeprom_len(struct net_device *dev)
@@ -4217,7 +4217,7 @@ static const struct ethtool_ops sky2_ethtool_ops =
=3D {
 	.get_eeprom	=3D sky2_get_eeprom,
 	.set_eeprom	=3D sky2_set_eeprom,
 	.set_tx_csum	=3D sky2_set_tx_csum,
-	.set_tso	=3D sky2_set_tso,
+	.hw_set_tso	=3D sky2_set_tso,
 	.get_rx_csum	=3D sky2_get_rx_csum,
 	.set_rx_csum	=3D sky2_set_rx_csum,
 	.get_strings	=3D sky2_get_strings,
@@ -4549,7 +4549,7 @@ static __devinit struct net_device *sky2_init_net=
dev(struct sky2_hw *hw,
=20
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->irq =3D hw->pdev->irq;
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &sky2_ethtool_ops);
 	dev->watchdog_timeo =3D TX_WATCHDOG;
 	dev->netdev_ops =3D &sky2_netdev_ops[port];
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/s=
tmmac_ethtool.c
index 4461a9e..0674ebb 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -378,12 +378,10 @@ static struct ethtool_ops stmmac_ethtool_ops =3D =
{
 	.get_wol =3D stmmac_get_wol,
 	.set_wol =3D stmmac_set_wol,
 	.get_sset_count	=3D stmmac_get_sset_count,
-	.get_tso =3D ethtool_op_get_tso,
-	.set_tso =3D ethtool_op_set_tso,
 };
=20
 void stmmac_set_ethtool_ops(struct net_device *netdev)
 {
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &stmmac_ethtool_ops);
 }
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index ed6dc44..42913bf 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2426,7 +2426,6 @@ static void bdx_set_ethtool_ops(struct net_device=
 *netdev)
 		.set_ringparam =3D bdx_set_ringparam,
 		.get_rx_csum =3D bdx_get_rx_csum,
 		.get_tx_csum =3D bdx_get_tx_csum,
-		.get_tso =3D ethtool_op_get_tso,
 		.get_strings =3D bdx_get_strings,
 		.get_sset_count =3D bdx_get_sset_count,
 		.get_ethtool_stats =3D bdx_get_ethtool_stats,
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b07e2d1..c08172d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6142,7 +6142,7 @@ static inline void tg3_set_mtu(struct net_device =
*dev, struct tg3 *tp,
 	if (new_mtu > ETH_DATA_LEN) {
 		if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
 			tp->tg3_flags2 &=3D ~TG3_FLG2_TSO_CAPABLE;
-			ethtool_op_set_tso(dev, 0);
+			dev->features &=3D ~NETIF_F_ALL_TSO;
 		} else {
 			tp->tg3_flags |=3D TG3_FLAG_JUMBO_RING_ENABLE;
 		}
@@ -9977,27 +9977,28 @@ static int tg3_set_tso(struct net_device *dev, =
u32 value)
 {
 	struct tg3 *tp =3D netdev_priv(dev);
=20
-	if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE)) {
-		if (value)
-			return -EINVAL;
+	if (!(tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) && value)
+		return -EINVAL;
+
+	if (!value)
 		return 0;
-	}
+
+	dev->features |=3D NETIF_F_TSO;
+
 	if ((dev->features & NETIF_F_IPV6_CSUM) &&
 	    ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) ||
 	     (tp->tg3_flags2 & TG3_FLG2_HW_TSO_3))) {
-		if (value) {
-			dev->features |=3D NETIF_F_TSO6;
-			if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5761 ||
-			    (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5784 &&
-			     GET_CHIP_REV(tp->pci_chip_rev_id) !=3D CHIPREV_5784_AX) ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5785 ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_57780)
-				dev->features |=3D NETIF_F_TSO_ECN;
-		} else
-			dev->features &=3D ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
+		dev->features |=3D NETIF_F_TSO6;
+		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_3) ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5761 ||
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5784 &&
+		     GET_CHIP_REV(tp->pci_chip_rev_id) !=3D CHIPREV_5784_AX) ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5785 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_57780)
+			dev->features |=3D NETIF_F_TSO_ECN;
 	}
-	return ethtool_op_set_tso(dev, value);
+
+	return 1;
 }
=20
 static int tg3_nway_reset(struct net_device *dev)
@@ -11306,7 +11307,7 @@ static const struct ethtool_ops tg3_ethtool_ops=
 =3D {
 	.get_rx_csum		=3D tg3_get_rx_csum,
 	.set_rx_csum		=3D tg3_set_rx_csum,
 	.set_tx_csum		=3D tg3_set_tx_csum,
-	.set_tso		=3D tg3_set_tso,
+	.hw_set_tso		=3D tg3_set_tso,
 	.self_test		=3D tg3_self_test,
 	.get_strings		=3D tg3_get_strings,
 	.phys_id		=3D tg3_phys_id,
@@ -14681,6 +14682,7 @@ static int __devinit tg3_init_one(struct pci_de=
v *pdev,
 	tp->rx_jumbo_pending =3D TG3_DEF_RX_JUMBO_RING_PENDING;
=20
 	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6|NETIF_F_TSO_ECN;
 	dev->ethtool_ops =3D &tg3_ethtool_ops;
 	dev->watchdog_timeo =3D TG3_TX_TIMEOUT;
 	dev->irq =3D pdev->irq;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 4b49dd7..cc2f811 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1191,7 +1191,6 @@ static const struct ethtool_ops typhoon_ethtool_o=
ps =3D {
 	.get_link		=3D ethtool_op_get_link,
 	.get_rx_csum		=3D typhoon_get_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_tso		=3D ethtool_op_set_tso,
 	.get_ringparam		=3D typhoon_get_ringparam,
 	.set_flags		=3D typhoon_set_flags,
 	.get_flags		=3D ethtool_op_get_flags,
@@ -2479,7 +2478,7 @@ typhoon_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 	netif_napi_add(dev, &tp->napi, typhoon_poll, 16);
 	dev->watchdog_timeo	=3D TX_TIMEOUT;
=20
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &typhoon_ethtool_ops);
=20
 	/* We can handle scatter gather, up to 16 entries, and
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 753ee6e..466ed50 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -617,16 +617,6 @@ static int smsc75xx_ethtool_set_rx_csum(struct net=
_device *netdev, u32 val)
 	return smsc75xx_set_rx_csum_offload(dev);
 }
=20
-static int smsc75xx_ethtool_set_tso(struct net_device *netdev, u32 dat=
a)
-{
-	if (data)
-		netdev->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
-	else
-		netdev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static const struct ethtool_ops smsc75xx_ethtool_ops =3D {
 	.get_link	=3D usbnet_get_link,
 	.nway_reset	=3D usbnet_nway_reset,
@@ -642,8 +632,6 @@ static const struct ethtool_ops smsc75xx_ethtool_op=
s =3D {
 	.set_tx_csum	=3D ethtool_op_set_tx_hw_csum,
 	.get_rx_csum	=3D smsc75xx_ethtool_get_rx_csum,
 	.set_rx_csum	=3D smsc75xx_ethtool_set_rx_csum,
-	.get_tso	=3D ethtool_op_get_tso,
-	.set_tso	=3D smsc75xx_ethtool_set_tso,
 };
=20
 static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq,=
 int cmd)
@@ -964,8 +952,6 @@ static int smsc75xx_reset(struct usbnet *dev)
 	ret =3D smsc75xx_set_rx_csum_offload(dev);
 	check_warn_return(ret, "Failed to set rx csum offload: %d", ret);
=20
-	smsc75xx_ethtool_set_tso(dev->net, DEFAULT_TSO_ENABLE);
-
 	smsc75xx_set_multicast(dev->net);
=20
 	ret =3D smsc75xx_phy_initialize(dev);
@@ -1069,11 +1055,14 @@ static int smsc75xx_bind(struct usbnet *dev, st=
ruct usb_interface *intf)
=20
 	/* We have to advertise SG otherwise TSO cannot be enabled */
 	dev->net->features |=3D NETIF_F_SG;
+	if (DEFAULT_TSO_ENABLE)
+		dev->net->features |=3D NETIF_F_TSO | NETIF_F_TSO6;
=20
 	/* Init all registers */
 	ret =3D smsc75xx_reset(dev);
=20
 	dev->net->netdev_ops =3D &smsc75xx_netdev_ops;
+	dev->net->hw_features |=3D NETIF_F_TSO | NETIF_F_TSO6;
 	dev->net->ethtool_ops =3D &smsc75xx_ethtool_ops;
 	dev->net->flags |=3D IFF_MULTICAST;
 	dev->net->hard_header_len +=3D SMSC75XX_TX_OVERHEAD;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b332e92..037913f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -818,7 +818,6 @@ static void virtnet_vlan_rx_kill_vid(struct net_dev=
ice *dev, u16 vid)
=20
 static const struct ethtool_ops virtnet_ethtool_ops =3D {
 	.set_tx_csum =3D virtnet_set_tx_csum,
-	.set_tso =3D ethtool_op_set_tso,
 	.set_ufo =3D ethtool_op_set_ufo,
 	.get_link =3D ethtool_op_get_link,
 };
@@ -902,7 +901,7 @@ static int virtnet_probe(struct virtio_device *vdev=
)
 	/* Set up network device as normal. */
 	dev->netdev_ops =3D &virtnet_netdev;
 	dev->features =3D NETIF_F_HIGHDMA;
-	dev->hw_features |=3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
=20
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet=
3/vmxnet3_ethtool.c
index 9925d2b..a43c5fb 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -547,8 +547,6 @@ static struct ethtool_ops vmxnet3_ethtool_ops =3D {
 	.set_rx_csum       =3D vmxnet3_set_rx_csum,
 	.get_tx_csum       =3D ethtool_op_get_tx_csum,
 	.set_tx_csum       =3D ethtool_op_set_tx_hw_csum,
-	.get_tso           =3D ethtool_op_get_tso,
-	.set_tso           =3D ethtool_op_set_tso,
 	.get_strings       =3D vmxnet3_get_strings,
 	.get_flags	   =3D ethtool_op_get_flags,
 	.set_flags	   =3D vmxnet3_set_flags,
@@ -560,6 +558,6 @@ static struct ethtool_ops vmxnet3_ethtool_ops =3D {
=20
 void vmxnet3_set_ethtool_ops(struct net_device *netdev)
 {
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &vmxnet3_ethtool_ops);
 }
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-et=
htool.c
index 3c7ccd0..df9e500 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1090,16 +1090,6 @@ static int vxge_set_rx_csum(struct net_device *d=
ev, u32 data)
 	return 0;
 }
=20
-static int vxge_ethtool_op_set_tso(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static int vxge_ethtool_get_sset_count(struct net_device *dev, int sse=
t)
 {
 	struct vxgedev *vdev =3D (struct vxgedev *)netdev_priv(dev);
@@ -1132,8 +1122,6 @@ static const struct ethtool_ops vxge_ethtool_ops =
=3D {
 	.set_rx_csum		=3D vxge_set_rx_csum,
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
-	.get_tso		=3D ethtool_op_get_tso,
-	.set_tso		=3D vxge_ethtool_op_set_tso,
 	.get_strings		=3D vxge_ethtool_get_strings,
 	.phys_id		=3D vxge_ethtool_idnic,
 	.get_sset_count		=3D vxge_ethtool_get_sset_count,
@@ -1143,5 +1131,6 @@ static const struct ethtool_ops vxge_ethtool_ops =
=3D {
 void vxge_initialize_ethtool_ops(struct net_device *ndev)
 {
 	ndev->hw_features |=3D NETIF_F_SG;
+	ndev->hw_features |=3D NETIF_F_TSO|NETIF_F_TSO6;
 	SET_ETHTOOL_OPS(ndev, &vxge_ethtool_ops);
 }
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index e494cc2..5715ba6 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1178,7 +1178,7 @@ static struct net_device * __devinit xennet_creat=
e_dev(struct xenbus_device *dev
 	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
 	netdev->features        =3D NETIF_F_IP_CSUM;
=20
-	netdev->hw_features |=3D NETIF_F_SG;
+	netdev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
=20
@@ -1508,7 +1508,7 @@ static int xennet_set_tso(struct net_device *dev,=
 u32 data)
 			return -ENOSYS;
 	}
=20
-	return ethtool_op_set_tso(dev, data);
+	return 0;
 }
=20
 static void xennet_set_features(struct net_device *dev)
@@ -1525,7 +1525,8 @@ static void xennet_set_features(struct net_device=
 *dev)
=20
 	if (!xennet_set_sg(dev, 1)) {
 		dev->features |=3D NETIF_F_SG;
-		xennet_set_tso(dev, 1);
+		if (!xennet_set_tso(dev, 1))
+			dev->features |=3D NETIF_F_TSO;
 	}
 }
=20
@@ -1640,7 +1641,7 @@ static const struct ethtool_ops xennet_ethtool_op=
s =3D
 {
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.hw_set_sg =3D xennet_set_sg,
-	.set_tso =3D xennet_set_tso,
+	.hw_set_tso =3D xennet_set_tso,
 	.get_link =3D ethtool_op_get_link,
 };
=20
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3=
_main.c
index 5fd646f..efd49c9 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3230,7 +3230,7 @@ static int qeth_l3_ethtool_set_tso(struct net_dev=
ice *dev, u32 data)
 		dev->features &=3D ~NETIF_F_TSO;
 		card->options.large_send =3D QETH_LARGE_SEND_NO;
 	}
-	return rc;
+	return rc ? rc : 1;
 }
=20
 static int qeth_l3_ethtool_set_tx_csum(struct net_device *dev, u32 dat=
a)
@@ -3254,8 +3254,7 @@ static const struct ethtool_ops qeth_l3_ethtool_o=
ps =3D {
 	.set_tx_csum =3D qeth_l3_ethtool_set_tx_csum,
 	.get_rx_csum =3D qeth_l3_ethtool_get_rx_csum,
 	.set_rx_csum =3D qeth_l3_ethtool_set_rx_csum,
-	.get_tso     =3D ethtool_op_get_tso,
-	.set_tso     =3D qeth_l3_ethtool_set_tso,
+	.hw_set_tso  =3D qeth_l3_ethtool_set_tso,
 	.get_strings =3D qeth_core_get_strings,
 	.get_ethtool_stats =3D qeth_core_get_ethtool_stats,
 	.get_sset_count =3D qeth_core_get_sset_count,
@@ -3355,7 +3354,7 @@ static int qeth_l3_setup_netdev(struct qeth_card =
*card)
 	card->dev->ml_priv =3D card;
 	card->dev->watchdog_timeo =3D QETH_TX_TIMEOUT;
 	card->dev->mtu =3D card->info.initial_mtu;
-	card->dev->hw_features |=3D NETIF_F_SG;
+	card->dev->hw_features |=3D NETIF_F_SG|NETIF_F_TSO;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
 	card->dev->features |=3D	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 6b26e3e..0efb1c9 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -548,8 +548,6 @@ u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data);
-u32 ethtool_op_get_tso(struct net_device *dev);
-int ethtool_op_set_tso(struct net_device *dev, u32 data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
 u32 ethtool_op_get_flags(struct net_device *dev);
@@ -581,8 +579,7 @@ void ethtool_ntuple_flush(struct net_device *dev);
  * get_tx_csum: Report whether transmit checksums are turned on or off
  * set_tx_csum: Turn transmit checksums on or off
  * hw_set_sg: Turn scatter-gather on or off
- * get_tso: Report whether TCP segmentation offload is enabled
- * set_tso: Turn TCP segmentation offload on or off
+ * hw_set_tso: Turn TCP segmentation offload on or off
  * get_ufo: Report whether UDP fragmentation offload is enabled
  * set_ufo: Turn UDP fragmentation offload on or off
  * self_test: Run specified self-tests
@@ -646,8 +643,7 @@ struct ethtool_ops {
 	u32	(*get_tx_csum)(struct net_device *);
 	int	(*set_tx_csum)(struct net_device *, u32);
 	int	(*hw_set_sg)(struct net_device *, u32);
-	u32	(*get_tso)(struct net_device *);
-	int	(*set_tso)(struct net_device *, u32);
+	int	(*hw_set_tso)(struct net_device *, u32);
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
 	int	(*phys_id)(struct net_device *, u32);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f11a5a1..1c35967 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -877,6 +877,8 @@ struct net_device {
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
=20
+#define NETIF_F_ALL_TSO		(NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6=
)
+
 	/*
 	 * If one device supports one of these features, then enable them
 	 * for all in netdev_increment_features.
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 14e3d1f..fae31b1 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -872,7 +872,7 @@ static int vlan_ethtool_set_tso(struct net_device *=
dev, u32 data)
 	} else {
 		dev->features &=3D ~NETIF_F_TSO;
 	}
-	return 0;
+	return 1;
 }
=20
 static const struct ethtool_ops vlan_ethtool_ops =3D {
@@ -881,7 +881,7 @@ static const struct ethtool_ops vlan_ethtool_ops =3D=
 {
 	.get_link		=3D ethtool_op_get_link,
 	.get_rx_csum		=3D vlan_ethtool_get_rx_csum,
 	.get_flags		=3D vlan_ethtool_get_flags,
-	.set_tso                =3D vlan_ethtool_set_tso,
+	.hw_set_tso             =3D vlan_ethtool_set_tso,
 };
=20
 static const struct net_device_ops vlan_netdev_ops =3D {
@@ -992,6 +992,7 @@ void vlan_setup(struct net_device *dev)
=20
 	dev->netdev_ops		=3D &vlan_netdev_ops;
 	dev->destructor		=3D free_netdev;
+	dev->hw_features	=3D NETIF_F_ALL_TSO;
 	dev->ethtool_ops	=3D &vlan_ethtool_ops;
=20
 	memset(dev->broadcast, 0, ETH_ALEN);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 3d12ebc..dbda588 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -196,7 +196,7 @@ static int br_set_tso(struct net_device *dev, u32 d=
ata)
 		br->feature_mask &=3D ~NETIF_F_TSO;
=20
 	br_features_recompute(br);
-	return 0;
+	return 1;
 }
=20
 static int br_set_tx_csum(struct net_device *dev, u32 data)
@@ -303,8 +303,7 @@ static const struct ethtool_ops br_ethtool_ops =3D =
{
 	.get_tx_csum	=3D ethtool_op_get_tx_csum,
 	.set_tx_csum 	=3D br_set_tx_csum,
 	.hw_set_sg	=3D br_set_sg,
-	.get_tso	=3D ethtool_op_get_tso,
-	.set_tso	=3D br_set_tso,
+	.hw_set_tso	=3D br_set_tso,
 	.get_ufo	=3D ethtool_op_get_ufo,
 	.set_ufo	=3D ethtool_op_set_ufo,
 	.get_flags	=3D ethtool_op_get_flags,
@@ -342,7 +341,7 @@ void br_dev_setup(struct net_device *dev)
=20
 	dev->netdev_ops =3D &br_netdev_ops;
 	dev->destructor =3D br_dev_free;
-	dev->hw_features =3D NETIF_F_SG;
+	dev->hw_features |=3D NETIF_F_SG|NETIF_F_ALL_TSO;
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	dev->tx_queue_len =3D 0;
 	dev->priv_flags =3D IFF_EBRIDGE;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 017667c..9b0e598 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -78,23 +78,6 @@ int ethtool_op_set_tx_ipv6_csum(struct net_device *d=
ev, u32 data)
 }
 EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
=20
-u32 ethtool_op_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_tso);
-
-int ethtool_op_set_tso(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_TSO;
-	else
-		dev->features &=3D ~NETIF_F_TSO;
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_tso);
-
 u32 ethtool_op_get_ufo(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_UFO) !=3D 0;
@@ -1065,10 +1048,13 @@ static int __ethtool_set_sg(struct net_device *=
dev, u32 data)
 {
 	int err;
=20
-	if (!data && dev->ethtool_ops->set_tso) {
-		err =3D dev->ethtool_ops->set_tso(dev, 0);
-		if (err)
-			return err;
+	if (!data && (dev->hw_features & NETIF_F_ALL_TSO)) {
+		if (dev->ethtool_ops->hw_set_tso) {
+			err =3D dev->ethtool_ops->hw_set_tso(dev, 0);
+			if (err < 0)
+				return err;
+		}
+		dev->features &=3D dev->hw_features & NETIF_F_ALL_TSO;
 	}
=20
 	if (!data && dev->ethtool_ops->set_ufo) {
@@ -1145,11 +1131,16 @@ static int ethtool_set_sg(struct net_device *de=
v, char __user *useraddr)
 	return __ethtool_set_sg(dev, edata.data);
 }
=20
+static u32 ethtool_get_tso(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_ALL_TSO) !=3D 0;
+}
+
 static int ethtool_set_tso(struct net_device *dev, char __user *userad=
dr)
 {
 	struct ethtool_value edata;
=20
-	if (!dev->ethtool_ops->set_tso)
+	if (!(dev->hw_features & NETIF_F_ALL_TSO))
 		return -EOPNOTSUPP;
=20
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
@@ -1158,7 +1149,18 @@ static int ethtool_set_tso(struct net_device *de=
v, char __user *useraddr)
 	if (edata.data && !(dev->features & NETIF_F_SG))
 		return -EINVAL;
=20
-	return dev->ethtool_ops->set_tso(dev, edata.data);
+	if (dev->ethtool_ops->hw_set_tso) {
+		int err =3D dev->ethtool_ops->hw_set_tso(dev, edata.data);
+		if (err)
+			return min(err, 0);
+	}
+
+	if (edata.data)
+		dev->features |=3D dev->hw_features & NETIF_F_ALL_TSO;
+	else
+		dev->features &=3D ~NETIF_F_ALL_TSO;
+
+	return 0;
 }
=20
 static int ethtool_set_ufo(struct net_device *dev, char __user *userad=
dr)
@@ -1582,9 +1584,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		break;
 	case ETHTOOL_GTSO:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_tso ?
-					dev->ethtool_ops->get_tso :
-					ethtool_op_get_tso));
+					ethtool_get_tso);
 		break;
 	case ETHTOOL_STSO:
 		rc =3D ethtool_set_tso(dev, useraddr);
--=20
1.7.1

