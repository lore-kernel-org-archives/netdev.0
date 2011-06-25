From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 36/72] eepro/eexpress/eth16i/ewrk3/lp486e/seeq8005/znet: Move the ISA drivers
Date: Sat, 25 Jun 2011 06:58:47 -0700
Message-ID: <1309010363-22750-37-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Philip Blundell <philb@gnu.org>, Mika Kuoppala <miku@iki.fi>,
	<bao.ha@srs.gov>, <aris@cathedrallabs.org>,
	David Davies <davies@maniac.ultranet.com>, <aeb@cwi.nl>,
	Hamish Coleman <hamish@zot.apana.org.au>,
	Donald Becker <becker@scyld.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13697 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499Ab1FYOAa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:30 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the ISA drivers into drivers/net/ethernet/isa/ and make the
necessary Kconfig and Makefile changes.

CC: Philip Blundell <philb@gnu.org>
CC: Mika Kuoppala <miku@iki.fi>
CC: <bao.ha@srs.gov>
CC: <aris@cathedrallabs.org>
CC: David Davies <davies@maniac.ultranet.com>
CC: <aeb@cwi.nl>
CC: Hamish Coleman <hamish@zot.apana.org.au>
CC: Donald Becker <becker@scyld.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                               |    4 +-
 drivers/net/Kconfig                       |   98 ----------------------------
 drivers/net/Makefile                      |   10 ---
 drivers/net/ethernet/Kconfig              |    1 +
 drivers/net/ethernet/Makefile             |    1 +
 drivers/net/ethernet/isa/Kconfig          |  101 +++++++++++++++++++++++++++++
 drivers/net/ethernet/isa/Makefile         |   11 +++
 drivers/net/{ => ethernet/isa}/eepro.c    |    0
 drivers/net/{ => ethernet/isa}/eexpress.c |    0
 drivers/net/{ => ethernet/isa}/eexpress.h |    0
 drivers/net/{ => ethernet/isa}/eth16i.c   |    0
 drivers/net/{ => ethernet/isa}/ewrk3.c    |    0
 drivers/net/{ => ethernet/isa}/ewrk3.h    |    0
 drivers/net/{ => ethernet/isa}/lp486e.c   |    0
 drivers/net/{ => ethernet/isa}/seeq8005.c |    0
 drivers/net/{ => ethernet/isa}/seeq8005.h |    0
 drivers/net/{ => ethernet/isa}/znet.c     |    0
 17 files changed, 116 insertions(+), 110 deletions(-)
 create mode 100644 drivers/net/ethernet/isa/Kconfig
 create mode 100644 drivers/net/ethernet/isa/Makefile
 rename drivers/net/{ => ethernet/isa}/eepro.c (100%)
 rename drivers/net/{ => ethernet/isa}/eexpress.c (100%)
 rename drivers/net/{ => ethernet/isa}/eexpress.h (100%)
 rename drivers/net/{ => ethernet/isa}/eth16i.c (100%)
 rename drivers/net/{ => ethernet/isa}/ewrk3.c (100%)
 rename drivers/net/{ => ethernet/isa}/ewrk3.h (100%)
 rename drivers/net/{ => ethernet/isa}/lp486e.c (100%)
 rename drivers/net/{ => ethernet/isa}/seeq8005.c (100%)
 rename drivers/net/{ => ethernet/isa}/seeq8005.h (100%)
 rename drivers/net/{ => ethernet/isa}/znet.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 70df907..160ce2f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2477,7 +2477,7 @@ ETHEREXPRESS-16 NETWORK DRIVER
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/eexpress.*
+F:	drivers/net/ethernet/isa/eexpress.*
 
 ETHERNET BRIDGE
 M:	Stephen Hemminger <shemminger@linux-foundation.org>
@@ -2491,7 +2491,7 @@ F:	net/bridge/
 ETHERTEAM 16I DRIVER
 M:	Mika Kuoppala <miku@iki.fi>
 S:	Maintained
