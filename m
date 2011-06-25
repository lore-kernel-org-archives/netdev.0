From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 37/72] fsl_*/gianfar*/ucc_*: Move the Freescale drivers
Date: Sat, 25 Jun 2011 06:58:48 -0700
Message-ID: <1309010363-22750-38-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Sandeep Gopalpet <sandeep.kumar@freescale.com>,
	Andy Fleming <afleming@freescale.com>,
	Shlomi Gridish <gridish@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711Ab1FYOAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:05 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Freescale driver into drivers/net/ethernet/freescale/ and
make the necessary Kconfig and Makefile changes.

CC: Sandeep Gopalpet <sandeep.kumar@freescale.com>
CC: Andy Fleming <afleming@freescale.com>
CC: Shlomi Gridish <gridish@freescale.com>
CC: Li Yang <leoli@freescale.com>
CC: Pantelis Antoniou <pantelis.antoniou@gmail.com>
CC: Vitaly Bordug <vbordug@ru.mvista.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    4 +-
 drivers/net/Kconfig                                |   33 -------------
 drivers/net/Makefile                               |   14 ------
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/freescale/Kconfig             |   48 ++++++++++++++++++++
 drivers/net/ethernet/freescale/Makefile            |   13 +++++
 .../net/{ => ethernet/freescale}/fs_enet/Kconfig   |    2 +-
 .../net/{ => ethernet/freescale}/fs_enet/Makefile  |    0
 drivers/net/{ => ethernet/freescale}/fs_enet/fec.h |    0
 .../freescale}/fs_enet/fs_enet-main.c              |    0
 .../net/{ => ethernet/freescale}/fs_enet/fs_enet.h |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-fcc.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-fec.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-scc.c |    0
 .../{ => ethernet/freescale}/fs_enet/mii-bitbang.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mii-fec.c |    0
 drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.c |    0
 drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.h |    0
 drivers/net/{ => ethernet/freescale}/gianfar.c     |    0
 drivers/net/{ => ethernet/freescale}/gianfar.h     |    0
 .../net/{ => ethernet/freescale}/gianfar_ethtool.c |    0
 drivers/net/{ => ethernet/freescale}/gianfar_ptp.c |    0
 .../net/{ => ethernet/freescale}/gianfar_sysfs.c   |    0
 drivers/net/{ => ethernet/freescale}/ucc_geth.c    |    0
 drivers/net/{ => ethernet/freescale}/ucc_geth.h    |    0
 .../{ => ethernet/freescale}/ucc_geth_ethtool.c    |    0
 27 files changed, 66 insertions(+), 50 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/Makefile
 rename drivers/net/{ => ethernet/freescale}/fs_enet/Kconfig (91%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/Makefile (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fec.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fs_enet-main.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fs_enet.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-fcc.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-scc.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mii-bitbang.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mii-fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.h (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar.h (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_ethtool.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_ptp.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_sysfs.c (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth.c (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth.h (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth_ethtool.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 160ce2f..bbb609b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2656,7 +2656,7 @@ M:	Vitaly Bordug <vbordug@ru.mvista.com>
 L:	linuxppc-dev@lists.ozlabs.org
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/fs_enet/
+F:	drivers/net/ethernet/freescale/fs_enet/
 F:	include/linux/fs_enet_pd.h
 
 FREESCALE QUICC ENGINE LIBRARY
@@ -2678,7 +2678,7 @@ M:	Li Yang <leoli@freescale.com>
 L:	netdev@vger.kernel.org
 L:	linuxppc-dev@lists.ozlabs.org
 S:	Maintained
-F:	drivers/net/ucc_geth*
+F:	drivers/net/ethernet/freescale/ucc_geth*
 
 FREESCALE QUICC ENGINE UCC UART DRIVER
 M:	Timur Tabi <timur@freescale.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e352432..71efe31 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -765,9 +765,6 @@ config LANTIQ_ETOP
 	help
 	  Support for the MII0 inside the Lantiq SoC
 
-
-source "drivers/net/fs_enet/Kconfig"
-
 source "drivers/net/octeon/Kconfig"
 
 endif # NET_ETHERNET
@@ -884,36 +881,6 @@ config GELIC_WIRELESS
 	  the driver automatically distinguishes the models, you can
 	  safely enable this option even if you have a wireless-less model.
 
-config FSL_PQ_MDIO
-	tristate "Freescale PQ MDIO"
-	depends on FSL_SOC
-	select PHYLIB
-	help
-	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
-
-config GIANFAR
-	tristate "Gianfar Ethernet"
-	depends on FSL_SOC
-	select FSL_PQ_MDIO
-	select PHYLIB
-	select CRC32
-	help
-	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
-	  and MPC86xx family of chips, and the FEC on the 8540.
-
-config UCC_GETH
-	tristate "Freescale QE Gigabit Ethernet"
-	depends on QUICC_ENGINE
-	select FSL_PQ_MDIO
-	select PHYLIB
-	help
-	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
-	  which is available on some Freescale SOCs.
-
-config UGETH_TX_ON_DEMAND
-	bool "Transmit on Demand support"
-	depends on UCC_GETH
-
 config MV643XX_ETH
 	tristate "Marvell Discovery (643XX) and Orion ethernet support"
 	depends on (MV64X60 || PPC32 || PLAT_ORION) && INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index eee3091..0b1c240 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -5,24 +5,12 @@
 obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_PHYLIB) += phy/
-
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
-obj-$(CONFIG_GIANFAR) += gianfar_driver.o
-obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 
-gianfar_driver-objs := gianfar.o \
-		gianfar_ethtool.o \
-		gianfar_sysfs.o
-
-obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
-ucc_geth_driver-objs := ucc_geth.o ucc_geth_ethtool.o
-
-obj-$(CONFIG_FSL_PQ_MDIO) += fsl_pq_mdio.o
-
 #
 # link order important here
 #
@@ -150,8 +138,6 @@ obj-$(CONFIG_ENP2611_MSF_NET) += ixp2000/
 
 obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
-obj-$(CONFIG_FS_ENET) += fs_enet/
-
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 
 obj-$(CONFIG_WIMAX) += wimax/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index c584ba7..8654b69 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -24,6 +24,7 @@ source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
+source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1d8dba7..a09193f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
+obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
new file mode 100644
index 0000000..192286e
--- /dev/null
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -0,0 +1,48 @@
+#
+# Freescale device configuration
+#
+
+config NET_VENDOR_FEESCALE
+	bool "Freescale devices"
+	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x
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
+source "drivers/net/ethernet/freescale/fs_enet/Kconfig"
+
+config FSL_PQ_MDIO
+	tristate "Freescale PQ MDIO"
+	depends on NET_VENDOR_FREESCALE && FSL_SOC
+	select PHYLIB
+	---help---
+	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
+
+config UCC_GETH
+	tristate "Freescale QE Gigabit Ethernet"
+	depends on NET_VENDOR_FREESCALE && QUICC_ENGINE
+	select FSL_PQ_MDIO
+	select PHYLIB
+	---help---
+	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
+	  which is available on some Freescale SOCs.
+
+config UGETH_TX_ON_DEMAND
+	bool "Transmit on Demand support"
+	depends on UCC_GETH
+
+config GIANFAR
+	tristate "Gianfar Ethernet"
+	depends on NET_VENDOR_FREESCALE && FSL_SOC
+	select FSL_PQ_MDIO
+	select PHYLIB
+	select CRC32
+	---help---
+	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
+	  and MPC86xx family of chips, and the FEC on the 8540.
diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
new file mode 100644
index 0000000..7f7fae9
--- /dev/null
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -0,0 +1,13 @@
+#
+# Makefile for the Freescale network device drivers.
+#
+
+obj-$(CONFIG_FS_ENET) += fs_enet/
+obj-$(CONFIG_FSL_PQ_MDIO) += fsl_pq_mdio.o
+obj-$(CONFIG_GIANFAR) += gianfar_driver.o
+obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
+gianfar_driver-objs := gianfar.o \
+		gianfar_ethtool.o \
+		gianfar_sysfs.o
+obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
+ucc_geth_driver-objs := ucc_geth.o ucc_geth_ethtool.o
diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/ethernet/freescale/fs_enet/Kconfig
similarity index 91%
rename from drivers/net/fs_enet/Kconfig
rename to drivers/net/ethernet/freescale/fs_enet/Kconfig
index fc073b5..be92229 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/ethernet/freescale/fs_enet/Kconfig
@@ -1,6 +1,6 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
-       depends on CPM1 || CPM2 || PPC_MPC512x
+       depends on NET_VENDOR_FREESCALE && (CPM1 || CPM2 || PPC_MPC512x)
        select MII
        select PHYLIB
 
diff --git a/drivers/net/fs_enet/Makefile b/drivers/net/ethernet/freescale/fs_enet/Makefile
similarity index 100%
rename from drivers/net/fs_enet/Makefile
rename to drivers/net/ethernet/freescale/fs_enet/Makefile
diff --git a/drivers/net/fs_enet/fec.h b/drivers/net/ethernet/freescale/fs_enet/fec.h
similarity index 100%
rename from drivers/net/fs_enet/fec.h
rename to drivers/net/ethernet/freescale/fs_enet/fec.h
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
similarity index 100%
rename from drivers/net/fs_enet/fs_enet-main.c
rename to drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
similarity index 100%
rename from drivers/net/fs_enet/fs_enet.h
rename to drivers/net/ethernet/freescale/fs_enet/fs_enet.h
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
similarity index 100%
rename from drivers/net/fs_enet/mac-fcc.c
rename to drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
similarity index 100%
rename from drivers/net/fs_enet/mac-fec.c
rename to drivers/net/ethernet/freescale/fs_enet/mac-fec.c
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
similarity index 100%
rename from drivers/net/fs_enet/mac-scc.c
rename to drivers/net/ethernet/freescale/fs_enet/mac-scc.c
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
similarity index 100%
rename from drivers/net/fs_enet/mii-bitbang.c
rename to drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
similarity index 100%
rename from drivers/net/fs_enet/mii-fec.c
rename to drivers/net/ethernet/freescale/fs_enet/mii-fec.c
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
similarity index 100%
rename from drivers/net/fsl_pq_mdio.c
rename to drivers/net/ethernet/freescale/fsl_pq_mdio.c
diff --git a/drivers/net/fsl_pq_mdio.h b/drivers/net/ethernet/freescale/fsl_pq_mdio.h
similarity index 100%
rename from drivers/net/fsl_pq_mdio.h
rename to drivers/net/ethernet/freescale/fsl_pq_mdio.h
diff --git a/drivers/net/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
similarity index 100%
rename from drivers/net/gianfar.c
rename to drivers/net/ethernet/freescale/gianfar.c
diff --git a/drivers/net/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
similarity index 100%
rename from drivers/net/gianfar.h
rename to drivers/net/ethernet/freescale/gianfar.h
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
similarity index 100%
rename from drivers/net/gianfar_ethtool.c
rename to drivers/net/ethernet/freescale/gianfar_ethtool.c
diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
similarity index 100%
rename from drivers/net/gianfar_ptp.c
rename to drivers/net/ethernet/freescale/gianfar_ptp.c
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/ethernet/freescale/gianfar_sysfs.c
similarity index 100%
rename from drivers/net/gianfar_sysfs.c
rename to drivers/net/ethernet/freescale/gianfar_sysfs.c
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
similarity index 100%
rename from drivers/net/ucc_geth.c
rename to drivers/net/ethernet/freescale/ucc_geth.c
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
similarity index 100%
rename from drivers/net/ucc_geth.h
rename to drivers/net/ethernet/freescale/ucc_geth.h
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
similarity index 100%
rename from drivers/net/ucc_geth_ethtool.c
rename to drivers/net/ethernet/freescale/ucc_geth_ethtool.c
-- 
1.7.5.4

