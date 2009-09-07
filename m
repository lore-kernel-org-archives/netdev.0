From: Mikael Pettersson <mikpe@it.uu.se>
Subject: [PATCH 2.6.31-rc9] mv643xx_eth.c: remove unused txq_set_wrr()
Date: Mon, 7 Sep 2009 11:59:16 +0200 (MEST)
Message-ID: <200909070959.n879xGui019854@pilspetsen.it.uu.se>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@marvell.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752938AbZIGK10@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The txq_set_wrr() function in drivers/net/mv643xx_eth.c is
unused, not even referenced under #if 0 or something like that,
which results in a compile-time warning:

drivers/net/mv643xx_eth.c:1070: warning: 'txq_set_wrr' defined but not used

Fix: remove it.

Signed-off-by: Mikael Pettersson <mikpe@it.uu.se>
---
 drivers/net/mv643xx_eth.c |   34 ----------------------------------
 1 file changed, 34 deletions(-)

--- linux-2.6.31-rc9/drivers/net/mv643xx_eth.c.~1~	2009-09-06 12:20:57.000000000 +0200
+++ linux-2.6.31-rc9/drivers/net/mv643xx_eth.c	2009-09-07 11:36:32.000000000 +0200
@@ -1066,40 +1066,6 @@ static void txq_set_fixed_prio_mode(stru
 	}
 }
 
-static void txq_set_wrr(struct tx_queue *txq, int weight)
-{
-	struct mv643xx_eth_private *mp = txq_to_mp(txq);
-	int off;
-	u32 val;
-
-	/*
-	 * Turn off fixed priority mode.
-	 */
-	off = 0;
-	switch (mp->shared->tx_bw_control) {
-	case TX_BW_CONTROL_OLD_LAYOUT:
-		off = TXQ_FIX_PRIO_CONF;
-		break;
-	case TX_BW_CONTROL_NEW_LAYOUT:
-		off = TXQ_FIX_PRIO_CONF_MOVED;
-		break;
-	}
-
-	if (off) {
-		val = rdlp(mp, off);
-		val &= ~(1 << txq->index);
-		wrlp(mp, off, val);
-
-		/*
-		 * Configure WRR weight for this queue.
-		 */
-
-		val = rdlp(mp, off);
-		val = (val & ~0xff) | (weight & 0xff);
-		wrlp(mp, TXQ_BW_WRR_CONF(txq->index), val);
-	}
-}
-
 
 /* mii management interface *************************************************/
 static irqreturn_t mv643xx_eth_err_irq(int irq, void *dev_id)
