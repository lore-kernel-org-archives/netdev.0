From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 27/72] ftgmac100/ftmac100: Move the Faraday drivers
Date: Sat, 25 Jun 2011 06:58:38 -0700
Message-ID: <1309010363-22750-28-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	"Po-Yu Chuang" <ratbert@faraday-tech.com>,
	"Po-Yu Chuang" <ratbert.chuang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986Ab1FYN74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:56 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Faraday driver into drivers/net/ethernet/faraday/ and
make the necessary Kconfig and Makefile changes.

CC: "Po-Yu Chuang" <ratbert@faraday-tech.com>
CC: "Po-Yu Chuang" <ratbert.chuang@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                            |   18 ------------
 drivers/net/Makefile                           |    2 -
 drivers/net/ethernet/Kconfig                   |    1 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/ethernet/faraday/Kconfig           |   34 ++++++++++++++++++++++++
 drivers/net/ethernet/faraday/Makefile          |    6 ++++
 drivers/net/{ => ethernet/faraday}/ftgmac100.c |    0
 drivers/net/{ => ethernet/faraday}/ftgmac100.h |    0
 drivers/net/{ => ethernet/faraday}/ftmac100.c  |    0
 drivers/net/{ => ethernet/faraday}/ftmac100.h  |    0
 10 files changed, 42 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/faraday/Kconfig
 create mode 100644 drivers/net/ethernet/faraday/Makefile
 rename drivers/net/{ => ethernet/faraday}/ftgmac100.c (100%)
 rename drivers/net/{ => ethernet/faraday}/ftgmac100.h (100%)
 rename drivers/net/{ => ethernet/faraday}/ftmac100.c (100%)
 rename drivers/net/{ => ethernet/faraday}/ftmac100.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3568fc2..c819982 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1027,15 +1027,6 @@ config XILINX_EMACLITE
 	help
 	  This driver supports the 10/100 Ethernet Lite from Xilinx.
 
-config FTMAC100
-	tristate "Faraday FTMAC100 10/100 Ethernet support"
-	depends on ARM
-	select MII
-	help
-	  This driver supports the FTMAC100 10/100 Ethernet controller
-	  from Faraday. It is used on Faraday A320, Andes AG101 and some
-	  other ARM/NDS32 SoC's.
-
 config LANTIQ_ETOP
 	tristate "Lantiq SoC ETOP driver"
 	depends on SOC_TYPE_XWAY
@@ -1384,15 +1375,6 @@ config PCH_GBE
 	  ML7223 is companion chip for Intel Atom E6xx series.
 	  ML7223 is completely compatible for Intel EG20T PCH.
 
-config FTGMAC100
-	tristate "Faraday FTGMAC100 Gigabit Ethernet support"
-	depends on ARM
-	select PHYLIB
-	help
-	  This driver supports the FTGMAC100 Gigabit Ethernet controller
-	  from Faraday. It is used on Faraday A369, Andes AG102 and some
-	  other ARM/NDS32 SoC's.
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d3eb443..2d50791 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -77,8 +77,6 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
-obj-$(CONFIG_FTGMAC100) += ftgmac100.o
-obj-$(CONFIG_FTMAC100) += ftmac100.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
 obj-$(CONFIG_MV643XX_ETH) += mv643xx_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 76fcaae..ca05127 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -21,6 +21,7 @@ source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
+source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 0bdb3ed..803882c 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -13,6 +13,7 @@ obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
+obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
diff --git a/drivers/net/ethernet/faraday/Kconfig b/drivers/net/ethernet/faraday/Kconfig
new file mode 100644
index 0000000..32eaee9
--- /dev/null
+++ b/drivers/net/ethernet/faraday/Kconfig
@@ -0,0 +1,34 @@
+#
+# Faraday device configuration
+#
+
+config NET_VENDOR_FARADAY
+	bool "Faraday devices"
+	depends on ARM
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Faraday cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config FTMAC100
+	tristate "Faraday FTMAC100 10/100 Ethernet support"
+	depends on NET_VENDOR_FARADAY && ARM
+	select MII
+	---help---
+	  This driver supports the FTMAC100 10/100 Ethernet controller
+	  from Faraday. It is used on Faraday A320, Andes AG101 and some
+	  other ARM/NDS32 SoC's.
+
+config FTGMAC100
+	tristate "Faraday FTGMAC100 Gigabit Ethernet support"
+	depends on NET_VENDOR_FARADAY && ARM
+	select PHYLIB
+	---help---
+	  This driver supports the FTGMAC100 Gigabit Ethernet controller
+	  from Faraday. It is used on Faraday A369, Andes AG102 and some
+	  other ARM/NDS32 SoC's.
diff --git a/drivers/net/ethernet/faraday/Makefile b/drivers/net/ethernet/faraday/Makefile
new file mode 100644
index 0000000..408b539
--- /dev/null
+++ b/drivers/net/ethernet/faraday/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Faraday device drivers.
+#
+
+obj-$(CONFIG_FTGMAC100) += ftgmac100.o
+obj-$(CONFIG_FTMAC100) += ftmac100.o
diff --git a/drivers/net/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
similarity index 100%
rename from drivers/net/ftgmac100.c
rename to drivers/net/ethernet/faraday/ftgmac100.c
diff --git a/drivers/net/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
similarity index 100%
rename from drivers/net/ftgmac100.h
rename to drivers/net/ethernet/faraday/ftgmac100.h
diff --git a/drivers/net/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
similarity index 100%
rename from drivers/net/ftmac100.c
rename to drivers/net/ethernet/faraday/ftmac100.c
diff --git a/drivers/net/ftmac100.h b/drivers/net/ethernet/faraday/ftmac100.h
similarity index 100%
rename from drivers/net/ftmac100.h
rename to drivers/net/ethernet/faraday/ftmac100.h
-- 
1.7.5.4

