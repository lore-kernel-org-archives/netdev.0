From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] seeq: Move the SEEQ drivers
Date: Fri, 12 Aug 2011 00:32:57 -0700
Message-ID: <1313134384-7287-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Russell King <linux@arm.linux.org.uk>,
	Hamish Coleman <hamish@zot.apana.org.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58632 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751513Ab1HLHdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 03:33:09 -0400
In-Reply-To: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the drivers that use SEEQ chipset into drivers/net/ethernet/seeq
and make the necessary Kconfig and Makefile changes.

CC: Russell King <linux@arm.linux.org.uk>
CC: Hamish Coleman <hamish@zot.apana.org.au>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                 |    3 +-
 drivers/net/Kconfig                         |   18 -----------
 drivers/net/Makefile                        |    2 -
 drivers/net/arm/Kconfig                     |    7 ----
 drivers/net/arm/Makefile                    |    1 -
 drivers/net/ethernet/Kconfig                |    1 +
 drivers/net/ethernet/Makefile               |    1 +
 drivers/net/ethernet/seeq/Kconfig           |   45 +++++++++++++++++++++++++++
 drivers/net/ethernet/seeq/Makefile          |    7 ++++
 drivers/net/{arm => ethernet/seeq}/ether3.c |    0
 drivers/net/{arm => ethernet/seeq}/ether3.h |    0
 drivers/net/{ => ethernet/seeq}/seeq8005.c  |    0
 drivers/net/{ => ethernet/seeq}/seeq8005.h  |    0
 drivers/net/{ => ethernet/seeq}/sgiseeq.c   |    0
 drivers/net/{ => ethernet/seeq}/sgiseeq.h   |    0
 15 files changed, 56 insertions(+), 29 deletions(-)
 create mode 100644 drivers/net/ethernet/seeq/Kconfig
 create mode 100644 drivers/net/ethernet/seeq/Makefile
 rename drivers/net/{arm => ethernet/seeq}/ether3.c (100%)
 rename drivers/net/{arm => ethernet/seeq}/ether3.h (100%)
 rename drivers/net/{ => ethernet/seeq}/seeq8005.c (100%)
 rename drivers/net/{ => ethernet/seeq}/seeq8005.h (100%)
 rename drivers/net/{ => ethernet/seeq}/sgiseeq.c (100%)
 rename drivers/net/{ => ethernet/seeq}/sgiseeq.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1bd9fbd..e986e3e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1014,7 +1014,8 @@ F:	arch/arm/include/asm/hardware/ioc.h
 F:	arch/arm/include/asm/hardware/iomd.h
 F:	arch/arm/include/asm/hardware/memc.h
 F:	arch/arm/mach-rpc/
-F:	drivers/net/arm/ether3*
+F:	drivers/net/ethernet/i825xx/ether1*
+F:	drivers/net/ethernet/seeq/ether3*
 F:	drivers/scsi/arm/
 
 ARM/SHARK MACHINE SUPPORT
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index aec74ad..696464c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -489,17 +489,6 @@ config ETH16I
 	  To compile this driver as a module, choose M here. The module
 	  will be called eth16i.
 
-config SEEQ8005
-	tristate "SEEQ8005 support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL
-	help
-	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
-	  is for you, read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called seeq8005.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
@@ -690,13 +679,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config SGISEEQ
-	tristate "SGI Seeq ethernet controller support"
-	depends on SGI_HAS_SEEQ
-	help
-	  Say Y here if you have an Seeq based Ethernet network card. This is
-	  used in many Silicon Graphics machines.
-
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index c98e1ad..b1ead87 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -65,7 +65,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 
 obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
-obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_FEC) += fec.o
@@ -102,7 +101,6 @@ obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
-obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index 4320e88..b6f7302 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -3,13 +3,6 @@
 #  These are for Acorn's Expansion card network interfaces
 #
 
