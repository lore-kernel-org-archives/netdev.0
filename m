From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH -v2 1/2] net/7990: Fix whitespace errors
Date: Wed, 13 Nov 2013 09:52:37 +0100
Message-ID: <1384332758-7106-1-git-send-email-geert@linux-m68k.org>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Most of them reported by checkpatch.pl

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
v2: Add this cleanup as a prerequisite for [PATCH 2/2]

 drivers/net/ethernet/amd/7990.c    |  836 ++++++++++++++++++------------------
 drivers/net/ethernet/amd/7990.h    |  268 ++++++------
 drivers/net/ethernet/amd/hplance.c |   96 ++---
 drivers/net/ethernet/amd/mvme147.c |   36 +-
 4 files changed, 619 insertions(+), 617 deletions(-)

diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 65926a956575..72cfff7d23a5 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -42,9 +42,9 @@
 
 #include "7990.h"
 
-#define WRITERAP(lp,x) out_be16(lp->base + LANCE_RAP, (x))
-#define WRITERDP(lp,x) out_be16(lp->base + LANCE_RDP, (x))
-#define READRDP(lp) in_be16(lp->base + LANCE_RDP)
+#define WRITERAP(lp, x)	out_be16(lp->base + LANCE_RAP, (x))
+#define WRITERDP(lp, x)	out_be16(lp->base + LANCE_RDP, (x))
+#define READRDP(lp)	in_be16(lp->base + LANCE_RDP)
 
 #if defined(CONFIG_HPLANCE) || defined(CONFIG_HPLANCE_MODULE)
 #include "hplance.h"
@@ -56,9 +56,9 @@
 #if defined(CONFIG_MVME147_NET) || defined(CONFIG_MVME147_NET_MODULE)
 
 /* Lossage Factor Nine, Mr Sulu. */
-#define WRITERAP(lp,x) (lp->writerap(lp,x))
-#define WRITERDP(lp,x) (lp->writerdp(lp,x))
-#define READRDP(lp) (lp->readrdp(lp))
+#define WRITERAP(lp, x)	(lp->writerap(lp, x))
+#define WRITERDP(lp, x)	(lp->writerdp(lp, x))
+#define READRDP(lp)	(lp->readrdp(lp))
 
 #else
 
@@ -94,428 +94,436 @@ static inline __u16 READRDP(struct lance_private *lp)
 #ifdef UNDEF
 #define PRINT_RINGS() \
 do { \
-        int t; \
-        for (t=0; t < RX_RING_SIZE; t++) { \
-                printk("R%d: @(%02X %04X) len %04X, mblen %04X, bits %02X\n",\
-                       t, ib->brx_ring[t].rmd1_hadr, ib->brx_ring[t].rmd0,\
-                       ib->brx_ring[t].length,\
-                       ib->brx_ring[t].mblength, ib->brx_ring[t].rmd1_bits);\
-        }\
-        for (t=0; t < TX_RING_SIZE; t++) { \
-                printk("T%d: @(%02X %04X) len %04X, misc %04X, bits %02X\n",\
-                       t, ib->btx_ring[t].tmd1_hadr, ib->btx_ring[t].tmd0,\
-                       ib->btx_ring[t].length,\
-                       ib->btx_ring[t].misc, ib->btx_ring[t].tmd1_bits);\
-        }\
+	int t; \
+	for (t = 0; t < RX_RING_SIZE; t++) { \
+		printk("R%d: @(%02X %04X) len %04X, mblen %04X, bits %02X\n", \
+		       t, ib->brx_ring[t].rmd1_hadr, ib->brx_ring[t].rmd0, \
+		       ib->brx_ring[t].length, \
+		       ib->brx_ring[t].mblength, ib->brx_ring[t].rmd1_bits); \
+	} \
+	for (t = 0; t < TX_RING_SIZE; t++) { \
+		printk("T%d: @(%02X %04X) len %04X, misc %04X, bits %02X\n", \
+		       t, ib->btx_ring[t].tmd1_hadr, ib->btx_ring[t].tmd0, \
+		       ib->btx_ring[t].length, \
+		       ib->btx_ring[t].misc, ib->btx_ring[t].tmd1_bits); \
+	} \
 } while (0)
 #else
 #define PRINT_RINGS()
 #endif
 
 /* Load the CSR registers. The LANCE has to be STOPped when we do this! */
-static void load_csrs (struct lance_private *lp)
+static void load_csrs(struct lance_private *lp)
 {
-        volatile struct lance_init_block *aib = lp->lance_init_block;
-        int leptr;
+	volatile struct lance_init_block *aib = lp->lance_init_block;
+	int leptr;
 
-        leptr = LANCE_ADDR (aib);
+	leptr = LANCE_ADDR(aib);
 
-        WRITERAP(lp, LE_CSR1);                    /* load address of init block */
-        WRITERDP(lp, leptr & 0xFFFF);
-        WRITERAP(lp, LE_CSR2);
-        WRITERDP(lp, leptr >> 16);
-        WRITERAP(lp, LE_CSR3);
-        WRITERDP(lp, lp->busmaster_regval);       /* set byteswap/ALEctrl/byte ctrl */
+	WRITERAP(lp, LE_CSR1);                    /* load address of init block */
+	WRITERDP(lp, leptr & 0xFFFF);
+	WRITERAP(lp, LE_CSR2);
+	WRITERDP(lp, leptr >> 16);
+	WRITERAP(lp, LE_CSR3);
+	WRITERDP(lp, lp->busmaster_regval);       /* set byteswap/ALEctrl/byte ctrl */
 
-        /* Point back to csr0 */
-        WRITERAP(lp, LE_CSR0);
+	/* Point back to csr0 */
+	WRITERAP(lp, LE_CSR0);
 }
 
 /* #define to 0 or 1 appropriately */
 #define DEBUG_IRING 0
 /* Set up the Lance Rx and Tx rings and the init block */
