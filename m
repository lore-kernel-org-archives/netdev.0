From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Thu, 9 Jun 2011 14:56:57 +1000
Message-ID: <20110609145657.96fae0d0.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg KH <greg@kroah.com>, Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

[See summary in patch below.]

[Hmmm, suddenly allmodconfig is building stuff in staging?  Ah ha!
Commit fe35a59e16fb ("Staging: remove STAGING_EXCLUDE_BUILD
option")  Greg, a bit of warning might have been nice :-( ]

I assume that this is fallout from commit a6b7a407865a ("net: remove
interrupt.h inclusion from netdevice.h").

I added the following patch for today:

>From 520e46c255afa851b33e5c4a2bcf2112ecccbb6f Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 9 Jun 2011 14:19:09 +1000
Subject: [PATCH] net/staging: add needed interrupt.h and hardirq.h includes

Made necessary by commit a6b7a407865a ("net: remove
interrupt.h inclusion from netdevice.h").

Fixes these build errors:

drivers/staging/brcm80211/brcmfmac/dhd_linux.c:1212:3: error: implicit declaration of function 'in_interrupt'
drivers/staging/brcm80211/brcmfmac/dhd_linux.c:1390:4: error: implicit declaration of function 'tasklet_schedule'
drivers/staging/brcm80211/brcmfmac/dhd_linux.c:1988:3: error: implicit declaration of function 'tasklet_init'
drivers/staging/brcm80211/brcmfmac/dhd_linux.c:2288:5: error: implicit declaration of function 'tasklet_kill'
drivers/staging/brcm80211/brcmfmac/dhd_linux.c:232:24: error: field 'tasklet' has incomplete type
drivers/staging/brcm80211/brcmfmac/wl_iw.c:3670:2: error: implicit declaration of function 'in_interrupt'
drivers/staging/brcm80211/brcmsmac/wl_mac80211.c:1349:3: error: implicit declaration of function 'free_irq'
drivers/staging/brcm80211/brcmsmac/wl_mac80211.c:1352:2: error: implicit declaration of function 'tasklet_kill'
drivers/staging/brcm80211/brcmsmac/wl_mac80211.c:1538:4: error: implicit declaration of function 'tasklet_schedule'
drivers/staging/brcm80211/brcmsmac/wl_mac80211.c:765:2: error: implicit declaration of function 'tasklet_init'
drivers/staging/brcm80211/brcmsmac/wl_mac80211.c:817:2: error: implicit declaration of function 'request_irq'
drivers/staging/brcm80211/brcmsmac/wl_mac80211.c:817:31: error: 'IRQF_SHARED' undeclared (first use in this function)
drivers/staging/brcm80211/brcmsmac/wl_mac80211.h:65:24: error: field 'tasklet' has incomplete type
drivers/staging/rtl8187se/ieee80211/ieee80211.h:994:24: error: field 'ps_task' has incomplete type
drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c:1790:3: error: implicit declaration of function 'tasklet_schedule'
drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c:2590:2: error: implicit declaration of function 'tasklet_init'
drivers/staging/rtl8187se/r8180.h:461:24: error: field 'irq_rx_tasklet' has incomplete type
drivers/staging/rtl8187se/r8180_core.c:2764:2: error: implicit declaration of function 'tasklet_init'
drivers/staging/rtl8187se/r8180_core.c:2954:2: error: implicit declaration of function 'request_irq'
drivers/staging/rtl8187se/r8180_core.c:2954:55: error: 'IRQF_SHARED' undeclared (first use in this function)
drivers/staging/rtl8187se/r8180_core.c:3641:4: error: implicit declaration of function 'free_irq'
drivers/staging/rtl8187se/r8180_core.c:4026:3: error: implicit declaration of function 'tasklet_schedule'
drivers/staging/rtl8192e/ieee80211/ieee80211.h:2000:24: error: field 'ps_task' has incomplete type
drivers/staging/rtl8192e/r8192E.h:909:24: error: field 'irq_rx_tasklet' has incomplete type
drivers/staging/rtl8192e/r8192E.h:910:24: error: field 'irq_tx_tasklet' has incomplete type
drivers/staging/rtl8192e/r8192E.h:911:31: error: field 'irq_prepare_beacon_tasklet' has incomplete type
drivers/staging/rtl8192e/r8192E_core.c:2008:2: error: implicit declaration of function 'tasklet_init'
drivers/staging/rtl8192e/r8192E_core.c:2412:54: error: 'IRQF_SHARED' undeclared (first use in this function)
drivers/staging/rtl8192e/r8192E_core.c:2412:9: error: implicit declaration of function 'request_irq'
drivers/staging/rtl8192e/r8192E_core.c:4640:4: error: implicit declaration of function 'free_irq'
drivers/staging/rtl8192e/r8192E_core.c:620:2: error: implicit declaration of function 'synchronize_irq'
drivers/staging/rtl8192e/r8192E_core.c:913:3: error: implicit declaration of function 'tasklet_schedule'
drivers/staging/rtl8192u/ieee80211/ieee80211.h:1993:24: error: field 'ps_task' has incomplete type

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/staging/brcm80211/brcmfmac/dhd_linux.c     |    2 ++
 drivers/staging/brcm80211/brcmfmac/wl_iw.c         |    1 +
 drivers/staging/brcm80211/brcmsmac/wl_mac80211.c   |    1 +
 drivers/staging/brcm80211/brcmsmac/wl_mac80211.h   |    2 ++
 drivers/staging/rtl8187se/ieee80211/ieee80211.h    |    1 +
 .../rtl8187se/ieee80211/ieee80211_softmac.c        |    1 +
 drivers/staging/rtl8187se/r8180.h                  |    1 +
 drivers/staging/rtl8187se/r8180_core.c             |    1 +
 drivers/staging/rtl8192e/ieee80211/ieee80211.h     |    1 +
 drivers/staging/rtl8192e/r8192E.h                  |    1 +
 drivers/staging/rtl8192e/r8192E_core.c             |    2 ++
 drivers/staging/rtl8192u/ieee80211/ieee80211.h     |    1 +
 12 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/brcm80211/brcmfmac/dhd_linux.c b/drivers/staging/brcm80211/brcmfmac/dhd_linux.c
index f356c56..09957bd 100644
--- a/drivers/staging/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/staging/brcm80211/brcmfmac/dhd_linux.c
@@ -31,6 +31,8 @@
 #include <linux/fcntl.h>
 #include <linux/fs.h>
 #include <linux/uaccess.h>
+#include <linux/interrupt.h>
+#include <linux/hardirq.h>
 #include <bcmdefs.h>
 #include <bcmutils.h>
 
diff --git a/drivers/staging/brcm80211/brcmfmac/wl_iw.c b/drivers/staging/brcm80211/brcmfmac/wl_iw.c
index 15e1b05..35eec91 100644
--- a/drivers/staging/brcm80211/brcmfmac/wl_iw.c
+++ b/drivers/staging/brcm80211/brcmfmac/wl_iw.c
@@ -18,6 +18,7 @@
 #include <linux/semaphore.h>
 #include <bcmdefs.h>
 #include <linux/netdevice.h>
+#include <linux/hardirq.h>
 #include <wlioctl.h>
 
 #include <bcmutils.h>
diff --git a/drivers/staging/brcm80211/brcmsmac/wl_mac80211.c b/drivers/staging/brcm80211/brcmsmac/wl_mac80211.c
index 6c6236c..8261229 100644
--- a/drivers/staging/brcm80211/brcmsmac/wl_mac80211.c
+++ b/drivers/staging/brcm80211/brcmsmac/wl_mac80211.c
@@ -24,6 +24,7 @@
 #include <linux/pci.h>
 #include <linux/sched.h>
 #include <linux/firmware.h>
+#include <linux/interrupt.h>
 #include <net/mac80211.h>
 
 #include <proto/802.11.h>
diff --git a/drivers/staging/brcm80211/brcmsmac/wl_mac80211.h b/drivers/staging/brcm80211/brcmsmac/wl_mac80211.h
index e703d8b..f7a58b7 100644
--- a/drivers/staging/brcm80211/brcmsmac/wl_mac80211.h
+++ b/drivers/staging/brcm80211/brcmsmac/wl_mac80211.h
@@ -17,6 +17,8 @@
 #ifndef _wl_mac80211_h_
 #define _wl_mac80211_h_
 
+#include <linux/interrupt.h>
+
 /* BMAC Note: High-only driver is no longer working in softirq context as it needs to block and
  * sleep so perimeter lock has to be a semaphore instead of spinlock. This requires timers to be
  * submitted to workqueue instead of being on kernel timer
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211.h b/drivers/staging/rtl8187se/ieee80211/ieee80211.h
index 16aa6a8..4384d93 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211.h
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211.h
@@ -32,6 +32,7 @@
 #include <linux/semaphore.h>
 #include <linux/wireless.h>
 #include <linux/ieee80211.h>
+#include <linux/interrupt.h>
 
 #define KEY_TYPE_NA		0x0
 #define KEY_TYPE_WEP40 		0x1
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
index 736a140..00ee02f 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
@@ -20,6 +20,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/version.h>
+#include <linux/interrupt.h>
 #include <asm/uaccess.h>
 
 #include "dot11d.h"
diff --git a/drivers/staging/rtl8187se/r8180.h b/drivers/staging/rtl8187se/r8180.h
index d15bdf6..a2c46ae 100644
--- a/drivers/staging/rtl8187se/r8180.h
+++ b/drivers/staging/rtl8187se/r8180.h
@@ -18,6 +18,7 @@
 #ifndef R8180H
 #define R8180H
 
+#include <linux/interrupt.h>
 
 #define RTL8180_MODULE_NAME "r8180"
 #define DMESG(x,a...) printk(KERN_INFO RTL8180_MODULE_NAME ": " x "\n", ## a)
diff --git a/drivers/staging/rtl8187se/r8180_core.c b/drivers/staging/rtl8187se/r8180_core.c
index 2155a77..bae7d85 100644
--- a/drivers/staging/rtl8187se/r8180_core.c
+++ b/drivers/staging/rtl8187se/r8180_core.c
@@ -33,6 +33,7 @@
 #include <linux/slab.h>
 #include <linux/syscalls.h>
 #include <linux/eeprom_93cx6.h>
+#include <linux/interrupt.h>
 
 #include "r8180_hw.h"
 #include "r8180.h"
diff --git a/drivers/staging/rtl8192e/ieee80211/ieee80211.h b/drivers/staging/rtl8192e/ieee80211/ieee80211.h
index dbe21ab..82bc59a 100644
--- a/drivers/staging/rtl8192e/ieee80211/ieee80211.h
+++ b/drivers/staging/rtl8192e/ieee80211/ieee80211.h
@@ -31,6 +31,7 @@
 #include <linux/timer.h>
 #include <linux/sched.h>
 #include <linux/semaphore.h>
+#include <linux/interrupt.h>
 
 #include <linux/delay.h>
 #include <linux/wireless.h>
diff --git a/drivers/staging/rtl8192e/r8192E.h b/drivers/staging/rtl8192e/r8192E.h
index 0229031..89fe8fc 100644
--- a/drivers/staging/rtl8192e/r8192E.h
+++ b/drivers/staging/rtl8192e/r8192E.h
@@ -36,6 +36,7 @@
 #include <linux/if_arp.h>
 #include <linux/random.h>
 #include <linux/version.h>
+#include <linux/interrupt.h>
 #include <asm/io.h>
 #include "ieee80211/rtl819x_HT.h"
 #include "ieee80211/ieee80211.h"
diff --git a/drivers/staging/rtl8192e/r8192E_core.c b/drivers/staging/rtl8192e/r8192E_core.c
index 58d800f..19a9a07 100644
--- a/drivers/staging/rtl8192e/r8192E_core.c
+++ b/drivers/staging/rtl8192e/r8192E_core.c
@@ -27,6 +27,8 @@
 
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/hardirq.h>
 #include <asm/uaccess.h>
 #include "r8192E_hw.h"
 #include "r8192E.h"
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211.h b/drivers/staging/rtl8192u/ieee80211/ieee80211.h
index e716f7b..2333257 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211.h
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211.h
@@ -31,6 +31,7 @@
 #include <linux/timer.h>
 #include <linux/sched.h>
 #include <linux/semaphore.h>
+#include <linux/interrupt.h>
 
 #include <linux/delay.h>
 #include <linux/wireless.h>
-- 
1.7.5.3

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
