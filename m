From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] drivers/net: fix up stale paths from driver reorg
Date: Fri, 27 Jan 2012 18:36:01 -0500
Message-ID: <1327707361-30274-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43984 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab2A0XgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 18:36:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The reorganization of the driver layout in drivers/net
left behind some stale paths in comments and in Kconfig
help text.  Bring them up to date.  No actual change to
any code takes place here.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

diff --git a/Documentation/magic-number.txt b/Documentation/magic-number.txt
index abf481f..82761a3 100644
--- a/Documentation/magic-number.txt
+++ b/Documentation/magic-number.txt
@@ -89,7 +89,7 @@ TTY_DRIVER_MAGIC      0x5402      tty_driver        include/linux/tty_driver.h
 MGSLPC_MAGIC          0x5402      mgslpc_info       drivers/char/pcmcia/synclink_cs.c
 TTY_LDISC_MAGIC       0x5403      tty_ldisc         include/linux/tty_ldisc.h
 USB_SERIAL_MAGIC      0x6702      usb_serial        drivers/usb/serial/usb-serial.h
-FULL_DUPLEX_MAGIC     0x6969                        drivers/net/tulip/de2104x.c
+FULL_DUPLEX_MAGIC     0x6969                        drivers/net/ethernet/dec/tulip/de2104x.c
 USB_BLUETOOTH_MAGIC   0x6d02      usb_bluetooth     drivers/usb/class/bluetty.c
 RFCOMM_TTY_MAGIC      0x6d02                        net/bluetooth/rfcomm/tty.c
 USB_SERIAL_PORT_MAGIC 0x7301      usb_serial_port   drivers/usb/serial/usb-serial.h
diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index 9eb1ba5..95e5f59 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -62,7 +62,8 @@ The MDIO bus
  5) The bus must also be declared somewhere as a device, and registered.
 
  As an example for how one driver implemented an mdio bus driver, see
- drivers/net/gianfar_mii.c and arch/ppc/syslib/mpc85xx_devices.c
+ drivers/net/ethernet/freescale/fsl_pq_mdio.c and an associated DTS file
+ for one of the users. (e.g. "git grep fsl,.*-mdio arch/powerpc/boot/dts/")
 
 Connecting to a PHY
 
diff --git a/Documentation/zh_CN/magic-number.txt b/Documentation/zh_CN/magic-number.txt
index c278f41..f606ba8 100644
--- a/Documentation/zh_CN/magic-number.txt
+++ b/Documentation/zh_CN/magic-number.txt
@@ -89,7 +89,7 @@ TTY_DRIVER_MAGIC      0x5402      tty_driver        include/linux/tty_driver.h
 MGSLPC_MAGIC          0x5402      mgslpc_info       drivers/char/pcmcia/synclink_cs.c
 TTY_LDISC_MAGIC       0x5403      tty_ldisc         include/linux/tty_ldisc.h
 USB_SERIAL_MAGIC      0x6702      usb_serial        drivers/usb/serial/usb-serial.h
