From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.25] pcnet32.c avoid transmit hang for 79C791
Date: Mon, 23 Feb 2004 14:12:06 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402232212.i1NMC6418719@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The pcnet32 driver will hang after a few frames (<30) with the 79C971
(and probably the 79C972 though I don't have the hardware to prove it).
By interrupt slightly more frequently the hang will not occur.

This has been broken since before 2.4.20.

--- linux-2.4.25/drivers/net/loop.pcnet32.c	Mon Feb 23 11:05:56 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Mon Feb 23 13:56:29 2004
@@ -1405,11 +1405,12 @@
     status = 0x8300;
     entry = (lp->cur_tx - lp->dirty_tx) & TX_RING_MOD_MASK;
     if ((lp->ltint) &&
-	((entry == TX_RING_SIZE/2) ||
+	((entry == TX_RING_SIZE/3) ||
+	 (entry == (TX_RING_SIZE*2)/3) ||
 	 (entry >= TX_RING_SIZE-2)))
     {
 	/* Enable Successful-TxDone interrupt if we have
-	 * 1/2 of, or nearly all of, our ring buffer Tx'd
+	 * 1/3, 2/3 or nearly all of, our ring buffer Tx'd
 	 * but not yet cleaned up.  Thus, most of the time,
 	 * we will not enable Successful-TxDone interrupts.
 	 */


-- 
Don Fry
brazilnut@us.ibm.com
