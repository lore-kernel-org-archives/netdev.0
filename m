From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/3] drivers/net/ixgbe/ixgbe_main.c: Use pr_<level>
Date: Sun, 22 Aug 2010 19:53:01 -0700
Message-ID: <3b3bc5cde9435a0e66a81441958fb3073ebfc563.1282531322.git.joe@perches.com>
References: <cover.1282531322.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1228 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080Ab0HWCxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Aug 2010 22:53:09 -0400
In-Reply-To: <cover.1282531322.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Did not add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
because no printk in this module used message prefixing.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   74 +++++++++++++++++++--------------------
 1 files changed, 36 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5afbd99..6e100d4 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -282,17 +282,17 @@ static void ixgbe_regdump(struct ixgbe_hw *hw, struct ixgbe_reg_info *reginfo)
 			regs[i] = IXGBE_READ_REG(hw, IXGBE_TXDCTL(i));
 		break;
 	default:
-		printk(KERN_INFO "%-15s %08x\n", reginfo->name,
+		pr_info("%-15s %08x\n", reginfo->name,
 			IXGBE_READ_REG(hw, reginfo->ofs));
 		return;
 	}
 
 	for (i = 0; i < 8; i++) {
 		snprintf(rname, 16, "%s[%d-%d]", reginfo->name, i*8, i*8+7);
-		printk(KERN_ERR "%-15s ", rname);
+		pr_err("%-15s", rname);
 		for (j = 0; j < 8; j++)
-			printk(KERN_CONT "%08x ", regs[i*8+j]);
-		printk(KERN_CONT "\n");
+			pr_cont(" %08x", regs[i*8+j]);
+		pr_cont("\n");
 	}
 
 }
