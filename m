From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 24/24] net, diet: Convert all drivers to use SET_ETHTOOL_OPS
Date: Mon,  5 May 2014 15:26:13 -0700
Message-ID: <1399328773-6531-25-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58945 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933174AbaEEW01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 18:26:27 -0400
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

Convert all drivers to use SET_ETHTOOL_OPS. This allows
the compiler to throw the code away when CONFIG_ETHTOOL
is disabled, saving text size

This is a purely mechanic patch, done with the following
coccinelle script (also available in
scripts/coccinelle/api/ethtool_ops.cocci)

// Convert network drivers to use the SET_ETHTOOL_OPS macro
// This allows to compile out the ethtool code when not needed.
//
@@
struct ethtool_ops *ops;
struct net_device *dev;
@@
-	dev->ethtool_ops = ops;
+	SET_ETHTOOL_OPS(dev, ops);

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 arch/um/drivers/net_kern.c                            | 2 +-
 drivers/firewire/net.c                                | 2 +-
 drivers/infiniband/hw/nes/nes_nic.c                   | 2 +-
 drivers/net/bonding/bond_main.c                       | 2 +-
 drivers/net/cris/eth_v10.c                            | 2 +-
 drivers/net/ethernet/3com/3c515.c                     | 2 +-
 drivers/net/ethernet/3com/3c59x.c                     | 2 +-
 drivers/net/ethernet/8390/ax88796.c                   | 2 +-
 drivers/net/ethernet/8390/etherh.c                    | 2 +-
 drivers/net/ethernet/8390/ne2k-pci.c                  | 2 +-
 drivers/net/ethernet/adi/bfin_mac.c                   | 2 +-
 drivers/net/ethernet/aeroflex/greth.c                 | 2 +-
 drivers/net/ethernet/allwinner/sun4i-emac.c           | 2 +-
 drivers/net/ethernet/amd/pcnet32.c                    | 2 +-
 drivers/net/ethernet/amd/sunlance.c                   | 2 +-
 drivers/net/ethernet/apple/bmac.c                     | 2 +-
 drivers/net/ethernet/arc/emac_main.c                  | 2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c              | 2 +-
 drivers/net/ethernet/broadcom/bnx2.c                  | 2 +-
 drivers/net/ethernet/broadcom/tg3.c                   | 2 +-
 drivers/net/ethernet/cadence/at91_ether.c             | 2 +-
 drivers/net/ethernet/cirrus/ep93xx_eth.c              | 2 +-
 drivers/net/ethernet/davicom/dm9000.c                 | 2 +-
 drivers/net/ethernet/dec/tulip/de2104x.c              | 2 +-
 drivers/net/ethernet/dec/tulip/dmfe.c                 | 2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c              | 2 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c          | 2 +-
 drivers/net/ethernet/dnet.c                           | 2 +-
 drivers/net/ethernet/ethoc.c                          | 2 +-
 drivers/net/ethernet/fealnx.c                         | 2 +-
 drivers/net/ethernet/freescale/fec_main.c             | 2 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c          | 2 +-
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 2 +-
 drivers/net/ethernet/freescale/gianfar.c              | 2 +-
 drivers/net/ethernet/ibm/ibmveth.c                    | 2 +-
 drivers/net/ethernet/jme.c                            | 2 +-
 drivers/net/ethernet/korina.c                         | 2 +-
 drivers/net/ethernet/lantiq_etop.c                    | 2 +-
 drivers/net/ethernet/marvell/skge.c                   | 2 +-
 drivers/net/ethernet/micrel/ks8842.c                  | 2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c              | 2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c          | 2 +-
 drivers/net/ethernet/nxp/lpc_eth.c                    | 2 +-
 drivers/net/ethernet/octeon/octeon_mgmt.c             | 2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c              | 2 +-
 drivers/net/ethernet/rdc/r6040.c                      | 2 +-
 drivers/net/ethernet/realtek/8139cp.c                 | 2 +-
 drivers/net/ethernet/realtek/8139too.c                | 2 +-
 drivers/net/ethernet/sfc/efx.c                        | 2 ++
 drivers/net/ethernet/sgi/ioc3-eth.c                   | 2 +-
 drivers/net/ethernet/silan/sc92031.c                  | 2 +-
 drivers/net/ethernet/sis/sis900.c                     | 2 +-
 drivers/net/ethernet/smsc/epic100.c                   | 2 +-
 drivers/net/ethernet/smsc/smc911x.c                   | 2 +-
 drivers/net/ethernet/smsc/smc91x.c                    | 2 +-
 drivers/net/ethernet/smsc/smsc911x.c                  | 2 +-
 drivers/net/ethernet/smsc/smsc9420.c                  | 2 +-
 drivers/net/ethernet/sun/cassini.c                    | 2 +-
 drivers/net/ethernet/sun/niu.c                        | 2 +-
 drivers/net/ethernet/sun/sunbmac.c                    | 2 +-
 drivers/net/ethernet/sun/sungem.c                     | 2 +-
 drivers/net/ethernet/sun/sunhme.c                     | 4 ++--
 drivers/net/ethernet/sun/sunqe.c                      | 2 +-
 drivers/net/ethernet/sun/sunvnet.c                    | 2 +-
 drivers/net/ethernet/ti/cpmac.c                       | 2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c          | 2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c     | 2 +-
 drivers/net/ethernet/toshiba/spider_net.c             | 2 +-
 drivers/net/ethernet/toshiba/tc35815.c                | 2 +-
 drivers/net/ethernet/tundra/tsi108_eth.c              | 2 +-
 drivers/net/ethernet/via/via-rhine.c                  | 2 +-
 drivers/net/ethernet/via/via-velocity.c               | 2 +-
 drivers/net/ethernet/wiznet/w5100.c                   | 2 +-
 drivers/net/ethernet/wiznet/w5300.c                   | 2 +-
 drivers/net/ethernet/xilinx/ll_temac_main.c           | 2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c     | 2 +-
 drivers/net/ethernet/xircom/xirc2ps_cs.c              | 2 +-
 drivers/net/ethernet/xscale/ixp4xx_eth.c              | 2 +-
 drivers/net/loopback.c                                | 2 +-
 drivers/net/macvlan.c                                 | 2 +-
 drivers/net/nlmon.c                                   | 2 +-
 drivers/net/team/team.c                               | 2 +-
 drivers/net/tun.c                                     | 2 +-
 drivers/net/usb/mcs7830.c                             | 2 +-
 drivers/net/usb/sr9700.c                              | 2 +-
 drivers/net/usb/usbnet.c                              | 2 +-
 drivers/net/veth.c                                    | 2 +-
 drivers/net/wimax/i2400m/netdev.c                     | 2 +-
 drivers/net/wimax/i2400m/usb.c                        | 2 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c   | 2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c                | 2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c                | 2 +-
 drivers/net/wireless/libertas/main.c                  | 2 +-
 drivers/net/wireless/libertas/mesh.c                  | 2 +-
 drivers/net/wireless/mwifiex/cfg80211.c               | 2 +-
 drivers/net/wireless/prism54/islpci_dev.c             | 2 +-
 drivers/staging/bcm/Bcmnet.c                          | 2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c          | 2 +-
 drivers/staging/wlags49_h2/wl_netdev.c                | 3 +--
 net/8021q/vlan_dev.c                                  | 2 +-
 100 files changed, 102 insertions(+), 101 deletions(-)