-static void lance_init_ring (struct net_device *dev)
+static void lance_init_ring(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
-        volatile struct lance_init_block *ib = lp->init_block;
-        volatile struct lance_init_block *aib; /* for LANCE_ADDR computations */
-        int leptr;
-        int i;
-
-        aib = lp->lance_init_block;
-
-        lp->rx_new = lp->tx_new = 0;
-        lp->rx_old = lp->tx_old = 0;
-
-        ib->mode = LE_MO_PROM;                             /* normal, enable Tx & Rx */
-
-        /* Copy the ethernet address to the lance init block
-         * Notice that we do a byteswap if we're big endian.
-         * [I think this is the right criterion; at least, sunlance,
-         * a2065 and atarilance do the byteswap and lance.c (PC) doesn't.
-         * However, the datasheet says that the BSWAP bit doesn't affect
-         * the init block, so surely it should be low byte first for
-         * everybody? Um.]
-         * We could define the ib->physaddr as three 16bit values and
-         * use (addr[1] << 8) | addr[0] & co, but this is more efficient.
-         */
+	struct lance_private *lp = netdev_priv(dev);
+	volatile struct lance_init_block *ib = lp->init_block;
+	volatile struct lance_init_block *aib; /* for LANCE_ADDR computations */
+	int leptr;
+	int i;
+
+	aib = lp->lance_init_block;
+
+	lp->rx_new = lp->tx_new = 0;
+	lp->rx_old = lp->tx_old = 0;
+
+	ib->mode = LE_MO_PROM;                             /* normal, enable Tx & Rx */
+
+	/* Copy the ethernet address to the lance init block
+	 * Notice that we do a byteswap if we're big endian.
+	 * [I think this is the right criterion; at least, sunlance,
+	 * a2065 and atarilance do the byteswap and lance.c (PC) doesn't.
+	 * However, the datasheet says that the BSWAP bit doesn't affect
+	 * the init block, so surely it should be low byte first for
+	 * everybody? Um.]
+	 * We could define the ib->physaddr as three 16bit values and
+	 * use (addr[1] << 8) | addr[0] & co, but this is more efficient.
+	 */
 #ifdef __BIG_ENDIAN
-        ib->phys_addr [0] = dev->dev_addr [1];
-        ib->phys_addr [1] = dev->dev_addr [0];
-        ib->phys_addr [2] = dev->dev_addr [3];
-        ib->phys_addr [3] = dev->dev_addr [2];
-        ib->phys_addr [4] = dev->dev_addr [5];
-        ib->phys_addr [5] = dev->dev_addr [4];
+	ib->phys_addr[0] = dev->dev_addr[1];
+	ib->phys_addr[1] = dev->dev_addr[0];
+	ib->phys_addr[2] = dev->dev_addr[3];
+	ib->phys_addr[3] = dev->dev_addr[2];
+	ib->phys_addr[4] = dev->dev_addr[5];
+	ib->phys_addr[5] = dev->dev_addr[4];
 #else
-        for (i=0; i<6; i++)
-           ib->phys_addr[i] = dev->dev_addr[i];
+	for (i = 0; i < 6; i++)
+	       ib->phys_addr[i] = dev->dev_addr[i];
 #endif
 
-        if (DEBUG_IRING)
-                printk ("TX rings:\n");
+	if (DEBUG_IRING)
+		printk("TX rings:\n");
 
 	lp->tx_full = 0;
-        /* Setup the Tx ring entries */
-        for (i = 0; i < (1<<lp->lance_log_tx_bufs); i++) {
-                leptr = LANCE_ADDR(&aib->tx_buf[i][0]);
-                ib->btx_ring [i].tmd0      = leptr;
-                ib->btx_ring [i].tmd1_hadr = leptr >> 16;
-                ib->btx_ring [i].tmd1_bits = 0;
-                ib->btx_ring [i].length    = 0xf000; /* The ones required by tmd2 */
-                ib->btx_ring [i].misc      = 0;
-                if (DEBUG_IRING)
-                   printk ("%d: 0x%8.8x\n", i, leptr);
-        }
-
-        /* Setup the Rx ring entries */
-        if (DEBUG_IRING)
-                printk ("RX rings:\n");
-        for (i = 0; i < (1<<lp->lance_log_rx_bufs); i++) {
-                leptr = LANCE_ADDR(&aib->rx_buf[i][0]);
-
-                ib->brx_ring [i].rmd0      = leptr;
-                ib->brx_ring [i].rmd1_hadr = leptr >> 16;
-                ib->brx_ring [i].rmd1_bits = LE_R1_OWN;
-                /* 0xf000 == bits that must be one (reserved, presumably) */
-                ib->brx_ring [i].length    = -RX_BUFF_SIZE | 0xf000;
-                ib->brx_ring [i].mblength  = 0;
-                if (DEBUG_IRING)
-                        printk ("%d: 0x%8.8x\n", i, leptr);
-        }
-
-        /* Setup the initialization block */
-
-        /* Setup rx descriptor pointer */
-        leptr = LANCE_ADDR(&aib->brx_ring);
-        ib->rx_len = (lp->lance_log_rx_bufs << 13) | (leptr >> 16);
-        ib->rx_ptr = leptr;
-        if (DEBUG_IRING)
-                printk ("RX ptr: %8.8x\n", leptr);
-
-        /* Setup tx descriptor pointer */
-        leptr = LANCE_ADDR(&aib->btx_ring);
-        ib->tx_len = (lp->lance_log_tx_bufs << 13) | (leptr >> 16);
-        ib->tx_ptr = leptr;
-        if (DEBUG_IRING)
-                printk ("TX ptr: %8.8x\n", leptr);
-
-        /* Clear the multicast filter */
-        ib->filter [0] = 0;
-        ib->filter [1] = 0;
-        PRINT_RINGS();
+	/* Setup the Tx ring entries */
+	for (i = 0; i < (1 << lp->lance_log_tx_bufs); i++) {
+		leptr = LANCE_ADDR(&aib->tx_buf[i][0]);
+		ib->btx_ring[i].tmd0      = leptr;
+		ib->btx_ring[i].tmd1_hadr = leptr >> 16;
+		ib->btx_ring[i].tmd1_bits = 0;
+		ib->btx_ring[i].length    = 0xf000; /* The ones required by tmd2 */
+		ib->btx_ring[i].misc      = 0;
+		if (DEBUG_IRING)
+			printk("%d: 0x%8.8x\n", i, leptr);
+	}
+
+	/* Setup the Rx ring entries */
+	if (DEBUG_IRING)
+		printk("RX rings:\n");
+	for (i = 0; i < (1 << lp->lance_log_rx_bufs); i++) {
+		leptr = LANCE_ADDR(&aib->rx_buf[i][0]);
+
+		ib->brx_ring[i].rmd0      = leptr;
+		ib->brx_ring[i].rmd1_hadr = leptr >> 16;
+		ib->brx_ring[i].rmd1_bits = LE_R1_OWN;
+		/* 0xf000 == bits that must be one (reserved, presumably) */
+		ib->brx_ring[i].length    = -RX_BUFF_SIZE | 0xf000;
+		ib->brx_ring[i].mblength  = 0;
+		if (DEBUG_IRING)
+			printk("%d: 0x%8.8x\n", i, leptr);
+	}
+
+	/* Setup the initialization block */
+
+	/* Setup rx descriptor pointer */
+	leptr = LANCE_ADDR(&aib->brx_ring);
+	ib->rx_len = (lp->lance_log_rx_bufs << 13) | (leptr >> 16);
+	ib->rx_ptr = leptr;
+	if (DEBUG_IRING)
+		printk("RX ptr: %8.8x\n", leptr);
+
+	/* Setup tx descriptor pointer */
+	leptr = LANCE_ADDR(&aib->btx_ring);
+	ib->tx_len = (lp->lance_log_tx_bufs << 13) | (leptr >> 16);
+	ib->tx_ptr = leptr;
+	if (DEBUG_IRING)
+		printk("TX ptr: %8.8x\n", leptr);
+
+	/* Clear the multicast filter */
+	ib->filter[0] = 0;
+	ib->filter[1] = 0;
+	PRINT_RINGS();
 }
 
 /* LANCE must be STOPped before we do this, too... */
-static int init_restart_lance (struct lance_private *lp)
+static int init_restart_lance(struct lance_private *lp)
 {
-        int i;
+	int i;
 
-        WRITERAP(lp, LE_CSR0);
-        WRITERDP(lp, LE_C0_INIT);
+	WRITERAP(lp, LE_CSR0);
+	WRITERDP(lp, LE_C0_INIT);
 
-        /* Need a hook here for sunlance ledma stuff */
+	/* Need a hook here for sunlance ledma stuff */
 
-        /* Wait for the lance to complete initialization */
-        for (i = 0; (i < 100) && !(READRDP(lp) & (LE_C0_ERR | LE_C0_IDON)); i++)
-                barrier();
-        if ((i == 100) || (READRDP(lp) & LE_C0_ERR)) {
-                printk ("LANCE unopened after %d ticks, csr0=%4.4x.\n", i, READRDP(lp));
-                return -1;
-        }
+	/* Wait for the lance to complete initialization */
+	for (i = 0; (i < 100) && !(READRDP(lp) & (LE_C0_ERR | LE_C0_IDON)); i++)
+		barrier();
+	if ((i == 100) || (READRDP(lp) & LE_C0_ERR)) {
+		printk("LANCE unopened after %d ticks, csr0=%4.4x.\n", i, READRDP(lp));
+		return -1;
+	}
 
-        /* Clear IDON by writing a "1", enable interrupts and start lance */
-        WRITERDP(lp, LE_C0_IDON);
-        WRITERDP(lp, LE_C0_INEA | LE_C0_STRT);
+	/* Clear IDON by writing a "1", enable interrupts and start lance */
+	WRITERDP(lp, LE_C0_IDON);
+	WRITERDP(lp, LE_C0_INEA | LE_C0_STRT);
 
-        return 0;
+	return 0;
 }
 
-static int lance_reset (struct net_device *dev)
+static int lance_reset(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
-        int status;
+	struct lance_private *lp = netdev_priv(dev);
+	int status;
 
-        /* Stop the lance */
-        WRITERAP(lp, LE_CSR0);
-        WRITERDP(lp, LE_C0_STOP);
+	/* Stop the lance */
+	WRITERAP(lp, LE_CSR0);
+	WRITERDP(lp, LE_C0_STOP);
 
-        load_csrs (lp);
-        lance_init_ring (dev);
-        dev->trans_start = jiffies; /* prevent tx timeout */
-        status = init_restart_lance (lp);
+	load_csrs(lp);
+	lance_init_ring(dev);
+	dev->trans_start = jiffies; /* prevent tx timeout */
+	status = init_restart_lance(lp);
 #ifdef DEBUG_DRIVER
-        printk ("Lance restart=%d\n", status);
+	printk("Lance restart=%d\n", status);
 #endif
-        return status;
+	return status;
 }
 
