From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 2/4] Ethtool: convert get_sg/set_sg calls to hw_features flag
Date: Sat, 30 Oct 2010 06:28:26 +0200
Message-ID: <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl>
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
Received: from rere.qmqm.pl ([89.167.52.164]:49491 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750730Ab0JaEAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Oct 2010 00:00:32 -0400
In-Reply-To: <cover.1288496404.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/infiniband/hw/nes/nes_nic.c     |    3 +-
 drivers/net/8139cp.c                    |    2 +-
 drivers/net/atl1c/atl1c_ethtool.c       |    3 +-
 drivers/net/atl1e/atl1e_ethtool.c       |    2 +-
 drivers/net/atlx/atl1.c                 |    2 +-
 drivers/net/atlx/atl2.c                 |    3 +-
 drivers/net/benet/be_ethtool.c          |    2 -
 drivers/net/benet/be_main.c             |    1 +
 drivers/net/bna/bnad_ethtool.c          |    3 +-
 drivers/net/bnx2.c                      |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c       |    3 +-
 drivers/net/bonding/bond_main.c         |    1 -
 drivers/net/chelsio/cxgb2.c             |    2 +-
 drivers/net/cxgb3/cxgb3_main.c          |    2 +-
 drivers/net/cxgb4/cxgb4_main.c          |    2 +-
 drivers/net/cxgb4vf/cxgb4vf_main.c      |    2 +-
 drivers/net/e1000/e1000_ethtool.c       |    2 +-
 drivers/net/e1000e/ethtool.c            |    3 +-
 drivers/net/enic/enic_main.c            |    3 +-
 drivers/net/forcedeth.c                 |   13 +-------
 drivers/net/fs_enet/fs_enet-main.c      |    2 +-
 drivers/net/gianfar.c                   |    1 +
 drivers/net/gianfar_ethtool.c           |    1 -
 drivers/net/ibm_newemac/core.c          |    1 -
 drivers/net/ibmveth.c                   |    2 +-
 drivers/net/igb/igb_ethtool.c           |    3 +-
 drivers/net/igbvf/ethtool.c             |    3 +-
 drivers/net/ixgb/ixgb_ethtool.c         |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c       |    3 +-
 drivers/net/ixgbevf/ethtool.c           |    3 +-
 drivers/net/jme.c                       |    2 +-
 drivers/net/ksz884x.c                   |    3 +-
 drivers/net/loopback.c                  |    1 -
 drivers/net/mlx4/en_ethtool.c           |    2 -
 drivers/net/mlx4/en_netdev.c            |    1 +
 drivers/net/mv643xx_eth.c               |    2 +-
 drivers/net/myri10ge/myri10ge.c         |    2 +-
 drivers/net/netxen/netxen_nic_ethtool.c |    1 -
 drivers/net/netxen/netxen_nic_main.c    |    1 +
 drivers/net/qlcnic/qlcnic_ethtool.c     |    1 -
 drivers/net/qlcnic/qlcnic_main.c        |    1 +
 drivers/net/qlge/qlge_ethtool.c         |    2 -
 drivers/net/qlge/qlge_main.c            |    1 +
 drivers/net/r8169.c                     |    2 +-
 drivers/net/s2io.c                      |    2 +-
 drivers/net/sfc/efx.c                   |    1 +
 drivers/net/sfc/ethtool.c               |    2 -
 drivers/net/skge.c                      |   13 +-------
 drivers/net/sky2.c                      |    2 +-
 drivers/net/stmmac/stmmac_ethtool.c     |    3 +-
 drivers/net/tehuti.c                    |    1 -
 drivers/net/tg3.c                       |    2 +-
 drivers/net/typhoon.c                   |    2 +-
 drivers/net/ucc_geth_ethtool.c          |    2 +-
 drivers/net/veth.c                      |    3 +-
 drivers/net/via-velocity.c              |    2 +-
 drivers/net/virtio_net.c                |    2 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c   |    3 +-
 drivers/net/vxge/vxge-ethtool.c         |    3 +-
 drivers/net/xen-netfront.c              |   10 +++++--
 drivers/s390/net/qeth_l3_main.c         |    3 +-
 drivers/staging/hv/netvsc_drv.c         |    3 +-
 drivers/staging/octeon/ethernet-mdio.c  |    1 -
 include/linux/ethtool.h                 |    8 +----
 net/bridge/br_device.c                  |    6 ++--
 net/core/ethtool.c                      |   46 +++++++++++++++--------=
--------
 net/dsa/slave.c                         |    2 +-
 67 files changed, 87 insertions(+), 134 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/h=
w/nes/nes_nic.c
index 3892e2c..6056913 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1585,7 +1585,6 @@ static const struct ethtool_ops nes_ethtool_ops =3D=
 {
 	.set_settings =3D nes_netdev_set_settings,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.get_rx_csum =3D nes_netdev_get_rx_csum,
-	.get_sg =3D ethtool_op_get_sg,
 	.get_strings =3D nes_netdev_get_strings,
 	.get_sset_count =3D nes_netdev_get_sset_count,
 	.get_ethtool_stats =3D nes_netdev_get_ethtool_stats,
@@ -1596,7 +1595,6 @@ static const struct ethtool_ops nes_ethtool_ops =3D=
 {
 	.set_pauseparam =3D nes_netdev_set_pauseparam,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
 	.set_rx_csum =3D nes_netdev_set_rx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D ethtool_op_get_tso,
 	.set_tso =3D ethtool_op_set_tso,
 	.get_flags =3D ethtool_op_get_flags,
@@ -1672,6 +1670,7 @@ struct net_device *nes_netdev_init(struct nes_dev=
ice *nesdev,
 	netdev->type =3D ARPHRD_ETHER;
 	netdev->features =3D NETIF_F_HIGHDMA;
 	netdev->netdev_ops =3D &nes_netdev_ops;
+	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->ethtool_ops =3D &nes_ethtool_ops;
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index ac422cd..e8cc0be 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1559,7 +1559,6 @@ static const struct ethtool_ops cp_ethtool_ops =3D=
 {
 	.get_rx_csum		=3D cp_get_rx_csum,
 	.set_rx_csum		=3D cp_set_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum, /* local! */
-	.set_sg			=3D ethtool_op_set_sg,
 	.set_tso		=3D ethtool_op_set_tso,
 	.get_regs		=3D cp_get_regs,
 	.get_wol		=3D cp_get_wol,
@@ -1958,6 +1957,7 @@ static int cp_init_one (struct pci_dev *pdev, con=
st struct pci_device_id *ent)
=20
 	dev->netdev_ops =3D &cp_netdev_ops;
 	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
+	dev->hw_features |=3D NETIF_F_SG;
 	dev->ethtool_ops =3D &cp_ethtool_ops;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
=20
diff --git a/drivers/net/atl1c/atl1c_ethtool.c b/drivers/net/atl1c/atl1=
c_ethtool.c
index 7c52150..d517223 100644
--- a/drivers/net/atl1c/atl1c_ethtool.c
+++ b/drivers/net/atl1c/atl1c_ethtool.c
@@ -308,11 +308,10 @@ static const struct ethtool_ops atl1c_ethtool_ops=
 =3D {
 	.get_eeprom_len         =3D atl1c_get_eeprom_len,
 	.get_eeprom             =3D atl1c_get_eeprom,
 	.get_tx_csum            =3D atl1c_get_tx_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
 };
=20
 void atl1c_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &atl1c_ethtool_ops);
 }
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1=
e_ethtool.c
index 6943a6c..5beebd5 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -383,11 +383,11 @@ static const struct ethtool_ops atl1e_ethtool_ops=
 =3D {
 	.get_eeprom             =3D atl1e_get_eeprom,
 	.set_eeprom             =3D atl1e_set_eeprom,
 	.set_tx_csum            =3D ethtool_op_set_tx_hw_csum,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.set_tso                =3D ethtool_op_set_tso,
 };
=20
 void atl1e_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &atl1e_ethtool_ops);
 }
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 43579b3..9e27bd6 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2991,6 +2991,7 @@ static int __devinit atl1_probe(struct pci_dev *p=
dev,
 	netdev->netdev_ops =3D &atl1_netdev_ops;
 	netdev->watchdog_timeo =3D 5 * HZ;
=20
+	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->ethtool_ops =3D &atl1_ethtool_ops;
 	adapter->bd_number =3D cards_found;
=20
@@ -3677,7 +3678,6 @@ static const struct ethtool_ops atl1_ethtool_ops =
=3D {
 	.get_rx_csum		=3D atl1_get_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
 	.get_link		=3D ethtool_op_get_link,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D atl1_get_strings,
 	.nway_reset		=3D atl1_nway_reset,
 	.get_ethtool_stats	=3D atl1_get_ethtool_stats,
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 35b14be..1850a00 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -2107,8 +2107,6 @@ static const struct ethtool_ops atl2_ethtool_ops =
=3D {
 	.get_eeprom		=3D atl2_get_eeprom,
 	.set_eeprom		=3D atl2_set_eeprom,
 	.get_tx_csum		=3D atl2_get_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 #ifdef NETIF_F_TSO
 	.get_tso		=3D ethtool_op_get_tso,
 #endif
@@ -2116,6 +2114,7 @@ static const struct ethtool_ops atl2_ethtool_ops =
=3D {
=20
 static void atl2_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &atl2_ethtool_ops);
 }
=20
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_etht=
ool.c
index 0f46366..169429c 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -698,8 +698,6 @@ const struct ethtool_ops be_ethtool_ops =3D {
 	.set_rx_csum =3D be_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D ethtool_op_get_tso,
 	.set_tso =3D ethtool_op_set_tso,
 	.get_strings =3D be_get_stat_strings,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c36cd2f..dfa231d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2554,6 +2554,7 @@ static void be_netdev_init(struct net_device *net=
dev)
=20
 	BE_SET_NETDEV_OPS(netdev, &be_netdev_ops);
=20
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &be_ethtool_ops);
=20
 	for_all_rx_queues(adapter, rxo, i)
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_etht=
ool.c
index 11fa2ea..207f57b 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -1261,8 +1261,6 @@ static struct ethtool_ops bnad_ethtool_ops =3D {
 	.set_rx_csum =3D bnad_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D bnad_set_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D ethtool_op_get_tso,
 	.set_tso =3D bnad_set_tso,
 	.get_strings =3D bnad_get_strings,
@@ -1273,5 +1271,6 @@ static struct ethtool_ops bnad_ethtool_ops =3D {
 void
 bnad_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &bnad_ethtool_ops);
 }
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 062600b..50bdafb 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7569,7 +7569,6 @@ static const struct ethtool_ops bnx2_ethtool_ops =
=3D {
 	.get_rx_csum		=3D bnx2_get_rx_csum,
 	.set_rx_csum		=3D bnx2_set_rx_csum,
 	.set_tx_csum		=3D bnx2_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.set_tso		=3D bnx2_set_tso,
 	.self_test		=3D bnx2_self_test,
 	.get_strings		=3D bnx2_get_strings,
@@ -8320,6 +8319,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct =
pci_device_id *ent)
=20
 	dev->netdev_ops =3D &bnx2_netdev_ops;
 	dev->watchdog_timeo =3D TX_TIMEOUT;
+	dev->hw_features |=3D NETIF_F_SG;
 	dev->ethtool_ops =3D &bnx2_ethtool_ops;
=20
 	bp =3D netdev_priv(dev);
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2=
x_ethtool.c
index d02ffbd..54955fb 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -2082,8 +2082,6 @@ static const struct ethtool_ops bnx2x_ethtool_ops=
 =3D {
 	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
 	.set_flags		=3D bnx2x_set_flags,
 	.get_flags		=3D ethtool_op_get_flags,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
 	.set_tso		=3D bnx2x_set_tso,
 	.self_test		=3D bnx2x_self_test,
@@ -2095,5 +2093,6 @@ static const struct ethtool_ops bnx2x_ethtool_ops=
 =3D {
=20
 void bnx2x_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &bnx2x_ethtool_ops);
 }
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index bdb68a6..577b462 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4651,7 +4651,6 @@ static const struct ethtool_ops bond_ethtool_ops =
=3D {
 	.get_drvinfo		=3D bond_ethtool_get_drvinfo,
 	.get_link		=3D ethtool_op_get_link,
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
 	.get_tso		=3D ethtool_op_get_tso,
 	.get_ufo		=3D ethtool_op_get_ufo,
 	.get_flags		=3D ethtool_op_get_flags,
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 0f71304..7f63ede 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -834,7 +834,6 @@ static const struct ethtool_ops t1_ethtool_ops =3D =
{
 	.get_rx_csum       =3D get_rx_csum,
 	.set_rx_csum       =3D set_rx_csum,
 	.set_tx_csum       =3D ethtool_op_set_tx_csum,
-	.set_sg            =3D ethtool_op_set_sg,
 	.get_link          =3D ethtool_op_get_link,
 	.get_strings       =3D get_strings,
 	.get_sset_count	   =3D get_sset_count,
@@ -1131,6 +1130,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
=20
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
=20
+		netdev->hw_features |=3D NETIF_F_SG;
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
 	}
=20
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_m=
ain.c
index 407d4e2..2bc7529 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2097,7 +2097,6 @@ static const struct ethtool_ops cxgb_ethtool_ops =
=3D {
 	.get_rx_csum =3D get_rx_csum,
 	.set_rx_csum =3D set_rx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_link =3D ethtool_op_get_link,
 	.get_strings =3D get_strings,
 	.phys_id =3D cxgb3_phys_id,
@@ -3311,6 +3310,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
=20
 		netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->netdev_ops =3D &cxgb_netdev_ops;
+		netdev->hw_features |=3D NETIF_F_SG;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
=20
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_m=
ain.c
index f17703f..ac843a3 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2011,7 +2011,6 @@ static struct ethtool_ops cxgb_ethtool_ops =3D {
 	.get_rx_csum       =3D get_rx_csum,
 	.set_rx_csum       =3D set_rx_csum,
 	.set_tx_csum       =3D ethtool_op_set_tx_ipv6_csum,
-	.set_sg            =3D ethtool_op_set_sg,
 	.get_link          =3D ethtool_op_get_link,
 	.get_strings       =3D get_strings,
 	.phys_id           =3D identify_port,
@@ -3674,6 +3673,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 		netdev->vlan_features =3D netdev->features & VLAN_FEAT;
=20
 		netdev->netdev_ops =3D &cxgb4_netdev_ops;
+		netdev->hw_features |=3D NETIF_F_SG;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
=20
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/c=
xgb4vf_main.c
index 555ecc5..ddaba63 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1564,7 +1564,6 @@ static struct ethtool_ops cxgb4vf_ethtool_ops =3D=
 {
 	.get_rx_csum		=3D cxgb4vf_get_rx_csum,
 	.set_rx_csum		=3D cxgb4vf_set_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_ipv6_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_link		=3D ethtool_op_get_link,
 	.get_strings		=3D cxgb4vf_get_strings,
 	.phys_id		=3D cxgb4vf_phys_id,
@@ -2630,6 +2629,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci=
_dev *pdev,
 		netdev->poll_controller =3D cxgb4vf_poll_controller;
 #endif
 #endif
+		netdev->hw_features |=3D NETIF_F_SG;
 		SET_ETHTOOL_OPS(netdev, &cxgb4vf_ethtool_ops);
=20
 		/*
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e100=
0_ethtool.c
index f4d0922..008632c 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1925,7 +1925,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.set_rx_csum            =3D e1000_set_rx_csum,
 	.get_tx_csum            =3D e1000_get_tx_csum,
 	.set_tx_csum            =3D e1000_set_tx_csum,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.set_tso                =3D e1000_set_tso,
 	.self_test              =3D e1000_diag_test,
 	.get_strings            =3D e1000_get_strings,
@@ -1938,5 +1937,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
=20
 void e1000_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &e1000_ethtool_ops);
 }
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.=
c
index 8984d16..bb0bcfa 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -2036,8 +2036,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
 	.set_rx_csum		=3D e1000_set_rx_csum,
 	.get_tx_csum		=3D e1000_get_tx_csum,
 	.set_tx_csum		=3D e1000_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
 	.set_tso		=3D e1000_set_tso,
 	.self_test		=3D e1000_diag_test,
@@ -2052,5 +2050,6 @@ static const struct ethtool_ops e1000_ethtool_ops=
 =3D {
=20
 void e1000e_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &e1000_ethtool_ops);
 }
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.=
c
index a466ef9..b744fca 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -413,8 +413,6 @@ static const struct ethtool_ops enic_ethtool_ops =3D=
 {
 	.set_rx_csum =3D enic_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D enic_set_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D ethtool_op_get_tso,
 	.set_tso =3D enic_set_tso,
 	.get_coalesce =3D enic_get_coalesce,
@@ -2638,6 +2636,7 @@ static int __devinit enic_probe(struct pci_dev *p=
dev,
 		netdev->netdev_ops =3D &enic_netdev_ops;
=20
 	netdev->watchdog_timeo =3D 2 * HZ;
+	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->ethtool_ops =3D &enic_ethtool_ops;
=20
 	netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 0fa1776..fb8c7c9 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4658,16 +4658,6 @@ static int nv_set_tx_csum(struct net_device *dev=
, u32 data)
 		return -EOPNOTSUPP;
 }
=20
-static int nv_set_sg(struct net_device *dev, u32 data)
-{
-	struct fe_priv *np =3D netdev_priv(dev);
-
-	if (np->driver_data & DEV_HAS_CHECKSUM)
-		return ethtool_op_set_sg(dev, data);
-	else
-		return -EOPNOTSUPP;
-}
-
 static int nv_get_sset_count(struct net_device *dev, int sset)
 {
 	struct fe_priv *np =3D netdev_priv(dev);
@@ -5047,7 +5037,6 @@ static const struct ethtool_ops ops =3D {
 	.get_rx_csum =3D nv_get_rx_csum,
 	.set_rx_csum =3D nv_set_rx_csum,
 	.set_tx_csum =3D nv_set_tx_csum,
-	.set_sg =3D nv_set_sg,
 	.get_strings =3D nv_get_strings,
 	.get_ethtool_stats =3D nv_get_ethtool_stats,
 	.get_sset_count =3D nv_get_sset_count,
@@ -5575,6 +5564,8 @@ static int __devinit nv_probe(struct pci_dev *pci=
_dev, const struct pci_device_i
 		dev->netdev_ops =3D &nv_netdev_ops_optimized;
=20
 	netif_napi_add(dev, &np->napi, nv_napi_poll, RX_WORK_PER_LOOP);
+	if (np->driver_data & DEV_HAS_CHECKSUM)
+		dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &ops);
 	dev->watchdog_timeo =3D NV_WATCHDOG_TIMEO;
=20
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/f=
s_enet-main.c
index d684f18..4f1adcb 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -956,7 +956,6 @@ static const struct ethtool_ops fs_ethtool_ops =3D =
{
 	.get_msglevel =3D fs_get_msglevel,
 	.set_msglevel =3D fs_set_msglevel,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,	/* local! */
-	.set_sg =3D ethtool_op_set_sg,
 	.get_regs =3D fs_get_regs,
 };
=20
@@ -1078,6 +1077,7 @@ static int __devinit fs_enet_probe(struct platfor=
m_device *ofdev,
 		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
 		               fpi->napi_weight);
=20
+	ndev->hw_features |=3D NETIF_F_SG;
 	ndev->ethtool_ops =3D &fs_ethtool_ops;
=20
 	init_timer(&fep->phy_timer_list);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 49e4ce1..c34b1cc 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1021,6 +1021,7 @@ static int gfar_probe(struct platform_device *ofd=
ev,
 	dev->watchdog_timeo =3D TX_TIMEOUT;
 	dev->mtu =3D 1500;
 	dev->netdev_ops =3D &gfar_netdev_ops;
+	dev->hw_features |=3D NETIF_F_SG;
 	dev->ethtool_ops =3D &gfar_ethtool_ops;
=20
 	/* Register for napi ...We are registering NAPI for each grp */
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtoo=
l.c
index 5c566eb..cf4a87a 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -897,7 +897,6 @@ const struct ethtool_ops gfar_ethtool_ops =3D {
 	.get_tx_csum =3D gfar_get_tx_csum,
 	.set_rx_csum =3D gfar_set_rx_csum,
 	.set_tx_csum =3D gfar_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_msglevel =3D gfar_get_msglevel,
 	.set_msglevel =3D gfar_set_msglevel,
 #ifdef CONFIG_PM
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/c=
ore.c
index 385dc32..7f3ccc2 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2211,7 +2211,6 @@ static const struct ethtool_ops emac_ethtool_ops =
=3D {
=20
 	.get_link =3D ethtool_op_get_link,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
 };
=20
 static int emac_ioctl(struct net_device *ndev, struct ifreq *rq, int c=
md)
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index c454b45..7e96672 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -925,7 +925,6 @@ static const struct ethtool_ops netdev_ethtool_ops =
=3D {
 	.get_strings		=3D ibmveth_get_strings,
 	.get_sset_count		=3D ibmveth_get_sset_count,
 	.get_ethtool_stats	=3D ibmveth_get_ethtool_stats,
-	.set_sg			=3D ethtool_op_set_sg,
 };
=20
 static int ibmveth_ioctl(struct net_device *dev, struct ifreq *ifr, in=
t cmd)
@@ -1415,6 +1414,7 @@ static int __devinit ibmveth_probe(struct vio_dev=
 *dev,
=20
 	netdev->irq =3D dev->irq;
 	netdev->netdev_ops =3D &ibmveth_netdev_ops;
+	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->ethtool_ops =3D &netdev_ethtool_ops;
 	SET_NETDEV_DEV(netdev, &dev->dev);
 	netdev->features |=3D NETIF_F_SG;
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtoo=
l.c
index a70e16b..2909af5 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -2193,8 +2193,6 @@ static const struct ethtool_ops igb_ethtool_ops =3D=
 {
 	.set_rx_csum            =3D igb_set_rx_csum,
 	.get_tx_csum            =3D igb_get_tx_csum,
 	.set_tx_csum            =3D igb_set_tx_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.get_tso                =3D ethtool_op_get_tso,
 	.set_tso                =3D igb_set_tso,
 	.self_test              =3D igb_diag_test,
@@ -2208,5 +2206,6 @@ static const struct ethtool_ops igb_ethtool_ops =3D=
 {
=20
 void igb_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &igb_ethtool_ops);
 }
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index 33add70..9bf5ea0 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -527,8 +527,6 @@ static const struct ethtool_ops igbvf_ethtool_ops =3D=
 {
 	.set_rx_csum            =3D igbvf_set_rx_csum,
 	.get_tx_csum		=3D igbvf_get_tx_csum,
 	.set_tx_csum		=3D igbvf_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
 	.set_tso		=3D igbvf_set_tso,
 	.self_test		=3D igbvf_diag_test,
@@ -542,6 +540,7 @@ static const struct ethtool_ops igbvf_ethtool_ops =3D=
 {
=20
 void igbvf_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	/* have to "undeclare" const on this struct to remove warnings */
 	SET_ETHTOOL_OPS(netdev, (struct ethtool_ops *)&igbvf_ethtool_ops);
 }
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_et=
htool.c
index 43994c1..9623e87 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -724,7 +724,6 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
 	.set_rx_csum =3D ixgb_set_rx_csum,
 	.get_tx_csum =3D ixgb_get_tx_csum,
 	.set_tx_csum =3D ixgb_set_tx_csum,
-	.set_sg	=3D ethtool_op_set_sg,
 	.get_msglevel =3D ixgb_get_msglevel,
 	.set_msglevel =3D ixgb_set_msglevel,
 	.set_tso =3D ixgb_set_tso,
@@ -736,5 +735,6 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
=20
 void ixgb_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &ixgb_ethtool_ops);
 }
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 3dc731c..5f1e17c 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2287,8 +2287,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops=
 =3D {
 	.set_rx_csum            =3D ixgbe_set_rx_csum,
 	.get_tx_csum            =3D ixgbe_get_tx_csum,
 	.set_tx_csum            =3D ixgbe_set_tx_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.get_msglevel           =3D ixgbe_get_msglevel,
 	.set_msglevel           =3D ixgbe_set_msglevel,
 	.get_tso                =3D ethtool_op_get_tso,
@@ -2307,5 +2305,6 @@ static const struct ethtool_ops ixgbe_ethtool_ops=
 =3D {
=20
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &ixgbe_ethtool_ops);
 }
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtoo=
l.c
index 4cc817a..624375a 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -718,8 +718,6 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D {
 	.set_rx_csum            =3D ixgbevf_set_rx_csum,
 	.get_tx_csum            =3D ethtool_op_get_tx_csum,
 	.set_tx_csum            =3D ethtool_op_set_tx_ipv6_csum,
-	.get_sg                 =3D ethtool_op_get_sg,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.get_msglevel           =3D ixgbevf_get_msglevel,
 	.set_msglevel           =3D ixgbevf_set_msglevel,
 	.get_tso                =3D ethtool_op_get_tso,
@@ -732,5 +730,6 @@ static struct ethtool_ops ixgbevf_ethtool_ops =3D {
=20
 void ixgbevf_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &ixgbevf_ethtool_ops);
 }
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index d85edf3..1f7a0a7 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2685,7 +2685,6 @@ static const struct ethtool_ops jme_ethtool_ops =3D=
 {
 	.set_rx_csum		=3D jme_set_rx_csum,
 	.set_tx_csum		=3D jme_set_tx_csum,
 	.set_tso		=3D jme_set_tso,
-	.set_sg			=3D ethtool_op_set_sg,
 	.nway_reset             =3D jme_nway_reset,
 	.get_eeprom_len		=3D jme_get_eeprom_len,
 	.get_eeprom		=3D jme_get_eeprom,
@@ -2795,6 +2794,7 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_release_regions;
 	}
 	netdev->netdev_ops =3D &jme_netdev_ops;
+	netdev->hw_features |=3D NETIF_F_SG;
 	netdev->ethtool_ops		=3D &jme_ethtool_ops;
 	netdev->watchdog_timeo		=3D TX_TIMEOUT;
 	netdev->features		=3D	NETIF_F_HW_CSUM |
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 37504a3..ea69576 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -6662,8 +6662,6 @@ static struct ethtool_ops netdev_ethtool_ops =3D =
{
 	.set_rx_csum		=3D netdev_set_rx_csum,
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 };
=20
 /*
@@ -7150,6 +7148,7 @@ static int __init pcidev_init(struct pci_dev *pde=
v,
 		}
=20
 		dev->netdev_ops =3D &netdev_ops;
+		dev->hw_features |=3D NETIF_F_SG;
 		SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 		if (register_netdev(dev))
 			goto pcidev_init_reg_err;
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 2d9663a..208e9f4 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -131,7 +131,6 @@ static const struct ethtool_ops loopback_ethtool_op=
s =3D {
 	.get_link		=3D always_on,
 	.set_tso		=3D ethtool_op_set_tso,
 	.get_tx_csum		=3D always_on,
-	.get_sg			=3D always_on,
 	.get_rx_csum		=3D always_on,
 };
=20
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtoo=
l.c
index 056152b..1b355b7 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -430,8 +430,6 @@ const struct ethtool_ops mlx4_en_ethtool_ops =3D {
 	.get_tso =3D mlx4_en_get_tso,
 	.set_tso =3D mlx4_en_set_tso,
 #endif
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_link =3D ethtool_op_get_link,
 	.get_rx_csum =3D mlx4_en_get_rx_csum,
 	.set_rx_csum =3D mlx4_en_set_rx_csum,
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.=
c
index 6d6806b..f496dbc 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1038,6 +1038,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev,=
 int port,
 	netif_set_real_num_tx_queues(dev, priv->tx_ring_num);
 	netif_set_real_num_rx_queues(dev, priv->rx_ring_num);
=20
+	dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &mlx4_en_ethtool_ops);
=20
 	/* Set defualt MAC */
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index dd2b6a7..aa3b981 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1666,7 +1666,6 @@ static const struct ethtool_ops mv643xx_eth_ethto=
ol_ops =3D {
 	.get_rx_csum		=3D mv643xx_eth_get_rx_csum,
 	.set_rx_csum		=3D mv643xx_eth_set_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D mv643xx_eth_get_strings,
 	.get_ethtool_stats	=3D mv643xx_eth_get_ethtool_stats,
 	.get_flags		=3D ethtool_op_get_flags,
@@ -2910,6 +2909,7 @@ static int mv643xx_eth_probe(struct platform_devi=
ce *pdev)
 	if (mp->phy !=3D NULL)
 		phy_init(mp, pd->speed, pd->duplex);
=20
+	dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &mv643xx_eth_ethtool_ops);
=20
 	init_pscr(mp, pd->speed, pd->duplex);
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index 8524cc4..3696bba 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1951,7 +1951,6 @@ static const struct ethtool_ops myri10ge_ethtool_=
ops =3D {
 	.get_rx_csum =3D myri10ge_get_rx_csum,
 	.set_rx_csum =3D myri10ge_set_rx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_hw_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.set_tso =3D myri10ge_set_tso,
 	.get_link =3D ethtool_op_get_link,
 	.get_strings =3D myri10ge_get_strings,
@@ -3998,6 +3997,7 @@ static int myri10ge_probe(struct pci_dev *pdev, c=
onst struct pci_device_id *ent)
 		    (unsigned long)mgp);
=20
 	spin_lock_init(&mgp->stats_lock);
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &myri10ge_ethtool_ops);
 	INIT_WORK(&mgp->watchdog_work, myri10ge_watchdog);
 	status =3D register_netdev(netdev);
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netx=
en/netxen_nic_ethtool.c
index b30de24..f22f0a7 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -926,7 +926,6 @@ const struct ethtool_ops netxen_nic_ethtool_ops =3D=
 {
 	.set_pauseparam =3D netxen_nic_set_pauseparam,
 	.get_tx_csum =3D netxen_nic_get_tx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D netxen_nic_get_tso,
 	.set_tso =3D netxen_nic_set_tso,
 	.get_wol =3D netxen_nic_get_wol,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index 35ae1aa..4b2874c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1210,6 +1210,7 @@ netxen_setup_netdev(struct netxen_adapter *adapte=
r,
=20
 	netxen_nic_change_mtu(netdev, netdev->mtu);
=20
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
=20
 	netdev->features |=3D (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/q=
lcnic_ethtool.c
index ec21d24..ceba22d 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -1166,7 +1166,6 @@ const struct ethtool_ops qlcnic_ethtool_ops =3D {
 	.set_pauseparam =3D qlcnic_set_pauseparam,
 	.get_tx_csum =3D qlcnic_get_tx_csum,
 	.set_tx_csum =3D qlcnic_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D qlcnic_get_tso,
 	.set_tso =3D qlcnic_set_tso,
 	.get_wol =3D qlcnic_get_wol,
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcn=
ic_main.c
index 7a298cd..30ed19a 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1425,6 +1425,7 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapte=
r,
=20
 	qlcnic_change_mtu(netdev, netdev->mtu);
=20
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
=20
 	netdev->features |=3D (NETIF_F_SG | NETIF_F_IP_CSUM |
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_et=
htool.c
index 4892d64..d8b2d3f 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -698,8 +698,6 @@ const struct ethtool_ops qlge_ethtool_ops =3D {
 	.set_rx_csum =3D ql_set_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D ethtool_op_get_tso,
 	.set_tso =3D ql_set_tso,
 	.get_coalesce =3D ql_get_coalesce,
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index c30e0fe..75b708c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4713,6 +4713,7 @@ static int __devinit qlge_probe(struct pci_dev *p=
dev,
 	ndev->irq =3D pdev->irq;
=20
 	ndev->netdev_ops =3D &qlge_netdev_ops;
+	ndev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(ndev, &qlge_ethtool_ops);
 	ndev->watchdog_timeo =3D 10 * HZ;
=20
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index d88ce9f..746e296 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1277,7 +1277,6 @@ static const struct ethtool_ops rtl8169_ethtool_o=
ps =3D {
 	.get_rx_csum		=3D rtl8169_get_rx_csum,
 	.set_rx_csum		=3D rtl8169_set_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.set_tso		=3D ethtool_op_set_tso,
 	.get_regs		=3D rtl8169_get_regs,
 	.get_wol		=3D rtl8169_get_wol,
@@ -3173,6 +3172,7 @@ rtl8169_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 		dev->dev_addr[i] =3D RTL_R8(MAC0 + i);
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
=20
+	dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &rtl8169_ethtool_ops);
 	dev->watchdog_timeo =3D RTL8169_TX_TIMEOUT;
 	dev->irq =3D pdev->irq;
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index ecc25aa..e447a4d 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6769,7 +6769,6 @@ static const struct ethtool_ops netdev_ethtool_op=
s =3D {
 	.set_tx_csum =3D s2io_ethtool_op_set_tx_csum,
 	.set_flags =3D s2io_ethtool_set_flags,
 	.get_flags =3D ethtool_op_get_flags,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_tso =3D s2io_ethtool_op_get_tso,
 	.set_tso =3D s2io_ethtool_op_set_tso,
 	.set_ufo =3D ethtool_op_set_ufo,
@@ -8034,6 +8033,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct =
pci_device_id *pre)
=20
 	/*  Driver entry points */
 	dev->netdev_ops =3D &s2io_netdev_ops;
+	dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->features |=3D NETIF_F_LRO;
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 05df20e..b6b0f5d 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1882,6 +1882,7 @@ static int efx_register_netdev(struct efx_nic *ef=
x)
 	net_dev->watchdog_timeo =3D 5 * HZ;
 	net_dev->irq =3D efx->pci_dev->irq;
 	net_dev->netdev_ops =3D &efx_netdev_ops;
+	net_dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(net_dev, &efx_ethtool_ops);
=20
 	/* Clear MAC statistics */
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index edb9d16..c994666 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -1130,8 +1130,6 @@ const struct ethtool_ops efx_ethtool_ops =3D {
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
 	/* Need to enable/disable IPv6 too */
 	.set_tx_csum		=3D efx_ethtool_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
 	/* Need to enable/disable TSO-IPv6 too */
 	.set_tso		=3D efx_ethtool_set_tso,
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index bfec2e0..ac153bd 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -537,16 +537,6 @@ static int skge_nway_reset(struct net_device *dev)
 	return 0;
 }
=20
-static int skge_set_sg(struct net_device *dev, u32 data)
-{
-	struct skge_port *skge =3D netdev_priv(dev);
-	struct skge_hw *hw =3D skge->hw;
-
-	if (hw->chip_id =3D=3D CHIP_ID_GENESIS && data)
-		return -EOPNOTSUPP;
-	return ethtool_op_set_sg(dev, data);
-}
-
 static int skge_set_tx_csum(struct net_device *dev, u32 data)
 {
 	struct skge_port *skge =3D netdev_priv(dev);
@@ -925,7 +915,6 @@ static const struct ethtool_ops skge_ethtool_ops =3D=
 {
 	.set_pauseparam =3D skge_set_pauseparam,
 	.get_coalesce	=3D skge_get_coalesce,
 	.set_coalesce	=3D skge_set_coalesce,
-	.set_sg		=3D skge_set_sg,
 	.set_tx_csum	=3D skge_set_tx_csum,
 	.get_rx_csum	=3D skge_get_rx_csum,
 	.set_rx_csum	=3D skge_set_rx_csum,
@@ -3811,6 +3800,8 @@ static struct net_device *skge_devinit(struct skg=
e_hw *hw, int port,
=20
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->netdev_ops =3D &skge_netdev_ops;
+	if (hw->chip_id !=3D CHIP_ID_GENESIS)
+		dev->hw_features |=3D NETIF_F_SG;
 	dev->ethtool_ops =3D &skge_ethtool_ops;
 	dev->watchdog_timeo =3D TX_WATCHDOG;
 	dev->irq =3D hw->pdev->irq;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d657708..a06bb6e 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4216,7 +4216,6 @@ static const struct ethtool_ops sky2_ethtool_ops =
=3D {
 	.get_eeprom_len	=3D sky2_get_eeprom_len,
 	.get_eeprom	=3D sky2_get_eeprom,
 	.set_eeprom	=3D sky2_set_eeprom,
-	.set_sg 	=3D ethtool_op_set_sg,
 	.set_tx_csum	=3D sky2_set_tx_csum,
 	.set_tso	=3D sky2_set_tso,
 	.get_rx_csum	=3D sky2_get_rx_csum,
@@ -4550,6 +4549,7 @@ static __devinit struct net_device *sky2_init_net=
dev(struct sky2_hw *hw,
=20
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->irq =3D hw->pdev->irq;
+	dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &sky2_ethtool_ops);
 	dev->watchdog_timeo =3D TX_WATCHDOG;
 	dev->netdev_ops =3D &sky2_netdev_ops[port];
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/s=
tmmac_ethtool.c
index 6d65482..4461a9e 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -371,8 +371,6 @@ static struct ethtool_ops stmmac_ethtool_ops =3D {
 	.get_rx_csum =3D stmmac_ethtool_get_rx_csum,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 	.set_tx_csum =3D stmmac_ethtool_set_tx_csum,
-	.get_sg =3D ethtool_op_get_sg,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_pauseparam =3D stmmac_get_pauseparam,
 	.set_pauseparam =3D stmmac_set_pauseparam,
 	.get_ethtool_stats =3D stmmac_get_ethtool_stats,
@@ -386,5 +384,6 @@ static struct ethtool_ops stmmac_ethtool_ops =3D {
=20
 void stmmac_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &stmmac_ethtool_ops);
 }
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 8b3dc1e..ed6dc44 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2426,7 +2426,6 @@ static void bdx_set_ethtool_ops(struct net_device=
 *netdev)
 		.set_ringparam =3D bdx_set_ringparam,
 		.get_rx_csum =3D bdx_get_rx_csum,
 		.get_tx_csum =3D bdx_get_tx_csum,
-		.get_sg =3D ethtool_op_get_sg,
 		.get_tso =3D ethtool_op_get_tso,
 		.get_strings =3D bdx_get_strings,
 		.get_sset_count =3D bdx_get_sset_count,
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 30ccbb6..b07e2d1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11306,7 +11306,6 @@ static const struct ethtool_ops tg3_ethtool_ops=
 =3D {
 	.get_rx_csum		=3D tg3_get_rx_csum,
 	.set_rx_csum		=3D tg3_set_rx_csum,
 	.set_tx_csum		=3D tg3_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.set_tso		=3D tg3_set_tso,
 	.self_test		=3D tg3_self_test,
 	.get_strings		=3D tg3_get_strings,
@@ -14681,6 +14680,7 @@ static int __devinit tg3_init_one(struct pci_de=
v *pdev,
 	tp->rx_pending =3D TG3_DEF_RX_RING_PENDING;
 	tp->rx_jumbo_pending =3D TG3_DEF_RX_JUMBO_RING_PENDING;
=20
+	dev->hw_features |=3D NETIF_F_SG;
 	dev->ethtool_ops =3D &tg3_ethtool_ops;
 	dev->watchdog_timeo =3D TG3_TX_TIMEOUT;
 	dev->irq =3D pdev->irq;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 5b83c3f..4b49dd7 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1191,7 +1191,6 @@ static const struct ethtool_ops typhoon_ethtool_o=
ps =3D {
 	.get_link		=3D ethtool_op_get_link,
 	.get_rx_csum		=3D typhoon_get_rx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.set_tso		=3D ethtool_op_set_tso,
 	.get_ringparam		=3D typhoon_get_ringparam,
 	.set_flags		=3D typhoon_set_flags,
@@ -2480,6 +2479,7 @@ typhoon_init_one(struct pci_dev *pdev, const stru=
ct pci_device_id *ent)
 	netif_napi_add(dev, &tp->napi, typhoon_poll, 16);
 	dev->watchdog_timeo	=3D TX_TIMEOUT;
=20
+	dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &typhoon_ethtool_ops);
=20
 	/* We can handle scatter gather, up to 16 entries, and
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_etht=
ool.c
index 6f92e48..fa3e464 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -410,7 +410,6 @@ static const struct ethtool_ops uec_ethtool_ops =3D=
 {
 	.set_ringparam          =3D uec_set_ringparam,
 	.get_pauseparam         =3D uec_get_pauseparam,
 	.set_pauseparam         =3D uec_set_pauseparam,
-	.set_sg                 =3D ethtool_op_set_sg,
 	.get_sset_count		=3D uec_get_sset_count,
 	.get_strings            =3D uec_get_strings,
 	.get_ethtool_stats      =3D uec_get_ethtool_stats,
@@ -420,5 +419,6 @@ static const struct ethtool_ops uec_ethtool_ops =3D=
 {
=20
 void uec_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &uec_ethtool_ops);
 }
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0bbc0c3..d00db8a 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -138,8 +138,6 @@ static const struct ethtool_ops veth_ethtool_ops =3D=
 {
 	.set_rx_csum		=3D veth_set_rx_csum,
 	.get_tx_csum		=3D veth_get_tx_csum,
 	.set_tx_csum		=3D veth_set_tx_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D veth_get_strings,
 	.get_sset_count		=3D veth_get_sset_count,
 	.get_ethtool_stats	=3D veth_get_ethtool_stats,
@@ -299,6 +297,7 @@ static void veth_setup(struct net_device *dev)
 	ether_setup(dev);
=20
 	dev->netdev_ops =3D &veth_netdev_ops;
+	dev->hw_features |=3D NETIF_F_SG;
 	dev->ethtool_ops =3D &veth_ethtool_ops;
 	dev->features |=3D NETIF_F_LLTX;
 	dev->destructor =3D veth_dev_free;
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index cab96ad..a6389ef 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2838,6 +2838,7 @@ static int __devinit velocity_found1(struct pci_d=
ev *pdev, const struct pci_devi
=20
 	dev->irq =3D pdev->irq;
 	dev->netdev_ops =3D &velocity_netdev_ops;
+	dev->hw_features |=3D NETIF_F_SG;
 	dev->ethtool_ops =3D &velocity_ethtool_ops;
 	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT)=
;
=20
@@ -3454,7 +3455,6 @@ static const struct ethtool_ops velocity_ethtool_=
ops =3D {
 	.set_wol	=3D	velocity_ethtool_set_wol,
 	.get_msglevel	=3D	velocity_get_msglevel,
 	.set_msglevel	=3D	velocity_set_msglevel,
-	.set_sg 	=3D	ethtool_op_set_sg,
 	.get_link	=3D	velocity_get_link,
 	.get_coalesce	=3D	velocity_get_coalesce,
 	.set_coalesce	=3D	velocity_set_coalesce,
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index bb6b67f..b332e92 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -818,7 +818,6 @@ static void virtnet_vlan_rx_kill_vid(struct net_dev=
ice *dev, u16 vid)
=20
 static const struct ethtool_ops virtnet_ethtool_ops =3D {
 	.set_tx_csum =3D virtnet_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.set_tso =3D ethtool_op_set_tso,
 	.set_ufo =3D ethtool_op_set_ufo,
 	.get_link =3D ethtool_op_get_link,
@@ -903,6 +902,7 @@ static int virtnet_probe(struct virtio_device *vdev=
)
 	/* Set up network device as normal. */
 	dev->netdev_ops =3D &virtnet_netdev;
 	dev->features =3D NETIF_F_HIGHDMA;
+	dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
=20
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet=
3/vmxnet3_ethtool.c
index b79070b..9925d2b 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -547,8 +547,6 @@ static struct ethtool_ops vmxnet3_ethtool_ops =3D {
 	.set_rx_csum       =3D vmxnet3_set_rx_csum,
 	.get_tx_csum       =3D ethtool_op_get_tx_csum,
 	.set_tx_csum       =3D ethtool_op_set_tx_hw_csum,
-	.get_sg            =3D ethtool_op_get_sg,
-	.set_sg            =3D ethtool_op_set_sg,
 	.get_tso           =3D ethtool_op_get_tso,
 	.set_tso           =3D ethtool_op_set_tso,
 	.get_strings       =3D vmxnet3_get_strings,
@@ -562,5 +560,6 @@ static struct ethtool_ops vmxnet3_ethtool_ops =3D {
=20
 void vmxnet3_set_ethtool_ops(struct net_device *netdev)
 {
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &vmxnet3_ethtool_ops);
 }
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-et=
htool.c
index b67746e..3c7ccd0 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1132,8 +1132,6 @@ static const struct ethtool_ops vxge_ethtool_ops =
=3D {
 	.set_rx_csum		=3D vxge_set_rx_csum,
 	.get_tx_csum		=3D ethtool_op_get_tx_csum,
 	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
-	.get_sg			=3D ethtool_op_get_sg,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_tso		=3D ethtool_op_get_tso,
 	.set_tso		=3D vxge_ethtool_op_set_tso,
 	.get_strings		=3D vxge_ethtool_get_strings,
@@ -1144,5 +1142,6 @@ static const struct ethtool_ops vxge_ethtool_ops =
=3D {
=20
 void vxge_initialize_ethtool_ops(struct net_device *ndev)
 {
+	ndev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(ndev, &vxge_ethtool_ops);
 }
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 458bb57..e494cc2 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1178,6 +1178,7 @@ static struct net_device * __devinit xennet_creat=
e_dev(struct xenbus_device *dev
 	netif_napi_add(netdev, &np->napi, xennet_poll, 64);
 	netdev->features        =3D NETIF_F_IP_CSUM;
=20
+	netdev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(netdev, &xennet_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
=20
@@ -1491,7 +1492,7 @@ static int xennet_set_sg(struct net_device *dev, =
u32 data)
 	} else if (dev->mtu > ETH_DATA_LEN)
 		dev->mtu =3D ETH_DATA_LEN;
=20
-	return ethtool_op_set_sg(dev, data);
+	return 0;
 }
=20
 static int xennet_set_tso(struct net_device *dev, u32 data)
@@ -1516,13 +1517,16 @@ static void xennet_set_features(struct net_devi=
ce *dev)
 	dev->features &=3D ~NETIF_F_GSO_MASK;
 	dev->features |=3D NETIF_F_GSO_ROBUST;
 	xennet_set_sg(dev, 0);
+	dev->features &=3D ~NETIF_F_SG;
=20
 	/* We need checksum offload to enable scatter/gather and TSO. */
 	if (!(dev->features & NETIF_F_IP_CSUM))
 		return;
=20
-	if (!xennet_set_sg(dev, 1))
+	if (!xennet_set_sg(dev, 1)) {
+		dev->features |=3D NETIF_F_SG;
 		xennet_set_tso(dev, 1);
+	}
 }
=20
 static int xennet_connect(struct net_device *dev)
@@ -1635,7 +1639,7 @@ static void netback_changed(struct xenbus_device =
*dev,
 static const struct ethtool_ops xennet_ethtool_ops =3D
 {
 	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.set_sg =3D xennet_set_sg,
+	.hw_set_sg =3D xennet_set_sg,
 	.set_tso =3D xennet_set_tso,
 	.get_link =3D ethtool_op_get_link,
 };
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3=
_main.c
index 74d1401..5fd646f 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3254,8 +3254,6 @@ static const struct ethtool_ops qeth_l3_ethtool_o=
ps =3D {
 	.set_tx_csum =3D qeth_l3_ethtool_set_tx_csum,
 	.get_rx_csum =3D qeth_l3_ethtool_get_rx_csum,
 	.set_rx_csum =3D qeth_l3_ethtool_set_rx_csum,
-	.get_sg      =3D ethtool_op_get_sg,
-	.set_sg      =3D ethtool_op_set_sg,
 	.get_tso     =3D ethtool_op_get_tso,
 	.set_tso     =3D qeth_l3_ethtool_set_tso,
 	.get_strings =3D qeth_core_get_strings,
@@ -3357,6 +3355,7 @@ static int qeth_l3_setup_netdev(struct qeth_card =
*card)
 	card->dev->ml_priv =3D card;
 	card->dev->watchdog_timeo =3D QETH_TX_TIMEOUT;
 	card->dev->mtu =3D card->info.initial_mtu;
+	card->dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
 	card->dev->features |=3D	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |
diff --git a/drivers/staging/hv/netvsc_drv.c b/drivers/staging/hv/netvs=
c_drv.c
index 1415352..3118ca5 100644
--- a/drivers/staging/hv/netvsc_drv.c
+++ b/drivers/staging/hv/netvsc_drv.c
@@ -317,8 +317,6 @@ static void netvsc_get_drvinfo(struct net_device *n=
et,
=20
 static const struct ethtool_ops ethtool_ops =3D {
 	.get_drvinfo	=3D netvsc_get_drvinfo,
-	.get_sg		=3D ethtool_op_get_sg,
-	.set_sg		=3D ethtool_op_set_sg,
 	.get_link	=3D ethtool_op_get_link,
 };
=20
@@ -392,6 +390,7 @@ static int netvsc_probe(struct device *device)
 	/* TODO: Add GSO and Checksum offload */
 	net->features =3D NETIF_F_SG;
=20
+	net->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, device);
=20
diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/o=
cteon/ethernet-mdio.c
index 10a82ef..7ad58bf 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -91,7 +91,6 @@ const struct ethtool_ops cvm_oct_ethtool_ops =3D {
 	.set_settings =3D cvm_oct_set_settings,
 	.nway_reset =3D cvm_oct_nway_reset,
 	.get_link =3D ethtool_op_get_link,
-	.get_sg =3D ethtool_op_get_sg,
 	.get_tx_csum =3D ethtool_op_get_tx_csum,
 };
=20
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 6628a50..6b26e3e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -548,8 +548,6 @@ u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
 int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data);
-u32 ethtool_op_get_sg(struct net_device *dev);
-int ethtool_op_set_sg(struct net_device *dev, u32 data);
 u32 ethtool_op_get_tso(struct net_device *dev);
 int ethtool_op_set_tso(struct net_device *dev, u32 data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
@@ -582,8 +580,7 @@ void ethtool_ntuple_flush(struct net_device *dev);
  * set_rx_csum: Turn receive checksum on or off
  * get_tx_csum: Report whether transmit checksums are turned on or off
  * set_tx_csum: Turn transmit checksums on or off
- * get_sg: Report whether scatter-gather is enabled
- * set_sg: Turn scatter-gather on or off
+ * hw_set_sg: Turn scatter-gather on or off
  * get_tso: Report whether TCP segmentation offload is enabled
  * set_tso: Turn TCP segmentation offload on or off
  * get_ufo: Report whether UDP fragmentation offload is enabled
@@ -648,8 +645,7 @@ struct ethtool_ops {
 	int	(*set_rx_csum)(struct net_device *, u32);
 	u32	(*get_tx_csum)(struct net_device *);
 	int	(*set_tx_csum)(struct net_device *, u32);
-	u32	(*get_sg)(struct net_device *);
-	int	(*set_sg)(struct net_device *, u32);
+	int	(*hw_set_sg)(struct net_device *, u32);
 	u32	(*get_tso)(struct net_device *);
 	int	(*set_tso)(struct net_device *, u32);
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 17cb0b6..3d12ebc 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -183,7 +183,7 @@ static int br_set_sg(struct net_device *dev, u32 da=
ta)
 		br->feature_mask &=3D ~NETIF_F_SG;
=20
 	br_features_recompute(br);
-	return 0;
+	return 1;
 }
=20
 static int br_set_tso(struct net_device *dev, u32 data)
@@ -302,8 +302,7 @@ static const struct ethtool_ops br_ethtool_ops =3D =
{
 	.get_link	=3D ethtool_op_get_link,
 	.get_tx_csum	=3D ethtool_op_get_tx_csum,
 	.set_tx_csum 	=3D br_set_tx_csum,
-	.get_sg		=3D ethtool_op_get_sg,
-	.set_sg		=3D br_set_sg,
+	.hw_set_sg	=3D br_set_sg,
 	.get_tso	=3D ethtool_op_get_tso,
 	.set_tso	=3D br_set_tso,
 	.get_ufo	=3D ethtool_op_get_ufo,
@@ -343,6 +342,7 @@ void br_dev_setup(struct net_device *dev)
=20
 	dev->netdev_ops =3D &br_netdev_ops;
 	dev->destructor =3D br_dev_free;
+	dev->hw_features =3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	dev->tx_queue_len =3D 0;
 	dev->priv_flags =3D IFF_EBRIDGE;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 956a9f4..017667c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -78,23 +78,6 @@ int ethtool_op_set_tx_ipv6_csum(struct net_device *d=
ev, u32 data)
 }
 EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
=20
-u32 ethtool_op_get_sg(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_SG) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_sg);
-
-int ethtool_op_set_sg(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_SG;
-	else
-		dev->features &=3D ~NETIF_F_SG;
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_sg);
-
 u32 ethtool_op_get_tso(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_TSO) !=3D 0;
@@ -1073,6 +1056,11 @@ static int ethtool_set_pauseparam(struct net_dev=
ice *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_pauseparam(dev, &pauseparam);
 }
=20
+static u32 ethtool_get_sg(struct net_device *dev)
+{
+	return (dev->features & NETIF_F_SG) !=3D 0;
+}
+
 static int __ethtool_set_sg(struct net_device *dev, u32 data)
 {
 	int err;
@@ -1088,7 +1076,19 @@ static int __ethtool_set_sg(struct net_device *d=
ev, u32 data)
 		if (err)
 			return err;
 	}
-	return dev->ethtool_ops->set_sg(dev, data);
+
+	if (dev->ethtool_ops->hw_set_sg) {
+		err =3D dev->ethtool_ops->hw_set_sg(dev, data);
+		if (err)
+			return min(err, 0);
+	}
+
+	if (data)
+		dev->features |=3D NETIF_F_SG;
+	else
+		dev->features &=3D ~NETIF_F_SG;
+
+	return 0;
 }
=20
 static int ethtool_set_tx_csum(struct net_device *dev, char __user *us=
eraddr)
@@ -1102,7 +1102,7 @@ static int ethtool_set_tx_csum(struct net_device =
*dev, char __user *useraddr)
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
=20
-	if (!edata.data && dev->ethtool_ops->set_sg) {
+	if (!edata.data && (dev->hw_features & NETIF_F_SG)) {
 		err =3D __ethtool_set_sg(dev, 0);
 		if (err)
 			return err;
@@ -1122,7 +1122,7 @@ static int ethtool_set_rx_csum(struct net_device =
*dev, char __user *useraddr)
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
=20
-	if (!edata.data && dev->ethtool_ops->set_sg)
+	if (!edata.data && (dev->hw_features & NETIF_F_SG))
 		dev->features &=3D ~NETIF_F_GRO;
=20
 	return dev->ethtool_ops->set_rx_csum(dev, edata.data);
@@ -1132,7 +1132,7 @@ static int ethtool_set_sg(struct net_device *dev,=
 char __user *useraddr)
 {
 	struct ethtool_value edata;
=20
-	if (!dev->ethtool_ops->set_sg)
+	if (!(dev->hw_features & NETIF_F_SG))
 		return -EOPNOTSUPP;
=20
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
@@ -1575,9 +1575,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		break;
 	case ETHTOOL_GSG:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_sg ?
-					dev->ethtool_ops->get_sg :
-					ethtool_op_get_sg));
+					ethtool_get_sg);
 		break;
 	case ETHTOOL_SSG:
 		rc =3D ethtool_set_sg(dev, useraddr);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 64ca2a6..f40660c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -288,7 +288,6 @@ static const struct ethtool_ops dsa_slave_ethtool_o=
ps =3D {
 	.get_drvinfo		=3D dsa_slave_get_drvinfo,
 	.nway_reset		=3D dsa_slave_nway_reset,
 	.get_link		=3D dsa_slave_get_link,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_strings		=3D dsa_slave_get_strings,
 	.get_ethtool_stats	=3D dsa_slave_get_ethtool_stats,
 	.get_sset_count		=3D dsa_slave_get_sset_count,
@@ -350,6 +349,7 @@ dsa_slave_create(struct dsa_switch *ds, struct devi=
ce *parent,
 		return slave_dev;
=20
 	slave_dev->features =3D master->vlan_features;
+	slave_dev->hw_features |=3D NETIF_F_SG;
 	SET_ETHTOOL_OPS(slave_dev, &dsa_slave_ethtool_ops);
 	memcpy(slave_dev->dev_addr, master->dev_addr, ETH_ALEN);
 	slave_dev->tx_queue_len =3D 0;
--=20
1.7.1

