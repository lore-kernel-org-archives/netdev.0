From: Zhao Qiang <B45475@freescale.com>
Subject: [PATCH v4] QE: Move QE from arch/powerpc to drivers/soc
Date: Wed, 12 Nov 2014 11:40:13 +0800
Message-ID: <1415763613-43674-1-git-send-email-B45475@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <R63061@freescale.com>, Zhao Qiang <B45475@freescale.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>, <B07421@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ls1 has qe and ls1 has arm cpu.
move qe from arch/powerpc to drivers/soc/fsl
to adapt to powerpc and arm

Signed-off-by: Zhao Qiang <B45475@freescale.com>
---
Changes for v2:
	- move code to driver/soc
Changes for v3:
	- change drivers/soc/qe to drivers/soc/fsl-qe
Changes for v4:
	- move drivers/soc/fsl-qe to drivers/soc/fsl/qe
	- move head files for qe from include/linux/fsl to include/soc/fsl
	- move qe_ic.c to drivers/irqchip/

 arch/powerpc/platforms/83xx/km83xx.c               |  4 +--
 arch/powerpc/platforms/83xx/misc.c                 |  2 +-
 arch/powerpc/platforms/83xx/mpc832x_mds.c          |  4 +--
 arch/powerpc/platforms/83xx/mpc832x_rdb.c          |  4 +--
 arch/powerpc/platforms/83xx/mpc836x_mds.c          |  4 +--
 arch/powerpc/platforms/83xx/mpc836x_rdk.c          |  4 +--
 arch/powerpc/platforms/85xx/common.c               |  2 +-
 arch/powerpc/platforms/85xx/corenet_generic.c      |  2 +-
 arch/powerpc/platforms/85xx/mpc85xx_mds.c          |  4 +--
 arch/powerpc/platforms/85xx/mpc85xx_rdb.c          |  4 +--
 arch/powerpc/platforms/85xx/twr_p102x.c            |  4 +--
 arch/powerpc/platforms/Kconfig                     | 19 -------------
 arch/powerpc/sysdev/qe_lib/Kconfig                 | 23 +++++-----------
 arch/powerpc/sysdev/qe_lib/Makefile                | 10 +++----
 arch/powerpc/sysdev/qe_lib/gpio.c                  |  2 +-
 arch/powerpc/sysdev/qe_lib/qe_io.c                 |  2 +-
 arch/powerpc/sysdev/qe_lib/usb.c                   |  4 +--
 drivers/irqchip/Makefile                           |  1 +
 .../sysdev/qe_lib => drivers/irqchip}/qe_ic.c      |  2 +-
 .../sysdev/qe_lib => drivers/irqchip}/qe_ic.h      |  2 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c       |  2 +-
 drivers/net/ethernet/freescale/ucc_geth.c          |  8 +++---
 drivers/net/ethernet/freescale/ucc_geth.h          |  8 +++---
 drivers/soc/Kconfig                                |  2 ++
 drivers/soc/Makefile                               |  1 +
 drivers/soc/fsl/Makefile                           |  5 ++++
 drivers/soc/fsl/qe/Kconfig                         | 31 ++++++++++++++++++++++
 drivers/soc/fsl/qe/Makefile                        |  8 ++++++
 .../sysdev/qe_lib => drivers/soc/fsl/qe}/qe.c      |  4 +--
 .../sysdev/qe_lib => drivers/soc/fsl/qe}/ucc.c     |  6 ++---
 .../qe_lib => drivers/soc/fsl/qe}/ucc_fast.c       |  8 +++---
 .../qe_lib => drivers/soc/fsl/qe}/ucc_slow.c       |  8 +++---
 drivers/spi/spi-fsl-cpm.c                          |  2 +-
 drivers/tty/serial/ucc_uart.c                      |  2 +-
 drivers/usb/gadget/fsl_qe_udc.c                    |  2 +-
 drivers/usb/host/fhci-hcd.c                        |  2 +-
 drivers/usb/host/fhci-hub.c                        |  2 +-
 drivers/usb/host/fhci-sched.c                      |  2 +-
 drivers/usb/host/fhci.h                            |  4 +--
 .../include/asm => include/linux/fsl}/qe_ic.h      |  0
 .../include/asm => include/soc/fsl}/immap_qe.h     |  0
 {arch/powerpc/include/asm => include/soc/fsl}/qe.h |  2 +-
 .../powerpc/include/asm => include/soc/fsl}/ucc.h  |  4 +--
 .../include/asm => include/soc/fsl}/ucc_fast.h     |  6 ++---
 .../include/asm => include/soc/fsl}/ucc_slow.h     |  6 ++---
 45 files changed, 121 insertions(+), 107 deletions(-)
 rename {arch/powerpc/sysdev/qe_lib => drivers/irqchip}/qe_ic.c (99%)
 rename {arch/powerpc/sysdev/qe_lib => drivers/irqchip}/qe_ic.h (98%)
 create mode 100644 drivers/soc/fsl/Makefile
 create mode 100644 drivers/soc/fsl/qe/Kconfig
 create mode 100644 drivers/soc/fsl/qe/Makefile
 rename {arch/powerpc/sysdev/qe_lib => drivers/soc/fsl/qe}/qe.c (99%)
 rename {arch/powerpc/sysdev/qe_lib => drivers/soc/fsl/qe}/ucc.c (98%)
 rename {arch/powerpc/sysdev/qe_lib => drivers/soc/fsl/qe}/ucc_fast.c (99%)
 rename {arch/powerpc/sysdev/qe_lib => drivers/soc/fsl/qe}/ucc_slow.c (98%)
 rename {arch/powerpc/include/asm => include/linux/fsl}/qe_ic.h (100%)
 rename {arch/powerpc/include/asm => include/soc/fsl}/immap_qe.h (100%)
 rename {arch/powerpc/include/asm => include/soc/fsl}/qe.h (99%)
 rename {arch/powerpc/include/asm => include/soc/fsl}/ucc.h (96%)
 rename {arch/powerpc/include/asm => include/soc/fsl}/ucc_fast.h (98%)
 rename {arch/powerpc/include/asm => include/soc/fsl}/ucc_slow.h (99%)

