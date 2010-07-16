From: Joseph Kogut <joseph.kogut@gmail.com>
Subject: [PATCH] Drivers: net: 8139cp: Improved conformance to the Linux coding style guidelines.
Date: Fri, 16 Jul 2010 06:19:51 -0700
Message-ID: <1279286391-31464-1-git-send-email-joseph.kogut@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joseph Kogut <joseph.kogut@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed several issues that made the 8139C+ driver nonconformant to the Linux coding style guidelines.

Signed-off-by: Joseph Kogut <joseph.kogut@gmail.com>
---
 drivers/net/8139cp.c |  304 +++++++++++++++++++++++++-------------------------
 1 files changed, 153 insertions(+), 151 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 284a5f4..b91a508 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -2,12 +2,12 @@
 /*
 	Copyright 2001-2004 Jeff Garzik <jgarzik@pobox.com>
 
-	Copyright (C) 2001, 2002 David S. Miller (davem@redhat.com) [tg3.c]
-	Copyright (C) 2000, 2001 David S. Miller (davem@redhat.com) [sungem.c]
-	Copyright 2001 Manfred Spraul				    [natsemi.c]
-	Copyright 1999-2001 by Donald Becker.			    [natsemi.c]
-       	Written 1997-2001 by Donald Becker.			    [8139too.c]
-	Copyright 1998-2001 by Jes Sorensen, <jes@trained-monkey.org>. [acenic.c]
+	Copyright (C) 2001, 2002 David S. Miller (davem@redhat.com)	[tg3.c]
+	Copyright (C) 2000, 2001 David S. Miller (davem@redhat.com)	[sungem.c]
+	Copyright 2001 Manfred Spraul					[natsemi.c]
+	Copyright 1999-2001 by Donald Becker.				[natsemi.c]
+	Written 1997-2001 by Donald Becker.				[8139too.c]
+	Copyright 1998-2001 by Jes Sorensen, <jes@trained-monkey.org>.	[acenic.c]
 
 	This software may be used and distributed according to the terms of
 	the GNU General Public License (GPL), incorporated herein by reference.
@@ -73,18 +73,18 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/cache.h>
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
+#include <linux/io.h>
+#include <linux/irq.h>
+#include <linux/uaccess.h>
 
 /* VLAN tagging feature enable/disable */
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define CP_VLAN_TAG_USED 1
-#define CP_VLAN_TX_TAG(tx_desc,vlan_tag_value) \
+#define CP_VLAN_TX_TAG(tx_desc, vlan_tag_value) \
 	do { (tx_desc)->opts2 = cpu_to_le32(vlan_tag_value); } while (0)
 #else
 #define CP_VLAN_TAG_USED 0
-#define CP_VLAN_TX_TAG(tx_desc,vlan_tag_value) \
+#define CP_VLAN_TX_TAG(tx_desc, vlan_tag_value) \
 	do { (tx_desc)->opts2 = 0; } while (0)
 #endif
 
@@ -99,16 +99,16 @@ MODULE_LICENSE("GPL");
 
 static int debug = -1;
 module_param(debug, int, 0);
-MODULE_PARM_DESC (debug, "8139cp: bitmapped message enable number");
+MODULE_PARM_DESC(debug, "8139cp: bitmapped message enable number");
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC.  */
 static int multicast_filter_limit = 32;
 module_param(multicast_filter_limit, int, 0);
-MODULE_PARM_DESC (multicast_filter_limit, "8139cp: maximum number of filtered multicast addresses");
+MODULE_PARM_DESC(multicast_filter_limit, "8139cp: maximum number of filtered multicast addresses");
 
 #define CP_DEF_MSG_ENABLE	(NETIF_MSG_DRV		| \
-				 NETIF_MSG_PROBE 	| \
+				 NETIF_MSG_PROBE	| \
 				 NETIF_MSG_LINK)
 #define CP_NUM_STATS		14	/* struct cp_dma_stats, plus one */
 #define CP_STATS_SIZE		64	/* size in bytes of DMA stats block */
