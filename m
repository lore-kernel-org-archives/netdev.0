From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] update networking config menu (v3)
Date: Sun, 4 Apr 2004 20:03:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040404200354.50e5dd74.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, benh@kernel.crashing.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This is a modified version of the patch that I posted about 3 weeks ago.
It no longer puts "Networking support" in the top-level menu because
it makes more sense to me to keep it close to the Network drivers and
other protocols, so basically this patch mostly moves some menu items
around to have a better logical grouping (IMO of course).

Comments/suggestions?

Thanks,
--
~Randy


// linux-2.6.5

// Networking support/options and Networking drivers have been, uhm,
// messy to navigate for some time now.   BenH mentioned this
// and I was already looking into options to clean it up.

// This is a cleanup of Networking support/options and Networking Drivers.
// It presents a more consistent interface and lists similar driver
// groups and protocol groups closer together.
// It also moves the IBMVETH driver so that it no longer breaks the
// dependency tree, allowing other drivers (nearby in Kconfig file)
// to be presented in a more linear manner.

diffstat:=
 drivers/net/Kconfig   |   53 ++++++++++-----------
 net/Kconfig           |  123 +++++++++++++++++++++++++-------------------------
 net/ax25/Kconfig      |    7 --
 net/bluetooth/Kconfig |    6 --
 net/irda/Kconfig      |    8 ---
 5 files changed, 93 insertions(+), 104 deletions(-)


diff -Naurp ./drivers/net/Kconfig.orig ./drivers/net/Kconfig
--- ./drivers/net/Kconfig.orig	2004-04-03 19:38:10.000000000 -0800
+++ ./drivers/net/Kconfig	2004-04-04 17:31:22.000000000 -0700
@@ -21,10 +21,6 @@ config NETDEVICES
 
 	  If unsure, say Y.
 
-if NETDEVICES
-	source "drivers/net/arcnet/Kconfig"
-endif
-
 config DUMMY
 	tristate "Dummy net driver support"
 	depends on NETDEVICES
@@ -155,6 +151,10 @@ config NET_SB1000
 
 	  If you don't have this card, of course say N.
 
+if NETDEVICES
+	source "drivers/net/arcnet/Kconfig"
+endif
+
 #
 #	Ethernet
 #
@@ -1178,6 +1178,17 @@ config IBMLANA
 	  boards with this driver should be possible, but has not been tested
 	  up to now due to lack of hardware.
 
+config IBMVETH
+	tristate "IBM LAN Virtual Ethernet support"
+	depends on NETDEVICES && NET_ETHERNET && PPC_PSERIES
+	---help---
+	  This driver supports virtual ethernet adapters on newer IBM iSeries
+	  and pSeries systems.
+
+	  To compile this driver as a module, choose M here and read
+	  <file:Documentation/networking/net-modules.txt>. The module will
+	  be called ibmveth.
+
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on NET_ETHERNET && (ISA || EISA || PCI)
@@ -2103,6 +2114,17 @@ config IXGB_NAPI
 
 endmenu
 
+source "drivers/net/tokenring/Kconfig"
+
+source "drivers/net/wireless/Kconfig"
+
+source "drivers/net/pcmcia/Kconfig"
+
+source "drivers/net/wan/Kconfig"
+
+source "drivers/atm/Kconfig"
+
+source "drivers/s390/net/Kconfig"
 
 config VETH
 	tristate "iSeries Virtual Ethernet driver support"
@@ -2170,17 +2192,6 @@ config HIPPI
 	  under Linux, say Y here (you must also remember to enable the driver
 	  for your HIPPI card below). Most people will say N here.
 
-config IBMVETH
-	tristate "IBM LAN Virtual Ethernet support"
-	depends on NETDEVICES && NET_ETHERNET && PPC_PSERIES
-	---help---
-	  This driver supports virtual ethernet adapters on newer IBM iSeries
-	  and pSeries systems.
-
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>. The module will
-	  be called ibmveth.
-
 config ROADRUNNER
 	tristate "Essential RoadRunner HIPPI PCI adapter support (EXPERIMENTAL)"
 	depends on HIPPI && PCI
@@ -2438,10 +2449,6 @@ config SLIP_MODE_SLIP6
 	  end of the link as well. It's good enough, for example, to run IP
 	  over the async ports of a Camtec JNT Pad. If unsure, say N.
 
