From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: [PATCH] mv643xx enet update + ethtool support
Date: Thu, 17 Feb 2005 15:42:39 -0700
Message-ID: <20050217224239.GA16609@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is an update to mv643xx ethernet support.  
There are several small bugfixes.  The two larger issues are
the beginning of ethtool support and the fact that I've disabled
hardware tcp/udp checksum generation.  It now looks like there's
a hardware bug with the checksums, but I'm still characterizing it.

ChangeSets before 1.2065 are already in -netdev.
I've included a cumulative patch of the new changesets below.

Thanks,
-Dale Farnsworth

Please do a

	bk pull bk://dfarnsworth.bkbits.net/linux-2.5-mv643xx-enet

This will update the following files:

 drivers/net/Kconfig       |    5 
 drivers/net/mv643xx_eth.c | 2689 ++++++++++++++++++++++++++--------------------
 drivers/net/mv643xx_eth.h |  641 ++++------
 include/linux/mv643xx.h   |  448 +++++--
 4 files changed, 2119 insertions(+), 1664 deletions(-)

through these ChangeSets:

<dale@farnsworth.org> (05/02/17 1.2075)
   Add ethtool support to the mv643xx ethernet driver.
   Initially, we add statistics and link status reporting.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2074)
   Enable the mv643xx ethernet support on platforms using the MV64360 chip.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2073)
   Disable tcp/udp checksum offload to hardware.  It generally works,
   but the hardware appears to generate the wrong checksum if the
   hw checksum generation wasn't used in the previous packet sent.
   
   I'm increasingly confident this is a hardware error.
   We'll disable hw tcp/udp checksum generation until we have a fix
   or workaround.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2072)
   We already set ETH_TX_ENABLE_INTERRUPT whenever we set ETH_TX_LAST_DESC.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2071)
   Update tx_bytes statistic when using hw tcp/udp checksum generation.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2070)
   Call netif_carrier_off when closing the driver.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2069)
   Trivial.  Remove repeated comment.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2068)
   Clear transmit l4i_chk even when the hardware ignores it.
   Not absolutely necessary, but makes debugging easier.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2067)
   Increment tx_ring_skbs before calling eth_port_send, since
   otherwise the irq handler may check and decrement it before
   we increment it.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2066)
   Fix handling of unaligned tiny fragments not handled by hardware
   Check all fragments instead of just the last.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/02/17 1.2065)
   Fix a few places I missed in the previous rename patch.
   Rename: mv64x60 => mv643xx
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.17)
   Big rename.
   
   Change MV64340 => MV643XX and mv64340 => mv643xx
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.16)
   Rename MV_READ => mv_read and MV_WRITE => mv_write
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.15)
   Additional whitespace cleanups, mostly changing spaces to tabs in comments

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.14)
   Run mv643xx_eth.[ch] through scripts/Lindent
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.13)
   Add a function to detect at runtime whether a PHY is attached to
   the specified port, and use it to cause the probe routine to fail
   when there is no PHY.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.12)
   This one liner removes a spurious left paren fixing an obvious syntax error
   in the #ifndef MV64340_NAPI case

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.11)
   Add support for PHYs/boards that don't support autonegotiation.
     
   Signed-off-by: Brian Waite <brian@waitefamily.us>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.10)
   With this patch, the driver now calls netif_carrier_off/netif_carrier_on
   on a link down/up condition.
     
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dfarnsworth@mvista.com> (05/01/27 1.1966.60.9)
   This patch cleans up the handling of receive skb sizing.
     
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.8)
   This patch simplifies the mv64340_eth_set_rx_mode function without
   changing its behavior.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.7)
   This patch makes the use of the MV64340_RX_QUEUE_FILL_ON_TASK config macro
   more consistent, though the macro remains undefined, since the feature still
   does not work properly.
           
   Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.6)
   This patch adds support for passing additional parameters via the
   platform_device interface.  These additional parameters are:
           size of RX and TX descriptor rings
           port_config value 
           port_config_extend value
           port_sdma_config value
           port_serial_control value
           PHY address                                                                                                                                             Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.5)
   This patch adds device driver model support to the mv643xx_eth driver.
   
   This is a change to the driver's programming interface.  Platform
   code must now pass in the address of the MV643xx ethernet registers
   and IRQ.  If firmware doesn't set the MAC address, platform code
   must also pass in the MAC address.
   
   Also, note that local MV_READ/MV_WRITE macros are used rather than              using global macros.  Keeping the macro names minimizes the patch size.         The names will be changed to mv_read/mv_write in a later cosmetic               cleanup patch.                                                                                                                                                  Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.4)
   This patch replaces the use of the pci_map_* functions with the
   corresponding dma_map_* functions.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.3)
   This patch fixes the code that enables hardware checksum generation.
   The previous code has so many problems that it appears to never have 
   worked 2.6.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.2)
   This patch removes spin delays (count to 1000000, ugh) and instead waits
   with udelay or msleep for hardware flags to change.
   
   It also adds a spinlock to protect access to the MV64340_ETH_SMI_REG,
   which is shared across ports.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (05/01/14 1.1966.60.1)
   This patch removes code that is redundant or useless.
   The biggest area is in pre-initializing the RX and TX descriptor
   rings, which only obfuscates the driver since the ring data is
   overwritten without being used.
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

