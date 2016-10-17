From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 15/15] ethernet: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:17 -0400
Message-ID: <20161017195417.48259-16-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Mark Einon <mark.einon@gmail.com>,
        Vince Bridgers <vbridger@opensource.altera.com>,
        Rasesh Mody <rasesh.mody@qlogic.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Santosh Raspatur <santosh@chelsio.com>,
        Hariprasad S <hariprasad@chelsio.com>,
        Christian Benvenuti <benve@cisco.com>,
        Sujith Sankar <ssujith@cisco.com>,
        Govindarajulu Varadarajan <_govind@gmx.com>,
        Neel Patel <neepatel@cisco.com>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        Hyong-Youb Kim <hykim@myri.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Olof Johansson <olof@lixom.net>, Jiri Pirko <jiri@resnulli.us>,
        Byungho An <bh74.an@samsung.com>,
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

et131x: min_mtu 64, max_mtu 9216

altera_tse: min_mtu 64, max_mtu 1500

amd8111e: min_mtu 60, max_mtu 9000

bnad: min_mtu 46, max_mtu 9000

macb: min_mtu 68, max_mtu 1500 or 10240 depending on hardware capability

xgmac: min_mtu 46, max_mtu 9000

cxgb2: min_mtu 68, max_mtu 9582 (pm3393) or 9600 (vsc7326)

enic: min_mtu 68, max_mtu 9000

gianfar: min_mtu 50, max_mu 9586

hns_enet: min_mtu 68, max_mtu 9578 (v1) or 9706 (v2)

ksz884x: min_mtu 60, max_mtu 1894

myri10ge: min_mtu 68, max_mtu 9000

natsemi: min_mtu 64, max_mtu 2024

nfp: min_mtu 68, max_mtu hardware-specific

forcedeth: min_mtu 64, max_mtu 1500 or 9100, depending on hardware

pch_gbe: min_mtu 46, max_mtu 10300

pasemi_mac: min_mtu 64, max_mtu 9000

qcaspi: min_mtu 46, max_mtu 1500
- remove qcaspi_netdev_change_mtu as it is now redundant

rocker: min_mtu 68, max_mtu 9000

sxgbe: min_mtu 68, max_mtu 9000

stmmac: min_mtu 46, max_mtu depends on hardware

tehuti: min_mtu 60, max_mtu 16384
- driver had no max mtu checking, but product docs say 16k jumbo packets
  are supported by the hardware

netcp: min_mtu 68, max_mtu 9486
- remove netcp_ndo_change_mtu as it is now redundant

via-velocity: min_mtu 64, max_mtu 9000

octeon: min_mtu 46, max_mtu 65370

CC: netdev@vger.kernel.org
CC: Mark Einon <mark.einon@gmail.com>
CC: Vince Bridgers <vbridger@opensource.altera.com>
CC: Rasesh Mody <rasesh.mody@qlogic.com>
CC: Nicolas Ferre <nicolas.ferre@atmel.com>
CC: Santosh Raspatur <santosh@chelsio.com>
CC: Hariprasad S <hariprasad@chelsio.com>
CC:  Christian Benvenuti <benve@cisco.com>
CC: Sujith Sankar <ssujith@cisco.com>
CC: Govindarajulu Varadarajan <_govind@gmx.com>
CC: Neel Patel <neepatel@cisco.com>
CC: Claudiu Manoil <claudiu.manoil@freescale.com>
CC: Yisen Zhuang <yisen.zhuang@huawei.com>
CC: Salil Mehta <salil.mehta@huawei.com>
CC: Hyong-Youb Kim <hykim@myri.com>
CC: Jakub Kicinski <jakub.kicinski@netronome.com>
CC: Olof Johansson <olof@lixom.net>
CC: Jiri Pirko <jiri@resnulli.us>
CC: Byungho An <bh74.an@samsung.com>
CC: Girish K S <ks.giri@samsung.com>
CC: Vipul Pandya <vipul.pandya@samsung.com>
CC: Giuseppe Cavallaro <peppe.cavallaro@st.com>
CC: Alexandre Torgue <alexandre.torgue@st.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Wingman Kwok <w-kwok2@ti.com>
CC: Murali Karicheri <m-karicheri2@ti.com>
CC: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/agere/et131x.c                |  7 +++--
 drivers/net/ethernet/altera/altera_tse.h           |  1 -
 drivers/net/ethernet/altera/altera_tse_main.c      | 14 ++-------
 drivers/net/ethernet/amd/amd8111e.c                |  5 ++--
 drivers/net/ethernet/brocade/bna/bnad.c            |  7 +++--
 drivers/net/ethernet/cadence/macb.c                | 19 ++++++-------
 drivers/net/ethernet/calxeda/xgmac.c               | 20 ++++---------
 drivers/net/ethernet/chelsio/cxgb/common.h         |  5 ++++
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          | 18 ++++++++++--
 drivers/net/ethernet/chelsio/cxgb/pm3393.c         |  8 +-----
 drivers/net/ethernet/chelsio/cxgb/vsc7326.c        |  5 ----
 drivers/net/ethernet/cisco/enic/enic_main.c        |  7 +++--
 drivers/net/ethernet/cisco/enic/enic_res.h         |  2 +-
 drivers/net/ethernet/freescale/gianfar.c           |  9 ++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  3 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 11 +++++---
 drivers/net/ethernet/micrel/ksz884x.c              | 33 +++++++++++-----------
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   | 20 +++++++------
 drivers/net/ethernet/natsemi/natsemi.c             |  7 +++--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 10 +++----
 drivers/net/ethernet/nvidia/forcedeth.c            |  9 +++---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 13 ++++-----
 drivers/net/ethernet/pasemi/pasemi_mac.c           | 12 ++++----
 drivers/net/ethernet/qualcomm/qca_framing.h        |  6 ++--
 drivers/net/ethernet/qualcomm/qca_spi.c            | 16 +++--------
 drivers/net/ethernet/rocker/rocker_main.c          | 12 ++++----
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c    | 17 +++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 25 ++++++----------
 drivers/net/ethernet/tehuti/tehuti.c               | 14 +++------
 drivers/net/ethernet/tehuti/tehuti.h               |  3 ++
 drivers/net/ethernet/ti/netcp_core.c               | 20 +++----------
 drivers/net/ethernet/via/via-velocity.c            | 11 +++-----
 drivers/staging/octeon/ethernet.c                  | 22 +++++++--------
 33 files changed, 169 insertions(+), 222 deletions(-)

diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet/agere/et131x.c
index 9066838..831bab3 100644
--- a/drivers/net/ethernet/agere/et131x.c
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -176,6 +176,8 @@ MODULE_DESCRIPTION("10/100/1000 Base-T Ethernet Driver for the ET1310 by Agere S
 #define NUM_FBRS		2
 
 #define MAX_PACKETS_HANDLED	256
+#define ET131X_MIN_MTU		64
+#define ET131X_MAX_MTU		9216
 
 #define ALCATEL_MULTICAST_PKT	0x01000000
 #define ALCATEL_BROADCAST_PKT	0x02000000
@@ -3869,9 +3871,6 @@ static int et131x_change_mtu(struct net_device *netdev, int new_mtu)
 	int result = 0;
 	struct et131x_adapter *adapter = netdev_priv(netdev);
 
-	if (new_mtu < 64 || new_mtu > 9216)
-		return -EINVAL;
-
 	et131x_disable_txrx(netdev);
 
 	netdev->mtu = new_mtu;
@@ -3958,6 +3957,8 @@ static int et131x_pci_setup(struct pci_dev *pdev,
 
 	netdev->watchdog_timeo = ET131X_TX_TIMEOUT;
 	netdev->netdev_ops     = &et131x_netdev_ops;
+	netdev->min_mtu        = ET131X_MIN_MTU;
+	netdev->max_mtu        = ET131X_MAX_MTU;
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	netdev->ethtool_ops = &et131x_ethtool_ops;
diff --git a/drivers/net/ethernet/altera/altera_tse.h b/drivers/net/ethernet/altera/altera_tse.h
index e005200..9b640c8 100644
--- a/drivers/net/ethernet/altera/altera_tse.h
+++ b/drivers/net/ethernet/altera/altera_tse.h
@@ -443,7 +443,6 @@ struct altera_tse_private {
 	/* RX/TX MAC FIFO configs */
 	u32 tx_fifo_depth;
 	u32 rx_fifo_depth;
-	u32 max_mtu;
 
 	/* Hash filter settings */
 	u32 hash_filter;
diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index bda31f3..cc9787e 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -994,20 +994,11 @@ static void tse_set_mac(struct altera_tse_private *priv, bool enable)
  */
 static int tse_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct altera_tse_private *priv = netdev_priv(dev);
-	unsigned int max_mtu = priv->max_mtu;
-	unsigned int min_mtu = ETH_ZLEN + ETH_FCS_LEN;
-
 	if (netif_running(dev)) {
 		netdev_err(dev, "must be stopped to change its MTU\n");
 		return -EBUSY;
 	}
 
-	if ((new_mtu < min_mtu) || (new_mtu > max_mtu)) {
-		netdev_err(dev, "invalid MTU, max MTU is: %u\n", max_mtu);
-		return -EINVAL;
-	}
-
 	dev->mtu = new_mtu;
 	netdev_update_features(dev);
 
@@ -1446,15 +1437,16 @@ static int altera_tse_probe(struct platform_device *pdev)
 		of_property_read_bool(pdev->dev.of_node,
 				      "altr,has-supplementary-unicast");
 
+	priv->dev->min_mtu = ETH_ZLEN + ETH_FCS_LEN;
 	/* Max MTU is 1500, ETH_DATA_LEN */
-	priv->max_mtu = ETH_DATA_LEN;
+	priv->dev->max_mtu = ETH_DATA_LEN;
 
 	/* Get the max mtu from the device tree. Note that the
 	 * "max-frame-size" parameter is actually max mtu. Definition
 	 * in the ePAPR v1.1 spec and usage differ, so go with usage.
 	 */
 	of_property_read_u32(pdev->dev.of_node, "max-frame-size",
-			     &priv->max_mtu);
+			     &priv->dev->max_mtu);
 
 	/* The DMA buffer size already accounts for an alignment bias
 	 * to avoid unaligned access exceptions for the NIOS processor,
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index f92cc971..84b4ffb 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -1556,9 +1556,6 @@ static int amd8111e_change_mtu(struct net_device *dev, int new_mtu)
 	struct amd8111e_priv *lp = netdev_priv(dev);
 	int err;
 
-	if ((new_mtu < AMD8111E_MIN_MTU) || (new_mtu > AMD8111E_MAX_MTU))
-		return -EINVAL;
-
 	if (!netif_running(dev)) {
 		/* new_mtu will be used
 		 * when device starts netxt time
@@ -1874,6 +1871,8 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	dev->ethtool_ops = &ops;
 	dev->irq =pdev->irq;
 	dev->watchdog_timeo = AMD8111E_TX_TIMEOUT;
+	dev->min_mtu = AMD8111E_MIN_MTU;
+	dev->max_mtu = AMD8111E_MAX_MTU;
 	netif_napi_add(dev, &lp->napi, amd8111e_rx_poll, 32);
 
 #if AMD8111E_VLAN_TAG_USED
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index f9df4b5a..b200a78 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3296,9 +3296,6 @@ bnad_change_mtu(struct net_device *netdev, int new_mtu)
 	struct bnad *bnad = netdev_priv(netdev);
 	u32 rx_count = 0, frame, new_frame;
 
-	if (new_mtu + ETH_HLEN < ETH_ZLEN || new_mtu > BNAD_JUMBO_MTU)
-		return -EINVAL;
-
 	mutex_lock(&bnad->conf_mutex);
 
 	mtu = netdev->mtu;
@@ -3465,6 +3462,10 @@ bnad_netdev_init(struct bnad *bnad, bool using_dac)
 	netdev->mem_start = bnad->mmio_start;
 	netdev->mem_end = bnad->mmio_start + bnad->mmio_len - 1;
 
+	/* MTU range: 46 - 9000 */
+	netdev->min_mtu = ETH_ZLEN - ETH_HLEN;
+	netdev->max_mtu = BNAD_JUMBO_MTU;
+
 	netdev->netdev_ops = &bnad_netdev_ops;
 	bnad_set_ethtool_ops(netdev);
 }
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 20e7204..e83781a 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -56,7 +56,7 @@
 #define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
 #define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
 
-#define GEM_MTU_MIN_SIZE	68
+#define GEM_MTU_MIN_SIZE	ETH_MIN_MTU
 
 #define MACB_WOL_HAS_MAGIC_PACKET	(0x1 << 0)
 #define MACB_WOL_ENABLED		(0x1 << 1)
@@ -1986,19 +1986,9 @@ static int macb_close(struct net_device *dev)
 
 static int macb_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct macb *bp = netdev_priv(dev);
-	u32 max_mtu;
-
 	if (netif_running(dev))
 		return -EBUSY;
 
-	max_mtu = ETH_DATA_LEN;
-	if (bp->caps & MACB_CAPS_JUMBO)
-		max_mtu = gem_readl(bp, JML) - ETH_HLEN - ETH_FCS_LEN;
-
-	if ((new_mtu > max_mtu) || (new_mtu < GEM_MTU_MIN_SIZE))
-		return -EINVAL;
-
 	dev->mtu = new_mtu;
 
 	return 0;
@@ -3027,6 +3017,13 @@ static int macb_probe(struct platform_device *pdev)
 		goto err_out_free_netdev;
 	}
 
