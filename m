From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove useless MOD_{INC,DEC}_USE_COUNT in sb1250-mac
Date: Sun, 22 Feb 2004 19:58:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222185843.GB28350@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- 1.8/drivers/net/sb1250-mac.c	Sat Jan 10 16:30:29 2004
+++ edited/drivers/net/sb1250-mac.c	Sun Feb 22 20:30:54 2004
@@ -2456,8 +2456,6 @@
 {
 	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
 	
-	MOD_INC_USE_COUNT;
-
 	if (debug > 1) {
 		printk(KERN_DEBUG "%s: sbmac_open() irq %d.\n", dev->name, dev->irq);
 	}
@@ -2466,10 +2464,8 @@
 	 * map/route interrupt 
 	 */
 	
-	if (request_irq(dev->irq, &sbmac_intr, SA_SHIRQ, dev->name, dev)) {
-		MOD_DEC_USE_COUNT;
+	if (request_irq(dev->irq, &sbmac_intr, SA_SHIRQ, dev->name, dev))
 		return -EBUSY;
-	}
 	
 	/*
 	 * Configure default speed 
@@ -2791,8 +2787,6 @@
 	sbdma_emptyring(&(sc->sbm_txdma));
 	sbdma_emptyring(&(sc->sbm_rxdma));
 	
-	MOD_DEC_USE_COUNT;
-
 	return 0;
 }
 
