From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] gigaset: include cleanup cleanup
Date: Sat, 17 Apr 2010 00:08:58 +0200 (CEST)
Message-ID: <20100416220858.A19F540123@xenon.ts.pxnet.com>
Cc: Tejun Heo <tj@kernel.org>, Hansjoerg Lipp <hjlipp@web.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 5a0e3ad causes slab.h to be included twice in many of the
Gigaset driver's source files, first via the common include file
gigaset.h and then a second time directly. Drop the spares, and
use the opportunity to clean up a few more similar cases.

Impact: cleanup, no functional change
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
CC: Tejun Heo <tj@kernel.org>
---
Seeing that the "include cleanup" patch triggering this was accepted
after the merge window, I have hopes this one will be accepted, too.

 drivers/isdn/gigaset/bas-gigaset.c |    5 -----
 drivers/isdn/gigaset/capi.c        |    2 --
 drivers/isdn/gigaset/common.c      |    2 --
 drivers/isdn/gigaset/gigaset.h     |    2 +-
 drivers/isdn/gigaset/i4l.c         |    1 -
 drivers/isdn/gigaset/interface.c   |    1 -
 drivers/isdn/gigaset/proc.c        |    1 -
 drivers/isdn/gigaset/ser-gigaset.c |    3 ---
 drivers/isdn/gigaset/usb-gigaset.c |    4 ----
 9 files changed, 1 insertions(+), 20 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 0be15c7..47a5ffe 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -14,11 +14,6 @@
  */
 
 #include "gigaset.h"
-
-#include <linux/errno.h>
-#include <linux/init.h>
-#include <linux/slab.h>
-#include <linux/timer.h>
 #include <linux/usb.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index eb7e271..964a55f 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -12,8 +12,6 @@
  */
 
 #include "gigaset.h"
-#include <linux/slab.h>
-#include <linux/ctype.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/isdn/capilli.h>
diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index 0b39b38..f6f45f2 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -14,10 +14,8 @@
  */
 
 #include "gigaset.h"
-#include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/slab.h>
 
 /* Version Information */
 #define DRIVER_AUTHOR "Hansjoerg Lipp <hjlipp@web.de>, Tilman Schmidt <tilman@imap.cc>, Stefan Eilers"
diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
index 9ef5b04..d32efb6 100644
--- a/drivers/isdn/gigaset/gigaset.h
+++ b/drivers/isdn/gigaset/gigaset.h
@@ -22,9 +22,9 @@
 #include <linux/kernel.h>
 #include <linux/compiler.h>
 #include <linux/types.h>
+#include <linux/ctype.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
-#include <linux/usb.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/ppp_defs.h>
diff --git a/drivers/isdn/gigaset/i4l.c b/drivers/isdn/gigaset/i4l.c
index c99fb97..c22e5ac 100644
--- a/drivers/isdn/gigaset/i4l.c
+++ b/drivers/isdn/gigaset/i4l.c
@@ -15,7 +15,6 @@
 
 #include "gigaset.h"
 #include <linux/isdnif.h>
-#include <linux/slab.h>
 
 #define HW_HDR_LEN	2	/* Header size used to store ack info */
 
diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index f0dc6c9..c9f28dd 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -13,7 +13,6 @@
 
 #include "gigaset.h"
 #include <linux/gigaset_dev.h>
-#include <linux/tty.h>
 #include <linux/tty_flip.h>
 
 /*** our ioctls ***/
diff --git a/drivers/isdn/gigaset/proc.c b/drivers/isdn/gigaset/proc.c
index b69f73a..b943efb 100644
--- a/drivers/isdn/gigaset/proc.c
+++ b/drivers/isdn/gigaset/proc.c
@@ -14,7 +14,6 @@
  */
 
 #include "gigaset.h"
-#include <linux/ctype.h>
 
 static ssize_t show_cidmode(struct device *dev,
 			    struct device_attribute *attr, char *buf)
diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/ser-gigaset.c
index 8b0afd2..e96c058 100644
--- a/drivers/isdn/gigaset/ser-gigaset.c
+++ b/drivers/isdn/gigaset/ser-gigaset.c
@@ -11,13 +11,10 @@
  */
 
 #include "gigaset.h"
-
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/platform_device.h>
-#include <linux/tty.h>
 #include <linux/completion.h>
-#include <linux/slab.h>
 
 /* Version Information */
 #define DRIVER_AUTHOR "Tilman Schmidt"
diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 9430a2b..76dbb20 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -16,10 +16,6 @@
  */
 
 #include "gigaset.h"
-
-#include <linux/errno.h>
-#include <linux/init.h>
-#include <linux/slab.h>
 #include <linux/usb.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-- 
1.6.5.3.298.g39add
