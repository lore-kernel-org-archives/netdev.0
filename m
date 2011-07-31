From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 37/71] eth16i: Move the Allied Telesis/Fujitsu drivers
Date: Sat, 30 Jul 2011 20:26:56 -0700
Message-ID: <1312082850-24914-38-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Shingo Fujimoto <shingo@flab.fujitsu.co.jp>,
	Yutaka Tamiya <tamy@flab.fujitsu.co.jp>,
	Rene Schmit <rene@bss.lu>, Mika Kuoppala <miku@iki.fi>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38846 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab1GaD2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:07 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Allied Telesis/Fujitsu drivers into drivers/net/ethernet/fujitsu/
and make the necessary Kconfig and Makefile changes.

CC: Shingo Fujimoto <shingo@flab.fujitsu.co.jp>
CC: Yutaka Tamiya <tamy@flab.fujitsu.co.jp>
CC: Rene Schmit <rene@bss.lu>
CC: Mika Kuoppala <miku@iki.fi>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |   40 ----------------
 drivers/net/Makefile                               |    3 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/fujitsu/Kconfig               |   49 ++++++++++++++++++++
 drivers/net/ethernet/fujitsu/Makefile              |    7 +++
 drivers/net/{ => ethernet/fujitsu}/at1700.c        |    0
 drivers/net/{ => ethernet/fujitsu}/eth16i.c        |    0
 .../net/{pcmcia => ethernet/fujitsu}/fmvj18x_cs.c  |    0
 drivers/net/pcmcia/Kconfig                         |   10 ----
 drivers/net/pcmcia/Makefile                        |    1 -
 12 files changed, 59 insertions(+), 55 deletions(-)
 create mode 100644 drivers/net/ethernet/fujitsu/Kconfig
 create mode 100644 drivers/net/ethernet/fujitsu/Makefile
 rename drivers/net/{ => ethernet/fujitsu}/at1700.c (100%)
 rename drivers/net/{ => ethernet/fujitsu}/eth16i.c (100%)
 rename drivers/net/{pcmcia => ethernet/fujitsu}/fmvj18x_cs.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 7acba11..9e4a6b0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2512,7 +2512,7 @@ F:	net/bridge/
 ETHERTEAM 16I DRIVER
 M:	Mika Kuoppala <miku@iki.fi>
 S:	Maintained
-F:	drivers/net/eth16i.c
+F:	drivers/net/ethernet/fujitsu/eth16i.c
 
 EXT2 FILE SYSTEM
 M:	Jan Kara <jack@suse.cz>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 349c6e1..91a498e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -428,18 +428,6 @@ config DNET
 	  To compile this driver as a module, choose M here: the module
 	  will be called dnet.
 
-config AT1700
-	tristate "AT1700/1720 support (EXPERIMENTAL)"
-	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called at1700.
-
 config HP100
 	tristate "HP 10/100VG PCLAN (ISA, EISA, PCI) support"
 	depends on ISA || EISA || PCI
@@ -451,34 +439,6 @@ config HP100
 	  To compile this driver as a module, choose M here. The module
 	  will be called hp100.
 