diff --git a/arch/um/drivers/net_kern.c b/arch/um/drivers/net_kern.c
index 7d26d9c..1a8125f 100644
--- a/arch/um/drivers/net_kern.c
+++ b/arch/um/drivers/net_kern.c
@@ -477,7 +477,7 @@ static void eth_configure(int n, void *init, char *mac,
 
 	dev->mtu = transport->user->mtu;
 	dev->netdev_ops = &uml_netdev_ops;
-	dev->ethtool_ops = &uml_net_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &uml_net_ethtool_ops);
 	dev->watchdog_timeo = (HZ >> 1);
 	dev->irq = UM_ETH_IRQ;
 
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 4af0a7b..f0bc9bc 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1393,7 +1393,7 @@ static void fwnet_init_dev(struct net_device *net)
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
 	net->tx_queue_len	= FWNET_TX_QUEUE_LEN;
-	net->ethtool_ops	= &fwnet_ethtool_ops;
+	SET_ETHTOOL_OPS(net, &fwnet_ethtool_ops);
 }
 
 /* caller must hold fwnet_device_mutex */
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 49eb511..316b888 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1678,7 +1678,7 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 	netdev->addr_len = ETH_ALEN;
 	netdev->type = ARPHRD_ETHER;
 	netdev->netdev_ops = &nes_netdev_ops;
-	netdev->ethtool_ops = &nes_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &nes_ethtool_ops);
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
 	nes_debug(NES_DBG_INIT, "Enabling VLAN Insert/Delete.\n");
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 69aff72..ef89255 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3910,7 +3910,7 @@ void bond_setup(struct net_device *bond_dev)
 	/* Initialize the device entry points */
 	ether_setup(bond_dev);
 	bond_dev->netdev_ops = &bond_netdev_ops;
-	bond_dev->ethtool_ops = &bond_ethtool_ops;
+	SET_ETHTOOL_OPS(bond_dev, &bond_ethtool_ops);
 
 	bond_dev->destructor = bond_destructor;
 
diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 29e272c..fc8ca1f 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -314,7 +314,7 @@ etrax_ethernet_init(void)
 
 	/* fill in our handlers so the network layer can talk to us in the future */
 
-	dev->ethtool_ops	= &e100_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &e100_ethtool_ops);
 	dev->netdev_ops		= &e100_netdev_ops;
 
 	spin_lock_init(&np->lock);
diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index 94c656f..9fc8d80 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -698,7 +698,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	/* The 3c51x-specific entries in the device structure. */
 	dev->netdev_ops = &netdev_ops;
 	dev->watchdog_timeo = (400 * HZ) / 1000;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 
 	return register_netdev(dev);
 }
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 61477b8..eb0d3b6 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1467,7 +1467,7 @@ static int vortex_probe1(struct device *gendev, void __iomem *ioaddr, int irq,
 				(dev->features & NETIF_F_IP_CSUM) ? "en":"dis");
 	}
 
-	dev->ethtool_ops = &vortex_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &vortex_ethtool_ops);
 	dev->watchdog_timeo = (watchdog * HZ) / 1000;
 
 	if (pdev) {
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 455d4c3..5650712 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -782,7 +782,7 @@ static int ax_init_dev(struct net_device *dev)
 	ei_local->msg_enable = ax_msg_enable;
 
 	dev->netdev_ops = &ax_netdev_ops;
-	dev->ethtool_ops = &ax_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &ax_ethtool_ops);
 
 	ret = ax_mii_init(dev);
 	if (ret)
diff --git a/drivers/net/ethernet/8390/etherh.c b/drivers/net/ethernet/8390/etherh.c
index b36ee9e..c0846b8 100644
--- a/drivers/net/ethernet/8390/etherh.c
+++ b/drivers/net/ethernet/8390/etherh.c
@@ -688,7 +688,7 @@ etherh_probe(struct expansion_card *ec, const struct ecard_id *id)
 
 	dev->netdev_ops		= &etherh_netdev_ops;
 	dev->irq		= ec->irq;
-	dev->ethtool_ops	= &etherh_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &etherh_ethtool_ops);
 
 	if (data->supported & SUPPORTED_Autoneg)
 		dev->flags |= IFF_AUTOMEDIA;
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index f395c96..67c91ff 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -373,7 +373,7 @@ static int ne2k_pci_init_one(struct pci_dev *pdev,
 	ei_status.get_8390_hdr = &ne2k_pci_get_8390_hdr;
 	ei_status.priv = (unsigned long) pdev;
 
-	dev->ethtool_ops = &ne2k_pci_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &ne2k_pci_ethtool_ops);
 	NS8390_init(dev, 0);
 
 	memcpy(dev->dev_addr, SA_prom, dev->addr_len);
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 7ae74d4..826016bc 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -1683,7 +1683,7 @@ static int bfin_mac_probe(struct platform_device *pdev)
 	ether_setup(ndev);
 
 	ndev->netdev_ops = &bfin_mac_netdev_ops;
-	ndev->ethtool_ops = &bfin_mac_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &bfin_mac_ethtool_ops);
 
 	init_timer(&lp->tx_reclaim_timer);
 	lp->tx_reclaim_timer.data = (unsigned long)lp;
diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 23578df..3608b97 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -1529,7 +1529,7 @@ static int greth_of_probe(struct platform_device *ofdev)
 	}
 
 	dev->netdev_ops = &greth_netdev_ops;
