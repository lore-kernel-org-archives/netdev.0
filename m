From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next] drivers/net
 Documentation/networking: Create directory intel_wired_lan
Date: Sun, 10 Oct 2010 13:42:32 -0700
Message-ID: <1286743352.11039.165.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Don, e1000-devel <e1000-devel@lists.sourceforge.net>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Perhaps it's better to move drivers from the very populated
drivers/net directory into vendor specific directories similar
to the Atheros approach used for drivers/net/wireless/ath/

Move intel drivers and Documentation to separate directories
Create drivers/net/intel_wired_lan/Kconfig.<speed> and Makefile
Modify drivers/net/Kconfig and Makefile
Update MAINTAINERS

Signed-off-by: Joe Perches <joe@perches.com>
---
 .../networking/{ => intel_wired_lan}/e100.txt      |    0
 .../networking/{ => intel_wired_lan}/e1000.txt     |    0
 .../networking/{ => intel_wired_lan}/igb.txt       |    0
 .../networking/{ => intel_wired_lan}/igbvf.txt     |    0
 .../networking/{ => intel_wired_lan}/ixgb.txt      |    0
 .../networking/{ => intel_wired_lan}/ixgbe.txt     |    0
 .../networking/{ => intel_wired_lan}/ixgbevf.txt   |    0
 MAINTAINERS                                        |   18 +--
 drivers/net/Kconfig                                |  214 +-------------------
 drivers/net/Makefile                               |    8 -
 drivers/net/intel_wired_lan/Kconfig.100            |   25 +++
 drivers/net/intel_wired_lan/Kconfig.1000           |  102 ++++++++++
 drivers/net/intel_wired_lan/Kconfig.10000          |   81 ++++++++
 drivers/net/intel_wired_lan/Makefile               |    9 +
 drivers/net/{ => intel_wired_lan}/e100.c           |    0
 drivers/net/{ => intel_wired_lan}/e1000/Makefile   |    0
 drivers/net/{ => intel_wired_lan}/e1000/e1000.h    |    0
 .../{ => intel_wired_lan}/e1000/e1000_ethtool.c    |    0
 drivers/net/{ => intel_wired_lan}/e1000/e1000_hw.c |    0
 drivers/net/{ => intel_wired_lan}/e1000/e1000_hw.h |    0
 .../net/{ => intel_wired_lan}/e1000/e1000_main.c   |    0
 .../net/{ => intel_wired_lan}/e1000/e1000_osdep.h  |    0
 .../net/{ => intel_wired_lan}/e1000/e1000_param.c  |    0
 drivers/net/{ => intel_wired_lan}/e1000e/82571.c   |    0
 drivers/net/{ => intel_wired_lan}/e1000e/Makefile  |    0
 drivers/net/{ => intel_wired_lan}/e1000e/defines.h |    0
 drivers/net/{ => intel_wired_lan}/e1000e/e1000.h   |    0
 drivers/net/{ => intel_wired_lan}/e1000e/es2lan.c  |    0
 drivers/net/{ => intel_wired_lan}/e1000e/ethtool.c |    0
 drivers/net/{ => intel_wired_lan}/e1000e/hw.h      |    0
 drivers/net/{ => intel_wired_lan}/e1000e/ich8lan.c |    0
 drivers/net/{ => intel_wired_lan}/e1000e/lib.c     |    0
 drivers/net/{ => intel_wired_lan}/e1000e/netdev.c  |    0
 drivers/net/{ => intel_wired_lan}/e1000e/param.c   |    0
 drivers/net/{ => intel_wired_lan}/e1000e/phy.c     |    0
 drivers/net/{ => intel_wired_lan}/igb/Makefile     |    0
 .../net/{ => intel_wired_lan}/igb/e1000_82575.c    |    0
 .../net/{ => intel_wired_lan}/igb/e1000_82575.h    |    0
 .../net/{ => intel_wired_lan}/igb/e1000_defines.h  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_hw.h   |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_mac.c  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_mac.h  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_mbx.c  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_mbx.h  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_nvm.c  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_nvm.h  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_phy.c  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_phy.h  |    0
 drivers/net/{ => intel_wired_lan}/igb/e1000_regs.h |    0
 drivers/net/{ => intel_wired_lan}/igb/igb.h        |    0
 .../net/{ => intel_wired_lan}/igb/igb_ethtool.c    |    0
 drivers/net/{ => intel_wired_lan}/igb/igb_main.c   |    0
 drivers/net/{ => intel_wired_lan}/igbvf/Makefile   |    0
 drivers/net/{ => intel_wired_lan}/igbvf/defines.h  |    0
 drivers/net/{ => intel_wired_lan}/igbvf/ethtool.c  |    0
 drivers/net/{ => intel_wired_lan}/igbvf/igbvf.h    |    0
 drivers/net/{ => intel_wired_lan}/igbvf/mbx.c      |    0
 drivers/net/{ => intel_wired_lan}/igbvf/mbx.h      |    0
 drivers/net/{ => intel_wired_lan}/igbvf/netdev.c   |    0
 drivers/net/{ => intel_wired_lan}/igbvf/regs.h     |    0
 drivers/net/{ => intel_wired_lan}/igbvf/vf.c       |    0
 drivers/net/{ => intel_wired_lan}/igbvf/vf.h       |    0
 drivers/net/{ => intel_wired_lan}/ixgb/Makefile    |    0
 drivers/net/{ => intel_wired_lan}/ixgb/ixgb.h      |    0
 drivers/net/{ => intel_wired_lan}/ixgb/ixgb_ee.c   |    0
 drivers/net/{ => intel_wired_lan}/ixgb/ixgb_ee.h   |    0
 .../net/{ => intel_wired_lan}/ixgb/ixgb_ethtool.c  |    0
 drivers/net/{ => intel_wired_lan}/ixgb/ixgb_hw.c   |    0
 drivers/net/{ => intel_wired_lan}/ixgb/ixgb_hw.h   |    0
 drivers/net/{ => intel_wired_lan}/ixgb/ixgb_ids.h  |    0
 drivers/net/{ => intel_wired_lan}/ixgb/ixgb_main.c |    0
 .../net/{ => intel_wired_lan}/ixgb/ixgb_osdep.h    |    0
 .../net/{ => intel_wired_lan}/ixgb/ixgb_param.c    |    0
 drivers/net/{ => intel_wired_lan}/ixgbe/Makefile   |    0
 drivers/net/{ => intel_wired_lan}/ixgbe/ixgbe.h    |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_82598.c  |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_82599.c  |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_common.c |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_common.h |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_dcb.c    |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_dcb.h    |    0
 .../{ => intel_wired_lan}/ixgbe/ixgbe_dcb_82598.c  |    0
 .../{ => intel_wired_lan}/ixgbe/ixgbe_dcb_82598.h  |    0
 .../{ => intel_wired_lan}/ixgbe/ixgbe_dcb_82599.c  |    0
 .../{ => intel_wired_lan}/ixgbe/ixgbe_dcb_82599.h  |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_dcb_nl.c |    0
 .../{ => intel_wired_lan}/ixgbe/ixgbe_ethtool.c    |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_fcoe.c   |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_fcoe.h   |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_main.c   |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_mbx.c    |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_mbx.h    |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_phy.c    |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_phy.h    |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_sriov.c  |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_sriov.h  |    0
 .../net/{ => intel_wired_lan}/ixgbe/ixgbe_type.h   |    0
 drivers/net/{ => intel_wired_lan}/ixgbevf/Makefile |    0
 .../net/{ => intel_wired_lan}/ixgbevf/defines.h    |    0
 .../net/{ => intel_wired_lan}/ixgbevf/ethtool.c    |    0
 .../net/{ => intel_wired_lan}/ixgbevf/ixgbevf.h    |    0
 .../{ => intel_wired_lan}/ixgbevf/ixgbevf_main.c   |    0
 drivers/net/{ => intel_wired_lan}/ixgbevf/mbx.c    |    0
 drivers/net/{ => intel_wired_lan}/ixgbevf/mbx.h    |    0
 drivers/net/{ => intel_wired_lan}/ixgbevf/regs.h   |    0
 drivers/net/{ => intel_wired_lan}/ixgbevf/vf.c     |    0
 drivers/net/{ => intel_wired_lan}/ixgbevf/vf.h     |    0
 107 files changed, 224 insertions(+), 233 deletions(-)