-source "drivers/net/wireless/Kconfig"
-
-source "drivers/net/tokenring/Kconfig"
-
 config NET_FC
 	bool "Fibre Channel driver support"
 	depends on NETDEVICES && SCSI && PCI
@@ -2501,11 +2508,3 @@ config NETCONSOLE
 	---help---
 	If you want to log kernel messages over the network, enable this.
 	See Documentation/networking/netconsole.txt for details.
-
-source "drivers/net/wan/Kconfig"
-
-source "drivers/net/pcmcia/Kconfig"
-
-source "drivers/atm/Kconfig"
-
-source "drivers/s390/net/Kconfig"
diff -Naurp ./net/bluetooth/Kconfig.orig ./net/bluetooth/Kconfig
--- ./net/bluetooth/Kconfig.orig	2004-04-03 19:38:12.000000000 -0800
+++ ./net/bluetooth/Kconfig	2004-04-03 22:30:19.000000000 -0800
@@ -2,10 +2,8 @@
 # Bluetooth subsystem configuration
 #
 
-menu "Bluetooth support"
+menuconfig BT
 	depends on NET
-
-config BT
 	tristate "Bluetooth subsystem support"
 	help
 	  Bluetooth is low-cost, low-power, short-range wireless technology.
@@ -62,5 +60,3 @@ source "net/bluetooth/cmtp/Kconfig"
 
 source "drivers/bluetooth/Kconfig"
 
-endmenu
-
diff -Naurp ./net/irda/Kconfig.orig ./net/irda/Kconfig
--- ./net/irda/Kconfig.orig	2004-04-03 19:37:07.000000000 -0800
+++ ./net/irda/Kconfig	2004-04-03 22:30:19.000000000 -0800
@@ -2,11 +2,9 @@
 # IrDA protocol configuration
 #
 
-menu "IrDA (infrared) support"
+menuconfig IRDA
 	depends on NET
-
-config IRDA
-	tristate "IrDA subsystem support"
+	tristate "IrDA (infrared) subsystem support"
 	---help---
 	  Say Y here if you want to build support for the IrDA (TM) protocols.
 	  The Infrared Data Associations (tm) specifies standards for wireless
@@ -95,5 +93,3 @@ config IRDA_DEBUG
 
 source "drivers/net/irda/Kconfig"
 
-endmenu
-
diff -Naurp ./net/ax25/Kconfig.orig ./net/ax25/Kconfig
--- ./net/ax25/Kconfig.orig	2004-04-03 19:38:13.000000000 -0800
+++ ./net/ax25/Kconfig	2004-04-03 22:30:19.000000000 -0800
@@ -6,9 +6,8 @@
 #		Joerg Reuter DL1BKE <jreuter@yaina.de>
 # 19980129	Moved to net/ax25/Config.in, sourcing device drivers.
 
-menu "Amateur Radio support"
-
-config HAMRADIO
+menuconfig HAMRADIO
+	depends on NET
 	bool "Amateur Radio support"
 	help
 	  If you want to connect your Linux box to an amateur radio, answer Y
@@ -109,5 +108,3 @@ source "drivers/net/hamradio/Kconfig"
 
 endmenu
 
-endmenu
-
diff -Naurp ./net/Kconfig.orig ./net/Kconfig
--- ./net/Kconfig.orig	2004-04-03 19:36:16.000000000 -0800
+++ ./net/Kconfig	2004-04-04 19:44:42.000000000 -0700
@@ -129,59 +129,6 @@ config IPV6
 
 source "net/ipv6/Kconfig"
 
