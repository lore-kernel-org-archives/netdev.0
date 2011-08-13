From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] hp100: Move the HP driver
Date: Sat, 13 Aug 2011 00:56:25 -0700
Message-ID: <1313222196-10074-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jaroslav Kysela <perex@perex.cz>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39635 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791Ab1HMH4j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 03:56:39 -0400
In-Reply-To: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the HP driver into drivers/net/ethernet/hp/ and
made the necessary Kconfig and Makefile changes.

CC: Jaroslav Kysela <perex@perex.cz>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                           |    2 +-
 drivers/net/Kconfig                   |   11 -----------
 drivers/net/Makefile                  |    1 -
 drivers/net/ethernet/Kconfig          |    1 +
 drivers/net/ethernet/Makefile         |    1 +
 drivers/net/ethernet/hp/Kconfig       |   31 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/hp/Makefile      |    5 +++++
 drivers/net/{ => ethernet/hp}/hp100.c |    0
 drivers/net/{ => ethernet/hp}/hp100.h |    0
 9 files changed, 39 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/ethernet/hp/Kconfig
 create mode 100644 drivers/net/ethernet/hp/Makefile
 rename drivers/net/{ => ethernet/hp}/hp100.c (100%)
 rename drivers/net/{ => ethernet/hp}/hp100.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 8ca886e..dfa4269 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3066,7 +3066,7 @@ F:	drivers/platform/x86/tc1100-wmi.c
 HP100:	Driver for HP 10/100 Mbit/s Voice Grade Network Adapter Series
 M:	Jaroslav Kysela <perex@perex.cz>
 S:	Maintained
-F:	drivers/net/hp100.*
+F:	drivers/net/ethernet/hp/hp100.*
 
 HPET:	High Precision Event Timers driver
 M:	Clemens Ladisch <clemens@ladisch.de>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index e6e10a4..39ba799 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -320,17 +320,6 @@ config DNET
 	  To compile this driver as a module, choose M here: the module
 	  will be called dnet.
 
-config HP100
-	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
-	depends on ISA || EISA || PCI
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called hp100.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 670e175..5b37149 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -26,7 +26,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_HP100) += hp100.o
 
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 8cd38c9..c1ce356 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -30,6 +30,7 @@ source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/fujitsu/Kconfig"
+source "drivers/net/ethernet/hp/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 50e040c..34e84fa 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_FUJITSU) += fujitsu/
+obj-$(CONFIG_NET_VENDOR_HP) += hp/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
diff --git a/drivers/net/ethernet/hp/Kconfig b/drivers/net/ethernet/hp/Kconfig
new file mode 100644
index 0000000..07b42e9
--- /dev/null
+++ b/drivers/net/ethernet/hp/Kconfig
@@ -0,0 +1,31 @@
+#
+# HP network device configuration
+#
+
+config NET_VENDOR_HP
+	bool "HP devices"
+	depends on ISA || EISA || PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about HP cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_HP
+
+config HP100
+	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
+	depends on (ISA || EISA || PCI)
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called hp100.
+
+endif # NET_VENDOR_HP
diff --git a/drivers/net/ethernet/hp/Makefile b/drivers/net/ethernet/hp/Makefile
new file mode 100644
index 0000000..20b6918
--- /dev/null
+++ b/drivers/net/ethernet/hp/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the HP network device drivers.
+#
+
+obj-$(CONFIG_HP100) += hp100.o
diff --git a/drivers/net/hp100.c b/drivers/net/ethernet/hp/hp100.c
similarity index 100%
rename from drivers/net/hp100.c
rename to drivers/net/ethernet/hp/hp100.c
diff --git a/drivers/net/hp100.h b/drivers/net/ethernet/hp/hp100.h
similarity index 100%
rename from drivers/net/hp100.h
rename to drivers/net/ethernet/hp/hp100.h
-- 
1.7.6