--- linux-2.5-enet/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -38,6 +38,7 @@
 
 #include <linux/bitops.h>
 #include <linux/delay.h>
+#include <linux/ethtool.h>
 #include <asm/io.h>
 #include <asm/types.h>
 #include <asm/pgtable.h>
@@ -82,8 +83,12 @@
 #endif
 static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
 static int ethernet_phy_detect(unsigned int eth_port_num);
+void mv643xx_set_ethtool_ops(struct net_device *netdev);
 
-static void __iomem *mv64x60_eth_shared_base;
+static char mv643xx_driver_name[] = "mv643xx_eth";
+static char mv643xx_driver_version[] = "1.0";
+
+static void __iomem *mv643xx_eth_shared_base;
 
 /* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
 static spinlock_t mv643xx_eth_phy_lock = SPIN_LOCK_UNLOCKED;
@@ -92,7 +97,7 @@
 {
 	void *__iomem reg_base;
 
-	reg_base = mv64x60_eth_shared_base - MV643XX_ETH_SHARED_REGS;
+	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
 
 	return readl(reg_base + offset);
 }
@@ -101,7 +106,7 @@
 {
 	void * __iomem reg_base;
 
-	reg_base = mv64x60_eth_shared_base - MV643XX_ETH_SHARED_REGS;
+	reg_base = mv643xx_eth_shared_base - MV643XX_ETH_SHARED_REGS;
 	writel(data, reg_base + offset);
 }
 
@@ -995,6 +1000,7 @@
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 
+	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
 	mv643xx_eth_free_tx_rings(dev);
@@ -1159,10 +1165,11 @@
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 	if (!skb_shinfo(skb)->nr_frags) {
 linear:
-		if (skb->ip_summed != CHECKSUM_HW)
+		if (skb->ip_summed != CHECKSUM_HW) {
 			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
 					ETH_TX_FIRST_DESC | ETH_TX_LAST_DESC;
-		else {
+			pkt_info.l4i_chk = 0;
+		} else {
 			u32 ipheader = skb->nh.iph->ihl << 11;
 
 			pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT |
@@ -1187,21 +1194,34 @@
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
 							DMA_TO_DEVICE);
 		pkt_info.return_info = skb;
+		mp->tx_ring_skbs++;
 		status = eth_port_send(mp, &pkt_info);
 		if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
 			printk(KERN_ERR "%s: Error on transmitting packet\n",
 								dev->name);
-		mp->tx_ring_skbs++;
+		stats->tx_bytes += pkt_info.byte_cnt;
 	} else {
 		unsigned int frag;
 		u32 ipheader;
-		skb_frag_t *last_frag;
 
-		frag = skb_shinfo(skb)->nr_frags - 1;
-		last_frag = &skb_shinfo(skb)->frags[frag];
-		if (last_frag->size <= 8 && last_frag->page_offset & 0x7) {
-			skb_linearize(skb, GFP_ATOMIC);
-			goto linear;
+		/* Since hardware can't handle unaligned fragments smaller
+		 * than 9 bytes, if we find any, we linearize the skb
+		 * and start again.  When I've seen it, it's always been
+		 * the first frag (probably near the end of the page),
+		 * but we check all frags to be safe.
+		 */
+		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
+			skb_frag_t *fragp;
+
+			fragp = &skb_shinfo(skb)->frags[frag];
+			if (fragp->size <= 8 && fragp->page_offset & 0x7) {
+				skb_linearize(skb, GFP_ATOMIC);
+				printk(KERN_DEBUG "%s: unaligned tiny fragment"
+						"%d of %d, fixed\n",
+						dev->name, frag,
+						skb_shinfo(skb)->nr_frags);
+				goto linear;
+			}
 		}
 
 		/* first frag which is skb header */
