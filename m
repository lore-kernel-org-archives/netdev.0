From: akpm@osdl.org
Subject: [patch 13/13] tulip: make tulip_stop_rxtx() wait for DMA to fully stop
Date: Sun, 21 Nov 2004 22:43:59 -0800
Message-ID: <200411220644.iAM6iB900701@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        linville@tuxdriver.com, iod00d@hp.com, charlie.brett@hp.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "John W. Linville" <linville@tuxdriver.com>

tulip_stop_rxtx() doesn't wait for DMA to fully stop like the function
call name implies.

This was submitted through my employer -- I am not the original author of this
patch.  However, I passed it by Jeff Garizk and he expressed interest in
having it upstream.

Signed-off-by: Grant Grundler <iod00d@hp.com>
Acked-by: Charlie Brett <charlie.brett@hp.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/tulip/21142.c      |    2 +-
 25-akpm/drivers/net/tulip/eeprom.c     |    1 +
 25-akpm/drivers/net/tulip/interrupt.c  |    2 +-
 25-akpm/drivers/net/tulip/media.c      |    1 +
 25-akpm/drivers/net/tulip/pnic.c       |    1 +
 25-akpm/drivers/net/tulip/pnic2.c      |    2 +-
 25-akpm/drivers/net/tulip/timer.c      |    1 +
 25-akpm/drivers/net/tulip/tulip.h      |   15 ++++++++++++++-
 25-akpm/drivers/net/tulip/tulip_core.c |    2 +-
 9 files changed, 22 insertions(+), 5 deletions(-)

diff -puN drivers/net/tulip/21142.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/21142.c
--- 25/drivers/net/tulip/21142.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.037467296 -0800
+++ 25-akpm/drivers/net/tulip/21142.c	2004-11-21 22:42:54.053464864 -0800
@@ -14,9 +14,9 @@
 
 */
 
-#include "tulip.h"
 #include <linux/pci.h>
 #include <linux/delay.h>
+#include "tulip.h"
 
 
 static u16 t21142_csr13[] = { 0x0001, 0x0009, 0x0009, 0x0000, 0x0001, };
diff -puN drivers/net/tulip/eeprom.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/eeprom.c
--- 25/drivers/net/tulip/eeprom.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.038467144 -0800
+++ 25-akpm/drivers/net/tulip/eeprom.c	2004-11-21 22:42:54.053464864 -0800
@@ -14,6 +14,7 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 #include <linux/init.h>
 #include <asm/unaligned.h>
diff -puN drivers/net/tulip/interrupt.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/interrupt.c
--- 25/drivers/net/tulip/interrupt.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.040466840 -0800
+++ 25-akpm/drivers/net/tulip/interrupt.c	2004-11-21 22:42:54.054464712 -0800
@@ -14,10 +14,10 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 #include <linux/config.h>
 #include <linux/etherdevice.h>
-#include <linux/pci.h>
 
 int tulip_rx_copybreak;
 unsigned int tulip_max_interrupt_work;
diff -puN drivers/net/tulip/media.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/media.c
--- 25/drivers/net/tulip/media.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.042466536 -0800
+++ 25-akpm/drivers/net/tulip/media.c	2004-11-21 22:42:54.055464560 -0800
@@ -18,6 +18,7 @@
 #include <linux/mii.h>
 #include <linux/init.h>
 #include <linux/delay.h>
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -puN drivers/net/tulip/pnic2.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/pnic2.c
--- 25/drivers/net/tulip/pnic2.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.043466384 -0800
+++ 25-akpm/drivers/net/tulip/pnic2.c	2004-11-21 22:42:54.055464560 -0800
@@ -76,8 +76,8 @@
 
 
 
-#include "tulip.h"
 #include <linux/pci.h>
+#include "tulip.h"
 #include <linux/delay.h>
 
 
diff -puN drivers/net/tulip/pnic.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/pnic.c
--- 25/drivers/net/tulip/pnic.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.045466080 -0800
+++ 25-akpm/drivers/net/tulip/pnic.c	2004-11-21 22:42:54.055464560 -0800
@@ -15,6 +15,7 @@
 */
 
 #include <linux/kernel.h>
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -puN drivers/net/tulip/timer.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/timer.c
--- 25/drivers/net/tulip/timer.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.046465928 -0800
+++ 25-akpm/drivers/net/tulip/timer.c	2004-11-21 22:42:54.056464408 -0800
@@ -14,6 +14,7 @@
 
 */
 
+#include <linux/pci.h>
 #include "tulip.h"
 
 
diff -puN drivers/net/tulip/tulip_core.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/tulip_core.c
--- 25/drivers/net/tulip/tulip_core.c~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.048465624 -0800
+++ 25-akpm/drivers/net/tulip/tulip_core.c	2004-11-21 22:42:54.057464256 -0800
@@ -26,8 +26,8 @@
 
 
 #include <linux/module.h>
-#include "tulip.h"
 #include <linux/pci.h>
+#include "tulip.h"
 #include <linux/init.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
diff -puN drivers/net/tulip/tulip.h~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop drivers/net/tulip/tulip.h
--- 25/drivers/net/tulip/tulip.h~tulip-make-tulip_stop_rxtx-wait-for-dma-to-fully-stop	2004-11-21 22:42:54.050465320 -0800
+++ 25-akpm/drivers/net/tulip/tulip.h	2004-11-21 22:42:54.058464104 -0800
@@ -149,6 +149,9 @@ enum status_bits {
 	TxIntr = 0x01,
 };
 
+/* bit mask for CSR5 TX/RX process state */
+#define CSR5_TS	0x00700000
+#define CSR5_RS	0x000e0000
 
 enum tulip_mode_bits {
 	TxThreshold		= (1 << 22),
@@ -460,9 +463,19 @@ static inline void tulip_stop_rxtx(struc
 	u32 csr6 = ioread32(ioaddr + CSR6);
 
 	if (csr6 & RxTx) {
+		unsigned i=1300/10;
 		iowrite32(csr6 & ~RxTx, ioaddr + CSR6);
 		barrier();
-		(void) ioread32(ioaddr + CSR6); /* mmio sync */
+		/* wait until in-flight frame completes.
+		 * Max time @ 10BT: 1500*8b/10Mbps == 1200us (+ 100us margin)
+		 * Typically expect this loop to end in < 50 us on 100BT.
+		 */
+		while (--i && (ioread32(ioaddr + CSR5) & (CSR5_TS|CSR5_RS)))
+			udelay(10);
+
+		if (!i)
+			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed\n",
+					tp->pdev->slot_name);
 	}
 }
 
_