-config DECNET
-	tristate "DECnet Support"
-	---help---
-	  The DECnet networking protocol was used in many products made by
-	  Digital (now Compaq).  It provides reliable stream and sequenced
-	  packet communications over which run a variety of services similar
-	  to those which run over TCP/IP.
-
-	  To find some tools to use with the kernel layer support, please
-	  look at Patrick Caulfield's web site:
-	  <http://linux-decnet.sourceforge.net/>.
-
-	  More detailed documentation is available in
-	  <file:Documentation/networking/decnet.txt>.
-
-	  Be sure to say Y to "/proc file system support" and "Sysctl support"
-	  below when using DECnet, since you will need sysctl support to aid
-	  in configuration at run time.
-
-	  The DECnet code is also available as a module ( = code which can be
-	  inserted in and removed from the running kernel whenever you want).
-	  The module is called decnet.
-
-source "net/decnet/Kconfig"
-
-config BRIDGE
-	tristate "802.1d Ethernet Bridging"
-	---help---
-	  If you say Y here, then your Linux box will be able to act as an
-	  Ethernet bridge, which means that the different Ethernet segments it
-	  is connected to will appear as one Ethernet to the participants.
-	  Several such bridges can work together to create even larger
-	  networks of Ethernets using the IEEE 802.1 spanning tree algorithm.
-	  As this is a standard, Linux bridges will cooperate properly with
-	  other third party bridge products.
-
-	  In order to use the Ethernet bridge, you'll need the bridge
-	  configuration tools; see <file:Documentation/networking/bridge.txt>
-	  for location. Please read the Bridge mini-HOWTO for more
-	  information.
-
-	  If you enable iptables support along with the bridge support then you
-	  turn your bridge into a bridging IP firewall.
-	  iptables will then see the IP packets being bridged, so you need to
-	  take this into account when setting up your firewall rules.
-	  Enabling arptables support when bridging will let arptables see
-	  bridged ARP traffic in the arptables FORWARD chain.
-
-	  To compile this code as a module, choose M here: the module
-	  will be called bridge.
-
-	  If unsure, say N.
-
 menuconfig NETFILTER
 	bool "Network packet filtering (replaces ipchains)"
 	---help---
@@ -345,9 +292,62 @@ config ATM_BR2684_IPFILTER
 	  large number of IP-only vcc's.  Do not enable this unless you are sure
 	  you know what you are doing.
 
+config BRIDGE
+	tristate "802.1d Ethernet Bridging"
+	---help---
+	  If you say Y here, then your Linux box will be able to act as an
+	  Ethernet bridge, which means that the different Ethernet segments it
+	  is connected to will appear as one Ethernet to the participants.
+	  Several such bridges can work together to create even larger
+	  networks of Ethernets using the IEEE 802.1 spanning tree algorithm.
+	  As this is a standard, Linux bridges will cooperate properly with
+	  other third party bridge products.
+
+	  In order to use the Ethernet bridge, you'll need the bridge
+	  configuration tools; see <file:Documentation/networking/bridge.txt>
+	  for location. Please read the Bridge mini-HOWTO for more
+	  information.
+
+	  If you enable iptables support along with the bridge support then you
+	  turn your bridge into a bridging IP firewall.
+	  iptables will then see the IP packets being bridged, so you need to
+	  take this into account when setting up your firewall rules.
+	  Enabling arptables support when bridging will let arptables see
+	  bridged ARP traffic in the arptables FORWARD chain.
+
+	  To compile this code as a module, choose M here: the module
+	  will be called bridge.
+
+	  If unsure, say N.
+
 config VLAN_8021Q
 	tristate "802.1Q VLAN Support"
 
+config DECNET
+	tristate "DECnet Support"
+	---help---
+	  The DECnet networking protocol was used in many products made by
+	  Digital (now Compaq).  It provides reliable stream and sequenced
+	  packet communications over which run a variety of services similar
+	  to those which run over TCP/IP.
+
+	  To find some tools to use with the kernel layer support, please
+	  look at Patrick Caulfield's web site:
+	  <http://linux-decnet.sourceforge.net/>.
+
+	  More detailed documentation is available in
+	  <file:Documentation/networking/decnet.txt>.
+
+	  Be sure to say Y to "/proc file system support" and "Sysctl support"
+	  below when using DECnet, since you will need sysctl support to aid
+	  in configuration at run time.
+
+	  The DECnet code is also available as a module ( = code which can be
+	  inserted in and removed from the running kernel whenever you want).
+	  The module is called decnet.
+
+source "net/decnet/Kconfig"
+
 source "net/llc/Kconfig"
 
 config IPX
@@ -650,14 +650,6 @@ endmenu
 
 endmenu
 
-source "drivers/net/Kconfig"
-
-source "net/ax25/Kconfig"
-
-source "net/irda/Kconfig"
-
-source "net/bluetooth/Kconfig"
-
 config NETPOLL
 	def_bool NETCONSOLE
 
@@ -674,4 +666,13 @@ config NETPOLL_TRAP
 config NET_POLL_CONTROLLER
 	def_bool NETPOLL
 
+source "net/ax25/Kconfig"
+
+source "net/irda/Kconfig"
+
+source "net/bluetooth/Kconfig"
+
+source "drivers/net/Kconfig"
+
 endmenu
+