+	/* MTU range: 68 - 1500 or 10240 */
+	dev->min_mtu = GEM_MTU_MIN_SIZE;
+	if (bp->caps & MACB_CAPS_JUMBO)
+		dev->max_mtu = gem_readl(bp, JML) - ETH_HLEN - ETH_FCS_LEN;
+	else
+		dev->max_mtu = ETH_DATA_LEN;
+
 	mac = of_get_mac_address(np);
 	if (mac)
 		ether_addr_copy(bp->dev->dev_addr, mac);
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 63efa0d..6e72366 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -394,7 +394,7 @@ struct xgmac_priv {
 };
 
 /* XGMAC Configuration Settings */
-#define MAX_MTU			9000
+#define XGMAC_MAX_MTU		9000
 #define PAUSE_TIME		0x400
 
 #define DMA_RX_RING_SZ		256
@@ -1360,20 +1360,6 @@ static void xgmac_set_rx_mode(struct net_device *dev)
  */
 static int xgmac_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct xgmac_priv *priv = netdev_priv(dev);
-	int old_mtu;
-
-	if ((new_mtu < 46) || (new_mtu > MAX_MTU)) {
-		netdev_err(priv->dev, "invalid MTU, max MTU is: %d\n", MAX_MTU);
-		return -EINVAL;
-	}
-
-	old_mtu = dev->mtu;
-
-	/* return early if the buffer sizes will not change */
-	if (old_mtu == new_mtu)
-		return 0;
-
 	/* Stop everything, get ready to change the MTU */
 	if (!netif_running(dev))
 		return 0;
@@ -1804,6 +1790,10 @@ static int xgmac_probe(struct platform_device *pdev)
 	ndev->features |= ndev->hw_features;
 	ndev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 46 - 9000 */
+	ndev->min_mtu = ETH_ZLEN - ETH_HLEN;
+	ndev->max_mtu = XGMAC_MAX_MTU;
+
 	/* Get the MAC address */
 	xgmac_get_mac_addr(priv->base, ndev->dev_addr, 0);
 	if (!is_valid_ether_addr(ndev->dev_addr))
