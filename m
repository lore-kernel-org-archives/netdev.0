From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] drivers/net: Kconfig & Makefile cleanup
Date: Tue, 23 Aug 2011 21:39:33 -0700
Message-ID: <1314160774-6980-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2828 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab1HXEjo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Aug 2011 00:39:44 -0400
In-Reply-To: <1314160774-6980-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The is does a general cleanup of the drivers/net/ Kconfig and
Makefile.  This patch create a "core" option and places all
the networking core drivers into this option (default is yes
for this option).  In addition, it alphabitizes the Kconfig
driver options.

As a side cleanup, found that the arcnet, token ring, and PHY
Kconfig options were a tri-state option and should have been
a bool option.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig           |  267 +++++++++++++++++++++--------------------
 drivers/net/Makefile          |   63 ++++------
 drivers/net/arcnet/Kconfig    |    2 +-
 drivers/net/phy/Kconfig       |    2 +-
 drivers/net/tokenring/Kconfig |    2 +-
 5 files changed, 167 insertions(+), 169 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5762370..583f66c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -25,18 +25,32 @@ menuconfig NETDEVICES
 # that for each of the symbols.
 if NETDEVICES
 
-config IFB
-	tristate "Intermediate Functional Block support"
-	depends on NET_CLS_ACT
+config NET_CORE
+	default y
+	bool "Network core driver support"
 	---help---
-	  This is an intermediate driver that allows sharing of
-	  resources.
+	  You can say N here if you do not intend to use any of the
+	  networking core drivers (i.e. VLAN, bridging, bonding, etc.)
+
+if NET_CORE
+
+config BONDING
+	tristate "Bonding driver support"
+	depends on INET
+	depends on IPV6 || IPV6=n
+	---help---
+	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
+	  Channels together. This is called 'Etherchannel' by Cisco,
+	  'Trunking' by Sun, 802.3ad by the IEEE, and 'Bonding' in Linux.
+
+	  The driver supports multiple bonding modes to allow for both high
+	  performance and high availability operation.
+
+	  Refer to <file:Documentation/networking/bonding.txt> for more
+	  information.
+
 	  To compile this driver as a module, choose M here: the module
-	  will be called ifb.  If you want to use more than one ifb
-	  device at a time, you need to compile this driver as a module.
-	  Instead of 'ifb', the devices will then be called 'ifb0',
-	  'ifb1' etc.
-	  Look at the iproute2 documentation directory for usage etc
+	  will be called bonding.
 
 config DUMMY
 	tristate "Dummy net driver support"
@@ -57,23 +71,59 @@ config DUMMY
 	  Instead of 'dummy', the devices will then be called 'dummy0',
 	  'dummy1' etc.
 
-config BONDING
-	tristate "Bonding driver support"
-	depends on INET
-	depends on IPV6 || IPV6=n
+config EQUALIZER
+	tristate "EQL (serial line load balancing) support"
 	---help---
-	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
-	  Channels together. This is called 'Etherchannel' by Cisco,
-	  'Trunking' by Sun, 802.3ad by the IEEE, and 'Bonding' in Linux.
+	  If you have two serial connections to some other computer (this
+	  usually requires two modems and two telephone lines) and you use
+	  SLIP (the protocol for sending Internet traffic over telephone
+	  lines) or PPP (a better SLIP) on them, you can make them behave like
+	  one double speed connection using this driver.  Naturally, this has
+	  to be supported at the other end as well, either with a similar EQL
+	  Linux driver or with a Livingston Portmaster 2e.
 
-	  The driver supports multiple bonding modes to allow for both high
-	  performance and high availability operation.
+	  Say Y if you want this and read
+	  <file:Documentation/networking/eql.txt>.  You may also want to read
+	  section 6.2 of the NET-3-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
 
-	  Refer to <file:Documentation/networking/bonding.txt> for more
-	  information.
+	  To compile this driver as a module, choose M here: the module
+	  will be called eql.  If unsure, say N.
+
+config NET_FC
+	bool "Fibre Channel driver support"
+	depends on SCSI && PCI
+	help
+	  Fibre Channel is a high speed serial protocol mainly used to connect
+	  large storage devices to the computer; it is compatible with and
+	  intended to replace SCSI.
+
+	  If you intend to use Fibre Channel, you need to have a Fibre channel
+	  adaptor card in your computer; say Y here and to the driver for your
+	  adaptor below. You also should have said Y to "SCSI support" and
+	  "SCSI generic support".
 
