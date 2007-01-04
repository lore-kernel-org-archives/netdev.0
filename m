From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/3] qla3xxx: Add delay to NVRAM register access.
Date: Wed,  3 Jan 2007 16:33:35 -0800
Message-ID: <11678708161162-git-send-email-ron.mercer@qlogic.com>
References: '<20070104002503.GB22318@linux-7mw0.qlogic.org>'
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:46677 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932217AbXADAdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 19:33:39 -0500
To: jeff@garzik.org
In-Reply-To: '<20070104002503.GB22318@linux-7mw0.qlogic.org>'
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When accessing the 93LC86 serial prom the clock high and low times must be at least 250ns each.  We have seen on some systems where the access times were much lower casing bit errors.
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   37 +++++++++++++++++++++++--------------
 1 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 36e0830..8844c20 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -208,6 +208,15 @@ static void ql_write_common_reg(struct q
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
@@ -336,9 +345,9 @@ static void fm93c56a_select(struct ql3_a
 	    		qdev->mem_map_registers;
 
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_1;
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ((ISP_NVRAM_MASK << 16) | qdev->eeprom_cmd_data));
 }
 
@@ -355,14 +364,14 @@ static void fm93c56a_cmd(struct ql3_adap
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
@@ -378,20 +387,20 @@ static void fm93c56a_cmd(struct ql3_adap
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
@@ -412,20 +421,20 @@ static void fm93c56a_cmd(struct ql3_adap
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
@@ -443,7 +452,7 @@ static void fm93c56a_deselect(struct ql3
 	struct ql3xxx_port_registers __iomem *port_regs =
 	    		qdev->mem_map_registers;
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_0;
-	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
+	ql_write_nvram_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
 }
 
@@ -461,12 +470,12 @@ static void fm93c56a_datain(struct ql3_a
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