diff --git a/drivers/net/ethernet/chelsio/cxgb/common.h b/drivers/net/ethernet/chelsio/cxgb/common.h
index 53b1f94..6916c62 100644
--- a/drivers/net/ethernet/chelsio/cxgb/common.h
+++ b/drivers/net/ethernet/chelsio/cxgb/common.h
@@ -85,6 +85,11 @@ struct t1_rx_mode {
 #define SPEED_INVALID 0xffff
 #define DUPLEX_INVALID 0xff
 
+/* Max frame size PM3393 can handle. Includes Ethernet header and CRC. */
+#define PM3393_MAX_FRAME_SIZE 9600
+
+#define VSC7326_MAX_MTU 9600
+
 enum {
 	CHBT_BOARD_N110,
 	CHBT_BOARD_N210,
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index f5f1b0b..81d1d0b 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -825,8 +825,6 @@ static int t1_change_mtu(struct net_device *dev, int new_mtu)
 
 	if (!mac->ops->set_mtu)
 		return -EOPNOTSUPP;
-	if (new_mtu < 68)
-		return -EINVAL;
 	if ((ret = mac->ops->set_mtu(mac, new_mtu)))
 		return ret;
 	dev->mtu = new_mtu;
@@ -1101,6 +1099,22 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
 
 		netdev->ethtool_ops = &t1_ethtool_ops;
+
+		switch (bi->board) {
+		case CHBT_BOARD_CHT110:
+		case CHBT_BOARD_N110:
+		case CHBT_BOARD_N210:
+		case CHBT_BOARD_CHT210:
+			netdev->max_mtu = PM3393_MAX_FRAME_SIZE -
+					  (ETH_HLEN + ETH_FCS_LEN);
+			break;
+		case CHBT_BOARD_CHN204:
+			netdev->max_mtu = VSC7326_MAX_MTU;
+			break;
+		default:
+			netdev->max_mtu = ETH_DATA_LEN;
+			break;
+		}
 	}
 
 	if (t1_init_sw_modules(adapter, bi) < 0) {
diff --git a/drivers/net/ethernet/chelsio/cxgb/pm3393.c b/drivers/net/ethernet/chelsio/cxgb/pm3393.c
index eb462d7..c27908e 100644
--- a/drivers/net/ethernet/chelsio/cxgb/pm3393.c
+++ b/drivers/net/ethernet/chelsio/cxgb/pm3393.c
@@ -47,9 +47,6 @@
 
 #define OFFSET(REG_ADDR)    ((REG_ADDR) << 2)
 
-/* Max frame size PM3393 can handle. Includes Ethernet header and CRC. */
-#define MAX_FRAME_SIZE  9600
-
 #define IPG 12
 #define TXXG_CONF1_VAL ((IPG << SUNI1x10GEXP_BITOFF_TXXG_IPGT) | \
 	SUNI1x10GEXP_BITMSK_TXXG_32BIT_ALIGN | SUNI1x10GEXP_BITMSK_TXXG_CRCEN | \
@@ -331,10 +328,7 @@ static int pm3393_set_mtu(struct cmac *cmac, int mtu)
 {
 	int enabled = cmac->instance->enabled;
 
-	/* MAX_FRAME_SIZE includes header + FCS, mtu doesn't */
-	mtu += 14 + 4;
-	if (mtu > MAX_FRAME_SIZE)
-		return -EINVAL;
+	mtu += ETH_HLEN + ETH_FCS_LEN;
 
 	/* Disable Rx/Tx MAC before configuring it. */
 	if (enabled)
diff --git a/drivers/net/ethernet/chelsio/cxgb/vsc7326.c b/drivers/net/ethernet/chelsio/cxgb/vsc7326.c
index 6f30b6f..bdc895b 100644
--- a/drivers/net/ethernet/chelsio/cxgb/vsc7326.c
+++ b/drivers/net/ethernet/chelsio/cxgb/vsc7326.c
@@ -11,8 +11,6 @@
 /* 30 minutes for full statistics update */
 #define MAJOR_UPDATE_TICKS (1800 / STATS_TICK_SECS)
 
-#define MAX_MTU 9600
-
 /* The egress WM value 0x01a01fff should be used only when the
  * interface is down (MAC port disabled). This is a workaround
  * for disabling the T2/MAC flow-control. When the interface is
@@ -452,9 +450,6 @@ static int mac_set_mtu(struct cmac *mac, int mtu)
 {
 	int port = mac->instance->index;
 
-	if (mtu > MAX_MTU)
-		return -EINVAL;
-
 	/* max_len includes header and FCS */
 	vsc_write(mac->adapter, REG_MAX_LEN(port), mtu + 14 + 4);
 	return 0;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 48f82ab..f514faf 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1843,9 +1843,6 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 	struct enic *enic = netdev_priv(netdev);
 	int running = netif_running(netdev);
 
-	if (new_mtu < ENIC_MIN_MTU || new_mtu > ENIC_MAX_MTU)
-		return -EINVAL;
-
 	if (enic_is_dynamic(enic) || enic_is_sriov_vf(enic))
 		return -EOPNOTSUPP;
 
@@ -2751,6 +2748,10 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 68 - 9000 */
+	netdev->min_mtu = ENIC_MIN_MTU;
+	netdev->max_mtu = ENIC_MAX_MTU;
+
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(dev, "Cannot register net device, aborting\n");
diff --git a/drivers/net/ethernet/cisco/enic/enic_res.h b/drivers/net/ethernet/cisco/enic/enic_res.h
index 69f60af..81f98a8 100644
--- a/drivers/net/ethernet/cisco/enic/enic_res.h
+++ b/drivers/net/ethernet/cisco/enic/enic_res.h
@@ -30,7 +30,7 @@
 #define ENIC_MIN_RQ_DESCS		64
 #define ENIC_MAX_RQ_DESCS		4096
 
-#define ENIC_MIN_MTU			68
+#define ENIC_MIN_MTU			ETH_MIN_MTU
 #define ENIC_MAX_MTU			9000
 
 #define ENIC_MULTICAST_PERFECT_FILTERS	32
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4b4f5bc..4092104 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1338,7 +1338,10 @@ static int gfar_probe(struct platform_device *ofdev)
 
 	/* Fill in the dev structure */
 	dev->watchdog_timeo = TX_TIMEOUT;
+	/* MTU range: 50 - 9586 */
 	dev->mtu = 1500;
+	dev->min_mtu = 50;
+	dev->max_mtu = GFAR_JUMBO_FRAME_SIZE - ETH_HLEN;
 	dev->netdev_ops = &gfar_netdev_ops;
 	dev->ethtool_ops = &gfar_ethtool_ops;
 
@@ -2592,12 +2595,6 @@ static int gfar_set_mac_address(struct net_device *dev)
 static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct gfar_private *priv = netdev_priv(dev);
-	int frame_size = new_mtu + ETH_HLEN;
-
-	if ((frame_size < 64) || (frame_size > GFAR_JUMBO_FRAME_SIZE)) {
-		netif_err(priv, drv, dev, "Invalid MTU setting\n");
-		return -EINVAL;
-	}
 
 	while (test_and_set_bit_lock(GFAR_RESETTING, &priv->state))
 		cpu_relax();
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 22e1410..d8e9941 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -446,8 +446,7 @@ int hns_mac_set_mtu(struct hns_mac_cb *mac_cb, u32 new_mtu)
 	if (mac_cb->mac_type == HNAE_PORT_DEBUG)
 		max_frm = MAC_MAX_MTU_DBG;
 
-	if ((new_mtu < MAC_MIN_MTU) || (new_frm > max_frm) ||
-	    (new_frm > HNS_RCB_RING_MAX_BD_PER_PKT * buf_size))
+	if (new_frm > HNS_RCB_RING_MAX_BD_PER_PKT * buf_size)
 		return -EINVAL;
 
 	if (!drv->config_max_frame_length)
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 059aaed..a720867 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -22,6 +22,7 @@
 
 #include "hnae.h"
 #include "hns_enet.h"
+#include "hns_dsaf_mac.h"
 
 #define NIC_MAX_Q_PER_VF 16
 #define HNS_NIC_TX_TIMEOUT (5 * HZ)
@@ -1405,10 +1406,6 @@ static int hns_nic_change_mtu(struct net_device *ndev, int new_mtu)
 	struct hnae_handle *h = priv->ae_handle;
 	int ret;
 
-	/* MTU < 68 is an error and causes problems on some kernels */
-	if (new_mtu < 68)
-		return -EINVAL;
-
 	if (!h->dev->ops->set_mtu)
 		return -ENOTSUPP;
 
@@ -1953,14 +1950,20 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
 	ndev->vlan_features |= NETIF_F_SG | NETIF_F_GSO | NETIF_F_GRO;
 
+	/* MTU range: 68 - 9578 (v1) or 9706 (v2) */
+	ndev->min_mtu = MAC_MIN_MTU;
 	switch (priv->enet_ver) {
 	case AE_VERSION_2:
 		ndev->features |= NETIF_F_TSO | NETIF_F_TSO6;
 		ndev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
 			NETIF_F_GRO | NETIF_F_TSO | NETIF_F_TSO6;
+		ndev->max_mtu = MAC_MAX_MTU_V2 -
+				(ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
 		break;
 	default:
+		ndev->max_mtu = MAC_MAX_MTU -
+				(ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
 		break;
 	}
 
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 280e761..97f6ef1 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -5807,24 +5807,19 @@ static int netdev_change_mtu(struct net_device *dev, int new_mtu)
 	if (hw->dev_count > 1)
 		if (dev != hw_priv->dev)
 			return 0;
-	if (new_mtu < 60)
-		return -EINVAL;
 
-	if (dev->mtu != new_mtu) {
-		hw_mtu = new_mtu + ETHERNET_HEADER_SIZE + 4;
-		if (hw_mtu > MAX_RX_BUF_SIZE)
-			return -EINVAL;
-		if (hw_mtu > REGULAR_RX_BUF_SIZE) {
-			hw->features |= RX_HUGE_FRAME;
-			hw_mtu = MAX_RX_BUF_SIZE;
-		} else {
-			hw->features &= ~RX_HUGE_FRAME;
-			hw_mtu = REGULAR_RX_BUF_SIZE;
-		}
-		hw_mtu = (hw_mtu + 3) & ~3;
-		hw_priv->mtu = hw_mtu;
-		dev->mtu = new_mtu;
+	hw_mtu = new_mtu + ETHERNET_HEADER_SIZE + 4;
+	if (hw_mtu > REGULAR_RX_BUF_SIZE) {
+		hw->features |= RX_HUGE_FRAME;
+		hw_mtu = MAX_RX_BUF_SIZE;
+	} else {
+		hw->features &= ~RX_HUGE_FRAME;
+		hw_mtu = REGULAR_RX_BUF_SIZE;
 	}
+	hw_mtu = (hw_mtu + 3) & ~3;
+	hw_priv->mtu = hw_mtu;
+	dev->mtu = new_mtu;
+
 	return 0;
 }
 
@@ -7099,6 +7094,12 @@ static int pcidev_init(struct pci_dev *pdev, const struct pci_device_id *id)
 
 		dev->netdev_ops = &netdev_ops;
 		dev->ethtool_ops = &netdev_ethtool_ops;
+
+		/* MTU range: 60 - 1894 */
+		dev->min_mtu = ETH_ZLEN;
+		dev->max_mtu = MAX_RX_BUF_SIZE -
+			       (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
+
 		if (register_netdev(dev))
 			goto pcidev_init_reg_err;
 		port_set_power_saving(port, true);
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 6d1a956..5ae3f17 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -3232,10 +3232,6 @@ static int myri10ge_change_mtu(struct net_device *dev, int new_mtu)
 	struct myri10ge_priv *mgp = netdev_priv(dev);
 	int error = 0;
 
-	if ((new_mtu < 68) || (ETH_HLEN + new_mtu > MYRI10GE_MAX_ETHER_MTU)) {
-		netdev_err(dev, "new mtu (%d) is not valid\n", new_mtu);
-		return -EINVAL;
-	}
 	netdev_info(dev, "changing mtu from %d to %d\n", dev->mtu, new_mtu);
 	if (mgp->running) {
 		/* if we change the mtu on an active device, we must
@@ -4086,13 +4082,19 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	myri10ge_setup_dca(mgp);
 #endif
 	pci_set_drvdata(pdev, mgp);
-	if ((myri10ge_initial_mtu + ETH_HLEN) > MYRI10GE_MAX_ETHER_MTU)
-		myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
-	if ((myri10ge_initial_mtu + ETH_HLEN) < 68)
-		myri10ge_initial_mtu = 68;
 
-	netdev->netdev_ops = &myri10ge_netdev_ops;
+	/* MTU range: 68 - 9000 */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
+
+	if (myri10ge_initial_mtu > netdev->max_mtu)
+		myri10ge_initial_mtu = netdev->max_mtu;
+	if (myri10ge_initial_mtu < netdev->min_mtu)
+		myri10ge_initial_mtu = netdev->min_mtu;
+
 	netdev->mtu = myri10ge_initial_mtu;
+
+	netdev->netdev_ops = &myri10ge_netdev_ops;
 	netdev->hw_features = mgp->features | NETIF_F_RXCSUM;
 
 	/* fake NETIF_F_HW_VLAN_CTAG_RX for good GRO performance */
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index ed89029..22b0821 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -929,6 +929,10 @@ static int natsemi_probe1(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev->ethtool_ops = &ethtool_ops;
 
+	/* MTU range: 64 - 2024 */
+	dev->min_mtu = ETH_ZLEN + ETH_FCS_LEN;
+	dev->max_mtu = NATSEMI_RX_LIMIT - NATSEMI_HEADERS;
+
 	if (mtu)
 		dev->mtu = mtu;
 
@@ -2526,9 +2530,6 @@ static void __set_rx_mode(struct net_device *dev)
 
 static int natsemi_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < 64 || new_mtu > NATSEMI_RX_LIMIT-NATSEMI_HEADERS)
-		return -EINVAL;
-
 	dev->mtu = new_mtu;
 
 	/* synchronized against open : rtnl_lock() held by caller */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index aee3fd2..d365760 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2278,11 +2278,6 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	struct nfp_net_rx_ring *tmp_rings;
 	int err;
 
-	if (new_mtu < 68 || new_mtu > nn->max_mtu) {
-		nn_err(nn, "New MTU (%d) is not valid\n", new_mtu);
-		return -EINVAL;
-	}
-
 	old_mtu = netdev->mtu;
 	old_fl_bufsz = nn->fl_bufsz;
 	new_fl_bufsz = NFP_NET_MAX_PREPEND + ETH_HLEN + VLAN_HLEN * 2 + new_mtu;
@@ -2930,6 +2925,11 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	ether_setup(netdev);
 	netdev->netdev_ops = &nfp_net_netdev_ops;
 	netdev->watchdog_timeo = msecs_to_jiffies(5 * 1000);
+
+	/* MTU range: 68 - hw-specific max */
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = nn->max_mtu;
+
 	netif_carrier_off(netdev);
 
 	nfp_net_set_ethtool_ops(netdev);
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 9b0d7f4..3913f07 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3008,17 +3008,12 @@ static int nv_change_mtu(struct net_device *dev, int new_mtu)
 	struct fe_priv *np = netdev_priv(dev);
 	int old_mtu;
 
-	if (new_mtu < 64 || new_mtu > np->pkt_limit)
-		return -EINVAL;
-
 	old_mtu = dev->mtu;
 	dev->mtu = new_mtu;
 
 	/* return early if the buffer sizes will not change */
 	if (old_mtu <= ETH_DATA_LEN && new_mtu <= ETH_DATA_LEN)
 		return 0;
-	if (old_mtu == new_mtu)
-		return 0;
 
 	/* synchronized against open : rtnl_lock() held by caller */
 	if (netif_running(dev)) {
@@ -5719,6 +5714,10 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	/* Add loopback capability to the device. */
 	dev->hw_features |= NETIF_F_LOOPBACK;
 
+	/* MTU range: 64 - 1500 or 9100 */
+	dev->min_mtu = ETH_ZLEN + ETH_FCS_LEN;
+	dev->max_mtu = np->pkt_limit;
+
 	np->pause_flags = NV_PAUSEFRAME_RX_CAPABLE | NV_PAUSEFRAME_RX_REQ | NV_PAUSEFRAME_AUTONEG;
 	if ((id->driver_data & DEV_HAS_PAUSEFRAME_TX_V1) ||
 	    (id->driver_data & DEV_HAS_PAUSEFRAME_TX_V2) ||
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3cd87a4..d461f41 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2260,16 +2260,10 @@ static int pch_gbe_set_mac(struct net_device *netdev, void *addr)
 static int pch_gbe_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
-	int max_frame;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 	unsigned long old_rx_buffer_len = adapter->rx_buffer_len;
 	int err;
 
-	max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
-		(max_frame > PCH_GBE_MAX_JUMBO_FRAME_SIZE)) {
-		netdev_err(netdev, "Invalid MTU setting\n");
-		return -EINVAL;
-	}
 	if (max_frame <= PCH_GBE_FRAME_SIZE_2048)
 		adapter->rx_buffer_len = PCH_GBE_FRAME_SIZE_2048;
 	else if (max_frame <= PCH_GBE_FRAME_SIZE_4096)
@@ -2633,6 +2627,11 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	netdev->features = netdev->hw_features;
 	pch_gbe_set_ethtool_ops(netdev);
 
+	/* MTU range: 46 - 10300 */
+	netdev->min_mtu = ETH_ZLEN - ETH_HLEN;
+	netdev->max_mtu = PCH_GBE_MAX_JUMBO_FRAME_SIZE -
+			  (ETH_HLEN + ETH_FCS_LEN);
+
 	pch_gbe_mac_load_mac_addr(&adapter->hw);
 	pch_gbe_mac_reset_hw(&adapter->hw);
 
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 2f4a837..badfa1d 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -53,7 +53,7 @@
  * - Multiqueue RX/TX
  */
 
-#define PE_MIN_MTU	64
+#define PE_MIN_MTU	(ETH_ZLEN + ETH_HLEN)
 #define PE_MAX_MTU	9000
 #define PE_DEF_MTU	ETH_DATA_LEN
 
@@ -1611,9 +1611,6 @@ static int pasemi_mac_change_mtu(struct net_device *dev, int new_mtu)
 	int running;
 	int ret = 0;
 
-	if (new_mtu < PE_MIN_MTU || new_mtu > PE_MAX_MTU)
-		return -EINVAL;
-
 	running = netif_running(dev);
 
 	if (running) {
@@ -1635,7 +1632,7 @@ static int pasemi_mac_change_mtu(struct net_device *dev, int new_mtu)
 	}
 
 	/* Setup checksum channels if large MTU and none already allocated */
-	if (new_mtu > 1500 && !mac->num_cs) {
+	if (new_mtu > PE_DEF_MTU && !mac->num_cs) {
 		pasemi_mac_setup_csrings(mac);
 		if (!mac->num_cs) {
 			ret = -ENOMEM;
@@ -1757,6 +1754,11 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev->netdev_ops = &pasemi_netdev_ops;
 	dev->mtu = PE_DEF_MTU;
+
+	/* MTU range: 64 - 9000 */
+	dev->min_mtu = PE_MIN_MTU;
+	dev->max_mtu = PE_MAX_MTU;
+
 	/* 1500 MTU + ETH_HLEN + VLAN_HLEN + 2 64B cachelines */
 	mac->bufsz = dev->mtu + ETH_HLEN + ETH_FCS_LEN + LOCAL_SKB_ALIGN + 128;
 
diff --git a/drivers/net/ethernet/qualcomm/qca_framing.h b/drivers/net/ethernet/qualcomm/qca_framing.h
index 5d96595..d5e795d 100644
--- a/drivers/net/ethernet/qualcomm/qca_framing.h
+++ b/drivers/net/ethernet/qualcomm/qca_framing.h
@@ -43,9 +43,9 @@
 /* Frame length is invalid */
 #define QCAFRM_INVFRAME (QCAFRM_ERR_BASE - 4)
 
-/* Min/Max Ethernet MTU */
-#define QCAFRM_ETHMINMTU 46
-#define QCAFRM_ETHMAXMTU 1500
+/* Min/Max Ethernet MTU: 46/1500 */
+#define QCAFRM_ETHMINMTU (ETH_ZLEN - ETH_HLEN)
+#define QCAFRM_ETHMAXMTU ETH_DATA_LEN
 
 /* Min/Max frame lengths */
 #define QCAFRM_ETHMINLEN (QCAFRM_ETHMINMTU + ETH_HLEN)
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 6e2add9..513e6c7 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -780,24 +780,12 @@ qcaspi_netdev_uninit(struct net_device *dev)
 		dev_kfree_skb(qca->rx_skb);
 }
 
-static int
-qcaspi_netdev_change_mtu(struct net_device *dev, int new_mtu)
-{
-	if ((new_mtu < QCAFRM_ETHMINMTU) || (new_mtu > QCAFRM_ETHMAXMTU))
-		return -EINVAL;
-
-	dev->mtu = new_mtu;
-
-	return 0;
-}
-
 static const struct net_device_ops qcaspi_netdev_ops = {
 	.ndo_init = qcaspi_netdev_init,
 	.ndo_uninit = qcaspi_netdev_uninit,
 	.ndo_open = qcaspi_netdev_open,
 	.ndo_stop = qcaspi_netdev_close,
 	.ndo_start_xmit = qcaspi_netdev_xmit,
-	.ndo_change_mtu = qcaspi_netdev_change_mtu,
 	.ndo_set_mac_address = eth_mac_addr,
 	.ndo_tx_timeout = qcaspi_netdev_tx_timeout,
 	.ndo_validate_addr = eth_validate_addr,
@@ -814,6 +802,10 @@ qcaspi_netdev_setup(struct net_device *dev)
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->tx_queue_len = 100;
 
+	/* MTU range: 46 - 1500 */
+	dev->min_mtu = QCAFRM_ETHMINMTU;
+	dev->max_mtu = QCAFRM_ETHMAXMTU;
+
 	qca = netdev_priv(dev);
 	memset(qca, 0, sizeof(struct qcaspi));
 
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 5424fb3..9b64f36 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1953,12 +1953,6 @@ static int rocker_port_change_mtu(struct net_device *dev, int new_mtu)
 	int running = netif_running(dev);
 	int err;
 
-#define ROCKER_PORT_MIN_MTU	68
-#define ROCKER_PORT_MAX_MTU	9000
-
-	if (new_mtu < ROCKER_PORT_MIN_MTU || new_mtu > ROCKER_PORT_MAX_MTU)
-		return -EINVAL;
-
 	if (running)
 		rocker_port_stop(dev);
 
@@ -2536,6 +2530,8 @@ static void rocker_port_dev_addr_init(struct rocker_port *rocker_port)
 	}
 }
 
+#define ROCKER_PORT_MIN_MTU	ETH_MIN_MTU
+#define ROCKER_PORT_MAX_MTU	9000
 static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 {
 	const struct pci_dev *pdev = rocker->pdev;
@@ -2570,6 +2566,10 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_SG;
 
+	/* MTU range: 68 - 9000 */
+	dev->min_mtu = ROCKER_PORT_MIN_MTU;
+	dev->max_mtu = ROCKER_PORT_MAX_MTU;
+
 	err = rocker_world_port_pre_init(rocker_port);
 	if (err) {
 		dev_err(&pdev->dev, "port world pre-init failed\n");
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index ea44a24..5dbe406 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -1820,19 +1820,6 @@ static int sxgbe_set_features(struct net_device *dev,
  */
 static int sxgbe_change_mtu(struct net_device *dev, int new_mtu)
 {
-	/* RFC 791, page 25, "Every internet module must be able to forward
-	 * a datagram of 68 octets without further fragmentation."
-	 */
-	if (new_mtu < MIN_MTU || (new_mtu > MAX_MTU)) {
-		netdev_err(dev, "invalid MTU, MTU should be in between %d and %d\n",
-			   MIN_MTU, MAX_MTU);
-		return -EINVAL;
-	}
-
-	/* Return if the buffer sizes will not change */
-	if (dev->mtu == new_mtu)
-		return 0;
-
 	dev->mtu = new_mtu;
 
 	if (!netif_running(dev))
@@ -2144,6 +2131,10 @@ struct sxgbe_priv_data *sxgbe_drv_probe(struct device *device,
 	/* assign filtering support */
 	ndev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* MTU range: 68 - 9000 */
+	ndev->min_mtu = MIN_MTU;
+	ndev->max_mtu = MAX_MTU;
+
 	priv->msg_enable = netif_msg_init(debug, default_msg_level);
 
 	/* Enable TCP segmentation offload for all DMA channels */
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index da0b80a..fa4a82f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2715,27 +2715,11 @@ static void stmmac_set_rx_mode(struct net_device *dev)
  */
 static int stmmac_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct stmmac_priv *priv = netdev_priv(dev);
-	int max_mtu;
-
 	if (netif_running(dev)) {
 		pr_err("%s: must be stopped to change its MTU\n", dev->name);
 		return -EBUSY;
 	}
 
-	if ((priv->plat->enh_desc) || (priv->synopsys_id >= DWMAC_CORE_4_00))
-		max_mtu = JUMBO_LEN;
-	else
-		max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
-
-	if (priv->plat->maxmtu < max_mtu)
-		max_mtu = priv->plat->maxmtu;
-
-	if ((new_mtu < 46) || (new_mtu > max_mtu)) {
-		pr_err("%s: invalid MTU, max MTU is: %d\n", dev->name, max_mtu);
-		return -EINVAL;
-	}
-
 	dev->mtu = new_mtu;
 
 	netdev_update_features(dev);
@@ -3317,6 +3301,15 @@ int stmmac_dvr_probe(struct device *device,
 #endif
 	priv->msg_enable = netif_msg_init(debug, default_msg_level);
 
+	/* MTU range: 46 - hw-specific max */
+	ndev->min_mtu = ETH_ZLEN - ETH_HLEN;
+	if ((priv->plat->enh_desc) || (priv->synopsys_id >= DWMAC_CORE_4_00))
+		ndev->max_mtu = JUMBO_LEN;
+	else
+		ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
+	if (priv->plat->maxmtu < ndev->max_mtu)
+		ndev->max_mtu = priv->plat->maxmtu;
+
 	if (flow_ctrl)
 		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
 
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 7108c68..baa3e4a 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -761,16 +761,6 @@ static int bdx_change_mtu(struct net_device *ndev, int new_mtu)
 {
 	ENTER;
 
-	if (new_mtu == ndev->mtu)
-		RET(0);
-
-	/* enforce minimum frame size */
-	if (new_mtu < ETH_ZLEN) {
-		netdev_err(ndev, "mtu %d is less then minimal %d\n",
-			   new_mtu, ETH_ZLEN);
-		RET(-EINVAL);
-	}
-
 	ndev->mtu = new_mtu;
 	if (netif_running(ndev)) {
 		bdx_close(ndev);
@@ -2057,6 +2047,10 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef BDX_LLTX
 		ndev->features |= NETIF_F_LLTX;
 #endif
+		/* MTU range: 60 - 16384 */
+		ndev->min_mtu = ETH_ZLEN;
+		ndev->max_mtu = BDX_MAX_MTU;
+
 		spin_lock_init(&priv->tx_lock);
 
 		/*bdx_hw_reset(priv); */
diff --git a/drivers/net/ethernet/tehuti/tehuti.h b/drivers/net/ethernet/tehuti/tehuti.h
index 709ebd6..8e7b4c9 100644
--- a/drivers/net/ethernet/tehuti/tehuti.h
+++ b/drivers/net/ethernet/tehuti/tehuti.h
@@ -74,6 +74,9 @@
  * ifcontig eth1 txqueuelen 3000 - to change it at runtime */
 #define BDX_NDEV_TXQ_LEN 3000
 
+/* Max MTU for Jumbo Frame mode, per tehutinetworks.net Features FAQ is 16k */
+#define BDX_MAX_MTU	(16 * 1024)
+
 #define FIFO_SIZE  4096
 #define FIFO_EXTRA_SPACE            1024
 
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index 3251666..11609d5 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1766,21 +1766,6 @@ static int netcp_ndo_ioctl(struct net_device *ndev,
 	return (ret == 0) ? 0 : err;
 }
 
-static int netcp_ndo_change_mtu(struct net_device *ndev, int new_mtu)
-{
-	struct netcp_intf *netcp = netdev_priv(ndev);
-
-	/* MTU < 68 is an error for IPv4 traffic */
-	if ((new_mtu < 68) ||
-	    (new_mtu > (NETCP_MAX_FRAME_SIZE - ETH_HLEN - ETH_FCS_LEN))) {
-		dev_err(netcp->ndev_dev, "Invalid mtu size = %d\n", new_mtu);
-		return -EINVAL;
-	}
-
-	ndev->mtu = new_mtu;
-	return 0;
-}
-
 static void netcp_ndo_tx_timeout(struct net_device *ndev)
 {
 	struct netcp_intf *netcp = netdev_priv(ndev);
@@ -1886,7 +1871,6 @@ static const struct net_device_ops netcp_netdev_ops = {
 	.ndo_start_xmit		= netcp_ndo_start_xmit,
 	.ndo_set_rx_mode	= netcp_set_rx_mode,
 	.ndo_do_ioctl           = netcp_ndo_ioctl,
-	.ndo_change_mtu		= netcp_ndo_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_vlan_rx_add_vid	= netcp_rx_add_vid,
@@ -1923,6 +1907,10 @@ static int netcp_create_interface(struct netcp_device *netcp_device,
 	ndev->hw_features = ndev->features;
 	ndev->vlan_features |=  NETIF_F_SG;
 
+	/* MTU range: 68 - 9486 */
+	ndev->min_mtu = ETH_MIN_MTU;
+	ndev->max_mtu = NETCP_MAX_FRAME_SIZE - (ETH_HLEN + ETH_FCS_LEN);
+
 	netcp = netdev_priv(ndev);
 	spin_lock_init(&netcp->lock);
 	INIT_LIST_HEAD(&netcp->module_head);
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 908e72e..4716e60 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2284,13 +2284,6 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 	struct velocity_info *vptr = netdev_priv(dev);
 	int ret = 0;
 
-	if ((new_mtu < VELOCITY_MIN_MTU) || new_mtu > (VELOCITY_MAX_MTU)) {
-		VELOCITY_PRT(MSG_LEVEL_ERR, KERN_NOTICE "%s: Invalid MTU.\n",
-				vptr->netdev->name);
-		ret = -EINVAL;
-		goto out_0;
-	}
-
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
 		goto out_0;
@@ -2864,6 +2857,10 @@ static int velocity_probe(struct device *dev, int irq,
 			NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_CTAG_RX |
 			NETIF_F_IP_CSUM;
 
+	/* MTU range: 64 - 9000 */
+	netdev->min_mtu = VELOCITY_MIN_MTU;
+	netdev->max_mtu = VELOCITY_MAX_MTU;
+
 	ret = register_netdev(netdev);
 	if (ret < 0)
 		goto err_iounmap;
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index d02e3e3..8130dfe 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -259,17 +259,6 @@ static int cvm_oct_common_change_mtu(struct net_device *dev, int new_mtu)
 #endif
 	int mtu_overhead = ETH_HLEN + ETH_FCS_LEN + vlan_bytes;
 
-	/*
-	 * Limit the MTU to make sure the ethernet packets are between
-	 * 64 bytes and 65535 bytes.
-	 */
-	if ((new_mtu + mtu_overhead < VLAN_ETH_ZLEN) ||
-	    (new_mtu + mtu_overhead > OCTEON_MAX_MTU)) {
-		pr_err("MTU must be between %d and %d.\n",
-		       VLAN_ETH_ZLEN - mtu_overhead,
-		       OCTEON_MAX_MTU - mtu_overhead);
-		return -EINVAL;
-	}
 	dev->mtu = new_mtu;
 
 	if ((interface < 2) &&
@@ -457,7 +446,7 @@ int cvm_oct_common_init(struct net_device *dev)
 	dev->ethtool_ops = &cvm_oct_ethtool_ops;
 
 	cvm_oct_set_mac_filter(dev);
-	dev->netdev_ops->ndo_change_mtu(dev, dev->mtu);
+	dev_set_mtu(dev, dev->mtu);
 
 	/*
 	 * Zero out stats for port so we won't mistakenly show
@@ -685,6 +674,11 @@ static int cvm_oct_probe(struct platform_device *pdev)
 	int fau = FAU_NUM_PACKET_BUFFERS_TO_FREE;
 	int qos;
 	struct device_node *pip;
+	int mtu_overhead = ETH_HLEN + ETH_FCS_LEN;
+
+#if IS_ENABLED(CONFIG_VLAN_8021Q)
+	mtu_overhead += VLAN_HLEN;
+#endif
 
 	octeon_mdiobus_force_mod_depencency();
 
@@ -783,6 +777,8 @@ static int cvm_oct_probe(struct platform_device *pdev)
 			strcpy(dev->name, "pow%d");
 			for (qos = 0; qos < 16; qos++)
 				skb_queue_head_init(&priv->tx_free_list[qos]);
+			dev->min_mtu = VLAN_ETH_ZLEN - mtu_overhead;
+			dev->max_mtu = OCTEON_MAX_MTU - mtu_overhead;
 
 			if (register_netdev(dev) < 0) {
 				pr_err("Failed to register ethernet device for POW\n");
@@ -836,6 +832,8 @@ static int cvm_oct_probe(struct platform_device *pdev)
 			for (qos = 0; qos < cvmx_pko_get_num_queues(port);
 			     qos++)
 				cvmx_fau_atomic_write32(priv->fau + qos * 4, 0);
+			dev->min_mtu = VLAN_ETH_ZLEN - mtu_overhead;
+			dev->max_mtu = OCTEON_MAX_MTU - mtu_overhead;
 
 			switch (priv->imode) {
 			/* These types don't support ports to IPD/PKO */
-- 
2.10.0