+config MII
+	tristate "Generic Media Independent Interface device support"
+	help
+	  Most ethernet controllers have MII transceiver either as an external
+	  or internal device.  It is safe to say Y or M here even if your
+	  ethernet card lacks MII.
+
+source "drivers/ieee802154/Kconfig"
+
+config IFB
+	tristate "Intermediate Functional Block support"
+	depends on NET_CLS_ACT
+	---help---
+	  This is an intermediate driver that allows sharing of
+	  resources.
 	  To compile this driver as a module, choose M here: the module
-	  will be called bonding.
+	  will be called ifb.  If you want to use more than one ifb
+	  device at a time, you need to compile this driver as a module.
+	  Instead of 'ifb', the devices will then be called 'ifb0',
+	  'ifb1' etc.
+	  Look at the iproute2 documentation directory for usage etc
 
 config MACVLAN
 	tristate "MAC-VLAN support (EXPERIMENTAL)"
@@ -102,24 +152,46 @@ config MACVTAP
 	  To compile this driver as a module, choose M here: the module
 	  will be called macvtap.
 
-config EQUALIZER
-	tristate "EQL (serial line load balancing) support"
+config NETCONSOLE
+	tristate "Network console logging support"
 	---help---
-	  If you have two serial connections to some other computer (this
-	  usually requires two modems and two telephone lines) and you use
-	  SLIP (the protocol for sending Internet traffic over telephone
-	  lines) or PPP (a better SLIP) on them, you can make them behave like
-	  one double speed connection using this driver.  Naturally, this has
-	  to be supported at the other end as well, either with a similar EQL
-	  Linux driver or with a Livingston Portmaster 2e.
+	If you want to log kernel messages over the network, enable this.
+	See <file:Documentation/networking/netconsole.txt> for details.
 
-	  Say Y if you want this and read
-	  <file:Documentation/networking/eql.txt>.  You may also want to read
-	  section 6.2 of the NET-3-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+config NETCONSOLE_DYNAMIC
+	bool "Dynamic reconfiguration of logging targets"
+	depends on NETCONSOLE && SYSFS && CONFIGFS_FS && \
+			!(NETCONSOLE=y && CONFIGFS_FS=m)
+	help
+	  This option enables the ability to dynamically reconfigure target
+	  parameters (interface, IP addresses, port numbers, MAC addresses)
+	  at runtime through a userspace interface exported using configfs.
+	  See <file:Documentation/networking/netconsole.txt> for details.
 
-	  To compile this driver as a module, choose M here: the module
-	  will be called eql.  If unsure, say N.
+config NETPOLL
+	def_bool NETCONSOLE
+
+config NETPOLL_TRAP
+	bool "Netpoll traffic trapping"
+	default n
+	depends on NETPOLL
+
+config NET_POLL_CONTROLLER
+	def_bool NETPOLL
+
+config RIONET
+	tristate "RapidIO Ethernet over messaging driver support"
+	depends on RAPIDIO
+
+config RIONET_TX_SIZE
+	int "Number of outbound queue entries"
+	depends on RIONET
+	default "128"
+
+config RIONET_RX_SIZE
+	int "Number of inbound queue entries"
+	depends on RIONET
+	default "128"
 
 config TUN
 	tristate "Universal TUN/TAP device driver support"
@@ -151,6 +223,28 @@ config VETH
 	  When one end receives the packet it appears on its pair and vice
 	  versa.
 
+config VIRTIO_NET
+	tristate "Virtio network driver (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && VIRTIO
+	---help---
+	  This is the virtual network driver for virtio.  It can be used with
+	  lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
+
+endif # NET_CORE
+
+config SUNGEM_PHY
+	tristate
+
+source "drivers/net/arcnet/Kconfig"
+
+source "drivers/atm/Kconfig"
+
+source "drivers/net/caif/Kconfig"
+
+source "drivers/net/ethernet/Kconfig"
+
+source "drivers/net/fddi/Kconfig"
+
 config NET_SB1000
 	tristate "General Instruments Surfboard 1000"
 	depends on PNP
@@ -175,52 +269,26 @@ config NET_SB1000
 
 	  If you don't have this card, of course say N.
 
-source "drivers/net/arcnet/Kconfig"
-
-config MII
-	tristate "Generic Media Independent Interface device support"
-	help
-	  Most ethernet controllers have MII transceiver either as an external
-	  or internal device.  It is safe to say Y or M here even if your
-	  ethernet card lacks MII.
-
 source "drivers/net/phy/Kconfig"
 