diff --git a/arch/powerpc/platforms/83xx/km83xx.c b/arch/powerpc/platforms/83xx/km83xx.c
index bf4c447..11c386bb2 100644
--- a/arch/powerpc/platforms/83xx/km83xx.c
+++ b/arch/powerpc/platforms/83xx/km83xx.c
@@ -37,8 +37,8 @@
 #include <asm/udbg.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 
 #include "mpc83xx.h"
 
diff --git a/arch/powerpc/platforms/83xx/misc.c b/arch/powerpc/platforms/83xx/misc.c
index 125336f..3e2e6d2 100644
--- a/arch/powerpc/platforms/83xx/misc.c
+++ b/arch/powerpc/platforms/83xx/misc.c
@@ -17,7 +17,7 @@
 #include <asm/io.h>
 #include <asm/hw_irq.h>
 #include <asm/ipic.h>
-#include <asm/qe_ic.h>
+#include <linux/fsl/qe_ic.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 
diff --git a/arch/powerpc/platforms/83xx/mpc832x_mds.c b/arch/powerpc/platforms/83xx/mpc832x_mds.c
index 8d76220..dfa4ba4 100644
--- a/arch/powerpc/platforms/83xx/mpc832x_mds.c
+++ b/arch/powerpc/platforms/83xx/mpc832x_mds.c
@@ -36,8 +36,8 @@
 #include <asm/udbg.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 
 #include "mpc83xx.h"
 
diff --git a/arch/powerpc/platforms/83xx/mpc832x_rdb.c b/arch/powerpc/platforms/83xx/mpc832x_rdb.c
index eff5baa..c5b80c7 100644
--- a/arch/powerpc/platforms/83xx/mpc832x_rdb.c
+++ b/arch/powerpc/platforms/83xx/mpc832x_rdb.c
@@ -25,8 +25,8 @@
 #include <asm/time.h>
 #include <asm/ipic.h>
 #include <asm/udbg.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 
diff --git a/arch/powerpc/platforms/83xx/mpc836x_mds.c b/arch/powerpc/platforms/83xx/mpc836x_mds.c
index 1a26d2f..fba4cd3 100644
--- a/arch/powerpc/platforms/83xx/mpc836x_mds.c
+++ b/arch/powerpc/platforms/83xx/mpc836x_mds.c
@@ -44,8 +44,8 @@
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 #include <sysdev/simple_gpio.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 
 #include "mpc83xx.h"
 
