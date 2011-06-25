From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 42/72] 82586.c/fec*: Move the Motorola drivers
Date: Sat, 25 Jun 2011 06:58:53 -0700
Message-ID: <1309010363-22750-43-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Dan Malek <dmalek@jlc.net>, Sylvain Munaut <tnt@246tNt.com>,
	Richard Hirst <richard@sleepie.demon.co.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752524Ab1FYOAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:34 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Motorola drivers into drivers/net/ethernet/motorola/ and
make the necessary Kconfig and Makefile changes

CC: Dan Malek <dmalek@jlc.net>
CC: Sylvain Munaut <tnt@246tNt.com>
CC: Richard Hirst <richard@sleepie.demon.co.uk>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   69 ---------------
 drivers/net/Makefile                               |    9 --
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/{ => ethernet/motorola}/82596.c        |    0
 drivers/net/ethernet/motorola/Kconfig              |   88 ++++++++++++++++++++
 drivers/net/ethernet/motorola/Makefile             |   13 +++
 drivers/net/{ => ethernet/motorola}/fec.c          |    0
 drivers/net/{ => ethernet/motorola}/fec.h          |    0
 drivers/net/{ => ethernet/motorola}/fec_mpc52xx.c  |    0
 drivers/net/{ => ethernet/motorola}/fec_mpc52xx.h  |    0
 .../net/{ => ethernet/motorola}/fec_mpc52xx_phy.c  |    0
 12 files changed, 103 insertions(+), 78 deletions(-)
 rename drivers/net/{ => ethernet/motorola}/82596.c (100%)
 create mode 100644 drivers/net/ethernet/motorola/Kconfig
 create mode 100644 drivers/net/ethernet/motorola/Makefile
 rename drivers/net/{ => ethernet/motorola}/fec.c (100%)
 rename drivers/net/{ => ethernet/motorola}/fec.h (100%)
 rename drivers/net/{ => ethernet/motorola}/fec_mpc52xx.c (100%)
 rename drivers/net/{ => ethernet/motorola}/fec_mpc52xx.h (100%)
 rename drivers/net/{ => ethernet/motorola}/fec_mpc52xx_phy.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 37e06ae..ddbdf3c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -256,24 +256,6 @@ config A2065
 	  To compile this driver as a module, choose M here: the module
 	  will be called a2065.
 
-config MVME16x_NET
-	tristate "MVME16x Ethernet support"
-	depends on MVME16x
-	help
-	  This is the driver for the Ethernet interface on the Motorola
-	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
-	  driver for this chip in your kernel.
-	  To compile this driver as a module, choose M here.
-
-config BVME6000_NET
-	tristate "BVME6000 Ethernet support"
-	depends on BVME6000
-	help
-	  This is the driver for the Ethernet interface on BVME4000 and
-	  BVME6000 VME boards.  Say Y here to include the driver for this chip
-	  in your kernel.
-	  To compile this driver as a module, choose M here.
-
 config LASI_82596
 	tristate "Lasi ethernet"
 	depends on GSC
@@ -521,17 +503,6 @@ config ADAPTEC_STARFIRE
 	  To compile this driver as a module, choose M here: the module
 	  will be called starfire.  This is recommended.
 
-config APRICOT
-	tristate "Apricot Xen-II on board Ethernet"
-	depends on NET_PCI && ISA
-	help
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called apricot.
-
 config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on NET_PCI && PCI
@@ -651,46 +622,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config 68360_ENET
-	bool "Motorola 68360 ethernet controller"
-	depends on M68360
-	help
-	  Say Y here if you want to use the built-in ethernet controller of
-	  the Motorola 68360 processor.
-
-config FEC
-	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
-	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
-		IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC
-	default IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC if ARM
-	select PHYLIB
-	help
-	  Say Y here if you want to use the built-in 10/100 Fast ethernet
-	  controller on some Motorola ColdFire and Freescale i.MX processors.
-
-config FEC_MPC52xx
-	tristate "MPC52xx FEC driver"
-	depends on PPC_MPC52xx && PPC_BESTCOMM
-	select CRC32
-	select PHYLIB
-	select PPC_BESTCOMM_FEC
-	---help---
-	  This option enables support for the MPC5200's on-chip
-	  Fast Ethernet Controller
-	  If compiled as module, it will be called fec_mpc52xx.
-
-config FEC_MPC52xx_MDIO
-	bool "MPC52xx FEC MDIO bus driver"
-	depends on FEC_MPC52xx
-	default y
-	---help---
-	  The MPC5200's FEC can connect to the Ethernet either with
-	  an external MII PHY chip or 10 Mbps 7-wire interface
-	  (Motorola? industry standard).
-	  If your board uses an external PHY connected to FEC, enable this.
-	  If not sure, enable.
-	  If compiled as module, it will be called fec_mpc52xx_phy.
-
 config XILINX_EMACLITE
 	tristate "Xilinx 10/100 Ethernet Lite support"
 	depends on PPC32 || MICROBLAZE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d1724fa..0d02503 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -41,12 +41,6 @@ obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
-obj-$(CONFIG_FEC) += fec.o
-obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
-ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
-	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
-endif
-obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
@@ -78,11 +72,8 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_DEPCA) += depca.o
-obj-$(CONFIG_APRICOT) += 82596.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
-obj-$(CONFIG_MVME16x_NET) += 82596.o
-obj-$(CONFIG_BVME6000_NET) += 82596.o
 obj-$(CONFIG_SC92031) += sc92031.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 276a19d..74d98b3 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -30,6 +30,7 @@ source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
