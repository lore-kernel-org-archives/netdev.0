From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/12] acenic: Move the Alteon driver
Date: Sat, 13 Aug 2011 00:56:35 -0700
Message-ID: <1313222196-10074-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jes Sorensen <jes@trained-monkey.org>,
	Alan Cox <alan@linux.intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43690 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770Ab1HMH4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 03:56:45 -0400
In-Reply-To: <1313222196-10074-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on feedback from Alan Cox, the acenic driver moved to
drivers/net/ethernet/alteon/ and made the necessary Kconfig and
Makefile changes.

CC: Jes Sorensen <jes@trained-monkey.org>
CC: Alan Cox <alan@linux.intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                    |    2 +-
 drivers/net/ethernet/3com/Kconfig              |   27 --------------
 drivers/net/ethernet/3com/Makefile             |    1 -
 drivers/net/ethernet/Kconfig                   |    1 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/ethernet/alteon/Kconfig            |   47 ++++++++++++++++++++++++
 drivers/net/ethernet/alteon/Makefile           |    5 +++
 drivers/net/ethernet/{3com => alteon}/acenic.c |    0
 drivers/net/ethernet/{3com => alteon}/acenic.h |    0
 9 files changed, 55 insertions(+), 29 deletions(-)
 create mode 100644 drivers/net/ethernet/alteon/Kconfig
 create mode 100644 drivers/net/ethernet/alteon/Makefile
 rename drivers/net/ethernet/{3com => alteon}/acenic.c (100%)
 rename drivers/net/ethernet/{3com => alteon}/acenic.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 3d8a6a6..d374c6f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -213,7 +213,7 @@ ACENIC DRIVER
 M:	Jes Sorensen <jes@trained-monkey.org>
 L:	linux-acenic@sunsite.dk
 S:	Maintained
-F:	drivers/net/ethernet/3com/acenic*
+F:	drivers/net/ethernet/alteon/acenic*
 
 ACER ASPIRE ONE TEMPERATURE AND FAN DRIVER
 M:	Peter Feuerer <peter@piie.net>
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index 497f038..65cc129 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -117,31 +117,4 @@ config TYPHOON
 	  To compile this driver as a module, choose M here. The module
 	  will be called typhoon.
 
-config ACENIC
-	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
-	depends on PCI
-	---help---
-	  Say Y here if you have an Alteon AceNIC, 3Com 3C985(B), NetGear
-	  GA620, SGI Gigabit or Farallon PN9000-SX PCI Gigabit Ethernet
-	  adapter. The driver allows for using the Jumbo Frame option (9000
-	  bytes/frame) however it requires that your switches can handle this
-	  as well. To enable Jumbo Frames, add `mtu 9000' to your ifconfig
-	  line.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called acenic.
-
-config ACENIC_OMIT_TIGON_I
-	bool "Omit support for old Tigon I based AceNICs"
-	depends on ACENIC
-	---help---
-	  Say Y here if you only have Tigon II based AceNICs and want to leave
-	  out support for the older Tigon I based cards which are no longer
-	  being sold (ie. the original Alteon AceNIC and 3Com 3C985 (non B
-	  version)).  This will reduce the size of the driver object by
-	  app. 100KB.  If you are not sure whether your card is a Tigon I or a
-	  Tigon II, say N here.
-
-	  The safe and default value for this is N.
-
 endif # NET_VENDOR_3COM
diff --git a/drivers/net/ethernet/3com/Makefile b/drivers/net/ethernet/3com/Makefile
index 96d1d60..1e5382a 100644
--- a/drivers/net/ethernet/3com/Makefile
+++ b/drivers/net/ethernet/3com/Makefile
@@ -8,5 +8,4 @@ obj-$(CONFIG_3C515) += 3c515.o
 obj-$(CONFIG_PCMCIA_3C589) += 3c589_cs.o
 obj-$(CONFIG_PCMCIA_3C574) += 3c574_cs.o
 obj-$(CONFIG_VORTEX) += 3c59x.o
-obj-$(CONFIG_ACENIC) += acenic.o
 obj-$(CONFIG_TYPHOON) += typhoon.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index cff6ef5..1f5a32d 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -14,6 +14,7 @@ if ETHERNET
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
+source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
 source "drivers/net/ethernet/atheros/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 986def7..c53ad3a 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_ADAPTEC) += adaptec/
 obj-$(CONFIG_GRETH) += aeroflex/
+obj-$(CONFIG_NET_VENDOR_ALTEON) += alteon/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) += apple/
 obj-$(CONFIG_NET_VENDOR_ATHEROS) += atheros/
diff --git a/drivers/net/ethernet/alteon/Kconfig b/drivers/net/ethernet/alteon/Kconfig
new file mode 100644
index 0000000..68862e4
--- /dev/null
+++ b/drivers/net/ethernet/alteon/Kconfig
@@ -0,0 +1,47 @@
+#
+# Alteon network device configuration
+#
+
+config NET_VENDOR_ALTEON
+	bool "Alteon devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Alteon cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_ALTEON
+
+config ACENIC
+	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
+	depends on PCI
+	---help---
+	  Say Y here if you have an Alteon AceNIC, 3Com 3C985(B), NetGear
+	  GA620, SGI Gigabit or Farallon PN9000-SX PCI Gigabit Ethernet
+	  adapter. The driver allows for using the Jumbo Frame option (9000
+	  bytes/frame) however it requires that your switches can handle this
+	  as well. To enable Jumbo Frames, add `mtu 9000' to your ifconfig
+	  line.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called acenic.
+
+config ACENIC_OMIT_TIGON_I
+	bool "Omit support for old Tigon I based AceNICs"
+	depends on ACENIC
+	---help---
+	  Say Y here if you only have Tigon II based AceNICs and want to leave
+	  out support for the older Tigon I based cards which are no longer
+	  being sold (ie. the original Alteon AceNIC and 3Com 3C985 (non B
+	  version)).  This will reduce the size of the driver object by
+	  app. 100KB.  If you are not sure whether your card is a Tigon I or a
+	  Tigon II, say N here.
+
+	  The safe and default value for this is N.
+
+endif # NET_VENDOR_ALTEON
diff --git a/drivers/net/ethernet/alteon/Makefile b/drivers/net/ethernet/alteon/Makefile
new file mode 100644
index 0000000..a2ca173
--- /dev/null
+++ b/drivers/net/ethernet/alteon/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Alteon network device drivers.
+#
+
+obj-$(CONFIG_ACENIC) += acenic.o
diff --git a/drivers/net/ethernet/3com/acenic.c b/drivers/net/ethernet/alteon/acenic.c
similarity index 100%
rename from drivers/net/ethernet/3com/acenic.c
rename to drivers/net/ethernet/alteon/acenic.c
diff --git a/drivers/net/ethernet/3com/acenic.h b/drivers/net/ethernet/alteon/acenic.h
similarity index 100%
rename from drivers/net/ethernet/3com/acenic.h
rename to drivers/net/ethernet/alteon/acenic.h
-- 
1.7.6

