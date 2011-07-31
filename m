From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 71/71] drivers/net: Kconfig and Makefile cleanup
Date: Sat, 30 Jul 2011 20:27:30 -0700
Message-ID: <1312082850-24914-72-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753456Ab1GaD27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:59 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the move of the Ethernet drivers into drivers/net/ethernet/
there was some leftover cleanup to do in the Kconfig and Makefile.

Removed the 10/100, 1000, and 10GbE Kconfig menus.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig          |  113 ------------------------------------------
 drivers/net/Makefile         |    4 --
 drivers/net/ethernet/Kconfig |    3 +
 3 files changed, 3 insertions(+), 117 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 6fce41b..31d8792 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -192,119 +192,6 @@ source "drivers/net/phy/Kconfig"
 
 source "drivers/net/ethernet/Kconfig"
 
-menuconfig NET_ETHERNET
-	bool "Ethernet (10 or 100Mbit)"
-	depends on !UML
-	---help---
-	  Ethernet (also called IEEE 802.3 or ISO 8802-2) is the most common
-	  type of Local Area Network (LAN) in universities and companies.
-
-	  Common varieties of Ethernet are: 10BASE-2 or Thinnet (10 Mbps over
-	  coaxial cable, linking computers in a chain), 10BASE-T or twisted
-	  pair (10 Mbps over twisted pair cable, linking computers to central
-	  hubs), 10BASE-F (10 Mbps over optical fiber links, using hubs),
-	  100BASE-TX (100 Mbps over two twisted pair cables, using hubs),
-	  100BASE-T4 (100 Mbps over 4 standard voice-grade twisted pair
-	  cables, using hubs), 100BASE-FX (100 Mbps over optical fiber links)
-	  [the 100BASE varieties are also known as Fast Ethernet], and Gigabit
-	  Ethernet (1 Gbps over optical fiber or short copper links).
-
-	  If your Linux machine will be connected to an Ethernet and you have
-	  an Ethernet network interface card (NIC) installed in your computer,
-	  say Y here and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>. You will then also have
-	  to say Y to the driver for your particular NIC.
-
-	  Note that the answer to this question won't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about Ethernet network cards. If unsure, say N.
-
-if NET_ETHERNET
-
-config NET_PCI
-	bool "EISA, VLB, PCI and on board controllers"
-	depends on ISA || EISA || PCI
-	help
-	  This is another class of network cards which attach directly to the
-	  bus. If you have one of those, say Y and read the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about this class of network cards. If you say Y, you
-	  will be asked for your specific card in the following questions. If
-	  you are unsure, say Y.
-
-config NET_POCKET
-	bool "Pocket and portable adapters"
-	depends on PARPORT
-	---help---
-	  Cute little network (Ethernet) devices which attach to the parallel
-	  port ("pocket adapters"), commonly used with laptops. If you have
-	  one of those, say Y and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  If you want to plug a network (or some other) card into the PCMCIA
-	  (or PC-card) slot of your laptop instead (PCMCIA is the standard for
-	  credit card size extension cards used by all modern laptops), you
-	  need the pcmcia-cs package (location contained in the file
-	  <file:Documentation/Changes>) and you can say N here.
-
-	  Laptop users should read the Linux Laptop home page at
-	  <http://www.linux-on-laptops.com/> or
-	  Tuxmobil - Linux on Mobile Computers at <http://www.tuxmobil.org/>.
-
-	  Note that the answer to this question doesn't directly affect the
-	  kernel: saying N will just cause the configurator to skip all
-	  the questions about this class of network devices. If you say Y, you
-	  will be asked for your specific device in the following questions.
-
-endif # NET_ETHERNET
-
-#
-#	Gigabit Ethernet
-#
-
-menuconfig NETDEV_1000
-	bool "Ethernet (1000 Mbit)"
-	depends on !UML
-	default y
-	---help---
-	  Ethernet (also called IEEE 802.3 or ISO 8802-2) is the most common
-	  type of Local Area Network (LAN) in universities and companies.
-
-	  Say Y here to get to see options for Gigabit Ethernet drivers.
-	  This option alone does not add any kernel code.
-	  Note that drivers supporting both 100 and 1000 MBit may be listed
-	  under "Ethernet (10 or 100MBit)" instead.
-
-	  If you say N, all options in this submenu will be skipped and disabled.
-
-if NETDEV_1000
-
-endif # NETDEV_1000
-
-#
-#	10 Gigabit Ethernet
-#
-
-menuconfig NETDEV_10000
-	bool "Ethernet (10000 Mbit)"
-	depends on !UML
-	default y
-	---help---
-	  Say Y here to get to see options for 10 Gigabit Ethernet drivers.
-	  This option alone does not add any kernel code.
-
-	  If you say N, all options in this submenu will be skipped and disabled.
-
-if NETDEV_10000
-
-config MDIO
-	tristate
-
-endif # NETDEV_10000
-
 source "drivers/net/tokenring/Kconfig"
 
 source "drivers/net/wireless/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index fcc62e6..9cb47bb 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -13,9 +13,7 @@ obj-$(CONFIG_VMXNET3) += vmxnet3/
 # link order important here
 #
 obj-$(CONFIG_PLIP) += plip.o
-
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
-
 obj-$(CONFIG_SKFP) += skfp/
 obj-$(CONFIG_RIONET) += rionet.o
 
@@ -25,7 +23,6 @@ obj-$(CONFIG_RIONET) += rionet.o
 
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-
 obj-$(CONFIG_PPP) += ppp_generic.o
 obj-$(CONFIG_PPP_ASYNC) += ppp_async.o
 obj-$(CONFIG_PPP_SYNC_TTY) += ppp_synctty.o
@@ -35,7 +32,6 @@ obj-$(CONFIG_PPP_MPPE) += ppp_mppe.o
 obj-$(CONFIG_PPPOE) += pppox.o pppoe.o
 obj-$(CONFIG_PPPOL2TP) += pppox.o
 obj-$(CONFIG_PPTP) += pppox.o pptp.o
-
 obj-$(CONFIG_SLIP) += slip.o
 obj-$(CONFIG_SLHC) += slhc.o
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index cff6ef5..9ed3dc7 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -11,6 +11,9 @@ menuconfig ETHERNET
 
 if ETHERNET
 
+config MDIO
+	tristate
+
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
-- 
1.7.6

