From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 10/15] netdev: relocate more one-off drivers to the legacy dir
Date: Thu, 28 Oct 2010 21:19:14 -0400
Message-ID: <1288315159-1350-11-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33986 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab0J2BTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:32 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These one-off ISA/EISA/MCA drivers have been around since the
beginning of time; relocate them off to the legacy dir.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Kconfig                 |   76 -----------------------------------
 drivers/net/Makefile                |    5 --
 drivers/net/legacy/Kconfig          |   76 +++++++++++++++++++++++++++++++++++
 drivers/net/legacy/Makefile         |    5 ++
 drivers/net/{ => legacy}/at1700.c   |    0
 drivers/net/{ => legacy}/eth16i.c   |    0
 drivers/net/{ => legacy}/ibmlana.c  |    0
 drivers/net/{ => legacy}/ibmlana.h  |    0
 drivers/net/{ => legacy}/ni5010.c   |    0
 drivers/net/{ => legacy}/ni5010.h   |    0
 drivers/net/{ => legacy}/seeq8005.c |    0
 drivers/net/{ => legacy}/seeq8005.h |    0
 drivers/net/{ => legacy}/smc9194.c  |    0
 drivers/net/{ => legacy}/smc9194.h  |    0
 14 files changed, 81 insertions(+), 81 deletions(-)
 rename drivers/net/{ => legacy}/at1700.c (100%)
 rename drivers/net/{ => legacy}/eth16i.c (100%)
 rename drivers/net/{ => legacy}/ibmlana.c (100%)
 rename drivers/net/{ => legacy}/ibmlana.h (100%)
 rename drivers/net/{ => legacy}/ni5010.c (100%)
 rename drivers/net/{ => legacy}/ni5010.h (100%)
 rename drivers/net/{ => legacy}/seeq8005.c (100%)
 rename drivers/net/{ => legacy}/seeq8005.h (100%)
 rename drivers/net/{ => legacy}/smc9194.c (100%)
 rename drivers/net/{ => legacy}/smc9194.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5b6c3e9..b5adf52 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -586,21 +586,6 @@ config BFIN_MAC_USE_HWSTAMP
 	help
 	  To support the IEEE 1588 Precision Time Protocol (PTP), select y here
 
-config SMC9194
-	tristate "SMC 9194 support"
-	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
-	select CRC32
-	---help---
-	  This is support for the SMC9xxx based Ethernet cards. Choose this
-	  option if you have a DELL laptop with the docking station, or
-	  another SMC9192/9194 based chipset.  Say Y if you want it compiled
-	  into the kernel, and read the file
-	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called smc9194.
-
 config SMC91X
 	tristate "SMC 91C9x/91C1xxx support"
 	select CRC32
@@ -755,18 +740,6 @@ config NET_VENDOR_RACAL
 	  the questions about NI cards. If you say Y, you will be asked for
 	  your specific card in the following questions.
 
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
@@ -780,18 +753,6 @@ config DNET
 
 source "drivers/net/tulip/Kconfig"
 
-config AT1700
-	tristate "AT1700/1720 support (EXPERIMENTAL)"
-	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called at1700.
-
 config HP100
 	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
 	depends on ISA || EISA || PCI
@@ -820,43 +781,6 @@ config NET_ISA
 	  the remaining ISA network card questions. If you say Y, you will be
 	  asked for your specific card in the following questions.
 
-config ETH16I
-	tristate "ICL EtherTeam 16i/32 support"
-	depends on NET_ISA
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eth16i.
-
-config SEEQ8005
-	tristate "SEEQ8005 support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL
-	help
-	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
-	  is for you, read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called seeq8005.
-
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
 config IBMVETH
 	tristate "IBM LAN Virtual Ethernet support"
 	depends on PPC_PSERIES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 790bb6c..3182544 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -111,10 +111,8 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac/
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
-obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
-obj-$(CONFIG_SMC9194) += smc9194.o
 obj-$(CONFIG_FEC) += fec.o
 obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
@@ -156,8 +154,6 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
-obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_IBMLANA) += ibmlana.o
 obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
@@ -165,7 +161,6 @@ obj-$(CONFIG_ATP) += atp.o
 obj-$(CONFIG_NI5010) += ni5010.o
 obj-$(CONFIG_SC92031) += sc92031.o
 
-obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_JAZZ_SONIC) += jazzsonic.o
diff --git a/drivers/net/legacy/Kconfig b/drivers/net/legacy/Kconfig
index c4cdc99..2da3ac7 100644
--- a/drivers/net/legacy/Kconfig
+++ b/drivers/net/legacy/Kconfig
@@ -278,6 +278,18 @@ config ZNET
 	  by this driver. Read the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto>.
 
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
 config NI52
 	tristate "NI5210 support"
 	depends on NET_VENDOR_RACAL && ISA
@@ -573,3 +585,67 @@ config NE_H8300
 	help
 	  Say Y here if you want to use the NE2000 compatible
 	  controller on the Renesas H8/300 processor.
+
+config AT1700
+	tristate "AT1700/1720 support (EXPERIMENTAL)"
+	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called at1700.
+
+config ETH16I
+	tristate "ICL EtherTeam 16i/32 support"
+	depends on NET_ISA
+	help
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called eth16i.
+ 
+config SEEQ8005
+	tristate "SEEQ8005 support (EXPERIMENTAL)"
+	depends on NET_ISA && EXPERIMENTAL
+	help
+	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
+	  is for you, read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called seeq8005.
+
+config IBMLANA
+	tristate "IBM LAN Adapter/A support"
+	depends on MCA
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
+config SMC9194
+	tristate "SMC 9194 support"
+	depends on NET_VENDOR_SMC && (ISA || MAC && BROKEN)
+	select CRC32
+	---help---
+	  This is support for the SMC9xxx based Ethernet cards. Choose this
+	  option if you have a DELL laptop with the docking station, or
+	  another SMC9192/9194 based chipset.  Say Y if you want it compiled
+	  into the kernel, and read the file
+	  <file:Documentation/networking/smc9.txt> and the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called smc9194.
diff --git a/drivers/net/legacy/Makefile b/drivers/net/legacy/Makefile
index 5341a1d..0268706 100644
--- a/drivers/net/legacy/Makefile
+++ b/drivers/net/legacy/Makefile
@@ -70,3 +70,8 @@ obj-$(CONFIG_ZORRO8390) += zorro8390.o 8390.o
 # Other random one-off cards
 obj-$(CONFIG_EL3) += 3c509.o
 obj-$(CONFIG_3C515) += 3c515.o
+obj-$(CONFIG_SEEQ8005) += seeq8005.o
+obj-$(CONFIG_AT1700) += at1700.o
+obj-$(CONFIG_IBMLANA) += ibmlana.o
+obj-$(CONFIG_ETH16I) += eth16i.o
+obj-$(CONFIG_SMC9194) += smc9194.o
diff --git a/drivers/net/at1700.c b/drivers/net/legacy/at1700.c
similarity index 100%
rename from drivers/net/at1700.c
rename to drivers/net/legacy/at1700.c
diff --git a/drivers/net/eth16i.c b/drivers/net/legacy/eth16i.c
similarity index 100%
rename from drivers/net/eth16i.c
rename to drivers/net/legacy/eth16i.c
diff --git a/drivers/net/ibmlana.c b/drivers/net/legacy/ibmlana.c
similarity index 100%
rename from drivers/net/ibmlana.c
rename to drivers/net/legacy/ibmlana.c
diff --git a/drivers/net/ibmlana.h b/drivers/net/legacy/ibmlana.h
similarity index 100%
rename from drivers/net/ibmlana.h
rename to drivers/net/legacy/ibmlana.h
diff --git a/drivers/net/ni5010.c b/drivers/net/legacy/ni5010.c
similarity index 100%
rename from drivers/net/ni5010.c
rename to drivers/net/legacy/ni5010.c
diff --git a/drivers/net/ni5010.h b/drivers/net/legacy/ni5010.h
similarity index 100%
rename from drivers/net/ni5010.h
rename to drivers/net/legacy/ni5010.h
diff --git a/drivers/net/seeq8005.c b/drivers/net/legacy/seeq8005.c
similarity index 100%
rename from drivers/net/seeq8005.c
rename to drivers/net/legacy/seeq8005.c
diff --git a/drivers/net/seeq8005.h b/drivers/net/legacy/seeq8005.h
similarity index 100%
rename from drivers/net/seeq8005.h
rename to drivers/net/legacy/seeq8005.h
diff --git a/drivers/net/smc9194.c b/drivers/net/legacy/smc9194.c
similarity index 100%
rename from drivers/net/smc9194.c
rename to drivers/net/legacy/smc9194.c
diff --git a/drivers/net/smc9194.h b/drivers/net/legacy/smc9194.h
similarity index 100%
rename from drivers/net/smc9194.h
rename to drivers/net/legacy/smc9194.h
-- 
1.7.3.2.146.g2d444

