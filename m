From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 4/4] stmmac: Fix simple style problem
Date: Wed,  9 Sep 2015 15:14:16 +0200
Message-ID: <1441804456-15914-4-git-send-email-clabbe.montjoie@gmail.com>
References: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441804456-15914-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix the following warnings:
- braces {} should be used on all arms of this statement
- Prefer seq_puts to seq_printf
- No space is necessary after a cast
- Missing a blank line after declarations
- Please don't use multiple blank lines
- Comparison to NULL could be written
- networking block comments don't use an empty /* line
- Do not include the paragraph about writing to the Free Software

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 74 +++++++++++------------
 1 file changed, 35 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 5335bad..3ba95a7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -13,10 +13,6 @@
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
-  You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc.,
-  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
-
   The full GNU General Public License is included in this distribution in
   the file called "COPYING".
 
@@ -197,7 +193,7 @@ static void print_pkt(unsigned char *buf, int len)
 }
 
 /* minimum number of free TX descriptors required to wake up TX process */
-#define STMMAC_TX_THRESH(x)	(x->dma_tx_size/4)
+#define STMMAC_TX_THRESH(x)	(x->dma_tx_size / 4)
 
 static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 {
@@ -207,7 +203,7 @@ static inline u32 stmmac_tx_avail(struct stmmac_priv *priv)
 /**
  * stmmac_hw_fix_mac_speed - callback for speed selection
  * @priv: driver private structure
- * Description: on some platforms (e.g. ST), some HW system configuraton
+ * Description: on some platforms (e.g. ST), some HW system configuration
  * registers have to be set according to the link speed negotiated.
  */
 static inline void stmmac_hw_fix_mac_speed(struct stmmac_priv *priv)
@@ -371,8 +367,6 @@ static void stmmac_get_tx_hwtstamp(struct stmmac_priv *priv,
 	shhwtstamp.hwtstamp = ns_to_ktime(ns);
 	/* pass tstamp to stack */
 	skb_tstamp_tx(skb, &shhwtstamp);
-
-	return;
 }
 
 /* stmmac_get_rx_hwtstamp - get HW RX timestamps
@@ -615,7 +609,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		 * 2^x * y == (y << x), hence
 		 * 2^32 * 50000000 ==> (50000000 << 32)
 		 */
-		temp = (u64) (50000000ULL << 32);
+		temp = (u64)(50000000ULL << 32);
 		priv->default_addend = div_u64(temp, priv->clk_ptp_rate);
 		priv->hw->ptp->config_addend(priv->ioaddr,
 					     priv->default_addend);
@@ -693,7 +687,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 	int new_state = 0;
 	unsigned int fc = priv->flow_ctrl, pause_time = priv->pause;
 
-	if (phydev == NULL)
+	if (!phydev)
 		return;
 
 	spin_lock_irqsave(&priv->lock, flags);
@@ -702,7 +696,8 @@ static void stmmac_adjust_link(struct net_device *dev)
 		u32 ctrl = readl(priv->ioaddr + MAC_CTRL_REG);
 
 		/* Now we make sure that we can be in full duplex mode.
-		 * If not, we operate in half-duplex mode. */
+		 * If not, we operate in half-duplex mode.
+		 */
 		if (phydev->duplex != priv->oldduplex) {
 			new_state = 1;
 			if (!(phydev->duplex))
@@ -728,11 +723,10 @@ static void stmmac_adjust_link(struct net_device *dev)
 			case 10:
 				if (priv->plat->has_gmac) {
 					ctrl |= priv->hw->link.port;
-					if (phydev->speed == SPEED_100) {
+					if (phydev->speed == SPEED_100)
 						ctrl |= priv->hw->link.speed;
-					} else {
+					else
 						ctrl &= ~(priv->hw->link.speed);
-					}
 				} else {
 					ctrl &= ~priv->hw->link.port;
 				}
@@ -814,6 +808,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	char bus_id[MII_BUS_ID_SIZE];
 	int interface = priv->plat->interface;
 	int max_speed = priv->plat->max_speed;
+
 	priv->oldlink = 0;
 	priv->speed = 0;
 	priv->oldduplex = -1;
@@ -851,8 +846,7 @@ static int stmmac_init_phy(struct net_device *dev)
 		phydev->advertising &= ~(SUPPORTED_1000baseT_Half |
 					 SUPPORTED_1000baseT_Full);
 
-	/*
-	 * Broken HW is sometimes missing the pull-up resistor on the
+	/* Broken HW is sometimes missing the pull-up resistor on the
 	 * MDIO line, which results in reads to non-existent devices returning
 	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
 	 * device as well.
@@ -882,18 +876,18 @@ static void stmmac_display_ring(void *head, int size, int extend_desc)
 	int i;
 	struct dma_extended_desc *ep = (struct dma_extended_desc *)head;
 	struct dma_desc *p = (struct dma_desc *)head;
+	u64 x;
 
 	for (i = 0; i < size; i++) {
-		u64 x;
 		if (extend_desc) {
-			x = *(u64 *) ep;
+			x = *(u64 *)ep;
 			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				i, (unsigned int)virt_to_phys(ep),
 				(unsigned int)x, (unsigned int)(x >> 32),
 				ep->basic.des2, ep->basic.des3);
 			ep++;
 		} else {
-			x = *(u64 *) p;
+			x = *(u64 *)p;
 			pr_info("%d [0x%x]: 0x%x 0x%x 0x%x 0x%x",
 				i, (unsigned int)virt_to_phys(p),
 				(unsigned int)x, (unsigned int)(x >> 32),
@@ -1058,6 +1052,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 	}
 	for (i = 0; i < rxsize; i++) {
 		struct dma_desc *p;
+
 		if (priv->extend_desc)
 			p = &((priv->dma_erx + i)->basic);
 		else
@@ -1095,6 +1090,7 @@ static int init_dma_desc_rings(struct net_device *dev, gfp_t flags)
 	/* TX INITIALIZATION */
 	for (i = 0; i < txsize; i++) {
 		struct dma_desc *p;
+
 		if (priv->extend_desc)
 			p = &((priv->dma_etx + i)->basic);
 		else
@@ -1154,7 +1150,7 @@ static void dma_free_tx_skbufs(struct stmmac_priv *priv)
 						 DMA_TO_DEVICE);
 		}
 
-		if (priv->tx_skbuff[i] != NULL) {
+		if (priv->tx_skbuff[i]) {
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
 			priv->tx_skbuff[i] = NULL;
 			priv->tx_skbuff_dma[i].buf = 0;
@@ -1292,8 +1288,7 @@ static void stmmac_dma_operation_mode(struct stmmac_priv *priv)
 	if (priv->plat->force_thresh_dma_mode)
 		priv->hw->dma->dma_mode(priv->ioaddr, tc, tc, rxfifosz);
 	else if (priv->plat->force_sf_dma_mode || priv->plat->tx_coe) {
-		/*
-		 * In case of GMAC, SF mode can be enabled
+		/* In case of GMAC, SF mode can be enabled
 		 * to perform the TX COE in HW. This depends on:
 		 * 1) TX COE if actually supported
 		 * 2) There is no bugged Jumbo frame support
@@ -1371,7 +1366,7 @@ static void stmmac_tx_clean(struct stmmac_priv *priv)
 		}
 		priv->hw->mode->clean_desc3(priv, p);
 
-		if (likely(skb != NULL)) {
+		if (likely(skb)) {
 			pkts_compl++;
 			bytes_compl += skb->len;
 			dev_consume_skb_any(skb);
@@ -1425,6 +1420,7 @@ static void stmmac_tx_err(struct stmmac_priv *priv)
 {
 	int i;
 	int txsize = priv->dma_tx_size;
+
 	netif_stop_queue(priv->dev);
 
 	priv->hw->dma->stop_tx(priv->ioaddr);
@@ -2113,7 +2109,6 @@ static void stmmac_rx_vlan(struct net_device *dev, struct sk_buff *skb)
 	}
 }
 
-
 /**
  * stmmac_rx_refill - refill used skb preallocated buffers
  * @priv: driver private structure
@@ -2134,12 +2129,12 @@ static inline void stmmac_rx_refill(struct stmmac_priv *priv)
 		else
 			p = priv->dma_rx + entry;
 
-		if (likely(priv->rx_skbuff[entry] == NULL)) {
+		if (likely(!priv->rx_skbuff[entry])) {
 			struct sk_buff *skb;
 
 			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
 
-			if (unlikely(skb == NULL))
+			if (unlikely(!skb))
 				break;
 
 			priv->rx_skbuff[entry] = skb;
@@ -2535,25 +2530,25 @@ static void sysfs_display_ring(void *head, int size, int extend_desc,
 	int i;
 	struct dma_extended_desc *ep = (struct dma_extended_desc *)head;
 	struct dma_desc *p = (struct dma_desc *)head;
+	u64 x;
 
 	for (i = 0; i < size; i++) {
-		u64 x;
 		if (extend_desc) {
-			x = *(u64 *) ep;
+			x = *(u64 *)ep;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
 				   (unsigned int)x, (unsigned int)(x >> 32),
 				   ep->basic.des2, ep->basic.des3);
 			ep++;
 		} else {
-			x = *(u64 *) p;
+			x = *(u64 *)p;
 			seq_printf(seq, "%d [0x%x]: 0x%x 0x%x 0x%x 0x%x\n",
 				   i, (unsigned int)virt_to_phys(ep),
 				   (unsigned int)x, (unsigned int)(x >> 32),
 				   p->des2, p->des3);
 			p++;
 		}
-		seq_printf(seq, "\n");
+		seq_puts(seq, "\n");
 	}
 }
 
@@ -2565,14 +2560,14 @@ static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
 	unsigned int rxsize = priv->dma_rx_size;
 
 	if (priv->extend_desc) {
-		seq_printf(seq, "Extended RX descriptor ring:\n");
+		seq_puts(seq, "Extended RX descriptor ring:\n");
 		sysfs_display_ring((void *)priv->dma_erx, rxsize, 1, seq);
-		seq_printf(seq, "Extended TX descriptor ring:\n");
+		seq_puts(seq, "Extended TX descriptor ring:\n");
 		sysfs_display_ring((void *)priv->dma_etx, txsize, 1, seq);
 	} else {
-		seq_printf(seq, "RX descriptor ring:\n");
+		seq_puts(seq, "RX descriptor ring:\n");
 		sysfs_display_ring((void *)priv->dma_rx, rxsize, 0, seq);
-		seq_printf(seq, "TX descriptor ring:\n");
+		seq_puts(seq, "TX descriptor ring:\n");
 		sysfs_display_ring((void *)priv->dma_tx, txsize, 0, seq);
 	}
 
@@ -2598,13 +2593,13 @@ static int stmmac_sysfs_dma_cap_read(struct seq_file *seq, void *v)
 	struct stmmac_priv *priv = netdev_priv(dev);
 
 	if (!priv->hw_cap_support) {
-		seq_printf(seq, "DMA HW features not supported\n");
+		seq_puts(seq, "DMA HW features not supported\n");
 		return 0;
 	}
 
-	seq_printf(seq, "==============================\n");
-	seq_printf(seq, "\tDMA HW features\n");
-	seq_printf(seq, "==============================\n");
+	seq_puts(seq, "==============================\n");
+	seq_puts(seq, "\tDMA HW features\n");
+	seq_puts(seq, "==============================\n");
 
 	seq_printf(seq, "\t10/100 Mbps %s\n",
 		   (priv->dma_cap.mbps_10_100) ? "Y" : "N");
@@ -2793,8 +2788,9 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
 		else if (priv->dma_cap.rx_coe_type1)
 			priv->plat->rx_coe = STMMAC_RX_COE_TYPE1;
 
-	} else
+	} else {
 		dev_info(priv->device, "No HW DMA feature register supported\n");
+	}
 
 	/* To use alternate (extended) or normal descriptor structures */
 	stmmac_selec_desc_mode(priv);
-- 
2.4.6
