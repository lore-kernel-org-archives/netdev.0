From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/3] qla3xxx: Add delay to NVRAM register access.
Date: Mon, 11 Dec 2006 14:29:16 -0800
Message-ID: <11658761581326-git-send-email-ron.mercer@qlogic.com>
Cc: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47612 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937686AbWLKW3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 17:29:19 -0500
To: netdev@vger.kernel.org
In-Reply-To: 20061209214706.GA15946@linux-7mw0.qlogic.org
References: 20061209214706.GA15946@linux-7mw0.qlogic.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some platforms showed issues when no delay was used.  This code only runs during the probe.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index ae65602..5aef8aa 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -210,6 +210,15 @@ static void ql_write_common_reg(struct q
 	return;
 }
 
+static void ql_write_nvram_reg(struct ql3_adapter *qdev,
+				u32 __iomem *reg, u32 value)
+{
+	writel(value, reg);
+	readl(reg);
+	udelay(1);
+	return;
+}
+
 static void ql_write_page0_reg(struct ql3_adapter *qdev,
 			       u32 __iomem *reg, u32 value)
 {
@@ -338,9 +347,9 @@ static void fm93c56a_select(struct ql3_a
 	    		qdev->mem_map_registers;
 
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_1;
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ((ISP_NVRAM_MASK << 16) | qdev->eeprom_cmd_data));
 }
 
@@ -357,14 +366,14 @@ static void fm93c56a_cmd(struct ql3_adap
 	    		qdev->mem_map_registers;
 
 	/* Clock in a zero, then do the start bit */
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
 			    AUBURN_EEPROM_DO_1);
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->
 			    eeprom_cmd_data | AUBURN_EEPROM_DO_1 |
 			    AUBURN_EEPROM_CLK_RISE);
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->
 			    eeprom_cmd_data | AUBURN_EEPROM_DO_1 |
 			    AUBURN_EEPROM_CLK_FALL);
@@ -380,20 +389,20 @@ static void fm93c56a_cmd(struct ql3_adap
 			 * If the bit changed, then change the DO state to
 			 * match
 			 */
-			ql_write_common_reg(qdev,
+			ql_write_nvram_reg(qdev,
 					    &port_regs->CommonRegs.
 					    serialPortInterfaceReg,
 					    ISP_NVRAM_MASK | qdev->
 					    eeprom_cmd_data | dataBit);
 			previousBit = dataBit;
 		}
-		ql_write_common_reg(qdev,
+		ql_write_nvram_reg(qdev,
 				    &port_regs->CommonRegs.
 				    serialPortInterfaceReg,
 				    ISP_NVRAM_MASK | qdev->
 				    eeprom_cmd_data | dataBit |
 				    AUBURN_EEPROM_CLK_RISE);
-		ql_write_common_reg(qdev,
+		ql_write_nvram_reg(qdev,
 				    &port_regs->CommonRegs.
 				    serialPortInterfaceReg,
 				    ISP_NVRAM_MASK | qdev->
@@ -414,20 +423,20 @@ static void fm93c56a_cmd(struct ql3_adap
 			 * If the bit changed, then change the DO state to
 			 * match
 			 */
-			ql_write_common_reg(qdev,
+			ql_write_nvram_reg(qdev,
 					    &port_regs->CommonRegs.
 					    serialPortInterfaceReg,
 					    ISP_NVRAM_MASK | qdev->
 					    eeprom_cmd_data | dataBit);
 			previousBit = dataBit;
 		}
-		ql_write_common_reg(qdev,
+		ql_write_nvram_reg(qdev,
 				    &port_regs->CommonRegs.
 				    serialPortInterfaceReg,
 				    ISP_NVRAM_MASK | qdev->
 				    eeprom_cmd_data | dataBit |
 				    AUBURN_EEPROM_CLK_RISE);
-		ql_write_common_reg(qdev,
+		ql_write_nvram_reg(qdev,
 				    &port_regs->CommonRegs.
 				    serialPortInterfaceReg,
 				    ISP_NVRAM_MASK | qdev->
@@ -445,7 +454,7 @@ static void fm93c56a_deselect(struct ql3
 	struct ql3xxx_port_registers __iomem *port_regs =
 	    		qdev->mem_map_registers;
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_0;
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
 }
 
@@ -463,12 +472,12 @@ static void fm93c56a_datain(struct ql3_a
 	/* Read the data bits */
 	/* The first bit is a dummy.  Clock right over it. */
 	for (i = 0; i < dataBits; i++) {
-		ql_write_common_reg(qdev,
+		ql_write_nvram_reg(qdev,
 				    &port_regs->CommonRegs.
 				    serialPortInterfaceReg,
 				    ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
 				    AUBURN_EEPROM_CLK_RISE);
-		ql_write_common_reg(qdev,
+		ql_write_nvram_reg(qdev,
 				    &port_regs->CommonRegs.
 				    serialPortInterfaceReg,
 				    ISP_NVRAM_MASK | qdev->eeprom_cmd_data |
-- 
1.4.2.rc2-dirty

