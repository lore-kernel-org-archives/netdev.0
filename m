From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] ethtool: add register dump support for SMSC LAN911x/LAN921x
Date: Mon, 16 Jul 2007 20:04:40 +0100
Message-ID: <11846126802524-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from drevil.shawell.net ([86.54.8.5]:35660 "EHLO drevil.shawell.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762047AbXGPTEm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 15:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for SMSC's LAN911x and LAN921x families of
embedded ethernet controllers to ethtool's dump registers (-d) command.

This patch is for use with the smsc911x driver.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 Makefile.am    |    3 +-
 ethtool-util.h |    4 ++
 ethtool.c      |    2 +
 smsc911x.c     |   90 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 98 insertions(+), 1 deletions(-)
 create mode 100644 smsc911x.c

diff --git a/Makefile.am b/Makefile.am
index 240979e..9f4bbd3 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -7,7 +7,8 @@ sbin_PROGRAMS = ethtool
 ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c		\
 		  fec_8xx.c ibm_emac.c ixgb.c natsemi.c		\
-		  pcnet32.c realtek.c tg3.c marvell.c vioc.c
+		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
+		  smsc911x.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/ethtool-util.h b/ethtool-util.h
index dcb0c1c..c8f98f4 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -56,4 +56,8 @@ int sky2_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
 /* Fabric7 VIOC */
 int vioc_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
+/* SMSC LAN911x/LAN921x embedded ethernet controller */
+int smsc911x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 #endif
diff --git a/ethtool.c b/ethtool.c
index 4aa8e06..acaf4be 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -13,6 +13,7 @@
  * ixgb support by Nicholas Nunley <Nicholas.d.nunley@intel.com>
  * amd8111e support by Reeja John <reeja.john@amd.com>
  * long arguments by Andi Kleen.
+ * SMSC LAN911x support by Steve Glendinning <steve.glendinning@smsc.com>
  *
  * TODO:
  *   * no-args => summary of each device (mii-tool style)
@@ -1013,6 +1014,7 @@ static struct {
 	{ "skge", skge_dump_regs },
 	{ "sky2", sky2_dump_regs },
         { "vioc", vioc_dump_regs },
+        { "smsc911x", smsc911x_dump_regs },
 };
 
 static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
diff --git a/smsc911x.c b/smsc911x.c
new file mode 100644
index 0000000..07bf6a8
--- /dev/null
+++ b/smsc911x.c
@@ -0,0 +1,90 @@
+#include <stdio.h>
+#include <string.h>
+#include "ethtool-util.h"
+
+int smsc911x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	unsigned int *smsc_reg = (unsigned int *)regs->data;
+
+	fprintf(stdout, "LAN911x Registers\n");
+	fprintf(stdout, "offset 0x50, ID_REV       = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x54, INT_CFG      = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x58, INT_STS      = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x5C, INT_EN       = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x60, RESERVED     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x64, BYTE_TEST    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x68, FIFO_INT     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x6C, RX_CFG       = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x70, TX_CFG       = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x74, HW_CFG       = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x78, RX_DP_CTRL   = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x7C, RX_FIFO_INF  = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x80, TX_FIFO_INF  = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x84, PMT_CTRL     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x88, GPIO_CFG     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x8C, GPT_CFG      = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x90, GPT_CNT      = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x94, FPGA_REV     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x98, ENDIAN       = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0x9C, FREE_RUN     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xA0, RX_DROP      = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xA4, MAC_CSR_CMD  = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xA8, MAC_CSR_DATA = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xAC, AFC_CFG      = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xB0, E2P_CMD      = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "offset 0xB4, E2P_DATA     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "\n");
+
+	fprintf(stdout, "MAC Registers\n");
+	fprintf(stdout, "index 1, MAC_CR   = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 2, ADDRH    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 3, ADDRL    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 4, HASHH    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 5, HASHL    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 6, MII_ACC  = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 7, MII_DATA = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 8, FLOW     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index 9, VLAN1    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index A, VLAN2    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index B, WUFF     = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "index C, WUCSR    = 0x%08X\n",*smsc_reg++);
+	fprintf(stdout, "\n");
+
+	fprintf(stdout, "PHY Registers\n");
+	fprintf(stdout, "index 0, Basic Control Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 1, Basic Status Reg  = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 2, PHY identifier 1  = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 3, PHY identifier 2  = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 4, Auto Negotiation Advertisement Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 5, Auto Negotiation Link Partner Ability Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 6, Auto Negotiation Expansion Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 7, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 8, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 9, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 10, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 11, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 12, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 13, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 14, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 15, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 16, Silicon Revision Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 17, Mode Control/Status Reg = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 18, Special Modes = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 19, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 20, TSTCNTL = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 21, TSTREAD1 = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 22, TSTREAD2 = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 23, TSTWRITE = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 24, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 25, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 26, Reserved = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 27, Control/Status Indication = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 28, Special internal testability = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 29, Interrupt Source Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 30, Interrupt Mask Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "index 31, PHY Special Control/Status Register = 0x%04X\n",*smsc_reg++);
+	fprintf(stdout, "\n");
+	
+	return 0;
+}
+
-- 
1.5.2.2

