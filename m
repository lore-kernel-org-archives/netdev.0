From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v4 4/9] net: introduce and use netdev_features_t for device
 features sets
Date: Tue, 25 Oct 2011 02:36:33 +0200 (CEST)
Message-ID: <faeb6403c0ff9e0bffaf2ce7f605c6474b5be353.1319495302.git.mirq-linux@rere.qmqm.pl>
References: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:45083 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756050Ab1JYAgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 20:36:37 -0400
In-Reply-To: <cover.1319495301.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The type and bits definitions are moved to separate header so that
linux/skbuff.h won't need to include linux/netdevice.h.

v2:	add couple missing conversions in drivers
	split unexporting netdev_fix_features()
	implemented %pNF
	convert sock::sk_route_(no?)caps

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bonding/bond_main.c                    |    9 ++--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |   13 ++++--
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c    |   13 ++++--
 drivers/net/ethernet/atheros/atlx/atl2.c           |   13 ++++--
 drivers/net/ethernet/atheros/atlx/atlx.c           |   13 ++++--
 drivers/net/ethernet/broadcom/bnx2.c               |    6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |    5 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    5 +-
 drivers/net/ethernet/broadcom/tg3.c                |   11 +++--
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    7 ++-
 drivers/net/ethernet/chelsio/cxgb/sge.c            |    2 +-
 drivers/net/ethernet/chelsio/cxgb/sge.h            |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |    9 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   12 +++--
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |    8 ++-
 drivers/net/ethernet/davicom/dm9000.c              |    5 +-
 drivers/net/ethernet/freescale/gianfar.c           |    2 +-
 drivers/net/ethernet/freescale/gianfar.h           |    4 +-
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |    4 +-
 drivers/net/ethernet/ibm/ibmveth.c                 |    6 ++-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |   14 ++++--
 drivers/net/ethernet/intel/e1000e/netdev.c         |    5 +-
 drivers/net/ethernet/intel/igb/igb_main.c          |   12 +++--
 drivers/net/ethernet/intel/igbvf/netdev.c          |    3 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |    8 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    6 ++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |    3 +-
 drivers/net/ethernet/jme.c                         |    8 ++--
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    4 +-
 drivers/net/ethernet/marvell/sky2.c                |   13 +++---
 drivers/net/ethernet/micrel/ksz884x.c              |    3 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |    5 +-
 drivers/net/ethernet/neterion/s2io.c               |    4 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |    9 ++--
 drivers/net/ethernet/nvidia/forcedeth.c            |    9 ++--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    5 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    6 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    9 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |   10 +++--
 drivers/net/ethernet/realtek/8139cp.c              |    2 +-
 drivers/net/ethernet/realtek/r8169.c               |    6 ++-
 drivers/net/ethernet/sfc/efx.c                     |    2 +-
 drivers/net/ethernet/sfc/net_driver.h              |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    3 +-
 drivers/net/tun.c                                  |    7 ++-
 drivers/net/usb/smsc75xx.c                         |    3 +-
 drivers/net/usb/smsc95xx.c                         |    3 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c              |    4 +-
 drivers/net/vmxnet3/vmxnet3_int.h                  |    2 +-
 drivers/net/xen-netback/interface.c                |    3 +-
 drivers/net/xen-netfront.c                         |    8 ++-
 drivers/s390/net/qeth_l3_main.c                    |    6 ++-
 include/linux/netdev_features.h                    |    4 ++
 include/linux/netdevice.h                          |   41 +++++++++++-=
--------
 include/linux/skbuff.h                             |    4 +-
 include/net/protocol.h                             |    4 +-
 include/net/sock.h                                 |    6 +-
 include/net/tcp.h                                  |    3 +-
 include/net/udp.h                                  |    3 +-
 lib/vsprintf.c                                     |   19 +++++++++
 net/8021q/vlan_dev.c                               |    3 +-
 net/bridge/br_device.c                             |    3 +-
 net/bridge/br_if.c                                 |    5 +-
 net/bridge/br_private.h                            |    3 +-
 net/core/dev.c                                     |   38 ++++++++++--=
------
 net/core/ethtool.c                                 |    9 ++--
 net/core/skbuff.c                                  |    2 +-
 net/ipv4/af_inet.c                                 |    3 +-
 net/ipv4/tcp.c                                     |    3 +-
 net/ipv4/udp.c                                     |    3 +-
 net/ipv6/af_inet6.c                                |    3 +-
 net/ipv6/udp.c                                     |    3 +-
 74 files changed, 304 insertions(+), 201 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 41430ba..5fce8f0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1330,11 +1330,12 @@ static int bond_sethwaddr(struct net_device *bo=
nd_dev,
 	return 0;
 }
=20
-static u32 bond_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t bond_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct slave *slave;
 	struct bonding *bond =3D netdev_priv(dev);
-	u32 mask;
+	netdev_features_t mask;
 	int i;
=20
 	read_lock(&bond->lock);
@@ -1368,7 +1369,7 @@ static void bond_compute_features(struct bonding =
*bond)
 {
 	struct slave *slave;
 	struct net_device *bond_dev =3D bond->dev;
-	u32 vlan_features =3D BOND_VLAN_FEATURES;
+	netdev_features_t vlan_features =3D BOND_VLAN_FEATURES;
 	unsigned short max_hard_header_len =3D ETH_HLEN;
 	int i;
=20
@@ -1908,7 +1909,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	struct bonding *bond =3D netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
-	u32 old_features =3D bond_dev->features;
+	netdev_features_t old_features =3D bond_dev->features;
=20
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/=
net/ethernet/atheros/atl1c/atl1c_main.c
index 02c7ed8..b859124 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -411,7 +411,7 @@ static void atl1c_set_multi(struct net_device *netd=
ev)
 	}
 }
=20
-static void __atl1c_vlan_mode(u32 features, u32 *mac_ctrl_data)
+static void __atl1c_vlan_mode(netdev_features_t features, u32 *mac_ctr=
l_data)
 {
 	if (features & NETIF_F_HW_VLAN_RX) {
 		/* enable VLAN tag insert/strip */
@@ -422,7 +422,8 @@ static void __atl1c_vlan_mode(u32 features, u32 *ma=
c_ctrl_data)
 	}
 }
=20
-static void atl1c_vlan_mode(struct net_device *netdev, u32 features)
+static void atl1c_vlan_mode(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct atl1c_adapter *adapter =3D netdev_priv(netdev);
 	struct pci_dev *pdev =3D adapter->pdev;
@@ -482,7 +483,8 @@ static void atl1c_set_rxbufsize(struct atl1c_adapte=
r *adapter,
 		roundup(mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN, 8) : AT_RX_BUF_SIZ=
E;
 }
=20
-static u32 atl1c_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t atl1c_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -499,9 +501,10 @@ static u32 atl1c_fix_features(struct net_device *n=
etdev, u32 features)
 	return features;
 }
=20
-static int atl1c_set_features(struct net_device *netdev, u32 features)
+static int atl1c_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
-	u32 changed =3D netdev->features ^ features;
+	netdev_features_t changed =3D netdev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		atl1c_vlan_mode(netdev, features);
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/=
net/ethernet/atheros/atl1e/atl1e_main.c
index 95483bc..c915c08 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -313,7 +313,7 @@ static void atl1e_set_multi(struct net_device *netd=
ev)
 	}
 }
=20
-static void __atl1e_vlan_mode(u32 features, u32 *mac_ctrl_data)
+static void __atl1e_vlan_mode(netdev_features_t features, u32 *mac_ctr=
l_data)
 {
 	if (features & NETIF_F_HW_VLAN_RX) {
 		/* enable VLAN tag insert/strip */
@@ -324,7 +324,8 @@ static void __atl1e_vlan_mode(u32 features, u32 *ma=
c_ctrl_data)
 	}
 }
=20
-static void atl1e_vlan_mode(struct net_device *netdev, u32 features)
+static void atl1e_vlan_mode(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct atl1e_adapter *adapter =3D netdev_priv(netdev);
 	u32 mac_ctrl_data =3D 0;
@@ -370,7 +371,8 @@ static int atl1e_set_mac_addr(struct net_device *ne=
tdev, void *p)
 	return 0;
 }
=20
-static u32 atl1e_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t atl1e_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -384,9 +386,10 @@ static u32 atl1e_fix_features(struct net_device *n=
etdev, u32 features)
 	return features;
 }
=20
-static int atl1e_set_features(struct net_device *netdev, u32 features)
+static int atl1e_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
-	u32 changed =3D netdev->features ^ features;
+	netdev_features_t changed =3D netdev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		atl1e_vlan_mode(netdev, features);
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/eth=
ernet/atheros/atlx/atl2.c
index 1feae59..0e722b6 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -361,7 +361,7 @@ static inline void atl2_irq_disable(struct atl2_ada=
pter *adapter)
     synchronize_irq(adapter->pdev->irq);
 }
