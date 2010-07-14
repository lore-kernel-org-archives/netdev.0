From: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Subject: [PATCH 5/5] Remove REDWOOD_5 and REDWOOD_6 config options and
 conditional code
Date: Wed, 14 Jul 2010 16:05:05 +0200
Message-ID: <4f07b3092cafbbba37d61d367cc7484e24d18d2a.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
References: <c3c850bed3f5714f1efcfad24ad4f8bfcb6b5b54.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Solomon Peac
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:47130 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756520Ab0GNOFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 10:05:08 -0400
Content-Disposition: inline
In-Reply-To: <c3c850bed3f5714f1efcfad24ad4f8bfcb6b5b54.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The config options for REDWOOD_[56] were commented out in the powerpc
Kconfig. The ifdefs referencing this options therefore are dead and all
references to this can be removed (Also dependencies in other KConfig
files).

Signed-off-by: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
---
 arch/powerpc/platforms/40x/Kconfig |   16 -------------
 drivers/mtd/maps/Kconfig           |    2 +-
 drivers/mtd/maps/redwood.c         |   43 ------------------------------------
 drivers/net/Kconfig                |    2 +-
 4 files changed, 2 insertions(+), 61 deletions(-)

diff --git a/arch/powerpc/platforms/40x/Kconfig b/arch/powerpc/platforms/40x/Kconfig
index ec64264..b721764 100644
--- a/arch/powerpc/platforms/40x/Kconfig
+++ b/arch/powerpc/platforms/40x/Kconfig
@@ -71,22 +71,6 @@ config MAKALU
 	help
 	  This option enables support for the AMCC PPC405EX board.
 
-#config REDWOOD_5
-#	bool "Redwood-5"
-#	depends on 40x
-#	default n
-#	select STB03xxx
-#	help
-#	  This option enables support for the IBM STB04 evaluation board.
-
-#config REDWOOD_6
-#	bool "Redwood-6"
-#	depends on 40x
-#	default n
-#	select STB03xxx
-#	help
-#	  This option enables support for the IBM STBx25xx evaluation board.
-
 #config SYCAMORE
 #	bool "Sycamore"
 #	depends on 40x
diff --git a/drivers/mtd/maps/Kconfig b/drivers/mtd/maps/Kconfig
index f22bc9f..b5ebb72 100644
--- a/drivers/mtd/maps/Kconfig
+++ b/drivers/mtd/maps/Kconfig
@@ -321,7 +321,7 @@ config MTD_CFI_FLAGADM
 
 config MTD_REDWOOD
 	tristate "CFI Flash devices mapped on IBM Redwood"
-	depends on MTD_CFI && ( REDWOOD_4 || REDWOOD_5 || REDWOOD_6 )
+	depends on MTD_CFI && REDWOOD_4
 	help
 	  This enables access routines for the flash chips on the IBM
 	  Redwood board. If you have one of these boards and would like to
diff --git a/drivers/mtd/maps/redwood.c b/drivers/mtd/maps/redwood.c
index 933c0b6..d2c9db0 100644
--- a/drivers/mtd/maps/redwood.c
+++ b/drivers/mtd/maps/redwood.c
@@ -22,8 +22,6 @@
 
 #include <asm/io.h>
 
-#if !defined (CONFIG_REDWOOD_6)
-
 #define WINDOW_ADDR 0xffc00000
 #define WINDOW_SIZE 0x00400000
 
@@ -69,47 +67,6 @@ static struct mtd_partition redwood_flash_partitions[] = {
 	}
 };
 
-#else /* CONFIG_REDWOOD_6 */
-/* FIXME: the window is bigger - armin */
-#define WINDOW_ADDR 0xff800000
-#define WINDOW_SIZE 0x00800000
-
-#define RW_PART0_OF	0
-#define RW_PART0_SZ	0x400000	/* 4 MiB data */
-#define RW_PART1_OF	RW_PART0_OF + RW_PART0_SZ
-#define RW_PART1_SZ	0x10000		/* 64K VPD */
-#define RW_PART2_OF	RW_PART1_OF + RW_PART1_SZ
-#define RW_PART2_SZ	0x400000 - (0x10000 + 0x20000)
-#define RW_PART3_OF	RW_PART2_OF + RW_PART2_SZ
-#define RW_PART3_SZ	0x20000
-
-static struct mtd_partition redwood_flash_partitions[] = {
-	{
-		.name = "Redwood filesystem",
-		.offset = RW_PART0_OF,
-		.size = RW_PART0_SZ
-	},
-	{
-		.name = "Redwood OpenBIOS Vital Product Data",
-		.offset = RW_PART1_OF,
-		.size = RW_PART1_SZ,
-		.mask_flags = MTD_WRITEABLE	/* force read-only */
-	},
-	{
-		.name = "Redwood kernel",
-		.offset = RW_PART2_OF,
-		.size = RW_PART2_SZ
-	},
-	{
-		.name = "Redwood OpenBIOS",
-		.offset = RW_PART3_OF,
-		.size = RW_PART3_SZ,
-		.mask_flags = MTD_WRITEABLE	/* force read-only */
-	}
-};
-
-#endif /* CONFIG_REDWOOD_6 */
-
 struct map_info redwood_flash_map = {
 	.name = "IBM Redwood",
 	.size = WINDOW_SIZE,
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ce2fcdd..313d306 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -913,7 +913,7 @@ config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
 	select MII
-	depends on ARM || REDWOOD_5 || REDWOOD_6 || M32R || SUPERH || \
+	depends on ARM || M32R || SUPERH || \
 		MIPS || BLACKFIN || MN10300 || COLDFIRE
 	help
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
-- 
1.7.0.4

