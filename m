From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 4/5] 2.4.27-pre3 pcnet32 fix boundary comparison bug.
Date: Fri, 21 May 2004 13:58:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405212058.i4LKwVI10288@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes a boundary condition.  It is possible to get an
interrupt and have the transmit queue completely full.  Without this
the driver will leak skb's and pci maps (if the arch supports them).

--- linux-2.4.27-pre3/drivers/net/pro.pcnet32.c	Fri May 21 12:37:05 2004
+++ linux-2.4.27-pre3/drivers/net/pcnet32.c	Fri May 21 12:37:14 2004
@@ -1832,7 +1832,7 @@
 	    }
 
 	    delta = (lp->cur_tx - dirty_tx) & (TX_RING_MOD_MASK + TX_RING_SIZE);
-	    if (delta >= TX_RING_SIZE) {
+	    if (delta > TX_RING_SIZE) {
 		if (netif_msg_drv(lp))
 		    printk(KERN_ERR "%s: out-of-sync dirty pointer, %d vs. %d, full=%d.\n",
 			    dev->name, dirty_tx, lp->cur_tx, lp->tx_full);


-- 
Don Fry
brazilnut@us.ibm.com