-	dev->ethtool_ops = &greth_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &greth_ethtool_ops);
 
 	err = register_netdev(dev);
 	if (err) {
diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index 2846067..3a6c75a 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -879,7 +879,7 @@ static int emac_probe(struct platform_device *pdev)
 
 	ndev->netdev_ops = &emac_netdev_ops;
 	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	ndev->ethtool_ops = &emac_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &emac_ethtool_ops);
 
 	platform_set_drvdata(pdev, ndev);
 
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index e7cc917..4a9b2cf 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -1900,7 +1900,7 @@ pcnet32_probe1(unsigned long ioaddr, int shared, struct pci_dev *pdev)
 
 	/* The PCNET32-specific entries in the device structure. */
 	dev->netdev_ops = &pcnet32_netdev_ops;
-	dev->ethtool_ops = &pcnet32_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &pcnet32_ethtool_ops);
 	dev->watchdog_timeo = (5 * HZ);
 
 	/* Fill in the generic fields of the device structure. */
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 5e4273b..ac937c3 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -1450,7 +1450,7 @@ no_link_test:
 	lp->dev = dev;
 	SET_NETDEV_DEV(dev, &op->dev);
 	dev->watchdog_timeo = 5*HZ;
-	dev->ethtool_ops = &sparc_lance_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &sparc_lance_ethtool_ops);
 	dev->netdev_ops = &sparc_lance_ops;
 
 	dev->irq = op->archdata.irqs[0];
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index daae0e0..a2c6c2a 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1301,7 +1301,7 @@ static int bmac_probe(struct macio_dev *mdev, const struct of_device_id *match)
 	bmwrite(dev, INTDISABLE, DisableAll);
 
 	dev->netdev_ops = &bmac_netdev_ops;
-	dev->ethtool_ops = &bmac_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &bmac_ethtool_ops);
 
 	bmac_get_station_address(dev, addr);
 	if (bmac_verify_checksum(dev) != 0)
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index eeecc29..75956dc 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -665,7 +665,7 @@ static int arc_emac_probe(struct platform_device *pdev)
 	SET_NETDEV_DEV(ndev, &pdev->dev);
 
 	ndev->netdev_ops = &arc_emac_netdev_ops;
-	ndev->ethtool_ops = &arc_emac_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &arc_emac_ethtool_ops);
 	ndev->watchdog_timeo = TX_TIMEOUT;
 	/* FIXME :: no multicast support yet */
 	ndev->flags &= ~IFF_MULTICAST;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index dfd0e91..a50b729 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3014,7 +3014,7 @@ static int atl1_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->watchdog_timeo = 5 * HZ;
 	netif_napi_add(netdev, &adapter->napi, atl1_rings_clean, 64);
 
-	netdev->ethtool_ops = &atl1_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &atl1_ethtool_ops);
 	adapter->bd_number = cards_found;
 
 	/* setup the private structure */
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 0ab8370..9fac102 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8556,7 +8556,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev->netdev_ops = &bnx2_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	dev->ethtool_ops = &bnx2_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &bnx2_ethtool_ops);
 
 	bp = netdev_priv(dev);
 
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index e5d95c5..903710b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17590,7 +17590,7 @@ static int tg3_init_one(struct pci_dev *pdev,
 	tp->rx_pending = TG3_DEF_RX_RING_PENDING;
 	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
 
-	dev->ethtool_ops = &tg3_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &tg3_ethtool_ops);
 	dev->watchdog_timeo = TG3_TX_TIMEOUT;
 	dev->netdev_ops = &tg3_netdev_ops;
 	dev->irq = pdev->irq;
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 4a79eda..f71c2b6 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -353,7 +353,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
 
 	ether_setup(dev);
 	dev->netdev_ops = &at91ether_netdev_ops;
-	dev->ethtool_ops = &macb_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &macb_ethtool_ops);
 	platform_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 2be2a99..948e2e8 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -765,7 +765,7 @@ static struct net_device *ep93xx_dev_alloc(struct ep93xx_eth_data *data)
 
 	memcpy(dev->dev_addr, data->dev_addr, ETH_ALEN);
 
-	dev->ethtool_ops = &ep93xx_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &ep93xx_ethtool_ops);
 	dev->netdev_ops = &ep93xx_netdev_ops;
 
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 8c4b93b..73f76a8 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1602,7 +1602,7 @@ dm9000_probe(struct platform_device *pdev)
 
 	ndev->netdev_ops	= &dm9000_netdev_ops;
 	ndev->watchdog_timeo	= msecs_to_jiffies(watchdog);
-	ndev->ethtool_ops	= &dm9000_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &dm9000_ethtool_ops);
 
 	db->msg_enable       = NETIF_MSG_LINK;
 	db->mii.phy_id_mask  = 0x1f;
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 38148b0..55c80eb 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1985,7 +1985,7 @@ static int de_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev->netdev_ops = &de_netdev_ops;
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	dev->ethtool_ops = &de_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &de_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	de = netdev_priv(dev);
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 53f0c61..14bceaa 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -477,7 +477,7 @@ static int dmfe_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 	dev->netdev_ops = &netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	netif_carrier_off(dev);
 	spin_lock_init(&db->lock);
 
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index aa801a6..b54b462 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -372,7 +372,7 @@ static int uli526x_init_one(struct pci_dev *pdev,
 
 	/* Register some necessary functions */
 	dev->netdev_ops = &netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 
 	spin_lock_init(&db->lock);
 
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 62fe512..d780dc3 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -431,7 +431,7 @@ static int w840_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* The chip-specific entries in the device structure. */
 	dev->netdev_ops = &netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	i = register_netdev(dev);
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index e9b0fab..1b17b9e 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -876,7 +876,7 @@ static int dnet_probe(struct platform_device *pdev)
 
 	dev->netdev_ops = &dnet_netdev_ops;
 	netif_napi_add(dev, &bp->napi, dnet_poll, 64);
-	dev->ethtool_ops = &dnet_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &dnet_ethtool_ops);
 
 	dev->base_addr = (unsigned long)bp->regs;
 
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 8b70ca7..129a83c 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1234,7 +1234,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	netdev->netdev_ops = &ethoc_netdev_ops;
 	netdev->watchdog_timeo = ETHOC_TIMEOUT;
 	netdev->features |= 0;
-	netdev->ethtool_ops = &ethoc_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &ethoc_ethtool_ops);
 
 	/* setup NAPI */
 	netif_napi_add(netdev, &priv->napi, ethoc_poll, 64);
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 4b22a95..5cfac60 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -657,7 +657,7 @@ static int fealnx_init_one(struct pci_dev *pdev,
 	}
 
 	dev->netdev_ops = &netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	err = register_netdev(dev);
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 8d69e43..f959bad 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2019,7 +2019,7 @@ static int fec_enet_init(struct net_device *ndev)
 	/* The FEC Ethernet specific entries in the device structure */
 	ndev->watchdog_timeo = TX_TIMEOUT;
 	ndev->netdev_ops = &fec_netdev_ops;
