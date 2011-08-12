From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] r6040: Move the RDC driver
Date: Fri, 12 Aug 2011 12:45:41 -0700
Message-ID: <1313178344-8168-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63226 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753922Ab1HLTpw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 15:45:52 -0400
In-Reply-To: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the RDC driver into drivers/net/ethernet/rdc/ and make the
necessary Kconfig and Makefile changes.

CC: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                            |    2 +-
 drivers/net/Kconfig                    |   13 ------------
 drivers/net/Makefile                   |    1 -
 drivers/net/ethernet/Kconfig           |    1 +
 drivers/net/ethernet/Makefile          |    1 +
 drivers/net/ethernet/rdc/Kconfig       |   33 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/rdc/Makefile      |    5 ++++
 drivers/net/{ => ethernet/rdc}/r6040.c |    0
 8 files changed, 41 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/rdc/Kconfig
 create mode 100644 drivers/net/ethernet/rdc/Makefile
 rename drivers/net/{ => ethernet/rdc}/r6040.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index ae60f8c..ca3ec84 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5343,7 +5343,7 @@ RDC R6040 FAST ETHERNET DRIVER
 M:	Florian Fainelli <florian@openwrt.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/r6040.c
+F:	drivers/net/ethernet/rdc/r6040.c
 
 RDS - RELIABLE DATAGRAM SOCKETS
 M:	Andy Grover <andy.grover@oracle.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3f6622c..ca3afb5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -379,19 +379,6 @@ config FEALNX
 	  Say Y here to support the Myson MTD-800 family of PCI-based Ethernet 
 	  cards. <http://www.myson.com.tw/>
 
-config R6040
-	tristate "RDC R6040 Fast Ethernet Adapter support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	select PHYLIB
-	help
-	  This is a driver for the R6040 Fast Ethernet MACs found in the
-	  the RDC R-321x System-on-chips.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called r6040. This is recommended.
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d7873ba..051439f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -16,7 +16,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 68a31b9..78e567f 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -83,6 +83,7 @@ source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
+source "drivers/net/ethernet/rdc/Kconfig"
 
 config S6GMAC
 	tristate "S6105 GMAC ethernet support"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 0e91c4d..48d3209 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
diff --git a/drivers/net/ethernet/rdc/Kconfig b/drivers/net/ethernet/rdc/Kconfig
new file mode 100644
index 0000000..b15ebac
--- /dev/null
+++ b/drivers/net/ethernet/rdc/Kconfig
@@ -0,0 +1,33 @@
+#
+# RDC network device configuration
+#
+
+config NET_VENDOR_RDC
+	bool "RDC devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about RDC cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_RDC
+
+config R6040
+	tristate "RDC R6040 Fast Ethernet Adapter support"
+	depends on PCI
+	select CRC32
+	select MII
+	select PHYLIB
+	---help---
+	  This is a driver for the R6040 Fast Ethernet MACs found in the
+	  the RDC R-321x System-on-chips.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called r6040. This is recommended.
+
+endif # NET_VENDOR_RDC
diff --git a/drivers/net/ethernet/rdc/Makefile b/drivers/net/ethernet/rdc/Makefile
new file mode 100644
index 0000000..8d51fd2
--- /dev/null
+++ b/drivers/net/ethernet/rdc/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the RDC network device drivers.
+#
+
+obj-$(CONFIG_R6040) += r6040.o
diff --git a/drivers/net/r6040.c b/drivers/net/ethernet/rdc/r6040.c
similarity index 100%
rename from drivers/net/r6040.c
rename to drivers/net/ethernet/rdc/r6040.c
-- 
1.7.6

