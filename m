From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 8/5 2.4.27-pre3] pcnet32: correct printk for big-endian arch
Date: Wed, 26 May 2004 13:42:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405262042.i4QKgUV27910@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch corrects a printk when executed on a big-endian system.

--- linux-2.4.27-pre3/drivers/net/anr.pcnet32.c	Mon May 24 11:35:41 2004
+++ linux-2.4.27-pre3/drivers/net/pcnet32.c	Wed May 26 12:30:23 2004
@@ -1632,12 +1632,16 @@
 	   lp->cur_rx);
 	for (i = 0 ; i < RX_RING_SIZE; i++)
 	printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
-	       lp->rx_ring[i].base, -lp->rx_ring[i].buf_length,
-	       lp->rx_ring[i].msg_length, (unsigned)lp->rx_ring[i].status);
+	       le32_to_cpu(lp->rx_ring[i].base),
+	       le16_to_cpu(-lp->rx_ring[i].buf_length),
+	       le32_to_cpu(lp->rx_ring[i].msg_length),
+	       le16_to_cpu((unsigned)lp->rx_ring[i].status));
 	for (i = 0 ; i < TX_RING_SIZE; i++)
 	printk("%s %08x %04x %08x %04x", i & 1 ? "" : "\n ",
-	       lp->tx_ring[i].base, -lp->tx_ring[i].length,
-	       lp->tx_ring[i].misc, (unsigned)lp->tx_ring[i].status);
+	       le32_to_cpu(lp->tx_ring[i].base),
+	       le16_to_cpu(-lp->tx_ring[i].length),
+	       le32_to_cpu(lp->tx_ring[i].misc),
+	       le16_to_cpu((unsigned)lp->tx_ring[i].status));
 	printk("\n");
     }
     pcnet32_restart(dev, 0x0042);

-- 
Don Fry
brazilnut@us.ibm.com