=20
-static void __atl2_vlan_mode(u32 features, u32 *ctrl)
+static void __atl2_vlan_mode(netdev_features_t features, u32 *ctrl)
 {
 	if (features & NETIF_F_HW_VLAN_RX) {
 		/* enable VLAN tag insert/strip */
@@ -372,7 +372,8 @@ static void __atl2_vlan_mode(u32 features, u32 *ctr=
l)
 	}
 }
=20
-static void atl2_vlan_mode(struct net_device *netdev, u32 features)
+static void atl2_vlan_mode(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct atl2_adapter *adapter =3D netdev_priv(netdev);
 	u32 ctrl;
@@ -391,7 +392,8 @@ static void atl2_restore_vlan(struct atl2_adapter *=
adapter)
 	atl2_vlan_mode(adapter->netdev, adapter->netdev->features);
 }
=20
-static u32 atl2_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t atl2_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -405,9 +407,10 @@ static u32 atl2_fix_features(struct net_device *ne=
tdev, u32 features)
 	return features;
 }
=20
-static int atl2_set_features(struct net_device *netdev, u32 features)
+static int atl2_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
-	u32 changed =3D netdev->features ^ features;
+	netdev_features_t changed =3D netdev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		atl2_vlan_mode(netdev, features);
diff --git a/drivers/net/ethernet/atheros/atlx/atlx.c b/drivers/net/eth=
ernet/atheros/atlx/atlx.c
index aabcf4b..8ff7411 100644
--- a/drivers/net/ethernet/atheros/atlx/atlx.c
+++ b/drivers/net/ethernet/atheros/atlx/atlx.c
@@ -211,7 +211,7 @@ static void atlx_link_chg_task(struct work_struct *=
work)
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
=20
-static void __atlx_vlan_mode(u32 features, u32 *ctrl)
+static void __atlx_vlan_mode(netdev_features_t features, u32 *ctrl)
 {
 	if (features & NETIF_F_HW_VLAN_RX) {
 		/* enable VLAN tag insert/strip */
@@ -222,7 +222,8 @@ static void __atlx_vlan_mode(u32 features, u32 *ctr=
l)
 	}
 }
=20
-static void atlx_vlan_mode(struct net_device *netdev, u32 features)
+static void atlx_vlan_mode(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct atlx_adapter *adapter =3D netdev_priv(netdev);
 	unsigned long flags;
@@ -242,7 +243,8 @@ static void atlx_restore_vlan(struct atlx_adapter *=
adapter)
 	atlx_vlan_mode(adapter->netdev, adapter->netdev->features);
 }
=20
-static u32 atlx_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t atlx_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -256,9 +258,10 @@ static u32 atlx_fix_features(struct net_device *ne=
tdev, u32 features)
 	return features;
 }
=20
-static int atlx_set_features(struct net_device *netdev, u32 features)
+static int atlx_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
-	u32 changed =3D netdev->features ^ features;
+	netdev_features_t changed =3D netdev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		atlx_vlan_mode(netdev, features);
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/etherne=
t/broadcom/bnx2.c
index 965c723..e5c91da 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -7571,8 +7571,8 @@ bnx2_set_phys_id(struct net_device *dev, enum eth=
tool_phys_id_state state)
 	return 0;
 }
=20
-static u32
-bnx2_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t
+bnx2_fix_features(struct net_device *dev, netdev_features_t features)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
=20
@@ -7583,7 +7583,7 @@ bnx2_fix_features(struct net_device *dev, u32 fea=
tures)
 }
=20
 static int
-bnx2_set_features(struct net_device *dev, u32 features)
+bnx2_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
=20
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 580b44e..799709e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3409,7 +3409,8 @@ int bnx2x_change_mtu(struct net_device *dev, int =
new_mtu)
 	return bnx2x_reload_if_running(dev);
 }
=20
-u32 bnx2x_fix_features(struct net_device *dev, u32 features)
+netdev_features_t bnx2x_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
@@ -3420,7 +3421,7 @@ u32 bnx2x_fix_features(struct net_device *dev, u3=
2 features)
 	return features;
 }
=20
-int bnx2x_set_features(struct net_device *dev, u32 features)
+int bnx2x_set_features(struct net_device *dev, netdev_features_t featu=
res)
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
 	u32 flags =3D bp->flags;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/=
net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 5b1f9b5..551e657 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -533,8 +533,9 @@ int bnx2x_change_mtu(struct net_device *dev, int ne=
w_mtu);
  */
 int bnx2x_fcoe_get_wwn(struct net_device *dev, u64 *wwn, int type);
 #endif
-u32 bnx2x_fix_features(struct net_device *dev, u32 features);
-int bnx2x_set_features(struct net_device *dev, u32 features);
+netdev_features_t bnx2x_fix_features(struct net_device *dev,
+	netdev_features_t features);
+int bnx2x_set_features(struct net_device *dev, netdev_features_t featu=
res);
=20
 /**
  * bnx2x_tx_timeout - tx timeout netdev callback
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet=
/broadcom/tg3.c
index b89027c..2eb08f2 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6960,7 +6960,7 @@ static int tg3_phy_lpbk_set(struct tg3 *tp, u32 s=
peed, bool extlpbk)
 	return 0;
 }
=20
-static void tg3_set_loopback(struct net_device *dev, u32 features)
+static void tg3_set_loopback(struct net_device *dev, netdev_features_t=
 features)
 {
 	struct tg3 *tp =3D netdev_priv(dev);
=20
@@ -6986,7 +6986,8 @@ static void tg3_set_loopback(struct net_device *d=
ev, u32 features)
 	}
 }
=20
-static u32 tg3_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t tg3_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct tg3 *tp =3D netdev_priv(dev);
=20
@@ -6996,9 +6997,9 @@ static u32 tg3_fix_features(struct net_device *de=
v, u32 features)
 	return features;
 }
=20
-static int tg3_set_features(struct net_device *dev, u32 features)
+static int tg3_set_features(struct net_device *dev, netdev_features_t =
features)
 {
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	if ((changed & NETIF_F_LOOPBACK) && netif_running(dev))
 		tg3_set_loopback(dev, features);
@@ -15287,7 +15288,7 @@ static int __devinit tg3_init_one(struct pci_de=
v *pdev,
 	u32 sndmbx, rcvmbx, intmbx;
 	char str[40];
 	u64 dma_mask, persist_dma_mask;
-	u32 features =3D 0;
+	netdev_features_t features =3D 0;
=20
 	printk_once(KERN_INFO "%s\n", version);
=20
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/et=
hernet/chelsio/cxgb/cxgb2.c
index ca26d97..dd8b813 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -849,7 +849,8 @@ static int t1_set_mac_addr(struct net_device *dev, =
void *p)
 	return 0;
 }
=20
-static u32 t1_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t t1_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -863,9 +864,9 @@ static u32 t1_fix_features(struct net_device *dev, =
u32 features)
 	return features;
 }
=20
-static int t1_set_features(struct net_device *dev, u32 features)
+static int t1_set_features(struct net_device *dev, netdev_features_t f=
eatures)
 {
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
 	struct adapter *adapter =3D dev->ml_priv;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.c b/drivers/net/ethe=
rnet/chelsio/cxgb/sge.c
index f9b6023..47a8435 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.c
@@ -742,7 +742,7 @@ static inline void setup_ring_params(struct adapter=
 *adapter, u64 addr,
 /*
  * Enable/disable VLAN acceleration.
  */
-void t1_vlan_mode(struct adapter *adapter, u32 features)
+void t1_vlan_mode(struct adapter *adapter, netdev_features_t features)
 {
 	struct sge *sge =3D adapter->sge;
=20
diff --git a/drivers/net/ethernet/chelsio/cxgb/sge.h b/drivers/net/ethe=
rnet/chelsio/cxgb/sge.h
index e03980b..b9bf16b 100644
--- a/drivers/net/ethernet/chelsio/cxgb/sge.h
+++ b/drivers/net/ethernet/chelsio/cxgb/sge.h
@@ -79,7 +79,7 @@ irqreturn_t t1_interrupt(int irq, void *cookie);
 int t1_poll(struct napi_struct *, int);
=20
 netdev_tx_t t1_start_xmit(struct sk_buff *skb, struct net_device *dev)=
;
-void t1_vlan_mode(struct adapter *adapter, u32 features);
+void t1_vlan_mode(struct adapter *adapter, netdev_features_t features)=
;
 void t1_sge_start(struct sge *);
 void t1_sge_stop(struct sge *);
 int t1_sge_intr_error_handler(struct sge *);
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/=
net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 4d15c8f..77b27b1 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -2531,7 +2531,7 @@ static void t3_synchronize_rx(struct adapter *ada=
p, const struct port_info *p)
 	}
 }