-	ndev->ethtool_ops = &fec_enet_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &fec_enet_ethtool_ops);
 
 	writel(FEC_RX_DISABLED_IMASK, fep->hwp + FEC_IMASK);
 	netif_napi_add(ndev, &fep->napi, fec_enet_rx_napi, NAPI_POLL_WEIGHT);
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 9947765..779fe56 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -879,7 +879,7 @@ static int mpc52xx_fec_probe(struct platform_device *op)
 
 	/* Init ether ndev with what we have */
 	ndev->netdev_ops	= &mpc52xx_fec_netdev_ops;
-	ndev->ethtool_ops	= &mpc52xx_fec_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &mpc52xx_fec_ethtool_ops);
 	ndev->watchdog_timeo	= FEC_WATCHDOG_TIMEOUT;
 	ndev->base_addr		= mem.start;
 	SET_NETDEV_DEV(ndev, &op->dev);
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index dc80db4..8179097 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -1103,7 +1103,7 @@ static int fs_enet_probe(struct platform_device *ofdev)
 		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
 		               fpi->napi_weight);
 
-	ndev->ethtool_ops = &fs_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &fs_ethtool_ops);
 
 	init_timer(&fep->phy_timer_list);
 
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 9125d9a..2b5541f3 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1304,7 +1304,7 @@ static int gfar_probe(struct platform_device *ofdev)
 	dev->watchdog_timeo = TX_TIMEOUT;
 	dev->mtu = 1500;
 	dev->netdev_ops = &gfar_netdev_ops;
-	dev->ethtool_ops = &gfar_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &gfar_ethtool_ops);
 
 	/* Register for napi ...We are registering NAPI for each grp */
 	for (i = 0; i < priv->num_grps; i++) {
diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index c912756..81e3dff 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1384,7 +1384,7 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 
 	netdev->irq = dev->irq;
 	netdev->netdev_ops = &ibmveth_netdev_ops;
-	netdev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &netdev_ethtool_ops);
 	SET_NETDEV_DEV(netdev, &dev->dev);
 	netdev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index b0c6050..a1dbc6a 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3005,7 +3005,7 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_release_regions;
 	}
 	netdev->netdev_ops = &jme_netdev_ops;
-	netdev->ethtool_ops		= &jme_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &jme_ethtool_ops);
 	netdev->watchdog_timeo		= TX_TIMEOUT;
 	netdev->hw_features		=	NETIF_F_IP_CSUM |
 						NETIF_F_IPV6_CSUM |
diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index d74f5f4..b855327 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1160,7 +1160,7 @@ static int korina_probe(struct platform_device *pdev)
 	lp->dev = dev;
 
 	dev->netdev_ops = &korina_netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 	netif_napi_add(dev, &lp->napi, korina_poll, 64);
 
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index fd4b6ae..db7a814 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -741,7 +741,7 @@ ltq_etop_probe(struct platform_device *pdev)
 	}
 	strcpy(dev->name, "eth%d");
 	dev->netdev_ops = &ltq_eth_netdev_ops;
-	dev->ethtool_ops = &ltq_etop_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &ltq_etop_ethtool_ops);
 	priv = netdev_priv(dev);
 	priv->res = res;
 	priv->pdev = pdev;
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 7f81ae6..a8c3226 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3854,7 +3854,7 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 
 	SET_NETDEV_DEV(dev, &hw->pdev->dev);
 	dev->netdev_ops = &skge_netdev_ops;
-	dev->ethtool_ops = &skge_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &skge_ethtool_ops);
 	dev->watchdog_timeo = TX_WATCHDOG;
 	dev->irq = hw->pdev->irq;
 
diff --git a/drivers/net/ethernet/micrel/ks8842.c b/drivers/net/ethernet/micrel/ks8842.c
index 822616e..f3e19e9 100644
--- a/drivers/net/ethernet/micrel/ks8842.c
+++ b/drivers/net/ethernet/micrel/ks8842.c
@@ -1192,7 +1192,7 @@ static int ks8842_probe(struct platform_device *pdev)
 	spin_lock_init(&adapter->lock);
 
 	netdev->netdev_ops = &ks8842_netdev_ops;
-	netdev->ethtool_ops = &ks8842_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &ks8842_ethtool_ops);
 
 	/* Check if a mac address was given */
 	i = netdev->addr_len;
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index c83d16d..2225381 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1583,7 +1583,7 @@ static int ks8851_probe(struct platform_device *pdev)
 	spin_lock_init(&ks->statelock);
 
 	netdev->netdev_ops = &ks_netdev_ops;
-	netdev->ethtool_ops = &ks_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &ks_ethtool_ops);
 
 	/* setup mii state */
 	ks->mii.dev             = netdev;
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 79645f7..c64f33f 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -945,7 +945,7 @@ static int w90p910_ether_setup(struct net_device *dev)
 
 	ether_setup(dev);
 	dev->netdev_ops = &w90p910_ether_netdev_ops;
-	dev->ethtool_ops = &w90p910_ether_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &w90p910_ether_ethtool_ops);
 
 	dev->tx_queue_len = 16;
 	dev->dma = 0x0;
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 422d9b5..f2c2411 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -1379,7 +1379,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 
 	/* Setup driver functions */
 	ndev->netdev_ops = &lpc_netdev_ops;
-	ndev->ethtool_ops = &lpc_eth_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &lpc_eth_ethtool_ops);
 	ndev->watchdog_timeo = msecs_to_jiffies(2500);
 
 	/* Get size of DMA buffers/descriptors region */
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/octeon/octeon_mgmt.c
index 7dc3e9b..e47d8d3 100644
--- a/drivers/net/ethernet/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
@@ -1541,7 +1541,7 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
 	netdev->netdev_ops = &octeon_mgmt_ops;
-	netdev->ethtool_ops = &octeon_mgmt_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &octeon_mgmt_ethtool_ops);
 
 	mac = of_get_mac_address(pdev->dev.of_node);
 
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 9abf70d7..e92d8e5 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1812,7 +1812,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 	mac->bufsz = dev->mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
 
