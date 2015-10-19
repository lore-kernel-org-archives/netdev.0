From: Oliver Neukum <oneukum@suse.com>
Subject: [PATCH] usbnet: removed USB_USBNET as a config option
Date: Mon, 19 Oct 2015 14:23:07 +0200
Message-ID: <1445257387-4278-1-git-send-email-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48097 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751881AbbJSMYq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 08:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

usbnet drives no devices of its own. It makes more sense to
select it whenever a driver for actual hardware that needs
it is chosen rather than offer it as an option of its own.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/Kconfig | 75 +++++++++++++++----------------------------------
 1 file changed, 23 insertions(+), 52 deletions(-)

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 8cf0eba..0cf45ab 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -119,42 +119,12 @@ config USB_LAN78XX
 	  module will be called lan78xx.
 
 config USB_USBNET
-	tristate "Multi-purpose USB Networking Framework"
+	tristate
 	select MII
-	---help---
-	  This driver supports several kinds of network links over USB,
-	  with "minidrivers" built around a common network driver core
-	  that supports deep queues for efficient transfers.  (This gives
-	  better performance with small packets and at high speeds).
-
-	  The USB host runs "usbnet", and the other end of the link might be:
-
-	  - Another USB host, when using USB "network" or "data transfer"
-	    cables.  These are often used to network laptops to PCs, like
-	    "Laplink" parallel cables or some motherboards.  These rely
-	    on specialized chips from many suppliers.
-
-	  - An intelligent USB gadget, perhaps embedding a Linux system.
-	    These include PDAs running Linux (iPaq, Yopy, Zaurus, and
-	    others), and devices that interoperate using the standard
-	    CDC-Ethernet specification (including many cable modems).
-
-	  - Network adapter hardware (like those for 10/100 Ethernet) which
-	    uses this driver framework.
-
-	  The link will appear with a name like "usb0", when the link is
-	  a two-node link, or "eth0" for most CDC-Ethernet devices.  Those
-	  two-node links are most easily managed with Ethernet Bridging
-	  (CONFIG_BRIDGE) instead of routing.
-
-	  For more information see <http://www.linux-usb.org/usbnet/>.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called usbnet.
 
 config USB_NET_AX8817X
 	tristate "ASIX AX88xxx Based USB 2.0 Ethernet Adapters"
-	depends on USB_USBNET
+	select USB_USBNET
 	select CRC32
 	select PHYLIB
 	default y
@@ -183,7 +153,7 @@ config USB_NET_AX8817X
 
 config USB_NET_AX88179_178A
 	tristate "ASIX AX88179/178A USB 3.0/2.0 to Gigabit Ethernet"
-	depends on USB_USBNET
+	select USB_USBNET
 	select CRC32
 	select PHYLIB
 	default y
@@ -201,7 +171,7 @@ config USB_NET_AX88179_178A
 
 config USB_NET_CDCETHER
 	tristate "CDC Ethernet support (smart devices such as cable modems)"
-	depends on USB_USBNET
+	select USB_USBNET
 	default y
 	help
 	  This option supports devices conforming to the Communication Device
@@ -229,7 +199,7 @@ config USB_NET_CDCETHER
 
 config USB_NET_CDC_EEM
 	tristate "CDC EEM support"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  This option supports devices conforming to the Communication Device
 	  Class (CDC) Ethernet Emulation Model, a specification that's easy to
@@ -243,7 +213,7 @@ config USB_NET_CDC_EEM
 
 config USB_NET_CDC_NCM
 	tristate "CDC NCM support"
