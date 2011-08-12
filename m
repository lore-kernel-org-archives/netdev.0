From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] macb: Move the Atmel driver
Date: Fri, 12 Aug 2011 12:45:40 -0700
Message-ID: <1313178344-8168-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jamie Iles <jamie@jamieiles.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63226 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180Ab1HLTpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 15:45:52 -0400
In-Reply-To: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Atmel driver into drivers/net/ethernet/cadence/ and
make the necessary Kconfig and Makefile changes.

CC: Nicolas Ferre <nicolas.ferre@atmel.com>
CC: Jamie Iles <jamie@jamieiles.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Jamie Iles <jamie@jamieiles.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |   16 -------
 drivers/net/Makefile                               |    3 -
 drivers/net/arm/Kconfig                            |   12 -----
 drivers/net/arm/Makefile                           |    6 ---
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/cadence/Kconfig               |   44 ++++++++++++++++++++
 drivers/net/ethernet/cadence/Makefile              |    6 +++
 drivers/net/{arm => ethernet/cadence}/at91_ether.c |    0
 drivers/net/{arm => ethernet/cadence}/at91_ether.h |    0
 drivers/net/{ => ethernet/cadence}/macb.c          |    0
 drivers/net/{ => ethernet/cadence}/macb.h          |    0
 13 files changed, 53 insertions(+), 38 deletions(-)
 delete mode 100644 drivers/net/arm/Kconfig
 delete mode 100644 drivers/net/arm/Makefile
 create mode 100644 drivers/net/ethernet/cadence/Kconfig
 create mode 100644 drivers/net/ethernet/cadence/Makefile
 rename drivers/net/{arm => ethernet/cadence}/at91_ether.c (100%)
 rename drivers/net/{arm => ethernet/cadence}/at91_ether.h (100%)
 rename drivers/net/{ => ethernet/cadence}/macb.c (100%)
 rename drivers/net/{ => ethernet/cadence}/macb.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 15d7021..ae60f8c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1323,7 +1323,7 @@ F:	include/video/atmel_lcdc.h
 ATMEL MACB ETHERNET DRIVER
 M:	Nicolas Ferre <nicolas.ferre@atmel.com>
 S:	Supported
-F:	drivers/net/macb.*
+F:	drivers/net/ethernet/cadence/
 
 ATMEL SPI DRIVER
 M:	Nicolas Ferre <nicolas.ferre@atmel.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 10c25b5..3f6622c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2,9 +2,6 @@
 # Network device configuration
 #
 
-config HAVE_NET_MACB
-	bool
-
 menuconfig NETDEVICES
 	default y if UML
 	depends on NET
@@ -224,19 +221,6 @@ menuconfig NET_ETHERNET
 
 if NET_ETHERNET
 
-config MACB
-	tristate "Atmel MACB support"
-	depends on HAVE_NET_MACB
-	select PHYLIB
-	help
-	  The Atmel MACB ethernet interface is found on many AT32 and AT91
-	  parts. Say Y to include support for the MACB chip.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called macb.
-
-source "drivers/net/arm/Kconfig"
-
 config SH_ETH
 	tristate "Renesas SuperH Ethernet support"
 	depends on SUPERH && \
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d249d76..d7873ba 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -63,9 +63,6 @@ obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_DNET) += dnet.o
-obj-$(CONFIG_MACB) += macb.o
-
-obj-$(CONFIG_ARM) += arm/
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_TR) += tokenring/
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
deleted file mode 100644
index 57d16b9..0000000
--- a/drivers/net/arm/Kconfig
+++ /dev/null
@@ -1,12 +0,0 @@
-#
-# Acorn Network device configuration
-#  These are for Acorn's Expansion card network interfaces
-#
-
-config ARM_AT91_ETHER
-	tristate "AT91RM9200 Ethernet support"
-	depends on ARM && ARCH_AT91RM9200
-	select MII
-	help
-	  If you wish to compile a kernel for the AT91RM9200 and enable
-	  ethernet support, then you should always answer Y to this.
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
deleted file mode 100644
index fc0f85c..0000000
--- a/drivers/net/arm/Makefile
+++ /dev/null
@@ -1,6 +0,0 @@
-# File: drivers/net/arm/Makefile
-#
-# Makefile for the ARM network device drivers
-#
-
-obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index e087337..68a31b9 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -15,6 +15,7 @@ source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
+source "drivers/net/ethernet/cadence/Kconfig"
 source "drivers/net/ethernet/adi/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 826db27..0e91c4d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
+obj-$(CONFIG_NET_ATMEL) += cadence/
 obj-$(CONFIG_NET_BFIN) += adi/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
new file mode 100644
index 0000000..c00e706
--- /dev/null
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -0,0 +1,44 @@
+#
+# Atmel device configuration
+#
+
+config HAVE_NET_MACB
+	bool
+
+config NET_ATMEL
+	bool "Atmel devices"
+	depends on HAVE_NET_MACB || (ARM && ARCH_AT91RM9200)
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y.
+	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  If unsure, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the remaining Atmel network card questions. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+if NET_ATMEL
+
+config ARM_AT91_ETHER
+	tristate "AT91RM9200 Ethernet support"
+	depends on ARM && ARCH_AT91RM9200
+	select MII
+	---help---
+	  If you wish to compile a kernel for the AT91RM9200 and enable
+	  ethernet support, then you should always answer Y to this.
+
+config MACB
+	tristate "Atmel MACB support"
+	depends on HAVE_NET_MACB
+	select PHYLIB
+	---help---
+	  The Atmel MACB ethernet interface is found on many AT32 and AT91
+	  parts. Say Y to include support for the MACB chip.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called macb.
+
+endif # NET_ATMEL
diff --git a/drivers/net/ethernet/cadence/Makefile b/drivers/net/ethernet/cadence/Makefile
new file mode 100644
index 0000000..9068b83
--- /dev/null
+++ b/drivers/net/ethernet/cadence/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Atmel network device drivers.
+#
+
+obj-$(CONFIG_ARM_AT91_ETHER) += at91_ether.o
+obj-$(CONFIG_MACB) += macb.o
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
similarity index 100%
rename from drivers/net/arm/at91_ether.c
rename to drivers/net/ethernet/cadence/at91_ether.c
diff --git a/drivers/net/arm/at91_ether.h b/drivers/net/ethernet/cadence/at91_ether.h
similarity index 100%
rename from drivers/net/arm/at91_ether.h
rename to drivers/net/ethernet/cadence/at91_ether.h
diff --git a/drivers/net/macb.c b/drivers/net/ethernet/cadence/macb.c
similarity index 100%
rename from drivers/net/macb.c
rename to drivers/net/ethernet/cadence/macb.c
diff --git a/drivers/net/macb.h b/drivers/net/ethernet/cadence/macb.h
similarity index 100%
rename from drivers/net/macb.h
rename to drivers/net/ethernet/cadence/macb.h
-- 
1.7.6