-config NET_ISA
-	bool "Other ISA cards"
-	depends on ISA
-	---help---
-	  If your network (Ethernet) card hasn't been mentioned yet and its
-	  bus system (that's the way the cards talks to the other components
-	  of your computer) is ISA (as opposed to EISA, VLB or PCI), say Y.
-	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  If unsure, say Y.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the remaining ISA network card questions. If you say Y, you will be
-	  asked for your specific card in the following questions.
-
-config ETH16I
-	tristate "ICL EtherTeam 16i/32 support"
-	depends on NET_ISA
-	help
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eth16i.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ad3b8a8..00a180c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -96,10 +96,7 @@ obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
-obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_CPMAC) += cpmac.o
-
-obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_SIM_NET) += mipsnet.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index bdc0df8..d3aff74 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -24,6 +24,7 @@ source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
+source "drivers/net/ethernet/fujitsu/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ac60ac9..b098c5e 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
+obj-$(CONFIG_NET_VENDOR_FUJITSU) += fujitsu/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
new file mode 100644
index 0000000..980c81c
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -0,0 +1,49 @@
+#
+# Fujitsu Network device configuration
+#
+
+config NET_VENDOR_FUJITSU
+	bool "Fujitsu devices"
+	depends on ISA || PCMCIA || (ISA || MCA_LEGACY) && EXPERIMENTAL
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  the questions about Fujitsu cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config AT1700
+	tristate "AT1700/1720 support (EXPERIMENTAL)"
+	depends on NET_VENDOR_FUJITSU && (ISA || MCA_LEGACY) && EXPERIMENTAL
+	select CRC32
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called at1700.
+
+config PCMCIA_FMVJ18X
+	tristate "Fujitsu FMV-J18x PCMCIA support"
+	depends on NET_VENDOR_FUJITSU && PCMCIA
+	select CRC32
+	---help---
+	  Say Y here if you intend to attach a Fujitsu FMV-J18x or compatible
+	  PCMCIA (PC-card) Ethernet card to your computer.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called fmvj18x_cs.  If unsure, say N.
+
+config ETH16I
+	tristate "ICL EtherTeam 16i/32 support"
+	depends on NET_VENDOR_FUJITSU && ISA
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called eth16i.
diff --git a/drivers/net/ethernet/fujitsu/Makefile b/drivers/net/ethernet/fujitsu/Makefile
new file mode 100644
index 0000000..2730ae6
--- /dev/null
+++ b/drivers/net/ethernet/fujitsu/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Fujitsu network device drivers.
+#
+
+obj-$(CONFIG_AT1700) += at1700.o
+obj-$(CONFIG_ETH16I) += eth16i.o
+obj-$(CONFIG_PCMCIA_FMVJ18X) += fmvj18x_cs.o
diff --git a/drivers/net/at1700.c b/drivers/net/ethernet/fujitsu/at1700.c
similarity index 100%
rename from drivers/net/at1700.c
rename to drivers/net/ethernet/fujitsu/at1700.c
diff --git a/drivers/net/eth16i.c b/drivers/net/ethernet/fujitsu/eth16i.c
similarity index 100%
rename from drivers/net/eth16i.c
rename to drivers/net/ethernet/fujitsu/eth16i.c
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
similarity index 100%
rename from drivers/net/pcmcia/fmvj18x_cs.c
rename to drivers/net/ethernet/fujitsu/fmvj18x_cs.c
diff --git a/drivers/net/pcmcia/Kconfig b/drivers/net/pcmcia/Kconfig
index f5a738f..80d291e 100644
--- a/drivers/net/pcmcia/Kconfig
+++ b/drivers/net/pcmcia/Kconfig
@@ -21,16 +21,6 @@ menuconfig NET_PCMCIA
 
 if NET_PCMCIA && PCMCIA
 
-config PCMCIA_FMVJ18X
-	tristate "Fujitsu FMV-J18x PCMCIA support"
-	select CRC32
-	help
-	  Say Y here if you intend to attach a Fujitsu FMV-J18x or compatible
-	  PCMCIA (PC-card) Ethernet card to your computer.
-
-	  To compile this driver as a module, choose M here: the module will be
-	  called fmvj18x_cs.  If unsure, say N.
-
 config PCMCIA_XIRC2PS
 	tristate "Xircom 16-bit PCMCIA support"
 	help
diff --git a/drivers/net/pcmcia/Makefile b/drivers/net/pcmcia/Makefile
index f9c9883..ccf5535 100644
--- a/drivers/net/pcmcia/Makefile
+++ b/drivers/net/pcmcia/Makefile
@@ -3,7 +3,6 @@
 #
 
 # 16-bit client drivers
-obj-$(CONFIG_PCMCIA_FMVJ18X)	+= fmvj18x_cs.o
 obj-$(CONFIG_PCMCIA_XIRC2PS)	+= xirc2ps_cs.o
 obj-$(CONFIG_ARCNET_COM20020_CS)+= com20020_cs.o
 
-- 
1.7.6

