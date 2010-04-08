From: "Hans J. Koch" <hjk@linutronix.de>
Subject: [PATCH] Fix some #includes in CAN drivers
Date: Thu, 8 Apr 2010 21:25:45 +0200
Message-ID: <20100408192545.GD2004@bluebox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	Barry Song <21cnbao@gmail.com>,
	Chris Elston <celston@katalix.com>,
	Christian Pellegrin <chripell@evolware.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Sebastian Haas <haas@ems-wuenche.com>,
	Per Dalen <per.dalen@cnw.se>,
	Pavel Cheblakov <P.B.Cheblakov@inp.nsk.su>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Anant Gole <anantgole@ti.com>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:45729 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab0DHT07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 15:26:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current implementation, CAN drivers need to #include <linux/can.h>
_before_ they #include <linux/can/dev.h>, which is both ugly and
unnecessary.

Fix this by including <linux/can.h> in <linux/can/dev.h> and remove the
#include <linux/can.h> lines from drivers.

Signed-off-by: Hans J. Koch <hjk@linutronix.de>
---
 drivers/net/can/at91_can.c                    |    1 -
 drivers/net/can/bfin_can.c                    |    1 -
 drivers/net/can/mcp251x.c                     |    1 -
 drivers/net/can/mscan/mpc5xxx_can.c           |    1 -
 drivers/net/can/mscan/mscan.c                 |    1 -
 drivers/net/can/sja1000/ems_pci.c             |    1 -
 drivers/net/can/sja1000/kvaser_pci.c          |    1 -
 drivers/net/can/sja1000/plx_pci.c             |    1 -
 drivers/net/can/sja1000/sja1000.c             |    1 -
 drivers/net/can/sja1000/sja1000_isa.c         |    1 -
 drivers/net/can/sja1000/sja1000_of_platform.c |    1 -
 drivers/net/can/sja1000/sja1000_platform.c    |    1 -
 drivers/net/can/ti_hecc.c                     |    1 -
 include/linux/can/dev.h                       |    1 +
 14 files changed, 1 insertion(+), 13 deletions(-)

Index: linux-2.6.34-rc/include/linux/can/dev.h
===================================================================
--- linux-2.6.34-rc.orig/include/linux/can/dev.h	2010-04-08 19:37:34.000000000 +0200
+++ linux-2.6.34-rc/include/linux/can/dev.h	2010-04-08 19:37:50.000000000 +0200
@@ -14,6 +14,7 @@
 #ifndef CAN_DEV_H
 #define CAN_DEV_H
 
+#include <linux/can.h>
 #include <linux/can/netlink.h>
 #include <linux/can/error.h>
 
Index: linux-2.6.34-rc/drivers/net/can/at91_can.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/at91_can.c	2010-04-08 20:52:22.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/at91_can.c	2010-04-08 20:52:47.000000000 +0200
@@ -35,7 +35,6 @@
 #include <linux/string.h>
 #include <linux/types.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
Index: linux-2.6.34-rc/drivers/net/can/bfin_can.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/bfin_can.c	2010-04-08 20:53:15.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/bfin_can.c	2010-04-08 20:53:25.000000000 +0200
@@ -18,7 +18,6 @@
 #include <linux/skbuff.h>
 #include <linux/platform_device.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
Index: linux-2.6.34-rc/drivers/net/can/mcp251x.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/mcp251x.c	2010-04-08 20:53:47.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/mcp251x.c	2010-04-08 20:54:04.000000000 +0200
@@ -58,7 +58,6 @@
  *
  */
 
-#include <linux/can.h>
 #include <linux/can/core.h>
 #include <linux/can/dev.h>
 #include <linux/can/platform/mcp251x.h>
Index: linux-2.6.34-rc/drivers/net/can/ti_hecc.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/ti_hecc.c	2010-04-08 20:54:35.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/ti_hecc.c	2010-04-08 20:54:45.000000000 +0200
@@ -47,7 +47,6 @@
 #include <linux/platform_device.h>
 #include <linux/clk.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 #include <linux/can/platform/ti_hecc.h>
Index: linux-2.6.34-rc/drivers/net/can/mscan/mpc5xxx_can.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/mscan/mpc5xxx_can.c	2010-04-08 20:55:16.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/mscan/mpc5xxx_can.c	2010-04-08 20:55:26.000000000 +0200
@@ -25,7 +25,6 @@
 #include <linux/interrupt.h>
 #include <linux/platform_device.h>
 #include <linux/netdevice.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/of_platform.h>
 #include <sysdev/fsl_soc.h>
Index: linux-2.6.34-rc/drivers/net/can/mscan/mscan.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/mscan/mscan.c	2010-04-08 20:55:55.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/mscan/mscan.c	2010-04-08 20:56:08.000000000 +0200
@@ -28,7 +28,6 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/list.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 #include <linux/io.h>
Index: linux-2.6.34-rc/drivers/net/can/sja1000/ems_pci.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/sja1000/ems_pci.c	2010-04-08 20:56:48.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/sja1000/ems_pci.c	2010-04-08 20:57:17.000000000 +0200
@@ -23,7 +23,6 @@
 #include <linux/netdevice.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/io.h>
 
Index: linux-2.6.34-rc/drivers/net/can/sja1000/kvaser_pci.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/sja1000/kvaser_pci.c	2010-04-08 20:57:39.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/sja1000/kvaser_pci.c	2010-04-08 20:57:49.000000000 +0200
@@ -36,7 +36,6 @@
 #include <linux/netdevice.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/io.h>
 
Index: linux-2.6.34-rc/drivers/net/can/sja1000/plx_pci.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/sja1000/plx_pci.c	2010-04-08 20:58:00.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/sja1000/plx_pci.c	2010-04-08 20:58:09.000000000 +0200
@@ -26,7 +26,6 @@
 #include <linux/netdevice.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/io.h>
 
Index: linux-2.6.34-rc/drivers/net/can/sja1000/sja1000.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/sja1000/sja1000.c	2010-04-08 20:59:31.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/sja1000/sja1000.c	2010-04-08 20:59:50.000000000 +0200
@@ -60,7 +60,6 @@
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
Index: linux-2.6.34-rc/drivers/net/can/sja1000/sja1000_isa.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/sja1000/sja1000_isa.c	2010-04-08 20:59:55.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/sja1000/sja1000_isa.c	2010-04-08 21:00:06.000000000 +0200
@@ -23,7 +23,6 @@
 #include <linux/delay.h>
 #include <linux/irq.h>
 #include <linux/io.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/platform/sja1000.h>
 
Index: linux-2.6.34-rc/drivers/net/can/sja1000/sja1000_of_platform.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/sja1000/sja1000_of_platform.c	2010-04-08 20:58:44.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/sja1000/sja1000_of_platform.c	2010-04-08 20:58:52.000000000 +0200
@@ -38,7 +38,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/delay.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 
 #include <linux/of_platform.h>
Index: linux-2.6.34-rc/drivers/net/can/sja1000/sja1000_platform.c
===================================================================
--- linux-2.6.34-rc.orig/drivers/net/can/sja1000/sja1000_platform.c	2010-04-08 20:59:04.000000000 +0200
+++ linux-2.6.34-rc/drivers/net/can/sja1000/sja1000_platform.c	2010-04-08 20:59:11.000000000 +0200
@@ -24,7 +24,6 @@
 #include <linux/pci.h>
 #include <linux/platform_device.h>
 #include <linux/irq.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/platform/sja1000.h>
 #include <linux/io.h>
