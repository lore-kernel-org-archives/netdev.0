From: Roger Luethi <rl@hellgate.ch>
Subject: [4/9][PATCH 2.6] Nuke default_port, references to if_port, medialock
Date: Wed, 2 Jun 2004 13:58:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602115832.GA17509@k3.hellgate.ch>
References: <20040602115703.GA16079@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040602115703.GA16079@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

As is, code doesn't do anything useful.

Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- orig/drivers/net/via-rhine.c
+++ mod/drivers/net/via-rhine.c
@@ -522,7 +522,6 @@
 	u16 chip_cmd;			/* Current setting for ChipCmd */
 
 	/* These values are keep track of the transceiver/media in use. */
-	unsigned int default_port:4;	/* Last dev->if_port value. */
 	u8 tx_thresh, rx_thresh;
 
 	/* MII transceiver section. */
@@ -810,7 +809,6 @@
 	if (option > 0) {
 		if (option & 0x220)
 			rp->mii_if.full_duplex = 1;
-		rp->default_port = option & 15;
 	}
 	if (card_idx < MAX_UNITS && full_duplex[card_idx] > 0)
 		rp->mii_if.full_duplex = 1;
@@ -859,10 +857,7 @@
 	if (option > 0) {
 		if (option & 0x220)
 			rp->mii_if.full_duplex = 1;
-		rp->default_port = option & 0x3ff;
 		if (option & 0x330) {
-			/* FIXME: shouldn't someone check this variable? */
-			/* rp->medialock = 1; */
 			printk(KERN_INFO " Forcing %dMbs %s-duplex "
 				"operation.\n",
 			       (option & 0x300 ? 100 : 10),
@@ -1061,9 +1056,6 @@
 	rp->rx_thresh = 0x60;		/* Written in rhine_set_rx_mod/drivers/nete(). */
 	rp->mii_if.full_duplex = 0;
 
-	if (dev->if_port == 0)
-		dev->if_port = rp->default_port;
-
 	writel(rp->rx_ring_dma, ioaddr + RxRingPtr);
 	writel(rp->tx_ring_dma, ioaddr + TxRingPtr);
 
@@ -1254,8 +1246,6 @@
 	       dev->name, readw(ioaddr + IntrStatus),
 	       mdio_read(dev, rp->phys[0], MII_BMSR));
 
-	dev->if_port = 0;
-
 	/* protect against concurrent rx interrupts */
 	disable_irq(rp->pdev->irq);
 
