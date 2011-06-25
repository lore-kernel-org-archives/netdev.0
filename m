From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 31/72] tulip: Move the tulip drivers
Date: Sat, 25 Jun 2011 06:58:42 -0700
Message-ID: <1309010363-22750-32-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Tobias Ringstrom <tori@unhappy.mine.nu>,
	Grant Grundler <grundler@parisc-linux.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37770 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514Ab1FYOAD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:03 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the tulip driver into drivers/net/ethernet/tulip/ and make
the necessary Kconfig and Makefile changes.

CC: Tobias Ringstrom <tori@unhappy.mine.nu>
CC: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                    |    4 +-
 drivers/net/Kconfig                            |    2 -
 drivers/net/Makefile                           |    1 -
 drivers/net/ethernet/Kconfig                   |    2 +
 drivers/net/ethernet/Makefile                  |    1 +
 drivers/net/{ => ethernet}/tulip/21142.c       |    0
 drivers/net/{ => ethernet}/tulip/Kconfig       |   34 ++++++++++-------------
 drivers/net/{ => ethernet}/tulip/Makefile      |    0
 drivers/net/{ => ethernet}/tulip/de2104x.c     |    0
 drivers/net/{ => ethernet}/tulip/de4x5.c       |    0
 drivers/net/{ => ethernet}/tulip/de4x5.h       |    0
 drivers/net/{ => ethernet}/tulip/dmfe.c        |    0
 drivers/net/{ => ethernet}/tulip/eeprom.c      |    0
 drivers/net/{ => ethernet}/tulip/interrupt.c   |    0
 drivers/net/{ => ethernet}/tulip/media.c       |    0
 drivers/net/{ => ethernet}/tulip/pnic.c        |    0
 drivers/net/{ => ethernet}/tulip/pnic2.c       |    0
 drivers/net/{ => ethernet}/tulip/timer.c       |    0
 drivers/net/{ => ethernet}/tulip/tulip.h       |    0
 drivers/net/{ => ethernet}/tulip/tulip_core.c  |    0
 drivers/net/{ => ethernet}/tulip/uli526x.c     |    0
 drivers/net/{ => ethernet}/tulip/winbond-840.c |    0
 drivers/net/{ => ethernet}/tulip/xircom_cb.c   |    0
 23 files changed, 20 insertions(+), 24 deletions(-)
 rename drivers/net/{ => ethernet}/tulip/21142.c (100%)
 rename drivers/net/{ => ethernet}/tulip/Kconfig (93%)
 rename drivers/net/{ => ethernet}/tulip/Makefile (100%)
 rename drivers/net/{ => ethernet}/tulip/de2104x.c (100%)
 rename drivers/net/{ => ethernet}/tulip/de4x5.c (100%)
 rename drivers/net/{ => ethernet}/tulip/de4x5.h (100%)
 rename drivers/net/{ => ethernet}/tulip/dmfe.c (100%)
 rename drivers/net/{ => ethernet}/tulip/eeprom.c (100%)
 rename drivers/net/{ => ethernet}/tulip/interrupt.c (100%)
 rename drivers/net/{ => ethernet}/tulip/media.c (100%)
 rename drivers/net/{ => ethernet}/tulip/pnic.c (100%)
 rename drivers/net/{ => ethernet}/tulip/pnic2.c (100%)
 rename drivers/net/{ => ethernet}/tulip/timer.c (100%)
 rename drivers/net/{ => ethernet}/tulip/tulip.h (100%)
 rename drivers/net/{ => ethernet}/tulip/tulip_core.c (100%)
 rename drivers/net/{ => ethernet}/tulip/uli526x.c (100%)
 rename drivers/net/{ => ethernet}/tulip/winbond-840.c (100%)
 rename drivers/net/{ => ethernet}/tulip/xircom_cb.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index f72a8bd..26d1029 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2040,7 +2040,7 @@ DAVICOM FAST ETHERNET (DMFE) NETWORK DRIVER
 L:	netdev@vger.kernel.org
 S:	Orphan
 F:	Documentation/networking/dmfe.txt
-F:	drivers/net/tulip/dmfe.c
+F:	drivers/net/ethernet/tulip/dmfe.c
 
 DC390/AM53C974 SCSI driver
 M:	Kurt Garloff <garloff@suse.de>
@@ -6278,7 +6278,7 @@ TULIP NETWORK DRIVERS
 M:	Grant Grundler <grundler@parisc-linux.org>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/tulip/
+F:	drivers/net/ethernet/tulip/
 
 TUN/TAP driver
 M:	Maxim Krasnyansky <maxk@qualcomm.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 71efbe4..0846518 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -481,8 +481,6 @@ config DNET
 	  To compile this driver as a module, choose M here: the module
 	  will be called dnet.
 