-	depends on USB_USBNET
+	select USB_USBNET
 	default y
 	help
 	  This driver provides support for CDC NCM (Network Control Model
@@ -295,7 +265,7 @@ config USB_NET_CDC_MBIM
 
 config USB_NET_DM9601
 	tristate "Davicom DM96xx based USB 10/100 ethernet devices"
-	depends on USB_USBNET
+	select USB_USBNET
 	select CRC32
 	help
 	  This option adds support for Davicom DM9601/DM9620/DM9621A
@@ -303,7 +273,7 @@ config USB_NET_DM9601
 
 config USB_NET_SR9700
 	tristate "CoreChip-sz SR9700 based USB 1.1 10/100 ethernet devices"
-	depends on USB_USBNET
+	select USB_USBNET
 	select CRC32
 	help
 	  This option adds support for CoreChip-sz SR9700 based USB 1.1
@@ -311,7 +281,7 @@ config USB_NET_SR9700
 
 config USB_NET_SR9800
 	tristate "CoreChip-sz SR9800 based USB 2.0 10/100 ethernet devices"
-	depends on USB_USBNET
+	select USB_USBNET
 	select CRC32
 	---help---
 	  Say Y if you want to use one of the following 100Mbps USB Ethernet
@@ -326,7 +296,7 @@ config USB_NET_SR9800
 
 config USB_NET_SMSC75XX
 	tristate "SMSC LAN75XX based USB 2.0 gigabit ethernet devices"
-	depends on USB_USBNET
+	select USB_USBNET
 	select BITREVERSE
 	select CRC16
 	select CRC32
@@ -336,7 +306,7 @@ config USB_NET_SMSC75XX
 
 config USB_NET_SMSC95XX
 	tristate "SMSC LAN95XX based USB 2.0 10/100 ethernet devices"
-	depends on USB_USBNET
+	select USB_USBNET
 	select BITREVERSE
 	select CRC16
 	select CRC32
@@ -346,7 +316,7 @@ config USB_NET_SMSC95XX
 
 config USB_NET_GL620A
 	tristate "GeneSys GL620USB-A based cables"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you're using a host-to-host cable,
 	  or PC2PC motherboard, with this chip.
@@ -356,7 +326,7 @@ config USB_NET_GL620A
 config USB_NET_NET1080
 	tristate "NetChip 1080 based cables (Laplink, ...)"
 	default y
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you're using a host-to-host cable based
 	  on this design:  one NetChip 1080 chip and supporting logic,
@@ -366,14 +336,14 @@ config USB_NET_PLUSB
 	tristate "Prolific PL-2301/2302/25A1 based cables"
 	# if the handshake/init/reset problems, from original 'plusb',
 	# are ever resolved ... then remove "experimental"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you're using a host-to-host cable
 	  with one of these chips.
 
 config USB_NET_MCS7830
 	tristate "MosChip MCS7830 based Ethernet adapters"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you're using a 10/100 Ethernet USB2
 	  adapter based on the MosChip 7830 controller. This includes
@@ -396,7 +366,7 @@ config USB_NET_RNDIS_HOST
 
 config USB_NET_CDC_SUBSET
 	tristate "Simple USB Network Links (CDC Ethernet subset)"
-	depends on USB_USBNET
+	select USB_USBNET
 	default y
 	help
 	  This driver module supports USB network devices that can work
@@ -484,7 +454,7 @@ config USB_NET_ZAURUS
 
 config USB_NET_CX82310_ETH
 	tristate "Conexant CX82310 USB ethernet port"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you're using a Conexant CX82310-based ADSL
 	  router with USB ethernet port. This driver is for routers only,
@@ -492,7 +462,7 @@ config USB_NET_CX82310_ETH
 
 config USB_NET_KALMIA
 	tristate "Samsung Kalmia based LTE USB modem"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you have a Samsung Kalmia based USB modem
 	  as Samsung GT-B3730.
@@ -535,7 +505,7 @@ config USB_HSO
 
 config USB_NET_INT51X1
 	tristate "Intellon PLC based usb adapter"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you're using a 14Mb USB-based PLC
 	  (Powerline Communications) solution with an Intellon
@@ -543,7 +513,8 @@ config USB_NET_INT51X1
 
 config USB_CDC_PHONET
 	tristate "CDC Phonet support"
-	depends on PHONET && USB_USBNET
+	depends on PHONET
+	select USB_USBNET
 	help
 	  Choose this option to support the Phonet interface to a Nokia
 	  cellular modem, as found on most Nokia handsets with the
@@ -563,7 +534,7 @@ config USB_IPHETH
 
 config USB_SIERRA_NET
 	tristate "USB-to-WWAN Driver for Sierra Wireless modems"
-	depends on USB_USBNET
+	select USB_USBNET
 	help
 	  Choose this option if you have a Sierra Wireless USB-to-WWAN device.
 
@@ -587,7 +558,7 @@ config USB_VL600
 
 config USB_NET_CH9200
 	tristate "QingHeng CH9200 USB ethernet support"
-	depends on USB_USBNET
+	select USB_USBNET
 	select MII
 	help
 	  Choose this option if you have a USB ethernet adapter with a QinHeng
-- 
2.1.4
