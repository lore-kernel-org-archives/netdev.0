From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool  2/3] ethtool: don't display some registers on ixgbe X540
Date: Tue, 27 Aug 2013 17:08:48 -0700
Message-ID: <1377648529-8297-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53715 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753051Ab3H1AJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 20:09:12 -0400
In-Reply-To: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch modifies ixgbe_reg_dump to take into account registers removed in the
ixgbe X540 adapter. This adapter no longer has some of the registers, and thus
returns 0xDEADBEAF for the value. Rather than display this invalid register
value, modify ixgbe_reg_dump to only display these registers on older mac types.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c | 154 ++++++++++++++++++++++++++++++++++------------------------------
 1 file changed, 82 insertions(+), 72 deletions(-)

diff --git a/ixgbe.c b/ixgbe.c
index 89cb6be..854e463 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -869,41 +869,43 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		0x06034 + (0x40 * i), i, i, regs_buff[1022 + i]);
 
 	/* MAC */
-	fprintf(stdout,
-		"0x04200: PCS1GCFIG   (PCS_1G Gloabal Config 1)        0x%08X\n",
-		regs_buff[1038]);
+	if (mac_type < ixgbe_mac_X540) {
+		fprintf(stdout,
+			"0x04200: PCS1GCFIG   (PCS_1G Gloabal Config 1)        0x%08X\n",
+			regs_buff[1038]);
 
-	fprintf(stdout,
-		"0x04208: PCS1GLCTL   (PCS_1G Link Control)            0x%08X\n",
-		regs_buff[1039]);
+		fprintf(stdout,
+			"0x04208: PCS1GLCTL   (PCS_1G Link Control)            0x%08X\n",
+			regs_buff[1039]);
 
-	fprintf(stdout,
-		"0x0420C: PCS1GLSTA   (PCS_1G Link Status)             0x%08X\n",
-		regs_buff[1040]);
+		fprintf(stdout,
+			"0x0420C: PCS1GLSTA   (PCS_1G Link Status)             0x%08X\n",
+			regs_buff[1040]);
 
-	fprintf(stdout,
-		"0x04210: PCS1GDBG0   (PCS_1G Debug 0)                 0x%08X\n",
-		regs_buff[1041]);
+		fprintf(stdout,
+			"0x04210: PCS1GDBG0   (PCS_1G Debug 0)                 0x%08X\n",
+			regs_buff[1041]);
 
-	fprintf(stdout,
-		"0x04214: PCS1GDBG1   (PCS_1G Debug 1)                 0x%08X\n",
-		regs_buff[1042]);
+		fprintf(stdout,
+			"0x04214: PCS1GDBG1   (PCS_1G Debug 1)                 0x%08X\n",
+			regs_buff[1042]);
 
-	fprintf(stdout,
-		"0x04218: PCS1GANA    (PCS-1G Auto Neg. Adv.)          0x%08X\n",
-		regs_buff[1043]);
+		fprintf(stdout,
+			"0x04218: PCS1GANA    (PCS-1G Auto Neg. Adv.)          0x%08X\n",
+			regs_buff[1043]);
 
-	fprintf(stdout,
-		"0x0421C: PCS1GANLP   (PCS-1G AN LP Ability)           0x%08X\n",
-		regs_buff[1044]);
+		fprintf(stdout,
+			"0x0421C: PCS1GANLP   (PCS-1G AN LP Ability)           0x%08X\n",
+			regs_buff[1044]);
 
-	fprintf(stdout,
-		"0x04220: PCS1GANNP   (PCS_1G Auto Neg Next Page Tx)   0x%08X\n",
-		regs_buff[1045]);
+		fprintf(stdout,
+			"0x04220: PCS1GANNP   (PCS_1G Auto Neg Next Page Tx)   0x%08X\n",
+			regs_buff[1045]);
 
-	fprintf(stdout,
-		"0x04224: PCS1GANLPNP (PCS_1G Auto Neg LPs Next Page)  0x%08X\n",
-		regs_buff[1046]);
+		fprintf(stdout,
+			"0x04224: PCS1GANLPNP (PCS_1G Auto Neg LPs Next Page)  0x%08X\n",
+			regs_buff[1046]);
+	}
 
 	fprintf(stdout,
 		"0x04244: HLREG1      (Highlander Status 1)            0x%08X\n",
@@ -949,45 +951,47 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x0426C: TREG        (Test Register)                  0x%08X\n",
 		regs_buff[1058]);
 