diff --git a/Documentation/networking/e100.txt b/Documentation/networking/intel_wired_lan/e100.txt
similarity index 100%
rename from Documentation/networking/e100.txt
rename to Documentation/networking/intel_wired_lan/e100.txt
diff --git a/Documentation/networking/e1000.txt b/Documentation/networking/intel_wired_lan/e1000.txt
similarity index 100%
rename from Documentation/networking/e1000.txt
rename to Documentation/networking/intel_wired_lan/e1000.txt
diff --git a/Documentation/networking/igb.txt b/Documentation/networking/intel_wired_lan/igb.txt
similarity index 100%
rename from Documentation/networking/igb.txt
rename to Documentation/networking/intel_wired_lan/igb.txt
diff --git a/Documentation/networking/igbvf.txt b/Documentation/networking/intel_wired_lan/igbvf.txt
similarity index 100%
rename from Documentation/networking/igbvf.txt
rename to Documentation/networking/intel_wired_lan/igbvf.txt
diff --git a/Documentation/networking/ixgb.txt b/Documentation/networking/intel_wired_lan/ixgb.txt
similarity index 100%
rename from Documentation/networking/ixgb.txt
rename to Documentation/networking/intel_wired_lan/ixgb.txt
diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/intel_wired_lan/ixgbe.txt
similarity index 100%
rename from Documentation/networking/ixgbe.txt
rename to Documentation/networking/intel_wired_lan/ixgbe.txt
diff --git a/Documentation/networking/ixgbevf.txt b/Documentation/networking/intel_wired_lan/ixgbevf.txt
similarity index 100%
rename from Documentation/networking/ixgbevf.txt
rename to Documentation/networking/intel_wired_lan/ixgbevf.txt
diff --git a/MAINTAINERS b/MAINTAINERS
index ba8603c..b086404 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3096,22 +3096,8 @@ M:	John Ronciak <john.ronciak@intel.com>
 L:	e1000-devel@lists.sourceforge.net
 W:	http://e1000.sourceforge.net/
 S:	Supported
