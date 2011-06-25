From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 18/72] ehea/ibm*: Move the IBM drivers
Date: Sat, 25 Jun 2011 06:58:29 -0700
Message-ID: <1309010363-22750-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>,
	Alfred Arnold <alfred.arnold@lancom.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61256 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124Ab1FYOAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:04 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the IBM drivers into drivers/net/ethernet/ibm/ and make the
necessary Kconfig and Makefile changes.

CC: Christoph Raisch <raisch@de.ibm.com>
CC: Alfred Arnold <alfred.arnold@lancom.de>
CC: Santiago Leon <santil@linux.vnet.ibm.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    4 +-
 drivers/net/Kconfig                                |   37 --------------
 drivers/net/Makefile                               |    4 --
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/ibm/Kconfig                   |   53 ++++++++++++++++++++
 drivers/net/ethernet/ibm/Makefile                  |    8 +++
 drivers/net/{ => ethernet/ibm}/ehea/Makefile       |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea.h         |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h      |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c     |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h     |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/Kconfig |    2 +-
 .../net/{ => ethernet/ibm}/ibm_newemac/Makefile    |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/core.c  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/core.h  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.c |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.h |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/emac.h  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.c   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.h   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.c   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.h   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.c |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.h |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.c   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.h   |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.c  |    0
 drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.h  |    0
 drivers/net/{ => ethernet/ibm}/ibmlana.c           |    0
 drivers/net/{ => ethernet/ibm}/ibmlana.h           |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.c           |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.h           |    0
 37 files changed, 66 insertions(+), 44 deletions(-)
 create mode 100644 drivers/net/ethernet/ibm/Kconfig
 create mode 100644 drivers/net/ethernet/ibm/Makefile
 rename drivers/net/{ => ethernet/ibm}/ehea/Makefile (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/Kconfig (97%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/Makefile (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/core.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/core.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/emac.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmlana.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmlana.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 816c665..0176793 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2432,7 +2432,7 @@ EHEA (IBM pSeries eHEA 10Gb ethernet adapter) DRIVER
 M:	Breno Leitao <leitao@linux.vnet.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ehea/
+F:	drivers/net/ethernet/ibm/ehea/
 
 EMBEDDED LINUX
 M:	Paul Gortmaker <paul.gortmaker@windriver.com>
@@ -3131,7 +3131,7 @@ IBM Power Virtual Ethernet Device Driver
 M:	Santiago Leon <santil@linux.vnet.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/ibmveth.*
+F:	drivers/net/ethernet/ibm/ibmveth.*
 
 IBM ServeRAID RAID DRIVER
 P:	Jack Hammer
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6294de0..7f28373 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -770,33 +770,6 @@ config SEEQ8005
 	  To compile this driver as a module, choose M here. The module
 	  will be called seeq8005.
 
-config IBMLANA
-	tristate "IBM LAN Adapter/A support"
-	depends on MCA
-	---help---
-	  This is a Micro Channel Ethernet adapter.  You need to set
-	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
-	  driver and as a module.
-
-	  To compile this driver as a module, choose M here. The only
-	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
-	  will both support 16K and 32K memory windows, however a 32K window
-	  gives a better security against packet losses.  Usage of multiple
-	  boards with this driver should be possible, but has not been tested
-	  up to now due to lack of hardware.
-
-config IBMVETH
-	tristate "IBM LAN Virtual Ethernet support"
-	depends on PPC_PSERIES
-	---help---
-	  This driver supports virtual ethernet adapters on newer IBM iSeries
-	  and pSeries systems.
-
-	  To compile this driver as a module, choose M here. The module will
-	  be called ibmveth.
-
-source "drivers/net/ibm_newemac/Kconfig"
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
@@ -1652,16 +1625,6 @@ if NETDEV_10000
 config MDIO
 	tristate
 
-config EHEA
-	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET && SPARSEMEM
-	select INET_LRO
-	---help---
-	  This driver supports the IBM pSeries eHEA ethernet adapter.
-
-	  To compile the driver as a module, choose M here. The module
-	  will be called ehea.
-
 config ENIC
 	tristate "Cisco VIC Ethernet NIC Support"
 	depends on PCI && INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 5241d6e..f0efba2 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -10,9 +10,7 @@ obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
 obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
 obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 
-obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
 obj-$(CONFIG_IP1000) += ipg.o
-obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_ATL1) += atlx/
@@ -127,7 +125,6 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_IBMLANA) += ibmlana.o
 obj-$(CONFIG_EEXPRESS) += eexpress.o
 obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
 obj-$(CONFIG_8139CP) += 8139cp.o
@@ -165,7 +162,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_R8169) += r8169.o
-obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_SMC911X) += smc911x.o
 obj-$(CONFIG_SMSC911X) += smsc911x.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index a23ea19..0fd163e 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -19,6 +19,7 @@ source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