@@ -130,8 +130,8 @@ MODULE_PARM_DESC (multicast_filter_limit, "8139cp: maximum number of filtered mu
 #define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer.*/
 #define CP_INTERNAL_PHY		32
 
-/* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6==1024, 7==end of packet. */
-#define RX_FIFO_THRESH		5	/* Rx buffer level before first PCI xfer.  */
+/* The following settings are log_2(bytes)-4:  0 == 16 bytes .. 6 == 1024, 7 == end of packet. */
+#define RX_FIFO_THRESH		5	/* Rx buffer level before first PCI xfer. */
 #define RX_DMA_BURST		4	/* Maximum PCI burst, '4' is 256 */
 #define TX_DMA_BURST		6	/* Maximum PCI burst, '6' is 1024 */
 #define TX_EARLY_THRESH		256	/* Early Tx threshold, in bytes */
@@ -366,26 +366,26 @@ struct cp_private {
 #define cpr8(reg)	readb(cp->regs + (reg))
 #define cpr16(reg)	readw(cp->regs + (reg))
 #define cpr32(reg)	readl(cp->regs + (reg))
-#define cpw8(reg,val)	writeb((val), cp->regs + (reg))
-#define cpw16(reg,val)	writew((val), cp->regs + (reg))
-#define cpw32(reg,val)	writel((val), cp->regs + (reg))
-#define cpw8_f(reg,val) do {			\
+#define cpw8(reg, val)	writeb((val), cp->regs + (reg))
+#define cpw16(reg, val)	writew((val), cp->regs + (reg))
+#define cpw32(reg, val)	writel((val), cp->regs + (reg))
+#define cpw8_f(reg, val) do {			\
 	writeb((val), cp->regs + (reg));	\
 	readb(cp->regs + (reg));		\
 	} while (0)
-#define cpw16_f(reg,val) do {			\
+#define cpw16_f(reg, val) do {			\
 	writew((val), cp->regs + (reg));	\
 	readw(cp->regs + (reg));		\
 	} while (0)
-#define cpw32_f(reg,val) do {			\
+#define cpw32_f(reg, val) do {			\
 	writel((val), cp->regs + (reg));	\
 	readl(cp->regs + (reg));		\
 	} while (0)
 
 
-static void __cp_set_rx_mode (struct net_device *dev);
-static void cp_tx (struct cp_private *cp);
-static void cp_clean_rings (struct cp_private *cp);
+static void __cp_set_rx_mode(struct net_device *dev);
+static void cp_tx(struct cp_private *cp);
+static void cp_clean_rings(struct cp_private *cp);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cp_poll_controller(struct net_device *dev);
 #endif
@@ -440,7 +440,7 @@ static void cp_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 }
 #endif /* CP_VLAN_TAG_USED */
 
-static inline void cp_set_rxbufsize (struct cp_private *cp)
+static inline void cp_set_rxbufsize(struct cp_private *cp)
 {
 	unsigned int mtu = cp->dev->mtu;
 
@@ -451,10 +451,10 @@ static inline void cp_set_rxbufsize (struct cp_private *cp)
 		cp->rx_buf_sz = PKT_BUF_SZ;
 }
 
