From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 63/72] hp100/depca: Move the HP and Digital drivers
Date: Sat, 25 Jun 2011 06:59:14 -0700
Message-ID: <1309010363-22750-64-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Jaroslav Kysela <perex@perex.cz>,
	David Davies <davies@maniac.ultranet.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752355Ab1FYOAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:37 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the HP and Digital drivers into drivers/net/ethernet/ and
made the necessary Kconfig and Makefile changes.

CC: Jaroslav Kysela <perex@perex.cz>
CC: David Davies <davies@maniac.ultranet.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                        |    2 +-
 drivers/net/Kconfig                |   24 ------------------------
 drivers/net/Makefile               |    2 --
 drivers/net/ethernet/Kconfig       |   26 ++++++++++++++++++++++++++
 drivers/net/ethernet/Makefile      |    2 ++
 drivers/net/{ => ethernet}/depca.c |    0
 drivers/net/{ => ethernet}/depca.h |    0
 drivers/net/{ => ethernet}/hp100.c |    0
 drivers/net/{ => ethernet}/hp100.h |    0
 9 files changed, 29 insertions(+), 27 deletions(-)
 rename drivers/net/{ => ethernet}/depca.c (100%)
 rename drivers/net/{ => ethernet}/depca.h (100%)
 rename drivers/net/{ => ethernet}/hp100.c (100%)
 rename drivers/net/{ => ethernet}/hp100.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 432dbfc..f4a46ef 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3033,7 +3033,7 @@ F:	drivers/platform/x86/tc1100-wmi.c
 HP100:	Driver for HP 10/100 Mbit/s Voice Grade Network Adapter Series
 M:	Jaroslav Kysela <perex@perex.cz>
 S:	Maintained
-F:	drivers/net/hp100.*
+F:	drivers/net/ethernet/hp100.*
 
 HPET:	High Precision Event Timers driver
 M:	Clemens Ladisch <clemens@ladisch.de>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dcdf6e6..2af125b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -332,30 +332,6 @@ config AT1700
 	  To compile this driver as a module, choose M here. The module
 	  will be called at1700.
 
-config DEPCA
-	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
-	depends on ISA || EISA || MCA
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto> as well as
-	  <file:drivers/net/depca.c>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called depca.
-
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
index ae1b74d..13e2499 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -27,7 +27,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_HP100) += hp100.o
 
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
@@ -51,7 +50,6 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6ade848..bb4b87f 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -59,11 +59,37 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
+
+config DEPCA
+	tristate "DEPCA, DE10x, DE200, DE201, DE202, DE422 support"
+	depends on ISA || EISA || MCA
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto> as well as
+	  <file:drivers/net/depca.c>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called depca.
+
 source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
 source "drivers/net/ethernet/freescale/Kconfig"
+
+config HP100
+	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
+	depends on ISA || EISA || PCI
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called hp100.
+
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/icplus/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index eef91e6..37a5d1c 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -17,11 +17,13 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_DEPCA) += depca.o
 obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
 obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
+obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_IP1000) += icplus/
diff --git a/drivers/net/depca.c b/drivers/net/ethernet/depca.c
similarity index 100%
rename from drivers/net/depca.c
rename to drivers/net/ethernet/depca.c
diff --git a/drivers/net/depca.h b/drivers/net/ethernet/depca.h
similarity index 100%
rename from drivers/net/depca.h
rename to drivers/net/ethernet/depca.h
diff --git a/drivers/net/hp100.c b/drivers/net/ethernet/hp100.c
similarity index 100%
rename from drivers/net/hp100.c
rename to drivers/net/ethernet/hp100.c
diff --git a/drivers/net/hp100.h b/drivers/net/ethernet/hp100.h
similarity index 100%
rename from drivers/net/hp100.h
rename to drivers/net/ethernet/hp100.h
-- 
1.7.5.4

