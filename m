From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/10] forcedeth: Move the NVIDIA nForce driver
Date: Fri, 12 Aug 2011 12:45:43 -0700
Message-ID: <1313178344-8168-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63234 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043Ab1HLTpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 15:45:53 -0400
In-Reply-To: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the nForce driver into drivers/net/ethernet/nvidia/ and make
the necessary Kconfig and Makefile changes.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                           |   11 ---------
 drivers/net/Makefile                          |    1 -
 drivers/net/ethernet/Kconfig                  |    1 +
 drivers/net/ethernet/Makefile                 |    1 +
 drivers/net/ethernet/nvidia/Kconfig           |   31 +++++++++++++++++++++++++
 drivers/net/ethernet/nvidia/Makefile          |    5 ++++
 drivers/net/{ => ethernet/nvidia}/forcedeth.c |    0
 7 files changed, 38 insertions(+), 12 deletions(-)
 create mode 100644 drivers/net/ethernet/nvidia/Kconfig
 create mode 100644 drivers/net/ethernet/nvidia/Makefile
 rename drivers/net/{ => ethernet/nvidia}/forcedeth.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 754ddd2..c7953ad 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -359,17 +359,6 @@ config ADAPTEC_STARFIRE
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
index e11166a..4d5af15 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -28,7 +28,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
-obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 711297f..1de8edc 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -86,6 +86,7 @@ config FEALNX
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/nuvoton/Kconfig"
+source "drivers/net/ethernet/nvidia/Kconfig"
 source "drivers/net/ethernet/octeon/Kconfig"
 source "drivers/net/ethernet/oki-semi/Kconfig"
 source "drivers/net/ethernet/packetengines/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index e30dde4..3d5ed1f 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -37,6 +37,7 @@ obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
+obj-$(CONFIG_NET_VENDOR_NVIDIA) += nvidia/
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki-semi/
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
diff --git a/drivers/net/ethernet/nvidia/Kconfig b/drivers/net/ethernet/nvidia/Kconfig
new file mode 100644
index 0000000..0a18e73
--- /dev/null
+++ b/drivers/net/ethernet/nvidia/Kconfig
@@ -0,0 +1,31 @@
+#
+# NVIDIA network device configuration
+#
+
+config NET_VENDOR_NVIDIA
+	bool "NVIDIA devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about NVIDIA cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_NVIDIA
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
+endif # NET_VENDOR_NVIDIA
diff --git a/drivers/net/ethernet/nvidia/Makefile b/drivers/net/ethernet/nvidia/Makefile
new file mode 100644
index 0000000..e079ae5
--- /dev/null
+++ b/drivers/net/ethernet/nvidia/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the NVIDIA network device drivers.
+#
+
+obj-$(CONFIG_FORCEDETH) += forcedeth.o
diff --git a/drivers/net/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
similarity index 100%
rename from drivers/net/forcedeth.c
rename to drivers/net/ethernet/nvidia/forcedeth.c
-- 
1.7.6