=20
-static void cxgb_vlan_mode(struct net_device *dev, u32 features)
+static void cxgb_vlan_mode(struct net_device *dev, netdev_features_t f=
eatures)
 {
 	struct port_info *pi =3D netdev_priv(dev);
 	struct adapter *adapter =3D pi->adapter;
@@ -2552,7 +2552,8 @@ static void cxgb_vlan_mode(struct net_device *dev=
, u32 features)
 	t3_synchronize_rx(adapter, pi);
 }
=20
-static u32 cxgb_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t cxgb_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -2566,9 +2567,9 @@ static u32 cxgb_fix_features(struct net_device *d=
ev, u32 features)
 	return features;
 }
=20
-static int cxgb_set_features(struct net_device *dev, u32 features)
+static int cxgb_set_features(struct net_device *dev, netdev_features_t=
 features)
 {
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		cxgb_vlan_mode(dev, features);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/=
net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4c8f42a..6f4f5de 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1855,10 +1855,10 @@ static int set_wol(struct net_device *dev, stru=
ct ethtool_wolinfo *wol)
 	return err;
 }
=20
-static int cxgb_set_features(struct net_device *dev, u32 features)
+static int cxgb_set_features(struct net_device *dev, netdev_features_t=
 features)
 {
 	const struct port_info *pi =3D netdev_priv(dev);
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
 	int err;
=20
 	if (!(changed & NETIF_F_HW_VLAN_RX))
@@ -3537,7 +3537,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 {
 	int func, i, err;
 	struct port_info *pi;
-	unsigned int highdma =3D 0;
+	bool highdma =3D false;
 	struct adapter *adapter =3D NULL;
=20
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
@@ -3563,7 +3563,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 	}
=20
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		highdma =3D NETIF_F_HIGHDMA;
+		highdma =3D true;
 		err =3D pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err) {
 			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for "
@@ -3637,7 +3637,9 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_RXCSUM | NETIF_F_RXHASH |
 			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-		netdev->features |=3D netdev->hw_features | highdma;
+		if (highdma)
+			netdev->hw_features |=3D NETIF_F_HIGHDMA;
+		netdev->features |=3D netdev->hw_features;
 		netdev->vlan_features =3D netdev->features & VLAN_FEAT;
=20
 		netdev->priv_flags |=3D IFF_UNICAST_FLT;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/driv=
ers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index da9072b..e4056c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -1092,7 +1092,8 @@ static int cxgb4vf_change_mtu(struct net_device *=
dev, int new_mtu)
 	return ret;
 }
=20
-static u32 cxgb4vf_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t cxgb4vf_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -1106,10 +1107,11 @@ static u32 cxgb4vf_fix_features(struct net_devi=
ce *dev, u32 features)
 	return features;
 }
=20
-static int cxgb4vf_set_features(struct net_device *dev, u32 features)
+static int cxgb4vf_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct port_info *pi =3D netdev_priv(dev);
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		t4vf_set_rxmode(pi->adapter, pi->viid, -1, -1, -1, -1,
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethern=
et/davicom/dm9000.c
index 438f458..26be1df 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -474,10 +474,11 @@ static int dm9000_nway_reset(struct net_device *d=
ev)
 	return mii_nway_restart(&dm->mii);
 }
=20
-static int dm9000_set_features(struct net_device *dev, u32 features)
+static int dm9000_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	board_info_t *dm =3D to_dm9000_board(dev);
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
 	unsigned long flags;
=20
 	if (!(changed & NETIF_F_RXCSUM))
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/eth=
ernet/freescale/gianfar.c
index 83199fd..ff3e8b0 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2306,7 +2306,7 @@ void gfar_check_rx_parser_mode(struct gfar_privat=
e *priv)
 }
=20
 /* Enables and disables VLAN insertion/extraction */