-F:	drivers/net/eth16i.c
+F:	drivers/net/ethernet/isa/eth16i.c
 
 EXT2 FILE SYSTEM
 M:	Jan Kara <jack@suse.cz>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index bb68fac..e352432 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -503,104 +503,6 @@ config HP100
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
-config EWRK3
-	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
-	depends on NET_ISA
-	select CRC32
-	---help---
-	  This driver supports the DE203, DE204 and DE205 network (Ethernet)
-	  cards. If this is for you, say Y and read
-	  <file:Documentation/networking/ewrk3.txt> in the kernel source as
-	  well as the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called ewrk3.
-
-config EEXPRESS
-	tristate "EtherExpress 16 support"
-	depends on NET_ISA
-	---help---
-	  If you have an EtherExpress16 network (Ethernet) card, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Note that the Intel
-	  EtherExpress16 card used to be regarded as a very poor choice
-	  because the driver was very unreliable. We now have a new driver
-	  that should do better.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eexpress.
-
-config EEXPRESS_PRO
-	tristate "EtherExpressPro support/EtherExpress 10 (i82595) support"
-	depends on NET_ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y. This
-	  driver supports Intel i82595{FX,TX} based boards. Note however
-	  that the EtherExpress PRO/100 Ethernet card has its own separate
-	  driver.  Please read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eepro.
-
-config LP486E
-	tristate "LP486E on board Ethernet"
-	depends on NET_ISA
-	help
-	  Say Y here to support the 82596-based on-board Ethernet controller
-	  for the Panther motherboard, which is one of the two shipped in the
-	  Intel Professional Workstation.
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
-config ZNET
-	tristate "Zenith Z-Note support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL && ISA_DMA_API
-	help
-	  The Zenith Z-Note notebook computer has a built-in network
-	  (Ethernet) card, and this is the Linux driver for it. Note that the
-	  IBM Thinkpad 300 is compatible with the Z-Note and is also supported
-	  by this driver. Read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-config SEEQ8005
-	tristate "SEEQ8005 support (EXPERIMENTAL)"
-	depends on NET_ISA && EXPERIMENTAL
-	help
-	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
-	  is for you, read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called seeq8005.
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 47decf6..eee3091 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -59,7 +59,6 @@ obj-$(CONFIG_SH_ETH) += sh_eth.o
 obj-$(CONFIG_SUNDANCE) += sundance.o
 obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
-obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
 obj-$(CONFIG_FEC) += fec.o
@@ -98,23 +97,14 @@ obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
 obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_EEXPRESS) += eexpress.o
-obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
-obj-$(CONFIG_ZNET) += znet.o
 obj-$(CONFIG_CPMAC) += cpmac.o
 obj-$(CONFIG_DEPCA) += depca.o
-obj-$(CONFIG_EWRK3) += ewrk3.o
 obj-$(CONFIG_APRICOT) += 82596.o
 obj-$(CONFIG_LASI_82596) += lasi_82596.o
 obj-$(CONFIG_SNI_82596) += sni_82596.o
 obj-$(CONFIG_MVME16x_NET) += 82596.o
 obj-$(CONFIG_BVME6000_NET) += 82596.o
 obj-$(CONFIG_SC92031) += sc92031.o
-
-# This is also a 82596 and should probably be merged
-obj-$(CONFIG_LP486E) += lp486e.o
-
-obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_KORINA) += korina.o
 obj-$(CONFIG_MIPS_AU1X00_ENET) += au1000_eth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index be94115..c584ba7 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -30,6 +30,7 @@ source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/myricom/Kconfig"
 source "drivers/net/ethernet/natsemi/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