-static int lance_rx (struct net_device *dev)
+static int lance_rx(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
-        volatile struct lance_init_block *ib = lp->init_block;
-        volatile struct lance_rx_desc *rd;
-        unsigned char bits;
+	struct lance_private *lp = netdev_priv(dev);
+	volatile struct lance_init_block *ib = lp->init_block;
+	volatile struct lance_rx_desc *rd;
+	unsigned char bits;
 #ifdef TEST_HITS
-        int i;
+	int i;
 #endif
 
 #ifdef TEST_HITS
-        printk ("[");
-        for (i = 0; i < RX_RING_SIZE; i++) {
-                if (i == lp->rx_new)
-                        printk ("%s",
-                                ib->brx_ring [i].rmd1_bits & LE_R1_OWN ? "_" : "X");
-                else
-                        printk ("%s",
-                                ib->brx_ring [i].rmd1_bits & LE_R1_OWN ? "." : "1");
-        }
-        printk ("]");
+	printk("[");
+	for (i = 0; i < RX_RING_SIZE; i++) {
+		if (i == lp->rx_new)
+			printk("%s",
+			       ib->brx_ring[i].rmd1_bits & LE_R1_OWN ? "_" : "X");
+		else
+			printk("%s",
+			      ib->brx_ring[i].rmd1_bits & LE_R1_OWN ? "." : "1");
+	}
+	printk("]");
 #endif
 #ifdef CONFIG_HP300
 	blinken_leds(0x40, 0);
 #endif
-        WRITERDP(lp, LE_C0_RINT | LE_C0_INEA);     /* ack Rx int, reenable ints */
-        for (rd = &ib->brx_ring [lp->rx_new];     /* For each Rx ring we own... */
-             !((bits = rd->rmd1_bits) & LE_R1_OWN);
-             rd = &ib->brx_ring [lp->rx_new]) {
-
-                /* We got an incomplete frame? */
-                if ((bits & LE_R1_POK) != LE_R1_POK) {
-                        dev->stats.rx_over_errors++;
-                        dev->stats.rx_errors++;
-                        continue;
-                } else if (bits & LE_R1_ERR) {
-                        /* Count only the end frame as a rx error,
-                         * not the beginning
-                         */
-                        if (bits & LE_R1_BUF) dev->stats.rx_fifo_errors++;
-                        if (bits & LE_R1_CRC) dev->stats.rx_crc_errors++;
-                        if (bits & LE_R1_OFL) dev->stats.rx_over_errors++;
-                        if (bits & LE_R1_FRA) dev->stats.rx_frame_errors++;
-                        if (bits & LE_R1_EOP) dev->stats.rx_errors++;
-                } else {
+	WRITERDP(lp, LE_C0_RINT | LE_C0_INEA);     /* ack Rx int, reenable ints */
+	for (rd = &ib->brx_ring[lp->rx_new];     /* For each Rx ring we own... */
+	     !((bits = rd->rmd1_bits) & LE_R1_OWN);
+	     rd = &ib->brx_ring[lp->rx_new]) {
+
+		/* We got an incomplete frame? */
+		if ((bits & LE_R1_POK) != LE_R1_POK) {
+			dev->stats.rx_over_errors++;
+			dev->stats.rx_errors++;
+			continue;
+		} else if (bits & LE_R1_ERR) {
+			/* Count only the end frame as a rx error,
+			 * not the beginning
+			 */
+			if (bits & LE_R1_BUF)
+				dev->stats.rx_fifo_errors++;
+			if (bits & LE_R1_CRC)
+				dev->stats.rx_crc_errors++;
+			if (bits & LE_R1_OFL)
+				dev->stats.rx_over_errors++;
+			if (bits & LE_R1_FRA)
+				dev->stats.rx_frame_errors++;
+			if (bits & LE_R1_EOP)
+				dev->stats.rx_errors++;
+		} else {
 			int len = (rd->mblength & 0xfff) - 4;
 			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
-                        if (!skb) {
-                                dev->stats.rx_dropped++;
-                                rd->mblength = 0;
-                                rd->rmd1_bits = LE_R1_OWN;
-                                lp->rx_new = (lp->rx_new + 1) & lp->rx_ring_mod_mask;
-                                return 0;
-                        }
-
-                        skb_reserve (skb, 2);           /* 16 byte align */
-                        skb_put (skb, len);             /* make room */
-                        skb_copy_to_linear_data(skb,
-                                         (unsigned char *)&(ib->rx_buf [lp->rx_new][0]),
-                                         len);
-                        skb->protocol = eth_type_trans (skb, dev);
-			netif_rx (skb);
+			if (!skb) {
+				dev->stats.rx_dropped++;
+				rd->mblength = 0;
+				rd->rmd1_bits = LE_R1_OWN;
+				lp->rx_new = (lp->rx_new + 1) & lp->rx_ring_mod_mask;
+				return 0;
+			}
+
+			skb_reserve(skb, 2);           /* 16 byte align */
+			skb_put(skb, len);             /* make room */
+			skb_copy_to_linear_data(skb,
+					 (unsigned char *)&(ib->rx_buf[lp->rx_new][0]),
+					 len);
+			skb->protocol = eth_type_trans(skb, dev);
+			netif_rx(skb);
 			dev->stats.rx_packets++;
 			dev->stats.rx_bytes += len;
-                }
-
-                /* Return the packet to the pool */
-                rd->mblength = 0;
-                rd->rmd1_bits = LE_R1_OWN;
-                lp->rx_new = (lp->rx_new + 1) & lp->rx_ring_mod_mask;
-        }
-        return 0;
+		}
+
+		/* Return the packet to the pool */
+		rd->mblength = 0;
+		rd->rmd1_bits = LE_R1_OWN;
+		lp->rx_new = (lp->rx_new + 1) & lp->rx_ring_mod_mask;
+	}
+	return 0;
 }
 
-static int lance_tx (struct net_device *dev)
+static int lance_tx(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
-        volatile struct lance_init_block *ib = lp->init_block;
-        volatile struct lance_tx_desc *td;
-        int i, j;
-        int status;
+	struct lance_private *lp = netdev_priv(dev);
+	volatile struct lance_init_block *ib = lp->init_block;
+	volatile struct lance_tx_desc *td;
+	int i, j;
+	int status;
 
 #ifdef CONFIG_HP300
 	blinken_leds(0x80, 0);
 #endif
-        /* csr0 is 2f3 */
-        WRITERDP(lp, LE_C0_TINT | LE_C0_INEA);
-        /* csr0 is 73 */
-
-        j = lp->tx_old;
-        for (i = j; i != lp->tx_new; i = j) {
-                td = &ib->btx_ring [i];
-
-                /* If we hit a packet not owned by us, stop */
-                if (td->tmd1_bits & LE_T1_OWN)
-                        break;
-
-                if (td->tmd1_bits & LE_T1_ERR) {
-                        status = td->misc;
-
-                        dev->stats.tx_errors++;
-                        if (status & LE_T3_RTY)  dev->stats.tx_aborted_errors++;
-                        if (status & LE_T3_LCOL) dev->stats.tx_window_errors++;
-
-                        if (status & LE_T3_CLOS) {
-                                dev->stats.tx_carrier_errors++;
-                                if (lp->auto_select) {
-                                        lp->tpe = 1 - lp->tpe;
-                                        printk("%s: Carrier Lost, trying %s\n",
-                                               dev->name, lp->tpe?"TPE":"AUI");
-                                        /* Stop the lance */
-                                        WRITERAP(lp, LE_CSR0);
-                                        WRITERDP(lp, LE_C0_STOP);
-                                        lance_init_ring (dev);
-                                        load_csrs (lp);
-                                        init_restart_lance (lp);
-                                        return 0;
-                                }
-                        }
-
-                        /* buffer errors and underflows turn off the transmitter */
-                        /* Restart the adapter */
-                        if (status & (LE_T3_BUF|LE_T3_UFL)) {
-                                dev->stats.tx_fifo_errors++;
-
-                                printk ("%s: Tx: ERR_BUF|ERR_UFL, restarting\n",
-                                        dev->name);
-                                /* Stop the lance */
-                                WRITERAP(lp, LE_CSR0);
-                                WRITERDP(lp, LE_C0_STOP);
-                                lance_init_ring (dev);
-                                load_csrs (lp);
-                                init_restart_lance (lp);
-                                return 0;
-                        }
-                } else if ((td->tmd1_bits & LE_T1_POK) == LE_T1_POK) {
-                        /*
-                         * So we don't count the packet more than once.
-                         */
-                        td->tmd1_bits &= ~(LE_T1_POK);
-
-                        /* One collision before packet was sent. */
-                        if (td->tmd1_bits & LE_T1_EONE)
-                                dev->stats.collisions++;
-
-                        /* More than one collision, be optimistic. */
-                        if (td->tmd1_bits & LE_T1_EMORE)
-                                dev->stats.collisions += 2;
-
-                        dev->stats.tx_packets++;
-                }
-
-                j = (j + 1) & lp->tx_ring_mod_mask;
-        }
-        lp->tx_old = j;
-        WRITERDP(lp, LE_C0_TINT | LE_C0_INEA);
-        return 0;
+	/* csr0 is 2f3 */
+	WRITERDP(lp, LE_C0_TINT | LE_C0_INEA);
+	/* csr0 is 73 */
+
+	j = lp->tx_old;
+	for (i = j; i != lp->tx_new; i = j) {
+		td = &ib->btx_ring[i];
+
+		/* If we hit a packet not owned by us, stop */
+		if (td->tmd1_bits & LE_T1_OWN)
+			break;
+
+		if (td->tmd1_bits & LE_T1_ERR) {
+			status = td->misc;
+
+			dev->stats.tx_errors++;
+			if (status & LE_T3_RTY)
+				dev->stats.tx_aborted_errors++;
+			if (status & LE_T3_LCOL)
+				dev->stats.tx_window_errors++;
+
+			if (status & LE_T3_CLOS) {
+				dev->stats.tx_carrier_errors++;
+				if (lp->auto_select) {
+					lp->tpe = 1 - lp->tpe;
+					printk("%s: Carrier Lost, trying %s\n",
+					       dev->name,
+					       lp->tpe ? "TPE" : "AUI");
+					/* Stop the lance */
+					WRITERAP(lp, LE_CSR0);
+					WRITERDP(lp, LE_C0_STOP);
+					lance_init_ring(dev);
+					load_csrs(lp);
+					init_restart_lance(lp);
+					return 0;
+				}
+			}
+
+			/* buffer errors and underflows turn off the transmitter */
+			/* Restart the adapter */
+			if (status & (LE_T3_BUF|LE_T3_UFL)) {
+				dev->stats.tx_fifo_errors++;
+
+				printk("%s: Tx: ERR_BUF|ERR_UFL, restarting\n",
+				       dev->name);
+				/* Stop the lance */
+				WRITERAP(lp, LE_CSR0);
+				WRITERDP(lp, LE_C0_STOP);
+				lance_init_ring(dev);
+				load_csrs(lp);
+				init_restart_lance(lp);
+				return 0;
+			}
+		} else if ((td->tmd1_bits & LE_T1_POK) == LE_T1_POK) {
+			/*
+			 * So we don't count the packet more than once.
+			 */
+			td->tmd1_bits &= ~(LE_T1_POK);
+
+			/* One collision before packet was sent. */
+			if (td->tmd1_bits & LE_T1_EONE)
+				dev->stats.collisions++;
+
+			/* More than one collision, be optimistic. */
+			if (td->tmd1_bits & LE_T1_EMORE)
+				dev->stats.collisions += 2;
+
+			dev->stats.tx_packets++;
+		}
+
+		j = (j + 1) & lp->tx_ring_mod_mask;
+	}
+	lp->tx_old = j;
+	WRITERDP(lp, LE_C0_TINT | LE_C0_INEA);
+	return 0;
 }
 
 static irqreturn_t
