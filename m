From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 65/71] enc28j60: Move the Microchip driver
Date: Sat, 30 Jul 2011 20:27:24 -0700
Message-ID: <1312082850-24914-66-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38846 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238Ab1GaD2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:51 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Microchip driver into drivers/net/ethernet/microchip/ and
make the necessary Kconfig and Makefile changes.

CC: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   17 ----------
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/microchip/Kconfig             |   33 ++++++++++++++++++++
 drivers/net/ethernet/microchip/Makefile            |    5 +++
 drivers/net/{ => ethernet/microchip}/enc28j60.c    |    0
 drivers/net/{ => ethernet/microchip}/enc28j60_hw.h |    0
 8 files changed, 40 insertions(+), 18 deletions(-)
 create mode 100644 drivers/net/ethernet/microchip/Kconfig
 create mode 100644 drivers/net/ethernet/microchip/Makefile
 rename drivers/net/{ => ethernet/microchip}/enc28j60.c (100%)
 rename drivers/net/{ => ethernet/microchip}/enc28j60_hw.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0a20a35..ca11d5e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -274,23 +274,6 @@ config DM9000_FORCE_SIMPLE_PHY_POLL
 	  costly MII PHY reads. Note, this will not work if the chip is
 	  operating with an external PHY.
 
-config ENC28J60
-	tristate "ENC28J60 support"
-	depends on EXPERIMENTAL && SPI && NET_ETHERNET
-	select CRC32
-	---help---
-	  Support for the Microchip EN28J60 ethernet chip.
-
-	  To compile this driver as a module, choose M here. The module will be
-	  called enc28j60.
-
-config ENC28J60_WRITEVERIFY
-	bool "Enable write verify"
-	depends on ENC28J60
-	---help---
-	  Enable the verify after the buffer write useful for debugging purpose.
-	  If unsure, say N.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index e2f1f55..08ee56f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -53,7 +53,6 @@ obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DM9000) += dm9000.o
-obj-$(CONFIG_ENC28J60) += enc28j60.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 32561c7..0cec25c 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -78,6 +78,7 @@ config LANTIQ_ETOP
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
+source "drivers/net/ethernet/microchip/Kconfig"
 
 config MIPS_SIM_NET
 	tristate "MIPS simulator Network device"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 94f1be8..ebe8aee 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -36,6 +36,7 @@ obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
+obj-$(CONFIG_NET_VENDOR_MICROCHIP) += microchip/
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_FEALNX) += fealnx.o
diff --git a/drivers/net/ethernet/microchip/Kconfig b/drivers/net/ethernet/microchip/Kconfig
new file mode 100644
index 0000000..0b013d4
--- /dev/null
+++ b/drivers/net/ethernet/microchip/Kconfig
@@ -0,0 +1,33 @@
+#
+# Microchip network device configuration
+#
+
+config NET_VENDOR_MICROCHIP
+	bool "Microchip devices"
+	depends on SPI && EXPERIMENTAL
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Microchip cards. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+config ENC28J60
+	tristate "ENC28J60 support"
+	depends on NET_VENDOR_MICROCHIP && SPI && EXPERIMENTAL
+	select CRC32
+	---help---
+	  Support for the Microchip EN28J60 ethernet chip.
+
+	  To compile this driver as a module, choose M here. The module will be
+	  called enc28j60.
+
+config ENC28J60_WRITEVERIFY
+	bool "Enable write verify"
+	depends on ENC28J60
+	---help---
+	  Enable the verify after the buffer write useful for debugging purpose.
+	  If unsure, say N.
diff --git a/drivers/net/ethernet/microchip/Makefile b/drivers/net/ethernet/microchip/Makefile
new file mode 100644
index 0000000..573d429
--- /dev/null
+++ b/drivers/net/ethernet/microchip/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Microchip network device drivers.
+#
+
+obj-$(CONFIG_ENC28J60) += enc28j60.o
diff --git a/drivers/net/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
similarity index 100%
rename from drivers/net/enc28j60.c
rename to drivers/net/ethernet/microchip/enc28j60.c
diff --git a/drivers/net/enc28j60_hw.h b/drivers/net/ethernet/microchip/enc28j60_hw.h
similarity index 100%
rename from drivers/net/enc28j60_hw.h
rename to drivers/net/ethernet/microchip/enc28j60_hw.h
-- 
1.7.6

