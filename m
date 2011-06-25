From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 17/72] s2io/vxge: Move the Exar drivers
Date: Sat, 25 Jun 2011 06:58:28 -0700
Message-ID: <1309010363-22750-18-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Jon Mason <jdmason@kudzu.us>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13697 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752149Ab1FYOAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:07 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Exar drivers into drivers/net/ethernet/neterion/ and make the
necessary Kconfig and Makefile changes.

CC: Jon Mason <jdmason@kudzu.us>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    3 +-
 drivers/net/Kconfig                                |   34 -------------
 drivers/net/Makefile                               |    2 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/neterion/Kconfig              |   50 ++++++++++++++++++++
 drivers/net/ethernet/neterion/Makefile             |    6 ++
 drivers/net/{ => ethernet/neterion}/s2io-regs.h    |    0
 drivers/net/{ => ethernet/neterion}/s2io.c         |    0
 drivers/net/{ => ethernet/neterion}/s2io.h         |    0
 drivers/net/{ => ethernet/neterion}/vxge/Makefile  |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-config.c |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-config.h |    0
 .../{ => ethernet/neterion}/vxge/vxge-ethtool.c    |    0
 .../{ => ethernet/neterion}/vxge/vxge-ethtool.h    |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-main.c   |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-main.h   |    0
 .../net/{ => ethernet/neterion}/vxge/vxge-reg.h    |    0
 .../{ => ethernet/neterion}/vxge/vxge-traffic.c    |    0
 .../{ => ethernet/neterion}/vxge/vxge-traffic.h    |    0
 .../{ => ethernet/neterion}/vxge/vxge-version.h    |    0
 21 files changed, 59 insertions(+), 38 deletions(-)
 create mode 100644 drivers/net/ethernet/neterion/Kconfig
 create mode 100644 drivers/net/ethernet/neterion/Makefile
 rename drivers/net/{ => ethernet/neterion}/s2io-regs.h (100%)
 rename drivers/net/{ => ethernet/neterion}/s2io.c (100%)
 rename drivers/net/{ => ethernet/neterion}/s2io.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/Makefile (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-config.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-config.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-ethtool.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-ethtool.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-main.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-main.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-reg.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-traffic.c (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-traffic.h (100%)
 rename drivers/net/{ => ethernet/neterion}/vxge/vxge-version.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 81dfcff..816c665 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4321,9 +4321,8 @@ W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/Linux?Anonymous
 W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/X3100Linux?Anonymous
 S:	Supported
 F:	Documentation/networking/s2io.txt
-F:	drivers/net/s2io*
 F:	Documentation/networking/vxge.txt
-F:	drivers/net/vxge/
+F:	drivers/net/ethernet/neterion/
 
 NETFILTER/IPTABLES/IPCHAINS
 P:	Rusty Russell
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6b58ee3..6294de0 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1668,40 +1668,6 @@ config ENIC
 	help
 	  This enables the support for the Cisco VIC Ethernet card.
 
-config S2IO
-	tristate "Exar Xframe 10Gb Ethernet Adapter"
-	depends on PCI
-	---help---
-	  This driver supports Exar Corp's Xframe Series 10Gb Ethernet Adapters.
-
-	  More specific information on configuring the driver is in 
-	  <file:Documentation/networking/s2io.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called s2io.
-
-config VXGE
-	tristate "Exar X3100 Series 10GbE PCIe Server Adapter"
-	depends on PCI && INET
-	---help---
-	  This driver supports Exar Corp's X3100 Series 10 GbE PCIe
-	  I/O Virtualized Server Adapter.
-
-	  More specific information on configuring the driver is in
-	  <file:Documentation/networking/vxge.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called vxge.
-
-config VXGE_DEBUG_TRACE_ALL
-	bool "Enabling All Debug trace statments in driver"
-	default n
-	depends on VXGE
-	---help---
-	  Say Y here if you want to enabling all the debug trace statements in
-	  the vxge driver. By default only few debug trace statements are
-	  enabled.
-
 config PASEMI_MAC
 	tristate "PA Semi 1/10Gbit MAC"
 	depends on PPC_PASEMI && PCI && INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 15c3598..5241d6e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -166,8 +166,6 @@ obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_R8169) += r8169.o
 obj-$(CONFIG_IBMVETH) += ibmveth.o
-obj-$(CONFIG_S2IO) += s2io.o
-obj-$(CONFIG_VXGE) += vxge/
 obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6149413..a23ea19 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -18,6 +18,7 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
+source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 093b44f..690421d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
+obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
diff --git a/drivers/net/ethernet/neterion/Kconfig b/drivers/net/ethernet/neterion/Kconfig
new file mode 100644
index 0000000..c79fbe9
--- /dev/null
+++ b/drivers/net/ethernet/neterion/Kconfig
@@ -0,0 +1,50 @@
+#
+# Exar device configuration
+#
+
+config NET_VENDOR_EXAR
+	bool "Exar network devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say
+	  Y and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Exar cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config S2IO
+	tristate "Exar Xframe 10Gb Ethernet Adapter"
+	depends on NET_VENDOR_EXAR && PCI
+	---help---
+	  This driver supports Exar Corp's Xframe Series 10Gb Ethernet Adapters.
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/s2io.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called s2io.
+
+config VXGE
+	tristate "Exar X3100 Series 10GbE PCIe Server Adapter"
+	depends on NET_VENDOR_EXAR && PCI && INET
+	---help---
+	  This driver supports Exar Corp's X3100 Series 10 GbE PCIe
+	  I/O Virtualized Server Adapter.
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/vxge.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called vxge.
+
+config VXGE_DEBUG_TRACE_ALL
+	bool "Enabling All Debug trace statments in driver"
+	default n
+	depends on VXGE
+	---help---
+	  Say Y here if you want to enabling all the debug trace statements in
+	  the vxge driver. By default only few debug trace statements are
+	  enabled.
diff --git a/drivers/net/ethernet/neterion/Makefile b/drivers/net/ethernet/neterion/Makefile
new file mode 100644
index 0000000..70c8058
--- /dev/null
+++ b/drivers/net/ethernet/neterion/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Exar network device drivers.
+#
+
+obj-$(CONFIG_S2IO) += s2io.o
+obj-$(CONFIG_VXGE) += vxge/
diff --git a/drivers/net/s2io-regs.h b/drivers/net/ethernet/neterion/s2io-regs.h
similarity index 100%
rename from drivers/net/s2io-regs.h
rename to drivers/net/ethernet/neterion/s2io-regs.h
diff --git a/drivers/net/s2io.c b/drivers/net/ethernet/neterion/s2io.c
similarity index 100%
rename from drivers/net/s2io.c
rename to drivers/net/ethernet/neterion/s2io.c
diff --git a/drivers/net/s2io.h b/drivers/net/ethernet/neterion/s2io.h
similarity index 100%
rename from drivers/net/s2io.h
rename to drivers/net/ethernet/neterion/s2io.h
diff --git a/drivers/net/vxge/Makefile b/drivers/net/ethernet/neterion/vxge/Makefile
similarity index 100%
rename from drivers/net/vxge/Makefile
rename to drivers/net/ethernet/neterion/vxge/Makefile
diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/ethernet/neterion/vxge/vxge-config.c
similarity index 100%
rename from drivers/net/vxge/vxge-config.c
rename to drivers/net/ethernet/neterion/vxge/vxge-config.c
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/ethernet/neterion/vxge/vxge-config.h
similarity index 100%
rename from drivers/net/vxge/vxge-config.h
rename to drivers/net/ethernet/neterion/vxge/vxge-config.h
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
similarity index 100%
rename from drivers/net/vxge/vxge-ethtool.c
rename to drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
diff --git a/drivers/net/vxge/vxge-ethtool.h b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.h
similarity index 100%
rename from drivers/net/vxge/vxge-ethtool.h
rename to drivers/net/ethernet/neterion/vxge/vxge-ethtool.h
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
similarity index 100%
rename from drivers/net/vxge/vxge-main.c
rename to drivers/net/ethernet/neterion/vxge/vxge-main.c
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/ethernet/neterion/vxge/vxge-main.h
similarity index 100%
rename from drivers/net/vxge/vxge-main.h
rename to drivers/net/ethernet/neterion/vxge/vxge-main.h
diff --git a/drivers/net/vxge/vxge-reg.h b/drivers/net/ethernet/neterion/vxge/vxge-reg.h
similarity index 100%
rename from drivers/net/vxge/vxge-reg.h
rename to drivers/net/ethernet/neterion/vxge/vxge-reg.h
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/ethernet/neterion/vxge/vxge-traffic.c
similarity index 100%
rename from drivers/net/vxge/vxge-traffic.c
rename to drivers/net/ethernet/neterion/vxge/vxge-traffic.c
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/ethernet/neterion/vxge/vxge-traffic.h
similarity index 100%
rename from drivers/net/vxge/vxge-traffic.h
rename to drivers/net/ethernet/neterion/vxge/vxge-traffic.h
diff --git a/drivers/net/vxge/vxge-version.h b/drivers/net/ethernet/neterion/vxge/vxge-version.h
similarity index 100%
rename from drivers/net/vxge/vxge-version.h
rename to drivers/net/ethernet/neterion/vxge/vxge-version.h
-- 
1.7.5.4