-lance_interrupt (int irq, void *dev_id)
+lance_interrupt(int irq, void *dev_id)
 {
-        struct net_device *dev = (struct net_device *)dev_id;
-        struct lance_private *lp = netdev_priv(dev);
-        int csr0;
+	struct net_device *dev = (struct net_device *)dev_id;
+	struct lance_private *lp = netdev_priv(dev);
+	int csr0;
 
-	spin_lock (&lp->devlock);
+	spin_lock(&lp->devlock);
 
-        WRITERAP(lp, LE_CSR0);              /* LANCE Controller Status */
-        csr0 = READRDP(lp);
+	WRITERAP(lp, LE_CSR0);              /* LANCE Controller Status */
+	csr0 = READRDP(lp);
 
-        PRINT_RINGS();
+	PRINT_RINGS();
 
-        if (!(csr0 & LE_C0_INTR)) {     /* Check if any interrupt has */
-		spin_unlock (&lp->devlock);
-                return IRQ_NONE;        /* been generated by the Lance. */
+	if (!(csr0 & LE_C0_INTR)) {     /* Check if any interrupt has */
+		spin_unlock(&lp->devlock);
+		return IRQ_NONE;        /* been generated by the Lance. */
 	}
 
-        /* Acknowledge all the interrupt sources ASAP */
-        WRITERDP(lp, csr0 & ~(LE_C0_INEA|LE_C0_TDMD|LE_C0_STOP|LE_C0_STRT|LE_C0_INIT));
-
-        if ((csr0 & LE_C0_ERR)) {
-                /* Clear the error condition */
-                WRITERDP(lp, LE_C0_BABL|LE_C0_ERR|LE_C0_MISS|LE_C0_INEA);
-        }
-
-        if (csr0 & LE_C0_RINT)
-                lance_rx (dev);
-
-        if (csr0 & LE_C0_TINT)
-                lance_tx (dev);
-
-        /* Log misc errors. */
-        if (csr0 & LE_C0_BABL)
-                dev->stats.tx_errors++;       /* Tx babble. */
-        if (csr0 & LE_C0_MISS)
-                dev->stats.rx_errors++;       /* Missed a Rx frame. */
-        if (csr0 & LE_C0_MERR) {
-                printk("%s: Bus master arbitration failure, status %4.4x.\n",
-                       dev->name, csr0);
-                /* Restart the chip. */
-                WRITERDP(lp, LE_C0_STRT);
-        }
-
-        if (lp->tx_full && netif_queue_stopped(dev) && (TX_BUFFS_AVAIL >= 0)) {
+	/* Acknowledge all the interrupt sources ASAP */
+	WRITERDP(lp, csr0 & ~(LE_C0_INEA|LE_C0_TDMD|LE_C0_STOP|LE_C0_STRT|LE_C0_INIT));
+
+	if ((csr0 & LE_C0_ERR)) {
+		/* Clear the error condition */
+		WRITERDP(lp, LE_C0_BABL|LE_C0_ERR|LE_C0_MISS|LE_C0_INEA);
+	}
+
+	if (csr0 & LE_C0_RINT)
+		lance_rx(dev);
+
+	if (csr0 & LE_C0_TINT)
+		lance_tx(dev);
+
+	/* Log misc errors. */
+	if (csr0 & LE_C0_BABL)
+		dev->stats.tx_errors++;       /* Tx babble. */
+	if (csr0 & LE_C0_MISS)
+		dev->stats.rx_errors++;       /* Missed a Rx frame. */
+	if (csr0 & LE_C0_MERR) {
+		printk("%s: Bus master arbitration failure, status %4.4x.\n",
+		       dev->name, csr0);
+		/* Restart the chip. */
+		WRITERDP(lp, LE_C0_STRT);
+	}
+
+	if (lp->tx_full && netif_queue_stopped(dev) && (TX_BUFFS_AVAIL >= 0)) {
 		lp->tx_full = 0;
-		netif_wake_queue (dev);
-        }
+		netif_wake_queue(dev);
+	}
 
-        WRITERAP(lp, LE_CSR0);
-        WRITERDP(lp, LE_C0_BABL|LE_C0_CERR|LE_C0_MISS|LE_C0_MERR|LE_C0_IDON|LE_C0_INEA);
+	WRITERAP(lp, LE_CSR0);
+	WRITERDP(lp, LE_C0_BABL|LE_C0_CERR|LE_C0_MISS|LE_C0_MERR|LE_C0_IDON|LE_C0_INEA);
 
-	spin_unlock (&lp->devlock);
+	spin_unlock(&lp->devlock);
 	return IRQ_HANDLED;
 }
 
-int lance_open (struct net_device *dev)
+int lance_open(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
+	struct lance_private *lp = netdev_priv(dev);
 	int res;
 
-        /* Install the Interrupt handler. Or we could shunt this out to specific drivers? */
-        if (request_irq(lp->irq, lance_interrupt, IRQF_SHARED, lp->name, dev))
-                return -EAGAIN;
+	/* Install the Interrupt handler. Or we could shunt this out to specific drivers? */
+	if (request_irq(lp->irq, lance_interrupt, IRQF_SHARED, lp->name, dev))
+		return -EAGAIN;
 
-        res = lance_reset(dev);
+	res = lance_reset(dev);
 	spin_lock_init(&lp->devlock);
-	netif_start_queue (dev);
+	netif_start_queue(dev);
 
 	return res;
 }
 EXPORT_SYMBOL_GPL(lance_open);
 
-int lance_close (struct net_device *dev)
+int lance_close(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
+	struct lance_private *lp = netdev_priv(dev);
 
-	netif_stop_queue (dev);
+	netif_stop_queue(dev);
 
-        /* Stop the LANCE */
-        WRITERAP(lp, LE_CSR0);
-        WRITERDP(lp, LE_C0_STOP);
+	/* Stop the LANCE */
+	WRITERAP(lp, LE_CSR0);
+	WRITERDP(lp, LE_C0_STOP);
 
-        free_irq(lp->irq, dev);
+	free_irq(lp->irq, dev);
 
-        return 0;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(lance_close);
 
@@ -524,122 +532,122 @@ void lance_tx_timeout(struct net_device *dev)
 	printk("lance_tx_timeout\n");
 	lance_reset(dev);
 	dev->trans_start = jiffies; /* prevent tx timeout */
-	netif_wake_queue (dev);
+	netif_wake_queue(dev);
 }
 EXPORT_SYMBOL_GPL(lance_tx_timeout);
 
-int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
+int lance_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
-        volatile struct lance_init_block *ib = lp->init_block;
-        int entry, skblen, len;
-        static int outs;
+	struct lance_private *lp = netdev_priv(dev);
+	volatile struct lance_init_block *ib = lp->init_block;
+	int entry, skblen, len;
+	static int outs;
 	unsigned long flags;
 
-        if (!TX_BUFFS_AVAIL)
-                return NETDEV_TX_LOCKED;
+	if (!TX_BUFFS_AVAIL)
+		return NETDEV_TX_LOCKED;
 
-	netif_stop_queue (dev);
+	netif_stop_queue(dev);
 
-        skblen = skb->len;
+	skblen = skb->len;
 
 #ifdef DEBUG_DRIVER
-        /* dump the packet */
-        {
-                int i;
-
-                for (i = 0; i < 64; i++) {
-                        if ((i % 16) == 0)
-                                printk ("\n");
-                        printk ("%2.2x ", skb->data [i]);
-                }
-        }
+	/* dump the packet */
+	{
+		int i;
+
+		for (i = 0; i < 64; i++) {
+			if ((i % 16) == 0)
+				printk("\n");
+			printk("%2.2x ", skb->data[i]);
+		}
+	}
 #endif
-        len = (skblen <= ETH_ZLEN) ? ETH_ZLEN : skblen;
-        entry = lp->tx_new & lp->tx_ring_mod_mask;
-        ib->btx_ring [entry].length = (-len) | 0xf000;
-        ib->btx_ring [entry].misc = 0;
+	len = (skblen <= ETH_ZLEN) ? ETH_ZLEN : skblen;
+	entry = lp->tx_new & lp->tx_ring_mod_mask;
+	ib->btx_ring[entry].length = (-len) | 0xf000;
+	ib->btx_ring[entry].misc = 0;
 
 	if (skb->len < ETH_ZLEN)
 		memset((void *)&ib->tx_buf[entry][0], 0, ETH_ZLEN);
-        skb_copy_from_linear_data(skb, (void *)&ib->tx_buf[entry][0], skblen);
+	skb_copy_from_linear_data(skb, (void *)&ib->tx_buf[entry][0], skblen);
 
-        /* Now, give the packet to the lance */
-        ib->btx_ring [entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
-        lp->tx_new = (lp->tx_new+1) & lp->tx_ring_mod_mask;
+	/* Now, give the packet to the lance */
+	ib->btx_ring[entry].tmd1_bits = (LE_T1_POK|LE_T1_OWN);
+	lp->tx_new = (lp->tx_new + 1) & lp->tx_ring_mod_mask;
 
-        outs++;
-        /* Kick the lance: transmit now */
-        WRITERDP(lp, LE_C0_INEA | LE_C0_TDMD);
-        dev_kfree_skb (skb);
+	outs++;
+	/* Kick the lance: transmit now */
+	WRITERDP(lp, LE_C0_INEA | LE_C0_TDMD);
+	dev_kfree_skb(skb);
 
-	spin_lock_irqsave (&lp->devlock, flags);
-        if (TX_BUFFS_AVAIL)
-		netif_start_queue (dev);
+	spin_lock_irqsave(&lp->devlock, flags);
+	if (TX_BUFFS_AVAIL)
+		netif_start_queue(dev);
 	else
 		lp->tx_full = 1;
-	spin_unlock_irqrestore (&lp->devlock, flags);
+	spin_unlock_irqrestore(&lp->devlock, flags);
 
-        return NETDEV_TX_OK;
+	return NETDEV_TX_OK;
 }
 EXPORT_SYMBOL_GPL(lance_start_xmit);
 
 /* taken from the depca driver via a2065.c */
-static void lance_load_multicast (struct net_device *dev)
+static void lance_load_multicast(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
-        volatile struct lance_init_block *ib = lp->init_block;
-        volatile u16 *mcast_table = (u16 *)&ib->filter;
+	struct lance_private *lp = netdev_priv(dev);
+	volatile struct lance_init_block *ib = lp->init_block;
+	volatile u16 *mcast_table = (u16 *)&ib->filter;
 	struct netdev_hw_addr *ha;
-        u32 crc;
-
-        /* set all multicast bits */
-        if (dev->flags & IFF_ALLMULTI){
-                ib->filter [0] = 0xffffffff;
-                ib->filter [1] = 0xffffffff;
-                return;
-        }
-        /* clear the multicast filter */
-        ib->filter [0] = 0;
-        ib->filter [1] = 0;
-
-        /* Add addresses */
+	u32 crc;
+
+	/* set all multicast bits */
+	if (dev->flags & IFF_ALLMULTI) {
+		ib->filter[0] = 0xffffffff;
+		ib->filter[1] = 0xffffffff;
+		return;
+	}
+	/* clear the multicast filter */
+	ib->filter[0] = 0;
+	ib->filter[1] = 0;
+
+	/* Add addresses */
 	netdev_for_each_mc_addr(ha, dev) {
 		crc = ether_crc_le(6, ha->addr);
-                crc = crc >> 26;
-                mcast_table [crc >> 4] |= 1 << (crc & 0xf);
-        }
+		crc = crc >> 26;
+		mcast_table[crc >> 4] |= 1 << (crc & 0xf);
+	}
 }
 
 
