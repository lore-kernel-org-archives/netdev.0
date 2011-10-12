From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/5] igb: Convert printks to pr_<level>
Date: Wed, 12 Oct 2011 09:18:09 -0700
Message-ID: <f798850b903a47383a0e39ea1ed9207ce9930f9d.1318436085.git.joe@perches.com>
References: <cover.1318436085.git.joe@perches.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1318436085.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the current logging styles.

pr_<level> conversions are now prefixed with "igb: "

Correct a defect where the trailing NTU may have been printed
on a separate line because of an interleaving hex_dump.

Remove unnecessary uses of KERN_CONT and use single pr_info()s
to avoid any possible output interleaving from other modules.

Coalesce formats as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |  155 +++++++++++++---------------
 1 files changed, 72 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 10670f9..37c0000 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -25,6 +25,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -65,7 +67,7 @@ char igb_driver_name[] = "igb";
 char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
 				"Intel(R) Gigabit Ethernet Network Driver";
-static const char igb_copyright[] = "Copyright (c) 2007-2011 Intel Corporation.";
+static const char igb_copyright[] = "Copyright (c) 2007-2011 Intel Corporation";
 
 static const struct e1000_info *igb_info_tbl[] = {
 	[board_82575] = &e1000_82575_info,
@@ -318,16 +320,14 @@ static void igb_regdump(struct e1000_hw *hw, struct igb_reg_info *reginfo)
 			regs[n] = rd32(E1000_TXDCTL(n));
 		break;
 	default:
-		printk(KERN_INFO "%-15s %08x\n",
+		pr_info("%-15s %08x\n",
 			reginfo->name, rd32(reginfo->ofs));
 		return;
 	}
 
 	snprintf(rname, 16, "%s%s", reginfo->name, "[0-3]");
-	printk(KERN_INFO "%-15s ", rname);
-	for (n = 0; n < 4; n++)
-		printk(KERN_CONT "%08x ", regs[n]);
-	printk(KERN_CONT "\n");
+	pr_info("%-15s %08x %08x %08x %08x\n",
+		rname, regs[0], regs[1], regs[2], regs[3]);
 }
 
 /*
@@ -352,18 +352,17 @@ static void igb_dump(struct igb_adapter *adapter)
 	/* Print netdevice Info */
 	if (netdev) {
 		dev_info(&adapter->pdev->dev, "Net device Info\n");
-		printk(KERN_INFO "Device Name     state            "
-			"trans_start      last_rx\n");
-		printk(KERN_INFO "%-15s %016lX %016lX %016lX\n",
-		netdev->name,
-		netdev->state,
-		netdev->trans_start,
-		netdev->last_rx);
+		pr_info("Device Name     state            trans_start      last_rx\n");
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
 	for (reginfo = (struct igb_reg_info *)igb_reg_info_tbl;
 	     reginfo->name; reginfo++) {
 		igb_regdump(hw, reginfo);
@@ -374,18 +373,17 @@ static void igb_dump(struct igb_adapter *adapter)
 		goto exit;
 
 	dev_info(&adapter->pdev->dev, "TX Rings Summary\n");
-	printk(KERN_INFO "Queue [NTU] [NTC] [bi(ntc)->dma  ]"
-		" leng ntw timestamp\n");
+	pr_info("Queue [NTU] [NTC] [bi(ntc)->dma  ] leng ntw timestamp\n");
 	for (n = 0; n < adapter->num_tx_queues; n++) {
 		struct igb_tx_buffer *buffer_info;
 		tx_ring = adapter->tx_ring[n];
 		buffer_info = &tx_ring->tx_buffer_info[tx_ring->next_to_clean];
-		printk(KERN_INFO " %5d %5X %5X %016llX %04X %p %016llX\n",
-			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
-			   (u64)buffer_info->dma,
-			   buffer_info->length,
-			   buffer_info->next_to_watch,
-			   (u64)buffer_info->time_stamp);
+		pr_info(" %5d %5X %5X %016llX %04X %p %016llX\n",
+			n, tx_ring->next_to_use, tx_ring->next_to_clean,
+			(u64)buffer_info->dma,
+			buffer_info->length,
+			buffer_info->next_to_watch,
+			(u64)buffer_info->time_stamp);
 	}
 
 	/* Print TX Rings */
@@ -407,36 +405,37 @@ static void igb_dump(struct igb_adapter *adapter)
 
 	for (n = 0; n < adapter->num_tx_queues; n++) {
 		tx_ring = adapter->tx_ring[n];
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "TX QUEUE INDEX = %d\n", tx_ring->queue_index);
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "T [desc]     [address 63:0  ] "
-			"[PlPOCIStDDM Ln] [bi->dma       ] "
-			"leng  ntw timestamp        bi->skb\n");
+		pr_info("------------------------------------\n");
+		pr_info("TX QUEUE INDEX = %d\n", tx_ring->queue_index);
+		pr_info("------------------------------------\n");
+		pr_info("T [desc]     [address 63:0  ] [PlPOCIStDDM Ln] [bi->dma       ] leng  ntw timestamp        bi->skb\n");
 
 		for (i = 0; tx_ring->desc && (i < tx_ring->count); i++) {
+			const char *next_desc;
 			struct igb_tx_buffer *buffer_info;
 			tx_desc = IGB_TX_DESC(tx_ring, i);
 			buffer_info = &tx_ring->tx_buffer_info[i];
 			u0 = (struct my_u0 *)tx_desc;
-			printk(KERN_INFO "T [0x%03X]    %016llX %016llX %016llX"
-				" %04X  %p %016llX %p", i,
+			if (i == tx_ring->next_to_use &&
+			    i == tx_ring->next_to_clean)
+				next_desc = " NTC/U";
+			else if (i == tx_ring->next_to_use)
+				next_desc = " NTU";
+			else if (i == tx_ring->next_to_clean)
+				next_desc = " NTC";
+			else
+				next_desc = "";
+
+			pr_info("T [0x%03X]    %016llX %016llX %016llX"
+				" %04X  %p %016llX %p%s\n",
+				i,
 				le64_to_cpu(u0->a),
 				le64_to_cpu(u0->b),
 				(u64)buffer_info->dma,
 				buffer_info->length,
 				buffer_info->next_to_watch,
 				(u64)buffer_info->time_stamp,
-				buffer_info->skb);
-			if (i == tx_ring->next_to_use &&
-				i == tx_ring->next_to_clean)
-				printk(KERN_CONT " NTC/U\n");
-			else if (i == tx_ring->next_to_use)
-				printk(KERN_CONT " NTU\n");
-			else if (i == tx_ring->next_to_clean)
-				printk(KERN_CONT " NTC\n");
-			else
-				printk(KERN_CONT "\n");
+				buffer_info->skb, next_desc);
 
 			if (netif_msg_pktdata(adapter) && buffer_info->dma != 0)
 				print_hex_dump(KERN_INFO, "",
@@ -449,11 +448,11 @@ static void igb_dump(struct igb_adapter *adapter)
 	/* Print RX Rings Summary */
 rx_ring_summary:
 	dev_info(&adapter->pdev->dev, "RX Rings Summary\n");
-	printk(KERN_INFO "Queue [NTU] [NTC]\n");
+	pr_info("Queue [NTU] [NTC]\n");
 	for (n = 0; n < adapter->num_rx_queues; n++) {
 		rx_ring = adapter->rx_ring[n];
-		printk(KERN_INFO " %5d %5X %5X\n", n,
-			   rx_ring->next_to_use, rx_ring->next_to_clean);
+		pr_info(" %5d %5X %5X\n",
+			n, rx_ring->next_to_use, rx_ring->next_to_clean);
 	}
 
 	/* Print RX Rings */
@@ -485,36 +484,41 @@ rx_ring_summary:
 
 	for (n = 0; n < adapter->num_rx_queues; n++) {
 		rx_ring = adapter->rx_ring[n];
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "RX QUEUE INDEX = %d\n", rx_ring->queue_index);
-		printk(KERN_INFO "------------------------------------\n");
-		printk(KERN_INFO "R  [desc]      [ PktBuf     A0] "
-			"[  HeadBuf   DD] [bi->dma       ] [bi->skb] "
-			"<-- Adv Rx Read format\n");
-		printk(KERN_INFO "RWB[desc]      [PcsmIpSHl PtRs] "
-			"[vl er S cks ln] ---------------- [bi->skb] "
-			"<-- Adv Rx Write-Back format\n");
+		pr_info("------------------------------------\n");
+		pr_info("RX QUEUE INDEX = %d\n", rx_ring->queue_index);
+		pr_info("------------------------------------\n");
+		pr_info("R  [desc]      [ PktBuf     A0] [  HeadBuf   DD] [bi->dma       ] [bi->skb] <-- Adv Rx Read format\n");
+		pr_info("RWB[desc]      [PcsmIpSHl PtRs] [vl er S cks ln] ---------------- [bi->skb] <-- Adv Rx Write-Back format\n");
 
 		for (i = 0; i < rx_ring->count; i++) {
+			const char *next_desc;
 			struct igb_rx_buffer *buffer_info;
 			buffer_info = &rx_ring->rx_buffer_info[i];
 			rx_desc = IGB_RX_DESC(rx_ring, i);
 			u0 = (struct my_u0 *)rx_desc;
 			staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+
+			if (i == rx_ring->next_to_use)
+				next_desc = " NTU";
+			else if (i == rx_ring->next_to_clean)
+				next_desc = " NTC";
+			else
+				next_desc = "";
+
 			if (staterr & E1000_RXD_STAT_DD) {
 				/* Descriptor Done */
-				printk(KERN_INFO "RWB[0x%03X]     %016llX "
-					"%016llX ---------------- %p", i,
+				pr_info("%s[0x%03X]     %016llX %016llX ---------------- %p%s\n",
+					"RWB", i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
-					buffer_info->skb);
+					buffer_info->skb, next_desc);
 			} else {
-				printk(KERN_INFO "R  [0x%03X]     %016llX "
-					"%016llX %016llX %p", i,
+				pr_info("%s[0x%03X]     %016llX %016llX %016llX %p%s\n",
+					"R  ", i,
 					le64_to_cpu(u0->a),
 					le64_to_cpu(u0->b),
 					(u64)buffer_info->dma,
-					buffer_info->skb);
+					buffer_info->skb, next_desc);
 
 				if (netif_msg_pktdata(adapter)) {
 					print_hex_dump(KERN_INFO, "",
@@ -531,14 +535,6 @@ rx_ring_summary:
 					  PAGE_SIZE/2, true);
 				}
 			}
-
-			if (i == rx_ring->next_to_use)
-				printk(KERN_CONT " NTU\n");
-			else if (i == rx_ring->next_to_clean)
-				printk(KERN_CONT " NTC\n");
-			else
-				printk(KERN_CONT "\n");
-
 		}
 	}
 
@@ -592,10 +588,10 @@ struct net_device *igb_get_hw_dev(struct e1000_hw *hw)
 static int __init igb_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s - version %s\n",
+	pr_info("%s - version %s\n",
 	       igb_driver_string, igb_driver_version);
 
-	printk(KERN_INFO "%s\n", igb_copyright);
+	pr_info("%s\n", igb_copyright);
 
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
@@ -3676,23 +3672,19 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			ctrl = rd32(E1000_CTRL);
 			/* Links status message must follow this format */
-			printk(KERN_INFO "igb: %s NIC Link is Up %d Mbps %s, "
-				 "Flow Control: %s\n",
+			printk(KERN_INFO "igb: %s NIC Link is Up %d Mbps %s Duplex, Flow Control: %s\n",
 			       netdev->name,
 			       adapter->link_speed,
 			       adapter->link_duplex == FULL_DUPLEX ?
-				 "Full Duplex" : "Half Duplex",
-			       ((ctrl & E1000_CTRL_TFCE) &&
-			        (ctrl & E1000_CTRL_RFCE)) ? "RX/TX" :
-			       ((ctrl & E1000_CTRL_RFCE) ?  "RX" :
-			       ((ctrl & E1000_CTRL_TFCE) ?  "TX" : "None")));
+			       "Full" : "Half",
+			       (ctrl & E1000_CTRL_TFCE) &&
+			       (ctrl & E1000_CTRL_RFCE) ? "RX/TX" :
+			       (ctrl & E1000_CTRL_RFCE) ?  "RX" :
+			       (ctrl & E1000_CTRL_TFCE) ?  "TX" : "None");
 
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw, E1000_THSTAT_LINK_THROTTLE)) {
-				printk(KERN_INFO "igb: %s The network adapter "
-						 "link speed was downshifted "
-						 "because it overheated.\n",
-						 netdev->name);
+				netdev_info(netdev, "The network adapter link speed was downshifted because it overheated\n");
 			}
 
 			/* adjust timeout factor according to speed/duplex */
@@ -3723,10 +3715,7 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw, E1000_THSTAT_PWR_DOWN)) {
-				printk(KERN_ERR "igb: %s The network adapter "
-						"was stopped because it "
-						"overheated.\n",
-						netdev->name);
+				netdev_err(netdev, "The network adapter was stopped because it overheated\n");
 			}
 
 			/* Links status message must follow this format */
-- 
1.7.6.405.gc1be0
