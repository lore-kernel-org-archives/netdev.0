From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] small MV643xx fixes
Date: Tue, 24 Aug 2004 23:40:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824214035.GA27932@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manish_Lachwani@pmc-sierra.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 - kill an unused variable in mv64340_eth_remove
 - kill pointer arithmetics on integers sillyness
 - don't include <asm/addrspace.h> - it's unessecary and mips-specific



--- 1.6/drivers/net/mv643xx_eth.c	2004-07-14 20:59:24 +02:00
+++ edited/drivers/net/mv643xx_eth.c	2004-08-24 14:00:58 +02:00
@@ -1403,8 +1403,6 @@
 
 static void mv64340_eth_remove(struct net_device *dev)
 {
-	struct mv64340_private *mp = netdev_priv(dev);
-
 	unregister_netdev(dev);
 	flush_scheduled_work();
 	free_netdev(dev);
@@ -1739,12 +1737,12 @@
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
 	MV_WRITE(MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(eth_port_num),
-	         (struct eth_tx_desc *) mp->tx_desc_dma + tx_curr_desc);
+		 mp->tx_desc_dma + tx_curr_desc * sizeof(struct eth_tx_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
 	MV_WRITE(MV64340_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(eth_port_num),
-		 (struct eth_rx_desc *) mp->rx_desc_dma + rx_curr_desc);
+		 mp->rx_desc_dma + rx_curr_desc * sizeof(struct eth_rx_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
 	eth_port_uc_addr_set(mp->port_num, mp->port_mac_addr);
@@ -2355,8 +2353,10 @@
 		first_chip_ptr = MV_READ(MV64340_ETH_CURRENT_SERVED_TX_DESC_PTR(mp->port_num));
 
 		/* Apply send command */
-		if (first_chip_ptr == 0x00000000)
-			MV_WRITE(MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(mp->port_num), (struct eth_tx_desc *) mp->tx_desc_dma + tx_first_desc);
+		if (first_chip_ptr == 0x00000000) {
+			MV_WRITE(MV64340_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(mp->port_num),
+				 mp->tx_desc_dma + tx_first_desc * sizeof(struct eth_tx_desc));
+		}
 
                 ETH_ENABLE_TX_QUEUE(mp->port_num);
 
--- 1.6/include/linux/mv643xx.h	2004-07-27 19:45:06 +02:00
+++ edited/include/linux/mv643xx.h	2004-08-24 13:42:29 +02:00
@@ -13,7 +13,6 @@
 #ifndef __ASM_MV64340_H
 #define __ASM_MV64340_H
 
-#include <asm/addrspace.h>
 #include <asm/marvell.h>
 
 /****************************************/
 
