From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/9] hippi: Move the HIPPI driver
Date: Tue, 23 Aug 2011 21:39:28 -0700
Message-ID: <1314160774-6980-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jes Sorensen <jes@wildopensource.com>,
	Jes Sorensen <jes@trained-monkey.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8760 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395Ab1HXEjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 00:39:42 -0400
In-Reply-To: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the HIPPI driver into drivers/net/hippi/ and make the
necessary Kconfig and Makefile changes.

CC: Jes Sorensen <jes@wildopensource.com>
CC: Jes Sorensen <jes@trained-monkey.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                       |    1 +
 drivers/net/Kconfig               |   32 ------------------------------
 drivers/net/Makefile              |    2 +-
 drivers/net/hippi/Kconfig         |   39 +++++++++++++++++++++++++++++++++++++
 drivers/net/hippi/Makefile        |    5 ++++
 drivers/net/{ => hippi}/rrunner.c |    0
 drivers/net/{ => hippi}/rrunner.h |    0
 7 files changed, 46 insertions(+), 33 deletions(-)
 create mode 100644 drivers/net/hippi/Kconfig
 create mode 100644 drivers/net/hippi/Makefile
 rename drivers/net/{ => hippi}/rrunner.c (100%)
 rename drivers/net/{ => hippi}/rrunner.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index c5ec925..194095a 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3049,6 +3049,7 @@ S:	Maintained
 F:	include/linux/hippidevice.h
 F:	include/linux/if_hippi.h
 F:	net/802/hippi.c
+F:	drivers/net/hippi/
 
 HOST AP DRIVER
 M:	Jouni Malinen <j@w1.fi>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c5e2a38..1d8fa95 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -272,38 +272,6 @@ config RIONET_RX_SIZE
 	depends on RIONET
 	default "128"
 
-config HIPPI
-	bool "HIPPI driver support (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && INET && PCI
-	help
-	  HIgh Performance Parallel Interface (HIPPI) is a 800Mbit/sec and
-	  1600Mbit/sec dual-simplex switched or point-to-point network. HIPPI
-	  can run over copper (25m) or fiber (300m on multi-mode or 10km on
-	  single-mode). HIPPI networks are commonly used for clusters and to
-	  connect to super computers. If you are connected to a HIPPI network
-	  and have a HIPPI network card in your computer that you want to use
-	  under Linux, say Y here (you must also remember to enable the driver
-	  for your HIPPI card below). Most people will say N here.
-
-config ROADRUNNER
-	tristate "Essential RoadRunner HIPPI PCI adapter support (EXPERIMENTAL)"
-	depends on HIPPI && PCI
-	help
-	  Say Y here if this is your PCI HIPPI network card.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called rrunner.  If unsure, say N.
-
-config ROADRUNNER_LARGE_RINGS
-	bool "Use large TX/RX rings (EXPERIMENTAL)"
-	depends on ROADRUNNER
-	help
-	  If you say Y here, the RoadRunner driver will preallocate up to 2 MB
-	  of additional memory to allow for fastest operation, both for
-	  transmitting and receiving. This memory cannot be used by any other
-	  kernel code or by user space programs. Say Y here only if you have
-	  the memory.
-
 config PLIP
 	tristate "PLIP (parallel port) support"
 	depends on PARPORT
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 9ce7c70..aff07bd 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -13,7 +13,6 @@ obj-$(CONFIG_VMXNET3) += vmxnet3/
 # link order important here
 #
 obj-$(CONFIG_PLIP) += plip.o
-obj-$(CONFIG_ROADRUNNER) += rrunner.o
 obj-$(CONFIG_RIONET) += rionet.o
 
 #
@@ -39,6 +38,7 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_FDDI) += fddi/
+obj-$(CONFIG_HIPPI) += hippi/
 onj-$(CONFIG_PPP) += ppp/
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
diff --git a/drivers/net/hippi/Kconfig b/drivers/net/hippi/Kconfig
new file mode 100644
index 0000000..7393eb7
--- /dev/null
+++ b/drivers/net/hippi/Kconfig
@@ -0,0 +1,39 @@
+#
+# HIPPI network device configuration
+#
+
+config HIPPI
+	bool "HIPPI driver support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && INET && PCI
+	---help---
+	  HIgh Performance Parallel Interface (HIPPI) is a 800Mbit/sec and
+	  1600Mbit/sec dual-simplex switched or point-to-point network. HIPPI
+	  can run over copper (25m) or fiber (300m on multi-mode or 10km on
+	  single-mode). HIPPI networks are commonly used for clusters and to
+	  connect to super computers. If you are connected to a HIPPI network
+	  and have a HIPPI network card in your computer that you want to use
+	  under Linux, say Y here (you must also remember to enable the driver
+	  for your HIPPI card below). Most people will say N here.
+
+if HIPPI
+
+config ROADRUNNER
+	tristate "Essential RoadRunner HIPPI PCI adapter support (EXPERIMENTAL)"
+	depends on PCI
+	---help---
+	  Say Y here if this is your PCI HIPPI network card.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called rrunner.  If unsure, say N.
+
+config ROADRUNNER_LARGE_RINGS
+	bool "Use large TX/RX rings (EXPERIMENTAL)"
+	depends on ROADRUNNER
+	---help---
+	  If you say Y here, the RoadRunner driver will preallocate up to 2 MB
+	  of additional memory to allow for fastest operation, both for
+	  transmitting and receiving. This memory cannot be used by any other
+	  kernel code or by user space programs. Say Y here only if you have
+	  the memory.
+
+endif /* HIPPI */
diff --git a/drivers/net/hippi/Makefile b/drivers/net/hippi/Makefile
new file mode 100644
index 0000000..b95d629
--- /dev/null
+++ b/drivers/net/hippi/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the HIPPI network device drivers.
+#
+
+obj-$(CONFIG_ROADRUNNER) += rrunner.o
diff --git a/drivers/net/rrunner.c b/drivers/net/hippi/rrunner.c
similarity index 100%
rename from drivers/net/rrunner.c
rename to drivers/net/hippi/rrunner.c
diff --git a/drivers/net/rrunner.h b/drivers/net/hippi/rrunner.h
similarity index 100%
rename from drivers/net/rrunner.h
rename to drivers/net/hippi/rrunner.h
-- 
1.7.6