-void gfar_vlan_mode(struct net_device *dev, u32 features)
+void gfar_vlan_mode(struct net_device *dev, netdev_features_t features=
)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
 	struct gfar __iomem *regs =3D NULL;
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/eth=
ernet/freescale/gianfar.h
index 9aa4377..cda6cb2 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1179,9 +1179,9 @@ extern void gfar_phy_test(struct mii_bus *bus, st=
ruct phy_device *phydev,
 extern void gfar_configure_coalescing(struct gfar_private *priv,
 		unsigned long tx_mask, unsigned long rx_mask);
 void gfar_init_sysfs(struct net_device *dev);
-int gfar_set_features(struct net_device *dev, u32 features);
+int gfar_set_features(struct net_device *dev, netdev_features_t featur=
es);
 extern void gfar_check_rx_parser_mode(struct gfar_private *priv);
-extern void gfar_vlan_mode(struct net_device *dev, u32 features);
+extern void gfar_vlan_mode(struct net_device *dev, netdev_features_t f=
eatures);
=20
 extern const struct ethtool_ops gfar_ethtool_ops;
=20
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers=
/net/ethernet/freescale/gianfar_ethtool.c
index 212736b..1ea0eb9 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -519,12 +519,12 @@ static int gfar_sringparam(struct net_device *dev=
, struct ethtool_ringparam *rva
 	return err;
 }
=20
-int gfar_set_features(struct net_device *dev, u32 features)
+int gfar_set_features(struct net_device *dev, netdev_features_t featur=
es)
 {
 	struct gfar_private *priv =3D netdev_priv(dev);
 	unsigned long flags;
 	int err =3D 0, i =3D 0;
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	if (changed & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
 		gfar_vlan_mode(dev, features);
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/=
ibm/ibmveth.c
index b1cd41b..e877371 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -735,7 +735,8 @@ static void netdev_get_drvinfo(struct net_device *d=
ev,
 		sizeof(info->version) - 1);
 }
=20
-static u32 ibmveth_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t ibmveth_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	/*
 	 * Since the ibmveth firmware interface does not have the
@@ -838,7 +839,8 @@ static int ibmveth_set_csum_offload(struct net_devi=
ce *dev, u32 data)
 	return rc1 ? rc1 : rc2;
 }
=20
-static int ibmveth_set_features(struct net_device *dev, u32 features)
+static int ibmveth_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct ibmveth_adapter *adapter =3D netdev_priv(dev);
 	int rx_csum =3D !!(features & NETIF_F_RXCSUM);
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/ne=
t/ethernet/intel/e1000/e1000_main.c
index cf480b5..82f4ef1 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -167,7 +167,8 @@ static int e1000_82547_fifo_workaround(struct e1000=
_adapter *adapter,
                                        struct sk_buff *skb);
=20
 static bool e1000_vlan_used(struct e1000_adapter *adapter);
-static void e1000_vlan_mode(struct net_device *netdev, u32 features);
+static void e1000_vlan_mode(struct net_device *netdev,
+			    netdev_features_t features);
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)=
;
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
@@ -806,7 +807,8 @@ static int e1000_is_need_ioport(struct pci_dev *pde=
v)
 	}
 }
=20
-static u32 e1000_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t e1000_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -820,10 +822,11 @@ static u32 e1000_fix_features(struct net_device *=
netdev, u32 features)
 	return features;
 }
=20
-static int e1000_set_features(struct net_device *netdev, u32 features)
+static int e1000_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	u32 changed =3D features ^ netdev->features;
+	netdev_features_t changed =3D features ^ netdev->features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		e1000_vlan_mode(netdev, features);
@@ -4577,7 +4580,8 @@ static void e1000_vlan_filter_on_off(struct e1000=
_adapter *adapter,
 		e1000_irq_enable(adapter);
 }
=20
-static void e1000_vlan_mode(struct net_device *netdev, u32 features)
+static void e1000_vlan_mode(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/e=
thernet/intel/e1000e/netdev.c
index 6803127..863043f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5859,10 +5859,11 @@ static void e1000_eeprom_checks(struct e1000_ad=
apter *adapter)
 	}
 }
=20
-static int e1000_set_features(struct net_device *netdev, u32 features)
+static int e1000_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct e1000_adapter *adapter =3D netdev_priv(netdev);
-	u32 changed =3D features ^ netdev->features;
+	netdev_features_t changed =3D features ^ netdev->features;
=20
 	if (changed & (NETIF_F_TSO | NETIF_F_TSO6))
 		adapter->flags |=3D FLAG_TSO_FORCE;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/et=
hernet/intel/igb/igb_main.c
index ced5444..1fcba22 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -145,7 +145,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *,=
 int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
-static void igb_vlan_mode(struct net_device *netdev, u32 features);
+static void igb_vlan_mode(struct net_device *netdev, netdev_features_t=
 features);
 static void igb_vlan_rx_add_vid(struct net_device *, u16);
 static void igb_vlan_rx_kill_vid(struct net_device *, u16);
 static void igb_restore_vlan(struct igb_adapter *);
@@ -1742,7 +1742,8 @@ void igb_reset(struct igb_adapter *adapter)
 	igb_get_phy_info(hw);
 }
=20
-static u32 igb_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t igb_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -1756,9 +1757,10 @@ static u32 igb_fix_features(struct net_device *n=
etdev, u32 features)
 	return features;
 }
=20
-static int igb_set_features(struct net_device *netdev, u32 features)
+static int igb_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
-	u32 changed =3D netdev->features ^ features;
+	netdev_features_t changed =3D netdev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		igb_vlan_mode(netdev, features);
@@ -6467,7 +6469,7 @@ s32 igb_write_pcie_cap_reg(struct e1000_hw *hw, u=
32 reg, u16 *value)
 	return 0;
 }
=20
-static void igb_vlan_mode(struct net_device *netdev, u32 features)
+static void igb_vlan_mode(struct net_device *netdev, netdev_features_t=
 features)
 {
 	struct igb_adapter *adapter =3D netdev_priv(netdev);
 	struct e1000_hw *hw =3D &adapter->hw;
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/et=
hernet/intel/igbvf/netdev.c
index cca7812..2a05658 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2532,7 +2532,8 @@ static void igbvf_print_device_info(struct igbvf_=
adapter *adapter)
 	dev_info(&pdev->dev, "Address: %pM\n", netdev->dev_addr);
 }
=20
-static int igbvf_set_features(struct net_device *netdev, u32 features)
+static int igbvf_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct igbvf_adapter *adapter =3D netdev_priv(netdev);
=20
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/=
ethernet/intel/ixgb/ixgb_main.c
index e21148f..247cf92 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -325,8 +325,8 @@ ixgb_reset(struct ixgb_adapter *adapter)
 	}
 }
=20
-static u32
-ixgb_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t
+ixgb_fix_features(struct net_device *netdev, netdev_features_t feature=
s)
 {
 	/*
 	 * Tx VLAN insertion does not work per HW design when Rx stripping is
@@ -339,10 +339,10 @@ ixgb_fix_features(struct net_device *netdev, u32 =
features)
 }
=20
 static int
-ixgb_set_features(struct net_device *netdev, u32 features)
+ixgb_set_features(struct net_device *netdev, netdev_features_t feature=
s)
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
-	u32 changed =3D features ^ netdev->features;
+	netdev_features_t changed =3D features ^ netdev->features;
=20
 	if (!(changed & (NETIF_F_RXCSUM|NETIF_F_HW_VLAN_RX)))
 		return 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/ne=
t/ethernet/intel/ixgbe/ixgbe_main.c
index 09b8e88..4092b59 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7184,7 +7184,8 @@ void ixgbe_do_reset(struct net_device *netdev)
 		ixgbe_reset(adapter);
 }
=20
-static u32 ixgbe_fix_features(struct net_device *netdev, u32 data)
+static netdev_features_t ixgbe_fix_features(struct net_device *netdev,
+	netdev_features_t data)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
=20
@@ -7214,7 +7215,8 @@ static u32 ixgbe_fix_features(struct net_device *=
netdev, u32 data)
 	return data;
 }
=20
-static int ixgbe_set_features(struct net_device *netdev, u32 data)
+static int ixgbe_set_features(struct net_device *netdev,
+	netdev_features_t data)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
 	bool need_reset =3D false;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/driver=
s/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 5e92cc2..f5f4ef3 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3249,7 +3249,8 @@ static struct rtnl_link_stats64 *ixgbevf_get_stat=
s(struct net_device *netdev,
 	return stats;
 }
=20
-static int ixgbevf_set_features(struct net_device *netdev, u32 feature=
s)
+static int ixgbevf_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct ixgbevf_adapter *adapter =3D netdev_priv(netdev);
=20
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 7a0c746f..fc2b749 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1917,7 +1917,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk=
_buff *skb, int idx)
 	struct jme_ring *txring =3D &(jme->txring[0]);
 	struct txdesc *txdesc =3D txring->desc, *ctxdesc;
 	struct jme_buffer_info *txbi =3D txring->bufinf, *ctxbi;
-	u8 hidma =3D jme->dev->features & NETIF_F_HIGHDMA;
+	u8 hidma =3D !!(jme->dev->features & NETIF_F_HIGHDMA);
 	int i, nr_frags =3D skb_shinfo(skb)->nr_frags;
 	int mask =3D jme->tx_ring_mask;
 	const struct skb_frag_struct *frag;
@@ -2620,8 +2620,8 @@ jme_set_msglevel(struct net_device *netdev, u32 v=
alue)
 	jme->msg_enable =3D value;
 }
=20
-static u32
-jme_fix_features(struct net_device *netdev, u32 features)
+static netdev_features_t
+jme_fix_features(struct net_device *netdev, netdev_features_t features=
)
 {
 	if (netdev->mtu > 1900)
 		features &=3D ~(NETIF_F_ALL_TSO | NETIF_F_ALL_CSUM);
@@ -2629,7 +2629,7 @@ jme_fix_features(struct net_device *netdev, u32 f=
eatures)
 }
=20
 static int
-jme_set_features(struct net_device *netdev, u32 features)
+jme_set_features(struct net_device *netdev, netdev_features_t features=
)
 {
 	struct jme_adapter *jme =3D netdev_priv(netdev);
=20
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/e=
thernet/marvell/mv643xx_eth.c
index 194a031..e123b6d 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1578,10 +1578,10 @@ mv643xx_eth_set_ringparam(struct net_device *de=
v, struct ethtool_ringparam *er)
=20
=20
 static int
-mv643xx_eth_set_features(struct net_device *dev, u32 features)
+mv643xx_eth_set_features(struct net_device *dev, netdev_features_t fea=
tures)
 {
 	struct mv643xx_eth_private *mp =3D netdev_priv(dev);
-	u32 rx_csum =3D features & NETIF_F_RXCSUM;
+	int rx_csum =3D !!(features & NETIF_F_RXCSUM);
=20
 	wrlp(mp, PORT_CONFIG, rx_csum ? 0x02000000 : 0x00000000);
=20
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet=
/marvell/sky2.c
index 7b083c4..d234261 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1286,7 +1286,7 @@ static void rx_set_checksum(struct sky2_port *sky=
2)
 }
=20
 /* Enable/disable receive hash calculation (RSS) */
-static void rx_set_rss(struct net_device *dev, u32 features)
+static void rx_set_rss(struct net_device *dev, netdev_features_t featu=
res)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
 	struct sky2_hw *hw =3D sky2->hw;
@@ -1407,7 +1407,7 @@ static int sky2_ioctl(struct net_device *dev, str=
uct ifreq *ifr, int cmd)
=20
 #define SKY2_VLAN_OFFLOADS (NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO=
)
=20
-static void sky2_vlan_mode(struct net_device *dev, u32 features)
+static void sky2_vlan_mode(struct net_device *dev, netdev_features_t f=
eatures)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
 	struct sky2_hw *hw =3D sky2->hw;
@@ -4292,7 +4292,8 @@ static int sky2_set_eeprom(struct net_device *dev=
, struct ethtool_eeprom *eeprom
 	return sky2_vpd_write(sky2->hw, cap, data, eeprom->offset, eeprom->le=
n);
 }
=20
-static u32 sky2_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t sky2_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	const struct sky2_port *sky2 =3D netdev_priv(dev);
 	const struct sky2_hw *hw =3D sky2->hw;
@@ -4316,13 +4317,13 @@ static u32 sky2_fix_features(struct net_device =
*dev, u32 features)
 	return features;
 }
=20
-static int sky2_set_features(struct net_device *dev, u32 features)
+static int sky2_set_features(struct net_device *dev, netdev_features_t=
 features)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	if (changed & NETIF_F_RXCSUM) {
-		u32 on =3D features & NETIF_F_RXCSUM;
+		int on =3D !!(features & NETIF_F_RXCSUM);
 		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
 			     on ? BMU_ENA_RX_CHKSUM : BMU_DIS_RX_CHKSUM);
 	}
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethern=
et/micrel/ksz884x.c
index 7ece990..f697cff 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -6587,7 +6587,8 @@ static void netdev_get_ethtool_stats(struct net_d=
evice *dev,
  *
  * Return 0 if successful; otherwise an error code.
  */
-static int netdev_set_features(struct net_device *dev, u32 features)
+static int netdev_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct dev_priv *priv =3D netdev_priv(dev);
 	struct dev_info *hw_priv =3D priv->adapter;
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers=
/net/ethernet/myricom/myri10ge/myri10ge.c
index 0778edc..20b72ec 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -1491,7 +1491,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_stat=
e *ss, int budget)
 	 * access to avoid theoretical race condition with functions that
 	 * change NETIF_F_LRO flag at runtime.
 	 */
