From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] qla3xxx: add missing __iomem annotation
Date: Wed, 23 Feb 2011 09:54:27 -0800
Message-ID: <20110223095427.38a67186@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53007 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753676Ab1BWRy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 12:54:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add necessary annotations about pointer to io memory space
that is checked by sparse.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/qla3xxx.c	2011-02-23 09:42:44.363626866 -0800
+++ b/drivers/net/qla3xxx.c	2011-02-23 09:43:32.564194771 -0800
@@ -379,7 +379,7 @@ static void fm93c56a_select(struct ql3_a
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
 			qdev->mem_map_registers;
-	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
+	__iomem u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_1;
 	ql_write_nvram_reg(qdev, spir, ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
@@ -398,7 +398,7 @@ static void fm93c56a_cmd(struct ql3_adap
 	u32 previousBit;
 	struct ql3xxx_port_registers __iomem *port_regs =
 			qdev->mem_map_registers;
-	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
+	__iomem u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 
 	/* Clock in a zero, then do the start bit */
 	ql_write_nvram_reg(qdev, spir,
@@ -467,7 +467,7 @@ static void fm93c56a_deselect(struct ql3
 {
 	struct ql3xxx_port_registers __iomem *port_regs =
 			qdev->mem_map_registers;
-	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
+	__iomem u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 
 	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_0;
 	ql_write_nvram_reg(qdev, spir, ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
@@ -483,7 +483,7 @@ static void fm93c56a_datain(struct ql3_a
 	u32 dataBit;
 	struct ql3xxx_port_registers __iomem *port_regs =
 			qdev->mem_map_registers;
-	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
+	__iomem u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 
 	/* Read the data bits */
 	/* The first bit is a dummy.  Clock right over it. */
@@ -3011,7 +3011,7 @@ static int ql_adapter_initialize(struct
 	u32 value;
 	struct ql3xxx_port_registers __iomem *port_regs =
 		qdev->mem_map_registers;
-	u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
+	__iomem u32 *spir = &port_regs->CommonRegs.serialPortInterfaceReg;
 	struct ql3xxx_host_memory_registers __iomem *hmem_regs =
 		(void __iomem *)port_regs;
 	u32 delay = 10;
