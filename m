From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] dnet: Move the Dave Ethernet driver
Date: Sat, 13 Aug 2011 00:56:26 -0700
Message-ID: <1313222196-10074-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Ilya Yanok <yanok@emcraft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39635 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985Ab1HMH4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 03:56:39 -0400
In-Reply-To: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Dave Ethernet driver into drivers/net/ethernet/ and
make the necessary Kconfig and Makefile changes.

CC: Ilya Yanok <yanok@emcraft.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig               |   11 -----------
 drivers/net/Makefile              |    1 -
 drivers/net/ethernet/Kconfig      |   12 ++++++++++++
 drivers/net/ethernet/Makefile     |    1 +
 drivers/net/{ => ethernet}/dnet.c |    0
 drivers/net/{ => ethernet}/dnet.h |    0
 6 files changed, 13 insertions(+), 12 deletions(-)
 rename drivers/net/{ => ethernet}/dnet.c (100%)
 rename drivers/net/{ => ethernet}/dnet.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 39ba799..d292da7 100644
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
index 5b37149..14960d4 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -57,7 +57,6 @@ obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
 
-obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_TR) += tokenring/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index c1ce356..a911753 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -23,6 +23,18 @@ source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cirrus/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
+
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
 source "drivers/net/ethernet/dec/Kconfig"
 source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 34e84fa..5154291 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CIRRUS) += cirrus/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_NET_VENDOR_DEC) += dec/
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
1.7.6