-	bool lro_enabled =3D ACCESS_ONCE(mgp->dev->features) & NETIF_F_LRO;
+	bool lro_enabled =3D !!(ACCESS_ONCE(mgp->dev->features) & NETIF_F_LRO=
);
=20
 	while (rx_done->entry[idx].length !=3D 0 && work_done < budget) {
 		length =3D ntohs(rx_done->entry[idx].length);
@@ -3149,7 +3149,8 @@ static int myri10ge_set_mac_address(struct net_de=
vice *dev, void *addr)
 	return 0;
 }
=20
-static u32 myri10ge_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t myri10ge_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	if (!(features & NETIF_F_RXCSUM))
 		features &=3D ~NETIF_F_LRO;
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/etherne=
t/neterion/s2io.c
index c27fb3d..589d322 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -6616,10 +6616,10 @@ static void s2io_ethtool_get_strings(struct net=
_device *dev,
 	}
 }
=20
-static int s2io_set_features(struct net_device *dev, u32 features)
+static int s2io_set_features(struct net_device *dev, netdev_features_t=
 features)
 {
 	struct s2io_nic *sp =3D netdev_priv(dev);
-	u32 changed =3D (features ^ dev->features) & NETIF_F_LRO;
+	netdev_features_t changed =3D (features ^ dev->features) & NETIF_F_LR=
O;
=20
 	if (changed && netif_running(dev)) {
 		int rc;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/n=
et/ethernet/neterion/vxge/vxge-main.c
index 671e166..2d5afe3 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -2661,9 +2661,10 @@ static void vxge_poll_vp_lockup(unsigned long da=
ta)
 	mod_timer(&vdev->vp_lockup_timer, jiffies + HZ / 1000);
 }
=20
-static u32 vxge_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t vxge_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	/* Enabling RTH requires some of the logic in vxge_device_register an=
d a
 	 * vpath reset.  Due to these restrictions, only allow modification
@@ -2675,10 +2676,10 @@ static u32 vxge_fix_features(struct net_device =
*dev, u32 features)
 	return features;
 }
=20
-static int vxge_set_features(struct net_device *dev, u32 features)
+static int vxge_set_features(struct net_device *dev, netdev_features_t=
 features)
 {
 	struct vxgedev *vdev =3D netdev_priv(dev);
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	if (!(changed & NETIF_F_RXHASH))
 		return 0;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethe=
rnet/nvidia/forcedeth.c
index 1e37eb9..44af6c1 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4481,7 +4481,8 @@ static int nv_set_pauseparam(struct net_device *d=
ev, struct ethtool_pauseparam*
 	return 0;
 }
=20
-static u32 nv_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t nv_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	/* vlan is dependent on rx checksum offload */
 	if (features & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
@@ -4490,7 +4491,7 @@ static u32 nv_fix_features(struct net_device *dev=
, u32 features)
 	return features;
 }
=20
-static void nv_vlan_mode(struct net_device *dev, u32 features)
+static void nv_vlan_mode(struct net_device *dev, netdev_features_t fea=
tures)
 {
 	struct fe_priv *np =3D get_nvpriv(dev);
=20
@@ -4511,11 +4512,11 @@ static void nv_vlan_mode(struct net_device *dev=
, u32 features)
 	spin_unlock_irq(&np->lock);
 }
=20
-static int nv_set_features(struct net_device *dev, u32 features)
+static int nv_set_features(struct net_device *dev, netdev_features_t f=
eatures)
 {
 	struct fe_priv *np =3D netdev_priv(dev);
 	u8 __iomem *base =3D get_hwbase(dev);
-	u32 changed =3D dev->features ^ features;
+	netdev_features_t changed =3D dev->features ^ features;
=20
 	if (changed & NETIF_F_RXCSUM) {
 		spin_lock_irq(&np->lock);
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/dri=
vers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b89f3a6..d588cad 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2108,10 +2108,11 @@ static int pch_gbe_change_mtu(struct net_device=
 *netdev, int new_mtu)
  * Returns
  *	0:		HW state updated successfully
  */
-static int pch_gbe_set_features(struct net_device *netdev, u32 feature=
s)
+static int pch_gbe_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct pch_gbe_adapter *adapter =3D netdev_priv(netdev);
-	u32 changed =3D features ^ netdev->features;
+	netdev_features_t changed =3D features ^ netdev->features;
=20
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/dri=
vers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 8cf3173..7dd9a4b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -544,7 +544,8 @@ static void netxen_set_multicast_list(struct net_de=
vice *dev)
 	adapter->set_multi(dev);
 }
=20
-static u32 netxen_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t netxen_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	if (!(features & NETIF_F_RXCSUM)) {
 		netdev_info(dev, "disabling LRO as RXCSUM is off\n");
@@ -555,7 +556,8 @@ static u32 netxen_fix_features(struct net_device *d=
ev, u32 features)
 	return features;
 }
=20
-static int netxen_set_features(struct net_device *dev, u32 features)
+static int netxen_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct netxen_adapter *adapter =3D netdev_priv(dev);
 	int hw_lro;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/=
ethernet/qlogic/qlcnic/qlcnic.h
index 2fd1ba8..348a64b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1466,8 +1466,9 @@ void qlcnic_advert_link_change(struct qlcnic_adap=
ter *adapter, int linkup);
=20
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
-u32 qlcnic_fix_features(struct net_device *netdev, u32 features);
-int qlcnic_set_features(struct net_device *netdev, u32 features);
+netdev_features_t qlcnic_fix_features(struct net_device *netdev,
+	netdev_features_t features);
+int qlcnic_set_features(struct net_device *netdev, netdev_features_t f=
eatures);
 int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
 int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 ena=
ble);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/n=
et/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 74e9d7b..960aab7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -817,12 +817,13 @@ int qlcnic_change_mtu(struct net_device *netdev, =
int mtu)
 }
=20
=20
-u32 qlcnic_fix_features(struct net_device *netdev, u32 features)
+netdev_features_t qlcnic_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
=20
 	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
-		u32 changed =3D features ^ netdev->features;
+		netdev_features_t changed =3D features ^ netdev->features;
 		features ^=3D changed & (NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
 	}
=20
@@ -833,10 +834,10 @@ u32 qlcnic_fix_features(struct net_device *netdev=
, u32 features)
 }
=20
=20
-int qlcnic_set_features(struct net_device *netdev, u32 features)
+int qlcnic_set_features(struct net_device *netdev, netdev_features_t f=
eatures)
 {
 	struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
-	u32 changed =3D netdev->features ^ features;
+	netdev_features_t changed =3D netdev->features ^ features;
 	int hw_lro =3D (features & NETIF_F_LRO) ? QLCNIC_LRO_ENABLED : 0;
=20
 	if (!(changed & NETIF_F_LRO))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers=
/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 106503f..089aa3c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -792,7 +792,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *a=
dapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	struct net_device *netdev =3D adapter->netdev;
-	unsigned long features, vlan_features;
+	netdev_features_t features, vlan_features;
=20
 	features =3D (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net=
/ethernet/qlogic/qlge/qlge_main.c
index c92afcd..1ce4e08 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2307,7 +2307,7 @@ static int ql_napi_poll_msix(struct napi_struct *=
napi, int budget)
 	return work_done;
 }
=20
-static void qlge_vlan_mode(struct net_device *ndev, u32 features)
+static void qlge_vlan_mode(struct net_device *ndev, netdev_features_t =
features)
 {
 	struct ql_adapter *qdev =3D netdev_priv(ndev);
=20
@@ -2323,7 +2323,8 @@ static void qlge_vlan_mode(struct net_device *nde=
v, u32 features)
 	}
 }
=20
-static u32 qlge_fix_features(struct net_device *ndev, u32 features)
+static netdev_features_t qlge_fix_features(struct net_device *ndev,
+	netdev_features_t features)
 {
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
@@ -2337,9 +2338,10 @@ static u32 qlge_fix_features(struct net_device *=
ndev, u32 features)
 	return features;
 }
=20
-static int qlge_set_features(struct net_device *ndev, u32 features)
+static int qlge_set_features(struct net_device *ndev,
+	netdev_features_t features)
 {
-	u32 changed =3D ndev->features ^ features;
+	netdev_features_t changed =3D ndev->features ^ features;
=20
 	if (changed & NETIF_F_HW_VLAN_RX)
 		qlge_vlan_mode(ndev, features);
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethern=
et/realtek/8139cp.c
index ee5da92..25d9eab 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1392,7 +1392,7 @@ static void cp_set_msglevel(struct net_device *de=
v, u32 value)
 	cp->msg_enable =3D value;
 }