-config SUNGEM_PHY
-	tristate
-
-#
-#	Ethernet
-#
-
-source "drivers/net/ethernet/Kconfig"
-
-source "drivers/net/fddi/Kconfig"
-
 source "drivers/net/plip/Kconfig"
 
+source "drivers/net/ppp/Kconfig"
+
 source "drivers/net/slip/Kconfig"
 
+source "drivers/s390/net/Kconfig"
+
 source "drivers/net/tokenring/Kconfig"
 
+source "drivers/net/usb/Kconfig"
+
 source "drivers/net/wireless/Kconfig"
 
 source "drivers/net/wimax/Kconfig"
 
-source "drivers/net/usb/Kconfig"
-
-source "drivers/net/ppp/Kconfig"
-
 source "drivers/net/wan/Kconfig"
 
-source "drivers/atm/Kconfig"
-
-source "drivers/ieee802154/Kconfig"
-
-source "drivers/s390/net/Kconfig"
-
-source "drivers/net/caif/Kconfig"
-
 config XEN_NETDEV_FRONTEND
 	tristate "Xen network device frontend driver"
 	depends on XEN
@@ -260,67 +328,6 @@ config XEN_NETDEV_BACKEND
 	  compile this driver as a module, chose M here: the module
 	  will be called xen-netback.
 
-config RIONET
-	tristate "RapidIO Ethernet over messaging driver support"
-	depends on RAPIDIO
-
-config RIONET_TX_SIZE
-	int "Number of outbound queue entries"
-	depends on RIONET
-	default "128"
-
-config RIONET_RX_SIZE
-	int "Number of inbound queue entries"
-	depends on RIONET
-	default "128"
-
-config NET_FC
-	bool "Fibre Channel driver support"
-	depends on SCSI && PCI
-	help
-	  Fibre Channel is a high speed serial protocol mainly used to connect
-	  large storage devices to the computer; it is compatible with and
-	  intended to replace SCSI.
-
-	  If you intend to use Fibre Channel, you need to have a Fibre channel
-	  adaptor card in your computer; say Y here and to the driver for your
-	  adaptor below. You also should have said Y to "SCSI support" and
-	  "SCSI generic support".
-
-config NETCONSOLE
-	tristate "Network console logging support"
-	---help---
-	If you want to log kernel messages over the network, enable this.
-	See <file:Documentation/networking/netconsole.txt> for details.
-
-config NETCONSOLE_DYNAMIC
-	bool "Dynamic reconfiguration of logging targets"
-	depends on NETCONSOLE && SYSFS && CONFIGFS_FS && \
-			!(NETCONSOLE=y && CONFIGFS_FS=m)
-	help
-	  This option enables the ability to dynamically reconfigure target
-	  parameters (interface, IP addresses, port numbers, MAC addresses)
-	  at runtime through a userspace interface exported using configfs.
-	  See <file:Documentation/networking/netconsole.txt> for details.
-
-config NETPOLL
-	def_bool NETCONSOLE
-
-config NETPOLL_TRAP
-	bool "Netpoll traffic trapping"
-	default n
-	depends on NETPOLL
-
-config NET_POLL_CONTROLLER
-	def_bool NETPOLL
-
-config VIRTIO_NET
-	tristate "Virtio network driver (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && VIRTIO
-	---help---
-	  This is the virtual network driver for virtio.  It can be used with
-	  lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
-
 config VMXNET3
 	tristate "VMware VMXNET3 ethernet driver"
 	depends on PCI && INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d04d0ce..33ff347 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -2,46 +2,51 @@
 # Makefile for the Linux network device drivers.
 #
 
-obj-$(CONFIG_MII) += mii.o
-obj-$(CONFIG_MDIO) += mdio.o
-obj-$(CONFIG_PHYLIB) += phy/
-obj-$(CONFIG_CAN) += can/
-obj-$(CONFIG_BONDING) += bonding/
-obj-$(CONFIG_VMXNET3) += vmxnet3/
-
 #
-# link order important here
+# Networking Core Drivers
 #
-obj-$(CONFIG_RIONET) += rionet.o
-
-#
-# end link order section
-#
-
-obj-$(CONFIG_NET) += Space.o loopback.o
-obj-$(CONFIG_NET_SB1000) += sb1000.o
-
-obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
-obj-$(CONFIG_XEN_NETDEV_BACKEND) += xen-netback/
-
+obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_DUMMY) += dummy.o
+obj-$(CONFIG_EQUALIZER) += eql.o
 obj-$(CONFIG_IFB) += ifb.o
 obj-$(CONFIG_MACVLAN) += macvlan.o
 obj-$(CONFIG_MACVTAP) += macvtap.o