@@ -322,18 +322,18 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 	/* Print netdevice Info */
 	if (netdev) {
 		dev_info(&adapter->pdev->dev, "Net device Info\n");
-		printk(KERN_INFO "Device Name     state            "
+		pr_info("Device Name     state            "
 			"trans_start      last_rx\n");
-		printk(KERN_INFO "%-15s %016lX %016lX %016lX\n",
-		netdev->name,
-		netdev->state,
-		netdev->trans_start,
-		netdev->last_rx);
+		pr_info("%-15s %016lX %016lX %016lX\n",
+			netdev->name,
+			netdev->state,
+			netdev->trans_start,
+			netdev->last_rx);
 	}
 
 	/* Print Registers */
 	dev_info(&adapter->pdev->dev, "Register Dump\n");
-	printk(KERN_INFO " Register Name   Value\n");
+	pr_info(" Register Name   Value\n");
 	for (reginfo = (struct ixgbe_reg_info *)ixgbe_reg_info_tbl;
 	     reginfo->name; reginfo++) {
 		ixgbe_regdump(hw, reginfo);
@@ -344,13 +344,12 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		goto exit;
 
 	dev_info(&adapter->pdev->dev, "TX Rings Summary\n");
-	printk(KERN_INFO "Queue [NTU] [NTC] [bi(ntc)->dma  ] "
-		"leng ntw timestamp\n");
+	pr_info("Queue [NTU] [NTC] [bi(ntc)->dma  ] leng ntw timestamp\n");
 	for (n = 0; n < adapter->num_tx_queues; n++) {
 		tx_ring = adapter->tx_ring[n];
 		tx_buffer_info =
 			&tx_ring->tx_buffer_info[tx_ring->next_to_clean];
-		printk(KERN_INFO " %5d %5X %5X %016llX %04X %3X %016llX\n",
+		pr_info(" %5d %5X %5X %016llX %04X %3X %016llX\n",
 			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
 			   (u64)tx_buffer_info->dma,
 			   tx_buffer_info->length,
@@ -377,10 +376,10 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 
 	for (n = 0; n < adapter->num_tx_queues; n++) {
 		tx_ring = adapter->tx_ring[n];
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "TX QUEUE INDEX = %d\n", tx_ring->queue_index);
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "T [desc]     [address 63:0  ] "
+		pr_info("------------------------------------\n");
+		pr_info("TX QUEUE INDEX = %d\n", tx_ring->queue_index);
+		pr_info("------------------------------------\n");
+		pr_info("T [desc]     [address 63:0  ] "
 			"[PlPOIdStDDt Ln] [bi->dma       ] "
 			"leng  ntw timestamp        bi->skb\n");
 
@@ -388,7 +387,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 			tx_desc = IXGBE_TX_DESC_ADV(tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
-			printk(KERN_INFO "T [0x%03X]    %016llX %016llX %016llX"
+			pr_info("T [0x%03X]    %016llX %016llX %016llX"
 				" %04X  %3X %016llX %p", i,
 				le64_to_cpu(u0->a),
 				le64_to_cpu(u0->b),
@@ -399,13 +398,13 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 				tx_buffer_info->skb);
 			if (i == tx_ring->next_to_use &&
 				i == tx_ring->next_to_clean)
-				printk(KERN_CONT " NTC/U\n");
+				pr_cont(" NTC/U\n");
 			else if (i == tx_ring->next_to_use)
-				printk(KERN_CONT " NTU\n");
+				pr_cont(" NTU\n");
 			else if (i == tx_ring->next_to_clean)
-				printk(KERN_CONT " NTC\n");
+				pr_cont(" NTC\n");
 			else
-				printk(KERN_CONT "\n");
+				pr_cont("\n");
 
 			if (netif_msg_pktdata(adapter) &&
 				tx_buffer_info->dma != 0)
@@ -419,11 +418,11 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 	/* Print RX Rings Summary */
 rx_ring_summary:
 	dev_info(&adapter->pdev->dev, "RX Rings Summary\n");
-	printk(KERN_INFO "Queue [NTU] [NTC]\n");
+	pr_info("Queue [NTU] [NTC]\n");
 	for (n = 0; n < adapter->num_rx_queues; n++) {
 		rx_ring = adapter->rx_ring[n];
-		printk(KERN_INFO "%5d %5X %5X\n", n,
-			   rx_ring->next_to_use, rx_ring->next_to_clean);
+		pr_info("%5d %5X %5X\n",
+			n, rx_ring->next_to_use, rx_ring->next_to_clean);
 	}
 
 	/* Print RX Rings */
@@ -454,13 +453,13 @@ rx_ring_summary:
 	 */
 	for (n = 0; n < adapter->num_rx_queues; n++) {
 		rx_ring = adapter->rx_ring[n];
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "RX QUEUE INDEX = %d\n", rx_ring->queue_index);
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "R  [desc]      [ PktBuf     A0] "
+		pr_info("------------------------------------\n");
+		pr_info("RX QUEUE INDEX = %d\n", rx_ring->queue_index);
+		pr_info("------------------------------------\n");
+		pr_info("R  [desc]      [ PktBuf     A0] "
 			"[  HeadBuf   DD] [bi->dma       ] [bi->skb] "
 			"<-- Adv Rx Read format\n");
-		printk(KERN_INFO "RWB[desc]      [PcsmIpSHl PtRs] "
+		pr_info("RWB[desc]      [PcsmIpSHl PtRs] "
 			"[vl er S cks ln] ---------------- [bi->skb] "
 			"<-- Adv Rx Write-Back format\n");
 
@@ -471,13 +470,13 @@ rx_ring_summary:
 			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 			if (staterr & IXGBE_RXD_STAT_DD) {
 				/* Descriptor Done */
-				printk(KERN_INFO "RWB[0x%03X]     %016llX "
+				pr_info("RWB[0x%03X]     %016llX "
 					"%016llX ---------------- %p", i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
 					rx_buffer_info->skb);
 			} else {
-				printk(KERN_INFO "R  [0x%03X]     %016llX "
+				pr_info("R  [0x%03X]     %016llX "
 					"%016llX %016llX %p", i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
@@ -503,11 +502,11 @@ rx_ring_summary:
 			}
 
 			if (i == rx_ring->next_to_use)
-				printk(KERN_CONT " NTU\n");
+				pr_cont(" NTU\n");
 			else if (i == rx_ring->next_to_clean)
-				printk(KERN_CONT " NTC\n");
+				pr_cont(" NTC\n");
 			else
-				printk(KERN_CONT "\n");
+				pr_cont("\n");
 
 		}
 	}
@@ -7176,8 +7175,7 @@ static struct pci_driver ixgbe_driver = {
 static int __init ixgbe_init_module(void)
 {
 	int ret;
-	pr_info("%s - version %s\n", ixgbe_driver_string,
-		   ixgbe_driver_version);
+	pr_info("%s - version %s\n", ixgbe_driver_string, ixgbe_driver_version);
 	pr_info("%s\n", ixgbe_copyright);
 
 #ifdef CONFIG_IXGBE_DCA
-- 
1.7.2.19.g9a302