-void lance_set_multicast (struct net_device *dev)
+void lance_set_multicast(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
-        volatile struct lance_init_block *ib = lp->init_block;
+	struct lance_private *lp = netdev_priv(dev);
+	volatile struct lance_init_block *ib = lp->init_block;
 	int stopped;
 
 	stopped = netif_queue_stopped(dev);
 	if (!stopped)
-		netif_stop_queue (dev);
-
-        while (lp->tx_old != lp->tx_new)
-                schedule();
+		netif_stop_queue(dev);
 
-        WRITERAP(lp, LE_CSR0);
-        WRITERDP(lp, LE_C0_STOP);
-        lance_init_ring (dev);
+	while (lp->tx_old != lp->tx_new)
+		schedule();
 
-        if (dev->flags & IFF_PROMISC) {
-                ib->mode |= LE_MO_PROM;
-        } else {
-                ib->mode &= ~LE_MO_PROM;
-                lance_load_multicast (dev);
-        }
-        load_csrs (lp);
-        init_restart_lance (lp);
+	WRITERAP(lp, LE_CSR0);
+	WRITERDP(lp, LE_C0_STOP);
+	lance_init_ring(dev);
+
+	if (dev->flags & IFF_PROMISC) {
+		ib->mode |= LE_MO_PROM;
+	} else {
+		ib->mode &= ~LE_MO_PROM;
+		lance_load_multicast(dev);
+	}
+	load_csrs(lp);
+	init_restart_lance(lp);
 
 	if (!stopped)
-		netif_start_queue (dev);
+		netif_start_queue(dev);
 }
 EXPORT_SYMBOL_GPL(lance_set_multicast);
 
@@ -648,10 +656,10 @@ void lance_poll(struct net_device *dev)
 {
 	struct lance_private *lp = netdev_priv(dev);
 
-	spin_lock (&lp->devlock);
+	spin_lock(&lp->devlock);
 	WRITERAP(lp, LE_CSR0);
 	WRITERDP(lp, LE_C0_STRT);
-	spin_unlock (&lp->devlock);
+	spin_unlock(&lp->devlock);
 	lance_interrupt(dev->irq, dev);
 }
 #endif
diff --git a/drivers/net/ethernet/amd/7990.h b/drivers/net/ethernet/amd/7990.h
index 0a5837b96421..6a1a45374aec 100644
--- a/drivers/net/ethernet/amd/7990.h
+++ b/drivers/net/ethernet/amd/7990.h
@@ -35,33 +35,32 @@
 #define LANCE_LOG_RX_BUFFERS 3
 #endif
 
-#define TX_RING_SIZE (1<<LANCE_LOG_TX_BUFFERS)
-#define RX_RING_SIZE (1<<LANCE_LOG_RX_BUFFERS)
-#define TX_RING_MOD_MASK (TX_RING_SIZE - 1)
-#define RX_RING_MOD_MASK (RX_RING_SIZE - 1)
-#define TX_RING_LEN_BITS ((LANCE_LOG_TX_BUFFERS) << 29)
-#define RX_RING_LEN_BITS ((LANCE_LOG_RX_BUFFERS) << 29)
-#define PKT_BUFF_SIZE (1544)
-#define RX_BUFF_SIZE PKT_BUFF_SIZE
-#define TX_BUFF_SIZE PKT_BUFF_SIZE
+#define TX_RING_SIZE		(1 << LANCE_LOG_TX_BUFFERS)
+#define RX_RING_SIZE		(1 << LANCE_LOG_RX_BUFFERS)
+#define TX_RING_MOD_MASK	(TX_RING_SIZE - 1)
+#define RX_RING_MOD_MASK	(RX_RING_SIZE - 1)
+#define TX_RING_LEN_BITS	((LANCE_LOG_TX_BUFFERS) << 29)
+#define RX_RING_LEN_BITS	((LANCE_LOG_RX_BUFFERS) << 29)
+#define PKT_BUFF_SIZE		(1544)
+#define RX_BUFF_SIZE		PKT_BUFF_SIZE
+#define TX_BUFF_SIZE		PKT_BUFF_SIZE
 
 /* Each receive buffer is described by a receive message descriptor (RMD) */
 struct lance_rx_desc {
-	volatile unsigned short rmd0;        /* low address of packet */
-	volatile unsigned char  rmd1_bits;   /* descriptor bits */
-	volatile unsigned char  rmd1_hadr;   /* high address of packet */
-	volatile short    length;    	    /* This length is 2s complement (negative)!
-				     * Buffer length
-				     */
-	volatile unsigned short mblength;    /* Actual number of bytes received */
+	volatile unsigned short rmd0;	    /* low address of packet */
+	volatile unsigned char  rmd1_bits;  /* descriptor bits */
+	volatile unsigned char  rmd1_hadr;  /* high address of packet */
+	volatile short    length;	    /* This length is 2s complement (negative)!
+					     * Buffer length */
+	volatile unsigned short mblength;   /* Actual number of bytes received */
 };
 
 /* Ditto for TMD: */
 struct lance_tx_desc {
-	volatile unsigned short tmd0;        /* low address of packet */
-	volatile unsigned char  tmd1_bits;   /* descriptor bits */
-	volatile unsigned char  tmd1_hadr;   /* high address of packet */
-	volatile short    length;       	    /* Length is 2s complement (negative)! */
+	volatile unsigned short tmd0;	    /* low address of packet */
+	volatile unsigned char  tmd1_bits;  /* descriptor bits */
+	volatile unsigned char  tmd1_hadr;  /* high address of packet */
+	volatile short    length;	    /* Length is 2s complement (negative)! */
 	volatile unsigned short misc;
 };
 
