From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 4 2.6.7-bk6] pcnet32: Fix VMWare emulation hang.
Date: Wed, 23 Jun 2004 09:51:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406231652.i5NGq0e15930@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A problem with the VMWare emulation was reported on lkml.  This patch
prevents a VMWare hang.  Reported by Keith Moore <keithmo@exmsft.com>.
Tested by Keith on VMWare and myself on real pcnet32 adapters.

signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.7-bk6/drivers/net/orig.pcnet32.c	Wed Jun 23 08:27:33 2004
+++ linux-2.6.7-bk6/drivers/net/pcnet32.c	Wed Jun 23 08:29:40 2004
@@ -1884,7 +1884,8 @@ pcnet32_interrupt(int irq, void *dev_id,
     }
 
     /* Set interrupt enable. */
-    lp->a.write_csr (ioaddr, 0, 0x0040);
+    /* VMWare requires the IDON bit to remain set */
+    lp->a.write_csr (ioaddr, 0, 0x0140);
     lp->a.write_rap (ioaddr,rap);
 
     if (netif_msg_intr(lp))

-- 
Don Fry
brazilnut@us.ibm.com