-	dev->ethtool_ops = &pasemi_mac_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &pasemi_mac_ethtool_ops);
 
 	if (err)
 		goto out;
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index cd045ec..96cdc6b 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1171,7 +1171,7 @@ static int r6040_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* The RDC-specific entries in the device structure. */
 	dev->netdev_ops = &r6040_netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	netif_napi_add(dev, &lp->napi, r6040_poll, 64);
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 2bc728e..5f57041 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1992,7 +1992,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev->netdev_ops = &cp_netdev_ops;
 	netif_napi_add(dev, &cp->napi, cp_rx_poll, 16);
-	dev->ethtool_ops = &cp_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &cp_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 2e5df14..bfc36b4 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -996,7 +996,7 @@ static int rtl8139_init_one(struct pci_dev *pdev,
 
 	/* The Rtl8139-specific entries in the device structure. */
 	dev->netdev_ops = &rtl8139_netdev_ops;
-	dev->ethtool_ops = &rtl8139_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &rtl8139_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 	netif_napi_add(dev, &tp->napi, rtl8139_poll, 64);
 
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 63d595f..26a6add 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2214,6 +2214,8 @@ static int efx_netdev_event(struct notifier_block *this,
 {
 	struct net_device *net_dev = netdev_notifier_info_to_dev(ptr);
 
+	/* FIXME: this is broken now with !NETDEV_OPS */
+
 	if ((net_dev->netdev_ops == &efx_farch_netdev_ops ||
 	     net_dev->netdev_ops == &efx_ef10_netdev_ops) &&
 	    event == NETDEV_CHANGENAME)
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index 7984ad0..803f129 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1325,7 +1325,7 @@ static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* The IOC3-specific entries in the device structure. */
 	dev->watchdog_timeo	= 5 * HZ;
 	dev->netdev_ops		= &ioc3_netdev_ops;
-	dev->ethtool_ops	= &ioc3_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &ioc3_ethtool_ops);
 	dev->hw_features	= NETIF_F_IP_CSUM | NETIF_F_RXCSUM;
 	dev->features		= NETIF_F_IP_CSUM;
 
diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 7daa7d4..cad6e80 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1442,7 +1442,7 @@ static int sc92031_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	dev->netdev_ops		= &sc92031_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
-	dev->ethtool_ops	= &sc92031_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &sc92031_ethtool_ops);
 
 	priv = netdev_priv(dev);
 	spin_lock_init(&priv->lock);
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 6072f09..6aa56cd 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -496,7 +496,7 @@ static int sis900_probe(struct pci_dev *pci_dev,
 	/* The SiS900-specific entries in the device structure. */
 	net_dev->netdev_ops = &sis900_netdev_ops;
 	net_dev->watchdog_timeo = TX_TIMEOUT;
-	net_dev->ethtool_ops = &sis900_ethtool_ops;
+	SET_ETHTOOL_OPS(net_dev, &sis900_ethtool_ops);
 
 	if (sis900_debug > 0)
 		sis_priv->msg_enable = sis900_debug;
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 8ae1f8a7..93395e6 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -480,7 +480,7 @@ static int epic_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* The Epic-specific entries in the device structure. */
 	dev->netdev_ops = &epic_netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 	netif_napi_add(dev, &ep->napi, epic_poll, 64);
 
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 1c44e67..1bc3e57 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -1932,7 +1932,7 @@ static int smc911x_probe(struct net_device *dev)
 
 	dev->netdev_ops = &smc911x_netdev_ops;
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
-	dev->ethtool_ops = &smc911x_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &smc911x_ethtool_ops);
 
 	INIT_WORK(&lp->phy_configure, smc911x_phy_configure);
 	lp->mii.phy_id_mask = 0x1f;
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index d1b4dca..635e3ce 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -1971,7 +1971,7 @@ static int smc_probe(struct net_device *dev, void __iomem *ioaddr,
 
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
 	dev->netdev_ops = &smc_netdev_ops;
-	dev->ethtool_ops = &smc_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &smc_ethtool_ops);
 
 	tasklet_init(&lp->tx_task, smc_hardware_send_pkt, (unsigned long)dev);
 	INIT_WORK(&lp->phy_configure, smc_phy_configure);
diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index a0fc151..3cc7b0c 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2259,7 +2259,7 @@ static int smsc911x_init(struct net_device *dev)
 	dev->flags |= IFF_MULTICAST;
 	netif_napi_add(dev, &pdata->napi, smsc911x_poll, SMSC_NAPI_WEIGHT);
 	dev->netdev_ops = &smsc911x_netdev_ops;
-	dev->ethtool_ops = &smsc911x_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &smsc911x_ethtool_ops);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index d3b967a..df0ac39 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1661,7 +1661,7 @@ smsc9420_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	smsc9420_check_mac_address(dev);
 
 	dev->netdev_ops = &smsc9420_netdev_ops;
-	dev->ethtool_ops = &smsc9420_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &smsc9420_ethtool_ops);
 
 	netif_napi_add(dev, &pd->napi, smsc9420_rx_poll, NAPI_WEIGHT);
 
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index df8d383..df9fa8c 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -5103,7 +5103,7 @@ static int cas_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		skb_queue_head_init(&cp->rx_flows[i]);
 
 	dev->netdev_ops = &cas_netdev_ops;
-	dev->ethtool_ops = &cas_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &cas_ethtool_ops);
 	dev->watchdog_timeo = CAS_TX_TIMEOUT;
 
 #ifdef USE_NAPI
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 79606f47a..a49c9e6 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9699,7 +9699,7 @@ static const struct net_device_ops niu_netdev_ops = {
 static void niu_assign_netdev_ops(struct net_device *dev)
 {
 	dev->netdev_ops = &niu_netdev_ops;
-	dev->ethtool_ops = &niu_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &niu_ethtool_ops);
 	dev->watchdog_timeo = NIU_TX_TIMEOUT;
 }
 
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 206c106..b9475ed 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -1180,7 +1180,7 @@ static int bigmac_ether_init(struct platform_device *op,
 	bp->dev = dev;
 
 	/* Set links to our BigMAC open and close routines. */
-	dev->ethtool_ops = &bigmac_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &bigmac_ethtool_ops);
 	dev->netdev_ops = &bigmac_ops;
 	dev->watchdog_timeo = 5*HZ;
 
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 102a66f..e68ab54 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2965,7 +2965,7 @@ static int gem_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev->netdev_ops = &gem_netdev_ops;
 	netif_napi_add(dev, &gp->napi, gem_poll, 64);
-	dev->ethtool_ops = &gem_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &gem_ethtool_ops);
 	dev->watchdog_timeo = 5 * HZ;
 	dev->dma = 0;
 
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 0dbf46f..9e34e31 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2767,7 +2767,7 @@ static int happy_meal_sbus_probe_one(struct platform_device *op, int is_qfe)
 	hp->dev = dev;
 	dev->netdev_ops = &hme_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