=20
-static int cp_set_features(struct net_device *dev, u32 features)
+static int cp_set_features(struct net_device *dev, netdev_features_t f=
eatures)
 {
 	struct cp_private *cp =3D netdev_priv(dev);
 	unsigned long flags;
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index aa39e77..0309f98 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1553,7 +1553,8 @@ static int rtl8169_set_settings(struct net_device=
 *dev, struct ethtool_cmd *cmd)
 	return ret;
 }
=20
-static u32 rtl8169_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t rtl8169_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
=20
@@ -1567,7 +1568,8 @@ static u32 rtl8169_fix_features(struct net_device=
 *dev, u32 features)
 	return features;
 }
=20
-static int rtl8169_set_features(struct net_device *dev, u32 features)
+static int rtl8169_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
 	void __iomem *ioaddr =3D tp->mmio_addr;
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/=
efx.c
index de9afeb..6875986 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1900,7 +1900,7 @@ static void efx_set_multicast_list(struct net_dev=
ice *net_dev)
 	/* Otherwise efx_start_port() will do this */
 }
=20
-static int efx_set_features(struct net_device *net_dev, u32 data)
+static int efx_set_features(struct net_device *net_dev, netdev_feature=
s_t data)
 {
 	struct efx_nic *efx =3D netdev_priv(net_dev);
=20
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethern=
et/sfc/net_driver.h
index b8e251a..c49502b 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -908,7 +908,7 @@ struct efx_nic_type {
 	unsigned int phys_addr_channels;
 	unsigned int tx_dc_base;
 	unsigned int rx_dc_base;
-	u32 offload_features;
+	netdev_features_t offload_features;
 };
=20
 /*********************************************************************=
*****
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/driver=
s/net/ethernet/stmicro/stmmac/stmmac_main.c
index aeaa15b..bf0fe71 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1416,7 +1416,8 @@ static int stmmac_change_mtu(struct net_device *d=
ev, int new_mtu)
 	return 0;
 }
=20
-static u32 stmmac_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t stmmac_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct stmmac_priv *priv =3D netdev_priv(dev);
=20
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7bea9c6..5af6261 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -123,7 +123,7 @@ struct tun_struct {
 	gid_t			group;
=20
 	struct net_device	*dev;
-	u32			set_features;
+	netdev_features_t	set_features;
 #define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO=
| \
 			  NETIF_F_TSO6|NETIF_F_UFO)
 	struct fasync_struct	*fasync;
@@ -454,7 +454,8 @@ tun_net_change_mtu(struct net_device *dev, int new_=
mtu)
 	return 0;
 }
=20
-static u32 tun_net_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t tun_net_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct tun_struct *tun =3D netdev_priv(dev);
=20
@@ -1196,7 +1197,7 @@ static int tun_get_iff(struct net *net, struct tu=
n_struct *tun,
  * privs required. */
 static int set_offload(struct tun_struct *tun, unsigned long arg)
 {
-	u32 features =3D 0;
+	netdev_features_t features =3D 0;
=20
 	if (arg & TUN_F_CSUM) {
 		features |=3D NETIF_F_HW_CSUM;
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 22a7cf9..e14b3fa 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -727,7 +727,8 @@ static int smsc75xx_change_mtu(struct net_device *n=
etdev, int new_mtu)
 }
=20
 /* Enable or disable Rx checksum offload engine */
-static int smsc75xx_set_features(struct net_device *netdev, u32 featur=
es)
+static int smsc75xx_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct usbnet *dev =3D netdev_priv(netdev);
 	struct smsc75xx_priv *pdata =3D (struct smsc75xx_priv *)(dev->data[0]=
);
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index eff6767..56f3894 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -516,7 +516,8 @@ static void smsc95xx_status(struct usbnet *dev, str=
uct urb *urb)
 }
=20
 /* Enable or disable Tx & Rx checksum offload engines */
-static int smsc95xx_set_features(struct net_device *netdev, u32 featur=
es)
+static int smsc95xx_set_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct usbnet *dev =3D netdev_priv(netdev);
 	u32 read_buf;
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet=
3/vmxnet3_ethtool.c
index e662cbc..77f7234 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -262,11 +262,11 @@ vmxnet3_get_strings(struct net_device *netdev, u3=
2 stringset, u8 *buf)
 	}
 }
=20
-int vmxnet3_set_features(struct net_device *netdev, u32 features)
+int vmxnet3_set_features(struct net_device *netdev, netdev_features_t =
features)
 {
 	struct vmxnet3_adapter *adapter =3D netdev_priv(netdev);
 	unsigned long flags;
-	u32 changed =3D features ^ netdev->features;
+	netdev_features_t changed =3D features ^ netdev->features;
=20
 	if (changed & (NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_HW_VLAN_RX)) {
 		if (features & NETIF_F_RXCSUM)
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vm=
xnet3_int.h
index b18eac1..ed54797 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -401,7 +401,7 @@ void
 vmxnet3_rq_destroy_all(struct vmxnet3_adapter *adapter);
=20
 int
-vmxnet3_set_features(struct net_device *netdev, u32 features);
+vmxnet3_set_features(struct net_device *netdev, netdev_features_t feat=
ures);
=20
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netb=
ack/interface.c
index 1825629..0b5c18f 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -165,7 +165,8 @@ static int xenvif_change_mtu(struct net_device *dev=
, int mtu)
 	return 0;
 }
=20
-static u32 xenvif_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t xenvif_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct xenvif *vif =3D netdev_priv(dev);
=20
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 226faab..a6e379f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -203,7 +203,7 @@ static void xennet_sysfs_delif(struct net_device *n=
etdev);
=20
 static int xennet_can_sg(struct net_device *dev)
 {
-	return dev->features & NETIF_F_SG;
+	return !!(dev->features & NETIF_F_SG);
 }
=20
=20
@@ -1190,7 +1190,8 @@ static void xennet_uninit(struct net_device *dev)
 	gnttab_free_grant_references(np->gref_rx_head);
 }
=20
-static u32 xennet_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t xennet_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct netfront_info *np =3D netdev_priv(dev);
 	int val;
@@ -1216,7 +1217,8 @@ static u32 xennet_fix_features(struct net_device =
*dev, u32 features)
 	return features;
 }
=20
-static int xennet_set_features(struct net_device *dev, u32 features)
+static int xennet_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN) {
 		netdev_info(dev, "Reducing MTU because no SG offload");
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3=
_main.c
index ce73520..181bcf4 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3202,7 +3202,8 @@ static int qeth_l3_stop(struct net_device *dev)
 	return 0;
 }
=20
-static u32 qeth_l3_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t qeth_l3_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct qeth_card *card =3D dev->ml_priv;
=20
@@ -3216,7 +3217,8 @@ static u32 qeth_l3_fix_features(struct net_device=
 *dev, u32 features)
 	return features;
 }
=20
-static int qeth_l3_set_features(struct net_device *dev, u32 features)
+static int qeth_l3_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct qeth_card *card =3D dev->ml_priv;
 	u32 changed =3D dev->features ^ features;
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
index 32640ed..af52381 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -10,6 +10,10 @@
 #ifndef _LINUX_NETDEV_FEATURES_H
 #define _LINUX_NETDEV_FEATURES_H
=20
+#include <linux/types.h>
+
+typedef u32 netdev_features_t;
+
 /* Net device feature bits; if you change something,
  * also update netdev_features_strings[] in ethtool.c */
=20
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 82787b3..d1277b4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -847,12 +847,13 @@ struct netdev_tc_txq {
  *	Called to release previously enslaved netdev.
  *
  *      Feature/offload setting functions.
- * u32 (*ndo_fix_features)(struct net_device *dev, u32 features);
+ * netdev_features_t (*ndo_fix_features)(struct net_device *dev,
+ *		netdev_features_t features);
  *	Adjusts the requested feature flags according to device-specific
  *	constraints, and returns the resulting flags. Must not modify
  *	the device state.
  *
- * int (*ndo_set_features)(struct net_device *dev, u32 features);
+ * int (*ndo_set_features)(struct net_device *dev, netdev_features_t f=
eatures);
  *	Called to update device configuration to new features. Passed
  *	feature set might be less than what was returned by ndo_fix_feature=
s()).
  *	Must return >0 or -errno if it changed dev->features itself.
@@ -946,10 +947,10 @@ struct net_device_ops {
 						 struct net_device *slave_dev);
 	int			(*ndo_del_slave)(struct net_device *dev,
 						 struct net_device *slave_dev);
-	u32			(*ndo_fix_features)(struct net_device *dev,
-						    u32 features);
+	netdev_features_t	(*ndo_fix_features)(struct net_device *dev,
+						    netdev_features_t features);
 	int			(*ndo_set_features)(struct net_device *dev,
-						    u32 features);
+						    netdev_features_t features);
 };
=20
 /*
@@ -999,13 +1000,13 @@ struct net_device {
 	struct list_head	unreg_list;
=20
 	/* currently active device features */
