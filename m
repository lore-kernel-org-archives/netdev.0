From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 61/72] forcedeth: Move the NVIDIA nForce driver
Date: Sat, 25 Jun 2011 06:59:12 -0700
Message-ID: <1309010363-22750-62-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37764 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752575Ab1FYOAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:35 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the nForce driver into drivers/net/ethernet/ and make
the necessary Kconfig and Makefile changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                    |   11 -----------
 drivers/net/Makefile                   |    1 -
 drivers/net/ethernet/Kconfig           |   12 ++++++++++++
 drivers/net/ethernet/Makefile          |    1 +
 drivers/net/{ => ethernet}/forcedeth.c |    0
 5 files changed, 13 insertions(+), 12 deletions(-)
 rename drivers/net/{ => ethernet}/forcedeth.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4ec5d5e..04968e8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -384,17 +384,6 @@ config ADAPTEC_STARFIRE
 	  To compile this driver as a module, choose M here: the module
 	  will be called starfire.  This is recommended.
 
-config FORCEDETH
-	tristate "nForce Ethernet support"
-	depends on NET_PCI && PCI
-	help
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called forcedeth.
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 8b0a478..97edc95 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -29,7 +29,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
-obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 45becd2..94e8630 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -91,6 +91,18 @@ config FEALNX
 
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
+
+config FORCEDETH
+	tristate "nForce Ethernet support"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) controller of this type, say Y and
+	  read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called forcedeth.
+
 source "drivers/net/ethernet/octeon/Kconfig"
 source "drivers/net/ethernet/isa/Kconfig"
 source "drivers/net/ethernet/oki/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c4284aa..b6ff610 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_NET_VENDOR_MOTOROLA) += motorola/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_FORCEDETH) += forcedeth.o
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_ISA) += isa/
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
diff --git a/drivers/net/forcedeth.c b/drivers/net/ethernet/forcedeth.c
similarity index 100%
rename from drivers/net/forcedeth.c
rename to drivers/net/ethernet/forcedeth.c
-- 
1.7.5.4