@@ -71,181 +70,178 @@ struct lance_tx_desc {
  * init block,the Tx and Rx rings and the buffers together in memory:
  */
 struct lance_init_block {
-        volatile unsigned short mode;            /* Pre-set mode (reg. 15) */
-        volatile unsigned char phys_addr[6];     /* Physical ethernet address */
-        volatile unsigned filter[2];             /* Multicast filter (64 bits) */
-
-        /* Receive and transmit ring base, along with extra bits. */
-        volatile unsigned short rx_ptr;          /* receive descriptor addr */
-        volatile unsigned short rx_len;          /* receive len and high addr */
-        volatile unsigned short tx_ptr;          /* transmit descriptor addr */
-        volatile unsigned short tx_len;          /* transmit len and high addr */
-
-        /* The Tx and Rx ring entries must be aligned on 8-byte boundaries.
-         * This will be true if this whole struct is 8-byte aligned.
-         */
-        volatile struct lance_tx_desc btx_ring[TX_RING_SIZE];
-        volatile struct lance_rx_desc brx_ring[RX_RING_SIZE];
-
-        volatile char   tx_buf [TX_RING_SIZE][TX_BUFF_SIZE];
-        volatile char   rx_buf [RX_RING_SIZE][RX_BUFF_SIZE];
-        /* we use this just to make the struct big enough that we can move its startaddr
-         * in order to force alignment to an eight byte boundary.
-         */
+	volatile unsigned short mode;		/* Pre-set mode (reg. 15) */
+	volatile unsigned char phys_addr[6];	/* Physical ethernet address */
+	volatile unsigned filter[2];		/* Multicast filter (64 bits) */
+
+	/* Receive and transmit ring base, along with extra bits. */
+	volatile unsigned short rx_ptr;		/* receive descriptor addr */
+	volatile unsigned short rx_len;		/* receive len and high addr */
+	volatile unsigned short tx_ptr;		/* transmit descriptor addr */
+	volatile unsigned short tx_len;		/* transmit len and high addr */
+
+	/* The Tx and Rx ring entries must be aligned on 8-byte boundaries.
+	 * This will be true if this whole struct is 8-byte aligned.
+	 */
+	volatile struct lance_tx_desc btx_ring[TX_RING_SIZE];
+	volatile struct lance_rx_desc brx_ring[RX_RING_SIZE];
+
+	volatile char tx_buf[TX_RING_SIZE][TX_BUFF_SIZE];
+	volatile char rx_buf[RX_RING_SIZE][RX_BUFF_SIZE];
+	/* we use this just to make the struct big enough that we can move its startaddr
+	 * in order to force alignment to an eight byte boundary.
+	 */
 };
 
 /* This is where we keep all the stuff the driver needs to know about.
  * I'm definitely unhappy about the mechanism for allowing specific
  * drivers to add things...
  */
-struct lance_private
-{
-        char *name;
+struct lance_private {
+	char *name;
 	unsigned long base;
-        volatile struct lance_init_block *init_block; /* CPU address of RAM */
-        volatile struct lance_init_block *lance_init_block; /* LANCE address of RAM */
+	volatile struct lance_init_block *init_block; /* CPU address of RAM */
+	volatile struct lance_init_block *lance_init_block; /* LANCE address of RAM */
 
-        int rx_new, tx_new;
-        int rx_old, tx_old;
+	int rx_new, tx_new;
+	int rx_old, tx_old;
 
-        int lance_log_rx_bufs, lance_log_tx_bufs;
-        int rx_ring_mod_mask, tx_ring_mod_mask;
+	int lance_log_rx_bufs, lance_log_tx_bufs;
+	int rx_ring_mod_mask, tx_ring_mod_mask;
 
-        int tpe;                                  /* TPE is selected */
-        int auto_select;                          /* cable-selection is by carrier */
-        unsigned short busmaster_regval;
+	int tpe;			/* TPE is selected */
+	int auto_select;		/* cable-selection is by carrier */
+	unsigned short busmaster_regval;
 
-        unsigned int irq;                         /* IRQ to register */
+	unsigned int irq;		/* IRQ to register */
 
-        /* This is because the HP LANCE is disgusting and you have to check
-         * a DIO-specific register every time you read/write the LANCE regs :-<
-         * [could we get away with making these some sort of macro?]
-         */
-        void (*writerap)(void *, unsigned short);
-        void (*writerdp)(void *, unsigned short);
-        unsigned short (*readrdp)(void *);
+	/* This is because the HP LANCE is disgusting and you have to check
+	 * a DIO-specific register every time you read/write the LANCE regs :-<
+	 * [could we get away with making these some sort of macro?]
+	 */
+	void (*writerap)(void *, unsigned short);
+	void (*writerdp)(void *, unsigned short);
+	unsigned short (*readrdp)(void *);
 	spinlock_t devlock;
 	char tx_full;
 };
 
 /*
- *              Am7990 Control and Status Registers
+ *		Am7990 Control and Status Registers
  */
-#define LE_CSR0         0x0000          /* LANCE Controller Status */
-#define LE_CSR1         0x0001          /* IADR[15:0] (bit0==0 ie word aligned) */
-#define LE_CSR2         0x0002          /* IADR[23:16] (high bits reserved) */
-#define LE_CSR3         0x0003          /* Misc */
+#define LE_CSR0		0x0000	/* LANCE Controller Status */
+#define LE_CSR1		0x0001	/* IADR[15:0] (bit0==0 ie word aligned) */
+#define LE_CSR2		0x0002	/* IADR[23:16] (high bits reserved) */
+#define LE_CSR3		0x0003	/* Misc */
 
 /*
  *		Bit definitions for CSR0 (LANCE Controller Status)
  */
-#define LE_C0_ERR	0x8000		/* Error = BABL | CERR | MISS | MERR */
-#define LE_C0_BABL	0x4000		/* Babble: Transmitted too many bits */
-#define LE_C0_CERR	0x2000		/* No Heartbeat (10BASE-T) */
-#define LE_C0_MISS	0x1000		/* Missed Frame (no rx buffer to put it in) */
-#define LE_C0_MERR	0x0800		/* Memory Error */
-#define LE_C0_RINT	0x0400		/* Receive Interrupt */
-#define LE_C0_TINT	0x0200		/* Transmit Interrupt */
-#define LE_C0_IDON	0x0100		/* Initialization Done */
-#define LE_C0_INTR	0x0080		/* Interrupt Flag
-                                         = BABL | MISS | MERR | RINT | TINT | IDON */
-#define LE_C0_INEA	0x0040		/* Interrupt Enable */
-#define LE_C0_RXON	0x0020		/* Receive On */
-#define LE_C0_TXON	0x0010		/* Transmit On */
-#define LE_C0_TDMD	0x0008		/* Transmit Demand */
-#define LE_C0_STOP	0x0004		/* Stop */
-#define LE_C0_STRT	0x0002		/* Start */
-#define LE_C0_INIT	0x0001		/* Initialize */
+#define LE_C0_ERR	0x8000	/* Error = BABL | CERR | MISS | MERR */
+#define LE_C0_BABL	0x4000	/* Babble: Transmitted too many bits */
+#define LE_C0_CERR	0x2000	/* No Heartbeat (10BASE-T) */
+#define LE_C0_MISS	0x1000	/* Missed Frame (no rx buffer to put it in) */
+#define LE_C0_MERR	0x0800	/* Memory Error */
+#define LE_C0_RINT	0x0400	/* Receive Interrupt */
+#define LE_C0_TINT	0x0200	/* Transmit Interrupt */
+#define LE_C0_IDON	0x0100	/* Initialization Done */
+#define LE_C0_INTR	0x0080	/* Interrupt Flag
+				   = BABL | MISS | MERR | RINT | TINT | IDON */
+#define LE_C0_INEA	0x0040	/* Interrupt Enable */
+#define LE_C0_RXON	0x0020	/* Receive On */
+#define LE_C0_TXON	0x0010	/* Transmit On */
+#define LE_C0_TDMD	0x0008	/* Transmit Demand */
+#define LE_C0_STOP	0x0004	/* Stop */
+#define LE_C0_STRT	0x0002	/* Start */
+#define LE_C0_INIT	0x0001	/* Initialize */
 
 
 /*
  *		Bit definitions for CSR3
  */
-#define LE_C3_BSWP	0x0004		/* Byte Swap
-					   (on for big endian byte order) */
-#define LE_C3_ACON	0x0002		/* ALE Control
-					   (on for active low ALE) */
-#define LE_C3_BCON	0x0001		/* Byte Control */
+#define LE_C3_BSWP	0x0004	/* Byte Swap (on for big endian byte order) */
+#define LE_C3_ACON	0x0002	/* ALE Control (on for active low ALE) */
+#define LE_C3_BCON	0x0001	/* Byte Control */
 
 
 /*
  *		Mode Flags
  */
-#define LE_MO_PROM	0x8000		/* Promiscuous Mode */
+#define LE_MO_PROM	0x8000	/* Promiscuous Mode */
 /* these next ones 0x4000 -- 0x0080 are not available on the LANCE 7990,
  * but they are in NetBSD's am7990.h, presumably for backwards-compatible chips
  */
-#define LE_MO_DRCVBC  0x4000          /* disable receive broadcast */
-#define LE_MO_DRCVPA  0x2000          /* disable physical address detection */
-#define LE_MO_DLNKTST 0x1000          /* disable link status */
-#define LE_MO_DAPC    0x0800          /* disable automatic polarity correction */
-#define LE_MO_MENDECL 0x0400          /* MENDEC loopback mode */
-#define LE_MO_LRTTSEL 0x0200          /* lower RX threshold / TX mode selection */
-#define LE_MO_PSEL1   0x0100          /* port selection bit1 */
-#define LE_MO_PSEL0   0x0080          /* port selection bit0 */
+#define LE_MO_DRCVBC	0x4000	/* disable receive broadcast */
+#define LE_MO_DRCVPA	0x2000	/* disable physical address detection */
+#define LE_MO_DLNKTST	0x1000	/* disable link status */
+#define LE_MO_DAPC	0x0800	/* disable automatic polarity correction */
+#define LE_MO_MENDECL	0x0400	/* MENDEC loopback mode */
+#define LE_MO_LRTTSEL	0x0200	/* lower RX threshold / TX mode selection */
+#define LE_MO_PSEL1	0x0100	/* port selection bit1 */
+#define LE_MO_PSEL0	0x0080	/* port selection bit0 */
 /* and this one is from the C-LANCE data sheet... */
-#define LE_MO_EMBA      0x0080          /* Enable Modified Backoff Algorithm
-                                           (C-LANCE, not original LANCE) */
-#define LE_MO_INTL	0x0040		/* Internal Loopback */
-#define LE_MO_DRTY	0x0020		/* Disable Retry */
-#define LE_MO_FCOLL	0x0010		/* Force Collision */
-#define LE_MO_DXMTFCS	0x0008		/* Disable Transmit CRC */
-#define LE_MO_LOOP	0x0004		/* Loopback Enable */
-#define LE_MO_DTX	0x0002		/* Disable Transmitter */
-#define LE_MO_DRX	0x0001		/* Disable Receiver */
+#define LE_MO_EMBA	0x0080	/* Enable Modified Backoff Algorithm
+				   (C-LANCE, not original LANCE) */
+#define LE_MO_INTL	0x0040	/* Internal Loopback */
+#define LE_MO_DRTY	0x0020	/* Disable Retry */
+#define LE_MO_FCOLL	0x0010	/* Force Collision */
+#define LE_MO_DXMTFCS	0x0008	/* Disable Transmit CRC */
+#define LE_MO_LOOP	0x0004	/* Loopback Enable */
+#define LE_MO_DTX	0x0002	/* Disable Transmitter */
+#define LE_MO_DRX	0x0001	/* Disable Receiver */
 
 
 /*
  *		Receive Flags
  */
-#define LE_R1_OWN	0x80		/* LANCE owns the descriptor */
-#define LE_R1_ERR	0x40		/* Error */
-#define LE_R1_FRA	0x20		/* Framing Error */
-#define LE_R1_OFL	0x10		/* Overflow Error */
-#define LE_R1_CRC	0x08		/* CRC Error */
-#define LE_R1_BUF	0x04		/* Buffer Error */
-#define LE_R1_SOP	0x02		/* Start of Packet */
-#define LE_R1_EOP	0x01		/* End of Packet */
-#define LE_R1_POK       0x03		/* Packet is complete: SOP + EOP */
+#define LE_R1_OWN	0x80	/* LANCE owns the descriptor */
+#define LE_R1_ERR	0x40	/* Error */
+#define LE_R1_FRA	0x20	/* Framing Error */
+#define LE_R1_OFL	0x10	/* Overflow Error */
+#define LE_R1_CRC	0x08	/* CRC Error */
+#define LE_R1_BUF	0x04	/* Buffer Error */
+#define LE_R1_SOP	0x02	/* Start of Packet */
+#define LE_R1_EOP	0x01	/* End of Packet */
+#define LE_R1_POK	0x03	/* Packet is complete: SOP + EOP */
 
 
 /*
  *		Transmit Flags
  */
-#define LE_T1_OWN	0x80		/* LANCE owns the descriptor */
-#define LE_T1_ERR	0x40		/* Error */
-#define LE_T1_RES	0x20		/* Reserved, LANCE writes this with a zero */
-#define LE_T1_EMORE	0x10		/* More than one retry needed */
-#define LE_T1_EONE	0x08		/* One retry needed */
-#define LE_T1_EDEF	0x04		/* Deferred */
-#define LE_T1_SOP	0x02		/* Start of Packet */
-#define LE_T1_EOP	0x01		/* End of Packet */
-#define LE_T1_POK	0x03		/* Packet is complete: SOP + EOP */
+#define LE_T1_OWN	0x80	/* LANCE owns the descriptor */
+#define LE_T1_ERR	0x40	/* Error */
+#define LE_T1_RES	0x20	/* Reserved, LANCE writes this with a zero */
+#define LE_T1_EMORE	0x10	/* More than one retry needed */
+#define LE_T1_EONE	0x08	/* One retry needed */
+#define LE_T1_EDEF	0x04	/* Deferred */
+#define LE_T1_SOP	0x02	/* Start of Packet */
+#define LE_T1_EOP	0x01	/* End of Packet */
+#define LE_T1_POK	0x03	/* Packet is complete: SOP + EOP */
 
 /*
  *		Error Flags
  */
-#define LE_T3_BUF 	0x8000		/* Buffer Error */
-#define LE_T3_UFL 	0x4000		/* Underflow Error */
-#define LE_T3_LCOL 	0x1000		/* Late Collision */
-#define LE_T3_CLOS 	0x0800		/* Loss of Carrier */
-#define LE_T3_RTY 	0x0400		/* Retry Error */
-#define LE_T3_TDR	0x03ff		/* Time Domain Reflectometry */
+#define LE_T3_BUF	0x8000	/* Buffer Error */
+#define LE_T3_UFL	0x4000	/* Underflow Error */
+#define LE_T3_LCOL	0x1000	/* Late Collision */
+#define LE_T3_CLOS	0x0800	/* Loss of Carrier */
+#define LE_T3_RTY	0x0400	/* Retry Error */
+#define LE_T3_TDR	0x03ff	/* Time Domain Reflectometry */
 
 /* Miscellaneous useful macros */
 
-#define TX_BUFFS_AVAIL ((lp->tx_old<=lp->tx_new)?\
-                        lp->tx_old+lp->tx_ring_mod_mask-lp->tx_new:\
-                        lp->tx_old - lp->tx_new-1)
+#define TX_BUFFS_AVAIL ((lp->tx_old <= lp->tx_new) ? \
+			lp->tx_old + lp->tx_ring_mod_mask - lp->tx_new : \
+			lp->tx_old - lp->tx_new - 1)
 
 /* The LANCE only uses 24 bit addresses. This does the obvious thing. */
 #define LANCE_ADDR(x) ((int)(x) & ~0xff000000)
 
 /* Now the prototypes we export */
 extern int lance_open(struct net_device *dev);
