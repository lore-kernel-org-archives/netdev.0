From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 54/72] au1000_eth/mipsnet/tc35815: Move the MIPS drivers
Date: Sat, 25 Jun 2011 06:59:05 -0700
Message-ID: <1309010363-22750-55-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Matt Porter <mporter@kernel.crashing.org>,
	Herbert Valerio Riedel <hvr@gnu.org>,
	MontaVista Software <source@mvista.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355Ab1FYOAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:22 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the MIPS drivers into drivers/net/ethernet/mips/ and
make the necessary Kconfig and Makefile changes.

CC: Ralf Baechle <ralf@linux-mips.org>
CC: Matt Porter <mporter@kernel.crashing.org>
CC: Herbert Valerio Riedel <hvr@gnu.org>
CC: MontaVista Software <source@mvista.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                          |   42 ------------------
 drivers/net/Makefile                         |    6 ---
 drivers/net/ethernet/Kconfig                 |    1 +
 drivers/net/ethernet/Makefile                |    1 +
 drivers/net/ethernet/mips/Kconfig            |   61 ++++++++++++++++++++++++++
 drivers/net/ethernet/mips/Makefile           |   10 ++++
 drivers/net/{ => ethernet/mips}/au1000_eth.c |    0
 drivers/net/{ => ethernet/mips}/au1000_eth.h |    0
 drivers/net/{ => ethernet/mips}/lasi_82596.c |    0
 drivers/net/{ => ethernet/mips}/mipsnet.c    |    0
 drivers/net/{ => ethernet/mips}/sni_82596.c  |    0
 drivers/net/{ => ethernet/mips}/tc35815.c    |    0
 12 files changed, 73 insertions(+), 48 deletions(-)
 create mode 100644 drivers/net/ethernet/mips/Kconfig
 create mode 100644 drivers/net/ethernet/mips/Makefile
 rename drivers/net/{ => ethernet/mips}/au1000_eth.c (100%)
 rename drivers/net/{ => ethernet/mips}/au1000_eth.h (100%)
 rename drivers/net/{ => ethernet/mips}/lasi_82596.c (100%)
 rename drivers/net/{ => ethernet/mips}/mipsnet.c (100%)
 rename drivers/net/{ => ethernet/mips}/sni_82596.c (100%)
 rename drivers/net/{ => ethernet/mips}/tc35815.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2635bd1..29eca29 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -235,37 +235,6 @@ config MACB
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
 
-config LASI_82596
-	tristate "Lasi ethernet"
-	depends on GSC
-	help
-	  Say Y here to support the builtin Intel 82596 ethernet controller
-	  found in Hewlett-Packard PA-RISC machines with 10Mbit ethernet.
-
-config SNI_82596
-	tristate "SNI RM ethernet"
-	depends on NET_ETHERNET && SNI_RM
-	help
-	  Say Y here to support the on-board Intel 82596 ethernet controller
-	  built into SNI RM machines.
-
-config MIPS_AU1X00_ENET
-	tristate "MIPS AU1000 Ethernet support"
-	depends on MIPS_ALCHEMY
-	select PHYLIB
-	select CRC32
-	help
-	  If you have an Alchemy Semi AU1X00 based system
-	  say Y.  Otherwise, say N.
-
-config MIPS_SIM_NET
-	tristate "MIPS simulator Network device"
-	depends on MIPS_SIM
-	help
-	  The MIPSNET device is a simple Ethernet network device which is
-	  emulated by the MIPS Simulator.
-	  If you are not using a MIPSsim or are unsure, say N.
-
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
@@ -486,11 +455,6 @@ config FORCEDETH
 	  To compile this driver as a module, choose M here. The module
 	  will be called forcedeth.
 
-config TC35815
-	tristate "TOSHIBA TC35815 Ethernet support"
-	depends on NET_PCI && PCI && MIPS
-	select PHYLIB
-
 config FEALNX
 	tristate "Myson MTD-8xx PCI Ethernet support"
 	depends on NET_PCI && PCI
@@ -569,12 +533,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config LANTIQ_ETOP
-	tristate "Lantiq SoC ETOP driver"
-	depends on SOC_TYPE_XWAY
-	help
-	  Support for the MII0 inside the Lantiq SoC
-
 endif # NET_ETHERNET
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 3dff87b..4315328 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,7 +19,6 @@ obj-$(CONFIG_ROADRUNNER) += rrunner.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_FEALNX) += fealnx.o
-obj-$(CONFIG_TC35815) += tc35815.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
@@ -58,12 +57,8 @@ obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_DEPCA) += depca.o
-obj-$(CONFIG_LASI_82596) += lasi_82596.o
-obj-$(CONFIG_SNI_82596) += sni_82596.o
 obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_EQUALIZER) += eql.o
-obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
-obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
@@ -72,7 +67,6 @@ obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
-obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_MACB) += macb.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6115051..ef622d2 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -74,6 +74,7 @@ config KORINA
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
+source "drivers/net/ethernet/mips/Kconfig"
 source "drivers/net/ethernet/motorola/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 22a6eaa..1ab5f1f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
+obj-$(CONFIG_NET_MIPS) += mips/
 obj-$(CONFIG_NET_VENDOR_MOTOROLA) += motorola/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
diff --git a/drivers/net/ethernet/mips/Kconfig b/drivers/net/ethernet/mips/Kconfig
new file mode 100644
index 0000000..bc5d61e
--- /dev/null
+++ b/drivers/net/ethernet/mips/Kconfig
@@ -0,0 +1,61 @@
+#
+# MIPS device configuration
+#
+
+config NET_MIPS
+	bool "MIPS/PS-RISC devices"
+	depends on MIPS_ALCHEMY || MIPS_SIM || (PCI && MIPS) || GSC || \
+		SNI_RM || SOC_TYPE_XWAY
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  If unsure, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the remaining MIPS network card questions. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config LANTIQ_ETOP
+	tristate "Lantiq SoC ETOP driver"
+	depends on NET_MIPS && SOC_TYPE_XWAY
+	---help---
+	  Support for the MII0 inside the Lantiq SoC
+
+config LASI_82596
+	tristate "Lasi ethernet"
+	depends on NET_MIPS && GSC
+	---help---
+	  Say Y here to support the builtin Intel 82596 ethernet controller
+	  found in Hewlett-Packard PA-RISC machines with 10Mbit ethernet.
+
+config MIPS_AU1X00_ENET
+	tristate "MIPS AU1000 Ethernet support"
+	depends on NET_MIPS && MIPS_ALCHEMY
+	select PHYLIB
+	select CRC32
+	---help---
+	  If you have an Alchemy Semi AU1X00 based system
+	  say Y.  Otherwise, say N.
+
+config MIPS_SIM_NET
+	tristate "MIPS simulator Network device"
+	depends on NET_MIPS && MIPS_SIM
+	---help---
+	  The MIPSNET device is a simple Ethernet network device which is
+	  emulated by the MIPS Simulator.
+	  If you are not using a MIPSsim or are unsure, say N.
+
+config SNI_82596
+	tristate "SNI RM ethernet"
+	depends on NET_MIPS && SNI_RM
+	---help---
+	  Say Y here to support the on-board Intel 82596 ethernet controller
+	  built into SNI RM machines.
+
+config TC35815
+	tristate "TOSHIBA TC35815 Ethernet support"
+	depends on NET_MIPS && PCI && MIPS
+	select PHYLIB
diff --git a/drivers/net/ethernet/mips/Makefile b/drivers/net/ethernet/mips/Makefile
new file mode 100644
index 0000000..1fc1ac1
--- /dev/null
+++ b/drivers/net/ethernet/mips/Makefile
@@ -0,0 +1,10 @@
+#
+# Makefile for the MIPS device drivers.
+#
+
+obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
+obj-$(CONFIG_LASI_82596) += lasi_82596.o
+obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
+obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
+obj-$(CONFIG_SNI_82596) += sni_82596.o
+obj-$(CONFIG_TC35815) += tc35815.o
diff --git a/drivers/net/au1000_eth.c b/drivers/net/ethernet/mips/au1000_eth.c
similarity index 100%
rename from drivers/net/au1000_eth.c
rename to drivers/net/ethernet/mips/au1000_eth.c
diff --git a/drivers/net/au1000_eth.h b/drivers/net/ethernet/mips/au1000_eth.h
similarity index 100%
rename from drivers/net/au1000_eth.h
rename to drivers/net/ethernet/mips/au1000_eth.h
diff --git a/drivers/net/lasi_82596.c b/drivers/net/ethernet/mips/lasi_82596.c
similarity index 100%
rename from drivers/net/lasi_82596.c
rename to drivers/net/ethernet/mips/lasi_82596.c
diff --git a/drivers/net/mipsnet.c b/drivers/net/ethernet/mips/mipsnet.c
similarity index 100%
rename from drivers/net/mipsnet.c
rename to drivers/net/ethernet/mips/mipsnet.c
diff --git a/drivers/net/sni_82596.c b/drivers/net/ethernet/mips/sni_82596.c
similarity index 100%
rename from drivers/net/sni_82596.c
rename to drivers/net/ethernet/mips/sni_82596.c
diff --git a/drivers/net/tc35815.c b/drivers/net/ethernet/mips/tc35815.c
similarity index 100%
rename from drivers/net/tc35815.c
rename to drivers/net/ethernet/mips/tc35815.c
-- 
1.7.5.4