-	u32			features;
+	netdev_features_t	features;
 	/* user-changeable features */
-	u32			hw_features;
+	netdev_features_t	hw_features;
 	/* user-requested features */
-	u32			wanted_features;
+	netdev_features_t	wanted_features;
 	/* mask of features inheritable by VLAN devices */
-	u32			vlan_features;
+	netdev_features_t	vlan_features;
=20
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
@@ -1439,7 +1440,7 @@ struct packet_type {
 					 struct packet_type *,
 					 struct net_device *);
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
-						u32 features);
+						netdev_features_t features);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
@@ -2444,7 +2445,8 @@ extern int		netdev_set_master(struct net_device *=
dev, struct net_device *master)
 extern int netdev_set_bond_master(struct net_device *dev,
 				  struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb);
-extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 featur=
es);
+extern struct sk_buff *skb_gso_segment(struct sk_buff *skb,
+	netdev_features_t features);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
@@ -2471,11 +2473,13 @@ extern const char *netdev_drivername(const stru=
ct net_device *dev);
=20
 extern void linkwatch_run_queue(void);
=20
-static inline u32 netdev_get_wanted_features(struct net_device *dev)
+static inline netdev_features_t netdev_get_wanted_features(
+	struct net_device *dev)
 {
 	return (dev->features & ~dev->hw_features) | dev->wanted_features;
 }
-u32 netdev_increment_features(u32 all, u32 one, u32 mask);
+netdev_features_t netdev_increment_features(netdev_features_t all,
+	netdev_features_t one, netdev_features_t mask);
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
 void netdev_change_features(struct net_device *dev);
@@ -2483,21 +2487,22 @@ void netdev_change_features(struct net_device *=
dev);
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
 					struct net_device *dev);
=20
-u32 netif_skb_features(struct sk_buff *skb);
+netdev_features_t netif_skb_features(struct sk_buff *skb);
=20
-static inline int net_gso_ok(u32 features, int gso_type)
+static inline int net_gso_ok(netdev_features_t features, int gso_type)
 {
-	int feature =3D gso_type << NETIF_F_GSO_SHIFT;
+	netdev_features_t feature =3D gso_type << NETIF_F_GSO_SHIFT;
 	return (features & feature) =3D=3D feature;
 }
=20
-static inline int skb_gso_ok(struct sk_buff *skb, u32 features)
+static inline int skb_gso_ok(struct sk_buff *skb, netdev_features_t fe=
atures)
 {
 	return net_gso_ok(features, skb_shinfo(skb)->gso_type) &&
 	       (!skb_has_frag_list(skb) || (features & NETIF_F_FRAGLIST));
 }
=20
-static inline int netif_needs_gso(struct sk_buff *skb, int features)
+static inline int netif_needs_gso(struct sk_buff *skb,
+	netdev_features_t features)
 {
 	return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
 		unlikely(skb->ip_summed !=3D CHECKSUM_PARTIAL));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 94a23ff..ef4655d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -30,6 +30,7 @@
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
 #include <linux/dma-mapping.h>
+#include <linux/netdev_features.h>
=20
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -2105,7 +2106,8 @@ extern void	       skb_split(struct sk_buff *skb,
 extern int	       skb_shift(struct sk_buff *tgt, struct sk_buff *skb,
 				 int shiftlen);
=20
-extern struct sk_buff *skb_segment(struct sk_buff *skb, u32 features);
+extern struct sk_buff *skb_segment(struct sk_buff *skb,
+				   netdev_features_t features);
=20
 static inline void *skb_header_pointer(const struct sk_buff *skb, int =
offset,
 				       int len, void *buffer)
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 6f7eb80..e182e13 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -38,7 +38,7 @@ struct net_protocol {
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
-					       u32 features);
+					       netdev_features_t features);
 	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb);
@@ -57,7 +57,7 @@ struct inet6_protocol {
=20
 	int	(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
-				       u32 features);
+				       netdev_features_t features);
 	struct sk_buff **(*gro_receive)(struct sk_buff **head,
 					struct sk_buff *skb);
 	int	(*gro_complete)(struct sk_buff *skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index 5ac682f..50b3bcb 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -307,8 +307,8 @@ struct sock {
 	kmemcheck_bitfield_end(flags);
 	int			sk_wmem_queued;
 	gfp_t			sk_allocation;
-	int			sk_route_caps;
-	int			sk_route_nocaps;
+	netdev_features_t	sk_route_caps;
+	netdev_features_t	sk_route_nocaps;
 	int			sk_gso_type;
 	unsigned int		sk_gso_max_size;
 	int			sk_rcvlowat;
@@ -1393,7 +1393,7 @@ static inline int sk_can_gso(const struct sock *s=
k)
=20
 extern void sk_setup_caps(struct sock *sk, struct dst_entry *dst);
=20
-static inline void sk_nocaps_add(struct sock *sk, int flags)
+static inline void sk_nocaps_add(struct sock *sk, netdev_features_t fl=
ags)
 {
 	sk->sk_route_nocaps |=3D flags;
 	sk->sk_route_caps &=3D ~flags;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index e147f42..a875fbd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1428,7 +1428,8 @@ extern struct request_sock_ops tcp6_request_sock_=
ops;
 extern void tcp_v4_destroy_sock(struct sock *sk);
=20
 extern int tcp_v4_gso_send_check(struct sk_buff *skb);
-extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u32 featur=
es);
+extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
+				       netdev_features_t features);
 extern struct sk_buff **tcp_gro_receive(struct sk_buff **head,
 					struct sk_buff *skb);
 extern struct sk_buff **tcp4_gro_receive(struct sk_buff **head,
diff --git a/include/net/udp.h b/include/net/udp.h
index 67ea6fc..691ca16 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -256,5 +256,6 @@ extern void udp4_proc_exit(void);
 extern void udp_init(void);
=20
 extern int udp4_ufo_send_check(struct sk_buff *skb);
-extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u32 feat=
ures);
+extern struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
+	netdev_features_t features);
 #endif	/* _UDP_H */
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index d7222a9..bf1db7a 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -796,6 +796,18 @@ char *uuid_string(char *buf, char *end, const u8 *=
addr,
 	return string(buf, end, uuid, spec);
 }
=20
+static
+char *netdev_feature_string(char *buf, char *end, const u8 *addr,
+		      struct printf_spec spec)
+{
+	spec.flags |=3D SPECIAL | SMALL | ZEROPAD;
+	if (spec.field_width =3D=3D -1)
+		spec.field_width =3D 2 + 2 * sizeof(netdev_features_t);
+	spec.base =3D 16;
+
+	return number(buf, end, *(const netdev_features_t *)addr, spec);
+}
+
 int kptr_restrict __read_mostly;
=20
 /*
@@ -843,6 +855,7 @@ int kptr_restrict __read_mostly;
  *       Do not use this feature without some mechanism to verify the
  *       correctness of the format string and va_list arguments.
  * - 'K' For a kernel pointer that should be hidden from unprivileged =
users
+ * - 'NF' For a netdev_features_t
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -915,6 +928,12 @@ char *pointer(const char *fmt, char *buf, char *en=
d, void *ptr,
 		       has_capability_noaudit(current, CAP_SYSLOG))))
 			ptr =3D NULL;
 		break;
+	case 'N':
+		switch (fmt[1]) {
+		case 'F':
+			return netdev_feature_string(buf, end, ptr, spec);
+		}
+		break;
 	}
 	spec.flags |=3D SMALL;
 	if (spec.field_width =3D=3D -1) {
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index b54a2ef..3d9cd4f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -589,7 +589,8 @@ static void vlan_dev_uninit(struct net_device *dev)
 	}
 }
=20
-static u32 vlan_dev_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
 	u32 old_features =3D features;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index feb77ea..772bad3 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -186,7 +186,8 @@ static void br_getinfo(struct net_device *dev, stru=
ct ethtool_drvinfo *info)
 	strcpy(info->bus_info, "N/A");
 }
=20
-static u32 br_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t br_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct net_bridge *br =3D netdev_priv(dev);
=20
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c3b77dc..ca36b7d 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -295,10 +295,11 @@ int br_min_mtu(const struct net_bridge *br)
 /*
  * Recomputes features using slave's features
  */
