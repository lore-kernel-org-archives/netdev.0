From: Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH] net: smsc: Add support h8300
Date: Sat, 16 Jan 2016 00:05:09 +0900
Message-ID: <1452870309-5735-1-git-send-email-ysato@users.sourceforge.jp>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add H8/300 platform support for smc91x

Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
---
 drivers/net/ethernet/smsc/Kconfig  |  4 ++--
 drivers/net/ethernet/smsc/smc91x.h | 11 +++++++++++
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index eb9230e..63aca9f 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -7,7 +7,7 @@ config NET_VENDOR_SMSC
 	default y
 	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
 		   ISA || M32R || MAC || MIPS || MN10300 || NIOS2 || PCI || \
-		   PCMCIA || SUPERH || XTENSA
+		   PCMCIA || SUPERH || XTENSA || H8300
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y.
 
@@ -38,7 +38,7 @@ config SMC91X
 	select MII
 	depends on !OF || GPIOLIB
 	depends on ARM || ARM64 || ATARI_ETHERNAT || BLACKFIN || COLDFIRE || \
-		   M32R || MIPS || MN10300 || NIOS2 || SUPERH || XTENSA
+		   M32R || MIPS || MN10300 || NIOS2 || SUPERH || XTENSA || H8300
 	---help---
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
diff --git a/drivers/net/ethernet/smsc/smc91x.h b/drivers/net/ethernet/smsc/smc91x.h
index a3c129e..1a55c79 100644
--- a/drivers/net/ethernet/smsc/smc91x.h
+++ b/drivers/net/ethernet/smsc/smc91x.h
@@ -172,6 +172,17 @@ static inline void mcf_outsw(void *a, unsigned char *p, int l)
 
 #define SMC_IRQ_FLAGS		0
 
+#elif defined(CONFIG_H8300)
+#define SMC_CAN_USE_8BIT	1
+#define SMC_CAN_USE_16BIT	0
+#define SMC_CAN_USE_32BIT	0
+#define SMC_NOWAIT		0
+
+#define SMC_inb(a, r)		ioread8((a) + (r))
+#define SMC_outb(v, a, r)	iowrite8(v, (a) + (r))
+#define SMC_insb(a, r, p, l)	ioread8_rep((a) + (r), p, l)
+#define SMC_outsb(a, r, p, l)	iowrite8_rep((a) + (r), p, l)
+
 #else
 
 /*
-- 
2.6.1