-config ARM_ETHER3
-	tristate "Acorn/ANT Ether3 support"
-	depends on ARM && ARCH_ACORN
-	help
-	  If you have an Acorn system with one of these network cards, you
-	  should say Y to this option if you wish to use it with Linux.
-
 config ARM_AT91_ETHER
 	tristate "AT91RM9200 Ethernet support"
 	depends on ARM && ARCH_AT91RM9200
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index 5a0f141..a2532e6 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -3,7 +3,6 @@
 # Makefile for the ARM network device drivers
 #
 
-obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
 obj-$(CONFIG_ARM_KS8695_ETHER)	+= ks8695net.o
 obj-$(CONFIG_EP93XX_ETH)	+= ep93xx_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 7d25fa4..35ed4c2 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -36,6 +36,7 @@ source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
+source "drivers/net/ethernet/seeq/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/sgi/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ec58715..ea0999f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -27,6 +27,7 @@ obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SGI) += sgi/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
diff --git a/drivers/net/ethernet/seeq/Kconfig b/drivers/net/ethernet/seeq/Kconfig
new file mode 100644
index 0000000..0266791
--- /dev/null
+++ b/drivers/net/ethernet/seeq/Kconfig
@@ -0,0 +1,45 @@
+#
+# SEEQ device configuration
+#
+
+config NET_VENDOR_SEEQ
+	bool "SEEQ devices"
+	depends on (ARM && ARCH_ACORN) || SGI_HAS_SEEQ || EXPERIMENTAL
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about SEEQ devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_SEEQ
+
+config ARM_ETHER3
+	tristate "Acorn/ANT Ether3 support"
+	depends on ARM && ARCH_ACORN
+	---help---
+	  If you have an Acorn system with one of these network cards, you
+	  should say Y to this option if you wish to use it with Linux.
+
+config SEEQ8005
+	tristate "SEEQ8005 support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	---help---
+	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
+	  is for you, read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called seeq8005.
+
+config SGISEEQ
+	tristate "SGI Seeq ethernet controller support"
+	depends on SGI_HAS_SEEQ
+	---help---
+	  Say Y here if you have an Seeq based Ethernet network card. This is
+	  used in many Silicon Graphics machines.
+
+endif # NET_VENDOR_SEEQ
diff --git a/drivers/net/ethernet/seeq/Makefile b/drivers/net/ethernet/seeq/Makefile
new file mode 100644
index 0000000..3e258a5
--- /dev/null
+++ b/drivers/net/ethernet/seeq/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the SEEQ network device drivers
+#
+
+obj-$(CONFIG_ARM_ETHER3) += ether3.o
+obj-$(CONFIG_SEEQ8005) += seeq8005.o
+obj-$(CONFIG_SGISEEQ) += sgiseeq.o
diff --git a/drivers/net/arm/ether3.c b/drivers/net/ethernet/seeq/ether3.c
similarity index 100%
rename from drivers/net/arm/ether3.c
rename to drivers/net/ethernet/seeq/ether3.c
diff --git a/drivers/net/arm/ether3.h b/drivers/net/ethernet/seeq/ether3.h
similarity index 100%
rename from drivers/net/arm/ether3.h
rename to drivers/net/ethernet/seeq/ether3.h
diff --git a/drivers/net/seeq8005.c b/drivers/net/ethernet/seeq/seeq8005.c
similarity index 100%
rename from drivers/net/seeq8005.c
rename to drivers/net/ethernet/seeq/seeq8005.c
diff --git a/drivers/net/seeq8005.h b/drivers/net/ethernet/seeq/seeq8005.h
similarity index 100%
rename from drivers/net/seeq8005.h
rename to drivers/net/ethernet/seeq/seeq8005.h
diff --git a/drivers/net/sgiseeq.c b/drivers/net/ethernet/seeq/sgiseeq.c
similarity index 100%
rename from drivers/net/sgiseeq.c
rename to drivers/net/ethernet/seeq/sgiseeq.c
diff --git a/drivers/net/sgiseeq.h b/drivers/net/ethernet/seeq/sgiseeq.h
similarity index 100%
rename from drivers/net/sgiseeq.h
rename to drivers/net/ethernet/seeq/sgiseeq.h
-- 
1.7.6