-u32 br_features_recompute(struct net_bridge *br, u32 features)
+netdev_features_t br_features_recompute(struct net_bridge *br,
+	netdev_features_t features)
 {
 	struct net_bridge_port *p;
-	u32 mask;
+	netdev_features_t mask;
=20
 	if (list_empty(&br->port_list))
 		return features;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a248fe6..29c6017 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -386,7 +386,8 @@ extern int br_add_if(struct net_bridge *br,
 extern int br_del_if(struct net_bridge *br,
 	      struct net_device *dev);
 extern int br_min_mtu(const struct net_bridge *br);
-extern u32 br_features_recompute(struct net_bridge *br, u32 features);
+extern netdev_features_t br_features_recompute(struct net_bridge *br,
+	netdev_features_t features);
=20
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6521aac..25dc263 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1915,7 +1915,8 @@ EXPORT_SYMBOL(skb_checksum_help);
  *	It may return NULL if the skb requires no segmentation.  This is
  *	only possible when GSO is used for verifying header integrity.
  */
-struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *skb_gso_segment(struct sk_buff *skb,
+	netdev_features_t features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_type *ptype;
@@ -1945,9 +1946,9 @@ struct sk_buff *skb_gso_segment(struct sk_buff *s=
kb, u32 features)
 		if (dev && dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
 			dev->ethtool_ops->get_drvinfo(dev, &info);
=20
-		WARN(1, "%s: caps=3D(0x%lx, 0x%lx) len=3D%d data_len=3D%d ip_summed=3D=
%d\n",
-		     info.driver, dev ? dev->features : 0L,
-		     skb->sk ? skb->sk->sk_route_caps : 0L,
+		WARN(1, "%s: caps=3D(%pNF, %pNF) len=3D%d data_len=3D%d ip_summed=3D=
%d\n",
+		     info.driver, dev ? &dev->features : NULL,
+		     skb->sk ? &skb->sk->sk_route_caps : NULL,
 		     skb->len, skb->data_len, skb->ip_summed);
=20
 		if (skb_header_cloned(skb) &&
@@ -2056,7 +2057,7 @@ static void dev_gso_skb_destructor(struct sk_buff=
 *skb)
  *	This function segments the given skb and stores the list of segment=
s
  *	in skb->next.
  */
-static int dev_gso_segment(struct sk_buff *skb, int features)
+static int dev_gso_segment(struct sk_buff *skb, netdev_features_t feat=
ures)
 {
 	struct sk_buff *segs;
=20
@@ -2095,7 +2096,7 @@ static inline void skb_orphan_try(struct sk_buff =
*skb)
 	}
 }
=20
-static bool can_checksum_protocol(unsigned long features, __be16 proto=
col)
+static bool can_checksum_protocol(netdev_features_t features, __be16 p=
rotocol)
 {
 	return ((features & NETIF_F_GEN_CSUM) ||
 		((features & NETIF_F_V4_CSUM) &&
@@ -2106,7 +2107,8 @@ static bool can_checksum_protocol(unsigned long f=
eatures, __be16 protocol)
 		 protocol =3D=3D htons(ETH_P_FCOE)));
 }
=20
-static u32 harmonize_features(struct sk_buff *skb, __be16 protocol, u3=
2 features)
+static netdev_features_t harmonize_features(struct sk_buff *skb,
+	__be16 protocol, netdev_features_t features)
 {
 	if (!can_checksum_protocol(features, protocol)) {
 		features &=3D ~NETIF_F_ALL_CSUM;
@@ -2118,10 +2120,10 @@ static u32 harmonize_features(struct sk_buff *s=
kb, __be16 protocol, u32 features
 	return features;
 }
=20
-u32 netif_skb_features(struct sk_buff *skb)
+netdev_features_t netif_skb_features(struct sk_buff *skb)
 {
 	__be16 protocol =3D skb->protocol;
-	u32 features =3D skb->dev->features;
+	netdev_features_t features =3D skb->dev->features;
=20
 	if (protocol =3D=3D htons(ETH_P_8021Q)) {
 		struct vlan_ethhdr *veh =3D (struct vlan_ethhdr *)skb->data;
@@ -2167,7 +2169,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 	unsigned int skb_len;
=20
 	if (likely(!skb->next)) {
-		u32 features;
+		netdev_features_t features;
=20
 		/*
 		 * If device doesn't need skb->dst, release it right now while
@@ -5354,7 +5356,8 @@ static void rollback_registered(struct net_device=
 *dev)
 	list_del(&single);
 }
=20
-static u32 netdev_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t netdev_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
@@ -5416,7 +5419,7 @@ static u32 netdev_fix_features(struct net_device =
*dev, u32 features)
=20
 int __netdev_update_features(struct net_device *dev)
 {
-	u32 features;
+	netdev_features_t features;
 	int err =3D 0;
=20
 	ASSERT_RTNL();
@@ -5432,16 +5435,16 @@ int __netdev_update_features(struct net_device =
*dev)
 	if (dev->features =3D=3D features)
 		return 0;
=20
-	netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
-		dev->features, features);
+	netdev_dbg(dev, "Features changed: %pNF -> %pNF\n",
+		&dev->features, &features);
=20
 	if (dev->netdev_ops->ndo_set_features)
 		err =3D dev->netdev_ops->ndo_set_features(dev, features);
=20
 	if (unlikely(err < 0)) {
 		netdev_err(dev,
-			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
-			err, features, dev->features);
+			"set_features() failed (%d); wanted %pNF, left %pNF\n",
+			err, &features, &dev->features);
 		return -1;
 	}
=20
@@ -6364,7 +6367,8 @@ static int dev_cpu_callback(struct notifier_block=
 *nfb,
  *	@one to the master device with current feature set @all.  Will not
  *	enable anything that is off in @mask. Returns the new feature set.
  */
-u32 netdev_increment_features(u32 all, u32 one, u32 mask)
+netdev_features_t netdev_increment_features(netdev_features_t all,
+	netdev_features_t one, netdev_features_t mask)
 {
 	if (mask & NETIF_F_GEN_CSUM)
 		mask |=3D NETIF_F_ALL_CSUM;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a354919..f135f1c 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -171,7 +171,7 @@ static void __ethtool_get_strings(struct net_device=
 *dev,
 		ops->get_strings(dev, stringset, data);
 }
=20
-static u32 ethtool_get_feature_mask(u32 eth_cmd)
+static netdev_features_t ethtool_get_feature_mask(u32 eth_cmd)
 {
 	/* feature masks of legacy discrete ethtool ops */
=20
@@ -205,7 +205,7 @@ static u32 ethtool_get_feature_mask(u32 eth_cmd)
 static int ethtool_get_one_feature(struct net_device *dev,
 	char __user *useraddr, u32 ethcmd)
 {
-	u32 mask =3D ethtool_get_feature_mask(ethcmd);
+	netdev_features_t mask =3D ethtool_get_feature_mask(ethcmd);
 	struct ethtool_value edata =3D {
 		.cmd =3D ethcmd,
 		.data =3D !!(dev->features & mask),
@@ -220,7 +220,7 @@ static int ethtool_set_one_feature(struct net_devic=
e *dev,
 	void __user *useraddr, u32 ethcmd)
 {
 	struct ethtool_value edata;
-	u32 mask;
+	netdev_features_t mask;
=20
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
@@ -260,8 +260,7 @@ static u32 __ethtool_get_flags(struct net_device *d=
ev)
=20
 static int __ethtool_set_flags(struct net_device *dev, u32 data)
 {
-	u32 features =3D 0;
-	u32 changed;
+	netdev_features_t features =3D 0, changed;
=20
 	if (data & ~ETH_ALL_FLAGS)
 		return -EINVAL;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ca4db40..779059e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2620,7 +2620,7 @@ EXPORT_SYMBOL_GPL(skb_pull_rcsum);
  *	a pointer to the first in a list of new skbs for the segments.
  *	In case of error it returns ERR_PTR(err).
  */
-struct sk_buff *skb_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t fea=
tures)
 {
 	struct sk_buff *segs =3D NULL;
 	struct sk_buff *tail =3D NULL;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1b5096a..455be41 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1250,7 +1250,8 @@ out:
 	return err;
 }
=20
-static struct sk_buff *inet_gso_segment(struct sk_buff *skb, u32 featu=
res)
+static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
+	netdev_features_t features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	struct iphdr *iph;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 34f5db1..50c3596 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2653,7 +2653,8 @@ int compat_tcp_getsockopt(struct sock *sk, int le=
vel, int optname,
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
=20
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
+	netdev_features_t features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	struct tcphdr *th;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ebaa96b..d6ca69e 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2242,7 +2242,8 @@ int udp4_ufo_send_check(struct sk_buff *skb)
 	return 0;
 }
=20
-struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb, u32 features)
+struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
+	netdev_features_t features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	unsigned int mss;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 3b5669a..7d4bd91 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -769,7 +769,8 @@ out:
 	return err;
 }
=20
-static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, u32 featu=
res)
+static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
+	netdev_features_t features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	struct ipv6hdr *ipv6h;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index f4ca0a5..5c81516 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1298,7 +1298,8 @@ static int udp6_ufo_send_check(struct sk_buff *sk=
b)
 	return 0;
 }
=20
-static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u32 feat=
ures)
+static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
+	netdev_features_t features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	unsigned int mss;
--=20
1.7.6.3
