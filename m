From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net: smc91x: Add Atari EtherNAT support
Date: Thu, 15 Jan 2015 14:06:15 +0100
Message-ID: <1421327175-7613-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	Michael Schmitz <schmitzmic@gmail.com>,
	Michael Schmitz <schmitz@debian.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xavier.telenet-ops.be ([195.130.132.52]:38346 "EHLO
	xavier.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753588AbbAONGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 08:06:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Schmitz <schmitzmic@gmail.com>

Add Atari specific code to the smc91x Ethernet driver. This code is used
on the EtherNAT adapter card for the Atari Falcon extension port.

Signed-off-by: Michael Schmitz <schmitz@debian.org>
Tested-by: Christian Steigies <cts@debian.org>
[geert: Sort Kconfig entries, split in hard and soft dependencies]
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/smsc/Kconfig  | 10 ++++++----
 drivers/net/ethernet/smsc/smc91x.h | 21 +++++++++++++++++++++
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index 9468e64e6007bd2e..3e97a8b43147cc7c 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -5,8 +5,9 @@
 config NET_VENDOR_SMSC
 	bool "SMC (SMSC)/Western Digital devices"
 	default y
-	depends on ARM || ISA || MAC || ARM64 || MIPS || M32R || SUPERH || \
-		BLACKFIN || MN10300 || COLDFIRE || XTENSA || NIOS2 || PCI || PCMCIA
+	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
+		   ISA || M32R || MAC || MIPS || MN10300 || NIOS2 || PCI || \
+		   PCMCIA || SUPERH || XTENSA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -38,8 +39,9 @@ config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
 	select MII
-	depends on (ARM || M32R || SUPERH || MIPS || BLACKFIN || \
-		    MN10300 || COLDFIRE || ARM64 || XTENSA || NIOS2) && (!OF || GPIOLIB)
+	depends on !OF || GPIOLIB
+	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
+		   M32R || MIPS || MN10300 || NIOS2 || SUPERH || XTENSA
 	---help---
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index 2a38dacbbd27fba4..be67baf5f6778d08 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -216,6 +216,27 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 
 #include <unit/smc91111.h>
 
+#elif defined(CONFIG_ATARI)
+
+#define SMC_CAN_USE_8BIT        1
+#define SMC_CAN_USE_16BIT       1
+#define SMC_CAN_USE_32BIT       1
+#define SMC_NOWAIT              1
+
+#define SMC_inb(a, r)           readb((a) + (r))
+#define SMC_inw(a, r)           readw((a) + (r))
+#define SMC_inl(a, r)           readl((a) + (r))
+#define SMC_outb(v, a, r)       writeb(v, (a) + (r))
+#define SMC_outw(v, a, r)       writew(v, (a) + (r))
+#define SMC_outl(v, a, r)       writel(v, (a) + (r))
+#define SMC_insw(a, r, p, l)    readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)   writesw((a) + (r), p, l)
+#define SMC_insl(a, r, p, l)    readsl((a) + (r), p, l)
+#define SMC_outsl(a, r, p, l)   writesl((a) + (r), p, l)
+
+#define RPC_LSA_DEFAULT         RPC_LED_100_10
+#define RPC_LSB_DEFAULT         RPC_LED_TX_RX
+
 #elif defined(CONFIG_ARCH_MSM)
 
 #define SMC_CAN_USE_8BIT	0
-- 
1.9.1