+source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 690421d..43c912f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
+obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kconfig
new file mode 100644
index 0000000..ac755a3
--- /dev/null
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -0,0 +1,53 @@
+#
+# IBM device configuration.
+#
+
+config NET_VENDOR_IBM
+	bool "IBM devices"
+	depends on MCA || PPC_PSERIES || PPC_DCR || IBMEBUS
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about IBM devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config IBMLANA
+	tristate "IBM LAN Adapter/A support"
+	depends on NET_VENDOR_IBM && MCA
+	---help---
+	  This is a Micro Channel Ethernet adapter.  You need to set
+	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
+	  driver and as a module.
+
+	  To compile this driver as a module, choose M here. The only
+	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
+	  will both support 16K and 32K memory windows, however a 32K window
+	  gives a better security against packet losses.  Usage of multiple
+	  boards with this driver should be possible, but has not been tested
+	  up to now due to lack of hardware.
+
+config IBMVETH
+	tristate "IBM LAN Virtual Ethernet support"
+	depends on NET_VENDOR_IBM && PPC_PSERIES
+	---help---
+	  This driver supports virtual ethernet adapters on newer IBM iSeries
+	  and pSeries systems.
+
+	  To compile this driver as a module, choose M here. The module will
+	  be called ibmveth.
+
+source "drivers/net/ethernet/ibm/ibm_newemac/Kconfig"
+
+config EHEA
+	tristate "eHEA Ethernet support"
+	depends on NET_VENDOR_IBM && IBMEBUS && INET && SPARSEMEM
+	select INET_LRO
+	---help---
+	  This driver supports the IBM pSeries eHEA ethernet adapter.
+
+	  To compile the driver as a module, choose M here. The module
+	  will be called ehea.
diff --git a/drivers/net/ethernet/ibm/Makefile b/drivers/net/ethernet/ibm/Makefile
new file mode 100644
index 0000000..a63a8c3
--- /dev/null
+++ b/drivers/net/ethernet/ibm/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for th IBM network device drivers.
+#
+
+obj-$(CONFIG_IBMLANA) += ibmlana.o
+obj-$(CONFIG_IBMVETH) += ibmveth.o
+obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
+obj-$(CONFIG_EHEA) += ehea/
diff --git a/drivers/net/ehea/Makefile b/drivers/net/ethernet/ibm/ehea/Makefile
similarity index 100%
rename from drivers/net/ehea/Makefile
rename to drivers/net/ethernet/ibm/ehea/Makefile
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
similarity index 100%
rename from drivers/net/ehea/ehea.h
rename to drivers/net/ethernet/ibm/ehea/ehea.h
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
similarity index 100%
rename from drivers/net/ehea/ehea_ethtool.c
rename to drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
diff --git a/drivers/net/ehea/ehea_hw.h b/drivers/net/ethernet/ibm/ehea/ehea_hw.h
similarity index 100%
rename from drivers/net/ehea/ehea_hw.h
rename to drivers/net/ethernet/ibm/ehea/ehea_hw.h
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
similarity index 100%
rename from drivers/net/ehea/ehea_main.c
rename to drivers/net/ethernet/ibm/ehea/ehea_main.c
diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ethernet/ibm/ehea/ehea_phyp.c
similarity index 100%
rename from drivers/net/ehea/ehea_phyp.c
rename to drivers/net/ethernet/ibm/ehea/ehea_phyp.c
diff --git a/drivers/net/ehea/ehea_phyp.h b/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
similarity index 100%
rename from drivers/net/ehea/ehea_phyp.h
rename to drivers/net/ethernet/ibm/ehea/ehea_phyp.h
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
similarity index 100%
rename from drivers/net/ehea/ehea_qmr.c
rename to drivers/net/ethernet/ibm/ehea/ehea_qmr.c
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
similarity index 100%
rename from drivers/net/ehea/ehea_qmr.h
rename to drivers/net/ethernet/ibm/ehea/ehea_qmr.h
diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ethernet/ibm/ibm_newemac/Kconfig
similarity index 97%
rename from drivers/net/ibm_newemac/Kconfig
rename to drivers/net/ethernet/ibm/ibm_newemac/Kconfig
index 78a1628..7e370b0 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ethernet/ibm/ibm_newemac/Kconfig
@@ -1,6 +1,6 @@
 config IBM_NEW_EMAC
 	tristate "IBM EMAC Ethernet support"
-	depends on PPC_DCR
+	depends on NET_VENDOR_IBM && PPC_DCR
 	select CRC32
 	help
 	  This driver supports the IBM EMAC family of Ethernet controllers
