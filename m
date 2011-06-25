From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 10/72] ni5*/ni65: Move the Racal-Interlan (Micom) drivers
Date: Sat, 25 Jun 2011 06:58:21 -0700
Message-ID: <1309010363-22750-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	"Jan-Pascal van Best" <janpascal@vanbest.org>,
	Andreas Mohr <andi@lisas.de>,
	"M.Hipp" <hippm@informatik.uni-tuebingen.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13697 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab1FYN7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:55 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Racal-Interlan drivers into drivers/net/ethernet/racal/ and
make the necessary Kconfig and Makefile changes.

CC: "Jan-Pascal van Best" <janpascal@vanbest.org>
CC: Andreas Mohr <andi@lisas.de>
CC: "M.Hipp" <hippm@informatik.uni-tuebingen.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    2 +-
 drivers/net/Kconfig                       |   47 ---------------------------
 drivers/net/Makefile                      |    3 --
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/racal/Kconfig        |   50 +++++++++++++++++++++++++++++
 drivers/net/ethernet/racal/Makefile       |    7 ++++
 drivers/net/{ => ethernet/racal}/ni5010.c |    0
 drivers/net/{ => ethernet/racal}/ni5010.h |    0
 drivers/net/{ => ethernet/racal}/ni52.c   |    0
 drivers/net/{ => ethernet/racal}/ni52.h   |    0
 drivers/net/{ => ethernet/racal}/ni65.c   |    0
 drivers/net/{ => ethernet/racal}/ni65.h   |    0
 13 files changed, 60 insertions(+), 51 deletions(-)
 create mode 100644 drivers/net/ethernet/racal/Kconfig
 create mode 100644 drivers/net/ethernet/racal/Makefile
 rename drivers/net/{ => ethernet/racal}/ni5010.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni5010.h (100%)
 rename drivers/net/{ => ethernet/racal}/ni52.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni52.h (100%)
 rename drivers/net/{ => ethernet/racal}/ni65.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni65.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4dcfdc8..f567d4e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4462,7 +4462,7 @@ M:	Jan-Pascal van Best <janpascal@vanbest.org>
 M:	Andreas Mohr <andi@lisas.de>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ni5010.*
+F:	drivers/net/ethernet/racal/ni5010.*
 
 NILFS2 FILESYSTEM
 M:	KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c3399a5..8c57e20 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -690,53 +690,6 @@ config SMSC911X_ARCH_HOOKS
 	  hooks for more comprehensive interrupt control and also to override
 	  the source of the MAC address.
 
-config NET_VENDOR_RACAL
-	bool "Racal-Interlan (Micom) NI cards"
-	depends on ISA
-	help
-	  If you have a network (Ethernet) card belonging to this class, such
-	  as the NI5010, NI5210 or NI6210, say Y and read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about NI cards. If you say Y, you will be asked for
-	  your specific card in the following questions.
-
-config NI5010
-	tristate "NI5010 support (EXPERIMENTAL)"
-	depends on NET_VENDOR_RACAL && ISA && EXPERIMENTAL && BROKEN_ON_SMP
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>. Note that this is still
-	  experimental code.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ni5010.
-
-config NI52
-	tristate "NI5210 support"
-	depends on NET_VENDOR_RACAL && ISA
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ni52.
-
-config NI65
-	tristate "NI6510 support"
-	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ni65.
-
 config DNET
 	tristate "Dave ethernet support (DNET)"
 	depends on NET_ETHERNET && HAS_IOMEM
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index aa3296f..111fc02 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -147,9 +147,6 @@ obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_ATP) += atp.o
-obj-$(CONFIG_NI5010) += ni5010.o
-obj-$(CONFIG_NI52) += ni52.o
-obj-$(CONFIG_NI65) += ni65.o
 obj-$(CONFIG_APRICOT) += 82596.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index ca75c40..50c118c 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -18,6 +18,7 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
+source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 125b332..37d891d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -9,4 +9,5 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
+obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
diff --git a/drivers/net/ethernet/racal/Kconfig b/drivers/net/ethernet/racal/Kconfig
new file mode 100644
index 0000000..7d190d7
--- /dev/null
+++ b/drivers/net/ethernet/racal/Kconfig
@@ -0,0 +1,50 @@
+#
+# Racal-Interlan device configuration
+#
+
+config NET_VENDOR_RACAL
+	bool "Racal-Interlan (Micom) NI devices"
+	depends on ISA
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, such
+	  as the NI5010, NI5210 or NI6210, say Y and read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about NI cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config NI5010
+	tristate "NI5010 support (EXPERIMENTAL)"
+	depends on NET_VENDOR_RACAL && ISA && EXPERIMENTAL && BROKEN_ON_SMP
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>. Note that this is still
+	  experimental code.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ni5010.
+
+config NI52
+	tristate "NI5210 support"
+	depends on NET_VENDOR_RACAL && ISA
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ni52.
+
+config NI65
+	tristate "NI6510 support"
+	depends on NET_VENDOR_RACAL && ISA && ISA_DMA_API
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ni65.
diff --git a/drivers/net/ethernet/racal/Makefile b/drivers/net/ethernet/racal/Makefile
new file mode 100644
index 0000000..7f2915b
--- /dev/null
+++ b/drivers/net/ethernet/racal/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Racal-Interlan network device drivers.
+#
+
+obj-$(CONFIG_NI5010) += ni5010.o
+obj-$(CONFIG_NI52) += ni52.o
+obj-$(CONFIG_NI65) += ni65.o
diff --git a/drivers/net/ni5010.c b/drivers/net/ethernet/racal/ni5010.c
similarity index 100%
rename from drivers/net/ni5010.c
rename to drivers/net/ethernet/racal/ni5010.c
diff --git a/drivers/net/ni5010.h b/drivers/net/ethernet/racal/ni5010.h
similarity index 100%
rename from drivers/net/ni5010.h
rename to drivers/net/ethernet/racal/ni5010.h
diff --git a/drivers/net/ni52.c b/drivers/net/ethernet/racal/ni52.c
similarity index 100%
rename from drivers/net/ni52.c
rename to drivers/net/ethernet/racal/ni52.c
diff --git a/drivers/net/ni52.h b/drivers/net/ethernet/racal/ni52.h
similarity index 100%
rename from drivers/net/ni52.h
rename to drivers/net/ethernet/racal/ni52.h
diff --git a/drivers/net/ni65.c b/drivers/net/ethernet/racal/ni65.c
similarity index 100%
rename from drivers/net/ni65.c
rename to drivers/net/ethernet/racal/ni65.c
diff --git a/drivers/net/ni65.h b/drivers/net/ethernet/racal/ni65.h
similarity index 100%
rename from drivers/net/ni65.h
rename to drivers/net/ethernet/racal/ni65.h
-- 
1.7.5.4