+source "drivers/net/ethernet/isa/Kconfig"
 source "drivers/net/ethernet/oki/Kconfig"
 
 config PASEMI_MAC
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index e07d818..1d8dba7 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -21,6 +21,7 @@ obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_NET_ISA) += isa/
 obj-$(CONFIG_NET_VENDOR_OKI) += oki/
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
diff --git a/drivers/net/ethernet/isa/Kconfig b/drivers/net/ethernet/isa/Kconfig
new file mode 100644
index 0000000..a84bcf3
--- /dev/null
+++ b/drivers/net/ethernet/isa/Kconfig
@@ -0,0 +1,101 @@
+#
+# ISA Network device configuration
+#
+
+config NET_ISA
+	bool "Other ISA devices"
+	depends on ISA
+	---help---
+	  If your network (Ethernet) card hasn't been mentioned yet and its
+	  bus system (that's the way the cards talks to the other components
+	  of your computer) is ISA (as opposed to EISA, VLB or PCI), say Y.
+	  Make sure you know the name of your card. Read the Ethernet-HOWTO,
+	  available from <http://www.tldp.org/docs.html#howto>.
+
+	  If unsure, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the remaining ISA network card questions. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+config EEXPRESS
+	tristate "EtherExpress 16 support"
+	depends on NET_ISA
+	---help---
+	  If you have an EtherExpress16 network (Ethernet) card, say Y and
+	  read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.  Note that the Intel
+	  EtherExpress16 card used to be regarded as a very poor choice
+	  because the driver was very unreliable. We now have a new driver
+	  that should do better.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called eexpress.
+
+config EEXPRESS_PRO
+	tristate "EtherExpressPro support/EtherExpress 10 (i82595) support"
+	depends on NET_ISA
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y. This
+	  driver supports Intel i82595{FX,TX} based boards. Note however
+	  that the EtherExpress PRO/100 Ethernet card has its own separate
+	  driver.  Please read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called eepro.
+
+config EWRK3
+	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
+	depends on NET_ISA
+	select CRC32
+	---help---
+	  This driver supports the DE203, DE204 and DE205 network (Ethernet)
+	  cards. If this is for you, say Y and read
+	  <file:Documentation/networking/ewrk3.txt> in the kernel source as
+	  well as the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called ewrk3.
+
+config ETH16I
+	tristate "ICL EtherTeam 16i/32 support"
+	depends on NET_ISA
+	---help---
+	  If you have a network (Ethernet) card of this type, say Y and read
+	  the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called eth16i.
+
+config LP486E
+	tristate "LP486E on board Ethernet"
+	depends on NET_ISA
+	---help---
+	  Say Y here to support the 82596-based on-board Ethernet controller
+	  for the Panther motherboard, which is one of the two shipped in the
+	  Intel Professional Workstation.
+
+config SEEQ8005
+	tristate "SEEQ8005 support (EXPERIMENTAL)"
+	depends on NET_ISA && EXPERIMENTAL
+	---help---
+	  This is a driver for the SEEQ 8005 network (Ethernet) card.  If this
+	  is for you, read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called seeq8005.
+
+config ZNET
+	tristate "Zenith Z-Note support (EXPERIMENTAL)"
+	depends on NET_ISA && EXPERIMENTAL && ISA_DMA_API
+	---help---
+	  The Zenith Z-Note notebook computer has a built-in network
+	  (Ethernet) card, and this is the Linux driver for it. Note that the
+	  IBM Thinkpad 300 is compatible with the Z-Note and is also supported
+	  by this driver. Read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
diff --git a/drivers/net/ethernet/isa/Makefile b/drivers/net/ethernet/isa/Makefile
new file mode 100644
index 0000000..8901588
--- /dev/null
+++ b/drivers/net/ethernet/isa/Makefile
@@ -0,0 +1,11 @@
+#
+# Makefile for the ISA network device drivers.
+#
+
+obj-$(CONFIG_EEXPRESS) += eexpress.o
+obj-$(CONFIG_EEXPRESS_PRO) += eepro.o
+obj-$(CONFIG_ETH16I) += eth16i.o
+obj-$(CONFIG_EWRK3) += ewrk3.o
+obj-$(CONFIG_LP486E) += lp486e.o
+obj-$(CONFIG_SEEQ8005) += seeq8005.o
+obj-$(CONFIG_ZNET) += znet.o
diff --git a/drivers/net/eepro.c b/drivers/net/ethernet/isa/eepro.c
similarity index 100%
rename from drivers/net/eepro.c
rename to drivers/net/ethernet/isa/eepro.c
diff --git a/drivers/net/eexpress.c b/drivers/net/ethernet/isa/eexpress.c
similarity index 100%
rename from drivers/net/eexpress.c
rename to drivers/net/ethernet/isa/eexpress.c
diff --git a/drivers/net/eexpress.h b/drivers/net/ethernet/isa/eexpress.h
similarity index 100%
rename from drivers/net/eexpress.h
rename to drivers/net/ethernet/isa/eexpress.h
diff --git a/drivers/net/eth16i.c b/drivers/net/ethernet/isa/eth16i.c
similarity index 100%
rename from drivers/net/eth16i.c
rename to drivers/net/ethernet/isa/eth16i.c
diff --git a/drivers/net/ewrk3.c b/drivers/net/ethernet/isa/ewrk3.c
similarity index 100%
rename from drivers/net/ewrk3.c
rename to drivers/net/ethernet/isa/ewrk3.c
diff --git a/drivers/net/ewrk3.h b/drivers/net/ethernet/isa/ewrk3.h
similarity index 100%
rename from drivers/net/ewrk3.h
rename to drivers/net/ethernet/isa/ewrk3.h
diff --git a/drivers/net/lp486e.c b/drivers/net/ethernet/isa/lp486e.c
similarity index 100%
rename from drivers/net/lp486e.c
rename to drivers/net/ethernet/isa/lp486e.c
diff --git a/drivers/net/seeq8005.c b/drivers/net/ethernet/isa/seeq8005.c
similarity index 100%
rename from drivers/net/seeq8005.c
rename to drivers/net/ethernet/isa/seeq8005.c
diff --git a/drivers/net/seeq8005.h b/drivers/net/ethernet/isa/seeq8005.h
similarity index 100%
rename from drivers/net/seeq8005.h
rename to drivers/net/ethernet/isa/seeq8005.h
diff --git a/drivers/net/znet.c b/drivers/net/ethernet/isa/znet.c
similarity index 100%
rename from drivers/net/znet.c
rename to drivers/net/ethernet/isa/znet.c
-- 
1.7.5.4