-source "drivers/net/tulip/Kconfig"
-
 config AT1700
 	tristate "AT1700/1720 support (EXPERIMENTAL)"
 	depends on (ISA || MCA_LEGACY) && EXPERIMENTAL
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 1ac4164..ec07331 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -160,7 +160,6 @@ obj-$(CONFIG_USB_ZD1201)        += usb/
 obj-$(CONFIG_USB_IPHETH)        += usb/
 
 obj-$(CONFIG_WLAN) += wireless/
-obj-$(CONFIG_NET_TULIP) += tulip/
 obj-$(CONFIG_HAMRADIO) += hamradio/
 obj-$(CONFIG_IRDA) += irda/
 obj-$(CONFIG_ETRAX_ETHERNET) += cris/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 6fb1625..369f5bb 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -55,4 +55,6 @@ config TEHUTI
 	---help---
 	  Tehuti Networks 10G Ethernet NIC
 
+source "drivers/net/ethernet/tulip/Kconfig"
+
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 1123a3d..189d112 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -31,3 +31,4 @@ obj-$(CONFIG_NET_VENDOR_SMSC) += smsc/
 obj-$(CONFIG_NET_VENDOR_STMICRO) += stmicro/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
 obj-$(CONFIG_TEHUTI) += tehuti.o
+obj-$(CONFIG_NET_TULIP) += tulip/
diff --git a/drivers/net/tulip/21142.c b/drivers/net/ethernet/tulip/21142.c
similarity index 100%
rename from drivers/net/tulip/21142.c
rename to drivers/net/ethernet/tulip/21142.c
diff --git a/drivers/net/tulip/Kconfig b/drivers/net/ethernet/tulip/Kconfig
similarity index 93%
rename from drivers/net/tulip/Kconfig
rename to drivers/net/ethernet/tulip/Kconfig
index 1f8d4a8..c298a08 100644
--- a/drivers/net/tulip/Kconfig
+++ b/drivers/net/ethernet/tulip/Kconfig
@@ -2,17 +2,15 @@
 # Tulip family network device configuration
 #
 
-menuconfig NET_TULIP
-	bool "\"Tulip\" family network device support"
+config NET_TULIP
+	bool "\"Tulip\" family network devices"
 	depends on PCI || EISA || CARDBUS
-	help
+	---help---
 	  This selects the "Tulip" family of EISA/PCI network cards.
 
-if NET_TULIP
-
 config DE2104X
 	tristate "Early DECchip Tulip (dc2104x) PCI support"
-	depends on PCI
+	depends on NET_TULIP && PCI
 	select CRC32
 	---help---
 	  This driver is developed for the SMC EtherPower series Ethernet
@@ -32,7 +30,7 @@ config DE2104X_DSL
 	depends on DE2104X
 	range 0 31
 	default 0
-	help
+	---help---
 	  Setting this value allows to align ring buffer descriptors into their
 	  own cache lines. Value of 4 corresponds to the typical 32 byte line
 	  (the descriptor is 16 bytes). This is necessary on systems that lack
@@ -41,7 +39,7 @@ config DE2104X_DSL
 
 config TULIP
 	tristate "DECchip Tulip (dc2114x) PCI support"
-	depends on PCI
+	depends on NET_TULIP && PCI
 	select CRC32
 	---help---
 	  This driver is developed for the SMC EtherPower series Ethernet
@@ -59,7 +57,7 @@ config TULIP
 config TULIP_MWI
 	bool "New bus configuration (EXPERIMENTAL)"
 	depends on TULIP && EXPERIMENTAL
-	help
+	---help---
 	  This configures your Tulip card specifically for the card and
 	  system cache line size type you are using.
 
@@ -70,7 +68,7 @@ config TULIP_MWI
 config TULIP_MMIO
 	bool "Use PCI shared mem for NIC registers"
 	depends on TULIP
-	help
+	---help---
 	  Use PCI shared memory for the NIC registers, rather than going through
 	  the Tulip's PIO (programmed I/O ports).  Faster, but could produce
 	  obscure bugs if your mainboard has memory controller timing issues.
@@ -79,7 +77,7 @@ config TULIP_MMIO
 config TULIP_NAPI
 	bool "Use RX polling (NAPI)"
 	depends on TULIP
-	help
+	---help---
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
 	  when the driver is receiving lots of packets from the card. It is
 	  still somewhat experimental and thus not yet enabled by default.
@@ -107,7 +105,7 @@ config TULIP_DM910X
 
 config DE4X5
 	tristate "Generic DECchip & DIGITAL EtherWORKS PCI/EISA"
-	depends on PCI || EISA
+	depends on NET_TULIP && (PCI || EISA)
 	select CRC32
 	---help---
 	  This is support for the DIGITAL series of PCI/EISA Ethernet cards.
@@ -123,10 +121,10 @@ config DE4X5
 
 config WINBOND_840
 	tristate "Winbond W89c840 Ethernet support"
-	depends on PCI
+	depends on NET_TULIP && PCI
 	select CRC32
 	select MII