-extern int lance_close (struct net_device *dev);
-extern int lance_start_xmit (struct sk_buff *skb, struct net_device *dev);
-extern void lance_set_multicast (struct net_device *dev);
+extern int lance_close(struct net_device *dev);
+extern int lance_start_xmit(struct sk_buff *skb, struct net_device *dev);
+extern void lance_set_multicast(struct net_device *dev);
 extern void lance_tx_timeout(struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 extern void lance_poll(struct net_device *dev);
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 0c61fd50d882..88a81a18374d 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -127,41 +127,41 @@ static void hplance_remove_one(struct dio_dev *d)
 /* Initialise a single lance board at the given DIO device */
 static void hplance_init(struct net_device *dev, struct dio_dev *d)
 {
-        unsigned long va = (d->resource.start + DIO_VIRADDRBASE);
-        struct hplance_private *lp;
-        int i;
-
-        /* reset the board */
-        out_8(va+DIO_IDOFF, 0xff);
-        udelay(100);                              /* ariba! ariba! udelay! udelay! */
-
-        /* Fill the dev fields */
-        dev->base_addr = va;
-        dev->netdev_ops = &hplance_netdev_ops;
-        dev->dma = 0;
-
-        for (i=0; i<6; i++) {
-                /* The NVRAM holds our ethernet address, one nibble per byte,
-                 * at bytes NVRAMOFF+1,3,5,7,9...
-                 */
-                dev->dev_addr[i] = ((in_8(va + HPLANCE_NVRAMOFF + i*4 + 1) & 0xF) << 4)
-                        | (in_8(va + HPLANCE_NVRAMOFF + i*4 + 3) & 0xF);
-        }
-
-        lp = netdev_priv(dev);
-        lp->lance.name = (char*)d->name;                /* discards const, shut up gcc */
-        lp->lance.base = va;
-        lp->lance.init_block = (struct lance_init_block *)(va + HPLANCE_MEMOFF); /* CPU addr */
-        lp->lance.lance_init_block = NULL;              /* LANCE addr of same RAM */
-        lp->lance.busmaster_regval = LE_C3_BSWP;        /* we're bigendian */
-        lp->lance.irq = d->ipl;
-        lp->lance.writerap = hplance_writerap;
-        lp->lance.writerdp = hplance_writerdp;
-        lp->lance.readrdp = hplance_readrdp;
-        lp->lance.lance_log_rx_bufs = LANCE_LOG_RX_BUFFERS;
-        lp->lance.lance_log_tx_bufs = LANCE_LOG_TX_BUFFERS;
-        lp->lance.rx_ring_mod_mask = RX_RING_MOD_MASK;
-        lp->lance.tx_ring_mod_mask = TX_RING_MOD_MASK;
+	unsigned long va = (d->resource.start + DIO_VIRADDRBASE);
+	struct hplance_private *lp;
+	int i;
+
+	/* reset the board */
+	out_8(va + DIO_IDOFF, 0xff);
+	udelay(100);                              /* ariba! ariba! udelay! udelay! */
+
+	/* Fill the dev fields */
+	dev->base_addr = va;
+	dev->netdev_ops = &hplance_netdev_ops;
+	dev->dma = 0;
+
+	for (i = 0; i < 6; i++) {
+		/* The NVRAM holds our ethernet address, one nibble per byte,
+		 * at bytes NVRAMOFF+1,3,5,7,9...
+		 */
+		dev->dev_addr[i] = ((in_8(va + HPLANCE_NVRAMOFF + i*4 + 1) & 0xF) << 4)
+			| (in_8(va + HPLANCE_NVRAMOFF + i*4 + 3) & 0xF);
+	}
+
+	lp = netdev_priv(dev);
+	lp->lance.name = (char *)d->name;                /* discards const, shut up gcc */
+	lp->lance.base = va;
+	lp->lance.init_block = (struct lance_init_block *)(va + HPLANCE_MEMOFF); /* CPU addr */
+	lp->lance.lance_init_block = NULL;              /* LANCE addr of same RAM */
+	lp->lance.busmaster_regval = LE_C3_BSWP;        /* we're bigendian */
+	lp->lance.irq = d->ipl;
+	lp->lance.writerap = hplance_writerap;
+	lp->lance.writerdp = hplance_writerdp;
+	lp->lance.readrdp = hplance_readrdp;
+	lp->lance.lance_log_rx_bufs = LANCE_LOG_RX_BUFFERS;
+	lp->lance.lance_log_tx_bufs = LANCE_LOG_TX_BUFFERS;
+	lp->lance.rx_ring_mod_mask = RX_RING_MOD_MASK;
+	lp->lance.tx_ring_mod_mask = TX_RING_MOD_MASK;
 }
 
 /* This is disgusting. We have to check the DIO status register for ack every
@@ -195,25 +195,25 @@ static unsigned short hplance_readrdp(void *priv)
 
 static int hplance_open(struct net_device *dev)
 {
-        int status;
-        struct lance_private *lp = netdev_priv(dev);
+	int status;
+	struct lance_private *lp = netdev_priv(dev);
 
-        status = lance_open(dev);                 /* call generic lance open code */
-        if (status)
-                return status;
-        /* enable interrupts at board level. */
-        out_8(lp->base + HPLANCE_STATUS, LE_IE);
+	status = lance_open(dev);                 /* call generic lance open code */
+	if (status)
+		return status;
+	/* enable interrupts at board level. */
+	out_8(lp->base + HPLANCE_STATUS, LE_IE);
 
-        return 0;
+	return 0;
 }
 
 static int hplance_close(struct net_device *dev)
 {
-        struct lance_private *lp = netdev_priv(dev);
+	struct lance_private *lp = netdev_priv(dev);
 
-        out_8(lp->base + HPLANCE_STATUS, 0);	/* disable interrupts at boardlevel */
-        lance_close(dev);
-        return 0;
+	out_8(lp->base + HPLANCE_STATUS, 0);	/* disable interrupts at boardlevel */
+	lance_close(dev);
+	return 0;
 }
 
 static int __init hplance_init_module(void)
