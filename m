From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 30/72] atl*: Move the Atheros drivers
Date: Sat, 25 Jun 2011 06:58:41 -0700
Message-ID: <1309010363-22750-31-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jie Yang <jie.yang@atheros.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072Ab1FYOAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:01 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Atheros drivers into drivers/net/ethernet/atheros/ and
make the necessary Kconfig and Makefile changes.

CC: Jay Cliburn <jcliburn@gmail.com>
CC: Chris Snook <chris.snook@gmail.com>
CC: Jie Yang <jie.yang@atheros.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |   45 --------------
 drivers/net/Makefile                               |    4 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/atheros/Kconfig               |   61 ++++++++++++++++++++
 drivers/net/ethernet/atheros/Makefile              |    8 +++
 drivers/net/{ => ethernet/atheros}/atl1c/Makefile  |    0
 drivers/net/{ => ethernet/atheros}/atl1c/atl1c.h   |    0
 .../{ => ethernet/atheros}/atl1c/atl1c_ethtool.c   |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_hw.c    |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_hw.h    |    0
 .../net/{ => ethernet/atheros}/atl1c/atl1c_main.c  |    0
 drivers/net/{ => ethernet/atheros}/atl1e/Makefile  |    0
 drivers/net/{ => ethernet/atheros}/atl1e/atl1e.h   |    0
 .../{ => ethernet/atheros}/atl1e/atl1e_ethtool.c   |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_hw.c    |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_hw.h    |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_main.c  |    0
 .../net/{ => ethernet/atheros}/atl1e/atl1e_param.c |    0
 drivers/net/{ => ethernet/atheros}/atlx/Makefile   |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl1.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl1.h     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl2.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atl2.h     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atlx.c     |    0
 drivers/net/{ => ethernet/atheros}/atlx/atlx.h     |    0
 27 files changed, 72 insertions(+), 50 deletions(-)
 create mode 100644 drivers/net/ethernet/atheros/Kconfig
 create mode 100644 drivers/net/ethernet/atheros/Makefile
 rename drivers/net/{ => ethernet/atheros}/atl1c/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_ethtool.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_hw.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_hw.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1c/atl1c_main.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_ethtool.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_hw.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_hw.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_main.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atl1e/atl1e_param.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/Makefile (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl1.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl1.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl2.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atl2.h (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atlx.c (100%)
 rename drivers/net/{ => ethernet/atheros}/atlx/atlx.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index a0ccbea..f72a8bd 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1263,7 +1263,7 @@ L:	netdev@vger.kernel.org
 W:	http://sourceforge.net/projects/atl1
 W:	http://atl1.sourceforge.net
 S:	Maintained
-F:	drivers/net/atlx/
+F:	drivers/net/ethernet/atheros/
 
 ATM
 M:	Chas Williams <chas@cmf.nrl.navy.mil>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3961949..71efbe4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -897,17 +897,6 @@ config FEC_MPC52xx_MDIO
 	  If not sure, enable.
 	  If compiled as module, it will be called fec_mpc52xx_phy.
 
-config ATL2
-	tristate "Atheros L2 Fast Ethernet support"
-	depends on PCI
-	select CRC32
-	select MII
-	help
-	  This driver supports the Atheros L2 fast ethernet adapter.
-
-	  To compile this driver as a module, choose M here.  The module
-	  will be called atl2.
-
 config XILINX_EMACLITE
 	tristate "Xilinx 10/100 Ethernet Lite support"
 	depends on PPC32 || MICROBLAZE
@@ -1161,40 +1150,6 @@ config XILINX_LL_TEMAC
 	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
 	  core used in Xilinx Spartan and Virtex FPGAs
 
-config ATL1
-	tristate "Atheros/Attansic L1 Gigabit Ethernet support"
-	depends on PCI
-	select CRC32
-	select MII
-	help
-	  This driver supports the Atheros/Attansic L1 gigabit ethernet
-	  adapter.
-
-	  To compile this driver as a module, choose M here.  The module
-	  will be called atl1.
-
-config ATL1E
-	tristate "Atheros L1E Gigabit Ethernet support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
-	select CRC32
-	select MII
-	help
-	  This driver supports the Atheros L1E gigabit ethernet adapter.
-
-	  To compile this driver as a module, choose M here.  The module
-	  will be called atl1e.
-
-config ATL1C
-	tristate "Atheros L1C Gigabit Ethernet support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
-	select CRC32
-	select MII
-	help
-	  This driver supports the Atheros L1C gigabit ethernet adapter.
-
-	  To compile this driver as a module, choose M here.  The module
-	  will be called atl1c.
-
 config JME
 	tristate "JMicron(R) PCI-Express Gigabit Ethernet support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8cdf289..1ac4164 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -9,10 +9,6 @@ obj-$(CONFIG_PHYLIB) += phy/
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
-obj-$(CONFIG_ATL1) += atlx/
-obj-$(CONFIG_ATL2) += atlx/
-obj-$(CONFIG_ATL1E) += atl1e/
-obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_JME) += jme.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index b665c32..6fb1625 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -15,6 +15,7 @@ source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/arm/Kconfig"
+source "drivers/net/ethernet/atheros/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index e3c7243..1123a3d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -7,6 +7,7 @@ obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_ARM) += arm/
+obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
new file mode 100644
index 0000000..94b436d
--- /dev/null
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -0,0 +1,61 @@
+#
+# Atheros device configuration
+#
+
+config NET_VENDOR_ATHEROS
+	bool "Atheros devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Atheros devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+config ATL2
+	tristate "Atheros L2 Fast Ethernet support"
+	depends on NET_VENDOR_ATHEROS && PCI
+	select CRC32
+	select MII
+	---help---
+	  This driver supports the Atheros L2 fast ethernet adapter.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called atl2.
+
+config ATL1
+	tristate "Atheros/Attansic L1 Gigabit Ethernet support"
+	depends on NET_VENDOR_ATHEROS && PCI
+	select CRC32
+	select MII
+	---help---
+	  This driver supports the Atheros/Attansic L1 gigabit ethernet
+	  adapter.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called atl1.
+
+config ATL1E
+	tristate "Atheros L1E Gigabit Ethernet support (EXPERIMENTAL)"
+	depends on NET_VENDOR_ATHEROS && PCI && EXPERIMENTAL
+	select CRC32
+	select MII
+	---help---
+	  This driver supports the Atheros L1E gigabit ethernet adapter.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called atl1e.
+
+config ATL1C
+	tristate "Atheros L1C Gigabit Ethernet support (EXPERIMENTAL)"
+	depends on NET_VENDOR_ATHEROS && PCI && EXPERIMENTAL
+	select CRC32
+	select MII
+	---help---
+	  This driver supports the Atheros L1C gigabit ethernet adapter.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called atl1c.
diff --git a/drivers/net/ethernet/atheros/Makefile b/drivers/net/ethernet/atheros/Makefile
new file mode 100644
index 0000000..e7e76fb
--- /dev/null
+++ b/drivers/net/ethernet/atheros/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the Atheros network device drivers.
+#
+
+obj-$(CONFIG_ATL1) += atlx/
+obj-$(CONFIG_ATL2) += atlx/
+obj-$(CONFIG_ATL1E) += atl1e/
+obj-$(CONFIG_ATL1C) += atl1c/
diff --git a/drivers/net/atl1c/Makefile b/drivers/net/ethernet/atheros/atl1c/Makefile
similarity index 100%
rename from drivers/net/atl1c/Makefile
rename to drivers/net/ethernet/atheros/atl1c/Makefile
diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
similarity index 100%
rename from drivers/net/atl1c/atl1c.h
rename to drivers/net/ethernet/atheros/atl1c/atl1c.h
diff --git a/drivers/net/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
similarity index 100%
rename from drivers/net/atl1c/atl1c_ethtool.c
rename to drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
diff --git a/drivers/net/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
similarity index 100%
rename from drivers/net/atl1c/atl1c_hw.c
rename to drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
diff --git a/drivers/net/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
similarity index 100%
rename from drivers/net/atl1c/atl1c_hw.h
rename to drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
similarity index 100%
rename from drivers/net/atl1c/atl1c_main.c
rename to drivers/net/ethernet/atheros/atl1c/atl1c_main.c
diff --git a/drivers/net/atl1e/Makefile b/drivers/net/ethernet/atheros/atl1e/Makefile
similarity index 100%
rename from drivers/net/atl1e/Makefile
rename to drivers/net/ethernet/atheros/atl1e/Makefile
diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/ethernet/atheros/atl1e/atl1e.h
similarity index 100%
rename from drivers/net/atl1e/atl1e.h
rename to drivers/net/ethernet/atheros/atl1e/atl1e.h
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
similarity index 100%
rename from drivers/net/atl1e/atl1e_ethtool.c
rename to drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
diff --git a/drivers/net/atl1e/atl1e_hw.c b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
similarity index 100%
rename from drivers/net/atl1e/atl1e_hw.c
rename to drivers/net/ethernet/atheros/atl1e/atl1e_hw.c
diff --git a/drivers/net/atl1e/atl1e_hw.h b/drivers/net/ethernet/atheros/atl1e/atl1e_hw.h
similarity index 100%
rename from drivers/net/atl1e/atl1e_hw.h
rename to drivers/net/ethernet/atheros/atl1e/atl1e_hw.h
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
similarity index 100%
rename from drivers/net/atl1e/atl1e_main.c
rename to drivers/net/ethernet/atheros/atl1e/atl1e_main.c
diff --git a/drivers/net/atl1e/atl1e_param.c b/drivers/net/ethernet/atheros/atl1e/atl1e_param.c
similarity index 100%
rename from drivers/net/atl1e/atl1e_param.c
rename to drivers/net/ethernet/atheros/atl1e/atl1e_param.c
diff --git a/drivers/net/atlx/Makefile b/drivers/net/ethernet/atheros/atlx/Makefile
similarity index 100%
rename from drivers/net/atlx/Makefile
rename to drivers/net/ethernet/atheros/atlx/Makefile
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
similarity index 100%
rename from drivers/net/atlx/atl1.c
rename to drivers/net/ethernet/atheros/atlx/atl1.c
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/ethernet/atheros/atlx/atl1.h
similarity index 100%
rename from drivers/net/atlx/atl1.h
rename to drivers/net/ethernet/atheros/atlx/atl1.h
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
similarity index 100%
rename from drivers/net/atlx/atl2.c
rename to drivers/net/ethernet/atheros/atlx/atl2.c
diff --git a/drivers/net/atlx/atl2.h b/drivers/net/ethernet/atheros/atlx/atl2.h
similarity index 100%
rename from drivers/net/atlx/atl2.h
rename to drivers/net/ethernet/atheros/atlx/atl2.h
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/ethernet/atheros/atlx/atlx.c
similarity index 100%
rename from drivers/net/atlx/atlx.c
rename to drivers/net/ethernet/atheros/atlx/atlx.c
diff --git a/drivers/net/atlx/atlx.h b/drivers/net/ethernet/atheros/atlx/atlx.h
similarity index 100%
rename from drivers/net/atlx/atlx.h
rename to drivers/net/ethernet/atheros/atlx/atlx.h
-- 
1.7.5.4