diff --git a/drivers/net/ibm_newemac/Makefile b/drivers/net/ethernet/ibm/ibm_newemac/Makefile
similarity index 100%
rename from drivers/net/ibm_newemac/Makefile
rename to drivers/net/ethernet/ibm/ibm_newemac/Makefile
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ethernet/ibm/ibm_newemac/core.c
similarity index 100%
rename from drivers/net/ibm_newemac/core.c
rename to drivers/net/ethernet/ibm/ibm_newemac/core.c
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ethernet/ibm/ibm_newemac/core.h
similarity index 100%
rename from drivers/net/ibm_newemac/core.h
rename to drivers/net/ethernet/ibm/ibm_newemac/core.h
diff --git a/drivers/net/ibm_newemac/debug.c b/drivers/net/ethernet/ibm/ibm_newemac/debug.c
similarity index 100%
rename from drivers/net/ibm_newemac/debug.c
rename to drivers/net/ethernet/ibm/ibm_newemac/debug.c
diff --git a/drivers/net/ibm_newemac/debug.h b/drivers/net/ethernet/ibm/ibm_newemac/debug.h
similarity index 100%
rename from drivers/net/ibm_newemac/debug.h
rename to drivers/net/ethernet/ibm/ibm_newemac/debug.h
diff --git a/drivers/net/ibm_newemac/emac.h b/drivers/net/ethernet/ibm/ibm_newemac/emac.h
similarity index 100%
rename from drivers/net/ibm_newemac/emac.h
rename to drivers/net/ethernet/ibm/ibm_newemac/emac.h
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ethernet/ibm/ibm_newemac/mal.c
similarity index 100%
rename from drivers/net/ibm_newemac/mal.c
rename to drivers/net/ethernet/ibm/ibm_newemac/mal.c
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ethernet/ibm/ibm_newemac/mal.h
similarity index 100%
rename from drivers/net/ibm_newemac/mal.h
rename to drivers/net/ethernet/ibm/ibm_newemac/mal.h
diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ethernet/ibm/ibm_newemac/phy.c
similarity index 100%
rename from drivers/net/ibm_newemac/phy.c
rename to drivers/net/ethernet/ibm/ibm_newemac/phy.c
diff --git a/drivers/net/ibm_newemac/phy.h b/drivers/net/ethernet/ibm/ibm_newemac/phy.h
similarity index 100%
rename from drivers/net/ibm_newemac/phy.h
rename to drivers/net/ethernet/ibm/ibm_newemac/phy.h
diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ethernet/ibm/ibm_newemac/rgmii.c
similarity index 100%
rename from drivers/net/ibm_newemac/rgmii.c
rename to drivers/net/ethernet/ibm/ibm_newemac/rgmii.c
diff --git a/drivers/net/ibm_newemac/rgmii.h b/drivers/net/ethernet/ibm/ibm_newemac/rgmii.h
similarity index 100%
rename from drivers/net/ibm_newemac/rgmii.h
rename to drivers/net/ethernet/ibm/ibm_newemac/rgmii.h
diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ethernet/ibm/ibm_newemac/tah.c
similarity index 100%
rename from drivers/net/ibm_newemac/tah.c
rename to drivers/net/ethernet/ibm/ibm_newemac/tah.c
diff --git a/drivers/net/ibm_newemac/tah.h b/drivers/net/ethernet/ibm/ibm_newemac/tah.h
similarity index 100%
rename from drivers/net/ibm_newemac/tah.h
rename to drivers/net/ethernet/ibm/ibm_newemac/tah.h
diff --git a/drivers/net/ibm_newemac/zmii.c b/drivers/net/ethernet/ibm/ibm_newemac/zmii.c
similarity index 100%
rename from drivers/net/ibm_newemac/zmii.c
rename to drivers/net/ethernet/ibm/ibm_newemac/zmii.c
diff --git a/drivers/net/ibm_newemac/zmii.h b/drivers/net/ethernet/ibm/ibm_newemac/zmii.h
similarity index 100%
rename from drivers/net/ibm_newemac/zmii.h
rename to drivers/net/ethernet/ibm/ibm_newemac/zmii.h
diff --git a/drivers/net/ibmlana.c b/drivers/net/ethernet/ibm/ibmlana.c
similarity index 100%
rename from drivers/net/ibmlana.c
rename to drivers/net/ethernet/ibm/ibmlana.c
diff --git a/drivers/net/ibmlana.h b/drivers/net/ethernet/ibm/ibmlana.h
similarity index 100%
rename from drivers/net/ibmlana.h
rename to drivers/net/ethernet/ibm/ibmlana.h
diff --git a/drivers/net/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
similarity index 100%
rename from drivers/net/ibmveth.c
rename to drivers/net/ethernet/ibm/ibmveth.c
diff --git a/drivers/net/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
similarity index 100%
rename from drivers/net/ibmveth.h
rename to drivers/net/ethernet/ibm/ibmveth.h
-- 
1.7.5.4