diff --git a/arch/powerpc/platforms/83xx/mpc836x_rdk.c b/arch/powerpc/platforms/83xx/mpc836x_rdk.c
index b63b42d..2512364 100644
--- a/arch/powerpc/platforms/83xx/mpc836x_rdk.c
+++ b/arch/powerpc/platforms/83xx/mpc836x_rdk.c
@@ -20,8 +20,8 @@
 #include <asm/time.h>
 #include <asm/ipic.h>
 #include <asm/udbg.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 
diff --git a/arch/powerpc/platforms/85xx/common.c b/arch/powerpc/platforms/85xx/common.c
index b564b5e..c3f5089 100644
--- a/arch/powerpc/platforms/85xx/common.c
+++ b/arch/powerpc/platforms/85xx/common.c
@@ -9,7 +9,7 @@
 #include <linux/of_irq.h>
 #include <linux/of_platform.h>
 
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 #include <sysdev/cpm2_pic.h>
 
 #include "mpc85xx.h"
diff --git a/arch/powerpc/platforms/85xx/corenet_generic.c b/arch/powerpc/platforms/85xx/corenet_generic.c
index e56b89a..5e2acb9 100644
--- a/arch/powerpc/platforms/85xx/corenet_generic.c
+++ b/arch/powerpc/platforms/85xx/corenet_generic.c
@@ -27,7 +27,7 @@
 #include <asm/udbg.h>
 #include <asm/mpic.h>
 #include <asm/ehv_pic.h>
-#include <asm/qe_ic.h>
+#include <linux/fsl/qe_ic.h>
 
 #include <linux/of_platform.h>
 #include <sysdev/fsl_soc.h>
diff --git a/arch/powerpc/platforms/85xx/mpc85xx_mds.c b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
index a392e94..0a41795 100644
--- a/arch/powerpc/platforms/85xx/mpc85xx_mds.c
+++ b/arch/powerpc/platforms/85xx/mpc85xx_mds.c
@@ -47,8 +47,8 @@
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 #include <sysdev/simple_gpio.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 #include <asm/mpic.h>
 #include <asm/swiotlb.h>
 #include <asm/fsl_guts.h>
diff --git a/arch/powerpc/platforms/85xx/mpc85xx_rdb.c b/arch/powerpc/platforms/85xx/mpc85xx_rdb.c
index e358bed..13595cc 100644
--- a/arch/powerpc/platforms/85xx/mpc85xx_rdb.c
+++ b/arch/powerpc/platforms/85xx/mpc85xx_rdb.c
@@ -25,8 +25,8 @@
 #include <asm/prom.h>
 #include <asm/udbg.h>
 #include <asm/mpic.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 #include <asm/fsl_guts.h>
 
 #include <sysdev/fsl_soc.h>
diff --git a/arch/powerpc/platforms/85xx/twr_p102x.c b/arch/powerpc/platforms/85xx/twr_p102x.c
index 1eadb6d..a4ac222 100644
--- a/arch/powerpc/platforms/85xx/twr_p102x.c
+++ b/arch/powerpc/platforms/85xx/twr_p102x.c
@@ -21,8 +21,8 @@
 #include <asm/pci-bridge.h>
 #include <asm/udbg.h>
 #include <asm/mpic.h>
-#include <asm/qe.h>
-#include <asm/qe_ic.h>
+#include <soc/fsl/qe.h>
+#include <linux/fsl/qe_ic.h>
 #include <asm/fsl_guts.h>
 
 #include <sysdev/fsl_soc.h>
diff --git a/arch/powerpc/platforms/Kconfig b/arch/powerpc/platforms/Kconfig
index 391b3f6..ae8879c 100644
--- a/arch/powerpc/platforms/Kconfig
+++ b/arch/powerpc/platforms/Kconfig
@@ -277,25 +277,6 @@ config TAU_AVERAGE
 
 	  If in doubt, say N here.
 
