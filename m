From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool 3/3] ethtool/ixgbe: Reduce format string storage
Date: Wed,  4 May 2016 09:44:53 -0700
Message-ID: <1462380293-4132-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Preethi Banala <preethi.banala@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58281 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752423AbcEDQo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 12:44:56 -0400
In-Reply-To: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Preethi Banala <preethi.banala@intel.com>

Reduce format string storage using for loop.

Signed-off-by: Preethi Banala <preethi.banala@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ixgbe.c | 57 ++++++++++++---------------------------------------------
 1 file changed, 12 insertions(+), 45 deletions(-)

diff --git a/ixgbe.c b/ixgbe.c
index 4f5af77..ff0e769 100644
--- a/ixgbe.c
+++ b/ixgbe.c
@@ -1193,21 +1193,10 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x07F08: TDHMPN      (Tx Desc Handler Mem Page Num)   0x%08X\n",
 		regs_buff[1095]);
 
-	fprintf(stdout,
-		"0x07F10: TIC_DW0     (Tx Desc Hand. Mem Read Data 0)  0x%08X\n",
-		regs_buff[1096]);
-
-	fprintf(stdout,
-		"0x07F14: TIC_DW1     (Tx Desc Hand. Mem Read Data 1)  0x%08X\n",
-		regs_buff[1097]);
-
-	fprintf(stdout,
-		"0x07F18: TIC_DW2     (Tx Desc Hand. Mem Read Data 2)  0x%08X\n",
-		regs_buff[1098]);
-
-	fprintf(stdout,
-		"0x07F1C: TIC_DW3     (Tx Desc Hand. Mem Read Data 3)  0x%08X\n",
-		regs_buff[1099]);
+	for (i = 0; i < 4; i++)
+		fprintf(stdout,
+			"0x%05X: TIC_DW%d     (Tx Desc Hand. Mem Read Data %d)  0x%08X\n",
+			0x07F10 + (4 * i), i, i, regs_buff[1096 + i]);
 
 	fprintf(stdout,
 		"0x07F20: TDPROBE     (Tx Probe Mode Status)           0x%08X\n",
@@ -1217,41 +1206,19 @@ ixgbe_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 		"0x0C600: TXBUFCTRL   (TX Buffer Access Control)       0x%08X\n",
 		regs_buff[1101]);
 
-	fprintf(stdout,
-		"0x0C610: TXBUFDATA0  (TX Buffer DATA 0)               0x%08X\n",
-		regs_buff[1102]);
-
-	fprintf(stdout,
-		"0x0C614: TXBUFDATA1  (TX Buffer DATA 1)               0x%08X\n",
-		regs_buff[1103]);
-
-	fprintf(stdout,
-		"0x0C618: TXBUFDATA2  (TX Buffer DATA 2)               0x%08X\n",
-		regs_buff[1104]);
-
-	fprintf(stdout,
-		"0x0C61C: TXBUFDATA3  (TX Buffer DATA 3)               0x%08X\n",
-		regs_buff[1105]);
+	for (i = 0; i < 4; i++)
+		fprintf(stdout,
+			"0x%05X: TXBUFDATA%d  (TX Buffer DATA %d)               0x%08X\n",
+			0x0C610 + (4 * i), i, i, regs_buff[1102 + i]);
 
 	fprintf(stdout,
 		"0x03600: RXBUFCTRL   (RX Buffer Access Control)       0x%08X\n",
 		regs_buff[1106]);
 
-	fprintf(stdout,
-		"0x03610: RXBUFDATA0  (RX Buffer DATA 0)               0x%08X\n",
-		regs_buff[1107]);
-
-	fprintf(stdout,
-		"0x03614: RXBUFDATA1  (RX Buffer DATA 1)               0x%08X\n",
-		regs_buff[1108]);
-
-	fprintf(stdout,
-		"0x03618: RXBUFDATA2  (RX Buffer DATA 2)               0x%08X\n",
-		regs_buff[1109]);
-
-	fprintf(stdout,
-		"0x0361C: RXBUFDATA3  (RX Buffer DATA 3)               0x%08X\n",
-		regs_buff[1110]);
+	for (i = 0; i < 4; i++)
+		fprintf(stdout,
+			"0x%05X: RXBUFDATA%d  (RX Buffer DATA %d)               0x%08X\n",
+			0x03610 + (4 * i), i, i, regs_buff[1107 + i]);
 
 	for (i = 0; i < 8; i++)
 		fprintf(stdout,
-- 
2.5.5
