From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 68/72] enc28j60: Move the enc28j60 driver
Date: Sat, 25 Jun 2011 06:59:19 -0700
Message-ID: <1309010363-22750-69-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:41778 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752605Ab1FYOAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:38 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the enc28j60 driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                      |   17 -----------------
 drivers/net/Makefile                     |    1 -
 drivers/net/ethernet/Kconfig             |   18 ++++++++++++++++++
 drivers/net/ethernet/Makefile            |    1 +
 drivers/net/{ => ethernet}/enc28j60.c    |    0
 drivers/net/{ => ethernet}/enc28j60_hw.h |    0
 6 files changed, 19 insertions(+), 18 deletions(-)
 rename drivers/net/{ => ethernet}/enc28j60.c (100%)
 rename drivers/net/{ => ethernet}/enc28j60_hw.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 70ff9cc..d1bcd23 100644
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
index 9c9b2ea..b647529 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -54,7 +54,6 @@ obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DM9000) += dm9000.o
-obj-$(CONFIG_ENC28J60) += enc28j60.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 4c18328..ac88e7c 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -100,6 +100,24 @@ config DEPCA
 
 source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
+
+config ENC28J60
+	tristate "ENC28J60 support"
+	depends on EXPERIMENTAL && SPI && NET_ETHERNET
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
+
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/freescale/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index f2e36ba..afbb0ff 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
+obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
diff --git a/drivers/net/enc28j60.c b/drivers/net/ethernet/enc28j60.c
similarity index 100%
rename from drivers/net/enc28j60.c
rename to drivers/net/ethernet/enc28j60.c
diff --git a/drivers/net/enc28j60_hw.h b/drivers/net/ethernet/enc28j60_hw.h
similarity index 100%
rename from drivers/net/enc28j60_hw.h
rename to drivers/net/ethernet/enc28j60_hw.h
-- 
1.7.5.4