-	help
+	---help---
 	  This driver is for the Winbond W89c840 chip.  It also works with 
 	  the TX9882 chip on the Compex RL100-ATX board.
 	  More specific information and updates are available from
@@ -134,7 +132,7 @@ config WINBOND_840
 
 config DM9102
 	tristate "Davicom DM910x/DM980x support"
-	depends on PCI
+	depends on NET_TULIP && PCI
 	select CRC32
 	---help---
 	  This driver is for DM9102(A)/DM9132/DM9801 compatible PCI cards from
@@ -147,7 +145,7 @@ config DM9102
 
 config ULI526X
 	tristate "ULi M526x controller support"
-	depends on PCI
+	depends on NET_TULIP && PCI
 	select CRC32
 	---help---
 	  This driver is for ULi M5261/M5263 10/100M Ethernet Controller
@@ -158,7 +156,7 @@ config ULI526X
 	  
 config PCMCIA_XIRCOM
 	tristate "Xircom CardBus support"
-	depends on CARDBUS
+	depends on NET_TULIP && CARDBUS
 	---help---
 	  This driver is for the Digital "Tulip" Ethernet CardBus adapters.
 	  It should work with most DEC 21*4*-based chips/ethercards, as well
@@ -167,5 +165,3 @@ config PCMCIA_XIRCOM
 
 	  To compile this driver as a module, choose M here. The module will
 	  be called xircom_cb.  If unsure, say N.
-
-endif # NET_TULIP
diff --git a/drivers/net/tulip/Makefile b/drivers/net/ethernet/tulip/Makefile
similarity index 100%
rename from drivers/net/tulip/Makefile
rename to drivers/net/ethernet/tulip/Makefile
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/ethernet/tulip/de2104x.c
similarity index 100%
rename from drivers/net/tulip/de2104x.c
rename to drivers/net/ethernet/tulip/de2104x.c
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/ethernet/tulip/de4x5.c
similarity index 100%
rename from drivers/net/tulip/de4x5.c
rename to drivers/net/ethernet/tulip/de4x5.c
diff --git a/drivers/net/tulip/de4x5.h b/drivers/net/ethernet/tulip/de4x5.h
similarity index 100%
rename from drivers/net/tulip/de4x5.h
rename to drivers/net/ethernet/tulip/de4x5.h
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/ethernet/tulip/dmfe.c
similarity index 100%
rename from drivers/net/tulip/dmfe.c
rename to drivers/net/ethernet/tulip/dmfe.c
diff --git a/drivers/net/tulip/eeprom.c b/drivers/net/ethernet/tulip/eeprom.c
similarity index 100%
rename from drivers/net/tulip/eeprom.c
rename to drivers/net/ethernet/tulip/eeprom.c
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/ethernet/tulip/interrupt.c
similarity index 100%
rename from drivers/net/tulip/interrupt.c
rename to drivers/net/ethernet/tulip/interrupt.c
diff --git a/drivers/net/tulip/media.c b/drivers/net/ethernet/tulip/media.c
similarity index 100%
rename from drivers/net/tulip/media.c
rename to drivers/net/ethernet/tulip/media.c
diff --git a/drivers/net/tulip/pnic.c b/drivers/net/ethernet/tulip/pnic.c
similarity index 100%
rename from drivers/net/tulip/pnic.c
rename to drivers/net/ethernet/tulip/pnic.c
diff --git a/drivers/net/tulip/pnic2.c b/drivers/net/ethernet/tulip/pnic2.c
similarity index 100%
rename from drivers/net/tulip/pnic2.c
rename to drivers/net/ethernet/tulip/pnic2.c
diff --git a/drivers/net/tulip/timer.c b/drivers/net/ethernet/tulip/timer.c
similarity index 100%
rename from drivers/net/tulip/timer.c
rename to drivers/net/ethernet/tulip/timer.c
diff --git a/drivers/net/tulip/tulip.h b/drivers/net/ethernet/tulip/tulip.h
similarity index 100%
rename from drivers/net/tulip/tulip.h
rename to drivers/net/ethernet/tulip/tulip.h
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/ethernet/tulip/tulip_core.c
similarity index 100%
rename from drivers/net/tulip/tulip_core.c
rename to drivers/net/ethernet/tulip/tulip_core.c
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/ethernet/tulip/uli526x.c
similarity index 100%
rename from drivers/net/tulip/uli526x.c
rename to drivers/net/ethernet/tulip/uli526x.c
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/ethernet/tulip/winbond-840.c
similarity index 100%
rename from drivers/net/tulip/winbond-840.c
rename to drivers/net/ethernet/tulip/winbond-840.c
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/ethernet/tulip/xircom_cb.c
similarity index 100%
rename from drivers/net/tulip/xircom_cb.c
rename to drivers/net/ethernet/tulip/xircom_cb.c
-- 
1.7.5.4

