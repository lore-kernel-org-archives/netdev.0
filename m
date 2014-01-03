From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] sh_eth: coding style fixes
Date: Fri, 3 Jan 2014 15:52:22 +0300
Message-ID: <201401031552.22847.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Running 'scripts/checkpatch.pl' on the driver files gives numerous warnings:

- block comments using empty /* line;

- unneeded \ at end of lines;

- message string split across lines;

- use of __attribute__((aligned(n))) instead of __aligned(n) macro;

- use of __attribute__((packed)) instead of __packed macro.

Additionally, running 'scripts/checkpatch.pl --strict' gives more complaints:

- including the paragraph about writing to FSF into the heading comment;

- alignment not matching open paren;

- multiple assignments on one line;

- use of CamelCase names;

- missing {} on one of the *if* arms where another has them;

- spinlock definition without a comment.

While fixing these, also do some more style cleanups:

- remove useless () around expressions;

- add {} around multi-line *if* operator's arm;

- remove space before comma;

- add spaces after /* and before */;

- properly align continuation lines of broken up expressions;

- realign comments to the structure fields.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against DaveM's 'net-next.git' repo.

Changes in version 2:
- added missing comma and {} in/around dev_err() call in sh_eth_tx_timeout();

 drivers/net/ethernet/renesas/sh_eth.c |  110 ++++++++++++++++------------------
 drivers/net/ethernet/renesas/sh_eth.h |   53 +++++++---------
 2 files changed, 75 insertions(+), 88 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1,5 +1,4 @@
-/*
- *  SuperH Ethernet device driver
+/*  SuperH Ethernet device driver
  *
  *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2013 Renesas Solutions Corp.
@@ -13,9 +12,6 @@
  *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  *  more details.
- *  You should have received a copy of the GNU General Public License along with
- *  this program; if not, write to the Free Software Foundation, Inc.,
- *  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
  *
  *  The full GNU General Public License is included in this distribution in
  *  the file called "COPYING".
@@ -646,8 +642,8 @@ static struct sh_eth_cpu_data sh7763_dat
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 
 	.tx_check	= EESR_TC1 | EESR_FTC,
-	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT | \
-			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE | \
+	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
+			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 			  EESR_ECI,
 
 	.apr		= 1,
@@ -732,7 +728,7 @@ static void sh_eth_set_default_cpu_data(
 		cd->ecsipr_value = DEFAULT_ECSIPR_INIT;
 
 	if (!cd->fcftr_value)
-		cd->fcftr_value = DEFAULT_FIFO_F_D_RFF | \
+		cd->fcftr_value = DEFAULT_FIFO_F_D_RFF |
 				  DEFAULT_FIFO_F_D_RFD;
 
 	if (!cd->fdr_value)
@@ -849,20 +845,17 @@ static inline __u32 edmac_to_cpu(struct 
 	return x;
 }
 
-/*
- * Program the hardware MAC address from dev->dev_addr.
- */
+/* Program the hardware MAC address from dev->dev_addr. */
 static void update_mac_address(struct net_device *ndev)
 {
 	sh_eth_write(ndev,
-		(ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
-		(ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]), MAHR);
+		     (ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
+		     (ndev->dev_addr[2] << 8) | (ndev->dev_addr[3]), MAHR);
 	sh_eth_write(ndev,
-		(ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]), MALR);
+		     (ndev->dev_addr[4] << 8) | (ndev->dev_addr[5]), MALR);
 }
 
-/*
- * Get MAC address from SuperH MAC address register
+/* Get MAC address from SuperH MAC address register
  *
  * SuperH's Ethernet device doesn't have 'ROM' to MAC address.
  * This driver get MAC address that use by bootloader(U-boot or sh-ipl+g).
@@ -1019,8 +1012,10 @@ static void sh_eth_ring_format(struct ne
 	int rx_ringsize = sizeof(*rxdesc) * mdp->num_rx_ring;
 	int tx_ringsize = sizeof(*txdesc) * mdp->num_tx_ring;
 
-	mdp->cur_rx = mdp->cur_tx = 0;
-	mdp->dirty_rx = mdp->dirty_tx = 0;
+	mdp->cur_rx = 0;
+	mdp->cur_tx = 0;
+	mdp->dirty_rx = 0;
+	mdp->dirty_tx = 0;
 
 	memset(mdp->rx_ring, 0, rx_ringsize);
 
@@ -1033,7 +1028,7 @@ static void sh_eth_ring_format(struct ne
 		if (skb == NULL)
 			break;
 		dma_map_single(&ndev->dev, skb->data, mdp->rx_buf_sz,
-				DMA_FROM_DEVICE);
+			       DMA_FROM_DEVICE);
 		sh_eth_set_receive_align(skb);
 
 		/* RX descriptor */