-	dev->ethtool_ops = &hme_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &hme_ethtool_ops);
 
 	/* Happy Meal can do it all... */
 	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
@@ -3082,7 +3082,7 @@ static int happy_meal_pci_probe(struct pci_dev *pdev,
 	hp->dev = dev;
 	dev->netdev_ops = &hme_netdev_ops;
 	dev->watchdog_timeo = 5*HZ;
-	dev->ethtool_ops = &hme_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &hme_ethtool_ops);
 
 	/* Happy Meal can do it all... */
 	dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index 5695ae2..82f5942 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -895,7 +895,7 @@ static int qec_ether_init(struct platform_device *op)
 	dev->watchdog_timeo = 5*HZ;
 	dev->irq = op->archdata.irqs[0];
 	dev->dma = 0;
-	dev->ethtool_ops = &qe_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &qe_ethtool_ops);
 	dev->netdev_ops = &qec_ops;
 
 	res = register_netdev(dev);
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 1c24a8f..32a5f1b 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -1043,7 +1043,7 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	vp->local_mac = *local_mac;
 
 	dev->netdev_ops = &vnet_ops;
-	dev->ethtool_ops = &vnet_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &vnet_ethtool_ops);
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
 
 	err = register_netdev(dev);
diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 73f74f3..45ff516 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -1157,7 +1157,7 @@ static int cpmac_probe(struct platform_device *pdev)
 	dev->irq = platform_get_irq_byname(pdev, "irq");
 
 	dev->netdev_ops = &cpmac_netdev_ops;
-	dev->ethtool_ops = &cpmac_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &cpmac_ethtool_ops);
 
 	netif_napi_add(dev, &priv->napi, cpmac_poll, 64);
 
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index d899d00..7d3b6d6 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1467,7 +1467,7 @@ static void gelic_ether_setup_netdev_ops(struct net_device *netdev,
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
 	/* NAPI */
 	netif_napi_add(netdev, napi, gelic_net_poll, NAPI_POLL_WEIGHT);
-	netdev->ethtool_ops = &gelic_ether_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &gelic_ether_ethtool_ops);
 	netdev->netdev_ops = &gelic_netdevice_ops;
 }
 
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index d568af1..399d1a2 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -2589,7 +2589,7 @@ static void gelic_wl_setup_netdev_ops(struct net_device *netdev)
 	BUG_ON(!wl);
 	netdev->watchdog_timeo = GELIC_NET_WATCHDOG_TIMEOUT;
 
-	netdev->ethtool_ops = &gelic_wl_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &gelic_wl_ethtool_ops);
 	netdev->netdev_ops = &gelic_wl_netdevice_ops;
 	netdev->wireless_data = &wl->wireless_data;
 	netdev->wireless_handlers = &gelic_wl_wext_handler_def;
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 0282d01..0a8fea5 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -2286,7 +2286,7 @@ spider_net_setup_netdev_ops(struct net_device *netdev)
 	netdev->netdev_ops = &spider_net_ops;
 	netdev->watchdog_timeo = SPIDER_NET_WATCHDOG_TIMEOUT;
 	/* ethtool ops */
-	netdev->ethtool_ops = &spider_net_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &spider_net_ethtool_ops);
 }
 
 /**
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index fef5573..e8889cf 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -825,7 +825,7 @@ static int tc35815_init_one(struct pci_dev *pdev,
 
 	/* Initialize the device structure. */
 	dev->netdev_ops = &tc35815_netdev_ops;
-	dev->ethtool_ops = &tc35815_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &tc35815_ethtool_ops);
 	dev->watchdog_timeo = TC35815_TX_TIMEOUT;
 	netif_napi_add(dev, &lp->napi, tc35815_poll, NAPI_WEIGHT);
 
diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index 47eeb3a..98d688c 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -1604,7 +1604,7 @@ tsi108_init_one(struct platform_device *pdev)
 	data->id = pdev->id;
 	netif_napi_add(dev, &data->napi, tsi108_poll, 64);
 	dev->netdev_ops = &tsi108_netdev_ops;
-	dev->ethtool_ops = &tsi108_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &tsi108_ethtool_ops);
 
 	/* Apparently, the Linux networking code won't use scatter-gather
 	 * if the hardware doesn't do checksums.  However, it's faster
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index f61dc2b..89aef77 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1022,7 +1022,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* The chip-specific entries in the device structure. */
 	dev->netdev_ops = &rhine_netdev_ops;
-	dev->ethtool_ops = &netdev_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	netif_napi_add(dev, &rp->napi, rhine_napipoll, 64);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index de08e86..5f633b0 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2875,7 +2875,7 @@ static int velocity_probe(struct device *dev, int irq,
 	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
 
 	netdev->netdev_ops = &velocity_netdev_ops;
-	netdev->ethtool_ops = &velocity_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &velocity_ethtool_ops);
 	netif_napi_add(netdev, &vptr->napi, velocity_poll,
 							VELOCITY_NAPI_WEIGHT);
 
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 104d46f..45a6bdb 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -710,7 +710,7 @@ static int w5100_probe(struct platform_device *pdev)
 
 	ether_setup(ndev);
 	ndev->netdev_ops = &w5100_netdev_ops;
-	ndev->ethtool_ops = &w5100_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &w5100_ethtool_ops);
 	ndev->watchdog_timeo = HZ;
 	netif_napi_add(ndev, &priv->napi, w5100_napi_poll, 16);
 
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 1f33c4c..ce37156 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -622,7 +622,7 @@ static int w5300_probe(struct platform_device *pdev)
 
 	ether_setup(ndev);
 	ndev->netdev_ops = &w5300_netdev_ops;
-	ndev->ethtool_ops = &w5300_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &w5300_ethtool_ops);
 	ndev->watchdog_timeo = HZ;
 	netif_napi_add(ndev, &priv->napi, w5300_napi_poll, 16);
 
diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index fa193c4..a53ac0c 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -1018,7 +1018,7 @@ static int temac_of_probe(struct platform_device *op)
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
 	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &temac_netdev_ops;
-	ndev->ethtool_ops = &temac_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &temac_ethtool_ops);
 #if 0
 	ndev->features |= NETIF_F_IP_CSUM; /* Can checksum TCP/UDP over IPv4. */
 	ndev->features |= NETIF_F_HW_CSUM; /* Can checksum all the packets. */
diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
index 7b0a735..7b6b6636 100644
--- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
+++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
@@ -1492,7 +1492,7 @@ static int axienet_of_probe(struct platform_device *op)
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
 	ndev->features = NETIF_F_SG;
 	ndev->netdev_ops = &axienet_netdev_ops;
-	ndev->ethtool_ops = &axienet_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &axienet_ethtool_ops);
 
 	lp = netdev_priv(ndev);
 	lp->ndev = ndev;
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index 7c81ffb..31d6516 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -493,7 +493,7 @@ xirc2ps_probe(struct pcmcia_device *link)
 
     /* Fill in card specific entries */
     dev->netdev_ops = &netdev_ops;
-    dev->ethtool_ops = &netdev_ethtool_ops;
+    SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
     dev->watchdog_timeo = TX_TIMEOUT;
     INIT_WORK(&local->tx_timeout_task, xirc2ps_tx_timeout_task);
 
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index f7e0f0f..b854b79 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1436,7 +1436,7 @@ static int eth_init_one(struct platform_device *pdev)
 	}
 
 	dev->netdev_ops = &ixp4xx_netdev_ops;
-	dev->ethtool_ops = &ixp4xx_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &ixp4xx_ethtool_ops);
 	dev->tx_queue_len = 100;
 
 	netif_napi_add(dev, &port->napi, eth_poll, NAPI_WEIGHT);
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index bb96409..604fa6f 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -182,7 +182,7 @@ static void loopback_setup(struct net_device *dev)
 		| NETIF_F_NETNS_LOCAL
 		| NETIF_F_VLAN_CHALLENGED
 		| NETIF_F_LOOPBACK;
-	dev->ethtool_ops	= &loopback_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &loopback_ethtool_ops);
 	dev->header_ops		= &eth_header_ops;
 	dev->netdev_ops		= &loopback_ops;
 	dev->destructor		= loopback_dev_free;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 753a8c2..91eabd4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -735,7 +735,7 @@ void macvlan_common_setup(struct net_device *dev)
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops;
-	dev->ethtool_ops	= &macvlan_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &macvlan_ethtool_ops);
 }
 EXPORT_SYMBOL_GPL(macvlan_common_setup);
 
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
index 34924df..abeca48 100644
--- a/drivers/net/nlmon.c
+++ b/drivers/net/nlmon.c
@@ -133,7 +133,7 @@ static void nlmon_setup(struct net_device *dev)
 	dev->tx_queue_len = 0;
 
 	dev->netdev_ops	= &nlmon_ops;
-	dev->ethtool_ops = &nlmon_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &nlmon_ethtool_ops);
 	dev->destructor	= free_netdev;
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST |
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 33008c1..d1ad7cf 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2011,7 +2011,7 @@ static void team_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->netdev_ops = &team_netdev_ops;
-	dev->ethtool_ops = &team_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &team_ethtool_ops);
 	dev->destructor	= team_destructor;
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MULTICAST;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ee328ba..c2529b5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1418,7 +1418,7 @@ static void tun_setup(struct net_device *dev)
 	tun->owner = INVALID_UID;
 	tun->group = INVALID_GID;
 
-	dev->ethtool_ops = &tun_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &tun_ethtool_ops);
 	dev->destructor = tun_free_netdev;
 }
 
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 82d844a..0f79443 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -503,7 +503,7 @@ static int mcs7830_bind(struct usbnet *dev, struct usb_interface *udev)
 	if (ret)
 		goto out;
 
-	net->ethtool_ops = &mcs7830_ethtool_ops;
+	SET_ETHTOOL_OPS(net, &mcs7830_ethtool_ops);
 	net->netdev_ops = &mcs7830_netdev_ops;
 
 	/* reserve space for the status byte on rx */
diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
index 99b69af..4789e1a 100644
--- a/drivers/net/usb/sr9700.c
+++ b/drivers/net/usb/sr9700.c
@@ -327,7 +327,7 @@ static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
 	netdev = dev->net;
 
 	netdev->netdev_ops = &sr9700_netdev_ops;
-	netdev->ethtool_ops = &sr9700_ethtool_ops;
+	SET_ETHTOOL_OPS(netdev, &sr9700_ethtool_ops);
 	netdev->hard_header_len += SR_TX_OVERHEAD;
 	dev->hard_mtu = netdev->mtu + netdev->hard_header_len;
 	/* bulkin buffer is preferably not less than 3K */
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index f9e96c4..3bea2c0 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1616,7 +1616,7 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 
 	net->netdev_ops = &usbnet_netdev_ops;
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
-	net->ethtool_ops = &usbnet_ethtool_ops;
+	SET_ETHTOOL_OPS(net, &usbnet_ethtool_ops);
 
 	// allow device-specific bind/init procedures
 	// NOTE net->name still not usable ...
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index b4a10bc..77fe496 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -274,7 +274,7 @@ static void veth_setup(struct net_device *dev)
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
 	dev->netdev_ops = &veth_netdev_ops;
-	dev->ethtool_ops = &veth_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &veth_ethtool_ops);
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= VETH_FEATURES;
 	dev->vlan_features = dev->features &
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index a9970f1..50f25f0 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -631,7 +631,7 @@ void i2400m_netdev_setup(struct net_device *net_dev)
 		   & ~IFF_MULTICAST);
 	net_dev->watchdog_timeo = I2400M_TX_TIMEOUT;
 	net_dev->netdev_ops = &i2400m_netdev_ops;
-	net_dev->ethtool_ops = &i2400m_ethtool_ops;
+	SET_ETHTOOL_OPS(net_dev, &i2400m_ethtool_ops);
 	d_fnend(3, NULL, "(net_dev %p) = void\n", net_dev);
 }
 EXPORT_SYMBOL_GPL(i2400m_netdev_setup);
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index cd15a93..fe1b6f3 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -364,7 +364,7 @@ void i2400mu_netdev_setup(struct net_device *net_dev)
 	struct i2400mu *i2400mu = container_of(i2400m, struct i2400mu, i2400m);
 	i2400mu_init(i2400mu);
 	i2400m_netdev_setup(net_dev);
-	net_dev->ethtool_ops = &i2400mu_ethtool_ops;
+	SET_ETHTOOL_OPS(net_dev, &i2400mu_ethtool_ops);
 }
 
 
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
index 7d28cd3..d04ad4e 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -680,7 +680,7 @@ int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked)
 	ndev->netdev_ops = &brcmf_netdev_ops_pri;
 
 	ndev->hard_header_len += drvr->hdrlen;
