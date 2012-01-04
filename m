From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/6] r6040: remove unused variables and definitions
Date: Wed,  4 Jan 2012 19:59:33 +0100
Message-ID: <1325703578-17275-2-git-send-email-florian@openwrt.org>
References: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:60773 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756781Ab2ADS7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:59:53 -0500
In-Reply-To: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the conversion to phylib (3831861b: r6040: implement phylib) some
PHY-related variables and definitions are now useless, remove them.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index a63b23f..c2135f2 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -52,12 +52,6 @@
 #define DRV_VERSION	"0.28"
 #define DRV_RELDATE	"07Oct2011"
 
-/* PHY CHIP Address */
-#define PHY1_ADDR	1	/* For MAC1 */
-#define PHY2_ADDR	3	/* For MAC2 */
-#define PHY_MODE	0x3100	/* PHY CHIP Register 0 */
-#define PHY_CAP		0x01E1	/* PHY CHIP Register 4 */
-
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT	(6000 * HZ / 1000)
 
@@ -154,9 +148,6 @@
 #define DSC_RX_MIDH_HIT	0x0004	/* RX MID table hit (no error) */
 #define DSC_RX_IDX_MID_MASK 3	/* RX mask for the index of matched MIDx */
 
-/* PHY settings */
-#define ICPLUS_PHY_ID	0x0243
-
 MODULE_AUTHOR("Sten Wang <sten.wang@rdc.com.tw>,"
 	"Daniel Gimpelevich <daniel@gimpelevich.san-francisco.ca.us>,"
 	"Florian Fainelli <florian@openwrt.org>");
@@ -191,7 +182,7 @@ struct r6040_private {
 	struct r6040_descriptor *tx_ring;
 	dma_addr_t rx_ring_dma;
 	dma_addr_t tx_ring_dma;
-	u16	tx_free_desc, phy_addr;
+	u16	tx_free_desc;
 	u16	mcr0, mcr1;
 	struct net_device *dev;
 	struct mii_bus *mii_bus;
@@ -206,8 +197,6 @@ static char version[] __devinitdata = DRV_NAME
 	": RDC R6040 NAPI net driver,"
 	"version "DRV_VERSION " (" DRV_RELDATE ")";
 
-static int phy_table[] = { PHY1_ADDR, PHY2_ADDR };
-
 /* Read a word data from PHY Chip */
 static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 {
@@ -1167,7 +1156,6 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	/* Init RDC private data */
 	lp->mcr0 = 0x1002;
-	lp->phy_addr = phy_table[card_idx];
 
 	/* The RDC-specific entries in the device structure. */
 	dev->netdev_ops = &r6040_netdev_ops;
-- 
1.7.5.4