@@ -1081,8 +1076,7 @@ static int sh_eth_ring_init(struct net_d
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int rx_ringsize, tx_ringsize, ret = 0;
 
-	/*
-	 * +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
+	/* +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
 	 * card needs room to do 8 byte alignment, +2 so we can reserve
 	 * the first 2 bytes, and +16 gets room for the status word from the
 	 * card.
@@ -1257,7 +1251,7 @@ static int sh_eth_txfree(struct net_devi
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct sh_eth_txdesc *txdesc;
-	int freeNum = 0;
+	int free_num = 0;
 	int entry = 0;
 
 	for (; mdp->cur_tx - mdp->dirty_tx > 0; mdp->dirty_tx++) {
@@ -1271,7 +1265,7 @@ static int sh_eth_txfree(struct net_devi
 					 txdesc->buffer_length, DMA_TO_DEVICE);
 			dev_kfree_skb_irq(mdp->tx_skbuff[entry]);
 			mdp->tx_skbuff[entry] = NULL;
-			freeNum++;
+			free_num++;
 		}
 		txdesc->status = cpu_to_edmac(mdp, TD_TFP);
 		if (entry >= mdp->num_tx_ring - 1)
@@ -1280,7 +1274,7 @@ static int sh_eth_txfree(struct net_devi
 		ndev->stats.tx_packets++;
 		ndev->stats.tx_bytes += txdesc->buffer_length;
 	}
-	return freeNum;
+	return free_num;
 }
 
 /* Packet receive function */
@@ -1313,8 +1307,7 @@ static int sh_eth_rx(struct net_device *
 		if (!(desc_status & RDFEND))
 			ndev->stats.rx_length_errors++;
 
-		/*
-		 * In case of almost all GETHER/ETHERs, the Receive Frame State
+		/* In case of almost all GETHER/ETHERs, the Receive Frame State
 		 * (RFS) bits in the Receive Descriptor 0 are from bit 9 to
 		 * bit 0. However, in case of the R8A7740's GETHER, the RFS
 		 * bits are from bit 25 to bit 16. So, the driver needs right
@@ -1374,7 +1367,7 @@ static int sh_eth_rx(struct net_device *
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			dma_map_single(&ndev->dev, skb->data, mdp->rx_buf_sz,
-					DMA_FROM_DEVICE);
+				       DMA_FROM_DEVICE);
 			sh_eth_set_receive_align(skb);
 
 			skb_checksum_none_assert(skb);
@@ -1392,10 +1385,13 @@ static int sh_eth_rx(struct net_device *
 	/* If we don't need to check status, don't. -KDU */
 	if (!(sh_eth_read(ndev, EDRRR) & EDRRR_R)) {
 		/* fix the values for the next receiving if RDE is set */
-		if (intr_status & EESR_RDE)
-			mdp->cur_rx = mdp->dirty_rx =
-				(sh_eth_read(ndev, RDFAR) -
-				 sh_eth_read(ndev, RDLAR)) >> 4;
+		if (intr_status & EESR_RDE) {
+			u32 count = (sh_eth_read(ndev, RDFAR) -
+				     sh_eth_read(ndev, RDLAR)) >> 4;
+
+			mdp->cur_rx = count;
+			mdp->dirty_rx = count;
+		}
 		sh_eth_write(ndev, EDRRR_R, EDRRR);
 	}
 
@@ -1438,17 +1434,17 @@ static void sh_eth_error(struct net_devi
 				if (mdp->ether_link_active_low)
 					link_stat = ~link_stat;
 			}
-			if (!(link_stat & PHY_ST_LINK))
+			if (!(link_stat & PHY_ST_LINK)) {
 				sh_eth_rcv_snd_disable(ndev);
-			else {
+			} else {
 				/* Link Up */
 				sh_eth_write(ndev, sh_eth_read(ndev, EESIPR) &
-					  ~DMAC_M_ECI, EESIPR);
-				/*clear int */
+						   ~DMAC_M_ECI, EESIPR);
+				/* clear int */
 				sh_eth_write(ndev, sh_eth_read(ndev, ECSR),
-					  ECSR);
+					     ECSR);
 				sh_eth_write(ndev, sh_eth_read(ndev, EESIPR) |
-					  DMAC_M_ECI, EESIPR);
+						   DMAC_M_ECI, EESIPR);
 				/* enable tx and rx */
 				sh_eth_rcv_snd_enable(ndev);
 			}
