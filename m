From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/6] r6040: define more MCR0 register bits
Date: Wed,  4 Jan 2012 19:59:34 +0100
Message-ID: <1325703578-17275-3-git-send-email-florian@openwrt.org>
References: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:60766 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756778Ab2ADS7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:59:52 -0500
In-Reply-To: <1325703578-17275-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Define more MCR0-register bits and use them in place of the bits values.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index c2135f2..f4dddcee 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -63,8 +63,11 @@
 
 /* MAC registers */
 #define MCR0		0x00	/* Control register 0 */
+#define  MCR0_RCVEN	0x0002	/* Receive enable */
 #define  MCR0_PROMISC	0x0020	/* Promiscuous mode */
 #define  MCR0_HASH_EN	0x0100	/* Enable multicast hash table function */
+#define  MCR0_XMTEN	0x1000	/* Transmission enable */
+#define  MCR0_FD	0x8000	/* Full/Half duplex */
 #define MCR1		0x04	/* Control register 1 */
 #define  MAC_RST	0x0001	/* Reset the MAC */
 #define MBCR		0x08	/* Bus control */
@@ -398,7 +401,7 @@ static void r6040_init_mac_regs(struct net_device *dev)
 	iowrite16(INT_MASK, ioaddr + MIER);
 
 	/* Enable TX and RX */
-	iowrite16(lp->mcr0 | 0x0002, ioaddr);
+	iowrite16(lp->mcr0 | MCR0_RCVEN, ioaddr);
 
 	/* Let TX poll the descriptors
 	 * we may got called by r6040_tx_timeout which has left
@@ -1002,7 +1005,7 @@ static void r6040_adjust_link(struct net_device *dev)
 
 	/* reflect duplex change */
 	if (phydev->link && (lp->old_duplex != phydev->duplex)) {
-		lp->mcr0 |= (phydev->duplex == DUPLEX_FULL ? 0x8000 : 0);
+		lp->mcr0 |= (phydev->duplex == DUPLEX_FULL ? MCR0_FD : 0);
 		iowrite16(lp->mcr0, ioaddr);
 
 		status_changed = 1;
@@ -1155,7 +1158,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	lp->dev = dev;
 
 	/* Init RDC private data */
-	lp->mcr0 = 0x1002;
+	lp->mcr0 = MCR0_XMTEN | MCR0;
 
 	/* The RDC-specific entries in the device structure. */
 	dev->netdev_ops = &r6040_netdev_ops;
-- 
1.7.5.4
