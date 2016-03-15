From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH] netdev: Move octeon/octeon_mgmt driver to cavium directory.
Date: Mon, 14 Mar 2016 17:57:08 -0700
Message-ID: <1458003428-27632-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34195 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328AbcCOA5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 20:57:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Daney <david.daney@cavium.com>

No code changes.  Since OCTEON is a Cavium product, move the driver to
the vendor directory to unclutter things a bit.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/Kconfig                           |  1 -
 drivers/net/ethernet/Makefile                          |  1 -
 drivers/net/ethernet/cavium/Kconfig                    | 11 +++++++++++
 drivers/net/ethernet/cavium/Makefile                   |  1 +
 drivers/net/ethernet/{ => cavium}/octeon/Makefile      |  0
 drivers/net/ethernet/{ => cavium}/octeon/octeon_mgmt.c |  0
 drivers/net/ethernet/octeon/Kconfig                    | 14 --------------
 7 files changed, 12 insertions(+), 16 deletions(-)
 rename drivers/net/ethernet/{ => cavium}/octeon/Makefile (100%)
 rename drivers/net/ethernet/{ => cavium}/octeon/octeon_mgmt.c (100%)
 delete mode 100644 drivers/net/ethernet/octeon/Kconfig

diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index be67a19..2ffd634 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -139,7 +139,6 @@ config NET_NETX
 source "drivers/net/ethernet/nuvoton/Kconfig"
 source "drivers/net/ethernet/nvidia/Kconfig"
 source "drivers/net/ethernet/nxp/Kconfig"
-source "drivers/net/ethernet/octeon/Kconfig"
 source "drivers/net/ethernet/oki-semi/Kconfig"
 
 config ETHOC
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 6ffcc80..1d349e9 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -59,7 +59,6 @@ obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
 obj-$(CONFIG_NET_VENDOR_NVIDIA) += nvidia/
 obj-$(CONFIG_LPC_ENET) += nxp/
-obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 953aa40..0ef232d 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -53,4 +53,15 @@ config LIQUIDIO
 	  To compile this driver as a module, choose M here: the module
 	  will be called liquidio.  This is recommended.
 
+config OCTEON_MGMT_ETHERNET
+	tristate "Octeon Management port ethernet driver (CN5XXX, CN6XXX)"
+	depends on CAVIUM_OCTEON_SOC
+	select PHYLIB
+	select MDIO_OCTEON
+	default y
+	help
+	  Enable the ethernet driver for the management
+	  port on Cavium Networks' Octeon CN57XX, CN56XX, CN55XX,
+	  CN54XX, CN52XX, and CN6XXX chips.
+
 endif # NET_VENDOR_CAVIUM
diff --git a/drivers/net/ethernet/cavium/Makefile b/drivers/net/ethernet/cavium/Makefile
index d22f886a..872da9f 100644
--- a/drivers/net/ethernet/cavium/Makefile
+++ b/drivers/net/ethernet/cavium/Makefile
@@ -3,3 +3,4 @@
 #
 obj-$(CONFIG_NET_VENDOR_CAVIUM) += thunder/
 obj-$(CONFIG_NET_VENDOR_CAVIUM) += liquidio/
+obj-$(CONFIG_NET_VENDOR_CAVIUM) += octeon/
diff --git a/drivers/net/ethernet/octeon/Makefile b/drivers/net/ethernet/cavium/octeon/Makefile
similarity index 100%
rename from drivers/net/ethernet/octeon/Makefile
rename to drivers/net/ethernet/cavium/octeon/Makefile
diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
similarity index 100%
rename from drivers/net/ethernet/octeon/octeon_mgmt.c
rename to drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
diff --git a/drivers/net/ethernet/octeon/Kconfig b/drivers/net/ethernet/octeon/Kconfig
deleted file mode 100644
index a7aa280..0000000
--- a/drivers/net/ethernet/octeon/Kconfig
+++ /dev/null
@@ -1,14 +0,0 @@
-#
-# Cavium network device configuration
-#
-
-config OCTEON_MGMT_ETHERNET
-	tristate "Octeon Management port ethernet driver (CN5XXX, CN6XXX)"
-	depends on CAVIUM_OCTEON_SOC
-	select PHYLIB
-	select MDIO_OCTEON
-	default y
-	---help---
-	  This option enables the ethernet driver for the management
-	  port on Cavium Networks' Octeon CN57XX, CN56XX, CN55XX,
-	  CN54XX, CN52XX, and CN6XXX chips.
-- 
1.7.11.7