-	fprintf(stdout,
-		"0x04288: PCSS1       (XGXS Status 1)                  0x%08X\n",
-		regs_buff[1059]);
+	if (mac_type < ixgbe_mac_X540) {
+		fprintf(stdout,
+			"0x04288: PCSS1       (XGXS Status 1)                  0x%08X\n",
+			regs_buff[1059]);
 
-	fprintf(stdout,
-		"0x0428C: PCSS2       (XGXS Status 2)                  0x%08X\n",
-		regs_buff[1060]);
+		fprintf(stdout,
+			"0x0428C: PCSS2       (XGXS Status 2)                  0x%08X\n",
+			regs_buff[1060]);
 
-	fprintf(stdout,
-		"0x04290: XPCSS       (10GBASE-X PCS Status)           0x%08X\n",
-		regs_buff[1061]);
+		fprintf(stdout,
+			"0x04290: XPCSS       (10GBASE-X PCS Status)           0x%08X\n",
+			regs_buff[1061]);
 
-	fprintf(stdout,
-		"0x04298: SERDESC     (SERDES Interface Control)       0x%08X\n",
-		regs_buff[1062]);
+		fprintf(stdout,
+			"0x04298: SERDESC     (SERDES Interface Control)       0x%08X\n",
+			regs_buff[1062]);
 
-	fprintf(stdout,
-		"0x0429C: MACS        (FIFO Status/CNTL Report)        0x%08X\n",
-		regs_buff[1063]);
+		fprintf(stdout,
+			"0x0429C: MACS        (FIFO Status/CNTL Report)        0x%08X\n",
+			regs_buff[1063]);
 
-	fprintf(stdout,
-		"0x042A0: AUTOC       (Auto Negotiation Control)       0x%08X\n",
-		regs_buff[1064]);
+		fprintf(stdout,
+			"0x042A0: AUTOC       (Auto Negotiation Control)       0x%08X\n",
+			regs_buff[1064]);
 
-	fprintf(stdout,
-		"0x042A8: AUTOC2      (Auto Negotiation Control 2)     0x%08X\n",
-		regs_buff[1066]);
+		fprintf(stdout,
+			"0x042A8: AUTOC2      (Auto Negotiation Control 2)     0x%08X\n",
+			regs_buff[1066]);
 
-	fprintf(stdout,
-		"0x042AC: AUTOC3      (Auto Negotiation Control 3)     0x%08X\n",
-		regs_buff[1067]);
+		fprintf(stdout,
+			"0x042AC: AUTOC3      (Auto Negotiation Control 3)     0x%08X\n",
+			regs_buff[1067]);
 
-	fprintf(stdout,
-		"0x042B0: ANLP1       (Auto Neg Lnk Part. Ctrl Word 1) 0x%08X\n",
-		regs_buff[1068]);
+		fprintf(stdout,
+			"0x042B0: ANLP1       (Auto Neg Lnk Part. Ctrl Word 1) 0x%08X\n",
+			regs_buff[1068]);
 
-	fprintf(stdout,
-		"0x042B0: ANLP2       (Auto Neg Lnk Part. Ctrl Word 2) 0x%08X\n",
-		regs_buff[1069]);
+		fprintf(stdout,
+			"0x042B0: ANLP2       (Auto Neg Lnk Part. Ctrl Word 2) 0x%08X\n",
+			regs_buff[1069]);
+	}
 
 	if (mac_type == ixgbe_mac_82598EB) {
 		fprintf(stdout,
@@ -1025,6 +1029,10 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 			regs_buff[1084]);
 	}
 
+	if (mac_type < ixgbe_mac_X540)
+		fprintf(stdout,
+			"0x02F20: RDPROBE     (Rx Probe Mode Status)           0x%08X\n",
+			regs_buff[1085]);
 
 	fprintf(stdout,
 		"0x07C20: TDSTATCTL   (Tx DMA Statistic Control)       0x%08X\n",
@@ -1108,25 +1116,27 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x050A4: RFVAL       (Receive Filter Validation)      0x%08X\n",
 		regs_buff[1119]);
 
-	fprintf(stdout,
-		"0x042B8: MDFTC1      (MAC DFT Control 1)              0x%08X\n",
-		regs_buff[1120]);
+	if (mac_type < ixgbe_mac_X540) {
+		fprintf(stdout,
+			"0x042B8: MDFTC1      (MAC DFT Control 1)              0x%08X\n",
+			regs_buff[1120]);
 
-	fprintf(stdout,
-		"0x042C0: MDFTC2      (MAC DFT Control 2)              0x%08X\n",
-		regs_buff[1121]);
+		fprintf(stdout,
+			"0x042C0: MDFTC2      (MAC DFT Control 2)              0x%08X\n",
+			regs_buff[1121]);
 
-	fprintf(stdout,
-		"0x042C4: MDFTFIFO1   (MAC DFT FIFO 1)                 0x%08X\n",
-		regs_buff[1122]);
+		fprintf(stdout,
+			"0x042C4: MDFTFIFO1   (MAC DFT FIFO 1)                 0x%08X\n",
+			regs_buff[1122]);
 
-	fprintf(stdout,
-		"0x042C8: MDFTFIFO2   (MAC DFT FIFO 2)                 0x%08X\n",
-		regs_buff[1123]);
+		fprintf(stdout,
+			"0x042C8: MDFTFIFO2   (MAC DFT FIFO 2)                 0x%08X\n",
+			regs_buff[1123]);
 
-	fprintf(stdout,
-		"0x042CC: MDFTS       (MAC DFT Status)                 0x%08X\n",
-		regs_buff[1124]);
+		fprintf(stdout,
+			"0x042CC: MDFTS       (MAC DFT Status)                 0x%08X\n",
+			regs_buff[1124]);
+	}
 
 	if (mac_type == ixgbe_mac_82598EB) {
 		fprintf(stdout,
-- 
1.8.3.1
