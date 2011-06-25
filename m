From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 66/72] ethoc: Move the Avionic driver
Date: Sat, 25 Jun 2011 06:59:17 -0700
Message-ID: <1309010363-22750-67-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Thierry Reding <thierry.reding@avionic-design.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582Ab1FYOAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:38 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Avionic driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makfile changes.

CC: Thierry Reding <thierry.reding@avionic-design.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                |   10 ----------
 drivers/net/Makefile               |    1 -
 drivers/net/ethernet/Kconfig       |   11 +++++++++++
 drivers/net/ethernet/Makefile      |    1 +
 drivers/net/{ => ethernet}/ethoc.c |    0
 5 files changed, 12 insertions(+), 11 deletions(-)
 rename drivers/net/{ => ethernet}/ethoc.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 59b935c..043bbf5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -291,16 +291,6 @@ config ENC28J60_WRITEVERIFY
 	  Enable the verify after the buffer write useful for debugging purpose.
 	  If unsure, say N.
 
-config ETHOC
-	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
-	depends on NET_ETHERNET && HAS_IOMEM && HAS_DMA
-	select MII
-	select PHYLIB
-	select CRC32
-	select BITREVERSE
-	help
-	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
-
 config GRETH
 	tristate "Aeroflex Gaisler GRETH Ethernet MAC support"
 	depends on SPARC
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4e84419..67e25a4 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -55,7 +55,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
-obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 55976aa..5645609 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -168,6 +168,17 @@ config FORCEDETH
 	  will be called forcedeth.
 
 source "drivers/net/ethernet/octeon/Kconfig"
+
+config ETHOC
+	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
+	depends on HAS_IOMEM && HAS_DMA
+	select MII
+	select PHYLIB
+	select CRC32
+	select BITREVERSE
+	---help---
+	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
+
 source "drivers/net/ethernet/isa/Kconfig"
 source "drivers/net/ethernet/oki/Kconfig"
 source "drivers/net/ethernet/packetengines/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 8800662..47d19fc 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -41,6 +41,7 @@ obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
+obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_NET_ISA) += isa/
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki/
diff --git a/drivers/net/ethoc.c b/drivers/net/ethernet/ethoc.c
similarity index 100%
rename from drivers/net/ethoc.c
rename to drivers/net/ethernet/ethoc.c
-- 
1.7.5.4

