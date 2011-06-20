From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFT PATCH 4/9] net: introduce and use netdev_features_t for device features sets
Date: Mon, 20 Jun 2011 21:14:54 +0200 (CEST)
Message-ID: <24e8026de1130f193dc82315f83ad64fcce771d8.1308596963.git.mirq-linux@rere.qmqm.pl>
References: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41913 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805Ab1FTTO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:14:58 -0400
In-Reply-To: <cover.1308596962.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The type and bits definitions are moved to separate header so that
linux/skbuff.h won't need to include linux/netdevice.h.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/8139cp.c                  |    2 +-
 drivers/net/bnx2.c                    |    6 +-
 drivers/net/bnx2x/bnx2x_cmn.c         |    5 +-
 drivers/net/bnx2x/bnx2x_cmn.h         |    5 +-
 drivers/net/bonding/bond_main.c       |    9 ++-
 drivers/net/cxgb4/cxgb4_main.c        |   12 ++--
 drivers/net/dm9000.c                  |    3 +-
 drivers/net/e1000/e1000_main.c        |    5 +-
 drivers/net/forcedeth.c               |    7 +-
 drivers/net/gianfar.h                 |    2 +-
 drivers/net/gianfar_ethtool.c         |    4 +-
 drivers/net/ibmveth.c                 |    6 +-
 drivers/net/ixgbe/ixgbe_ethtool.c     |    7 +-
 drivers/net/ixgbe/ixgbe_main.c        |    5 +-
 drivers/net/jme.c                     |    8 +-
 drivers/net/ksz884x.c                 |    3 +-
 drivers/net/mv643xx_eth.c             |    2 +-
 drivers/net/myri10ge/myri10ge.c       |    2 +-
 drivers/net/netxen/netxen_nic_main.c  |    6 +-
 drivers/net/pch_gbe/pch_gbe_main.c    |    5 +-
 drivers/net/qlcnic/qlcnic.h           |    5 +-
 drivers/net/qlcnic/qlcnic_hw.c        |    9 ++-
 drivers/net/qlcnic/qlcnic_main.c      |    2 +-
 drivers/net/r8169.c                   |    6 +-
 drivers/net/s2io.c                    |    4 +-
 drivers/net/sfc/efx.c                 |    2 +-
 drivers/net/sky2.c                    |    5 +-
 drivers/net/tg3.c                     |    7 +-
 drivers/net/usb/smsc75xx.c            |    3 +-
 drivers/net/usb/smsc95xx.c            |    3 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c |    4 +-
 drivers/net/vmxnet3/vmxnet3_int.h     |    2 +-
 drivers/net/vxge/vxge-main.c          |    9 ++-
 drivers/net/xen-netfront.c            |    8 ++-
 drivers/s390/net/qeth_l3_main.c       |    6 +-
 include/linux/netdev_features.h       |   98 +++++++++++++++++++++++++=
+
 include/linux/netdevice.h             |  125 ++++++-------------------=
