From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/71] ni5010: Move the Racal-Interlan (Micom) driver
Date: Sat, 30 Jul 2011 20:26:30 -0700
Message-ID: <1312082850-24914-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	"Jan-Pascal van Best" <janpascal@vanbest.org>,
	Andreas Mohr <andi@lisas.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54473 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753128Ab1GaD1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:45 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Racal-Interlan driver into drivers/net/ethernet/racal/ and
make the necessary Kconfig and Makefile changes.

CC: "Jan-Pascal van Best" <janpascal@vanbest.org>
CC: Andreas Mohr <andi@lisas.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    2 +-
 drivers/net/Kconfig                       |   25 -------------------------
 drivers/net/Makefile                      |    1 -
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/racal/Kconfig        |   28 ++++++++++++++++++++++++++++
 drivers/net/ethernet/racal/Makefile       |    5 +++++
 drivers/net/{ => ethernet/racal}/ni5010.c |    0
 drivers/net/{ => ethernet/racal}/ni5010.h |    0
 9 files changed, 36 insertions(+), 27 deletions(-)
 create mode 100644 drivers/net/ethernet/racal/Kconfig
 create mode 100644 drivers/net/ethernet/racal/Makefile
 rename drivers/net/{ => ethernet/racal}/ni5010.c (100%)
 rename drivers/net/{ => ethernet/racal}/ni5010.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index b423be0..e922c04 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4494,7 +4494,7 @@ M:	Jan-Pascal van Best <janpascal@vanbest.org>
 M:	Andreas Mohr <andi@lisas.de>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ni5010.*
+F:	drivers/net/ethernet/racal/ni5010.*
 
 NILFS2 FILESYSTEM
 M:	KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d7d0b35..b76de82 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -581,31 +581,6 @@ config GRETH
 	help
 	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
 
-config NET_VENDOR_RACAL
-	bool "Racal-Interlan (Micom) NI cards"
-	depends on ISA
-	help
-	  If you have a network (Ethernet) card belonging to this class, such
-	  as the NI5010, say Y and read the Ethernet-HOWTO,
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
 config DNET
 	tristate "Dave ethernet support (DNET)"
 	depends on NET_ETHERNET && HAS_IOMEM
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 49b3e87..e641f70 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -140,7 +140,6 @@ obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_ATP) += atp.o
-obj-$(CONFIG_NI5010) += ni5010.o
 obj-$(CONFIG_SC92031) += sc92031.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index d0a8fa8..7efbb7c 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -19,6 +19,7 @@ source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
+source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/smsc/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 6d3276a..86da8b8 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -10,4 +10,5 @@ obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
+obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
diff --git a/drivers/net/ethernet/racal/Kconfig b/drivers/net/ethernet/racal/Kconfig
new file mode 100644
index 0000000..713c33e
--- /dev/null
+++ b/drivers/net/ethernet/racal/Kconfig
@@ -0,0 +1,28 @@
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
diff --git a/drivers/net/ethernet/racal/Makefile b/drivers/net/ethernet/racal/Makefile
new file mode 100644
index 0000000..1e210ca
--- /dev/null
+++ b/drivers/net/ethernet/racal/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Racal-Interlan network device drivers.
+#
+
+obj-$(CONFIG_NI5010) += ni5010.o
diff --git a/drivers/net/ni5010.c b/drivers/net/ethernet/racal/ni5010.c
similarity index 100%
rename from drivers/net/ni5010.c
rename to drivers/net/ethernet/racal/ni5010.c
diff --git a/drivers/net/ni5010.h b/drivers/net/ethernet/racal/ni5010.h
similarity index 100%
rename from drivers/net/ni5010.h
rename to drivers/net/ethernet/racal/ni5010.h
-- 
1.7.6