-config QUICC_ENGINE
-	bool "Freescale QUICC Engine (QE) Support"
-	depends on FSL_SOC && PPC32
-	select PPC_LIB_RHEAP
-	select CRC32
-	help
-	  The QUICC Engine (QE) is a new generation of communications
-	  coprocessors on Freescale embedded CPUs (akin to CPM in older chips).
-	  Selecting this option means that you wish to build a kernel
-	  for a machine with a QE coprocessor.
-
-config QE_GPIO
-	bool "QE GPIO support"
-	depends on QUICC_ENGINE
-	select ARCH_REQUIRE_GPIOLIB
-	help
-	  Say Y here if you're going to use hardware that connects to the
-	  QE GPIOs.
-
 config CPM2
 	bool "Enable support for the CPM2 (Communications Processor Module)"
 	depends on (FSL_SOC_BOOKE && PPC32) || 8260
diff --git a/arch/powerpc/sysdev/qe_lib/Kconfig b/arch/powerpc/sysdev/qe_lib/Kconfig
index 3c25199..c170805 100644
--- a/arch/powerpc/sysdev/qe_lib/Kconfig
+++ b/arch/powerpc/sysdev/qe_lib/Kconfig
@@ -1,24 +1,13 @@
 #
 # QE Communication options
 #
-
-config UCC_SLOW
-	bool
-	default y if SERIAL_QE
+config QE_GPIO
+	bool "QE GPIO support"
+	depends on QUICC_ENGINE
+	select ARCH_REQUIRE_GPIOLIB
 	help
-	  This option provides qe_lib support to UCC slow
-	  protocols: UART, BISYNC, QMC
-
-config UCC_FAST
-	bool
-	default y if UCC_GETH
-	help
-	  This option provides qe_lib support to UCC fast
-	  protocols: HDLC, Ethernet, ATM, transparent
-
-config UCC
-	bool
-	default y if UCC_FAST || UCC_SLOW
+	  Say Y here if you're going to use hardware that connects to the
+	  QE GPIOs.
 
 config QE_USB
 	bool
diff --git a/arch/powerpc/sysdev/qe_lib/Makefile b/arch/powerpc/sysdev/qe_lib/Makefile
index f1855c1..2f8630b 100644
--- a/arch/powerpc/sysdev/qe_lib/Makefile
+++ b/arch/powerpc/sysdev/qe_lib/Makefile
@@ -1,10 +1,6 @@
 #
 # Makefile for the linux ppc-specific parts of QE
 #