--------
 include/linux/skbuff.h                |    4 +-
 include/net/protocol.h                |    4 +-
 include/net/tcp.h                     |    3 +-
 include/net/udp.h                     |    3 +-
 net/8021q/vlan_dev.c                  |    3 +-
 net/bridge/br_if.c                    |    5 +-
 net/core/dev.c                        |   34 +++++----
 net/core/ethtool.c                    |    9 +--
 net/core/net-sysfs.c                  |    2 +-
 net/core/skbuff.c                     |    2 +-
 net/ipv4/af_inet.c                    |    3 +-
 net/ipv4/tcp.c                        |    2 +-
 net/ipv4/udp.c                        |    3 +-
 net/ipv6/af_inet6.c                   |    3 +-
 net/ipv6/udp.c                        |    2 +-
 52 files changed, 271 insertions(+), 213 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 73b10b0..a14bdf4 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1416,7 +1416,7 @@ static void cp_set_msglevel(struct net_device *de=
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
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 74580bb..35f0c8a 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7502,8 +7502,8 @@ bnx2_set_phys_id(struct net_device *dev, enum eth=
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
@@ -7514,7 +7514,7 @@ bnx2_fix_features(struct net_device *dev, u32 fea=
tures)
 }
=20
 static int
-bnx2_set_features(struct net_device *dev, u32 features)
+bnx2_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct bnx2 *bp =3D netdev_priv(dev);
=20
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cm=
n.c
index bb75560..c7da8ac 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -3177,7 +3177,8 @@ int bnx2x_change_mtu(struct net_device *dev, int =
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
@@ -3188,7 +3189,7 @@ u32 bnx2x_fix_features(struct net_device *dev, u3=
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
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cm=
n.h
index c016e20..33095fb 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -519,8 +519,9 @@ void bnx2x_free_mem_bp(struct bnx2x *bp);
  */
 int bnx2x_change_mtu(struct net_device *dev, int new_mtu);
=20
-u32 bnx2x_fix_features(struct net_device *dev, u32 features);
-int bnx2x_set_features(struct net_device *dev, u32 features);
+netdev_features_t bnx2x_fix_features(struct net_device *dev,
+	netdev_features_t features);
+int bnx2x_set_features(struct net_device *dev, netdev_features_t featu=
res);
=20
 /**
  * bnx2x_tx_timeout - tx timeout netdev callback
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 07e866d..f99c8b2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1375,11 +1375,12 @@ static int bond_sethwaddr(struct net_device *bo=
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
@@ -1413,7 +1414,7 @@ static void bond_compute_features(struct bonding =
*bond)
 {
 	struct slave *slave;
 	struct net_device *bond_dev =3D bond->dev;
-	u32 vlan_features =3D BOND_VLAN_FEATURES;
+	netdev_features_t vlan_features =3D BOND_VLAN_FEATURES;
 	unsigned short max_hard_header_len =3D ETH_HLEN;
 	int i;
=20
@@ -1951,7 +1952,7 @@ int bond_release(struct net_device *bond_dev, str=
uct net_device *slave_dev)
 	struct bonding *bond =3D netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
-	u32 old_features =3D bond_dev->features;
+	netdev_features_t old_features =3D bond_dev->features;
=20
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_m=
ain.c
index c9957b7..255f9f0 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1854,10 +1854,10 @@ static int set_wol(struct net_device *dev, stru=
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
@@ -3536,7 +3536,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 {
 	int func, i, err;
 	struct port_info *pi;
-	unsigned int highdma =3D 0;
+	bool highdma =3D false;
 	struct adapter *adapter =3D NULL;
=20
 	printk_once(KERN_INFO "%s - version %s\n", DRV_DESC, DRV_VERSION);
@@ -3562,7 +3562,7 @@ static int __devinit init_one(struct pci_dev *pde=
v,
 	}
=20
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		highdma =3D NETIF_F_HIGHDMA;
+		highdma =3D true;
 		err =3D pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err) {
 			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for "
@@ -3636,7 +3636,9 @@ static int __devinit init_one(struct pci_dev *pde=
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
 		netdev->netdev_ops =3D &cxgb4_netdev_ops;
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 8ef31dc..45bcefc 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -469,7 +469,8 @@ static int dm9000_nway_reset(struct net_device *dev=
)
 	return mii_nway_restart(&dm->mii);
 }
=20
-static int dm9000_set_features(struct net_device *dev, u32 features)
+static int dm9000_set_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	board_info_t *dm =3D to_dm9000_board(dev);
 	u32 changed =3D dev->features ^ features;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 188d99a..fab2ef6 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -797,10 +797,11 @@ static int e1000_is_need_ioport(struct pci_dev *p=
dev)
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
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 537b695..c542766 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4475,7 +4475,8 @@ static int nv_set_pauseparam(struct net_device *d=
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
@@ -4484,11 +4485,11 @@ static u32 nv_fix_features(struct net_device *d=
ev, u32 features)
 	return features;
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
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index fc86f51..3b980a2 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -1153,7 +1153,7 @@ extern void gfar_phy_test(struct mii_bus *bus, st=
ruct phy_device *phydev,
 extern void gfar_configure_coalescing(struct gfar_private *priv,
 		unsigned long tx_mask, unsigned long rx_mask);
 void gfar_init_sysfs(struct net_device *dev);
-int gfar_set_features(struct net_device *dev, u32 features);
+int gfar_set_features(struct net_device *dev, netdev_features_t featur=
es);
=20
 extern const struct ethtool_ops gfar_ethtool_ops;
=20
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtoo=
l.c
index 92d7ac0..4176b90 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -517,12 +517,12 @@ static int gfar_sringparam(struct net_device *dev=
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
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 838c5b6..06514bc 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -730,7 +730,8 @@ static void netdev_get_drvinfo(struct net_device *d=
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
@@ -824,7 +825,8 @@ static int ibmveth_set_csum_offload(struct net_devi=
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
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgb=
e_ethtool.c
index 38ee164..438c5b8 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2188,7 +2188,8 @@ static int ixgbe_set_coalesce(struct net_device *=
netdev,
 	return 0;
 }
=20
-u32 ixgbe_fix_features(struct net_device *netdev, u32 features)
+netdev_features_t ixgbe_fix_features(struct net_device *netdev,
+	netdev_features_t features)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
=20
@@ -2211,10 +2212,10 @@ u32 ixgbe_fix_features(struct net_device *netde=
v, u32 features)
 	return features;
 }
=20
-int ixgbe_set_features(struct net_device *netdev, u32 features)
+int ixgbe_set_features(struct net_device *netdev, netdev_features_t fe=
atures)
 {
 	struct ixgbe_adapter *adapter =3D netdev_priv(netdev);
-	u32 changed =3D netdev->features ^ features;
+	netdev_features_t changed =3D netdev->features ^ features;
 	bool need_reset =3D !!(changed & NETIF_F_HW_VLAN_RX);
=20
 	if (features & NETIF_F_RXCSUM)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_m=
ain.c
index 1a77310..c720710 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7199,8 +7199,9 @@ static struct rtnl_link_stats64 *ixgbe_get_stats6=
4(struct net_device *netdev,
 	return stats;
 }
=20
-u32 ixgbe_fix_features(struct net_device *netdev, u32 features);
-int ixgbe_set_features(struct net_device *netdev, u32 features);
+netdev_features_t ixgbe_fix_features(struct net_device *netdev,
+	netdev_features_t features);
+int ixgbe_set_features(struct net_device *netdev, netdev_features_t fe=
atures);
=20
 static const struct net_device_ops ixgbe_netdev_ops =3D {
 	.ndo_open		=3D ixgbe_open,
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index b5b174a..44f230a 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1917,7 +1917,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk=
_buff *skb, int idx)
 	struct jme_ring *txring =3D &(jme->txring[0]);
 	struct txdesc *txdesc =3D txring->desc, *ctxdesc;
 	struct jme_buffer_info *txbi =3D txring->bufinf, *ctxbi;
-	u8 hidma =3D jme->dev->features & NETIF_F_HIGHDMA;
+	u8 hidma =3D !!(jme->dev->features & NETIF_F_HIGHDMA);
 	int i, nr_frags =3D skb_shinfo(skb)->nr_frags;
 	int mask =3D jme->tx_ring_mask;
 	struct skb_frag_struct *frag;
@@ -2632,8 +2632,8 @@ jme_set_msglevel(struct net_device *netdev, u32 v=
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
@@ -2641,7 +2641,7 @@ jme_fix_features(struct net_device *netdev, u32 f=
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
diff --git a/drivers/net/ksz884x.c b/drivers/net/ksz884x.c
index 2ac6c6c..9e2f8c9 100644
--- a/drivers/net/ksz884x.c
+++ b/drivers/net/ksz884x.c
@@ -6590,7 +6590,8 @@ static void netdev_get_ethtool_stats(struct net_d=
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
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a5d9b1c..39ba830 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1577,7 +1577,7 @@ mv643xx_eth_set_ringparam(struct net_device *dev,=
 struct ethtool_ringparam *er)
=20
=20
 static int
-mv643xx_eth_set_features(struct net_device *dev, u32 features)
+mv643xx_eth_set_features(struct net_device *dev, netdev_features_t fea=
tures)
 {
 	struct mv643xx_eth_private *mp =3D netdev_priv(dev);
 	u32 rx_csum =3D features & NETIF_F_RXCSUM;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myr=
i10ge.c
index 04e10f4..6d0be83 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1489,7 +1489,7 @@ myri10ge_clean_rx_done(struct myri10ge_slice_stat=
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
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index 684cace..75c4405 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -486,7 +486,8 @@ static void netxen_set_multicast_list(struct net_de=
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
@@ -497,7 +498,8 @@ static u32 netxen_fix_features(struct net_device *d=
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
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/p=
ch_gbe_main.c
index eac3c5c..3684281 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -2040,10 +2040,11 @@ static int pch_gbe_change_mtu(struct net_device=
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
diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 480ef5c..49ed30d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1420,8 +1420,9 @@ void qlcnic_advert_link_change(struct qlcnic_adap=
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
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic=
_hw.c
index e965661..d0cc78e 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -760,12 +760,13 @@ int qlcnic_change_mtu(struct net_device *netdev, =
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
@@ -776,10 +777,10 @@ u32 qlcnic_fix_features(struct net_device *netdev=
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
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcn=
ic_main.c
index 3ab7d2c..979bca3 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -781,7 +781,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *a=
dapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	struct net_device *netdev =3D adapter->netdev;
-	unsigned long features, vlan_features;
+	netdev_features_t features, vlan_features;
=20
 	features =3D (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bc5bb37..78184ac 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1384,7 +1384,8 @@ static int rtl8169_set_settings(struct net_device=
 *dev, struct ethtool_cmd *cmd)
 	return ret;
 }
=20
-static u32 rtl8169_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t rtl8169_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	if (dev->mtu > TD_MSS_MAX)
 		features &=3D ~NETIF_F_ALL_TSO;
@@ -1392,7 +1393,8 @@ static u32 rtl8169_fix_features(struct net_device=
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
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index df0d2c8..698fbfa 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -6670,10 +6670,10 @@ static void s2io_ethtool_get_strings(struct net=
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
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c914729..ca869c0 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1883,7 +1883,7 @@ static void efx_set_multicast_list(struct net_dev=
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
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d252cb1..6068f49 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4168,7 +4168,8 @@ static int sky2_set_eeprom(struct net_device *dev=
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
@@ -4182,7 +4183,7 @@ static u32 sky2_fix_features(struct net_device *d=
ev, u32 features)
 	return features;
 }
=20
-static int sky2_set_features(struct net_device *dev, u32 features)
+static int sky2_set_features(struct net_device *dev, netdev_features_t=
 features)
 {
 	struct sky2_port *sky2 =3D netdev_priv(dev);
 	u32 changed =3D dev->features ^ features;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 97cd02d..67692b5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6186,7 +6186,8 @@ static void tg3_set_loopback(struct net_device *d=
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
@@ -6196,9 +6197,9 @@ static u32 tg3_fix_features(struct net_device *de=
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
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 15b3d68..f59b51f 100644
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
index f74f3ce..071a5cf 100644
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
index bba7c15..704c527 100644
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
 	if (changed & (NETIF_F_RXCSUM|NETIF_F_LRO)) {
 		if (features & NETIF_F_RXCSUM)
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vm=
xnet3_int.h
index 0e567c24..35e2b9b 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -399,7 +399,7 @@ void
 vmxnet3_rq_destroy_all(struct vmxnet3_adapter *adapter);
=20
 int
-vmxnet3_set_features(struct net_device *netdev, u32 features);
+vmxnet3_set_features(struct net_device *netdev, netdev_features_t feat=
ures);
=20
 int
 vmxnet3_create_queues(struct vmxnet3_adapter *adapter,
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.=
c
index e658edd..7d3040c 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -2662,9 +2662,10 @@ static void vxge_poll_vp_lockup(unsigned long da=
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
@@ -2676,10 +2677,10 @@ static u32 vxge_fix_features(struct net_device =
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
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d29365a..bfb5cf9 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -193,7 +193,7 @@ static void xennet_sysfs_delif(struct net_device *n=
etdev);
=20
 static int xennet_can_sg(struct net_device *dev)
 {
-	return dev->features & NETIF_F_SG;
+	return !!(dev->features & NETIF_F_SG);
 }
=20
=20
@@ -1140,7 +1140,8 @@ static void xennet_uninit(struct net_device *dev)
 	gnttab_free_grant_references(np->gref_rx_head);
 }
=20
-static u32 xennet_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t xennet_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct netfront_info *np =3D netdev_priv(dev);
 	int val;
@@ -1166,7 +1167,8 @@ static u32 xennet_fix_features(struct net_device =
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
index fd69da3..3225a4d 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3148,7 +3148,8 @@ static int qeth_l3_stop(struct net_device *dev)
 	return 0;
 }
=20
-static u32 qeth_l3_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t qeth_l3_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct qeth_card *card =3D dev->ml_priv;
=20
@@ -3162,7 +3163,8 @@ static u32 qeth_l3_fix_features(struct net_device=
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
new file mode 100644
index 0000000..d36bdcd
--- /dev/null
+++ b/include/linux/netdev_features.h
@@ -0,0 +1,98 @@
+/*
+ * Network device features.
+ *
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#ifndef _LINUX_NETDEV_FEATURES_H
+#define _LINUX_NETDEV_FEATURES_H
+
+#include <linux/types.h>
+
+typedef u32 netdev_features_t;
+
+#define NETIF_F_SG		1	/* Scatter/gather IO. */
+#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
+#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack.=
 */
+#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
+#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
+#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
+#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
+#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
+#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
+#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
+#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN pack=
ets */
+#define NETIF_F_GSO		2048	/* Enable software GSO. */
+#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
+					/* do not use LLTX in new drivers */
+#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces=
 */
+#define NETIF_F_GRO		16384	/* Generic receive offload */
+#define NETIF_F_LRO		32768	/* large receive offload */
+
+/* the GSO_MASK reserves bits 16 through 23 */
+#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
+#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
+#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 byte=
s*/
+#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
+#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
+#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
+#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
+#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
+
+	/* Segmentation offload features */
+#define NETIF_F_GSO_SHIFT	16
+#define NETIF_F_GSO_MASK	0x00ff0000
+#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
+#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
+
+	/* Features valid for ethtool to change */
+	/* =3D all defined minus driver/device-class-related */
+#define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
+				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
+#define NETIF_F_ETHTOOL_BITS	(0xff3fffff & ~NETIF_F_NEVER_CHANGE)
+
+	/* List of features with software fallbacks. */
+#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
+				 NETIF_F_TSO6 | NETIF_F_UFO)
+
+
+#define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
+#define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
+#define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
+#define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
+
+#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN=
)
+
+#define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
+				 NETIF_F_FSO)
+
+#define NETIF_F_ALL_TX_OFFLOADS	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
+				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
+				 NETIF_F_HIGHDMA | \
+				 NETIF_F_SCTP_CSUM | \
+				 NETIF_F_ALL_FCOE)
+
+	/*
+	 * If one device supports one of these features, then enable them
+	 * for all in netdev_increment_features.
+	 */
+#define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST=
 | \