@@ -1519,9 +1515,9 @@ ignore_link:
 		u32 edtrr = sh_eth_read(ndev, EDTRR);
 		/* dmesg */
 		dev_err(&ndev->dev, "TX error. status=%8.8x cur_tx=%8.8x ",
-				intr_status, mdp->cur_tx);
+			intr_status, mdp->cur_tx);
 		dev_err(&ndev->dev, "dirty_tx=%8.8x state=%8.8x EDTRR=%8.8x.\n",
-				mdp->dirty_tx, (u32) ndev->state, edtrr);
+			mdp->dirty_tx, (u32) ndev->state, edtrr);
 		/* dirty buffer free */
 		sh_eth_txfree(ndev);
 
@@ -1644,7 +1640,8 @@ static void sh_eth_adjust_link(struct ne
 		}
 		if (!mdp->link) {
 			sh_eth_write(ndev,
-				(sh_eth_read(ndev, ECMR) & ~ECMR_TXF), ECMR);
+				     sh_eth_read(ndev, ECMR) & ~ECMR_TXF,
+				     ECMR);
 			new_state = 1;
 			mdp->link = phydev->link;
 			if (mdp->cd->no_psr || mdp->no_ether_link)
@@ -1671,7 +1668,7 @@ static int sh_eth_phy_init(struct net_de
 	struct phy_device *phydev = NULL;
 
 	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
-		mdp->mii_bus->id , mdp->phy_id);
+		 mdp->mii_bus->id, mdp->phy_id);
 
 	mdp->link = 0;
 	mdp->speed = 0;
@@ -1709,7 +1706,7 @@ static int sh_eth_phy_start(struct net_d
 }
 
 static int sh_eth_get_settings(struct net_device *ndev,
-			struct ethtool_cmd *ecmd)
+			       struct ethtool_cmd *ecmd)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	unsigned long flags;
@@ -1723,7 +1720,7 @@ static int sh_eth_get_settings(struct ne
 }
 
 static int sh_eth_set_settings(struct net_device *ndev,
-		struct ethtool_cmd *ecmd)
+			       struct ethtool_cmd *ecmd)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	unsigned long flags;
@@ -1799,7 +1796,7 @@ static int sh_eth_get_sset_count(struct 
 }
 
 static void sh_eth_get_ethtool_stats(struct net_device *ndev,
-			struct ethtool_stats *stats, u64 *data)
+				     struct ethtool_stats *stats, u64 *data)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	int i = 0;
@@ -1816,7 +1813,7 @@ static void sh_eth_get_strings(struct ne
 	switch (stringset) {
 	case ETH_SS_STATS:
 		memcpy(data, *sh_eth_gstrings_stats,
-					sizeof(sh_eth_gstrings_stats));
+		       sizeof(sh_eth_gstrings_stats));
 		break;
 	}
 }
@@ -1951,9 +1948,10 @@ static void sh_eth_tx_timeout(struct net
 
 	netif_stop_queue(ndev);
 
-	if (netif_msg_timer(mdp))
-		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x,"
-	       " resetting...\n", ndev->name, (int)sh_eth_read(ndev, EESR));
+	if (netif_msg_timer(mdp)) {
+		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x, resetting...\n",
+			ndev->name, (int)sh_eth_read(ndev, EESR));
+	}
 
 	/* tx_errors count up */
 	ndev->stats.tx_errors++;