-static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
+static inline void cp_rx_skb(struct cp_private *cp, struct sk_buff *skb,
 			      struct cp_desc *desc)
 {
-	skb->protocol = eth_type_trans (skb, cp->dev);
+	skb->protocol = eth_type_trans(skb, cp->dev);
 
 	cp->dev->stats.rx_packets++;
 	cp->dev->stats.rx_bytes += skb->len;
@@ -468,7 +468,7 @@ static inline void cp_rx_skb (struct cp_private *cp, struct sk_buff *skb,
 		netif_receive_skb(skb);
 }
 
-static void cp_rx_err_acct (struct cp_private *cp, unsigned rx_tail,
+static void cp_rx_err_acct(struct cp_private *cp, unsigned rx_tail,
 			    u32 status, u32 len)
 {
 	netif_dbg(cp, rx_err, cp->dev, "rx err, slot %d status 0x%x len %d\n",
@@ -486,7 +486,7 @@ static void cp_rx_err_acct (struct cp_private *cp, unsigned rx_tail,
 		cp->dev->stats.rx_fifo_errors++;
 }
 
-static inline unsigned int cp_rx_csum_ok (u32 status)
+static inline unsigned int cp_rx_csum_ok(u32 status)
 {
 	unsigned int protocol = (status >> 16) & 0x3;
 
@@ -606,7 +606,7 @@ rx_next:
 	return rx;
 }
 
-static irqreturn_t cp_interrupt (int irq, void *dev_instance)
+static irqreturn_t cp_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct cp_private *cp;
@@ -674,7 +674,7 @@ static void cp_poll_controller(struct net_device *dev)
 }
 #endif
 
-static void cp_tx (struct cp_private *cp)
+static void cp_tx(struct cp_private *cp)
 {
 	unsigned tx_head = cp->tx_head;
 	unsigned tx_tail = cp->tx_tail;
@@ -731,7 +731,7 @@ static void cp_tx (struct cp_private *cp)
 		netif_wake_queue(cp->dev);
 }
 
-static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
+static netdev_tx_t cp_start_xmit(struct sk_buff *skb,
 					struct net_device *dev)
 {
 	struct cp_private *cp = netdev_priv(dev);
@@ -889,7 +889,7 @@ static netdev_tx_t cp_start_xmit (struct sk_buff *skb,
 /* Set or clear the multicast filter for this adaptor.
    This routine is not state sensitive and need not be SMP locked. */
 
-static void __cp_set_rx_mode (struct net_device *dev)
+static void __cp_set_rx_mode(struct net_device *dev)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	u32 mc_filter[2];	/* Multicast hash filter */
@@ -923,28 +923,28 @@ static void __cp_set_rx_mode (struct net_device *dev)
 	/* We can safely update without stopping the chip. */
 	tmp = cp_rx_config | rx_mode;
 	if (cp->rx_config != tmp) {
-		cpw32_f (RxConfig, tmp);
+		cpw32_f(RxConfig, tmp);
 		cp->rx_config = tmp;
 	}
-	cpw32_f (MAR0 + 0, mc_filter[0]);
-	cpw32_f (MAR0 + 4, mc_filter[1]);
+	cpw32_f(MAR0 + 0, mc_filter[0]);
+	cpw32_f(MAR0 + 4, mc_filter[1]);
 }
 
-static void cp_set_rx_mode (struct net_device *dev)
+static void cp_set_rx_mode(struct net_device *dev)
 {
 	unsigned long flags;
 	struct cp_private *cp = netdev_priv(dev);
 
-	spin_lock_irqsave (&cp->lock, flags);
+	spin_lock_irqsave(&cp->lock, flags);
 	__cp_set_rx_mode(dev);
-	spin_unlock_irqrestore (&cp->lock, flags);
+	spin_unlock_irqrestore(&cp->lock, flags);
 }
 
 static void __cp_get_stats(struct cp_private *cp)
 {
 	/* only lower 24 bits valid; write any value to clear */
-	cp->dev->stats.rx_missed_errors += (cpr32 (RxMissed) & 0xffffff);
-	cpw32 (RxMissed, 0);
+	cp->dev->stats.rx_missed_errors += (cpr32(RxMissed) & 0xffffff);
+	cpw32(RxMissed, 0);
 }
 
 static struct net_device_stats *cp_get_stats(struct net_device *dev)
@@ -954,14 +954,14 @@ static struct net_device_stats *cp_get_stats(struct net_device *dev)
 
 	/* The chip only need report frame silently dropped. */
 	spin_lock_irqsave(&cp->lock, flags);
- 	if (netif_running(dev) && netif_device_present(dev))
- 		__cp_get_stats(cp);
+	if (netif_running(dev) && netif_device_present(dev))
+		__cp_get_stats(cp);
 	spin_unlock_irqrestore(&cp->lock, flags);
 
 	return &dev->stats;
 }
 
-static void cp_stop_hw (struct cp_private *cp)
+static void cp_stop_hw(struct cp_private *cp)
 {
 	cpw16(IntrStatus, ~(cpr16(IntrStatus)));
 	cpw16_f(IntrMask, 0);
@@ -973,7 +973,7 @@ static void cp_stop_hw (struct cp_private *cp)
 	cp->tx_head = cp->tx_tail = 0;
 }
 
-static void cp_reset_hw (struct cp_private *cp)
+static void cp_reset_hw(struct cp_private *cp)
 {
 	unsigned work = 1000;
 
@@ -989,30 +989,30 @@ static void cp_reset_hw (struct cp_private *cp)
 	netdev_err(cp->dev, "hardware reset timeout\n");
 }
 
-static inline void cp_start_hw (struct cp_private *cp)
+static inline void cp_start_hw(struct cp_private *cp)
 {
 	cpw16(CpCmd, cp->cpcmd);
 	cpw8(Cmd, RxOn | TxOn);
 }
 
-static void cp_init_hw (struct cp_private *cp)
+static void cp_init_hw(struct cp_private *cp)
 {
 	struct net_device *dev = cp->dev;
 	dma_addr_t ring_dma;
 
 	cp_reset_hw(cp);
 
-	cpw8_f (Cfg9346, Cfg9346_Unlock);
+	cpw8_f(Cfg9346, Cfg9346_Unlock);
 
 	/* Restore our idea of the MAC address. */
-	cpw32_f (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
-	cpw32_f (MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr + 4)));
+	cpw32_f(MAC0 + 0, le32_to_cpu(*(__le32 *) (dev->dev_addr + 0)));
+	cpw32_f(MAC0 + 4, le32_to_cpu(*(__le32 *) (dev->dev_addr + 4)));
 
 	cp_start_hw(cp);
 	cpw8(TxThresh, 0x06); /* XXX convert magic num to a constant */
 
 	__cp_set_rx_mode(dev);
-	cpw32_f (TxConfig, IFG | (TX_DMA_BURST << TxDMAShift));
+	cpw32_f(TxConfig, IFG | (TX_DMA_BURST << TxDMAShift));
 
 	cpw8(Config1, cpr8(Config1) | DriverLoaded | PMEnable);
 	/* Disable Wake-on-LAN. Can be turned on with ETHTOOL_SWOL */
@@ -1073,23 +1073,23 @@ err_out:
 	return -ENOMEM;
 }
 
-static void cp_init_rings_index (struct cp_private *cp)
+static void cp_init_rings_index(struct cp_private *cp)
 {
 	cp->rx_tail = 0;
 	cp->tx_head = cp->tx_tail = 0;
 }
 
-static int cp_init_rings (struct cp_private *cp)
+static int cp_init_rings(struct cp_private *cp)
 {
 	memset(cp->tx_ring, 0, sizeof(struct cp_desc) * CP_TX_RING_SIZE);
 	cp->tx_ring[CP_TX_RING_SIZE - 1].opts1 = cpu_to_le32(RingEnd);
 
 	cp_init_rings_index(cp);
 
-	return cp_refill_rx (cp);
+	return cp_refill_rx(cp);
 }
 
-static int cp_alloc_rings (struct cp_private *cp)
+static int cp_alloc_rings(struct cp_private *cp)
 {
 	void *mem;
 
@@ -1104,7 +1104,7 @@ static int cp_alloc_rings (struct cp_private *cp)
 	return cp_init_rings(cp);
 }
 
-static void cp_clean_rings (struct cp_private *cp)
+static void cp_clean_rings(struct cp_private *cp)
 {
 	struct cp_desc *desc;
 	unsigned i;
@@ -1112,7 +1112,7 @@ static void cp_clean_rings (struct cp_private *cp)
 	for (i = 0; i < CP_RX_RING_SIZE; i++) {
 		if (cp->rx_skb[i]) {
 			desc = cp->rx_ring + i;
-			dma_unmap_single(&cp->pdev->dev,le64_to_cpu(desc->addr),
+			dma_unmap_single(&cp->pdev->dev, le64_to_cpu(desc->addr),
 					 cp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(cp->rx_skb[i]);
 		}
@@ -1123,7 +1123,7 @@ static void cp_clean_rings (struct cp_private *cp)
 			struct sk_buff *skb = cp->tx_skb[i];
 
 			desc = cp->tx_ring + i;
-			dma_unmap_single(&cp->pdev->dev,le64_to_cpu(desc->addr),
+			dma_unmap_single(&cp->pdev->dev, le64_to_cpu(desc->addr),
 					 le32_to_cpu(desc->opts1) & 0xffff,
 					 PCI_DMA_TODEVICE);
 			if (le32_to_cpu(desc->opts1) & LastFrag)
@@ -1139,7 +1139,7 @@ static void cp_clean_rings (struct cp_private *cp)
 	memset(cp->tx_skb, 0, sizeof(struct sk_buff *) * CP_TX_RING_SIZE);
 }
 
-static void cp_free_rings (struct cp_private *cp)
+static void cp_free_rings(struct cp_private *cp)
 {
 	cp_clean_rings(cp);
 	dma_free_coherent(&cp->pdev->dev, CP_RING_BYTES, cp->rx_ring,
@@ -1148,7 +1148,7 @@ static void cp_free_rings (struct cp_private *cp)
 	cp->tx_ring = NULL;
 }
 
-static int cp_open (struct net_device *dev)
+static int cp_open(struct net_device *dev)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	int rc;
@@ -1180,7 +1180,7 @@ err_out_hw:
 	return rc;
 }
 
-static int cp_close (struct net_device *dev)
+static int cp_close(struct net_device *dev)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
@@ -1295,32 +1295,32 @@ static void mdio_write(struct net_device *dev, int phy_id, int location,
 }
 
 /* Set the ethtool Wake-on-LAN settings */
-static int netdev_set_wol (struct cp_private *cp,
+static int netdev_set_wol(struct cp_private *cp,
 			   const struct ethtool_wolinfo *wol)
 {
 	u8 options;
 
-	options = cpr8 (Config3) & ~(LinkUp | MagicPacket);
+	options = cpr8(Config3) & ~(LinkUp | MagicPacket);
 	/* If WOL is being disabled, no need for complexity */
 	if (wol->wolopts) {
-		if (wol->wolopts & WAKE_PHY)	options |= LinkUp;
-		if (wol->wolopts & WAKE_MAGIC)	options |= MagicPacket;
+		if (wol->wolopts & WAKE_PHY) options |= LinkUp;
+		if (wol->wolopts & WAKE_MAGIC) options |= MagicPacket;
 	}
 
-	cpw8 (Cfg9346, Cfg9346_Unlock);
-	cpw8 (Config3, options);
-	cpw8 (Cfg9346, Cfg9346_Lock);
+	cpw8(Cfg9346, Cfg9346_Unlock);
+	cpw8(Config3, options);
+	cpw8(Cfg9346, Cfg9346_Lock);
 
 	options = 0; /* Paranoia setting */
-	options = cpr8 (Config5) & ~(UWF | MWF | BWF);
+	options = cpr8(Config5) & ~(UWF | MWF | BWF);
 	/* If WOL is being disabled, no need for complexity */
 	if (wol->wolopts) {
-		if (wol->wolopts & WAKE_UCAST)  options |= UWF;
-		if (wol->wolopts & WAKE_BCAST)	options |= BWF;
-		if (wol->wolopts & WAKE_MCAST)	options |= MWF;
+		if (wol->wolopts & WAKE_UCAST) options |= UWF;
+		if (wol->wolopts & WAKE_BCAST) options |= BWF;
+		if (wol->wolopts & WAKE_MCAST) options |= MWF;
 	}
 
-	cpw8 (Config5, options);
+	cpw8(Config5, options);
 
 	cp->wol_enabled = (wol->wolopts) ? 1 : 0;
 
@@ -1328,35 +1328,36 @@ static int netdev_set_wol (struct cp_private *cp,
 }
 
 /* Get the ethtool Wake-on-LAN settings */
-static void netdev_get_wol (struct cp_private *cp,
-	             struct ethtool_wolinfo *wol)
+static void netdev_get_wol(struct cp_private *cp,
+			   struct ethtool_wolinfo *wol)
 {
 	u8 options;
 
 	wol->wolopts   = 0; /* Start from scratch */
-	wol->supported = WAKE_PHY   | WAKE_BCAST | WAKE_MAGIC |
-		         WAKE_MCAST | WAKE_UCAST;
+	wol->supported = WAKE_PHY   | WAKE_BCAST | WAKE_MAGIC | WAKE_MCAST | WAKE_UCAST;
+
 	/* We don't need to go on if WOL is disabled */
-	if (!cp->wol_enabled) return;
+	if (!cp->wol_enabled)
+		return;
 
-	options        = cpr8 (Config3);
-	if (options & LinkUp)        wol->wolopts |= WAKE_PHY;
-	if (options & MagicPacket)   wol->wolopts |= WAKE_MAGIC;
+	options        = cpr8(Config3);
+	if (options & LinkUp) wol->wolopts |= WAKE_PHY;
+	if (options & MagicPacket) wol->wolopts |= WAKE_MAGIC;
 
 	options        = 0; /* Paranoia setting */
-	options        = cpr8 (Config5);
-	if (options & UWF)           wol->wolopts |= WAKE_UCAST;
-	if (options & BWF)           wol->wolopts |= WAKE_BCAST;
-	if (options & MWF)           wol->wolopts |= WAKE_MCAST;
+	options        = cpr8(Config5);
+	if (options & UWF) wol->wolopts |= WAKE_UCAST;
+	if (options & BWF) wol->wolopts |= WAKE_BCAST;
+	if (options & MWF) wol->wolopts |= WAKE_MCAST;
 }
 
-static void cp_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info)
+static void cp_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct cp_private *cp = netdev_priv(dev);
 
-	strcpy (info->driver, DRV_NAME);
-	strcpy (info->version, DRV_VERSION);
-	strcpy (info->bus_info, pci_name(cp->pdev));
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+	strcpy(info->bus_info, pci_name(cp->pdev));
 }
 
 static int cp_get_regs_len(struct net_device *dev)
@@ -1364,7 +1365,7 @@ static int cp_get_regs_len(struct net_device *dev)
 	return CP_REGS_SIZE;
 }
 
-static int cp_get_sset_count (struct net_device *dev, int sset)
+static int cp_get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
 	case ETH_SS_STATS:
@@ -1449,7 +1450,7 @@ static int cp_set_rx_csum(struct net_device *dev, u32 data)
 }
 
 static void cp_get_regs(struct net_device *dev, struct ethtool_regs *regs,
-		        void *p)
+			void *p)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
@@ -1464,30 +1465,30 @@ static void cp_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 	spin_unlock_irqrestore(&cp->lock, flags);
 }
 
-static void cp_get_wol (struct net_device *dev, struct ethtool_wolinfo *wol)
+static void cp_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
 
-	spin_lock_irqsave (&cp->lock, flags);
-	netdev_get_wol (cp, wol);
-	spin_unlock_irqrestore (&cp->lock, flags);
+	spin_lock_irqsave(&cp->lock, flags);
+	netdev_get_wol(cp, wol);
+	spin_unlock_irqrestore(&cp->lock, flags);
 }
 
-static int cp_set_wol (struct net_device *dev, struct ethtool_wolinfo *wol)
+static int cp_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
 	int rc;
 
-	spin_lock_irqsave (&cp->lock, flags);
-	rc = netdev_set_wol (cp, wol);
-	spin_unlock_irqrestore (&cp->lock, flags);
+	spin_lock_irqsave(&cp->lock, flags);
+	rc = netdev_set_wol(cp, wol);
+	spin_unlock_irqrestore(&cp->lock, flags);
 
 	return rc;
 }
 
