From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] yellowfin: correct printk of dma_addr_t
Date: Tue, 3 Feb 2004 15:37:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203153725.1454e69f.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


description:	fix dma_addr_t type error with CONFIG_HIGHMEM64G=y;
product_versions: linux-262-rc3

diffstat:=
 drivers/net/yellowfin.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff -Naurp ./drivers/net/yellowfin.c~yel_dma ./drivers/net/yellowfin.c
--- ./drivers/net/yellowfin.c~yel_dma	2004-01-08 22:59:26.000000000 -0800
+++ ./drivers/net/yellowfin.c	2004-02-03 15:02:22.000000000 -0800
@@ -1286,7 +1286,8 @@ static int yellowfin_close(struct net_de
 
 #if defined(__i386__)
 	if (yellowfin_debug > 2) {
-		printk("\n"KERN_DEBUG"  Tx ring at %8.8x:\n", yp->tx_ring_dma);
+		printk("\n"KERN_DEBUG"  Tx ring at %8.8llx:\n",
+				(unsigned long long)yp->tx_ring_dma);
 		for (i = 0; i < TX_RING_SIZE*2; i++)
 			printk(" %c #%d desc. %8.8x %8.8x %8.8x %8.8x.\n",
 				   inl(ioaddr + TxPtr) == (long)&yp->tx_ring[i] ? '>' : ' ',
@@ -1298,7 +1299,8 @@ static int yellowfin_close(struct net_de
 				   i, yp->tx_status[i].tx_cnt, yp->tx_status[i].tx_errs,
 				   yp->tx_status[i].total_tx_cnt, yp->tx_status[i].paused);
 
-		printk("\n"KERN_DEBUG "  Rx ring %8.8x:\n", yp->rx_ring_dma);
+		printk("\n"KERN_DEBUG "  Rx ring %8.8llx:\n",
+				(unsigned long long)yp->rx_ring_dma);
 		for (i = 0; i < RX_RING_SIZE; i++) {
 			printk(KERN_DEBUG " %c #%d desc. %8.8x %8.8x %8.8x\n",
 				   inl(ioaddr + RxPtr) == (long)&yp->rx_ring[i] ? '>' : ' ',


--
~Randy