@@ -223,7 +223,7 @@ static int __init hplance_init_module(void)
 
 static void __exit hplance_cleanup_module(void)
 {
-        dio_unregister_driver(&hplance_driver);
+	dio_unregister_driver(&hplance_driver);
 }
 
 module_init(hplance_init_module);
diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index e108e911da05..15a5e366af29 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -94,33 +94,31 @@ struct net_device * __init mvme147lance_probe(int unit)
 	dev->netdev_ops = &lance_netdev_ops;
 	dev->dma = 0;
 
-	addr=(u_long *)ETHERNET_ADDRESS;
+	addr = (u_long *)ETHERNET_ADDRESS;
 	address = *addr;
-	dev->dev_addr[0]=0x08;
-	dev->dev_addr[1]=0x00;
-	dev->dev_addr[2]=0x3e;
-	address=address>>8;
-	dev->dev_addr[5]=address&0xff;
-	address=address>>8;
-	dev->dev_addr[4]=address&0xff;
-	address=address>>8;
-	dev->dev_addr[3]=address&0xff;
-
-	printk("%s: MVME147 at 0x%08lx, irq %d, "
-	       "Hardware Address %pM\n",
+	dev->dev_addr[0] = 0x08;
+	dev->dev_addr[1] = 0x00;
+	dev->dev_addr[2] = 0x3e;
+	address = address >> 8;
+	dev->dev_addr[5] = address&0xff;
+	address = address >> 8;
+	dev->dev_addr[4] = address&0xff;
+	address = address >> 8;
+	dev->dev_addr[3] = address&0xff;
+
+	printk("%s: MVME147 at 0x%08lx, irq %d, Hardware Address %pM\n",
 	       dev->name, dev->base_addr, MVME147_LANCE_IRQ,
 	       dev->dev_addr);
 
 	lp = netdev_priv(dev);
 	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 16K */
-	if (!lp->ram)
-	{
+	if (!lp->ram) {
 		printk("%s: No memory for LANCE buffers\n", dev->name);
 		free_netdev(dev);
 		return ERR_PTR(-ENOMEM);
 	}
 
-	lp->lance.name = (char*)name;                   /* discards const, shut up gcc */
+	lp->lance.name = (char *)name;                   /* discards const, shut up gcc */
 	lp->lance.base = dev->base_addr;
 	lp->lance.init_block = (struct lance_init_block *)(lp->ram); /* CPU addr */
 	lp->lance.lance_init_block = (struct lance_init_block *)(lp->ram);                 /* LANCE addr of same RAM */
@@ -167,8 +165,8 @@ static int m147lance_open(struct net_device *dev)
 	if (status)
 		return status;
 	/* enable interrupts at board level. */
-	m147_pcc->lan_cntrl=0;       /* clear the interrupts (if any) */
-	m147_pcc->lan_cntrl=0x08 | 0x04;     /* Enable irq 4 */
+	m147_pcc->lan_cntrl = 0;       /* clear the interrupts (if any) */
+	m147_pcc->lan_cntrl = 0x08 | 0x04;     /* Enable irq 4 */
 
 	return 0;
 }
@@ -176,7 +174,7 @@ static int m147lance_open(struct net_device *dev)
 static int m147lance_close(struct net_device *dev)
 {
 	/* disable interrupts at boardlevel */
-	m147_pcc->lan_cntrl=0x0; /* disable interrupts */
+	m147_pcc->lan_cntrl = 0x0; /* disable interrupts */
 	lance_close(dev);
 	return 0;
 }
-- 
1.7.9.5