-FULL_DUPLEX_MAGIC     0x6969                        drivers/net/tulip/de2104x.c
+FULL_DUPLEX_MAGIC     0x6969                        drivers/net/ethernet/dec/tulip/de2104x.c
 USB_BLUETOOTH_MAGIC   0x6d02      usb_bluetooth     drivers/usb/class/bluetty.c
 RFCOMM_TTY_MAGIC      0x6d02                        net/bluetooth/rfcomm/tty.c
 USB_SERIAL_PORT_MAGIC 0x7301      usb_serial_port   drivers/usb/serial/usb-serial.h
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 3f1ebcc..579e7fc 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -1,7 +1,7 @@
 /*
  * slcan.c - serial line CAN interface driver (using tty line discipline)
  *
- * This file is derived from linux/drivers/net/slip.c
+ * This file is derived from linux/drivers/net/slip/slip.c
  *
  * slip.c Authors  : Laurence Culhane <loz@holmes.demon.co.uk>
  *                   Fred N. van Kempen <waltje@uwalt.nl.mugnet.org>
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index a8bb30c..bad4fa6 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -97,7 +97,7 @@ config VORTEX
 	  available from <http://www.tldp.org/docs.html#howto>. More
 	  specific information is in
 	  <file:Documentation/networking/vortex.txt> and in the comments at
-	  the beginning of <file:drivers/net/3c59x.c>.
+	  the beginning of <file:drivers/net/ethernet/3com/3c59x.c>.
 
 	  To compile this support as a module, choose M here.
 
diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 0f92e35..c30adcc 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -1,4 +1,4 @@
-/* drivers/net/ax88796.c
+/* drivers/net/ethernet/8390/ax88796.c
  *
  * Copyright 2005,2007 Simtec Electronics
  *	Ben Dooks <ben@simtec.co.uk>
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index bba51cd..5de3943 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -192,7 +192,7 @@ static int get_prom(struct pcmcia_device *link)
     unsigned int ioaddr = dev->base_addr;
     int i, j;
 
-    /* This is based on drivers/net/ne.c */
+    /* This is based on drivers/net/ethernet/8390/ne.c */
     struct {
 	u_char value, offset;
     } program_seq[] = {
diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index 053b255..f2a4e5d 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -326,7 +326,7 @@ static hw_info_t *get_prom(struct pcmcia_device *link)
     u_char prom[32];
     int i, j;
 
-    /* This is lifted straight from drivers/net/ne.c */
+    /* This is lifted straight from drivers/net/ethernet/8390/ne.c */
     struct {
 	u_char value, offset;
     } program_seq[] = {
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 238b537..8350f4b 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -113,7 +113,7 @@ config DEPCA
 	  If you have a network (Ethernet) card of this type, say Y and read
 	  the Ethernet-HOWTO, available from
 	  <http://www.tldp.org/docs.html#howto> as well as
-	  <file:drivers/net/depca.c>.
+	  <file:drivers/net/ethernet/amd/depca.c>.
 
 	  To compile this driver as a module, choose M here. The module
 	  will be called depca.
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 7d5ded8..216ae87 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/am79c961.c
+ *  linux/drivers/net/ethernet/amd/am79c961a.c
  *
  *  by Russell King <rmk@arm.linux.org.uk> 1995-2001.
  *
diff --git a/drivers/net/ethernet/amd/am79c961a.h b/drivers/net/ethernet/amd/am79c961a.h
index fd634d3..9f384b7 100644
--- a/drivers/net/ethernet/amd/am79c961a.h
+++ b/drivers/net/ethernet/amd/am79c961a.h
@@ -1,5 +1,5 @@
 /*
- * linux/drivers/net/arm/am79c961a.h
+ * linux/drivers/net/ethernet/amd/am79c961a.h
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
diff --git a/drivers/net/ethernet/dec/tulip/21142.c b/drivers/net/ethernet/dec/tulip/21142.c
index 25b8dee..3698582 100644
--- a/drivers/net/ethernet/dec/tulip/21142.c
+++ b/drivers/net/ethernet/dec/tulip/21142.c
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/21142.c
+	drivers/net/ethernet/dec/tulip/21142.c
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/dec/tulip/eeprom.c b/drivers/net/ethernet/dec/tulip/eeprom.c
index 14d5b61..ed7d1dc 100644
--- a/drivers/net/ethernet/dec/tulip/eeprom.c
+++ b/drivers/net/ethernet/dec/tulip/eeprom.c
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/eeprom.c
+	drivers/net/ethernet/dec/tulip/eeprom.c
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 4fb8c8c..feaee74 100644
--- a/drivers/net/ethernet/dec/tulip/interrupt.c
+++ b/drivers/net/ethernet/dec/tulip/interrupt.c
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/interrupt.c
+	drivers/net/ethernet/dec/tulip/interrupt.c
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/dec/tulip/media.c b/drivers/net/ethernet/dec/tulip/media.c
index beeb17b..ae937c6 100644
--- a/drivers/net/ethernet/dec/tulip/media.c
+++ b/drivers/net/ethernet/dec/tulip/media.c
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/media.c
+	drivers/net/ethernet/dec/tulip/media.c
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/dec/tulip/pnic.c b/drivers/net/ethernet/dec/tulip/pnic.c
index 9c16e4a..5364563 100644
--- a/drivers/net/ethernet/dec/tulip/pnic.c
+++ b/drivers/net/ethernet/dec/tulip/pnic.c
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/pnic.c
+	drivers/net/ethernet/dec/tulip/pnic.c
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/dec/tulip/pnic2.c b/drivers/net/ethernet/dec/tulip/pnic2.c
index 04a7e47..5895fc4 100644
--- a/drivers/net/ethernet/dec/tulip/pnic2.c
+++ b/drivers/net/ethernet/dec/tulip/pnic2.c
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/pnic2.c
+	drivers/net/ethernet/dec/tulip/pnic2.c
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/dec/tulip/timer.c b/drivers/net/ethernet/dec/tulip/timer.c
index 19078d2..768379b 100644
--- a/drivers/net/ethernet/dec/tulip/timer.c
+++ b/drivers/net/ethernet/dec/tulip/timer.c
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/timer.c
+	drivers/net/ethernet/dec/tulip/timer.c
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/dec/tulip/tulip.h b/drivers/net/ethernet/dec/tulip/tulip.h
index fb3887c..38431a1 100644
--- a/drivers/net/ethernet/dec/tulip/tulip.h
+++ b/drivers/net/ethernet/dec/tulip/tulip.h
@@ -1,5 +1,5 @@
 /*
-	drivers/net/tulip/tulip.h
+	drivers/net/ethernet/dec/tulip/tulip.h
 
 	Copyright 2000,2001  The Linux Kernel Team
 	Written/copyright 1994-2001 by Donald Becker.
diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 60f0e78..388c592 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1,5 +1,5 @@
 /*
- * linux/drivers/net/ethoc.c
+ * linux/drivers/net/ethernet/ethoc.c
  *
  * Copyright (C) 2007-2008 Avionic Design Development GmbH
  * Copyright (C) 2008-2009 Avionic Design GmbH
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.h b/drivers/net/ethernet/freescale/fec_mpc52xx.h
index 41d2dff..10afa54 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.h
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.h
@@ -1,5 +1,5 @@
 /*
- * drivers/drivers/net/fec_mpc52xx/fec.h
+ * drivers/net/ethernet/freescale/fec_mpc52xx.h
  *
  * Driver for the MPC5200 Fast Ethernet Controller
  *
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 39d160d..adb0ae4 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/gianfar.c
+ * drivers/net/ethernet/freescale/gianfar.c
  *
  * Gianfar Ethernet Driver
  * This driver is designed for the non-CPM ethernet controllers
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 40c33a7..4fe0f34 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/gianfar.h
+ * drivers/net/ethernet/freescale/gianfar.h
  *
  * Gianfar Ethernet Driver
  * Driver for FEC on MPC8540 and TSEC on MPC8540/MPC8560
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 5a3b2e5..5a78d55 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1,5 +1,5 @@
 /*
- *  drivers/net/gianfar_ethtool.c
+ *  drivers/net/ethernet/freescale/gianfar_ethtool.c
  *
  *  Gianfar Ethernet Driver
  *  Ethtool support for Gianfar Enet
diff --git a/drivers/net/ethernet/freescale/gianfar_sysfs.c b/drivers/net/ethernet/freescale/gianfar_sysfs.c
index 64f4094..cd14a4d 100644
--- a/drivers/net/ethernet/freescale/gianfar_sysfs.c
+++ b/drivers/net/ethernet/freescale/gianfar_sysfs.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/gianfar_sysfs.c
+ * drivers/net/ethernet/freescale/gianfar_sysfs.c
  *
  * Gianfar Ethernet Driver
  * This driver is designed for the non-CPM ethernet controllers
diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index 6650068..b8e46cc 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea.h
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea.h
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
index 6bdd8e3..95837b9 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea_ethtool.c
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_hw.h b/drivers/net/ethernet/ibm/ehea/ehea_hw.h
index 1a2fe4d..180d412 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_hw.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea_hw.h
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea_hw.h
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea_hw.h
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 5d5fb26..14507d1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea_main.c
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea_main.c
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_phyp.c b/drivers/net/ethernet/ibm/ehea/ehea_phyp.c
index 0506967..30f9033 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_phyp.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_phyp.c
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea_phyp.c
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea_phyp.c
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_phyp.h b/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
index 2f8174c..52c456e 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea_phyp.h
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
index c25b05b..4fb47f1 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea_qmr.c
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.h b/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
index 337a47e..8e4a70c 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
@@ -1,5 +1,5 @@
 /*
- *  linux/drivers/net/ehea/ehea_qmr.h
+ *  linux/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
  *
  *  eHEA ethernet device driver for IBM eServer System p
  *
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index 2abce96..d47c16e 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/core.c
+ * drivers/net/ethernet/ibm/emac/core.c
  *
  * Driver for PowerPC 4xx on-chip ethernet controller.
  *
diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index fa3ec57..bade296 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/core.h
+ * drivers/net/ethernet/ibm/emac/core.h
  *
  * Driver for PowerPC 4xx on-chip ethernet controller.
  *
diff --git a/drivers/net/ethernet/ibm/emac/debug.c b/drivers/net/ethernet/ibm/emac/debug.c
index 8c6c1e2..b16b482 100644
--- a/drivers/net/ethernet/ibm/emac/debug.c
+++ b/drivers/net/ethernet/ibm/emac/debug.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/debug.c
+ * drivers/net/ethernet/ibm/emac/debug.c
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
  *
diff --git a/drivers/net/ethernet/ibm/emac/debug.h b/drivers/net/ethernet/ibm/emac/debug.h
index 90477fe..59a92d5 100644
--- a/drivers/net/ethernet/ibm/emac/debug.h
+++ b/drivers/net/ethernet/ibm/emac/debug.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/debug.h
+ * drivers/net/ethernet/ibm/emac/debug.h
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
  *
diff --git a/drivers/net/ethernet/ibm/emac/emac.h b/drivers/net/ethernet/ibm/emac/emac.h
index 1568278..b44bd24 100644
--- a/drivers/net/ethernet/ibm/emac/emac.h
+++ b/drivers/net/ethernet/ibm/emac/emac.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/emac.h
+ * drivers/net/ethernet/ibm/emac/emac.h
  *
  * Register definitions for PowerPC 4xx on-chip ethernet contoller
  *
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index f3c50b9..479e43e 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/mal.c
+ * drivers/net/ethernet/ibm/emac/mal.c
  *
  * Memory Access Layer (MAL) support
  *
diff --git a/drivers/net/ethernet/ibm/emac/mal.h b/drivers/net/ethernet/ibm/emac/mal.h
index d06f985..e431a32 100644
--- a/drivers/net/ethernet/ibm/emac/mal.h
+++ b/drivers/net/ethernet/ibm/emac/mal.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/mal.h
+ * drivers/net/ethernet/ibm/emac/mal.h
  *
  * Memory Access Layer (MAL) support
  *
diff --git a/drivers/net/ethernet/ibm/emac/phy.c b/drivers/net/ethernet/ibm/emac/phy.c
index ab4e596..d3b9d10 100644
--- a/drivers/net/ethernet/ibm/emac/phy.c
+++ b/drivers/net/ethernet/ibm/emac/phy.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/phy.c
+ * drivers/net/ethernet/ibm/emac/phy.c
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, PHY support.
  * Borrowed from sungem_phy.c, though I only kept the generic MII
diff --git a/drivers/net/ethernet/ibm/emac/phy.h b/drivers/net/ethernet/ibm/emac/phy.h
index 5d2bf4c..d7e41ec 100644
--- a/drivers/net/ethernet/ibm/emac/phy.h
+++ b/drivers/net/ethernet/ibm/emac/phy.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/phy.h
+ * drivers/net/ethernet/ibm/emac/phy.h
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, PHY support
  *
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
index 4fa53f3..05484f9 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.c
+++ b/drivers/net/ethernet/ibm/emac/rgmii.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/rgmii.c
+ * drivers/net/ethernet/ibm/emac/rgmii.c
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
  *
diff --git a/drivers/net/ethernet/ibm/emac/rgmii.h b/drivers/net/ethernet/ibm/emac/rgmii.h
index 9296b6c..668bcee 100644
--- a/drivers/net/ethernet/ibm/emac/rgmii.h
+++ b/drivers/net/ethernet/ibm/emac/rgmii.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/rgmii.h
+ * drivers/net/ethernet/ibm/emac/rgmii.h
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, RGMII bridge support.
  *
diff --git a/drivers/net/ethernet/ibm/emac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
index 5f51bf7..0d9881e 100644
--- a/drivers/net/ethernet/ibm/emac/tah.c
+++ b/drivers/net/ethernet/ibm/emac/tah.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/tah.c
+ * drivers/net/ethernet/ibm/emac/tah.c
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
  *
diff --git a/drivers/net/ethernet/ibm/emac/tah.h b/drivers/net/ethernet/ibm/emac/tah.h
index 3437ab4..350b709 100644
--- a/drivers/net/ethernet/ibm/emac/tah.h
+++ b/drivers/net/ethernet/ibm/emac/tah.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/tah.h
+ * drivers/net/ethernet/ibm/emac/tah.h
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, TAH support.
  *
diff --git a/drivers/net/ethernet/ibm/emac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
index 97449e7..e799a61 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.c
+++ b/drivers/net/ethernet/ibm/emac/zmii.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/zmii.c
+ * drivers/net/ethernet/ibm/emac/zmii.c
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
  *
diff --git a/drivers/net/ethernet/ibm/emac/zmii.h b/drivers/net/ethernet/ibm/emac/zmii.h
index ceaed82..455bfb0 100644
--- a/drivers/net/ethernet/ibm/emac/zmii.h
+++ b/drivers/net/ethernet/ibm/emac/zmii.h
@@ -1,5 +1,5 @@
 /*
- * drivers/net/ibm_newemac/zmii.h
+ * drivers/net/ethernet/ibm/emac/zmii.h
  *
  * Driver for PowerPC 4xx on-chip ethernet controller, ZMII bridge support.
  *
diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 6b35e7d..134c4d0 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1,4 +1,4 @@
-/* drivers/net/ks8851.c
+/* drivers/net/ethernet/micrel/ks8851.c
  *
  * Copyright 2009 Simtec Electronics
  *	http://www.simtec.co.uk/
diff --git a/drivers/net/ethernet/micrel/ks8851.h b/drivers/net/ethernet/micrel/ks8851.h
index b0fae86..852256e 100644
--- a/drivers/net/ethernet/micrel/ks8851.h
+++ b/drivers/net/ethernet/micrel/ks8851.h
@@ -1,4 +1,4 @@
-/* drivers/net/ks8851.h
+/* drivers/net/ethernet/micrel/ks8851.h
  *
  * Copyright 2009 Simtec Electronics
  *      Ben Dooks <ben@simtec.co.uk>
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index e58e78e..a37264e 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -1,5 +1,5 @@
 /**
- * drivers/net/ks8851_mll.c
+ * drivers/net/ethernet/micrel/ks8851_mll.c
  * Copyright (c) 2009 Micrel Inc.
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index e52cd31..2725d69 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -1,5 +1,5 @@
 /**
- * drivers/net/ksx884x.c - Micrel KSZ8841/2 PCI Ethernet driver
+ * drivers/net/ethernet/micrel/ksx884x.c - Micrel KSZ8841/2 PCI Ethernet driver
  *
  * Copyright (c) 2009-2010 Micrel, Inc.
  * 	Tristram Ha <Tristram.Ha@micrel.com>
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 8d288af..a18bb10 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -1,5 +1,5 @@
 /*
- * drivers/net/netx-eth.c
+ * drivers/net/ethernet/netx-eth.c
  *
  * Copyright (c) 2005 Sascha Hauer <s.hauer@pengutronix.de>, Pengutronix
  *
diff --git a/drivers/net/ethernet/realtek/Kconfig b/drivers/net/ethernet/realtek/Kconfig
index 0578859..5821966 100644
--- a/drivers/net/ethernet/realtek/Kconfig
+++ b/drivers/net/ethernet/realtek/Kconfig
@@ -24,11 +24,11 @@ config ATP
 	select CRC32
 	---help---
 	  This is a network (Ethernet) device which attaches to your parallel
-	  port. Read <file:drivers/net/atp.c> as well as the Ethernet-HOWTO,
-	  available from <http://www.tldp.org/docs.html#howto>, if you
-	  want to use this.  If you intend to use this driver, you should have
-	  said N to the "Parallel printer support", because the two drivers
-	  don't like each other.
+	  port. Read <file:drivers/net/ethernet/realtek/atp.c> as well as the
+	  Ethernet-HOWTO, available from <http://www.tldp.org/docs.html#howto>,
+	  if you want to use this.  If you intend to use this driver, you
+	  should have said N to the "Parallel printer support", because the two
+	  drivers don't like each other.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called atp.
-- 
1.7.7
