From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] starfire: Move the Adaptec driver
Date: Fri, 12 Aug 2011 12:45:44 -0700
Message-ID: <1313178344-8168-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Ion Badulescu <ionut@badula.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63243 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754043Ab1HLTp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 15:45:56 -0400
In-Reply-To: <1313178344-8168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Adaptec driver into drivers/net/ethernet/adaptec/ and make
the necessary Kconfig and Makefile changes.

CC: Ion Badulescu <ionut@badula.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                   |    2 +-
 drivers/net/Kconfig                           |   14 ----------
 drivers/net/Makefile                          |    1 -
 drivers/net/ethernet/Kconfig                  |    1 +
 drivers/net/ethernet/Makefile                 |    1 +
 drivers/net/ethernet/adaptec/Kconfig          |   34 +++++++++++++++++++++++++
 drivers/net/ethernet/adaptec/Makefile         |    5 +++
 drivers/net/{ => ethernet/adaptec}/starfire.c |    0
 8 files changed, 42 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/adaptec/Kconfig
 create mode 100644 drivers/net/ethernet/adaptec/Makefile
 rename drivers/net/{ => ethernet/adaptec}/starfire.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index ca3ec84..8ca886e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6262,7 +6262,7 @@ F:	drivers/staging/xgifb/
 STARFIRE/DURALAN NETWORK DRIVER
 M:	Ion Badulescu <ionut@badula.org>
 S:	Odd Fixes
-F:	drivers/net/starfire*
+F:	drivers/net/ethernet/adaptec/starfire*
 
 SUN3/3X
 M:	Sam Creasey <sammy@sammy.net>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c7953ad..e6e10a4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -345,20 +345,6 @@ config NET_PCI
 	  will be asked for your specific card in the following questions. If
 	  you are unsure, say Y.
 
-config ADAPTEC_STARFIRE
-	tristate "Adaptec Starfire/DuraLAN support"
-	depends on NET_PCI && PCI
-	select CRC32
-	select MII
-	help
-	  Say Y here if you have an Adaptec Starfire (or DuraLAN) PCI network
-	  adapter. The DuraLAN chip is used on the 64 bit PCI boards from
-	  Adaptec e.g. the ANA-6922A. The older 32 bit boards use the tulip
-	  driver.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called starfire.  This is recommended.
-
 config NET_POCKET
 	bool "Pocket and portable adapters"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4d5af15..670e175 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -17,7 +17,6 @@ obj-$(CONFIG_PLIP) += plip.o
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
 obj-$(CONFIG_SKFP) += skfp/
-obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
 obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_SH_ETH) += sh_eth.o
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 1de8edc..8cd38c9 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -12,6 +12,7 @@ menuconfig ETHERNET
 if ETHERNET
 
 source "drivers/net/ethernet/3com/Kconfig"
+source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 3d5ed1f..50e040c 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
+obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
diff --git a/drivers/net/ethernet/adaptec/Kconfig b/drivers/net/ethernet/adaptec/Kconfig
new file mode 100644
index 0000000..5e9dbe9
--- /dev/null
+++ b/drivers/net/ethernet/adaptec/Kconfig
@@ -0,0 +1,34 @@
+#
+# Adaptec network device configuration
+#
+
+config NET_VENDOR_ADAPTEC
+	bool "Adaptec devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Adaptec cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_ADAPTEC
+
+config ADAPTEC_STARFIRE
+	tristate "Adaptec Starfire/DuraLAN support"
+	depends on PCI
+	select CRC32
+	select MII
+	---help---
+	  Say Y here if you have an Adaptec Starfire (or DuraLAN) PCI network
+	  adapter. The DuraLAN chip is used on the 64 bit PCI boards from
+	  Adaptec e.g. the ANA-6922A. The older 32 bit boards use the tulip
+	  driver.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called starfire.  This is recommended.
+
+endif # NET_VENDOR_ADAPTEC
diff --git a/drivers/net/ethernet/adaptec/Makefile b/drivers/net/ethernet/adaptec/Makefile
new file mode 100644
index 0000000..6c07b75
--- /dev/null
+++ b/drivers/net/ethernet/adaptec/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Adaptec network device drivers.
+#
+
+obj-$(CONFIG_ADAPTEC_STARFIRE) += starfire.o
diff --git a/drivers/net/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
similarity index 100%
rename from drivers/net/starfire.c
rename to drivers/net/ethernet/adaptec/starfire.c
-- 
1.7.6

