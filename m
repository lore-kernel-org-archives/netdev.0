From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 09/12] fec: remove debugging printks
Date: Wed, 15 Apr 2009 13:32:22 +0200
Message-ID: <1239795145-27558-10-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-8-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-9-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49344 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757855AbZDOLh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:37:28 -0400
In-Reply-To: <1239795145-27558-9-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These printks in fec_timeout do not give useful information in
a production kernel.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   33 ---------------------------------
 1 files changed, 0 insertions(+), 33 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index be3226c..d96aba9 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -377,41 +377,8 @@ fec_timeout(struct net_device *dev)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
 
-	printk("%s: transmit timed out.\n", dev->name);
 	dev->stats.tx_errors++;
-#ifndef final_version
-	{
-	int	i;
-	struct bufdesc *bdp;
-
-	printk("Ring data dump: cur_tx %lx%s, dirty_tx %lx cur_rx: %lx\n",
-	       (unsigned long)fep->cur_tx, fep->tx_full ? " (full)" : "",
-	       (unsigned long)fep->dirty_tx,
-	       (unsigned long)fep->cur_rx);
-
-	bdp = fep->tx_bd_base;
-	printk(" tx: %u buffers\n",  TX_RING_SIZE);
-	for (i = 0 ; i < TX_RING_SIZE; i++) {
-		printk("  %08x: %04x %04x %08x\n",
-		       (uint) bdp,
-		       bdp->cbd_sc,
-		       bdp->cbd_datlen,
-		       (int) bdp->cbd_bufaddr);
-		bdp++;
-	}
 
-	bdp = fep->rx_bd_base;
-	printk(" rx: %lu buffers\n",  (unsigned long) RX_RING_SIZE);
-	for (i = 0 ; i < RX_RING_SIZE; i++) {
-		printk("  %08x: %04x %04x %08x\n",
-		       (uint) bdp,
-		       bdp->cbd_sc,
-		       bdp->cbd_datlen,
-		       (int) bdp->cbd_bufaddr);
-		bdp++;
-	}
-	}
-#endif
 	fec_restart(dev, fep->full_duplex);
 	netif_wake_queue(dev);
 }
-- 
1.6.2.1