-F:	Documentation/networking/e100.txt
-F:	Documentation/networking/e1000.txt
-F:	Documentation/networking/e1000e.txt
-F:	Documentation/networking/igb.txt
-F:	Documentation/networking/igbvf.txt
-F:	Documentation/networking/ixgb.txt
-F:	Documentation/networking/ixgbe.txt
-F:	Documentation/networking/ixgbevf.txt
-F:	drivers/net/e100.c
-F:	drivers/net/e1000/
-F:	drivers/net/e1000e/
-F:	drivers/net/igb/
-F:	drivers/net/igbvf/
-F:	drivers/net/ixgb/
-F:	drivers/net/ixgbe/
-F:	drivers/net/ixgbevf/
+F:	Documentation/networking/intel_wired_lan/
+F:	drivers/net/intel_wired_lan/
 
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
 L:	linux-wireless@vger.kernel.org
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 13d01f3..4d6448d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1495,32 +1495,6 @@ config TC35815
 	depends on NET_PCI && PCI && MIPS
 	select PHYLIB
 
-config E100
-	tristate "Intel(R) PRO/100+ support"
-	depends on NET_PCI && PCI
-	select MII
-	---help---
-	  This driver supports Intel(R) PRO/100 family of adapters.
-	  To verify that your adapter is supported, find the board ID number 
-	  on the adapter. Look for a label that has a barcode and a number 
-	  in the format 123456-001 (six digits hyphen three digits). 
-
-	  Use the above information and the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-          to identify the adapter.
-
-	  For the latest Intel PRO/100 network driver for Linux, see:
-
-	  <http://appsr.intel.com/scripts-df/support_intel.asp>
-
-	  More specific information on configuring the driver is in 
-	  <file:Documentation/networking/e100.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e100.
-
 config LNE390
 	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
 	depends on NET_PCI && EISA && EXPERIMENTAL
@@ -1995,6 +1969,8 @@ source "drivers/net/fs_enet/Kconfig"
 
 source "drivers/net/octeon/Kconfig"
 
+source "drivers/net/intel_wired_lan/Kconfig.100"
+
 endif # NET_ETHERNET
 
 #
@@ -2059,45 +2035,7 @@ config DL2K
 	  To compile this driver as a module, choose M here: the
 	  module will be called dl2k.
 
-config E1000
-	tristate "Intel(R) PRO/1000 Gigabit Ethernet support"
-	depends on PCI
-	---help---
-	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
-	  adapters.  For more information on how to identify your adapter, go 
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  More specific information on configuring the driver is in 
-	  <file:Documentation/networking/e1000.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e1000.
-
-config E1000E
-	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
-	depends on PCI && (!SPARC32 || BROKEN)
-	---help---
-	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
-	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
-	  use the regular e1000 driver For more information on how to
-	  identify your adapter, go to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called e1000e.
+source "drivers/net/intel_wired_lan/Kconfig.1000"
 
 config IP1000
 	tristate "IP1000 Gigabit Ethernet support"
@@ -2109,57 +2047,6 @@ config IP1000
 	  To compile this driver as a module, choose M here: the module
 	  will be called ipg.  This is recommended.
 
-config IGB
-       tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
-       depends on PCI
-       ---help---
-         This driver supports Intel(R) 82575/82576 gigabit ethernet family of
-         adapters.  For more information on how to identify your adapter, go
-         to the Adapter & Driver ID Guide at:
-
-         <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-         For general information and support, go to the Intel support
-         website at:
-
-         <http://support.intel.com>
-
-         More specific information on configuring the driver is in
-         <file:Documentation/networking/e1000.txt>.
-
-         To compile this driver as a module, choose M here. The module
-         will be called igb.
-
-config IGB_DCA
-	bool "Direct Cache Access (DCA) Support"
-	default y
-	depends on IGB && DCA && !(IGB=y && DCA=m)
-	---help---
-	  Say Y here if you want to use Direct Cache Access (DCA) in the
-	  driver.  DCA is a method for warming the CPU cache before data
-	  is used, with the intent of lessening the impact of cache misses.
-
-config IGBVF
-       tristate "Intel(R) 82576 Virtual Function Ethernet support"
-       depends on PCI
-       ---help---
-         This driver supports Intel(R) 82576 virtual functions.  For more
-         information on how to identify your adapter, go to the Adapter &
-         Driver ID Guide at:
-
-         <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-         For general information and support, go to the Intel support
-         website at:
-
-         <http://support.intel.com>
-
-         More specific information on configuring the driver is in
-         <file:Documentation/networking/e1000.txt>.
-
-         To compile this driver as a module, choose M here. The module
-         will be called igbvf.
-
 source "drivers/net/ixp2000/Kconfig"
 
 config MYRI_SBUS
@@ -2515,17 +2402,6 @@ config S6GMAC
 
 source "drivers/net/stmmac/Kconfig"
 
-config PCH_GBE
-	tristate "PCH Gigabit Ethernet"
-	depends on PCI
-	---help---
-	  This is a gigabit ethernet driver for Topcliff PCH.
-	  Topcliff PCH is the platform controller hub that is used in Intel's
-	  general embedded platform.
-	  Topcliff PCH has Gigabit Ethernet interface.
-	  Using this interface, it is able to access system devices connected
-	  to Gigabit Ethernet.
-	  This driver enables Gigabit Ethernet function.
 
 endif # NETDEV_1000
 
@@ -2659,94 +2535,14 @@ config EHEA
 	  To compile the driver as a module, choose M here. The module
 	  will be called ehea.
 
+source "drivers/net/intel_wired_lan/Kconfig.10000"
+
 config ENIC
 	tristate "Cisco VIC Ethernet NIC Support"
 	depends on PCI && INET
 	help
 	  This enables the support for the Cisco VIC Ethernet card.
 
