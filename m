From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.5.x net driver fixes
Date: Wed, 12 Nov 2003 20:37:15 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031113013715.GA10734@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Linus, please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.5

This will update the following files:

 drivers/net/tg3.c         |    2 +-
 drivers/net/tulip/de4x5.c |    2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

through these ChangeSets:

<shemminger@osdl.org> (03/11/12 1.1414.3.4)
   [netdrvr de4x5] NE54-de4x5 - fix missing free on error path - found by viro

<herbert@gondor.apana.org.au> (03/11/12 1.1414.3.3)
   [netdrvr tg3] initialize workqueue correctly
   
   (fixes crash)




diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Wed Nov 12 20:34:35 2003
+++ b/drivers/net/tg3.c	Wed Nov 12 20:34:35 2003
@@ -7605,7 +7605,7 @@
 	spin_lock_init(&tp->lock);
 	spin_lock_init(&tp->tx_lock);
 	spin_lock_init(&tp->indirect_lock);
-	PREPARE_WORK(&tp->reset_task, tg3_reset_task, tp);
+	INIT_WORK(&tp->reset_task, tg3_reset_task, tp);
 
 	tp->regs = (unsigned long) ioremap(tg3reg_base, tg3reg_len);
 	if (tp->regs == 0UL) {
diff -Nru a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
--- a/drivers/net/tulip/de4x5.c	Wed Nov 12 20:34:35 2003
+++ b/drivers/net/tulip/de4x5.c	Wed Nov 12 20:34:35 2003
@@ -1237,6 +1237,8 @@
 	if (lp->useSROM) {
 	    lp->state = INITIALISED;
 	    if (srom_infoleaf_info(dev)) {
+	        dma_free_coherent (gendev, lp->dma_size,
+			       lp->rx_ring, lp->dma_rings);
 		return -ENXIO;
 	    }
 	    srom_init(dev);
