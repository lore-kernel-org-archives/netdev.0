From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 26/71] xscale: Move the Intel XScale IXP drivers
Date: Sat, 30 Jul 2011 20:26:45 -0700
Message-ID: <1312082850-24914-27-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Lennert Buytenhek <kernel@wantstofly.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39387 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246Ab1GaD2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:00 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Intel XScale IXP drivers into drivers/net/ethernet/xscale/
and make the necessary Kconfig and Makefile changes.

CC: Krzysztof Halasa <khc@pm.waw.pl>
CC: Lennert Buytenhek <kernel@wantstofly.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    4 +-
 drivers/net/Kconfig                                |    2 -
 drivers/net/Makefile                               |    1 -
 drivers/net/arm/Kconfig                            |    8 ------
 drivers/net/arm/Makefile                           |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/xscale/Kconfig                |   27 ++++++++++++++++++++
 drivers/net/ethernet/xscale/Makefile               |    6 ++++
 drivers/net/{ => ethernet/xscale}/ixp2000/Kconfig  |    4 +-
 drivers/net/{ => ethernet/xscale}/ixp2000/Makefile |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/caleb.c  |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/caleb.h  |    0
 .../net/{ => ethernet/xscale}/ixp2000/enp2611.c    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400-msf.c    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400-msf.h    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_rx.uc    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_rx.ucode |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_tx.uc    |    0
 .../{ => ethernet/xscale}/ixp2000/ixp2400_tx.ucode |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.c |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.h |    0
 .../{ => ethernet/xscale}/ixp2000/ixpdev_priv.h    |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.c |    0
 drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.h |    0
 drivers/net/{arm => ethernet/xscale}/ixp4xx_eth.c  |    0
 26 files changed, 39 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/xscale/Kconfig
 create mode 100644 drivers/net/ethernet/xscale/Makefile
 rename drivers/net/{ => ethernet/xscale}/ixp2000/Kconfig (76%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/Makefile (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/caleb.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/caleb.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/enp2611.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400-msf.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400-msf.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_rx.uc (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_rx.ucode (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_tx.uc (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixp2400_tx.ucode (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/ixpdev_priv.h (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.c (100%)
 rename drivers/net/{ => ethernet/xscale}/ixp2000/pm3386.h (100%)
 rename drivers/net/{arm => ethernet/xscale}/ixp4xx_eth.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f811111..40eb3ce 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3307,7 +3307,7 @@ F:	arch/arm/mach-ixp4xx/include/mach/qmgr.h
 F:	arch/arm/mach-ixp4xx/include/mach/npe.h
 F:	arch/arm/mach-ixp4xx/ixp4xx_qmgr.c
 F:	arch/arm/mach-ixp4xx/ixp4xx_npe.c
-F:	drivers/net/arm/ixp4xx_eth.c
+F:	drivers/net/ethernet/xscale/ixp4xx_eth.c
 F:	drivers/net/wan/ixp4xx_hss.c
 
 INTEL IXP4XX RANDOM NUMBER GENERATOR SUPPORT
@@ -3319,7 +3319,7 @@ INTEL IXP2000 ETHERNET DRIVER
 M:	Lennert Buytenhek <kernel@wantstofly.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ixp2000/
+F:	drivers/net/ethernet/xscale/ixp2000/
 
 INTEL ETHERNET DRIVERS (e100/e1000/e1000e/igb/igbvf/ixgb/ixgbe/ixgbevf)
 M:	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8b1fae8..7f09cd5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -989,8 +989,6 @@ config IP1000
 	  To compile this driver as a module, choose M here: the module
 	  will be called ipg.  This is recommended.
 
-source "drivers/net/ixp2000/Kconfig"
-
 config HAMACHI
 	tristate "Packet Engines Hamachi GNIC-II support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 843edb3..ffcb609 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -166,7 +166,6 @@ obj-$(CONFIG_NET_TULIP) += tulip/
 obj-$(CONFIG_HAMRADIO) += hamradio/
 obj-$(CONFIG_IRDA) += irda/
 obj-$(CONFIG_ETRAX_ETHERNET) += cris/
-obj-$(CONFIG_ENP2611_MSF_NET) += ixp2000/
 
 obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
diff --git a/drivers/net/arm/Kconfig b/drivers/net/arm/Kconfig
index 7848b5f..4320e88 100644
--- a/drivers/net/arm/Kconfig
+++ b/drivers/net/arm/Kconfig
@@ -34,14 +34,6 @@ config EP93XX_ETH
 	  This is a driver for the ethernet hardware included in EP93xx CPUs.
 	  Say Y if you are building a kernel for EP93xx based devices.
 
-config IXP4XX_ETH
-	tristate "Intel IXP4xx Ethernet support"
-	depends on ARM && ARCH_IXP4XX && IXP4XX_NPE && IXP4XX_QMGR
-	select PHYLIB
-	help
-	  Say Y here if you want to use built-in Ethernet ports
-	  on IXP4xx processor.
-
 config W90P910_ETH
 	tristate "Nuvoton w90p910 Ethernet support"
 	depends on ARM && ARCH_W90X900
diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index 6cca728..5a0f141 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -7,5 +7,4 @@ obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
 obj-$(CONFIG_ARM_KS8695_ETHER)	+= ks8695net.o
 obj-$(CONFIG_EP93XX_ETH)	+= ep93xx_eth.o
-obj-$(CONFIG_IXP4XX_ETH)	+= ixp4xx_eth.o
 obj-$(CONFIG_W90P910_ETH)	+= w90p910_ether.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index efc3665..45d3eff 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -23,6 +23,7 @@ source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
+source "drivers/net/ethernet/xscale/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 668ca92..09536de 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
+obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
diff --git a/drivers/net/ethernet/xscale/Kconfig b/drivers/net/ethernet/xscale/Kconfig
new file mode 100644
index 0000000..cf8c395
--- /dev/null
+++ b/drivers/net/ethernet/xscale/Kconfig
@@ -0,0 +1,27 @@
+#
+# Intel XScale IXP device configuration
+#
+
+config NET_VENDOR_XSCALE
+	bool "Intel XScale IXP devices"
+	depends on NET_VENDOR_INTEL && ((ARM && ARCH_IXP4XX && \
+		   IXP4XX_NPE && IXP4XX_QMGR) || ARCH_ENP2611)
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question does not directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about XSacle IXP devices. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config IXP4XX_ETH
+	tristate "Intel IXP4xx Ethernet support"
+	depends on ARM && ARCH_IXP4XX && IXP4XX_NPE && IXP4XX_QMGR
+	select PHYLIB
+	---help---
+	  Say Y here if you want to use built-in Ethernet ports
+	  on IXP4xx processor.
+
+source "drivers/net/ethernet/xscale/ixp2000/Kconfig"
diff --git a/drivers/net/ethernet/xscale/Makefile b/drivers/net/ethernet/xscale/Makefile
new file mode 100644
index 0000000..b195b9d
--- /dev/null
+++ b/drivers/net/ethernet/xscale/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Intel XScale IXP device drivers.
+#
+
+obj-$(CONFIG_ENP2611_MSF_NET) += ixp2000/
+obj-$(CONFIG_IXP4XX_ETH) += ixp4xx_eth.o
diff --git a/drivers/net/ixp2000/Kconfig b/drivers/net/ethernet/xscale/ixp2000/Kconfig
similarity index 76%
rename from drivers/net/ixp2000/Kconfig
rename to drivers/net/ethernet/xscale/ixp2000/Kconfig
index 2fec241..234c139 100644
--- a/drivers/net/ixp2000/Kconfig
+++ b/drivers/net/ethernet/xscale/ixp2000/Kconfig
@@ -1,6 +1,6 @@
 config ENP2611_MSF_NET
 	tristate "Radisys ENP2611 MSF network interface support"
-	depends on ARCH_ENP2611
-	help
+	depends on NET_VENDOR_XSCALE && ARCH_ENP2611
+	---help---
 	  This is a driver for the MSF network interface unit in
 	  the IXP2400 on the Radisys ENP2611 platform.
diff --git a/drivers/net/ixp2000/Makefile b/drivers/net/ethernet/xscale/ixp2000/Makefile
similarity index 100%
rename from drivers/net/ixp2000/Makefile
rename to drivers/net/ethernet/xscale/ixp2000/Makefile
diff --git a/drivers/net/ixp2000/caleb.c b/drivers/net/ethernet/xscale/ixp2000/caleb.c
similarity index 100%
rename from drivers/net/ixp2000/caleb.c
rename to drivers/net/ethernet/xscale/ixp2000/caleb.c
diff --git a/drivers/net/ixp2000/caleb.h b/drivers/net/ethernet/xscale/ixp2000/caleb.h
similarity index 100%
rename from drivers/net/ixp2000/caleb.h
rename to drivers/net/ethernet/xscale/ixp2000/caleb.h
diff --git a/drivers/net/ixp2000/enp2611.c b/drivers/net/ethernet/xscale/ixp2000/enp2611.c
similarity index 100%
rename from drivers/net/ixp2000/enp2611.c
rename to drivers/net/ethernet/xscale/ixp2000/enp2611.c
diff --git a/drivers/net/ixp2000/ixp2400-msf.c b/drivers/net/ethernet/xscale/ixp2000/ixp2400-msf.c
similarity index 100%
rename from drivers/net/ixp2000/ixp2400-msf.c
rename to drivers/net/ethernet/xscale/ixp2000/ixp2400-msf.c
diff --git a/drivers/net/ixp2000/ixp2400-msf.h b/drivers/net/ethernet/xscale/ixp2000/ixp2400-msf.h
similarity index 100%
rename from drivers/net/ixp2000/ixp2400-msf.h
rename to drivers/net/ethernet/xscale/ixp2000/ixp2400-msf.h
diff --git a/drivers/net/ixp2000/ixp2400_rx.uc b/drivers/net/ethernet/xscale/ixp2000/ixp2400_rx.uc
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_rx.uc
rename to drivers/net/ethernet/xscale/ixp2000/ixp2400_rx.uc
diff --git a/drivers/net/ixp2000/ixp2400_rx.ucode b/drivers/net/ethernet/xscale/ixp2000/ixp2400_rx.ucode
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_rx.ucode
rename to drivers/net/ethernet/xscale/ixp2000/ixp2400_rx.ucode
diff --git a/drivers/net/ixp2000/ixp2400_tx.uc b/drivers/net/ethernet/xscale/ixp2000/ixp2400_tx.uc
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_tx.uc
rename to drivers/net/ethernet/xscale/ixp2000/ixp2400_tx.uc
diff --git a/drivers/net/ixp2000/ixp2400_tx.ucode b/drivers/net/ethernet/xscale/ixp2000/ixp2400_tx.ucode
similarity index 100%
rename from drivers/net/ixp2000/ixp2400_tx.ucode
rename to drivers/net/ethernet/xscale/ixp2000/ixp2400_tx.ucode
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ethernet/xscale/ixp2000/ixpdev.c
similarity index 100%
rename from drivers/net/ixp2000/ixpdev.c
rename to drivers/net/ethernet/xscale/ixp2000/ixpdev.c
diff --git a/drivers/net/ixp2000/ixpdev.h b/drivers/net/ethernet/xscale/ixp2000/ixpdev.h
similarity index 100%
rename from drivers/net/ixp2000/ixpdev.h
rename to drivers/net/ethernet/xscale/ixp2000/ixpdev.h
diff --git a/drivers/net/ixp2000/ixpdev_priv.h b/drivers/net/ethernet/xscale/ixp2000/ixpdev_priv.h
similarity index 100%
rename from drivers/net/ixp2000/ixpdev_priv.h
rename to drivers/net/ethernet/xscale/ixp2000/ixpdev_priv.h
diff --git a/drivers/net/ixp2000/pm3386.c b/drivers/net/ethernet/xscale/ixp2000/pm3386.c
similarity index 100%
rename from drivers/net/ixp2000/pm3386.c
rename to drivers/net/ethernet/xscale/ixp2000/pm3386.c
diff --git a/drivers/net/ixp2000/pm3386.h b/drivers/net/ethernet/xscale/ixp2000/pm3386.h
similarity index 100%
rename from drivers/net/ixp2000/pm3386.h
rename to drivers/net/ethernet/xscale/ixp2000/pm3386.h
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
similarity index 100%
rename from drivers/net/arm/ixp4xx_eth.c
rename to drivers/net/ethernet/xscale/ixp4xx_eth.c
-- 
1.7.6

