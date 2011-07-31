From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 63/71] ethoc: Move the Avionic driver
Date: Sat, 30 Jul 2011 20:27:22 -0700
Message-ID: <1312082850-24914-64-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Thierry Reding <thierry.reding@avionic-design.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752851Ab1GaD2r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:47 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Avionic driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

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
index 873133e..c77a1b9 100644
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
index 14960d4..4e74d93 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -54,7 +54,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
-obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index a911753..e89bb27 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -103,6 +103,17 @@ source "drivers/net/ethernet/nuvoton/Kconfig"
 source "drivers/net/ethernet/nvidia/Kconfig"
 source "drivers/net/ethernet/octeon/Kconfig"
 source "drivers/net/ethernet/oki-semi/Kconfig"
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
 source "drivers/net/ethernet/packetengines/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 5154291..5ef1218 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -43,6 +43,7 @@ obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
 obj-$(CONFIG_NET_VENDOR_NVIDIA) += nvidia/
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
+obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
diff --git a/drivers/net/ethoc.c b/drivers/net/ethernet/ethoc.c
similarity index 100%
rename from drivers/net/ethoc.c
rename to drivers/net/ethernet/ethoc.c
-- 
1.7.6

