From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool 1/3] ethtool: fix ixgbe 82598EB only registers
Date: Tue, 27 Aug 2013 17:08:47 -0700
Message-ID: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53715 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753513Ab3H1AJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 20:09:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch fixes ixgbe_reg_dump to only display registers specific to the
82598EB part, as these registers display 0xDEADBEEF otherwise, and clutter up
the register dump.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c | 144 +++++++++++++++++++++++++++++++++-------------------------------
 1 file changed, 75 insertions(+), 69 deletions(-)

diff --git a/ixgbe.c b/ixgbe.c
index 9b005f2..89cb6be 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -342,9 +342,10 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x00000: MSIXT       (MSI-X Table)                    0x%08X\n",
 		regs_buff[26]);
 
-	fprintf(stdout,
-		"0x02000: MSIXPBA     (MSI-X Pending Bit Array)        0x%08X\n",
-		regs_buff[27]);
+	if (mac_type == ixgbe_mac_82598EB)
+		fprintf(stdout,
+			"0x02000: MSIXPBA     (MSI-X Pending Bit Array)        0x%08X\n",
+			regs_buff[27]);
 
 	fprintf(stdout,
 		"0x11068: PBACL       (MSI-X PBA Clear)                0x%08X\n",
@@ -436,9 +437,10 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x03000: RXCTRL      (Receive Control)                0x%08X\n",
 		regs_buff[478]);
 
-	fprintf(stdout,
-		"0x03D04: DROPEN      (Drop Enable Control)            0x%08X\n",
-		regs_buff[479]);
+	if (mac_type == ixgbe_mac_82598EB)
+		fprintf(stdout,
+			"0x03D04: DROPEN      (Drop Enable Control)            0x%08X\n",
+			regs_buff[479]);
 
 	/* Receive */
 	fprintf(stdout,
@@ -539,9 +541,10 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x%05X: DCA_TXCTRL%02d (Tx DCA Control %02d)             0x%08X\n",
 		0x07200 + (4 * i), i, i, regs_buff[794 + i]);
 
-	fprintf(stdout,
-		"0x0CB00: TIPG        (Transmit IPG Control)           0x%08X\n",
-		regs_buff[810]);
+	if (mac_type == ixgbe_mac_82598EB)
+		fprintf(stdout,
+			"0x0CB00: TIPG        (Transmit IPG Control)           0x%08X\n",
+			regs_buff[810]);
 
 	for (i = 0; i < 8; i++)
 		fprintf(stdout,
@@ -598,29 +601,31 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x0CD00: PDPMCS      (Pkt Data Plan Music ctrl Stat)  0x%08X\n",
 		regs_buff[831]);
 
-	fprintf(stdout,
-		"0x050A0: RUPPBMR     (Rx User Prior to Pkt Buff Map)  0x%08X\n",
-		regs_buff[832]);
-
-	for (i = 0; i < 8; i++)
-		fprintf(stdout,
-		"0x%05X: RT2CR%d      (Receive T2 Configure %d)         0x%08X\n",
-		0x03C20 + (4 * i), i, i, regs_buff[833 + i]);
-
-	for (i = 0; i < 8; i++)
-		fprintf(stdout,
-		"0x%05X: RT2SR%d      (Recieve T2 Status %d)            0x%08X\n",
-		0x03C40 + (4 * i), i, i, regs_buff[841 + i]);
-
-	for (i = 0; i < 8; i++)
-		fprintf(stdout,
-		"0x%05X: TDTQ2TCCR%d  (Tx Desc TQ2 TC Config %d)        0x%08X\n",
-		0x0602C + (0x40 * i), i, i, regs_buff[849 + i]);
-
-	for (i = 0; i < 8; i++)
+	if (mac_type == ixgbe_mac_82598EB) {
 		fprintf(stdout,
-		"0x%05X: TDTQ2TCSR%d  (Tx Desc TQ2 TC Status %d)        0x%08X\n",
-		0x0622C + (0x40 * i), i, i, regs_buff[857 + i]);
+			"0x050A0: RUPPBMR     (Rx User Prior to Pkt Buff Map)  0x%08X\n",
+			regs_buff[832]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+				"0x%05X: RT2CR%d      (Receive T2 Configure %d)         0x%08X\n",
+				0x03C20 + (4 * i), i, i, regs_buff[833 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+				"0x%05X: RT2SR%d      (Recieve T2 Status %d)            0x%08X\n",
+				0x03C40 + (4 * i), i, i, regs_buff[841 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+				"0x%05X: TDTQ2TCCR%d  (Tx Desc TQ2 TC Config %d)        0x%08X\n",
+				0x0602C + (0x40 * i), i, i, regs_buff[849 + i]);
+
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+				"0x%05X: TDTQ2TCSR%d  (Tx Desc TQ2 TC Status %d)        0x%08X\n",
+				0x0622C + (0x40 * i), i, i, regs_buff[857 + i]);
+	}
 
 	for (i = 0; i < 8; i++)
 		fprintf(stdout,
@@ -984,43 +989,42 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x042B0: ANLP2       (Auto Neg Lnk Part. Ctrl Word 2) 0x%08X\n",
 		regs_buff[1069]);
 
