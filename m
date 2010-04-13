From: "Hans J. Koch" <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: [PATCH - resubmit] Fix some #includes in CAN drivers (rebased for
	net-next-2.6)
Date: Tue, 13 Apr 2010 12:03:25 +0200
Message-ID: <20100413100324.GC2011@bluebox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Chris Elston <celston-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org>, Sebastian Haas <haas-zsNKPWJ8Piak0Ce0JJ2bFg@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Per Dalen <per.dalen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	Christian Pellegrin <chripell-LERDrqjqfvZg9hUCZPvPmw@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

In the current implementation, CAN drivers need to #include <linux/can.h>
_before_ they #include <linux/can/dev.h>, which is both ugly and
unnecessary.

Fix this by including <linux/can.h> in <linux/can/dev.h> and remove the
#include <linux/can.h> lines from drivers.

Signed-off-by: Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
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

Index: net-next-2.6/include/linux/can/dev.h
===================================================================
--- net-next-2.6.orig/include/linux/can/dev.h	2010-04-13 11:27:39.000000000 +0200
+++ net-next-2.6/include/linux/can/dev.h	2010-04-13 11:31:57.000000000 +0200
@@ -14,6 +14,7 @@
 #ifndef CAN_DEV_H
 #define CAN_DEV_H
 
+#include <linux/can.h>
 #include <linux/can/netlink.h>
 #include <linux/can/error.h>
 
Index: net-next-2.6/drivers/net/can/at91_can.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/at91_can.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/at91_can.c	2010-04-13 11:31:57.000000000 +0200
@@ -35,7 +35,6 @@
 #include <linux/string.h>
 #include <linux/types.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
Index: net-next-2.6/drivers/net/can/bfin_can.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/bfin_can.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/bfin_can.c	2010-04-13 11:31:57.000000000 +0200
@@ -18,7 +18,6 @@
 #include <linux/skbuff.h>
 #include <linux/platform_device.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
Index: net-next-2.6/drivers/net/can/mcp251x.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/mcp251x.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/mcp251x.c	2010-04-13 11:31:57.000000000 +0200
@@ -58,7 +58,6 @@
  *
  */
 
-#include <linux/can.h>
 #include <linux/can/core.h>
 #include <linux/can/dev.h>
 #include <linux/can/platform/mcp251x.h>
Index: net-next-2.6/drivers/net/can/ti_hecc.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/ti_hecc.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/ti_hecc.c	2010-04-13 11:31:57.000000000 +0200
@@ -47,7 +47,6 @@
 #include <linux/platform_device.h>
 #include <linux/clk.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 #include <linux/can/platform/ti_hecc.h>
Index: net-next-2.6/drivers/net/can/mscan/mpc5xxx_can.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/mscan/mpc5xxx_can.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/mscan/mpc5xxx_can.c	2010-04-13 11:31:57.000000000 +0200
@@ -25,7 +25,6 @@
 #include <linux/interrupt.h>
 #include <linux/platform_device.h>
 #include <linux/netdevice.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/of_platform.h>
 #include <sysdev/fsl_soc.h>
Index: net-next-2.6/drivers/net/can/mscan/mscan.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/mscan/mscan.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/mscan/mscan.c	2010-04-13 11:31:57.000000000 +0200
@@ -28,7 +28,6 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/list.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 #include <linux/io.h>
Index: net-next-2.6/drivers/net/can/sja1000/ems_pci.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/ems_pci.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/sja1000/ems_pci.c	2010-04-13 11:31:57.000000000 +0200
@@ -24,7 +24,6 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/io.h>
 
Index: net-next-2.6/drivers/net/can/sja1000/kvaser_pci.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/kvaser_pci.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/sja1000/kvaser_pci.c	2010-04-13 11:31:57.000000000 +0200
@@ -36,7 +36,6 @@
 #include <linux/netdevice.h>
 #include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/io.h>
 
Index: net-next-2.6/drivers/net/can/sja1000/plx_pci.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/plx_pci.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/sja1000/plx_pci.c	2010-04-13 11:31:57.000000000 +0200
@@ -27,7 +27,6 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/pci.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/io.h>
 
Index: net-next-2.6/drivers/net/can/sja1000/sja1000.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000.c	2010-04-13 11:31:57.000000000 +0200
@@ -60,7 +60,6 @@
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/error.h>
 
Index: net-next-2.6/drivers/net/can/sja1000/sja1000_isa.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000_isa.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000_isa.c	2010-04-13 11:31:57.000000000 +0200
@@ -23,7 +23,6 @@
 #include <linux/delay.h>
 #include <linux/irq.h>
 #include <linux/io.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/platform/sja1000.h>
 
Index: net-next-2.6/drivers/net/can/sja1000/sja1000_of_platform.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000_of_platform.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000_of_platform.c	2010-04-13 11:31:57.000000000 +0200
@@ -38,7 +38,6 @@
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/delay.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 
 #include <linux/of_platform.h>
Index: net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c
===================================================================
--- net-next-2.6.orig/drivers/net/can/sja1000/sja1000_platform.c	2010-04-13 11:27:33.000000000 +0200
+++ net-next-2.6/drivers/net/can/sja1000/sja1000_platform.c	2010-04-13 11:31:57.000000000 +0200
@@ -24,7 +24,6 @@
 #include <linux/pci.h>
 #include <linux/platform_device.h>
 #include <linux/irq.h>
-#include <linux/can.h>
 #include <linux/can/dev.h>
 #include <linux/can/platform/sja1000.h>
 #include <linux/io.h>