@@ -1209,11 +1229,11 @@
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data,
 							skb_headlen(skb),
 							DMA_TO_DEVICE);
+		pkt_info.l4i_chk = 0;
 		pkt_info.return_info = 0;
 		pkt_info.cmd_sts = ETH_TX_FIRST_DESC;
 
 		if (skb->ip_summed == CHECKSUM_HW) {
-			/* CPU already calculated pseudo header checksum. */
 			ipheader = skb->nh.iph->ihl << 11;
 			pkt_info.cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
 					ETH_GEN_IP_V_4_CHECKSUM | ipheader;
@@ -1243,6 +1263,7 @@
 			if (status == ETH_QUEUE_LAST_RESOURCE)
 				printk("Tx resource error \n");
 		}
+		stats->tx_bytes += pkt_info.byte_cnt;
 
 		/* Check for the remaining frags */
 		for (frag = 0; frag < skb_shinfo(skb)->nr_frags; frag++) {
@@ -1259,6 +1280,7 @@
 			} else {
 				pkt_info.return_info = 0;
 			}
+			pkt_info.l4i_chk = 0;
 			pkt_info.byte_cnt = this_frag->size;
 
 			pkt_info.buf_ptr = dma_map_page(NULL, this_frag->page,
@@ -1280,20 +1302,23 @@
 				if (status == ETH_QUEUE_FULL)
 					printk("Queue is full \n");
 			}
+			stats->tx_bytes += pkt_info.byte_cnt;
 		}
 	}
 #else
 	pkt_info.cmd_sts = ETH_TX_ENABLE_INTERRUPT | ETH_TX_FIRST_DESC |
 							ETH_TX_LAST_DESC;
+	pkt_info.l4i_chk = 0;
 	pkt_info.byte_cnt = skb->len;
 	pkt_info.buf_ptr = dma_map_single(NULL, skb->data, skb->len,
 								DMA_TO_DEVICE);
 	pkt_info.return_info = skb;
+	mp->tx_ring_skbs++;
 	status = eth_port_send(mp, &pkt_info);
 	if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
 		printk(KERN_ERR "%s: Error on transmitting packet\n",
 								dev->name);
-	mp->tx_ring_skbs++;
+	stats->tx_bytes += pkt_info.byte_cnt;
 #endif
 
 	/* Check if TX queue can handle another skb. If not, then
@@ -1308,7 +1333,6 @@
 		netif_stop_queue(dev);
 
 	/* Update statistics and start of transmittion time */
-	stats->tx_bytes += skb->len;
 	stats->tx_packets++;
 	dev->trans_start = jiffies;
 
@@ -1388,6 +1412,7 @@
 	dev->tx_queue_len = mp->tx_ring_size;
 	dev->base_addr = 0;
 	dev->change_mtu = mv643xx_eth_change_mtu;
+	mv643xx_set_ethtool_ops(dev);
 
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 #ifdef MAX_SKB_FRAGS
@@ -1519,9 +1544,9 @@
 	if (res == NULL)
 		return -ENODEV;
 