-	fprintf(stdout,
-		"0x04800: ATLASCTL    (Atlas Analog Configuration)     0x%08X\n",
-		regs_buff[1070]);
-
-	/* Diagnostic */
-	fprintf(stdout,
-		"0x02C20: RDSTATCTL   (Rx DMA Statistic Control)       0x%08X\n",
-		regs_buff[1071]);
+	if (mac_type == ixgbe_mac_82598EB) {
+		fprintf(stdout,
+			"0x04800: ATLASCTL    (Atlas Analog Configuration)     0x%08X\n",
+			regs_buff[1070]);
 
-	for (i = 0; i < 8; i++)
+		/* Diagnostic */
 		fprintf(stdout,
-		"0x%05X: RDSTAT%d     (Rx DMA Statistics %d)            0x%08X\n",
-		0x02C00 + (4 * i), i, i, regs_buff[1072 + i]);
+			"0x02C20: RDSTATCTL   (Rx DMA Statistic Control)       0x%08X\n",
+			regs_buff[1071]);
 
-	fprintf(stdout,
-		"0x02F08: RDHMPN      (Rx Desc Handler Mem Page num)   0x%08X\n",
-		regs_buff[1080]);
+		for (i = 0; i < 8; i++)
+			fprintf(stdout,
+				"0x%05X: RDSTAT%d     (Rx DMA Statistics %d)            0x%08X\n",
+				0x02C00 + (4 * i), i, i, regs_buff[1072 + i]);
 
-	fprintf(stdout,
-		"0x02F10: RIC_DW0     (Rx Desc Hand. Mem Read Data 0)  0x%08X\n",
-		regs_buff[1081]);
+		fprintf(stdout,
+			"0x02F08: RDHMPN      (Rx Desc Handler Mem Page num)   0x%08X\n",
+			regs_buff[1080]);
 
-	fprintf(stdout,
-		"0x02F14: RIC_DW1     (Rx Desc Hand. Mem Read Data 1)  0x%08X\n",
-		regs_buff[1082]);
+		fprintf(stdout,
+			"0x02F10: RIC_DW0     (Rx Desc Hand. Mem Read Data 0)  0x%08X\n",
+			regs_buff[1081]);
 
-	fprintf(stdout,
-		"0x02F18: RIC_DW2     (Rx Desc Hand. Mem Read Data 2)  0x%08X\n",
-		regs_buff[1083]);
+		fprintf(stdout,
+			"0x02F14: RIC_DW1     (Rx Desc Hand. Mem Read Data 1)  0x%08X\n",
+			regs_buff[1082]);
 
-	fprintf(stdout,
-		"0x02F1C: RIC_DW3     (Rx Desc Hand. Mem Read Data 3)  0x%08X\n",
-		regs_buff[1084]);
+		fprintf(stdout,
+			"0x02F18: RIC_DW2     (Rx Desc Hand. Mem Read Data 2)  0x%08X\n",
+			regs_buff[1083]);
+
+		fprintf(stdout,
+			"0x02F1C: RIC_DW3     (Rx Desc Hand. Mem Read Data 3)  0x%08X\n",
+			regs_buff[1084]);
+	}
 
-	fprintf(stdout,
-		"0x02F20: RDPROBE     (Rx Probe Mode Status)           0x%08X\n",
-		regs_buff[1085]);
 
 	fprintf(stdout,
 		"0x07C20: TDSTATCTL   (Tx DMA Statistic Control)       0x%08X\n",
@@ -1124,17 +1128,19 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x042CC: MDFTS       (MAC DFT Status)                 0x%08X\n",
 		regs_buff[1124]);
 
-	fprintf(stdout,
-		"0x1106C: PCIEECCCTL  (PCIe ECC Control)               0x%08X\n",
-		regs_buff[1125]);
+	if (mac_type == ixgbe_mac_82598EB) {
+		fprintf(stdout,
+			"0x1106C: PCIEECCCTL  (PCIe ECC Control)               0x%08X\n",
+			regs_buff[1125]);
 
-	fprintf(stdout,
-		"0x0C300: PBTXECC     (Packet Buffer Tx ECC)           0x%08X\n",
-		regs_buff[1126]);
+		fprintf(stdout,
+			"0x0C300: PBTXECC     (Packet Buffer Tx ECC)           0x%08X\n",
+			regs_buff[1126]);
 
-	fprintf(stdout,
-		"0x03300: PBRXECC     (Packet Buffer Rx ECC)           0x%08X\n",
-		regs_buff[1127]);
+		fprintf(stdout,
+			"0x03300: PBRXECC     (Packet Buffer Rx ECC)           0x%08X\n",
+			regs_buff[1127]);
+	}
 
 	return 0;
 }
-- 
1.8.3.1
