From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/10] ewrk3/tulip: Move the DEC - Tulip drivers
Date: Fri, 12 Aug 2011 00:32:55 -0700
Message-ID: <1313134384-7287-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Tobias Ringstrom <tori@unhappy.mine.nu>,
	Grant Grundler <grundler@parisc-linux.org>,
	David Davies <davies@maniac.ultranet.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58632 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348Ab1HLHdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 03:33:08 -0400
In-Reply-To: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the DEC - Tulip driver into drivers/net/ethernet/dec/tulip/
and make the necessary Kconfig and Makefile changes.

The Digital Equioment (DEC) driver ewrk3 was moved into
drivers/net/ethernet/dec/ and the remaining drivers (Tulip)
were moved into drivers/net/ethernet/dec/tulip/

CC: Tobias Ringstrom <tori@unhappy.mine.nu>
CC: Grant Grundler <grundler@parisc-linux.org>
CC: David Davies <davies@maniac.ultranet.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Grant Grundler <grundler@parisc-linux.org>
---
 MAINTAINERS                                        |    4 +-
 drivers/net/Kconfig                                |   16 ---------
 drivers/net/Makefile                               |    2 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/dec/Kconfig                   |   36 ++++++++++++++++++++
 drivers/net/ethernet/dec/Makefile                  |    6 +++
 drivers/net/{ => ethernet/dec}/ewrk3.c             |    0
 drivers/net/{ => ethernet/dec}/ewrk3.h             |    0
 drivers/net/{ => ethernet/dec}/tulip/21142.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/Kconfig       |   20 +++++-----
 drivers/net/{ => ethernet/dec}/tulip/Makefile      |    0
 drivers/net/{ => ethernet/dec}/tulip/de2104x.c     |    0
 drivers/net/{ => ethernet/dec}/tulip/de4x5.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/de4x5.h       |    0
 drivers/net/{ => ethernet/dec}/tulip/dmfe.c        |    0
 drivers/net/{ => ethernet/dec}/tulip/eeprom.c      |    0
 drivers/net/{ => ethernet/dec}/tulip/interrupt.c   |    0
 drivers/net/{ => ethernet/dec}/tulip/media.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/pnic.c        |    0
 drivers/net/{ => ethernet/dec}/tulip/pnic2.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/timer.c       |    0
 drivers/net/{ => ethernet/dec}/tulip/tulip.h       |    0
 drivers/net/{ => ethernet/dec}/tulip/tulip_core.c  |    0
 drivers/net/{ => ethernet/dec}/tulip/uli526x.c     |    0
 drivers/net/{ => ethernet/dec}/tulip/winbond-840.c |    0
 drivers/net/{ => ethernet/dec}/tulip/xircom_cb.c   |    0
 27 files changed, 56 insertions(+), 30 deletions(-)
 create mode 100644 drivers/net/ethernet/dec/Kconfig
 create mode 100644 drivers/net/ethernet/dec/Makefile
 rename drivers/net/{ => ethernet/dec}/ewrk3.c (100%)
 rename drivers/net/{ => ethernet/dec}/ewrk3.h (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/21142.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/Kconfig (96%)
 rename drivers/net/{ => ethernet/dec}/tulip/Makefile (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/de2104x.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/de4x5.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/de4x5.h (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/dmfe.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/eeprom.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/interrupt.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/media.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/pnic.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/pnic2.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/timer.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/tulip.h (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/tulip_core.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/uli526x.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/winbond-840.c (100%)
 rename drivers/net/{ => ethernet/dec}/tulip/xircom_cb.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 26fa497..fbafbb6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2073,7 +2073,7 @@ DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
 L:	netdev@vger.kernel.org
 S:	Orphan
 F:	Documentation/networking/dmfe.txt
-F:	drivers/net/tulip/dmfe.c
+F:	drivers/net/ethernet/tulip/dmfe.c
 
 DC390/AM53C974 SCSI driver
 M:	Kurt Garloff <garloff@suse.de>
@@ -6514,7 +6514,7 @@ TULIP NETWORK DRIVERS
 M:	Grant Grundler <grundler@parisc-linux.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/tulip/
+F:	drivers/net/ethernet/tulip/
 
 TUN/TAP driver
 M:	Maxim Krasnyansky <maxk@qualcomm.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c8779c1..0cb136c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -452,8 +452,6 @@ config DNET
 	  To compile this driver as a module, choose M here: the module
 	  will be called dnet.
 
-source "drivers/net/tulip/Kconfig"
-
 config AT1700
 	tristate "AT1700/1720 support (EXPERIMENTAL)"
 	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
@@ -494,20 +492,6 @@ config NET_ISA
 	  the remaining ISA network card questions. If you say Y, you will be
 	  asked for your specific card in the following questions.
 
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
 config ETH16I
 	tristate "ICL EtherTeam 16i/32 support"
 	depends on NET_ISA
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index db888b0..8a56733 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -106,7 +106,6 @@ obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_CPMAC) += cpmac.o
-obj-$(CONFIG_EWRK3) += ewrk3.o
 
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_EQUALIZER) += eql.o
@@ -147,7 +146,6 @@ obj-$(CONFIG_USB_IPHETH)        += usb/
 obj-$(CONFIG_USB_CDC_PHONET)   += usb/
 
 obj-$(CONFIG_WLAN) += wireless/
-obj-$(CONFIG_NET_TULIP) += tulip/
 obj-$(CONFIG_HAMRADIO) += hamradio/
 obj-$(CONFIG_IRDA) += irda/
 obj-$(CONFIG_ETRAX_ETHERNET) += cris/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 9410f20..ed42850 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -19,6 +19,7 @@ source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
+source "drivers/net/ethernet/dec/Kconfig"
 source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 5d89fd9..3de8249 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
+obj-$(CONFIG_NET_VENDOR_DEC) += dec/
 obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
diff --git a/drivers/net/ethernet/dec/Kconfig b/drivers/net/ethernet/dec/Kconfig
new file mode 100644
index 0000000..40e8df9
--- /dev/null
+++ b/drivers/net/ethernet/dec/Kconfig
@@ -0,0 +1,36 @@
+#
+# Digital Equipment Inc network device configuration
+#
+
+config NET_VENDOR_DEC
+	bool "Digital Equipment devices"
+	depends on PCI || EISA || CARDBUS
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about DEC cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+if NET_VENDOR_DEC
+
+config EWRK3
+	tristate "EtherWORKS 3 (DE203, DE204, DE205) support"
+	depends on ISA
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
+source "drivers/net/ethernet/dec/tulip/Kconfig"
+
+endif # NET_VENDOR_DEC
diff --git a/drivers/net/ethernet/dec/Makefile b/drivers/net/ethernet/dec/Makefile
new file mode 100644
index 0000000..1b01ed8
--- /dev/null
+++ b/drivers/net/ethernet/dec/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Digital Equipment Inc. network device drivers.
+#
+
+obj-$(CONFIG_EWRK3) += ewrk3.o
+obj-$(CONFIG_NET_TULIP) += tulip/
diff --git a/drivers/net/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
similarity index 100%
rename from drivers/net/ewrk3.c
rename to drivers/net/ethernet/dec/ewrk3.c
diff --git a/drivers/net/ewrk3.h b/drivers/net/ethernet/dec/ewrk3.h
similarity index 100%
rename from drivers/net/ewrk3.h
rename to drivers/net/ethernet/dec/ewrk3.h
diff --git a/drivers/net/tulip/21142.c b/drivers/net/ethernet/dec/tulip/21142.c
similarity index 100%
rename from drivers/net/tulip/21142.c
rename to drivers/net/ethernet/dec/tulip/21142.c
diff --git a/drivers/net/tulip/Kconfig b/drivers/net/ethernet/dec/tulip/Kconfig
similarity index 96%
rename from drivers/net/tulip/Kconfig
rename to drivers/net/ethernet/dec/tulip/Kconfig
index 1f8d4a8..f6af772 100644
--- a/drivers/net/tulip/Kconfig
+++ b/drivers/net/ethernet/dec/tulip/Kconfig
@@ -2,10 +2,10 @@
 # Tulip family network device configuration
 #
 
-menuconfig NET_TULIP
-	bool "\"Tulip\" family network device support"
-	depends on PCI || EISA || CARDBUS
-	help
+config NET_TULIP
+	bool "DEC - Tulip devices"
+	depends on (PCI || EISA || CARDBUS)
+	---help---
 	  This selects the "Tulip" family of EISA/PCI network cards.
 
 if NET_TULIP
@@ -32,7 +32,7 @@ config DE2104X_DSL
 	depends on DE2104X
 	range 0 31
 	default 0
-	help
+	---help---
 	  Setting this value allows to align ring buffer descriptors into their
 	  own cache lines. Value of 4 corresponds to the typical 32 byte line
 	  (the descriptor is 16 bytes). This is necessary on systems that lack
@@ -59,7 +59,7 @@ config TULIP
 config TULIP_MWI
 	bool "New bus configuration (EXPERIMENTAL)"
 	depends on TULIP && EXPERIMENTAL
-	help
+	---help---
 	  This configures your Tulip card specifically for the card and
 	  system cache line size type you are using.
 
@@ -70,7 +70,7 @@ config TULIP_MWI
 config TULIP_MMIO
 	bool "Use PCI shared mem for NIC registers"
 	depends on TULIP
-	help
+	---help---
 	  Use PCI shared memory for the NIC registers, rather than going through
 	  the Tulip's PIO (programmed I/O ports).  Faster, but could produce
 	  obscure bugs if your mainboard has memory controller timing issues.
@@ -79,7 +79,7 @@ config TULIP_MMIO
 config TULIP_NAPI
 	bool "Use RX polling (NAPI)"
 	depends on TULIP
-	help
+	---help---
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
 	  when the driver is receiving lots of packets from the card. It is
 	  still somewhat experimental and thus not yet enabled by default.
@@ -107,7 +107,7 @@ config TULIP_DM910X
 
 config DE4X5
 	tristate "Generic DECchip & DIGITAL EtherWORKS PCI/EISA"
-	depends on PCI || EISA
+	depends on (PCI || EISA)
 	select CRC32
 	---help---
 	  This is support for the DIGITAL series of PCI/EISA Ethernet cards.
@@ -126,7 +126,7 @@ config WINBOND_840
 	depends on PCI
 	select CRC32
 	select MII
-	help
+	---help---
 	  This driver is for the Winbond W89c840 chip.  It also works with 
 	  the TX9882 chip on the Compex RL100-ATX board.
 	  More specific information and updates are available from
diff --git a/drivers/net/tulip/Makefile b/drivers/net/ethernet/dec/tulip/Makefile
similarity index 100%
rename from drivers/net/tulip/Makefile
rename to drivers/net/ethernet/dec/tulip/Makefile
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
similarity index 100%
rename from drivers/net/tulip/de2104x.c
rename to drivers/net/ethernet/dec/tulip/de2104x.c
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
similarity index 100%
rename from drivers/net/tulip/de4x5.c
rename to drivers/net/ethernet/dec/tulip/de4x5.c
diff --git a/drivers/net/tulip/de4x5.h b/drivers/net/ethernet/dec/tulip/de4x5.h
similarity index 100%
rename from drivers/net/tulip/de4x5.h
rename to drivers/net/ethernet/dec/tulip/de4x5.h
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
similarity index 100%
rename from drivers/net/tulip/dmfe.c
rename to drivers/net/ethernet/dec/tulip/dmfe.c
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/ethernet/dec/tulip/eeprom.c
similarity index 100%
rename from drivers/net/tulip/eeprom.c
rename to drivers/net/ethernet/dec/tulip/eeprom.c
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
similarity index 100%
rename from drivers/net/tulip/interrupt.c
rename to drivers/net/ethernet/dec/tulip/interrupt.c
diff --git a/drivers/net/tulip/media.c b/drivers/net/ethernet/dec/tulip/media.c
similarity index 100%
rename from drivers/net/tulip/media.c
rename to drivers/net/ethernet/dec/tulip/media.c
diff --git a/drivers/net/tulip/pnic.c b/drivers/net/ethernet/dec/tulip/pnic.c
similarity index 100%
rename from drivers/net/tulip/pnic.c
rename to drivers/net/ethernet/dec/tulip/pnic.c
diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/ethernet/dec/tulip/pnic2.c
similarity index 100%
rename from drivers/net/tulip/pnic2.c
rename to drivers/net/ethernet/dec/tulip/pnic2.c
diff --git a/drivers/net/tulip/timer.c b/drivers/net/ethernet/dec/tulip/timer.c
similarity index 100%
rename from drivers/net/tulip/timer.c
rename to drivers/net/ethernet/dec/tulip/timer.c
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/ethernet/dec/tulip/tulip.h
similarity index 100%
rename from drivers/net/tulip/tulip.h
rename to drivers/net/ethernet/dec/tulip/tulip.h
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
similarity index 100%
rename from drivers/net/tulip/tulip_core.c
rename to drivers/net/ethernet/dec/tulip/tulip_core.c
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
similarity index 100%
rename from drivers/net/tulip/uli526x.c
rename to drivers/net/ethernet/dec/tulip/uli526x.c
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
similarity index 100%
rename from drivers/net/tulip/winbond-840.c
rename to drivers/net/ethernet/dec/tulip/winbond-840.c
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
similarity index 100%
rename from drivers/net/tulip/xircom_cb.c
rename to drivers/net/ethernet/dec/tulip/xircom_cb.c
-- 
1.7.6

