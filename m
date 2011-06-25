From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 70/72] netx: Move the netx driver
Date: Sat, 25 Jun 2011 06:59:21 -0700
Message-ID: <1309010363-22750-71-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622Ab1FYOAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:39 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the netx driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Sascha Hauer <s.hauer@pengutronix.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                   |   10 ----------
 drivers/net/Makefile                  |    1 -
 drivers/net/ethernet/Kconfig          |   10 ++++++++++
 drivers/net/ethernet/Makefile         |    1 +
 drivers/net/{ => ethernet}/netx-eth.c |    0
 5 files changed, 11 insertions(+), 11 deletions(-)
 rename drivers/net/{ => ethernet}/netx-eth.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4ddc389..dfae2ec 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -236,16 +236,6 @@ config SH_ETH
 	  This driver supporting CPUs are:
 		- SH7710, SH7712, SH7763, SH7619, SH7724, and SH7757.
 
-config NET_NETX
-	tristate "NetX Ethernet support"
-	select MII
-	depends on ARCH_NETX
-	help
-	  This is support for the Hilscher netX builtin Ethernet ports
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called netx-eth.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 83075d4..c24b5ef 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -52,7 +52,6 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
-obj-$(CONFIG_NET_NETX) += netx-eth.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 3ec1903..b7d8d9b 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -176,6 +176,16 @@ config FEALNX
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 
+config NET_NETX
+	tristate "NetX Ethernet support"
+	depends on ARCH_NETX
+	select MII
+	---help---
+	  This is support for the Hilscher netX builtin Ethernet ports
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called netx-eth.
+
 config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on PCI
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 3b2a35a..c1a1c61 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_NET_VENDOR_MOTOROLA) += motorola/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_ETHOC) += ethoc.o
diff --git a/drivers/net/netx-eth.c b/drivers/net/ethernet/netx-eth.c
similarity index 100%
rename from drivers/net/netx-eth.c
rename to drivers/net/ethernet/netx-eth.c
-- 
1.7.5.4