-obj-$(CONFIG_EQUALIZER) += eql.o
+obj-$(CONFIG_MII) += mii.o
+obj-$(CONFIG_MDIO) += mdio.o
+obj-$(CONFIG_NET) += Space.o loopback.o
+obj-$(CONFIG_NETCONSOLE) += netconsole.o
+obj-$(CONFIG_PHYLIB) += phy/
+obj-$(CONFIG_RIONET) += rionet.o
 obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
+obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 
+#
+# Networking Drivers
+#
+obj-$(CONFIG_ARCNET) += arcnet/
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
+obj-$(CONFIG_CAIF) += caif/
+obj-$(CONFIG_CAN) += can/
+obj-$(CONFIG_ETRAX_ETHERNET) += cris/
 obj-$(CONFIG_ETHERNET) += ethernet/
 obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_HIPPI) += hippi/
+obj-$(CONFIG_HAMRADIO) += hamradio/
+obj-$(CONFIG_IRDA) += irda/
 obj-$(CONFIG_PLIP) += plip/
 onj-$(CONFIG_PPP) += ppp/
+obj-$(CONFIG_NET_SB1000) += sb1000.o
 onj-$(CONFIG_SLIP) += slip/
+obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
 obj-$(CONFIG_TR) += tokenring/
 obj-$(CONFIG_WAN) += wan/
-obj-$(CONFIG_ARCNET) += arcnet/
+obj-$(CONFIG_WLAN) += wireless/
+obj-$(CONFIG_WIMAX) += wimax/
+
+obj-$(CONFIG_VMXNET3) += vmxnet3/
+obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
+obj-$(CONFIG_XEN_NETDEV_BACKEND) += xen-netback/
 
 obj-$(CONFIG_USB_CATC)          += usb/
 obj-$(CONFIG_USB_KAWETH)        += usb/
@@ -52,17 +57,3 @@ obj-$(CONFIG_USB_USBNET)        += usb/
 obj-$(CONFIG_USB_ZD1201)        += usb/
 obj-$(CONFIG_USB_IPHETH)        += usb/
 obj-$(CONFIG_USB_CDC_PHONET)   += usb/
-
-obj-$(CONFIG_WLAN) += wireless/
-obj-$(CONFIG_HAMRADIO) += hamradio/
-obj-$(CONFIG_IRDA) += irda/
-obj-$(CONFIG_ETRAX_ETHERNET) += cris/
-
-obj-$(CONFIG_NETCONSOLE) += netconsole.o
-
-obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
-
-obj-$(CONFIG_WIMAX) += wimax/
-obj-$(CONFIG_CAIF) += caif/
-
-obj-$(CONFIG_SUNGEM_PHY) += sungem_phy.o
diff --git a/drivers/net/arcnet/Kconfig b/drivers/net/arcnet/Kconfig
index 84fb634..a73d9dc 100644
--- a/drivers/net/arcnet/Kconfig
+++ b/drivers/net/arcnet/Kconfig
@@ -4,7 +4,7 @@
 
 menuconfig ARCNET
 	depends on NETDEVICES && (ISA || PCI || PCMCIA)
-	tristate "ARCnet support"
+	bool "ARCnet support"
 	---help---
 	  If you have a network card of this type, say Y and check out the
 	  (arguably) beautiful poetry in
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index a702443..bb88e12 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -3,7 +3,7 @@
 #
 
 menuconfig PHYLIB
-	tristate "PHY Device support and infrastructure"
+	bool "PHY Device support and infrastructure"
 	depends on !S390
 	depends on NETDEVICES
 	help
diff --git a/drivers/net/tokenring/Kconfig b/drivers/net/tokenring/Kconfig
index 0f70158..c7e0149 100644
--- a/drivers/net/tokenring/Kconfig
+++ b/drivers/net/tokenring/Kconfig
@@ -4,7 +4,7 @@
 
 # So far, we only have PCI, ISA, and MCA token ring devices
 menuconfig TR
-	tristate "Token Ring driver support"
+	bool "Token Ring driver support"
 	depends on NETDEVICES && !UML
 	depends on (PCI || ISA || MCA || CCW || PCMCIA)
 	select LLC
-- 
1.7.6