-	mv64x60_eth_shared_base = ioremap(res->start,
+	mv643xx_eth_shared_base = ioremap(res->start,
 						MV643XX_ETH_SHARED_REGS_SIZE);
-	if (mv64x60_eth_shared_base == NULL)
+	if (mv643xx_eth_shared_base == NULL)
 		return -ENOMEM;
 
 	return 0;
@@ -1530,8 +1555,8 @@
 
 static int mv643xx_eth_shared_remove(struct device *ddev)
 {
-	iounmap(mv64x60_eth_shared_base);
-	mv64x60_eth_shared_base = NULL;
+	iounmap(mv643xx_eth_shared_base);
+	mv643xx_eth_shared_base = NULL;
 
 	return 0;
 }
@@ -2056,6 +2081,36 @@
 		mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
 }
 
+static inline u32 read_mib(struct mv643xx_private *mp, int offset)
+{
+	return mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
+}
+
+static void eth_update_mib_counters(struct mv643xx_private *mp)
+{
+	struct mv643xx_mib_counters *p = &mp->mib_counters;
+	int offset;
+
+	p->good_octets_received +=
+		read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
+	p->good_octets_received +=
+		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
+
+	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
+			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
+			offset += 4)
+		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+
+	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
+	p->good_octets_sent +=
+		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
+
+	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
+			offset <= ETH_MIB_LATE_COLLISION;
+			offset += 4)
+		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+}
+
 /*
  * ethernet_phy_detect - Detect whether a phy is present
  *
@@ -2262,19 +2317,27 @@
 	mv_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num), eth_config_reg);
 }
 
-static int eth_port_link_is_up(unsigned int eth_port_num)
+static int eth_port_autoneg_supported(unsigned int eth_port_num)
 {
 	unsigned int phy_reg_data0;
-	unsigned int phy_reg_data1;
 
 	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data0);
+
+	return phy_reg_data0 & 0x1000;
+}
+
+static int eth_port_link_is_up(unsigned int eth_port_num)
+{
+	unsigned int phy_reg_data1;
+
 	eth_port_read_smi_reg(eth_port_num, 1, &phy_reg_data1);
 
-	if (phy_reg_data0 & 0x1000) {	/* auto-neg supported? */
+	if (eth_port_autoneg_supported(eth_port_num)) {
 		if (phy_reg_data1 & 0x20)	/* auto-neg complete */
 			return 1;
-	} else if (phy_reg_data1 & 0x4)	/* link up */
+	} else if (phy_reg_data1 & 0x4)		/* link up */
 		return 1;
+
 	return 0;
 }
 
@@ -2476,9 +2539,6 @@
 
 	command = p_pkt_info->cmd_sts | ETH_ZERO_PADDING | ETH_GEN_CRC |
 							ETH_BUFFER_OWNED_BY_DMA;