-static void cp_get_strings (struct net_device *dev, u32 stringset, u8 *buf)
+static void cp_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	switch (stringset) {
 	case ETH_SS_STATS:
@@ -1499,7 +1500,7 @@ static void cp_get_strings (struct net_device *dev, u32 stringset, u8 *buf)
 	}
 }
 
-static void cp_get_ethtool_stats (struct net_device *dev,
+static void cp_get_ethtool_stats(struct net_device *dev,
 				  struct ethtool_stats *estats, u64 *tmp_stats)
 {
 	struct cp_private *cp = netdev_priv(dev);
@@ -1571,7 +1572,7 @@ static const struct ethtool_ops cp_ethtool_ops = {
 	.set_eeprom		= cp_set_eeprom,
 };
 
-static int cp_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
+static int cp_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct cp_private *cp = netdev_priv(dev);
 	int rc;
@@ -1599,8 +1600,8 @@ static int cp_set_mac_address(struct net_device *dev, void *p)
 	spin_lock_irq(&cp->lock);
 
 	cpw8_f(Cfg9346, Cfg9346_Unlock);
-	cpw32_f(MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
-	cpw32_f(MAC0 + 4, le32_to_cpu (*(__le32 *) (dev->dev_addr + 4)));
+	cpw32_f(MAC0 + 0, le32_to_cpu(*(__le32 *) (dev->dev_addr + 0)));
+	cpw32_f(MAC0 + 4, le32_to_cpu(*(__le32 *) (dev->dev_addr + 4)));
 	cpw8_f(Cfg9346, Cfg9346_Lock);
 
 	spin_unlock_irq(&cp->lock);
@@ -1640,9 +1641,9 @@ static int cp_set_mac_address(struct net_device *dev, void *p)
 
 static void eeprom_cmd_start(void __iomem *ee_addr)
 {
-	writeb (EE_ENB & ~EE_CS, ee_addr);
-	writeb (EE_ENB, ee_addr);
-	eeprom_delay ();
+	writeb(EE_ENB & ~EE_CS, ee_addr);
+	writeb(EE_ENB, ee_addr);
+	eeprom_delay();
 }
 
 static void eeprom_cmd(void __iomem *ee_addr, int cmd, int cmd_len)
@@ -1652,19 +1653,20 @@ static void eeprom_cmd(void __iomem *ee_addr, int cmd, int cmd_len)
 	/* Shift the command bits out. */
 	for (i = cmd_len - 1; i >= 0; i--) {
 		int dataval = (cmd & (1 << i)) ? EE_DATA_WRITE : 0;
-		writeb (EE_ENB | dataval, ee_addr);
-		eeprom_delay ();
-		writeb (EE_ENB | dataval | EE_SHIFT_CLK, ee_addr);
-		eeprom_delay ();
+		writeb(EE_ENB | dataval, ee_addr);
+		eeprom_delay();
+		writeb(EE_ENB | dataval | EE_SHIFT_CLK, ee_addr);
+		eeprom_delay();
 	}
-	writeb (EE_ENB, ee_addr);
-	eeprom_delay ();
+
+	writeb(EE_ENB, ee_addr);
+	eeprom_delay();
 }
 
 static void eeprom_cmd_end(void __iomem *ee_addr)
 {
-	writeb (~EE_CS, ee_addr);
-	eeprom_delay ();
+	writeb(~EE_CS, ee_addr);
+	eeprom_delay();
 }
 
 static void eeprom_extend_cmd(void __iomem *ee_addr, int extend_cmd,
@@ -1677,7 +1679,7 @@ static void eeprom_extend_cmd(void __iomem *ee_addr, int extend_cmd,
 	eeprom_cmd_end(ee_addr);
 }
 
-static u16 read_eeprom (void __iomem *ioaddr, int location, int addr_len)
+static u16 read_eeprom(void __iomem *ioaddr, int location, int addr_len)
 {
 	int i;
 	u16 retval = 0;
@@ -1688,13 +1690,13 @@ static u16 read_eeprom (void __iomem *ioaddr, int location, int addr_len)
 	eeprom_cmd(ee_addr, read_cmd, 3 + addr_len);
 
 	for (i = 16; i > 0; i--) {
-		writeb (EE_ENB | EE_SHIFT_CLK, ee_addr);
-		eeprom_delay ();
+		writeb(EE_ENB | EE_SHIFT_CLK, ee_addr);
+		eeprom_delay();
 		retval =
-		    (retval << 1) | ((readb (ee_addr) & EE_DATA_READ) ? 1 :
+		    (retval << 1) | ((readb(ee_addr) & EE_DATA_READ) ? 1 :
 				     0);
-		writeb (EE_ENB, ee_addr);
-		eeprom_delay ();
+		writeb(EE_ENB, ee_addr);
+		eeprom_delay();
 	}
 
 	eeprom_cmd_end(ee_addr);
@@ -1817,17 +1819,17 @@ static int cp_set_eeprom(struct net_device *dev,
 }
 
 /* Put the board into D3cold state and wait for WakeUp signal */
-static void cp_set_d3_state (struct cp_private *cp)
+static void cp_set_d3_state(struct cp_private *cp)
 {
-	pci_enable_wake (cp->pdev, 0, 1); /* Enable PME# generation */
-	pci_set_power_state (cp->pdev, PCI_D3hot);
+	pci_enable_wake(cp->pdev, 0, 1); /* Enable PME# generation */
+	pci_set_power_state(cp->pdev, PCI_D3hot);
 }
 
 static const struct net_device_ops cp_netdev_ops = {
 	.ndo_open		= cp_open,
 	.ndo_stop		= cp_close,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_mac_address 	= cp_set_mac_address,
+	.ndo_set_mac_address	= cp_set_mac_address,
 	.ndo_set_multicast_list	= cp_set_rx_mode,
 	.ndo_get_stats		= cp_get_stats,
 	.ndo_do_ioctl		= cp_ioctl,
@@ -1845,7 +1847,7 @@ static const struct net_device_ops cp_netdev_ops = {
 #endif
 };
 
-static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
+static int cp_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct cp_private *cp;
@@ -1877,7 +1879,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	cp->pdev = pdev;
 	cp->dev = dev;
 	cp->msg_enable = (debug < 0 ? CP_DEF_MSG_ENABLE : debug);
-	spin_lock_init (&cp->lock);
+	spin_lock_init(&cp->lock);
 	cp->mii_if.dev = dev;
 	cp->mii_if.mdio_read = mdio_read;
 	cp->mii_if.mdio_write = mdio_write;
@@ -1950,10 +1952,10 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	cp_stop_hw(cp);
 
 	/* read MAC address from EEPROM */
-	addr_len = read_eeprom (regs, 0, 8) == 0x8129 ? 8 : 6;
+	addr_len = read_eeprom(regs, 0, 8) == 0x8129 ? 8 : 6;
 	for (i = 0; i < 3; i++)
 		((__le16 *) (dev->dev_addr))[i] =
-		    cpu_to_le16(read_eeprom (regs, i + 7, addr_len));
+		    cpu_to_le16(read_eeprom(regs, i + 7, addr_len));
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	dev->netdev_ops = &cp_netdev_ops;
@@ -1987,7 +1989,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_master(pdev);
 
 	if (cp->wol_enabled)
-		cp_set_d3_state (cp);
+		cp_set_d3_state(cp);
 
 	return 0;
 
@@ -2004,7 +2006,7 @@ err_out_free:
 	return rc;
 }
 
-static void cp_remove_one (struct pci_dev *pdev)
+static void cp_remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct cp_private *cp = netdev_priv(dev);
@@ -2012,7 +2014,7 @@ static void cp_remove_one (struct pci_dev *pdev)
 	unregister_netdev(dev);
 	iounmap(cp->regs);
 	if (cp->wol_enabled)
-		pci_set_power_state (pdev, PCI_D0);
+		pci_set_power_state(pdev, PCI_D0);
 	pci_release_regions(pdev);
 	pci_clear_mwi(pdev);
 	pci_disable_device(pdev);
@@ -2021,7 +2023,7 @@ static void cp_remove_one (struct pci_dev *pdev)
 }
 
 #ifdef CONFIG_PM
-static int cp_suspend (struct pci_dev *pdev, pm_message_t state)
+static int cp_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct cp_private *cp = netdev_priv(dev);
@@ -2030,16 +2032,16 @@ static int cp_suspend (struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 
-	netif_device_detach (dev);
-	netif_stop_queue (dev);
+	netif_device_detach(dev);
+	netif_stop_queue(dev);
 
-	spin_lock_irqsave (&cp->lock, flags);
+	spin_lock_irqsave(&cp->lock, flags);
 
 	/* Disable Rx and Tx */
-	cpw16 (IntrMask, 0);
-	cpw8  (Cmd, cpr8 (Cmd) & (~RxOn | ~TxOn));
+	cpw16(IntrMask, 0);
+	cpw8(Cmd, cpr8(Cmd) & (~RxOn | ~TxOn));
 
-	spin_unlock_irqrestore (&cp->lock, flags);
+	spin_unlock_irqrestore(&cp->lock, flags);
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), cp->wol_enabled);
@@ -2048,31 +2050,31 @@ static int cp_suspend (struct pci_dev *pdev, pm_message_t state)
 	return 0;
 }
 
-static int cp_resume (struct pci_dev *pdev)
+static int cp_resume(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata (pdev);
+	struct net_device *dev = pci_get_drvdata(pdev);
 	struct cp_private *cp = netdev_priv(dev);
 	unsigned long flags;
 
 	if (!netif_running(dev))
 		return 0;
 
-	netif_device_attach (dev);
+	netif_device_attach(dev);
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* FIXME: sh*t may happen if the Rx ring buffer is depleted */
-	cp_init_rings_index (cp);
-	cp_init_hw (cp);
-	netif_start_queue (dev);
+	cp_init_rings_index(cp);
+	cp_init_hw(cp);
+	netif_start_queue(dev);
 
-	spin_lock_irqsave (&cp->lock, flags);
+	spin_lock_irqsave(&cp->lock, flags);
 
 	mii_check_media(&cp->mii_if, netif_msg_link(cp), false);
 
-	spin_unlock_irqrestore (&cp->lock, flags);
+	spin_unlock_irqrestore(&cp->lock, flags);
 
 	return 0;
 }
@@ -2089,7 +2091,7 @@ static struct pci_driver cp_driver = {
 #endif
 };
 
-static int __init cp_init (void)
+static int __init cp_init(void)
 {
 #ifdef MODULE
 	pr_info("%s", version);
@@ -2097,9 +2099,9 @@ static int __init cp_init (void)
 	return pci_register_driver(&cp_driver);
 }
 
-static void __exit cp_exit (void)
+static void __exit cp_exit(void)
 {
-	pci_unregister_driver (&cp_driver);
+	pci_unregister_driver(&cp_driver);
 }
 
 module_init(cp_init);
-- 
1.7.1