+source "drivers/net/ethernet/motorola/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index dd94351..4a682a7 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
+obj-$(CONFIG_NET_VENDOR_MOTOROLA) += motorola/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_ISA) += isa/
diff --git a/drivers/net/82596.c b/drivers/net/ethernet/motorola/82596.c
similarity index 100%
rename from drivers/net/82596.c
rename to drivers/net/ethernet/motorola/82596.c
diff --git a/drivers/net/ethernet/motorola/Kconfig b/drivers/net/ethernet/motorola/Kconfig
new file mode 100644
index 0000000..8a2e5cf
--- /dev/null
+++ b/drivers/net/ethernet/motorola/Kconfig
@@ -0,0 +1,88 @@
+#
+# Motorola device configuration
+#
+
+config NET_VENDOR_MOTOROLA
+	bool "Motorola devices"
+	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
+		IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC || M68360 \
+		|| PPC_MPC52xx || PPC_BESTCOMM || MVME16x || ISA || BVME6000
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Motorola devices. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+config APRICOT
+	tristate "Apricot Xen-II on board Ethernet"
+	depends on NET_VENDOR_MOTOROLA && ISA
+	---help---
+	  If you have a network (Ethernet) controller of this type, say Y and
+	  read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called apricot.
+
+config BVME6000_NET
+	tristate "BVME6000 Ethernet support"
+	depends on NET_VENDOR_MOTOROLA && BVME6000
+	---help---
+	  This is the driver for the Ethernet interface on BVME4000 and
+	  BVME6000 VME boards.  Say Y here to include the driver for this chip
+	  in your kernel.
+	  To compile this driver as a module, choose M here.
+
+config FEC
+	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
+	depends on NET_VENDOR_MOTOROLA && (AM523x || M527x || M5272 || M528x \
+		|| M520x || M532x || IMX_HAVE_PLATFORM_FEC || \
+		MXS_HAVE_PLATFORM_FEC)
+	default IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC if ARM
+	select PHYLIB
+	---help---
+	  Say Y here if you want to use the built-in 10/100 Fast ethernet
+	  controller on some Motorola ColdFire and Freescale i.MX processors.
+
+config 68360_ENET
+	bool "Motorola 68360 ethernet controller"
+	depends on NET_VENDOR_MOTOROLA && M68360
+	---help---
+	  Say Y here if you want to use the built-in ethernet controller of
+	  the Motorola 68360 processor.
+
+config FEC_MPC52xx
+	tristate "MPC52xx FEC driver"
+	depends on NET_VENDOR_MOTOROLA && PPC_MPC52xx && PPC_BESTCOMM
+	select CRC32
+	select PHYLIB
+	select PPC_BESTCOMM_FEC
+	---help---
+	  This option enables support for the MPC5200's on-chip
+	  Fast Ethernet Controller
+	  If compiled as module, it will be called fec_mpc52xx.
+
+config FEC_MPC52xx_MDIO
+	bool "MPC52xx FEC MDIO bus driver"
+	depends on FEC_MPC52xx
+	default y
+	---help---
+	  The MPC5200's FEC can connect to the Ethernet either with
+	  an external MII PHY chip or 10 Mbps 7-wire interface
+	  (Motorola? industry standard).
+	  If your board uses an external PHY connected to FEC, enable this.
+	  If not sure, enable.
+	  If compiled as module, it will be called fec_mpc52xx_phy.
+
+config MVME16x_NET
+	tristate "MVME16x Ethernet support"
+	depends on NET_VENDOR_MOTOROLA && MVME16x
+	---help---
+	  This is the driver for the Ethernet interface on the Motorola
+	  MVME162, 166, 167, 172 and 177 boards.  Say Y here to include the
+	  driver for this chip in your kernel.
+	  To compile this driver as a module, choose M here.
diff --git a/drivers/net/ethernet/motorola/Makefile b/drivers/net/ethernet/motorola/Makefile
new file mode 100644
index 0000000..b704427
--- /dev/null
+++ b/drivers/net/ethernet/motorola/Makefile
@@ -0,0 +1,13 @@
+#
+# Makefile for Motorola network device drivers.
+#
+
+obj-$(CONFIG_APRICOT) += 82596.o
+obj-$(CONFIG_68360_ENET) += 68360enet.o
+obj-$(CONFIG_BVME6000_NET) += 82596.o
+obj-$(CONFIG_FEC) += fec.o
+obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
+ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
+	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
+endif
+obj-$(CONFIG_MVME16x_NET) += 82596.o
diff --git a/drivers/net/fec.c b/drivers/net/ethernet/motorola/fec.c
similarity index 100%
rename from drivers/net/fec.c
rename to drivers/net/ethernet/motorola/fec.c
diff --git a/drivers/net/fec.h b/drivers/net/ethernet/motorola/fec.h
similarity index 100%
rename from drivers/net/fec.h
rename to drivers/net/ethernet/motorola/fec.h
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/ethernet/motorola/fec_mpc52xx.c
similarity index 100%
rename from drivers/net/fec_mpc52xx.c
rename to drivers/net/ethernet/motorola/fec_mpc52xx.c
diff --git a/drivers/net/fec_mpc52xx.h b/drivers/net/ethernet/motorola/fec_mpc52xx.h
similarity index 100%
rename from drivers/net/fec_mpc52xx.h
rename to drivers/net/ethernet/motorola/fec_mpc52xx.h
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/ethernet/motorola/fec_mpc52xx_phy.c
similarity index 100%
rename from drivers/net/fec_mpc52xx_phy.c
rename to drivers/net/ethernet/motorola/fec_mpc52xx_phy.c
-- 
1.7.5.4