-	if (command & ETH_TX_LAST_DESC)
-		command |= ETH_TX_ENABLE_INTERRUPT;
-
 	if (command & ETH_TX_FIRST_DESC) {
 		tx_first_desc = tx_desc_curr;
 		mp->tx_first_desc_q = tx_first_desc;
@@ -2754,0 +2815,227 @@
+
+/************* Begin ethtool support *************************/
+
+struct mv643xx_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define MV643XX_STAT(m) sizeof(((struct mv643xx_private *)0)->m), \
+		      offsetof(struct mv643xx_private, m)
+
+static const struct mv643xx_stats mv643xx_gstrings_stats[] = {
+	{ "rx_packets", MV643XX_STAT(stats.rx_packets) },
+	{ "tx_packets", MV643XX_STAT(stats.tx_packets) },
+	{ "rx_bytes", MV643XX_STAT(stats.rx_bytes) },
+	{ "tx_bytes", MV643XX_STAT(stats.tx_bytes) },
+	{ "rx_errors", MV643XX_STAT(stats.rx_errors) },
+	{ "tx_errors", MV643XX_STAT(stats.tx_errors) },
+	{ "rx_dropped", MV643XX_STAT(stats.rx_dropped) },
+	{ "tx_dropped", MV643XX_STAT(stats.tx_dropped) },
+	{ "good_octets_received", MV643XX_STAT(mib_counters.good_octets_received) },
+	{ "bad_octets_received", MV643XX_STAT(mib_counters.bad_octets_received) },
+	{ "internal_mac_transmit_err", MV643XX_STAT(mib_counters.internal_mac_transmit_err) },
+	{ "good_frames_received", MV643XX_STAT(mib_counters.good_frames_received) },
+	{ "bad_frames_received", MV643XX_STAT(mib_counters.bad_frames_received) },
+	{ "broadcast_frames_received", MV643XX_STAT(mib_counters.broadcast_frames_received) },
+	{ "multicast_frames_received", MV643XX_STAT(mib_counters.multicast_frames_received) },
+	{ "frames_64_octets", MV643XX_STAT(mib_counters.frames_64_octets) },
+	{ "frames_65_to_127_octets", MV643XX_STAT(mib_counters.frames_65_to_127_octets) },
+	{ "frames_128_to_255_octets", MV643XX_STAT(mib_counters.frames_128_to_255_octets) },
+	{ "frames_256_to_511_octets", MV643XX_STAT(mib_counters.frames_256_to_511_octets) },
+	{ "frames_512_to_1023_octets", MV643XX_STAT(mib_counters.frames_512_to_1023_octets) },
+	{ "frames_1024_to_max_octets", MV643XX_STAT(mib_counters.frames_1024_to_max_octets) },
+	{ "good_octets_sent", MV643XX_STAT(mib_counters.good_octets_sent) },
+	{ "good_frames_sent", MV643XX_STAT(mib_counters.good_frames_sent) },
+	{ "excessive_collision", MV643XX_STAT(mib_counters.excessive_collision) },
+	{ "multicast_frames_sent", MV643XX_STAT(mib_counters.multicast_frames_sent) },
+	{ "broadcast_frames_sent", MV643XX_STAT(mib_counters.broadcast_frames_sent) },
+	{ "unrec_mac_control_received", MV643XX_STAT(mib_counters.unrec_mac_control_received) },
+	{ "fc_sent", MV643XX_STAT(mib_counters.fc_sent) },
+	{ "good_fc_received", MV643XX_STAT(mib_counters.good_fc_received) },
+	{ "bad_fc_received", MV643XX_STAT(mib_counters.bad_fc_received) },
+	{ "undersize_received", MV643XX_STAT(mib_counters.undersize_received) },
+	{ "fragments_received", MV643XX_STAT(mib_counters.fragments_received) },
+	{ "oversize_received", MV643XX_STAT(mib_counters.oversize_received) },
+	{ "jabber_received", MV643XX_STAT(mib_counters.jabber_received) },
+	{ "mac_receive_error", MV643XX_STAT(mib_counters.mac_receive_error) },
+	{ "bad_crc_event", MV643XX_STAT(mib_counters.bad_crc_event) },
+	{ "collision", MV643XX_STAT(mib_counters.collision) },
+	{ "late_collision", MV643XX_STAT(mib_counters.late_collision) },
+};
+
+#define MV643XX_STATS_LEN	\
+	sizeof(mv643xx_gstrings_stats) / sizeof(struct mv643xx_stats)
+
+static int
+mv643xx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct mv643xx_private *mp = netdev->priv;
+	int port_num = mp->port_num;
+	int autoneg = eth_port_autoneg_supported(port_num);
+	int mode_10_bit;
+	int auto_duplex;
+	int half_duplex = 0;
+	int full_duplex = 0;
+	int auto_speed;
+	int speed_10 = 0;
+	int speed_100 = 0;
+	int speed_1000 = 0;
+
+	u32 pcs = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	u32 psr = mv_read(MV643XX_ETH_PORT_STATUS_REG(port_num));
+
+	mode_10_bit = psr & MV643XX_ETH_PORT_STATUS_MODE_10_BIT;
+
+	if (mode_10_bit) {
+		ecmd->supported = SUPPORTED_10baseT_Half;
+	} else {
+		ecmd->supported = (SUPPORTED_10baseT_Half		|
+				   SUPPORTED_10baseT_Full		|
+				   SUPPORTED_100baseT_Half		|
+				   SUPPORTED_100baseT_Full		|
+				   SUPPORTED_1000baseT_Full		|
+				   (autoneg ? SUPPORTED_Autoneg : 0)	|
+				   SUPPORTED_TP);
+
+		auto_duplex = !(pcs & MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX);
+		auto_speed = !(pcs & MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII);
+
+		ecmd->advertising = ADVERTISED_TP;
+
+		if (autoneg) {
+			ecmd->advertising |= ADVERTISED_Autoneg;
+
+			if (auto_duplex) {
+				half_duplex = 1;
+				full_duplex = 1;
+			} else {
+				if (pcs & MV643XX_ETH_SET_FULL_DUPLEX_MODE)
+					full_duplex = 1;
+				else
+					half_duplex = 1;
+			}
+
+			if (auto_speed) {
+				speed_10 = 1;
+				speed_100 = 1;
+				speed_1000 = 1;
+			} else {
+				if (pcs & MV643XX_ETH_SET_GMII_SPEED_TO_1000)
+					speed_1000 = 1;
+				else if (pcs & MV643XX_ETH_SET_MII_SPEED_TO_100)
+					speed_100 = 1;
+				else
+					speed_10 = 1;
+			}
+
+			if (speed_10 & half_duplex)
+				ecmd->advertising |= ADVERTISED_10baseT_Half;
+			if (speed_10 & full_duplex)
+				ecmd->advertising |= ADVERTISED_10baseT_Full;
+			if (speed_100 & half_duplex)
+				ecmd->advertising |= ADVERTISED_100baseT_Half;
+			if (speed_100 & full_duplex)
+				ecmd->advertising |= ADVERTISED_100baseT_Full;
+			if (speed_1000)
+				ecmd->advertising |= ADVERTISED_1000baseT_Full;
+		}
+	}
+
+	ecmd->port = PORT_TP;
+	ecmd->phy_address = ethernet_phy_get(port_num);
+
+	ecmd->transceiver = XCVR_EXTERNAL;
+
+	if (netif_carrier_ok(netdev)) {
+		if (mode_10_bit)
+			ecmd->speed = SPEED_10;
+		else {
+			if (psr & MV643XX_ETH_PORT_STATUS_GMII_1000)
+				ecmd->speed = SPEED_1000;
+			else if (psr & MV643XX_ETH_PORT_STATUS_MII_100)
+				ecmd->speed = SPEED_100;
+			else
+				ecmd->speed = SPEED_10;
+		}
+
+		if (psr & MV643XX_ETH_PORT_STATUS_FULL_DUPLEX)
+			ecmd->duplex = DUPLEX_FULL;
+		else
+			ecmd->duplex = DUPLEX_HALF;
+	} else {
+		ecmd->speed = -1;
+		ecmd->duplex = -1;
+	}
+
+	ecmd->autoneg = autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+	return 0;
+}
+
+static void
+mv643xx_get_drvinfo(struct net_device *netdev,
+                       struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
+	strncpy(drvinfo->version, mv643xx_driver_version, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, "mv643xx", 32);
+	drvinfo->n_stats = MV643XX_STATS_LEN;
+}
+
+static int 
+mv643xx_get_stats_count(struct net_device *netdev)
+{
+	return MV643XX_STATS_LEN;
+}
+
+static void 
+mv643xx_get_ethtool_stats(struct net_device *netdev, 
+		struct ethtool_stats *stats, uint64_t *data)
+{
+	struct mv643xx_private *mp = netdev->priv;
+	int i;
+
+	eth_update_mib_counters(mp);
+
+	for(i = 0; i < MV643XX_STATS_LEN; i++) {
+		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;	
+		data[i] = (mv643xx_gstrings_stats[i].sizeof_stat == 
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+	}
+}
+
+static void 
+mv643xx_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+{
+	int i;
+
+	switch(stringset) {
+	case ETH_SS_STATS:
+		for (i=0; i < MV643XX_STATS_LEN; i++) {
+			memcpy(data + i * ETH_GSTRING_LEN, 
+			mv643xx_gstrings_stats[i].stat_string,
+			ETH_GSTRING_LEN);
+		}
+		break;
+	}
+}
+
+struct ethtool_ops mv643xx_ethtool_ops = {
+	.get_settings           = mv643xx_get_settings,
+	.get_drvinfo            = mv643xx_get_drvinfo,
+	.get_link               = ethtool_op_get_link,
+	.get_sg			= ethtool_op_get_sg,
+	.set_sg			= ethtool_op_set_sg,
+	.get_strings            = mv643xx_get_strings,
+	.get_stats_count        = mv643xx_get_stats_count,
+	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
+};
+
+void mv643xx_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &mv643xx_ethtool_ops);
+}
+
+/************* End ethtool support *************************/
--- linux-2.5-enet/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -46,8 +46,10 @@
  *  The first part is the high level driver of the gigE ethernet ports.
  */
 