-config IXGBE
-	tristate "Intel(R) 10GbE PCI Express adapters support"
-	depends on PCI && INET
-	select MDIO
-	---help---
-	  This driver supports Intel(R) 10GbE PCI Express family of
-	  adapters.  For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ixgbe.
-
-config IXGBE_DCA
-	bool "Direct Cache Access (DCA) Support"
-	default y
-	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
-	---help---
-	  Say Y here if you want to use Direct Cache Access (DCA) in the
-	  driver.  DCA is a method for warming the CPU cache before data
-	  is used, with the intent of lessening the impact of cache misses.
-
-config IXGBE_DCB
-	bool "Data Center Bridging (DCB) Support"
-	default n
-	depends on IXGBE && DCB
-	---help---
-	  Say Y here if you want to use Data Center Bridging (DCB) in the
-	  driver.
-
-	  If unsure, say N.
-
-config IXGBEVF
-       tristate "Intel(R) 82599 Virtual Function Ethernet support"
-       depends on PCI_MSI
-       ---help---
-         This driver supports Intel(R) 82599 virtual functions.  For more
-         information on how to identify your adapter, go to the Adapter &
-         Driver ID Guide at:
-
-         <http://support.intel.com/support/network/sb/CS-008441.htm>
-
-         For general information and support, go to the Intel support
-         website at:
-
-         <http://support.intel.com>
-
-         More specific information on configuring the driver is in
-         <file:Documentation/networking/ixgbevf.txt>.
-
-         To compile this driver as a module, choose M here. The module
-         will be called ixgbevf.  MSI-X interrupt support is required
-         for this driver to work correctly.
-
-config IXGB
-	tristate "Intel(R) PRO/10GbE support"
-	depends on PCI
-	---help---
-	  This driver supports Intel(R) PRO/10GbE family of adapters for
-	  PCI-X type cards. For PCI-E type cards, use the "ixgbe" driver
-	  instead. For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
-
-	  <http://support.intel.com>
-
-	  More specific information on configuring the driver is in 
-	  <file:Documentation/networking/ixgb.txt>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ixgb.
-
 config S2IO
 	tristate "S2IO 10Gbe XFrame NIC"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b8bf93d..e457b3c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -8,14 +8,7 @@ obj-$(CONFIG_PHYLIB) += phy/
 
 obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
 
-obj-$(CONFIG_E1000) += e1000/
-obj-$(CONFIG_E1000E) += e1000e/
 obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
-obj-$(CONFIG_IGB) += igb/
-obj-$(CONFIG_IGBVF) += igbvf/
-obj-$(CONFIG_IXGBE) += ixgbe/
-obj-$(CONFIG_IXGBEVF) += ixgbevf/
-obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CHELSIO_T1) += chelsio/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
@@ -68,7 +61,6 @@ obj-$(CONFIG_VORTEX) += 3c59x.o
 obj-$(CONFIG_TYPHOON) += typhoon.o
 obj-$(CONFIG_NE2K_PCI) += ne2k-pci.o 8390.o
 obj-$(CONFIG_PCNET32) += pcnet32.o
-obj-$(CONFIG_E100) += e100.o
 obj-$(CONFIG_TLAN) += tlan.o
 obj-$(CONFIG_EPIC100) += epic100.o
 obj-$(CONFIG_SMSC9420) += smsc9420.o
