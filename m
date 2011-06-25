From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 08/72] qlogic: Move the QLogic drivers
Date: Sat, 25 Jun 2011 06:58:19 -0700
Message-ID: <1309010363-22750-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Ron Mercer <ron.mercer@qlogic.com>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46933 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976Ab1FYN7h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:37 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the QLogic drivers into drivers/net/ethernet/qlogic/ and
the necessary Kconfig and Makefile changes.

CC: Ron Mercer <ron.mercer@qlogic.com>
CC: Amit Kumar Salecha <amit.salecha@qlogic.com>
CC: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    8 ++--
 drivers/net/Kconfig                                |   26 ----------
 drivers/net/Makefile                               |    3 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/qlogic/Kconfig                |   49 ++++++++++++++++++++
 drivers/net/ethernet/qlogic/Makefile               |    8 +++
 drivers/net/{ => ethernet/qlogic}/netxen/Makefile  |    0
 .../net/{ => ethernet/qlogic}/netxen/netxen_nic.h  |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_ctx.c  |    0
 .../qlogic}/netxen/netxen_nic_ethtool.c            |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_hdr.h  |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_hw.c   |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_hw.h   |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_init.c |    0
 .../{ => ethernet/qlogic}/netxen/netxen_nic_main.c |    0
 drivers/net/{ => ethernet/qlogic}/qla3xxx.c        |    0
 drivers/net/{ => ethernet/qlogic}/qla3xxx.h        |    0
 drivers/net/{ => ethernet/qlogic}/qlcnic/Makefile  |    0
 drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic.h  |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_ctx.c  |    0
 .../{ => ethernet/qlogic}/qlcnic/qlcnic_ethtool.c  |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_hdr.h  |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_hw.c   |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_init.c |    0
 .../net/{ => ethernet/qlogic}/qlcnic/qlcnic_main.c |    0
 drivers/net/{ => ethernet/qlogic}/qlge/Makefile    |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge.h      |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge_dbg.c  |    0
 .../net/{ => ethernet/qlogic}/qlge/qlge_ethtool.c  |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge_main.c |    0
 drivers/net/{ => ethernet/qlogic}/qlge/qlge_mpi.c  |    0
 32 files changed, 63 insertions(+), 33 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/Kconfig
 create mode 100644 drivers/net/ethernet/qlogic/Makefile
 rename drivers/net/{ => ethernet/qlogic}/netxen/Makefile (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_ctx.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_ethtool.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_hdr.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_hw.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_hw.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_init.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/netxen/netxen_nic_main.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qla3xxx.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qla3xxx.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/Makefile (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_ctx.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_ethtool.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_hdr.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_hw.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_init.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlcnic/qlcnic_main.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/Makefile (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge.h (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_dbg.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_ethtool.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_main.c (100%)
 rename drivers/net/{ => ethernet/qlogic}/qlge/qlge_mpi.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index ed7cce6..4929f4a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4441,7 +4441,7 @@ M:	Amit Kumar Salecha <amit.salecha@qlogic.com>
 L:	netdev@vger.kernel.org
 W:	http://www.qlogic.com
 S:	Supported
-F:	drivers/net/netxen/
+F:	drivers/net/ethernet/qlogic/netxen/
 
 NFS, SUNRPC, AND LOCKD CLIENTS
 M:	Trond Myklebust <Trond.Myklebust@netapp.com>
@@ -5162,7 +5162,7 @@ M:	linux-driver@qlogic.com
 L:	netdev@vger.kernel.org
 S:	Supported
 F:	Documentation/networking/LICENSE.qla3xxx
-F:	drivers/net/qla3xxx.*
+F:	drivers/net/ethernet/qlogic/qla3xxx.*
 
 QLOGIC QLCNIC (1/10)Gb ETHERNET DRIVER
 M:	Amit Kumar Salecha <amit.salecha@qlogic.com>
@@ -5170,14 +5170,14 @@ M:	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
 M:	linux-driver@qlogic.com
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/qlcnic/
+F:	drivers/net/ethernet/qlogic/qlcnic/
 
 QLOGIC QLGE 10Gb ETHERNET DRIVER
 M:	Ron Mercer <ron.mercer@qlogic.com>
 M:	linux-driver@qlogic.com
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/qlge/
+F:	drivers/net/ethernet/qlogic/qlge/
 
 QNX4 FILESYSTEM
 M:	Anders Larsen <al@alarsen.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5bb247f..802be52 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1702,15 +1702,6 @@ config XILINX_LL_TEMAC
 	  This driver supports the Xilinx 10/100/1000 LocalLink TEMAC
 	  core used in Xilinx Spartan and Virtex FPGAs
 
-config QLA3XXX
-	tristate "QLogic QLA3XXX Network Driver Support"
-	depends on PCI
-	help
-	  This driver supports QLogic ISP3XXX gigabit Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called qla3xxx.
-
 config ATL1
 	tristate "Atheros/Attansic L1 Gigabit Ethernet support"
 	depends on PCI
@@ -1949,23 +1940,6 @@ config TEHUTI
 	help
 	  Tehuti Networks 10G Ethernet NIC
 
-config QLCNIC
-	tristate "QLOGIC QLCNIC 1/10Gb Converged Ethernet NIC Support"
-	depends on PCI
-	select FW_LOADER
-	help
-	  This driver supports QLogic QLE8240 and QLE8242 Converged Ethernet
-	  devices.
-
-config QLGE
-	tristate "QLogic QLGE 10Gb Ethernet Driver Support"
-	depends on PCI
-	help
-	  This driver supports QLogic ISP8XXX 10Gb Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called qlge.
-
 config BNA
 	tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b2e5b93..9dcbcc7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -111,9 +111,6 @@ obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
 ll_temac-objs := ll_temac_main.o ll_temac_mdio.o
 obj-$(CONFIG_XILINX_LL_TEMAC) += ll_temac.o
 obj-$(CONFIG_XILINX_EMACLITE) += xilinx_emaclite.o
-obj-$(CONFIG_QLA3XXX) += qla3xxx.o
-obj-$(CONFIG_QLCNIC) += qlcnic/
-obj-$(CONFIG_QLGE) += qlge/
 
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index a2fd385..ab591bb 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -17,5 +17,6 @@ source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
+source "drivers/net/ethernet/qlogic/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 5265271..d8cf120 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -8,3 +8,4 @@ obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
+obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
new file mode 100644
index 0000000..07f088a
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -0,0 +1,49 @@
+#
+# QLogic network device configuration
+#
+
+config NET_VENDOR_QLOGIC
+	bool "QLogic devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about QLogic cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config QLA3XXX
+	tristate "QLogic QLA3XXX Network Driver Support"
+	depends on NET_VENDOR_QLOGIC && PCI
+	---help---
+	  This driver supports QLogic ISP3XXX gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called qla3xxx.
+
+config QLCNIC
+	tristate "QLOGIC QLCNIC 1/10Gb Converged Ethernet NIC Support"
+	depends on NET_VENDOR_QLOGIC && PCI
+	select FW_LOADER
+	---help---
+	  This driver supports QLogic QLE8240 and QLE8242 Converged Ethernet
+	  devices.
+
+config QLGE
+	tristate "QLogic QLGE 10Gb Ethernet Driver Support"
+	depends on NET_VENDOR_QLOGIC && PCI
+	---help---
+	  This driver supports QLogic ISP8XXX 10Gb Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called qlge.
+
+config NETXEN_NIC
+	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
+	depends on NET_VENDOR_QLOGIC && PCI
+	select FW_LOADER
+	---help---
+	  This enables the support for NetXen's Gigabit Ethernet card.
diff --git a/drivers/net/ethernet/qlogic/Makefile b/drivers/net/ethernet/qlogic/Makefile
new file mode 100644
index 0000000..b2a283d
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the QLogic network device drivers.
+#
+
+obj-$(CONFIG_QLA3XXX) += qla3xxx.o
+obj-$(CONFIG_QLCNIC) += qlcnic/
+obj-$(CONFIG_QLGE) += qlge/
+obj-$(CONFIG_NETXEN_NIC) += netxen/
diff --git a/drivers/net/netxen/Makefile b/drivers/net/ethernet/qlogic/netxen/Makefile
similarity index 100%
rename from drivers/net/netxen/Makefile
rename to drivers/net/ethernet/qlogic/netxen/Makefile
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
similarity index 100%
rename from drivers/net/netxen/netxen_nic.h
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic.h
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
similarity index 100%
rename from drivers/net/netxen/netxen_nic_ctx.c
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
similarity index 100%
rename from drivers/net/netxen/netxen_nic_ethtool.c
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
similarity index 100%
rename from drivers/net/netxen/netxen_nic_hdr.h
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
similarity index 100%
rename from drivers/net/netxen/netxen_nic_hw.c
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.h
similarity index 100%
rename from drivers/net/netxen/netxen_nic_hw.h
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.h
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
similarity index 100%
rename from drivers/net/netxen/netxen_nic_init.c
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
similarity index 100%
rename from drivers/net/netxen/netxen_nic_main.c
rename to drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
diff --git a/drivers/net/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
similarity index 100%
rename from drivers/net/qla3xxx.c
rename to drivers/net/ethernet/qlogic/qla3xxx.c
diff --git a/drivers/net/qla3xxx.h b/drivers/net/ethernet/qlogic/qla3xxx.h
similarity index 100%
rename from drivers/net/qla3xxx.h
rename to drivers/net/ethernet/qlogic/qla3xxx.h
diff --git a/drivers/net/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
similarity index 100%
rename from drivers/net/qlcnic/Makefile
rename to drivers/net/ethernet/qlogic/qlcnic/Makefile
diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
similarity index 100%
rename from drivers/net/qlcnic/qlcnic.h
rename to drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
similarity index 100%
rename from drivers/net/qlcnic/qlcnic_ctx.c
rename to drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
similarity index 100%
rename from drivers/net/qlcnic/qlcnic_ethtool.c
rename to drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
similarity index 100%
rename from drivers/net/qlcnic/qlcnic_hdr.h
rename to drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
similarity index 100%
rename from drivers/net/qlcnic/qlcnic_hw.c
rename to drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
similarity index 100%
rename from drivers/net/qlcnic/qlcnic_init.c
rename to drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
similarity index 100%
rename from drivers/net/qlcnic/qlcnic_main.c
rename to drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
diff --git a/drivers/net/qlge/Makefile b/drivers/net/ethernet/qlogic/qlge/Makefile
similarity index 100%
rename from drivers/net/qlge/Makefile
rename to drivers/net/ethernet/qlogic/qlge/Makefile
diff --git a/drivers/net/qlge/qlge.h b/drivers/net/ethernet/qlogic/qlge/qlge.h
similarity index 100%
rename from drivers/net/qlge/qlge.h
rename to drivers/net/ethernet/qlogic/qlge/qlge.h
diff --git a/drivers/net/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
similarity index 100%
rename from drivers/net/qlge/qlge_dbg.c
rename to drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
similarity index 100%
rename from drivers/net/qlge/qlge_ethtool.c
rename to drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
similarity index 100%
rename from drivers/net/qlge/qlge_main.c
rename to drivers/net/ethernet/qlogic/qlge/qlge_main.c
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
similarity index 100%
rename from drivers/net/qlge/qlge_mpi.c
rename to drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
-- 
1.7.5.4

