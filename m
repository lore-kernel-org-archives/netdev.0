From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 22/72] stmmac: Move the STMicroelectronics driver
Date: Sat, 25 Jun 2011 06:58:33 -0700
Message-ID: <1309010363-22750-23-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61256 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199Ab1FYOAO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:14 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the STMicroelectronics driver into driver/net/ethernet/stmicro/ and
make the necessary Kconfig and Makefile changes.

CC: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |    2 --
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/stmicro/Kconfig               |   18 ++++++++++++++++++
 drivers/net/ethernet/stmicro/Makefile              |    5 +++++
 drivers/net/{ => ethernet/stmicro}/stmmac/Kconfig  |   14 +++++++-------
 drivers/net/{ => ethernet/stmicro}/stmmac/Makefile |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/common.h |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/descs.h  |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac100.h   |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac1000.h  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac1000_core.c |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac1000_dma.c  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac100_core.c  |    0
 .../{ => ethernet/stmicro}/stmmac/dwmac100_dma.c   |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac_dma.h  |    0
 .../net/{ => ethernet/stmicro}/stmmac/dwmac_lib.c  |    0
 .../net/{ => ethernet/stmicro}/stmmac/enh_desc.c   |    0
 .../net/{ => ethernet/stmicro}/stmmac/norm_desc.c  |    0
 drivers/net/{ => ethernet/stmicro}/stmmac/stmmac.h |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_ethtool.c |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_main.c    |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_mdio.c    |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_timer.c   |    0
 .../{ => ethernet/stmicro}/stmmac/stmmac_timer.h   |    0
 27 files changed, 33 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/ethernet/stmicro/Kconfig
 create mode 100644 drivers/net/ethernet/stmicro/Makefile
 rename drivers/net/{ => ethernet/stmicro}/stmmac/Kconfig (92%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/Makefile (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/common.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/descs.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000_core.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac1000_dma.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100_core.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac100_dma.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac_dma.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/dwmac_lib.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/enh_desc.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/norm_desc.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac.h (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_ethtool.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_main.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_mdio.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_timer.c (100%)
 rename drivers/net/{ => ethernet/stmicro}/stmmac/stmmac_timer.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 015e658..6f822c6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1996,7 +1996,7 @@ M:	Giuseppe Cavallaro <peppe.cavallaro@st.com>
 L:	netdev@vger.kernel.org
 W:	http://www.stlinux.com
 S:	Supported
-F:	drivers/net/stmmac/
+F:	drivers/net/ethernet/stmicro/stmmac/
 
 CYBERPRO FB DRIVER
 M:	Russell King <linux@arm.linux.org.uk>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1e157e7..4be1bcf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1574,8 +1574,6 @@ config S6GMAC
 	  To compile this driver as a module, choose M here. The module
 	  will be called s6gmac.
 
-source "drivers/net/stmmac/Kconfig"
-
 config PCH_GBE
 	tristate "Intel EG20T PCH / OKI SEMICONDUCTOR ML7223 IOH GbE"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 2c90508..9a73e0f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -69,7 +69,6 @@ obj-$(CONFIG_VIA_VELOCITY) += via-velocity.o
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_SH_ETH) += sh_eth.o
-obj-$(CONFIG_STMMAC_ETH) += stmmac/
 
 #
 # end link order section
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 74573fa..4714825 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -38,6 +38,7 @@ source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
+source "drivers/net/ethernet/stmicro/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 
 config TEHUTI
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d98ae32..76ea04b 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -20,5 +20,6 @@ obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
+obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_TEHUTI) += tehuti.o
diff --git a/drivers/net/ethernet/stmicro/Kconfig b/drivers/net/ethernet/stmicro/Kconfig
new file mode 100644
index 0000000..d4f7e02
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/Kconfig
@@ -0,0 +1,18 @@
+#
+# STMicroelectronics device configuration
+#
+
+config NET_VENDOR_STMICRO
+	bool "STMicroelectronics devices"
+	depends on HAS_IOMEM
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about STMicroelectronics cards. If you say Y, you will
+	  be asked for your specific card in the following questions.
+
+source "drivers/net/ethernet/stmicro/stmmac/Kconfig"
diff --git a/drivers/net/ethernet/stmicro/Makefile b/drivers/net/ethernet/stmicro/Makefile
new file mode 100644
index 0000000..9b3bfdd
--- /dev/null
+++ b/drivers/net/ethernet/stmicro/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the STMicroelectronics device drivers.
+#
+
+obj-$(CONFIG_STMMAC_ETH) += stmmac/
diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
similarity index 92%
rename from drivers/net/stmmac/Kconfig
rename to drivers/net/ethernet/stmicro/stmmac/Kconfig
index 7df7df4..e1d915d 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -1,10 +1,10 @@
 config STMMAC_ETH
 	tristate "STMicroelectronics 10/100/1000 Ethernet driver"
+	depends on NET_VENDOR_STMICRO && HAS_IOMEM
 	select MII
 	select PHYLIB
 	select CRC32
-	depends on NETDEVICES && HAS_IOMEM
-	help
+	---help---
 	  This is the driver for the Ethernet IPs are built around a
 	  Synopsys IP Core and only tested on the STMicroelectronics
 	  platforms.
@@ -14,7 +14,7 @@ if STMMAC_ETH
 config STMMAC_DA
 	bool "STMMAC DMA arbitration scheme"
 	default n
-	help
+	---help---
 	  Selecting this option, rx has priority over Tx (only for Giga
 	  Ethernet device).
 	  By default, the DMA arbitration scheme is based on Round-robin
@@ -24,7 +24,7 @@ config STMMAC_DUAL_MAC
 	bool "STMMAC: dual mac support (EXPERIMENTAL)"
 	default n
         depends on EXPERIMENTAL && STMMAC_ETH && !STMMAC_TIMER
-	help
+	---help---
 	  Some ST SoCs (for example the stx7141 and stx7200c2) have two
 	  Ethernet Controllers. This option turns on the second Ethernet
 	  device on this kind of platforms.
@@ -33,7 +33,7 @@ config STMMAC_TIMER
 	bool "STMMAC Timer optimisation"
 	default n
 	depends on RTC_HCTOSYS_DEVICE
-	help
+	---help---
 	  Use an external timer for mitigating the number of network
 	  interrupts. Currently, for SH architectures, it is possible
 	  to use the TMU channel 2 and the SH-RTC device.
@@ -45,12 +45,12 @@ choice
 config STMMAC_TMU_TIMER
         bool "TMU channel 2"
         depends on CPU_SH4
-	help
+	---help---
 
 config STMMAC_RTC_TIMER
         bool "Real time clock"
         depends on RTC_CLASS
-	help
+	---help---
 
 endchoice
 
diff --git a/drivers/net/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
similarity index 100%
rename from drivers/net/stmmac/Makefile
rename to drivers/net/ethernet/stmicro/stmmac/Makefile
diff --git a/drivers/net/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
similarity index 100%
rename from drivers/net/stmmac/common.h
rename to drivers/net/ethernet/stmicro/stmmac/common.h
diff --git a/drivers/net/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
similarity index 100%
rename from drivers/net/stmmac/descs.h
rename to drivers/net/ethernet/stmicro/stmmac/descs.h
diff --git a/drivers/net/stmmac/dwmac100.h b/drivers/net/ethernet/stmicro/stmmac/dwmac100.h
similarity index 100%
rename from drivers/net/stmmac/dwmac100.h
rename to drivers/net/ethernet/stmicro/stmmac/dwmac100.h
diff --git a/drivers/net/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
similarity index 100%
rename from drivers/net/stmmac/dwmac1000.h
rename to drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
similarity index 100%
rename from drivers/net/stmmac/dwmac1000_core.c
rename to drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
similarity index 100%
rename from drivers/net/stmmac/dwmac1000_dma.c
rename to drivers/net/ethernet/stmicro/stmmac/dwmac1000_dma.c
diff --git a/drivers/net/stmmac/dwmac100_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
similarity index 100%
rename from drivers/net/stmmac/dwmac100_core.c
rename to drivers/net/ethernet/stmicro/stmmac/dwmac100_core.c
diff --git a/drivers/net/stmmac/dwmac100_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
similarity index 100%
rename from drivers/net/stmmac/dwmac100_dma.c
rename to drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c
diff --git a/drivers/net/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
similarity index 100%
rename from drivers/net/stmmac/dwmac_dma.h
rename to drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
diff --git a/drivers/net/stmmac/dwmac_lib.c b/drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
similarity index 100%
rename from drivers/net/stmmac/dwmac_lib.c
rename to drivers/net/ethernet/stmicro/stmmac/dwmac_lib.c
diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
similarity index 100%
rename from drivers/net/stmmac/enh_desc.c
rename to drivers/net/ethernet/stmicro/stmmac/enh_desc.c
diff --git a/drivers/net/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
similarity index 100%
rename from drivers/net/stmmac/norm_desc.c
rename to drivers/net/ethernet/stmicro/stmmac/norm_desc.c
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
similarity index 100%
rename from drivers/net/stmmac/stmmac.h
rename to drivers/net/ethernet/stmicro/stmmac/stmmac.h
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
similarity index 100%
rename from drivers/net/stmmac/stmmac_ethtool.c
rename to drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
similarity index 100%
rename from drivers/net/stmmac/stmmac_main.c
rename to drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
diff --git a/drivers/net/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
similarity index 100%
rename from drivers/net/stmmac/stmmac_mdio.c
rename to drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
diff --git a/drivers/net/stmmac/stmmac_timer.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
similarity index 100%
rename from drivers/net/stmmac/stmmac_timer.c
rename to drivers/net/ethernet/stmicro/stmmac/stmmac_timer.c
diff --git a/drivers/net/stmmac/stmmac_timer.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h
similarity index 100%
rename from drivers/net/stmmac/stmmac_timer.h
rename to drivers/net/ethernet/stmicro/stmmac/stmmac_timer.h
-- 
1.7.5.4