diff --git a/drivers/net/intel_wired_lan/Kconfig.100 b/drivers/net/intel_wired_lan/Kconfig.100
new file mode 100644
index 0000000..6651ae9
--- /dev/null
+++ b/drivers/net/intel_wired_lan/Kconfig.100
@@ -0,0 +1,25 @@
+config E100
+	tristate "Intel(R) PRO/100+ support"
+	depends on NET_PCI && PCI
+	select MII
+	---help---
+	  This driver supports Intel(R) PRO/100 family of adapters.
+	  To verify that your adapter is supported, find the board ID number
+	  on the adapter. Look for a label that has a barcode and a number
+	  in the format 123456-001 (six digits hyphen three digits).
+
+	  Use the above information and the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+          to identify the adapter.
+
+	  For the latest Intel PRO/100 network driver for Linux, see:
+
+	  <http://appsr.intel.com/scripts-df/support_intel.asp>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/intel_wired_lan/e100.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e100.
diff --git a/drivers/net/intel_wired_lan/Kconfig.1000 b/drivers/net/intel_wired_lan/Kconfig.1000
new file mode 100644
index 0000000..4a7e13a
--- /dev/null
+++ b/drivers/net/intel_wired_lan/Kconfig.1000
@@ -0,0 +1,102 @@
+config E1000
+	tristate "Intel(R) PRO/1000 Gigabit Ethernet support"
+	depends on PCI
+	---help---
+	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/intel_wired_lan/e1000.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e1000.
+
+config E1000E
+	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
+	depends on PCI && (!SPARC32 || BROKEN)
+	---help---
+	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
+	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
+	  use the regular e1000 driver For more information on how to
+	  identify your adapter, go to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called e1000e.
+
+config IGB
+       tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
+       depends on PCI
+       ---help---
+         This driver supports Intel(R) 82575/82576 gigabit ethernet family of
+         adapters.  For more information on how to identify your adapter, go
+         to the Adapter & Driver ID Guide at:
+
+         <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+         For general information and support, go to the Intel support
+         website at:
+
+         <http://support.intel.com>
+
+         More specific information on configuring the driver is in
+         <file:Documentation/networking/intel_wired_lan/e1000.txt>.
+
+         To compile this driver as a module, choose M here. The module
+         will be called igb.
+
+config IGB_DCA
+	bool "Direct Cache Access (DCA) Support"
+	default y
+	depends on IGB && DCA && !(IGB=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
+
+config IGBVF
+       tristate "Intel(R) 82576 Virtual Function Ethernet support"
+       depends on PCI
+       ---help---
+         This driver supports Intel(R) 82576 virtual functions.  For more
+         information on how to identify your adapter, go to the Adapter &
+         Driver ID Guide at:
+
+         <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+         For general information and support, go to the Intel support
+         website at:
+
+         <http://support.intel.com>
+
+         More specific information on configuring the driver is in
+         <file:Documentation/networking/intel_wired_lan/e1000.txt>.
+
+         To compile this driver as a module, choose M here. The module
+         will be called igbvf.
+
+config PCH_GBE
+	tristate "PCH Gigabit Ethernet"
+	depends on PCI
+	---help---
+	  This is a gigabit ethernet driver for Topcliff PCH.
+	  Topcliff PCH is the platform controller hub that is used in Intel's
+	  general embedded platform.
+	  Topcliff PCH has Gigabit Ethernet interface.
+	  Using this interface, it is able to access system devices connected
+	  to Gigabit Ethernet.
+	  This driver enables Gigabit Ethernet function.
diff --git a/drivers/net/intel_wired_lan/Kconfig.10000 b/drivers/net/intel_wired_lan/Kconfig.10000
new file mode 100644
index 0000000..ef35ebd
--- /dev/null
+++ b/drivers/net/intel_wired_lan/Kconfig.10000
@@ -0,0 +1,81 @@
+config IXGBE
+	tristate "Intel(R) 10GbE PCI Express adapters support"
+	depends on PCI && INET
+	select MDIO
+	---help---
+	  This driver supports Intel(R) 10GbE PCI Express family of
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ixgbe.
+
+config IXGBE_DCA
+	bool "Direct Cache Access (DCA) Support"
+	default y
+	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
+
+config IXGBE_DCB
+	bool "Data Center Bridging (DCB) Support"
+	default n
+	depends on IXGBE && DCB
+	---help---
+	  Say Y here if you want to use Data Center Bridging (DCB) in the
+	  driver.
+
+	  If unsure, say N.
+
+config IXGBEVF
+       tristate "Intel(R) 82599 Virtual Function Ethernet support"
+       depends on PCI_MSI
+       ---help---
+         This driver supports Intel(R) 82599 virtual functions.  For more
+         information on how to identify your adapter, go to the Adapter &
+         Driver ID Guide at:
+
+         <http://support.intel.com/support/network/sb/CS-008441.htm>
+
+         For general information and support, go to the Intel support
+         website at:
+
+         <http://support.intel.com>
+
+         More specific information on configuring the driver is in
+         <file:Documentation/networking/intel_wired_lan/ixgbevf.txt>.
+
+         To compile this driver as a module, choose M here. The module
+         will be called ixgbevf.  MSI-X interrupt support is required
+         for this driver to work correctly.
+
+config IXGB
+	tristate "Intel(R) PRO/10GbE support"
+	depends on PCI
+	---help---
+	  This driver supports Intel(R) PRO/10GbE family of adapters for
+	  PCI-X type cards. For PCI-E type cards, use the "ixgbe" driver
+	  instead. For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
+
+	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+
+	  For general information and support, go to the Intel support
+	  website at:
+
+	  <http://support.intel.com>
+
+	  More specific information on configuring the driver is in
+	  <file:Documentation/networking/intel_wired_lan/ixgb.txt>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ixgb.
diff --git a/drivers/net/intel_wired_lan/Makefile b/drivers/net/intel_wired_lan/Makefile
new file mode 100644
index 0000000..87d7ba0
--- /dev/null
+++ b/drivers/net/intel_wired_lan/Makefile
@@ -0,0 +1,9 @@
+obj-$(CONFIG_E1000) += e1000/
+obj-$(CONFIG_E1000E) += e1000e/
+obj-$(CONFIG_IGB) += igb/
+obj-$(CONFIG_IGBVF) += igbvf/
+obj-$(CONFIG_IXGBE) += ixgbe/
+obj-$(CONFIG_IXGBEVF) += ixgbevf/
+obj-$(CONFIG_IXGB) += ixgb/
+
+obj-$(CONFIG_E100) += e100.o
diff --git a/drivers/net/e100.c b/drivers/net/intel_wired_lan/e100.c
similarity index 100%
rename from drivers/net/e100.c
rename to drivers/net/intel_wired_lan/e100.c
diff --git a/drivers/net/e1000/Makefile b/drivers/net/intel_wired_lan/e1000/Makefile
similarity index 100%
rename from drivers/net/e1000/Makefile
rename to drivers/net/intel_wired_lan/e1000/Makefile
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/intel_wired_lan/e1000/e1000.h
similarity index 100%
rename from drivers/net/e1000/e1000.h
rename to drivers/net/intel_wired_lan/e1000/e1000.h
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/intel_wired_lan/e1000/e1000_ethtool.c
similarity index 100%
rename from drivers/net/e1000/e1000_ethtool.c
rename to drivers/net/intel_wired_lan/e1000/e1000_ethtool.c
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/intel_wired_lan/e1000/e1000_hw.c
similarity index 100%
rename from drivers/net/e1000/e1000_hw.c
rename to drivers/net/intel_wired_lan/e1000/e1000_hw.c
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/intel_wired_lan/e1000/e1000_hw.h
similarity index 100%
rename from drivers/net/e1000/e1000_hw.h
rename to drivers/net/intel_wired_lan/e1000/e1000_hw.h
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/intel_wired_lan/e1000/e1000_main.c
similarity index 100%
rename from drivers/net/e1000/e1000_main.c
rename to drivers/net/intel_wired_lan/e1000/e1000_main.c
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/intel_wired_lan/e1000/e1000_osdep.h
similarity index 100%
rename from drivers/net/e1000/e1000_osdep.h
rename to drivers/net/intel_wired_lan/e1000/e1000_osdep.h
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/intel_wired_lan/e1000/e1000_param.c
similarity index 100%
rename from drivers/net/e1000/e1000_param.c
rename to drivers/net/intel_wired_lan/e1000/e1000_param.c
diff --git a/drivers/net/e1000e/82571.c b/drivers/net/intel_wired_lan/e1000e/82571.c
similarity index 100%
rename from drivers/net/e1000e/82571.c
rename to drivers/net/intel_wired_lan/e1000e/82571.c
diff --git a/drivers/net/e1000e/Makefile b/drivers/net/intel_wired_lan/e1000e/Makefile
similarity index 100%
rename from drivers/net/e1000e/Makefile
rename to drivers/net/intel_wired_lan/e1000e/Makefile
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/intel_wired_lan/e1000e/defines.h
similarity index 100%
rename from drivers/net/e1000e/defines.h
rename to drivers/net/intel_wired_lan/e1000e/defines.h
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/intel_wired_lan/e1000e/e1000.h
similarity index 100%
rename from drivers/net/e1000e/e1000.h
rename to drivers/net/intel_wired_lan/e1000e/e1000.h
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/intel_wired_lan/e1000e/es2lan.c
similarity index 100%
rename from drivers/net/e1000e/es2lan.c
rename to drivers/net/intel_wired_lan/e1000e/es2lan.c
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/intel_wired_lan/e1000e/ethtool.c
similarity index 100%
rename from drivers/net/e1000e/ethtool.c
rename to drivers/net/intel_wired_lan/e1000e/ethtool.c
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/intel_wired_lan/e1000e/hw.h
similarity index 100%
rename from drivers/net/e1000e/hw.h
rename to drivers/net/intel_wired_lan/e1000e/hw.h
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/intel_wired_lan/e1000e/ich8lan.c
similarity index 100%
rename from drivers/net/e1000e/ich8lan.c
rename to drivers/net/intel_wired_lan/e1000e/ich8lan.c
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/intel_wired_lan/e1000e/lib.c
similarity index 100%
rename from drivers/net/e1000e/lib.c
rename to drivers/net/intel_wired_lan/e1000e/lib.c
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/intel_wired_lan/e1000e/netdev.c
similarity index 100%
rename from drivers/net/e1000e/netdev.c
rename to drivers/net/intel_wired_lan/e1000e/netdev.c
diff --git a/drivers/net/e1000e/param.c b/drivers/net/intel_wired_lan/e1000e/param.c
similarity index 100%
rename from drivers/net/e1000e/param.c
rename to drivers/net/intel_wired_lan/e1000e/param.c
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/intel_wired_lan/e1000e/phy.c
similarity index 100%
rename from drivers/net/e1000e/phy.c
rename to drivers/net/intel_wired_lan/e1000e/phy.c
diff --git a/drivers/net/igb/Makefile b/drivers/net/intel_wired_lan/igb/Makefile
similarity index 100%
rename from drivers/net/igb/Makefile
rename to drivers/net/intel_wired_lan/igb/Makefile
diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/intel_wired_lan/igb/e1000_82575.c
similarity index 100%
rename from drivers/net/igb/e1000_82575.c
rename to drivers/net/intel_wired_lan/igb/e1000_82575.c
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/intel_wired_lan/igb/e1000_82575.h
similarity index 100%
rename from drivers/net/igb/e1000_82575.h
rename to drivers/net/intel_wired_lan/igb/e1000_82575.h
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/intel_wired_lan/igb/e1000_defines.h
similarity index 100%
rename from drivers/net/igb/e1000_defines.h
rename to drivers/net/intel_wired_lan/igb/e1000_defines.h
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/intel_wired_lan/igb/e1000_hw.h
similarity index 100%
rename from drivers/net/igb/e1000_hw.h
rename to drivers/net/intel_wired_lan/igb/e1000_hw.h
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/intel_wired_lan/igb/e1000_mac.c
similarity index 100%
rename from drivers/net/igb/e1000_mac.c
rename to drivers/net/intel_wired_lan/igb/e1000_mac.c
diff --git a/drivers/net/igb/e1000_mac.h b/drivers/net/intel_wired_lan/igb/e1000_mac.h
similarity index 100%
rename from drivers/net/igb/e1000_mac.h
rename to drivers/net/intel_wired_lan/igb/e1000_mac.h
diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/intel_wired_lan/igb/e1000_mbx.c
similarity index 100%
rename from drivers/net/igb/e1000_mbx.c
rename to drivers/net/intel_wired_lan/igb/e1000_mbx.c
diff --git a/drivers/net/igb/e1000_mbx.h b/drivers/net/intel_wired_lan/igb/e1000_mbx.h
similarity index 100%
rename from drivers/net/igb/e1000_mbx.h
rename to drivers/net/intel_wired_lan/igb/e1000_mbx.h
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/intel_wired_lan/igb/e1000_nvm.c
similarity index 100%
rename from drivers/net/igb/e1000_nvm.c
rename to drivers/net/intel_wired_lan/igb/e1000_nvm.c
diff --git a/drivers/net/igb/e1000_nvm.h b/drivers/net/intel_wired_lan/igb/e1000_nvm.h
similarity index 100%
rename from drivers/net/igb/e1000_nvm.h
rename to drivers/net/intel_wired_lan/igb/e1000_nvm.h
diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/intel_wired_lan/igb/e1000_phy.c
similarity index 100%
rename from drivers/net/igb/e1000_phy.c
rename to drivers/net/intel_wired_lan/igb/e1000_phy.c
diff --git a/drivers/net/igb/e1000_phy.h b/drivers/net/intel_wired_lan/igb/e1000_phy.h
similarity index 100%
rename from drivers/net/igb/e1000_phy.h
rename to drivers/net/intel_wired_lan/igb/e1000_phy.h
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/intel_wired_lan/igb/e1000_regs.h
similarity index 100%
rename from drivers/net/igb/e1000_regs.h
rename to drivers/net/intel_wired_lan/igb/e1000_regs.h
diff --git a/drivers/net/igb/igb.h b/drivers/net/intel_wired_lan/igb/igb.h
similarity index 100%
rename from drivers/net/igb/igb.h
rename to drivers/net/intel_wired_lan/igb/igb.h
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/intel_wired_lan/igb/igb_ethtool.c
similarity index 100%
rename from drivers/net/igb/igb_ethtool.c
rename to drivers/net/intel_wired_lan/igb/igb_ethtool.c
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/intel_wired_lan/igb/igb_main.c
similarity index 100%
rename from drivers/net/igb/igb_main.c
rename to drivers/net/intel_wired_lan/igb/igb_main.c
diff --git a/drivers/net/igbvf/Makefile b/drivers/net/intel_wired_lan/igbvf/Makefile
similarity index 100%
rename from drivers/net/igbvf/Makefile
rename to drivers/net/intel_wired_lan/igbvf/Makefile
diff --git a/drivers/net/igbvf/defines.h b/drivers/net/intel_wired_lan/igbvf/defines.h
similarity index 100%
rename from drivers/net/igbvf/defines.h
rename to drivers/net/intel_wired_lan/igbvf/defines.h
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/intel_wired_lan/igbvf/ethtool.c
similarity index 100%
rename from drivers/net/igbvf/ethtool.c
rename to drivers/net/intel_wired_lan/igbvf/ethtool.c
diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/intel_wired_lan/igbvf/igbvf.h
similarity index 100%
rename from drivers/net/igbvf/igbvf.h
rename to drivers/net/intel_wired_lan/igbvf/igbvf.h
diff --git a/drivers/net/igbvf/mbx.c b/drivers/net/intel_wired_lan/igbvf/mbx.c
similarity index 100%
rename from drivers/net/igbvf/mbx.c
rename to drivers/net/intel_wired_lan/igbvf/mbx.c
diff --git a/drivers/net/igbvf/mbx.h b/drivers/net/intel_wired_lan/igbvf/mbx.h
similarity index 100%
rename from drivers/net/igbvf/mbx.h
rename to drivers/net/intel_wired_lan/igbvf/mbx.h
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/intel_wired_lan/igbvf/netdev.c
similarity index 100%
rename from drivers/net/igbvf/netdev.c
rename to drivers/net/intel_wired_lan/igbvf/netdev.c
diff --git a/drivers/net/igbvf/regs.h b/drivers/net/intel_wired_lan/igbvf/regs.h
similarity index 100%
rename from drivers/net/igbvf/regs.h
rename to drivers/net/intel_wired_lan/igbvf/regs.h
diff --git a/drivers/net/igbvf/vf.c b/drivers/net/intel_wired_lan/igbvf/vf.c
similarity index 100%
rename from drivers/net/igbvf/vf.c
rename to drivers/net/intel_wired_lan/igbvf/vf.c
diff --git a/drivers/net/igbvf/vf.h b/drivers/net/intel_wired_lan/igbvf/vf.h
similarity index 100%
rename from drivers/net/igbvf/vf.h
rename to drivers/net/intel_wired_lan/igbvf/vf.h
diff --git a/drivers/net/ixgb/Makefile b/drivers/net/intel_wired_lan/ixgb/Makefile
similarity index 100%
rename from drivers/net/ixgb/Makefile
rename to drivers/net/intel_wired_lan/ixgb/Makefile
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/intel_wired_lan/ixgb/ixgb.h
similarity index 100%
rename from drivers/net/ixgb/ixgb.h
rename to drivers/net/intel_wired_lan/ixgb/ixgb.h
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/intel_wired_lan/ixgb/ixgb_ee.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_ee.c
rename to drivers/net/intel_wired_lan/ixgb/ixgb_ee.c
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/intel_wired_lan/ixgb/ixgb_ee.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_ee.h
rename to drivers/net/intel_wired_lan/ixgb/ixgb_ee.h
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/intel_wired_lan/ixgb/ixgb_ethtool.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_ethtool.c
rename to drivers/net/intel_wired_lan/ixgb/ixgb_ethtool.c
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/intel_wired_lan/ixgb/ixgb_hw.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_hw.c
rename to drivers/net/intel_wired_lan/ixgb/ixgb_hw.c
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/intel_wired_lan/ixgb/ixgb_hw.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_hw.h
rename to drivers/net/intel_wired_lan/ixgb/ixgb_hw.h
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/intel_wired_lan/ixgb/ixgb_ids.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_ids.h
rename to drivers/net/intel_wired_lan/ixgb/ixgb_ids.h
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/intel_wired_lan/ixgb/ixgb_main.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_main.c
rename to drivers/net/intel_wired_lan/ixgb/ixgb_main.c
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/intel_wired_lan/ixgb/ixgb_osdep.h
similarity index 100%
rename from drivers/net/ixgb/ixgb_osdep.h
rename to drivers/net/intel_wired_lan/ixgb/ixgb_osdep.h
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/intel_wired_lan/ixgb/ixgb_param.c
similarity index 100%
rename from drivers/net/ixgb/ixgb_param.c
rename to drivers/net/intel_wired_lan/ixgb/ixgb_param.c
diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/intel_wired_lan/ixgbe/Makefile
similarity index 100%
rename from drivers/net/ixgbe/Makefile
rename to drivers/net/intel_wired_lan/ixgbe/Makefile
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe.h
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_82598.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_82598.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_82598.c
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_82599.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_82599.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_82599.c
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_common.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_common.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_common.c
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_common.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_common.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_common.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb.c
diff --git a/drivers/net/ixgbe/ixgbe_dcb.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82598.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82598.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82598.c
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82598.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82598.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82598.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82599.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82599.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82599.c
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82599.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82599.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_82599.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_82599.h
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_nl.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_dcb_nl.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_dcb_nl.c
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_ethtool.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_ethtool.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_ethtool.c
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_fcoe.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_fcoe.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_fcoe.c
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_fcoe.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_fcoe.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_fcoe.h
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_main.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_main.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_main.c
diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_mbx.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_mbx.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_mbx.c
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_mbx.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_mbx.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_mbx.h
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_phy.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_phy.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_phy.c
diff --git a/drivers/net/ixgbe/ixgbe_phy.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_phy.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_phy.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_phy.h
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/intel_wired_lan/ixgbe/ixgbe_sriov.c
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_sriov.c
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_sriov.c
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_sriov.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_sriov.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_sriov.h
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/intel_wired_lan/ixgbe/ixgbe_type.h
similarity index 100%
rename from drivers/net/ixgbe/ixgbe_type.h
rename to drivers/net/intel_wired_lan/ixgbe/ixgbe_type.h
diff --git a/drivers/net/ixgbevf/Makefile b/drivers/net/intel_wired_lan/ixgbevf/Makefile
similarity index 100%
rename from drivers/net/ixgbevf/Makefile
rename to drivers/net/intel_wired_lan/ixgbevf/Makefile
diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/intel_wired_lan/ixgbevf/defines.h
similarity index 100%
rename from drivers/net/ixgbevf/defines.h
rename to drivers/net/intel_wired_lan/ixgbevf/defines.h
diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/intel_wired_lan/ixgbevf/ethtool.c
similarity index 100%
rename from drivers/net/ixgbevf/ethtool.c
rename to drivers/net/intel_wired_lan/ixgbevf/ethtool.c
diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/intel_wired_lan/ixgbevf/ixgbevf.h
similarity index 100%
rename from drivers/net/ixgbevf/ixgbevf.h
rename to drivers/net/intel_wired_lan/ixgbevf/ixgbevf.h
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/intel_wired_lan/ixgbevf/ixgbevf_main.c
similarity index 100%
rename from drivers/net/ixgbevf/ixgbevf_main.c
rename to drivers/net/intel_wired_lan/ixgbevf/ixgbevf_main.c
diff --git a/drivers/net/ixgbevf/mbx.c b/drivers/net/intel_wired_lan/ixgbevf/mbx.c
similarity index 100%
rename from drivers/net/ixgbevf/mbx.c
rename to drivers/net/intel_wired_lan/ixgbevf/mbx.c
diff --git a/drivers/net/ixgbevf/mbx.h b/drivers/net/intel_wired_lan/ixgbevf/mbx.h
similarity index 100%
rename from drivers/net/ixgbevf/mbx.h
rename to drivers/net/intel_wired_lan/ixgbevf/mbx.h
diff --git a/drivers/net/ixgbevf/regs.h b/drivers/net/intel_wired_lan/ixgbevf/regs.h
similarity index 100%
rename from drivers/net/ixgbevf/regs.h
rename to drivers/net/intel_wired_lan/ixgbevf/regs.h
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/intel_wired_lan/ixgbevf/vf.c
similarity index 100%
rename from drivers/net/ixgbevf/vf.c
rename to drivers/net/intel_wired_lan/ixgbevf/vf.c
diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/intel_wired_lan/ixgbevf/vf.h
similarity index 100%
rename from drivers/net/ixgbevf/vf.h
rename to drivers/net/intel_wired_lan/ixgbevf/vf.h



------------------------------------------------------------------------------
Beautiful is writing same markup. Internet Explorer 9 supports
standards for HTML5, CSS3, SVG 1.1,  ECMAScript5, and DOM L2 & L3.
Spend less time writing and  rewriting code and more time creating great
experiences on the web. Be a part of the beta today.
http://p.sf.net/sfu/beautyoftheweb
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
