From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 1/8] orinoco: Remove inneeded system includes.
Date: Fri, 23 Sep 2005 04:18:07 -0400
Message-ID: <E1EIikx-0003sj-5A@gnu.org>
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

Remove inneeded system includes.

Most system includes are not needed.  In particular, the hardware
backends don't need anything network related.  Some includes have been
moved from local headers to the C files where they are actually used.
Includes that have to be in the local headers are no longer from the C
sources.

diff --git a/drivers/net/wireless/airport.c b/drivers/net/wireless/airport.c
--- a/drivers/net/wireless/airport.c
+++ b/drivers/net/wireless/airport.c
@@ -15,28 +15,11 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/ioport.h>
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/etherdevice.h>
-#include <linux/wireless.h>
-
-#include <asm/io.h>
-#include <asm/system.h>
-#include <asm/current.h>
-#include <asm/prom.h>
-#include <asm/machdep.h>
+#include <linux/delay.h>
 #include <asm/pmac_feature.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
 
 #include "orinoco.h"
 
diff --git a/drivers/net/wireless/hermes.c b/drivers/net/wireless/hermes.c
--- a/drivers/net/wireless/hermes.c
+++ b/drivers/net/wireless/hermes.c
@@ -39,17 +39,10 @@
  */
 
 #include <linux/config.h>
-
 #include <linux/module.h>
-#include <linux/types.h>
-#include <linux/threads.h>
-#include <linux/smp.h>
-#include <asm/io.h>
-#include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/kernel.h>
-#include <linux/net.h>
-#include <asm/errno.h>
+#include <linux/init.h>
+#include <linux/delay.h>
 
 #include "hermes.h"
 
diff --git a/drivers/net/wireless/hermes.h b/drivers/net/wireless/hermes.h
--- a/drivers/net/wireless/hermes.h
+++ b/drivers/net/wireless/hermes.h
@@ -30,9 +30,8 @@
  * access to the hermes_t structure, and to the hardware
 */
 
-#include <linux/delay.h>
 #include <linux/if_ether.h>
-#include <asm/byteorder.h>
+#include <asm/io.h>
 
 /*
  * Limits and constants
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -77,28 +77,16 @@
 #define DRIVER_NAME "orinoco"
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/ioport.h>
 #include <linux/netdevice.h>
-#include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
 #include <net/ieee80211.h>
 
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/system.h>
-
-#include "hermes.h"
 #include "hermes_rid.h"
 #include "orinoco.h"
 
diff --git a/drivers/net/wireless/orinoco.h b/drivers/net/wireless/orinoco.h
--- a/drivers/net/wireless/orinoco.h
+++ b/drivers/net/wireless/orinoco.h
@@ -9,8 +9,6 @@
 
 #define DRIVER_VERSION "0.15rc2"
 
-#include <linux/types.h>
-#include <linux/spinlock.h>
 #include <linux/netdevice.h>
 #include <linux/wireless.h>
 #include <net/iw_handler.h>
diff --git a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -14,30 +14,16 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/ioport.h>
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/etherdevice.h>
-#include <linux/wireless.h>
-
+#include <linux/delay.h>
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
 
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/system.h>
-
 #include "orinoco.h"
 
 /********************************************************************/
diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless/orinoco_nortel.c
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -40,29 +40,13 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/ioport.h>
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/system.h>
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/etherdevice.h>
-#include <linux/list.h>
+#include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/fcntl.h>
-
 #include <pcmcia/cisreg.h>
 
-#include "hermes.h"
 #include "orinoco.h"
 
 #define COR_OFFSET    (0xe0)	/* COR attribute offset of Prism2 PC card */
diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -93,28 +93,12 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/ioport.h>
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/etherdevice.h>
-#include <linux/list.h>
+#include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/fcntl.h>
-
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/system.h>
 
-#include "hermes.h"
 #include "orinoco.h"
 
 /* All the magic there is from wlan-ng */
diff --git a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/orinoco_plx.c
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -117,29 +117,13 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/ioport.h>
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/system.h>
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/etherdevice.h>
-#include <linux/list.h>
+#include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/fcntl.h>
-
 #include <pcmcia/cisreg.h>
 
-#include "hermes.h"
 #include "orinoco.h"
 
 #define COR_OFFSET	(0x3e0)	/* COR attribute offset of Prism2 PC card */
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -53,29 +53,13 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/timer.h>
-#include <linux/ioport.h>
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/system.h>
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/etherdevice.h>
-#include <linux/list.h>
+#include <linux/delay.h>
 #include <linux/pci.h>
-#include <linux/fcntl.h>
-
 #include <pcmcia/cisreg.h>
 
-#include "hermes.h"
 #include "orinoco.h"
 
 #define COR_VALUE	(COR_LEVEL_REQ | COR_FUNC_ENA) /* Enable PC card with interrupt in level trigger */
diff --git a/drivers/net/wireless/spectrum_cs.c b/drivers/net/wireless/spectrum_cs.c
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -22,31 +22,17 @@
 #define PFX DRIVER_NAME ": "
 
 #include <linux/config.h>
-
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
-#include <linux/sched.h>
-#include <linux/ptrace.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/ioport.h>
-#include <linux/netdevice.h>
-#include <linux/if_arp.h>
-#include <linux/etherdevice.h>
-#include <linux/wireless.h>
+#include <linux/delay.h>
 #include <linux/firmware.h>
-
 #include <pcmcia/cs_types.h>
 #include <pcmcia/cs.h>
 #include <pcmcia/cistpl.h>
 #include <pcmcia/cisreg.h>
 #include <pcmcia/ds.h>
 
-#include <asm/uaccess.h>
-#include <asm/io.h>
-#include <asm/system.h>
-
 #include "orinoco.h"
 
 static unsigned char *primsym;



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
