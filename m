From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH net-2.6] can: Fix driver Kconfig structure
Date: Thu, 12 Nov 2009 12:35:01 +0100
Message-ID: <4AFBF2E5.1090909@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070803090202020907000405"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	SocketCAN Core Mailing List <socketcan-core@lists.berlios.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:27852 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbZKLLfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 06:35:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070803090202020907000405
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

In 2.6.32-rc the new EMS USB CAN driver was contributed and added the Kconfig
entry right behind an entry of the same *vendor*. This teared the SJA1000
based driver selection into pieces.

This fix cleans up the 2.6.32-rc Kconfig files for the CAN drivers and moves
the SJA1000 and USB Kconfig portions into the belonging directories.

As there are many new CAN drivers in the queue getting this cleanup into
2.6.32-rc would massively reduce the problems for the upcoming drivers.

Thanks,
Oliver

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

---



--------------070803090202020907000405
Content-Type: text/x-patch;
 name="can-kconfig-fix-net-2.6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can-kconfig-fix-net-2.6.patch"

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index df32c10..772f6d2 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -35,66 +35,16 @@ config CAN_CALC_BITTIMING
 	  arguments "tq", "prop_seg", "phase_seg1", "phase_seg2" and "sjw".
 	  If unsure, say Y.
 
-config CAN_SJA1000
-	depends on CAN_DEV && HAS_IOMEM
-	tristate "Philips SJA1000"
-	---help---
-	  Driver for the SJA1000 CAN controllers from Philips or NXP
-
-config CAN_SJA1000_ISA
-	depends on CAN_SJA1000 && ISA
-	tristate "ISA Bus based legacy SJA1000 driver"
-	---help---
-	  This driver adds legacy support for SJA1000 chips connected to
-	  the ISA bus using I/O port, memory mapped or indirect access.
-
-config CAN_SJA1000_PLATFORM
-	depends on CAN_SJA1000
-	tristate "Generic Platform Bus based SJA1000 driver"
-	---help---
-	  This driver adds support for the SJA1000 chips connected to
-	  the "platform bus" (Linux abstraction for directly to the
-	  processor attached devices).  Which can be found on various
-	  boards from Phytec (http://www.phytec.de) like the PCM027,
-	  PCM038.
-
-config CAN_SJA1000_OF_PLATFORM
-	depends on CAN_SJA1000 && PPC_OF
-	tristate "Generic OF Platform Bus based SJA1000 driver"
-	---help---
-	  This driver adds support for the SJA1000 chips connected to
-	  the OpenFirmware "platform bus" found on embedded systems with
-	  OpenFirmware bindings, e.g. if you have a PowerPC based system
-	  you may want to enable this option.
-
-config CAN_EMS_PCI
-	tristate "EMS CPC-PCI, CPC-PCIe and CPC-104P Card"
-	depends on PCI && CAN_SJA1000
-	---help---
-	  This driver is for the one, two or four channel CPC-PCI,
-	  CPC-PCIe and CPC-104P cards from EMS Dr. Thomas Wuensche
-	  (http://www.ems-wuensche.de).
-
-config CAN_EMS_USB
-	tristate "EMS CPC-USB/ARM7 CAN/USB interface"
-	depends on USB && CAN_DEV
-	---help---
-	  This driver is for the one channel CPC-USB/ARM7 CAN/USB interface
-	  from from EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
-
-config CAN_KVASER_PCI
-	tristate "Kvaser PCIcanx and Kvaser PCIcan PCI Cards"
-	depends on PCI && CAN_SJA1000
-	---help---
-	  This driver is for the the PCIcanx and PCIcan cards (1, 2 or
-	  4 channel) from Kvaser (http://www.kvaser.com).
-
 config CAN_AT91
 	tristate "Atmel AT91 onchip CAN controller"
-	depends on CAN && CAN_DEV && ARCH_AT91SAM9263
+	depends on CAN_DEV && ARCH_AT91SAM9263
 	---help---
 	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
 
+source "drivers/net/can/sja1000/Kconfig"
+
+source "drivers/net/can/usb/Kconfig"
+
 config CAN_DEBUG_DEVICES
 	bool "CAN devices debugging messages"
 	depends on CAN
diff --git a/drivers/net/can/sja1000/Kconfig b/drivers/net/can/sja1000/Kconfig
new file mode 100644
index 0000000..4c67492
--- /dev/null
+++ b/drivers/net/can/sja1000/Kconfig
@@ -0,0 +1,47 @@
+menuconfig CAN_SJA1000
+	tristate "Philips/NXP SJA1000 devices"
+	depends on CAN_DEV && HAS_IOMEM
+
+if CAN_SJA1000
+
+config CAN_SJA1000_ISA
+	tristate "ISA Bus based legacy SJA1000 driver"
+	depends on ISA
+	---help---
+	  This driver adds legacy support for SJA1000 chips connected to
+	  the ISA bus using I/O port, memory mapped or indirect access.
+
+config CAN_SJA1000_PLATFORM
+	tristate "Generic Platform Bus based SJA1000 driver"
+	---help---
+	  This driver adds support for the SJA1000 chips connected to
+	  the "platform bus" (Linux abstraction for directly to the
+	  processor attached devices).  Which can be found on various
+	  boards from Phytec (http://www.phytec.de) like the PCM027,
+	  PCM038.
+
+config CAN_SJA1000_OF_PLATFORM
+	tristate "Generic OF Platform Bus based SJA1000 driver"
+	depends on PPC_OF
+	---help---
+	  This driver adds support for the SJA1000 chips connected to
+	  the OpenFirmware "platform bus" found on embedded systems with
+	  OpenFirmware bindings, e.g. if you have a PowerPC based system
+	  you may want to enable this option.
+
+config CAN_EMS_PCI
+	tristate "EMS CPC-PCI, CPC-PCIe and CPC-104P Card"
+	depends on PCI
+	---help---
+	  This driver is for the one, two or four channel CPC-PCI,
+	  CPC-PCIe and CPC-104P cards from EMS Dr. Thomas Wuensche
+	  (http://www.ems-wuensche.de).
+
+config CAN_KVASER_PCI
+	tristate "Kvaser PCIcanx and Kvaser PCIcan PCI Cards"
+	depends on PCI
+	---help---
+	  This driver is for the the PCIcanx and PCIcan cards (1, 2 or
+	  4 channel) from Kvaser (http://www.kvaser.com).
+
+endif
diff --git a/drivers/net/can/usb/Kconfig b/drivers/net/can/usb/Kconfig
new file mode 100644
index 0000000..bbc78e0
--- /dev/null
+++ b/drivers/net/can/usb/Kconfig
@@ -0,0 +1,10 @@
+menu "CAN USB interfaces"
+	depends on USB && CAN_DEV
+
+config CAN_EMS_USB
+	tristate "EMS CPC-USB/ARM7 CAN/USB interface"
+	---help---
+	  This driver is for the one channel CPC-USB/ARM7 CAN/USB interface
+	  from from EMS Dr. Thomas Wuensche (http://www.ems-wuensche.de).
+
+endmenu
diff --git a/drivers/net/can/usb/Makefile b/drivers/net/can/usb/Makefile
index c3f75ba..0afd51d 100644
--- a/drivers/net/can/usb/Makefile
+++ b/drivers/net/can/usb/Makefile
@@ -3,3 +3,5 @@
 #
 
 obj-$(CONFIG_CAN_EMS_USB) += ems_usb.o
+
+ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG

--------------070803090202020907000405--
