From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 10 2.4.27-pre3] pcnet32: fix for patch 8 le16_to_cpu
Date: Thu, 27 May 2004 10:43:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405271743.i4RHhpM29809@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Joe Perches pointed out an error in patch 8.  As I looked at the results
closer 3 out of 4 looked correct.  This fixes the output for the last
case.  Output is now the same on IA32 and PPC64 hardware.

--- linux-2.4.27-pre3/drivers/net/wake.pcnet32.c	Wed May 26 12:30:42 2004
+++ linux-2.4.27-pre3/drivers/net/pcnet32.c	Wed May 26 14:26:49 2004
@@ -1634,15 +1634,15 @@
 	for (i = 0 ; i < RX_RING_SIZE; i++)
 	printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
 	       le32_to_cpu(lp->rx_ring[i].base),
-	       le16_to_cpu(-lp->rx_ring[i].buf_length),
+	       (-le16_to_cpu(lp->rx_ring[i].buf_length)) & 0xffff,
 	       le32_to_cpu(lp->rx_ring[i].msg_length),
-	       le16_to_cpu((unsigned)lp->rx_ring[i].status));
+	       le16_to_cpu(lp->rx_ring[i].status));
 	for (i = 0 ; i < TX_RING_SIZE; i++)
 	printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
 	       le32_to_cpu(lp->tx_ring[i].base),
-	       le16_to_cpu(-lp->tx_ring[i].length),
+	       (-le16_to_cpu(lp->tx_ring[i].length)) & 0xffff,
 	       le32_to_cpu(lp->tx_ring[i].misc),
-	       le16_to_cpu((unsigned)lp->tx_ring[i].status));
+	       le16_to_cpu(lp->tx_ring[i].status));
 	printk("\n");
     }
     pcnet32_restart(dev, 0x0042);

-- 
Don Fry
brazilnut@us.ibm.com