+				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
+				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
+	/*
+	 * If one device doesn't support one of these features, then disable =
it
+	 * for all in netdev_increment_features.
+	 */
+#define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
+
+	/* changeable features with no special hardware requirements */
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+
+#endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3482ee9..5e0e086 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -52,6 +52,8 @@
 #include <net/dcbnl.h>
 #endif
=20
+#include <linux/netdev_features.h>
+
 struct vlan_group;
 struct netpoll_info;
 struct phy_device;
@@ -877,12 +879,12 @@ struct netdev_tc_txq {
  *	Called to release previously enslaved netdev.
  *
  *      Feature/offload setting functions.
- * u32 (*ndo_fix_features)(struct net_device *dev, u32 features);
+ * netdev_features_t (*ndo_fix_features)(struct net_device *dev, netde=
v_features_t features);
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
@@ -974,10 +976,10 @@ struct net_device_ops {
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
@@ -1027,97 +1029,13 @@ struct net_device {
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
-
-	/* Net device feature bits; if you change something,
-	 * also update netdev_features_strings[] in ethtool.c */
-
-#define NETIF_F_SG		1	/* Scatter/gather IO. */
-#define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
-#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack.=
 */
-#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
-#define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
-#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
-#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
-#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
-#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN pack=
ets */
-#define NETIF_F_GSO		2048	/* Enable software GSO. */
-#define NETIF_F_LLTX		4096	/* LockLess TX - deprecated. Please */
-					/* do not use LLTX in new drivers */
-#define NETIF_F_NETNS_LOCAL	8192	/* Does not change network namespaces=
 */
-#define NETIF_F_GRO		16384	/* Generic receive offload */
-#define NETIF_F_LRO		32768	/* large receive offload */
-
-/* the GSO_MASK reserves bits 16 through 23 */
-#define NETIF_F_FCOE_CRC	(1 << 24) /* FCoE CRC32 */
-#define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
-#define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 byte=
s*/
-#define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
-#define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
-#define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
-#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
-#define NETIF_F_LOOPBACK	(1 << 31) /* Enable loopback */
-
-	/* Segmentation offload features */
-#define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_GSO_MASK	0x00ff0000
-#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
-#define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
-#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
-#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
-
-	/* Features valid for ethtool to change */
-	/* =3D all defined minus driver/device-class-related */
-#define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
-				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
-#define NETIF_F_ETHTOOL_BITS	(0xff3fffff & ~NETIF_F_NEVER_CHANGE)
-
-	/* List of features with software fallbacks. */
-#define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
-				 NETIF_F_TSO6 | NETIF_F_UFO)
-
-
-#define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
-#define NETIF_F_V4_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IP_CSUM)
-#define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
-#define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
-
-#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN=
)
-
-#define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
-				 NETIF_F_FSO)
-
-#define NETIF_F_ALL_TX_OFFLOADS	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
-				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
-				 NETIF_F_HIGHDMA | \
-				 NETIF_F_SCTP_CSUM | \
-				 NETIF_F_ALL_FCOE)
-
-	/*
-	 * If one device supports one of these features, then enable them
-	 * for all in netdev_increment_features.
-	 */
-#define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST=
 | \
