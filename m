From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 65/72] dnet: Move the Dave Ethernet driver
Date: Sat, 25 Jun 2011 06:59:16 -0700
Message-ID: <1309010363-22750-66-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Ilya Yanok <yanok@emcraft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752580Ab1FYOAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:37 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Dave Ethernet driver into drivers/net/ethernet/ and
make the necessary Kconfig and Makefile changes.

CC: "Dave S.r.l." <www.dave.eu>
CC: Ilya Yanok <yanok@emcraft.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig               |   11 -----------
 drivers/net/Makefile              |    2 --
 drivers/net/ethernet/Kconfig      |   11 +++++++++++
 drivers/net/ethernet/Makefile     |    1 +
 drivers/net/{ => ethernet}/dnet.c |    0
 drivers/net/{ => ethernet}/dnet.h |    0
 6 files changed, 12 insertions(+), 13 deletions(-)
 rename drivers/net/{ => ethernet}/dnet.c (100%)
 rename drivers/net/{ => ethernet}/dnet.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5c3505b..59b935c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -309,17 +309,6 @@ config GRETH
 	help
 	  Say Y here if you want to use the Aeroflex Gaisler GRETH Ethernet MAC.
 
-config DNET
-	tristate "Dave ethernet support (DNET)"
-	depends on NET_ETHERNET && HAS_IOMEM
-	select PHYLIB
-	help
-	  The Dave ethernet interface (DNET) is found on Qong Board FPGA.
-	  Say Y to include support for the DNET chip.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called dnet.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8504458..4e84419 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -58,8 +58,6 @@ obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
 
-obj-$(CONFIG_DNET) += dnet.o
-
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_TR) += tokenring/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index c6d61a01..55976aa 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -73,6 +73,17 @@ source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
 
+config DNET
+	tristate "Dave ethernet support (DNET)"
+	depends on HAS_IOMEM
+	select PHYLIB
+	---help---
+	  The Dave ethernet interface (DNET) is found on Qong Board FPGA.
+	  Say Y to include support for the DNET chip.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called dnet.
+
 config DEPCA
 	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
 	depends on ISA || EISA || MCA
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 0ad9873..8800662 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -18,6 +18,7 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
diff --git a/drivers/net/dnet.c b/drivers/net/ethernet/dnet.c
similarity index 100%
rename from drivers/net/dnet.c
rename to drivers/net/ethernet/dnet.c
diff --git a/drivers/net/dnet.h b/drivers/net/ethernet/dnet.h
similarity index 100%
rename from drivers/net/dnet.h
rename to drivers/net/ethernet/dnet.h
-- 
1.7.5.4