@@ -2086,8 +2084,7 @@ static struct net_device_stats *sh_eth_g
 }
 
 /* ioctl to device function */
-static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
-				int cmd)
+static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	struct phy_device *phydev = mdp->phydev;
@@ -2342,8 +2339,7 @@ static void sh_eth_set_multicast_list(st
 	unsigned long flags;
 
 	spin_lock_irqsave(&mdp->lock, flags);
-	/*
-	 * Initial condition is MCT = 1, PRM = 0.
+	/* Initial condition is MCT = 1, PRM = 0.
 	 * Depending on ndev->flags, set PRM or clear MCT
 	 */
 	ecmr_bits = (sh_eth_read(ndev, ECMR) & ~ECMR_PRM) | ECMR_MCT;
@@ -2409,8 +2405,7 @@ static int sh_eth_vlan_rx_add_vid(struct
 
 	mdp->vlan_num_ids++;
 
-	/*
-	 * The controller has one VLAN tag HW filter. So, if the filter is
+	/* The controller has one VLAN tag HW filter. So, if the filter is
 	 * already enabled, the driver disables it and the filte
 	 */
 	if (mdp->vlan_num_ids > 1) {
@@ -2526,7 +2521,7 @@ static int sh_mdio_init(struct net_devic
 	mdp->mii_bus->name = "sh_mii";
 	mdp->mii_bus->parent = &ndev->dev;
 	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
-		mdp->pdev->name, id);
+		 mdp->pdev->name, id);
 
 	/* PHY IRQ */
 	mdp->mii_bus->irq = devm_kzalloc(&ndev->dev,
@@ -2739,7 +2734,7 @@ static int sh_eth_drv_probe(struct platf
 
 	/* print device information */
 	pr_info("Base address at 0x%x, %pM, IRQ %d.\n",
-	       (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
+		(u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
 
 	platform_set_drvdata(pdev, ndev);
 
@@ -2777,8 +2772,7 @@ static int sh_eth_drv_remove(struct plat
 #ifdef CONFIG_PM
 static int sh_eth_runtime_nop(struct device *dev)
 {
-	/*
-	 * Runtime PM callback shared between ->runtime_suspend()
+	/* Runtime PM callback shared between ->runtime_suspend()
 	 * and ->runtime_resume(). Simply returns success.
 	 *
 	 * This driver re-initializes all registers after
Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -1,5 +1,4 @@
-/*
- *  SuperH Ethernet device driver
+/*  SuperH Ethernet device driver
  *
  *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
  *  Copyright (C) 2008-2012 Renesas Solutions Corp.
@@ -12,9 +11,6 @@
  *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  *  more details.
- *  You should have received a copy of the GNU General Public License along with
- *  this program; if not, write to the Free Software Foundation, Inc.,
- *  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
  *
  *  The full GNU General Public License is included in this distribution in
  *  the file called "COPYING".
@@ -171,8 +167,7 @@ enum {
 #define SH2_SH3_SKB_RX_ALIGN	2
 #endif
 
-/*
- * Register's bits
+/* Register's bits
  */
 /* EDSR : sh7734, sh7757, sh7763, and r8a7740 only */
 enum EDSR_BIT {
@@ -199,7 +194,7 @@ enum DMAC_T_BIT {
 	EDTRR_TRNS_ETHER = 0x01,
 };
 
-/* EDRRR*/
+/* EDRRR */
 enum EDRRR_R_BIT {
 	EDRRR_R = 0x01,
 };
@@ -422,8 +417,7 @@ enum TSU_FWSLC_BIT {
 #define TSU_VTAG_ENABLE		0x80000000
 #define TSU_VTAG_VID_MASK	0x00000fff
 
-/*
- * The sh ether Tx buffer descriptors.
+/* The sh ether Tx buffer descriptors.
  * This structure should be 20 bytes.
  */
 struct sh_eth_txdesc {
@@ -437,10 +431,9 @@ struct sh_eth_txdesc {
 #endif
 	u32 addr;		/* TD2 */
 	u32 pad1;		/* padding data */
-} __attribute__((aligned(2), packed));
+} __aligned(2) __packed;
 
-/*
- * The sh ether Rx buffer descriptors.
+/* The sh ether Rx buffer descriptors.
  * This structure should be 20 bytes.
  */
 struct sh_eth_rxdesc {
@@ -454,7 +447,7 @@ struct sh_eth_rxdesc {
 #endif
 	u32 addr;		/* RD2 */
 	u32 pad0;		/* padding data */
-} __attribute__((aligned(2), packed));
+} __aligned(2) __packed;
 
 /* This structure is used by each CPU dependency handling. */
 struct sh_eth_cpu_data {
@@ -480,16 +473,16 @@ struct sh_eth_cpu_data {
 	unsigned long eesr_err_check;
 
 	/* hardware features */
-	unsigned long irq_flags;	/* IRQ configuration flags */
-	unsigned no_psr:1;		/* EtherC DO NOT have PSR */
-	unsigned apr:1;			/* EtherC have APR */
-	unsigned mpr:1;			/* EtherC have MPR */
-	unsigned tpauser:1;		/* EtherC have TPAUSER */
-	unsigned bculr:1;		/* EtherC have BCULR */
-	unsigned tsu:1;			/* EtherC have TSU */
-	unsigned hw_swap:1;		/* E-DMAC have DE bit in EDMR */
-	unsigned rpadir:1;		/* E-DMAC have RPADIR */
-	unsigned no_trimd:1;		/* E-DMAC DO NOT have TRIMD */
+	unsigned long irq_flags; /* IRQ configuration flags */
+	unsigned no_psr:1;	/* EtherC DO NOT have PSR */
+	unsigned apr:1;		/* EtherC have APR */
+	unsigned mpr:1;		/* EtherC have MPR */
+	unsigned tpauser:1;	/* EtherC have TPAUSER */
+	unsigned bculr:1;	/* EtherC have BCULR */
+	unsigned tsu:1;		/* EtherC have TSU */
+	unsigned hw_swap:1;	/* E-DMAC have DE bit in EDMR */
+	unsigned rpadir:1;	/* E-DMAC have RPADIR */
+	unsigned no_trimd:1;	/* E-DMAC DO NOT have TRIMD */
 	unsigned no_ade:1;	/* E-DMAC DO NOT have ADE bit in EESR */
 	unsigned hw_crc:1;	/* E-DMAC have CSMR */
 	unsigned select_mii:1;	/* EtherC have RMII_MII (MII select register) */
@@ -511,14 +504,14 @@ struct sh_eth_private {
 	struct sh_eth_txdesc *tx_ring;
 	struct sk_buff **rx_skbuff;
 	struct sk_buff **tx_skbuff;
-	spinlock_t lock;
-	u32 cur_rx, dirty_rx;	/* Producer/consumer ring indices */
+	spinlock_t lock;		/* Register access lock */
+	u32 cur_rx, dirty_rx;		/* Producer/consumer ring indices */
 	u32 cur_tx, dirty_tx;
-	u32 rx_buf_sz;		/* Based on MTU+slack. */
+	u32 rx_buf_sz;			/* Based on MTU+slack. */
 	int edmac_endian;
 	struct napi_struct napi;
 	/* MII transceiver section. */
-	u32 phy_id;					/* PHY ID */
+	u32 phy_id;			/* PHY ID */
 	struct mii_bus *mii_bus;	/* MDIO bus control */
 	struct phy_device *phydev;	/* PHY device control */
 	int link;
@@ -526,8 +519,8 @@ struct sh_eth_private {
 	int msg_enable;
 	int speed;
 	int duplex;
-	int port;		/* for TSU */
-	int vlan_num_ids;	/* for VLAN tag filter */
+	int port;			/* for TSU */
+	int vlan_num_ids;		/* for VLAN tag filter */
 
 	unsigned no_ether_link:1;
 	unsigned ether_link_active_low:1;
