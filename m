From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 13/72] be2net: Move the Emulex driver
Date: Sat, 25 Jun 2011 06:58:24 -0700
Message-ID: <1309010363-22750-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13697 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986Ab1FYOAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:03 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Emulex driver into drivers/net/ethernet/emulex/ and
make the necessary Kconfig and Makefile changes.

CC: Sathya Perla <sathya.perla@emulex.com>
CC: Subbu Seetharaman <subbu.seetharaman@emulex.com>
CC: Ajit Khaparde <ajit.khaparde@emulex.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |    2 --
 drivers/net/Makefile                               |    1 -
 drivers/net/benet/Kconfig                          |    6 ------
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/emulex/Kconfig                |   18 ++++++++++++++++++
 drivers/net/ethernet/emulex/Makefile               |    5 +++++
 drivers/net/ethernet/emulex/benet/Kconfig          |    6 ++++++
 drivers/net/{ => ethernet/emulex}/benet/Makefile   |    0
 drivers/net/{ => ethernet/emulex}/benet/be.h       |    0
 drivers/net/{ => ethernet/emulex}/benet/be_cmds.c  |    0
 drivers/net/{ => ethernet/emulex}/benet/be_cmds.h  |    0
 .../net/{ => ethernet/emulex}/benet/be_ethtool.c   |    0
 drivers/net/{ => ethernet/emulex}/benet/be_hw.h    |    0
 drivers/net/{ => ethernet/emulex}/benet/be_main.c  |    0
 16 files changed, 32 insertions(+), 10 deletions(-)
 delete mode 100644 drivers/net/benet/Kconfig
 create mode 100644 drivers/net/ethernet/emulex/Kconfig
 create mode 100644 drivers/net/ethernet/emulex/Makefile
 create mode 100644 drivers/net/ethernet/emulex/benet/Kconfig
 rename drivers/net/{ => ethernet/emulex}/benet/Makefile (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_cmds.c (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_cmds.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_ethtool.c (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_hw.h (100%)
 rename drivers/net/{ => ethernet/emulex}/benet/be_main.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index cc16a52f..5bf6ae2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5655,7 +5655,7 @@ M:	Ajit Khaparde <ajit.khaparde@emulex.com>
 L:	netdev@vger.kernel.org
 W:	http://www.emulex.com
 S:	Supported
-F:	drivers/net/benet/
+F:	drivers/net/ethernet/emulex/benet/
 
 SFC NETWORK DRIVER
 M:	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 51dbdb5..5218303 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1781,8 +1781,6 @@ config BNA
 
 	  <http://support.brocade.com>
 
-source "drivers/net/benet/Kconfig"
-
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b616154..5e1ccb5 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -24,7 +24,6 @@ obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
-obj-$(CONFIG_BE2NET) += benet/
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 obj-$(CONFIG_BNA) += bna/
 
diff --git a/drivers/net/benet/Kconfig b/drivers/net/benet/Kconfig
deleted file mode 100644
index 1a41a49..0000000
--- a/drivers/net/benet/Kconfig
+++ /dev/null
@@ -1,6 +0,0 @@
-config BE2NET
-	tristate "ServerEngines' 10Gbps NIC - BladeEngine"
-	depends on PCI && INET
-	help
-	This driver implements the NIC functionality for ServerEngines'
-	10Gbps network adapter - BladeEngine.
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 37819a1..97a4b57 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -16,6 +16,7 @@ source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
+source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 917131c..bf9b2e9 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
+obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
diff --git a/drivers/net/ethernet/emulex/Kconfig b/drivers/net/ethernet/emulex/Kconfig
new file mode 100644
index 0000000..f8a68ce
--- /dev/null
+++ b/drivers/net/ethernet/emulex/Kconfig
@@ -0,0 +1,18 @@
+#
+# Emulex driver configuration
+#
+
+config NET_VENDOR_EMULEX
+	bool "Emulex devices"
+	depends on PCI || INET
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Emulex cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+source "drivers/net/ethernet/emulex/benet/Kconfig"
diff --git a/drivers/net/ethernet/emulex/Makefile b/drivers/net/ethernet/emulex/Makefile
new file mode 100644
index 0000000..ea8ec57
--- /dev/null
+++ b/drivers/net/ethernet/emulex/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Emulex device drivers.
+#
+
+obj-$(CONFIG_BE2NET) += benet/
diff --git a/drivers/net/ethernet/emulex/benet/Kconfig b/drivers/net/ethernet/emulex/benet/Kconfig
new file mode 100644
index 0000000..ca2c28e
--- /dev/null
+++ b/drivers/net/ethernet/emulex/benet/Kconfig
@@ -0,0 +1,6 @@
+config BE2NET
+	tristate "ServerEngines' 10Gbps NIC - BladeEngine"
+	depends on NET_VENDOR_EMULEX && PCI && INET
+	---help---
+	  This driver implements the NIC functionality for ServerEngines'
+	  10Gbps network adapter - BladeEngine.
diff --git a/drivers/net/benet/Makefile b/drivers/net/ethernet/emulex/benet/Makefile
similarity index 100%
rename from drivers/net/benet/Makefile
rename to drivers/net/ethernet/emulex/benet/Makefile
diff --git a/drivers/net/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
similarity index 100%
rename from drivers/net/benet/be.h
rename to drivers/net/ethernet/emulex/benet/be.h
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
similarity index 100%
rename from drivers/net/benet/be_cmds.c
rename to drivers/net/ethernet/emulex/benet/be_cmds.c
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
similarity index 100%
rename from drivers/net/benet/be_cmds.h
rename to drivers/net/ethernet/emulex/benet/be_cmds.h
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
similarity index 100%
rename from drivers/net/benet/be_ethtool.c
rename to drivers/net/ethernet/emulex/benet/be_ethtool.c
diff --git a/drivers/net/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
similarity index 100%
rename from drivers/net/benet/be_hw.h
rename to drivers/net/ethernet/emulex/benet/be_hw.h
diff --git a/drivers/net/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
similarity index 100%
rename from drivers/net/benet/be_main.c
rename to drivers/net/ethernet/emulex/benet/be_main.c
-- 
1.7.5.4

