From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] prism54: fix printk format warnings
Date: Tue, 1 Mar 2005 21:21:37 -0800
Message-ID: <20050301212137.57f9532f.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, mcgrof@ruslug.rutgers.edu
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


prism54 build shows some printk format complaints:
(sparc64 build warning)

drivers/net/wireless/prism54/isl_38xx.c:131: warning: long int format, different type arg (arg 3)
drivers/net/wireless/prism54/isl_38xx.c:151: warning: long int format, different type arg (arg 3)

cross-compile results:
https://www.osdl.org/plm-cgi/plm?module=patch_info&patch_id=4240

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/wireless/prism54/isl_38xx.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff -Naurp ./drivers/net/wireless/prism54/isl_38xx.c~prism_printk ./drivers/net/wireless/prism54/isl_38xx.c
--- ./drivers/net/wireless/prism54/isl_38xx.c~prism_printk	2004-12-24 13:34:45.000000000 -0800
+++ ./drivers/net/wireless/prism54/isl_38xx.c	2005-03-01 20:15:00.189995120 -0800
@@ -125,11 +125,11 @@ isl38xx_trigger_device(int asleep, void 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		do_gettimeofday(&current_time);
 		DEBUG(SHOW_TRACING, "%08li.%08li Device wakeup triggered\n",
-		      current_time.tv_sec, current_time.tv_usec);
+		      current_time.tv_sec, (long)current_time.tv_usec);
 #endif
 
 		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, current_time.tv_usec,
+		      current_time.tv_sec, (long)current_time.tv_usec,
 		      readl(device_base + ISL38XX_CTRL_STAT_REG));
 		udelay(ISL38XX_WRITEIO_DELAY);
 
@@ -139,7 +139,7 @@ isl38xx_trigger_device(int asleep, void 
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device register abadface\n",
-			      current_time.tv_sec, current_time.tv_usec);
+			      current_time.tv_sec, (long)current_time.tv_usec);
 #endif
 			/* read the Device Status Register until Sleepmode bit is set */
 			while (reg = readl(device_base + ISL38XX_CTRL_STAT_REG),
@@ -150,7 +150,7 @@ isl38xx_trigger_device(int asleep, void 
 
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device register read %08x\n",
-			      current_time.tv_sec, current_time.tv_usec,
+			      current_time.tv_sec, (long)current_time.tv_usec,
 			      readl(device_base + ISL38XX_CTRL_STAT_REG));
 			udelay(ISL38XX_WRITEIO_DELAY);
 
@@ -158,7 +158,7 @@ isl38xx_trigger_device(int asleep, void 
 			do_gettimeofday(&current_time);
 			DEBUG(SHOW_TRACING,
 			      "%08li.%08li Device asleep counter %i\n",
-			      current_time.tv_sec, current_time.tv_usec,
+			      current_time.tv_sec, (long)current_time.tv_usec,
 			      counter);
 #endif
 		}
@@ -174,7 +174,7 @@ isl38xx_trigger_device(int asleep, void 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 		do_gettimeofday(&current_time);
 		DEBUG(SHOW_TRACING, "%08li.%08li Device register read %08x\n",
-		      current_time.tv_sec, current_time.tv_usec, reg);
+		      current_time.tv_sec, (long)current_time.tv_usec, reg);
 #endif
 	} else {
 		/* device is (still) awake  */

---