-				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
-				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
-	/*
-	 * If one device doesn't support one of these features, then disable =
it
-	 * for all in netdev_increment_features.
-	 */
-#define NETIF_F_ALL_FOR_ALL	(NETIF_F_NOCACHE_COPY | NETIF_F_FSO)
-
-	/* changeable features with no special hardware requirements */
-#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+	netdev_features_t	vlan_features;
=20
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
@@ -1551,7 +1469,7 @@ struct packet_type {
 					 struct packet_type *,
 					 struct net_device *);
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
-						u32 features);
+						netdev_features_t features);
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 					       struct sk_buff *skb);
@@ -2528,7 +2446,7 @@ extern int		netdev_set_master(struct net_device *=
dev, struct net_device *master)
 extern int netdev_set_bond_master(struct net_device *dev,
 				  struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb);
-extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 featur=
es);
+extern struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_fea=
tures_t features);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
@@ -2555,12 +2473,12 @@ extern char *netdev_drivername(const struct net=
_device *dev, char *buffer, int l
=20
 extern void linkwatch_run_queue(void);
=20
-static inline u32 netdev_get_wanted_features(struct net_device *dev)
+static inline netdev_features_t netdev_get_wanted_features(struct net_=
device *dev)
 {
 	return (dev->features & ~dev->hw_features) | dev->wanted_features;
 }
-u32 netdev_increment_features(u32 all, u32 one, u32 mask);
-u32 netdev_fix_features(struct net_device *dev, u32 features);
+netdev_features_t netdev_increment_features(netdev_features_t all,
+	netdev_features_t one, netdev_features_t mask);
 int __netdev_update_features(struct net_device *dev);
 void netdev_update_features(struct net_device *dev);
 void netdev_change_features(struct net_device *dev);
@@ -2568,21 +2486,22 @@ void netdev_change_features(struct net_device *=
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
index f3af147..6aec265 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -29,6 +29,7 @@
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
 #include <linux/hrtimer.h>
+#include <linux/netdev_features.h>
=20
 /* Don't change this without changing skb_csum_unnecessary! */
 #define CHECKSUM_NONE 0
@@ -1880,7 +1881,8 @@ extern void	       skb_split(struct sk_buff *skb,
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
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 149a415..0c49be2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1403,7 +1403,8 @@ extern struct request_sock_ops tcp6_request_sock_=
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
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 774bd22..e47c1c8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -585,7 +585,8 @@ static void vlan_dev_uninit(struct net_device *dev)
 	}
 }
=20
-static u32 vlan_dev_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
=20
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1bacca4..c4908b7 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -292,10 +292,11 @@ int br_min_mtu(const struct net_bridge *br)
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
diff --git a/net/core/dev.c b/net/core/dev.c
index 3041b6ae..a5a0e76 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1842,7 +1842,7 @@ EXPORT_SYMBOL(skb_checksum_help);
  *	It may return NULL if the skb requires no segmentation.  This is
  *	only possible when GSO is used for verifying header integrity.
  */
-struct sk_buff *skb_gso_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t=
 features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_type *ptype;
@@ -1872,8 +1872,8 @@ struct sk_buff *skb_gso_segment(struct sk_buff *s=
kb, u32 features)
 		if (dev && dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
 			dev->ethtool_ops->get_drvinfo(dev, &info);
=20
-		WARN(1, "%s: caps=3D(0x%lx, 0x%lx) len=3D%d data_len=3D%d ip_summed=3D=
%d\n",
-		     info.driver, dev ? dev->features : 0L,
+		WARN(1, "%s: caps=3D(0x%llx, 0x%lx) len=3D%d data_len=3D%d ip_summed=
=3D%d\n",
+		     info.driver, dev ? (long long)dev->features : 0LL,
 		     skb->sk ? skb->sk->sk_route_caps : 0L,
 		     skb->len, skb->data_len, skb->ip_summed);
=20
@@ -1980,7 +1980,7 @@ static void dev_gso_skb_destructor(struct sk_buff=
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
@@ -2019,7 +2019,7 @@ static inline void skb_orphan_try(struct sk_buff =
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
@@ -2030,7 +2030,8 @@ static bool can_checksum_protocol(unsigned long f=
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
@@ -2042,10 +2043,10 @@ static u32 harmonize_features(struct sk_buff *s=
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
@@ -2091,7 +2092,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, stru=
ct net_device *dev,
 	unsigned int skb_len;
=20
 	if (likely(!skb->next)) {
-		u32 features;
+		netdev_features_t features;
=20
 		/*
 		 * If device doesn't need skb->dst, release it right now while
@@ -5191,7 +5192,8 @@ static void rollback_registered(struct net_device=
 *dev)
 	list_del(&single);
 }
=20
-u32 netdev_fix_features(struct net_device *dev, u32 features)
+static netdev_features_t netdev_fix_features(struct net_device *dev,
+	netdev_features_t features)
 {
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
@@ -5250,11 +5252,10 @@ u32 netdev_fix_features(struct net_device *dev,=
 u32 features)
=20
 	return features;
 }
-EXPORT_SYMBOL(netdev_fix_features);
=20
 int __netdev_update_features(struct net_device *dev)
 {
-	u32 features;
+	netdev_features_t features;
 	int err =3D 0;
=20
 	ASSERT_RTNL();
@@ -5270,8 +5271,10 @@ int __netdev_update_features(struct net_device *=
dev)
 	if (dev->features =3D=3D features)
 		return 0;
=20
+	BUILD_BUG_ON(sizeof(features) !=3D sizeof(u32));	/* XXX: need: %Fx */
+
 	netdev_dbg(dev, "Features changed: 0x%08x -> 0x%08x\n",
-		dev->features, features);
+		(u32)dev->features, (u32)features);
=20
 	if (dev->netdev_ops->ndo_set_features)
 		err =3D dev->netdev_ops->ndo_set_features(dev, features);
@@ -5279,7 +5282,7 @@ int __netdev_update_features(struct net_device *d=
ev)
 	if (unlikely(err < 0)) {
 		netdev_err(dev,
 			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
-			err, features, dev->features);
+			err, (u32)features, (u32)dev->features);
 		return -1;
 	}
=20
@@ -6193,7 +6196,8 @@ static int dev_cpu_callback(struct notifier_block=
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
index 9214e54..17f5f96 100644
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
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 11b98bc..af35d90 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -100,7 +100,7 @@ NETDEVICE_SHOW(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW(addr_len, fmt_dec);
 NETDEVICE_SHOW(iflink, fmt_dec);
 NETDEVICE_SHOW(ifindex, fmt_dec);
-NETDEVICE_SHOW(features, fmt_hex);
+NETDEVICE_SHOW(features, fmt_hex);	/* XXX: need %Fx */
 NETDEVICE_SHOW(type, fmt_dec);
 NETDEVICE_SHOW(link_mode, fmt_dec);
=20
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 46cbd28..76edd5b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2495,7 +2495,7 @@ EXPORT_SYMBOL_GPL(skb_pull_rcsum);
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
index 83673d2..7c9a33f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1242,7 +1242,8 @@ out:
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
index 054a59d..ff9104f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2654,7 +2654,7 @@ int compat_tcp_getsockopt(struct sock *sk, int le=
vel, int optname,
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
=20
-struct sk_buff *tcp_tso_segment(struct sk_buff *skb, u32 features)
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb, netdev_features_t=
 features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	struct tcphdr *th;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index abca870..2842993 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2244,7 +2244,8 @@ int udp4_ufo_send_check(struct sk_buff *skb)
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
index b7919f9..34088f7 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -765,7 +765,8 @@ out:
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
index 41f8c9c..1df53db 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1295,7 +1295,7 @@ static int udp6_ufo_send_check(struct sk_buff *sk=
b)
 	return 0;
 }
=20
-static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, u32 feat=
ures)
+static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb, netdev_f=
eatures_t features)
 {
 	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
 	unsigned int mss;
--=20
1.7.2.5

