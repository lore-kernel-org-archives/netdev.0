From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH v2] NET: AX88796: Tighten up Kconfig dependencies
Date: Mon, 27 Jun 2011 12:13:00 +0100
Message-ID: <20110627111259.GA13620@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-sh@vger.kernel.org, netdev@vger.kernel.org,
        linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>,
        Eric Miao <eric.y.miao@gmail.com>,
        Russell King <linux@arm.linux.org.uk>,
        Ben Dooks <ben-linux@fluff.org>,
        Pa
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

In def47c5095d53814512bb0c62ec02dfdec769db1 [[netdrvr] Fix dependencies for
ax88796 ne2k clone driver] the AX88796 driver got restricted to just be
build for ARM and MIPS on the sole merrit that it was written for some ARM
sytems and the driver had the misfortune to just build on MIPS, so MIPS was
throw into the dependency for a good measure.  Later
8687991a734a67f1638782c968f46fff0f94bb1f [ax88796: add superh to kconfig
dependencies] added SH but only one in-tree SH system actually has an
AX88796.

Tighten up dependencies by using an auxilliary config sysmbol
HAS_NET_AX88796 which is selected only by the platforms that actually
have or may have an AX88796.  This also means the driver won't be built
anymore for any MIPS platform.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
---
v2: fixed Sergei's complaints about the log message

 arch/arm/mach-pxa/Kconfig     |    2 ++
 arch/arm/mach-s3c2410/Kconfig |    1 +
 arch/arm/mach-s3c2440/Kconfig |    1 +
 arch/sh/boards/Kconfig        |    1 +
 drivers/net/Kconfig           |    5 ++++-
 5 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-pxa/Kconfig b/arch/arm/mach-pxa/Kconfig
index cd19309..37ce06f 100644
--- a/arch/arm/mach-pxa/Kconfig
+++ b/arch/arm/mach-pxa/Kconfig
@@ -247,11 +247,13 @@ config MACH_COLIBRI300
 	select PXA3xx
 	select CPU_PXA300
 	select CPU_PXA310
+	select HAS_NET_AX88796
 
 config MACH_COLIBRI320
 	bool "Toradex Colibri PXA320"
 	select PXA3xx
 	select CPU_PXA320
+	select HAS_NET_AX88796
 
 config MACH_COLIBRI_EVALBOARD
 	bool "Toradex Colibri Evaluation Carrier Board support"
diff --git a/arch/arm/mach-s3c2410/Kconfig b/arch/arm/mach-s3c2410/Kconfig
index 7245a55..d665f92 100644
--- a/arch/arm/mach-s3c2410/Kconfig
+++ b/arch/arm/mach-s3c2410/Kconfig
@@ -122,6 +122,7 @@ config ARCH_BAST
 	select S3C_DEV_HWMON
 	select S3C_DEV_USB_HOST
 	select S3C_DEV_NAND
+	select HAS_NET_AX88796
 	help
 	  Say Y here if you are using the Simtec Electronics EB2410ITX
 	  development board (also known as BAST)
diff --git a/arch/arm/mach-s3c2440/Kconfig b/arch/arm/mach-s3c2440/Kconfig
index 50825a3..7ddbd22 100644
--- a/arch/arm/mach-s3c2440/Kconfig
+++ b/arch/arm/mach-s3c2440/Kconfig
@@ -86,6 +86,7 @@ config MACH_ANUBIS
 	select S3C24XX_GPIO_EXTRA64
 	select S3C2440_XTAL_12000000
 	select S3C_DEV_USB_HOST
+	select HAS_NET_AX88796
 	help
 	  Say Y here if you are using the Simtec Electronics ANUBIS
 	  development system
diff --git a/arch/sh/boards/Kconfig b/arch/sh/boards/Kconfig
index d893411..f23f332 100644
--- a/arch/sh/boards/Kconfig
+++ b/arch/sh/boards/Kconfig
@@ -162,6 +162,7 @@ config SH_HIGHLANDER
 	depends on CPU_SUBTYPE_SH7780 || CPU_SUBTYPE_SH7785
 	select SYS_SUPPORTS_PCI
 	select IO_TRAPPED if MMU
+	select HAS_NET_AX88796
 
 config SH_SH7757LCR
 	bool "SH7757LCR"
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index be25e92..85d18c4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -237,13 +237,16 @@ source "drivers/net/arm/Kconfig"
 
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS || SUPERH
+	depends on HAS_NET_AX88796
 	select PHYLIB
 	select MDIO_BITBANG
 	help
 	  AX88796 driver, using platform bus to provide
 	  chip detection and resources
 
+config HAS_NET_AX88796
+	bool
+
 config AX88796_93CX6
 	bool "ASIX AX88796 external 93CX6 eeprom support"
 	depends on AX88796