-	ndev->ethtool_ops = &brcmf_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &brcmf_ethtool_ops);
 
 	drvr->rxsz = ndev->mtu + ndev->hard_header_len +
 			      drvr->hdrlen;
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index dfc6dfc..4a7e1e9 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6069,7 +6069,7 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 	priv->ieee->worst_rssi = -85;
 
 	dev->netdev_ops = &ipw2100_netdev_ops;
-	dev->ethtool_ops = &ipw2100_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &ipw2100_ethtool_ops);
 	dev->wireless_handlers = &ipw2100_wx_handler_def;
 	priv->wireless_data.libipw = priv->ieee;
 	dev->wireless_data = &priv->wireless_data;
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index c5aa404..661d3cc 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11823,7 +11823,7 @@ static int ipw_pci_probe(struct pci_dev *pdev,
 	priv->wireless_data.spy_data = &priv->ieee->spy_data;
 	net_dev->wireless_data = &priv->wireless_data;
 	net_dev->wireless_handlers = &ipw_wx_handler_def;
-	net_dev->ethtool_ops = &ipw_ethtool_ops;
+	SET_ETHTOOL_OPS(net_dev, &ipw_ethtool_ops);
 
 	err = sysfs_create_group(&pdev->dev.kobj, &ipw_attribute_group);
 	if (err) {
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 0c02f04..7ebf413 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -995,7 +995,7 @@ struct lbs_private *lbs_add_card(void *card, struct device *dmdev)
 
  	dev->netdev_ops = &lbs_netdev_ops;
 	dev->watchdog_timeo = 5 * HZ;
-	dev->ethtool_ops = &lbs_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &lbs_ethtool_ops);
 	dev->flags |= IFF_BROADCAST | IFF_MULTICAST;
 
 	priv->card = card;
diff --git a/drivers/net/wireless/libertas/mesh.c b/drivers/net/wireless/libertas/mesh.c
index 6fef746..546b92a 100644
--- a/drivers/net/wireless/libertas/mesh.c
+++ b/drivers/net/wireless/libertas/mesh.c
@@ -1016,7 +1016,7 @@ static int lbs_add_mesh(struct lbs_private *priv)
 	priv->mesh_dev = mesh_dev;
 
 	mesh_dev->netdev_ops = &mesh_netdev_ops;
-	mesh_dev->ethtool_ops = &lbs_ethtool_ops;
+	SET_ETHTOOL_OPS(mesh_dev, &lbs_ethtool_ops);
 	eth_hw_addr_inherit(mesh_dev, priv->dev);
 
 	SET_NETDEV_DEV(priv->mesh_dev, priv->dev->dev.parent);
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 21ee27a..69f3ab2 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -2296,7 +2296,7 @@ struct wireless_dev *mwifiex_add_virtual_intf(struct wiphy *wiphy,
 	dev->flags |= IFF_BROADCAST | IFF_MULTICAST;
 	dev->watchdog_timeo = MWIFIEX_DEFAULT_WATCHDOG_TIMEOUT;
 	dev->hard_header_len += MWIFIEX_MIN_DATA_HEADER_LEN;
-	dev->ethtool_ops = &mwifiex_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &mwifiex_ethtool_ops);
 
 	mdev_priv = netdev_priv(dev);
 	*((unsigned long *) mdev_priv) = (unsigned long) priv;
diff --git a/drivers/net/wireless/prism54/islpci_dev.c b/drivers/net/wireless/prism54/islpci_dev.c
index 931cf44..44bb341 100644
--- a/drivers/net/wireless/prism54/islpci_dev.c
+++ b/drivers/net/wireless/prism54/islpci_dev.c
@@ -834,7 +834,7 @@ islpci_setup(struct pci_dev *pdev)
 	/* initialize the function pointers */
 	ndev->netdev_ops = &islpci_netdev_ops;
 	ndev->wireless_handlers = &prism54_handler_def;
-	ndev->ethtool_ops = &islpci_ethtool_ops;
+	SET_ETHTOOL_OPS(ndev, &islpci_ethtool_ops);
 
 	/* ndev->set_multicast_list = &islpci_set_multicast_list; */
 	ndev->addr_len = ETH_ALEN;
diff --git a/drivers/staging/bcm/Bcmnet.c b/drivers/staging/bcm/Bcmnet.c
index 95a2358..c40e613 100644
--- a/drivers/staging/bcm/Bcmnet.c
+++ b/drivers/staging/bcm/Bcmnet.c
@@ -195,7 +195,7 @@ int register_networkdev(struct bcm_mini_adapter *Adapter)
 	int result;
 
 	net->netdev_ops = &bcmNetDevOps;
-	net->ethtool_ops = &bcm_ethtool_ops;
+	SET_ETHTOOL_OPS(net, &bcm_ethtool_ops);
 	net->mtu = MTU_SIZE;	/* 1400 Bytes */
 	net->tx_queue_len = TX_QLEN;
 	net->flags |= IFF_NOARP;
diff --git a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
index c01abc2..1f282cf 100644
--- a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
+++ b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
@@ -2928,7 +2928,7 @@ static int rtl8192_pci_probe(struct pci_dev *pdev,
 
 	dev->wireless_handlers = (struct iw_handler_def *)
 				 &r8192_wx_handlers_def;
-	dev->ethtool_ops = &rtl819x_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &rtl819x_ethtool_ops);
 
 	dev->type = ARPHRD_ETHER;
 	dev->watchdog_timeo = HZ * 3;
diff --git a/drivers/staging/wlags49_h2/wl_netdev.c b/drivers/staging/wlags49_h2/wl_netdev.c
index a10d014..a24379f 100644
--- a/drivers/staging/wlags49_h2/wl_netdev.c
+++ b/drivers/staging/wlags49_h2/wl_netdev.c
@@ -1183,8 +1183,7 @@ struct net_device *wl_device_alloc(void)
 
 	dev->watchdog_timeo = TX_TIMEOUT;
 
-	dev->ethtool_ops = &wl_ethtool_ops;
-
+	SET_ETHTOOL_OPS(dev, &wl_ethtool_ops);
 	netif_stop_queue(dev);
 
 	/* Allocate virtual devices for WDS support if needed */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 733ec28..b286646 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -831,7 +831,7 @@ void vlan_setup(struct net_device *dev)
 
 	dev->netdev_ops		= &vlan_netdev_ops;
 	dev->destructor		= free_netdev;
-	dev->ethtool_ops	= &vlan_ethtool_ops;
+	SET_ETHTOOL_OPS(dev, &vlan_ethtool_ops);
 
 	memset(dev->broadcast, 0, ETH_ALEN);
 }
-- 
1.9.0
