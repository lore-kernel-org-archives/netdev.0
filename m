From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 5 of 5][ATM]: replace schedule_timeout() with msleep()
Date: Wed, 26 Jan 2005 11:58:11 -0500
Message-ID: <200501261658.j0QGwAaO018882@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/24 13:38:44-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: replace schedule_timeout() with msleep()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# net/atm/resources.c
#   2005/01/24 13:38:27-05:00 chas@relax.cmf.nrl.navy.mil +2 -2
#   [ATM]: replace schedule_timeout() with msleep()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/net/atm/resources.c b/net/atm/resources.c
--- a/net/atm/resources.c	2005-01-25 09:37:57 -05:00
+++ b/net/atm/resources.c	2005-01-25 09:37:57 -05:00
@@ -16,6 +16,7 @@
 #include <linux/kernel.h> /* for barrier */
 #include <linux/module.h>
 #include <linux/bitops.h>
+#include <linux/delay.h>
 #include <net/sock.h>	 /* for struct sock */
 
 #include "common.h"
@@ -139,8 +140,7 @@
 
         warning_time = jiffies;
         while (atomic_read(&dev->refcnt) != 1) {
-                current->state = TASK_INTERRUPTIBLE;
-                schedule_timeout(HZ / 4);
+                msleep(250);
                 if ((jiffies - warning_time) > 10 * HZ) {
                         printk(KERN_EMERG "atm_dev_deregister: waiting for "
                                "dev %d to become free. Usage count = %d\n",