-/* Checksum offload for Tx works */
-#define	MV643XX_CHECKSUM_OFFLOAD_TX
+/* Checksum offload for Tx works for most packets, but
+ * fails if previous packet sent did not use hw csum
+ */
+#undef	MV643XX_CHECKSUM_OFFLOAD_TX
 #define	MV643XX_NAPI
 #define	MV643XX_TX_FAST_REFILL
 #undef	MV643XX_RX_QUEUE_FILL_ON_TASK	/* Does not work, yet */
@@ -286,6 +288,39 @@
 
 /* Ethernet port specific infomation */
 
+struct mv643xx_mib_counters {
+	u64 good_octets_received;
+	u32 bad_octets_received;
+	u32 internal_mac_transmit_err;
+	u32 good_frames_received;
+	u32 bad_frames_received;
+	u32 broadcast_frames_received;
+	u32 multicast_frames_received;
+	u32 frames_64_octets;
+	u32 frames_65_to_127_octets;
+	u32 frames_128_to_255_octets;
+	u32 frames_256_to_511_octets;
+	u32 frames_512_to_1023_octets;
+	u32 frames_1024_to_max_octets;
+	u64 good_octets_sent;
+	u32 good_frames_sent;
+	u32 excessive_collision;
+	u32 multicast_frames_sent;
+	u32 broadcast_frames_sent;
+	u32 unrec_mac_control_received;
+	u32 fc_sent;
+	u32 good_fc_received;
+	u32 bad_fc_received;
+	u32 undersize_received;
+	u32 fragments_received;
+	u32 oversize_received;
+	u32 jabber_received;
+	u32 mac_receive_error;
+	u32 bad_crc_event;
+	u32 collision;
+	u32 late_collision;
+};
+
 struct mv643xx_private {
 	int port_num;			/* User Ethernet port number	*/
 	u8 port_mac_addr[6];		/* User defined port MAC address.*/
@@ -336,6 +371,7 @@
 	 * Former struct mv643xx_eth_priv members start here
 	 */
 	struct net_device_stats stats;
+	struct mv643xx_mib_counters mib_counters;
 	spinlock_t lock;
 	/* Size of Tx Ring per queue */
 	unsigned int tx_ring_size;
--- linux-2.5-enet.orig/drivers/net/Kconfig
+++ linux-2.5-enet/drivers/net/Kconfig
@@ -2094,10 +2094,11 @@
 
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
-	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX
+	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV643XX
-	  chipset which is used in the Momenco Ocelot C and Jaguar ATX.
+	  chipset which is used in the Momenco Ocelot C and Jaguar ATX and
+	  Pegasos II, amongst other PPC and MIPS boards.
 
 config MV643XX_ETH_0
 	bool "MV-643XX Port 0"
--- linux-2.5-enet.orig/include/linux/mv643xx.h
+++ linux-2.5-enet/include/linux/mv643xx.h
@@ -1257,6 +1257,20 @@
 		MV643XX_ETH_SET_FULL_DUPLEX_MODE	|	\
 		MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
 
+/* These macros describe Ethernet Serial Status reg (PSR) bits */
+#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
+#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
+#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
+#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
+#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
+#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
+/* PSR bit 6 is undocumented */
+#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
+#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
+#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
+#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
+/* PSR bits 11-31 are reserved */
+
 #define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
 