-obj-$(CONFIG_QUICC_ENGINE)+= qe.o qe_ic.o qe_io.o
-
-obj-$(CONFIG_UCC)	+= ucc.o
-obj-$(CONFIG_UCC_SLOW)	+= ucc_slow.o
-obj-$(CONFIG_UCC_FAST)	+= ucc_fast.o
-obj-$(CONFIG_QE_USB)	+= usb.o
-obj-$(CONFIG_QE_GPIO)	+= gpio.o
+obj-$(CONFIG_QUICC_ENGINE)	+= qe_io.o
+obj-$(CONFIG_QE_USB)		+= usb.o
+obj-$(CONFIG_QE_GPIO)		+= gpio.o
diff --git a/arch/powerpc/sysdev/qe_lib/gpio.c b/arch/powerpc/sysdev/qe_lib/gpio.c
index 521e67a..35f90ea 100644
--- a/arch/powerpc/sysdev/qe_lib/gpio.c
+++ b/arch/powerpc/sysdev/qe_lib/gpio.c
@@ -21,7 +21,7 @@
 #include <linux/gpio.h>
 #include <linux/slab.h>
 #include <linux/export.h>
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 
 struct qe_gpio_chip {
 	struct of_mm_gpio_chip mm_gc;
diff --git a/arch/powerpc/sysdev/qe_lib/qe_io.c b/arch/powerpc/sysdev/qe_lib/qe_io.c
index d099941..54a44e8 100644
--- a/arch/powerpc/sysdev/qe_lib/qe_io.c
+++ b/arch/powerpc/sysdev/qe_lib/qe_io.c
@@ -21,7 +21,7 @@
 #include <linux/ioport.h>
 
 #include <asm/io.h>
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 #include <asm/prom.h>
 #include <sysdev/fsl_soc.h>
 
diff --git a/arch/powerpc/sysdev/qe_lib/usb.c b/arch/powerpc/sysdev/qe_lib/usb.c
index 27f23bd..f71e4d1 100644
--- a/arch/powerpc/sysdev/qe_lib/usb.c
+++ b/arch/powerpc/sysdev/qe_lib/usb.c
@@ -17,8 +17,8 @@
 #include <linux/errno.h>
 #include <linux/export.h>
 #include <linux/io.h>
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
 int qe_usb_clock_set(enum qe_clock clk, int rate)
 {
diff --git a/drivers/irqchip/Makefile b/drivers/irqchip/Makefile
index 62a13e5..b887856 100644
--- a/drivers/irqchip/Makefile
+++ b/drivers/irqchip/Makefile
@@ -30,3 +30,4 @@ obj-$(CONFIG_XTENSA)			+= irq-xtensa-pic.o
 obj-$(CONFIG_XTENSA_MX)			+= irq-xtensa-mx.o
 obj-$(CONFIG_IRQ_CROSSBAR)		+= irq-crossbar.o
 obj-$(CONFIG_BRCMSTB_L2_IRQ)		+= irq-brcmstb-l2.o
+obj-$(CONFIG_QUICC_ENGINE)		+= qe_ic.o
diff --git a/arch/powerpc/sysdev/qe_lib/qe_ic.c b/drivers/irqchip/qe_ic.c
similarity index 99%
rename from arch/powerpc/sysdev/qe_lib/qe_ic.c
rename to drivers/irqchip/qe_ic.c
index b2b87c3..eb4d160 100644
--- a/arch/powerpc/sysdev/qe_lib/qe_ic.c
+++ b/drivers/irqchip/qe_ic.c
@@ -28,7 +28,7 @@
 #include <asm/irq.h>
 #include <asm/io.h>
 #include <asm/prom.h>
-#include <asm/qe_ic.h>
+#include <linux/fsl/qe_ic.h>
 
 #include "qe_ic.h"
 
diff --git a/arch/powerpc/sysdev/qe_lib/qe_ic.h b/drivers/irqchip/qe_ic.h
similarity index 98%
rename from arch/powerpc/sysdev/qe_lib/qe_ic.h
rename to drivers/irqchip/qe_ic.h
index efef7ab..5c4480e 100644
--- a/arch/powerpc/sysdev/qe_lib/qe_ic.h
+++ b/drivers/irqchip/qe_ic.h
@@ -16,7 +16,7 @@
 #ifndef _POWERPC_SYSDEV_QE_IC_H
 #define _POWERPC_SYSDEV_QE_IC_H
 
-#include <asm/qe_ic.h>
+#include <linux/fsl/qe_ic.h>
 
 #define NR_QE_IC_INTS		64
 
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 583e71a..77448fd 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -28,7 +28,7 @@
 #include <linux/of_device.h>
 
 #include <asm/io.h>
-#include <asm/ucc.h>	/* for ucc_set_qe_mux_mii_mng() */
+#include <soc/fsl/ucc.h>	/* for ucc_set_qe_mux_mii_mng() */
 
 #include "gianfar.h"
 
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index fab39e2..28874dc 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -40,10 +40,10 @@
 #include <asm/uaccess.h>
 #include <asm/irq.h>
 #include <asm/io.h>
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
-#include <asm/ucc.h>
-#include <asm/ucc_fast.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
+#include <soc/fsl/ucc.h>
+#include <soc/fsl/ucc_fast.h>
 #include <asm/machdep.h>
 
 #include "ucc_geth.h"
diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
index 75f3371..012fdcf 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.h
+++ b/drivers/net/ethernet/freescale/ucc_geth.h
@@ -22,11 +22,11 @@
 #include <linux/list.h>
 #include <linux/if_ether.h>
 
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
-#include <asm/ucc.h>
-#include <asm/ucc_fast.h>
+#include <soc/fsl/ucc.h>
+#include <soc/fsl/ucc_fast.h>
 
 #define DRV_DESC "QE UCC Gigabit Ethernet Controller"
 #define DRV_NAME "ucc_geth"
diff --git a/drivers/soc/Kconfig b/drivers/soc/Kconfig
index c854385..324d75c 100644
--- a/drivers/soc/Kconfig
+++ b/drivers/soc/Kconfig
@@ -2,4 +2,6 @@ menu "SOC (System On Chip) specific Drivers"
 
 source "drivers/soc/qcom/Kconfig"
 
+source "drivers/soc/fsl/qe/Kconfig"
+
 endmenu
diff --git a/drivers/soc/Makefile b/drivers/soc/Makefile
index 0f7c447..b85c368 100644
--- a/drivers/soc/Makefile
+++ b/drivers/soc/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_ARCH_QCOM)		+= qcom/
+obj-y				+= fsl/
diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
new file mode 100644
index 0000000..170fe81
--- /dev/null
+++ b/drivers/soc/fsl/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Linux Kernel SOC fsl specific device drivers.
+#
+
+obj-$(CONFIG_QUICC_ENGINE)		+= qe/
diff --git a/drivers/soc/fsl/qe/Kconfig b/drivers/soc/fsl/qe/Kconfig
new file mode 100644
index 0000000..e6b8862
--- /dev/null
+++ b/drivers/soc/fsl/qe/Kconfig
@@ -0,0 +1,31 @@
+#
+# QE Communication options
+#
+config QUICC_ENGINE
+	bool "Freescale QUICC Engine (QE) Support"
+	depends on FSL_SOC && PPC32
+	select PPC_LIB_RHEAP
+	select CRC32
+	help
+	  The QUICC Engine (QE) is a new generation of communications
+	  coprocessors on Freescale embedded CPUs (akin to CPM in older chips).
+	  Selecting this option means that you wish to build a kernel
+	  for a machine with a QE coprocessor.
+
+config UCC_SLOW
+	bool
+	default y if SERIAL_QE
+	help
+	  This option provides qe_lib support to UCC slow
+	  protocols: UART, BISYNC, QMC
+
+config UCC_FAST
+	bool
+	default y if UCC_GETH
+	help
+	  This option provides qe_lib support to UCC fast
+	  protocols: HDLC, Ethernet, ATM, transparent
+
+config UCC
+	bool
+	default y if UCC_FAST || UCC_SLOW
diff --git a/drivers/soc/fsl/qe/Makefile b/drivers/soc/fsl/qe/Makefile
new file mode 100644
index 0000000..703793f
--- /dev/null
+++ b/drivers/soc/fsl/qe/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the linux ppc-specific parts of QE
+#
+obj-$(CONFIG_QUICC_ENGINE)	+= qe.o
+
+obj-$(CONFIG_UCC)		+= ucc.o
+obj-$(CONFIG_UCC_SLOW)		+= ucc_slow.o
+obj-$(CONFIG_UCC_FAST)		+= ucc_fast.o
diff --git a/arch/powerpc/sysdev/qe_lib/qe.c b/drivers/soc/fsl/qe/qe.c
similarity index 99%
rename from arch/powerpc/sysdev/qe_lib/qe.c
rename to drivers/soc/fsl/qe/qe.c
index 238a07b..2c56958 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/drivers/soc/fsl/qe/qe.c
@@ -32,10 +32,10 @@
 #include <asm/irq.h>
 #include <asm/page.h>
 #include <asm/pgtable.h>
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
 #include <asm/prom.h>
 #include <asm/rheap.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
 static void qe_snums_init(void);
 static int qe_sdma_init(void);
diff --git a/arch/powerpc/sysdev/qe_lib/ucc.c b/drivers/soc/fsl/qe/ucc.c
similarity index 98%
rename from arch/powerpc/sysdev/qe_lib/ucc.c
rename to drivers/soc/fsl/qe/ucc.c
index 621575b..f444c95 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc.c
+++ b/drivers/soc/fsl/qe/ucc.c
@@ -21,9 +21,9 @@
 
 #include <asm/irq.h>
 #include <asm/io.h>
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
-#include <asm/ucc.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
+#include <soc/fsl/ucc.h>
 
 int ucc_set_qe_mux_mii_mng(unsigned int ucc_num)
 {
diff --git a/arch/powerpc/sysdev/qe_lib/ucc_fast.c b/drivers/soc/fsl/qe/ucc_fast.c
similarity index 99%
rename from arch/powerpc/sysdev/qe_lib/ucc_fast.c
rename to drivers/soc/fsl/qe/ucc_fast.c
index 65aaf15..5b2e9b5e 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_fast.c
+++ b/drivers/soc/fsl/qe/ucc_fast.c
@@ -21,11 +21,11 @@
 #include <linux/export.h>
 
 #include <asm/io.h>
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
-#include <asm/ucc.h>
-#include <asm/ucc_fast.h>
+#include <soc/fsl/ucc.h>
+#include <soc/fsl/ucc_fast.h>
 
 void ucc_fast_dump_regs(struct ucc_fast_private * uccf)
 {
diff --git a/arch/powerpc/sysdev/qe_lib/ucc_slow.c b/drivers/soc/fsl/qe/ucc_slow.c
similarity index 98%
rename from arch/powerpc/sysdev/qe_lib/ucc_slow.c
rename to drivers/soc/fsl/qe/ucc_slow.c
index befaf11..b42c5dd 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_slow.c
+++ b/drivers/soc/fsl/qe/ucc_slow.c
@@ -21,11 +21,11 @@
 #include <linux/export.h>
 
 #include <asm/io.h>
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
-#include <asm/ucc.h>
-#include <asm/ucc_slow.h>
+#include <soc/fsl/ucc.h>
+#include <soc/fsl/ucc_slow.h>
 
 u32 ucc_slow_get_qe_cr_subblock(int uccs_num)
 {
diff --git a/drivers/spi/spi-fsl-cpm.c b/drivers/spi/spi-fsl-cpm.c
index 54b0637..77524c4 100644
--- a/drivers/spi/spi-fsl-cpm.c
+++ b/drivers/spi/spi-fsl-cpm.c
@@ -22,7 +22,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/of_address.h>
 #include <asm/cpm.h>
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 
 #include "spi-fsl-lib.h"
 #include "spi-fsl-cpm.h"
diff --git a/drivers/tty/serial/ucc_uart.c b/drivers/tty/serial/ucc_uart.c
index d569ca5..a8d528b 100644
--- a/drivers/tty/serial/ucc_uart.c
+++ b/drivers/tty/serial/ucc_uart.c
@@ -31,7 +31,7 @@
 #include <linux/dma-mapping.h>
 
 #include <linux/fs_uart_pd.h>
-#include <asm/ucc_slow.h>
+#include <soc/fsl/ucc_slow.h>
 
 #include <linux/firmware.h>
 #include <asm/reg.h>
diff --git a/drivers/usb/gadget/fsl_qe_udc.c b/drivers/usb/gadget/fsl_qe_udc.c
index ad54833..9b0477b 100644
--- a/drivers/usb/gadget/fsl_qe_udc.c
+++ b/drivers/usb/gadget/fsl_qe_udc.c
@@ -38,7 +38,7 @@
 #include <linux/usb/ch9.h>
 #include <linux/usb/gadget.h>
 #include <linux/usb/otg.h>
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 #include <asm/cpm.h>
 #include <asm/dma.h>
 #include <asm/reg.h>
diff --git a/drivers/usb/host/fhci-hcd.c b/drivers/usb/host/fhci-hcd.c
index 1cf68ea..7a63726 100644
--- a/drivers/usb/host/fhci-hcd.c
+++ b/drivers/usb/host/fhci-hcd.c
@@ -31,7 +31,7 @@
 #include <linux/of_platform.h>
 #include <linux/of_gpio.h>
 #include <linux/slab.h>
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 #include <asm/fsl_gtm.h>
 #include "fhci.h"
 
diff --git a/drivers/usb/host/fhci-hub.c b/drivers/usb/host/fhci-hub.c
index 6af2512..c6e91fc 100644
--- a/drivers/usb/host/fhci-hub.c
+++ b/drivers/usb/host/fhci-hub.c
@@ -24,7 +24,7 @@
 #include <linux/usb.h>
 #include <linux/usb/hcd.h>
 #include <linux/gpio.h>
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 #include "fhci.h"
 
 /* virtual root hub specific descriptor */
diff --git a/drivers/usb/host/fhci-sched.c b/drivers/usb/host/fhci-sched.c
index 95ca598..acf4d44 100644
--- a/drivers/usb/host/fhci-sched.c
+++ b/drivers/usb/host/fhci-sched.c
@@ -25,7 +25,7 @@
 #include <linux/io.h>
 #include <linux/usb.h>
 #include <linux/usb/hcd.h>
-#include <asm/qe.h>
+#include <soc/fsl/qe.h>
 #include <asm/fsl_gtm.h>
 #include "fhci.h"
 
diff --git a/drivers/usb/host/fhci.h b/drivers/usb/host/fhci.h
index 154e6a0..7492270 100644
--- a/drivers/usb/host/fhci.h
+++ b/drivers/usb/host/fhci.h
@@ -27,8 +27,8 @@
 #include <linux/io.h>
 #include <linux/usb.h>
 #include <linux/usb/hcd.h>
-#include <asm/qe.h>
-#include <asm/immap_qe.h>
+#include <soc/fsl/qe.h>
+#include <soc/fsl/immap_qe.h>
 
 #define USB_CLOCK	48000000
 
diff --git a/arch/powerpc/include/asm/qe_ic.h b/include/linux/fsl/qe_ic.h
similarity index 100%
rename from arch/powerpc/include/asm/qe_ic.h
rename to include/linux/fsl/qe_ic.h
diff --git a/arch/powerpc/include/asm/immap_qe.h b/include/soc/fsl/immap_qe.h
similarity index 100%
rename from arch/powerpc/include/asm/immap_qe.h
rename to include/soc/fsl/immap_qe.h
diff --git a/arch/powerpc/include/asm/qe.h b/include/soc/fsl/qe.h
similarity index 99%
rename from arch/powerpc/include/asm/qe.h
rename to include/soc/fsl/qe.h
index 32b9bfa..5b54099 100644
--- a/arch/powerpc/include/asm/qe.h
+++ b/include/soc/fsl/qe.h
@@ -20,7 +20,7 @@
 #include <linux/errno.h>
 #include <linux/err.h>
 #include <asm/cpm.h>
-#include <asm/immap_qe.h>
+#include <soc/fsl/immap_qe.h>
 
 #define QE_NUM_OF_SNUM	256	/* There are 256 serial number in QE */
 #define QE_NUM_OF_BRGS	16
diff --git a/arch/powerpc/include/asm/ucc.h b/include/soc/fsl/ucc.h
similarity index 96%
rename from arch/powerpc/include/asm/ucc.h
rename to include/soc/fsl/ucc.h
index 6927ac2..cdb2345 100644
--- a/arch/powerpc/include/asm/ucc.h
+++ b/include/soc/fsl/ucc.h
@@ -15,8 +15,8 @@
 #ifndef __UCC_H__
 #define __UCC_H__
 
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
 #define STATISTICS
 
diff --git a/arch/powerpc/include/asm/ucc_fast.h b/include/soc/fsl/ucc_fast.h
similarity index 98%
rename from arch/powerpc/include/asm/ucc_fast.h
rename to include/soc/fsl/ucc_fast.h
index 72ea9ba..e8dd1f5 100644
--- a/arch/powerpc/include/asm/ucc_fast.h
+++ b/include/soc/fsl/ucc_fast.h
@@ -16,10 +16,10 @@
 
 #include <linux/kernel.h>
 
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
-#include <asm/ucc.h>
+#include <soc/fsl/ucc.h>
 
 /* Receive BD's status */
 #define R_E	0x80000000	/* buffer empty */
diff --git a/arch/powerpc/include/asm/ucc_slow.h b/include/soc/fsl/ucc_slow.h
similarity index 99%
rename from arch/powerpc/include/asm/ucc_slow.h
rename to include/soc/fsl/ucc_slow.h
index c44131e..057f861 100644
--- a/arch/powerpc/include/asm/ucc_slow.h
+++ b/include/soc/fsl/ucc_slow.h
@@ -17,10 +17,10 @@
 
 #include <linux/kernel.h>
 
-#include <asm/immap_qe.h>
-#include <asm/qe.h>
+#include <soc/fsl/immap_qe.h>
+#include <soc/fsl/qe.h>
 
-#include <asm/ucc.h>
+#include <soc/fsl/ucc.h>
 
 /* transmit BD's status */
 #define T_R	0x80000000	/* ready bit */
-- 
2.1.0.27.g96db324
