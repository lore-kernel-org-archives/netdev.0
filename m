From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 67/71] netx: Move the netx driver
Date: Sat, 30 Jul 2011 20:27:26 -0700
Message-ID: <1312082850-24914-68-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Sascha Hauer <s.hauer@pengutronix.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753432Ab1GaD2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:51 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the netx driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Sascha Hauer <s.hauer@pengutronix.de>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/Kconfig                   |   10 ----------
 drivers/net/Makefile                  |    1 -
 drivers/net/ethernet/Kconfig          |   11 +++++++++++
 drivers/net/ethernet/Makefile         |    1 +
 drivers/net/{ => ethernet}/netx-eth.c |    0
 5 files changed, 12 insertions(+), 11 deletions(-)
 rename drivers/net/{ => ethernet}/netx-eth.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a6aba5b..b3da0bd 100644
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
index 298587f..8fa5b60 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -51,7 +51,6 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
-obj-$(CONFIG_NET_NETX) += netx-eth.o
 
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 45eef59..6e36196 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -102,6 +102,17 @@ config FEALNX
 
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
+
+config NET_NETX
+	tristate "NetX Ethernet support"
+	select MII
+	depends on ARCH_NETX
+	---help---
+	  This is support for the Hilscher netX builtin Ethernet ports
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called netx-eth.
+
 source "drivers/net/ethernet/nuvoton/Kconfig"
 source "drivers/net/ethernet/nvidia/Kconfig"
 source "drivers/net/ethernet/octeon/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index dfd5146..c274820 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -42,6 +42,7 @@ obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
 obj-$(CONFIG_NET_VENDOR_NVIDIA) += nvidia/
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
diff --git a/drivers/net/netx-eth.c b/drivers/net/ethernet/netx-eth.c
similarity index 100%
rename from drivers/net/netx-eth.c
rename to drivers/net/ethernet/netx-eth.c
-- 
1.7.6

