From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1 of 3][ATM]: [horizon] replace interruptible_sleep_on() with wait_event_interruptible()
Date: Fri, 04 Feb 2005 13:23:07 -0500
Message-ID: <200502041823.j14IN6RU020651@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/03 11:38:49-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [horizon] replace interruptible_sleep_on() with wait_event_interruptible()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/horizon.c
#   2005/02/03 11:38:31-05:00 chas@relax.cmf.nrl.navy.mil +6 -7
#   [ATM]: [horizon] replace interruptible_sleep_on() with wait_event_interruptible()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	2005-02-03 12:17:39 -05:00
+++ b/drivers/atm/horizon.c	2005-02-03 12:17:39 -05:00
@@ -39,6 +39,7 @@
 #include <linux/uio.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
+#include <linux/wait.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -1089,13 +1090,11 @@
 /********** (queue to) become the next TX thread **********/
 
 static inline int tx_hold (hrz_dev * dev) {
-  while (test_and_set_bit (tx_busy, &dev->flags)) {
-    PRINTD (DBG_TX, "sleeping at tx lock %p %lu", dev, dev->flags);
-    interruptible_sleep_on (&dev->tx_queue);
-    PRINTD (DBG_TX, "woken at tx lock %p %lu", dev, dev->flags);
-    if (signal_pending (current))
-      return -1;
-  }
+  PRINTD (DBG_TX, "sleeping at tx lock %p %lu", dev, dev->flags);
+  wait_event_interruptible(dev->tx_queue, (!test_and_set_bit(tx_busy, &dev->flags)));
+  PRINTD (DBG_TX, "woken at tx lock %p %lu", dev, dev->flags);
+  if (signal_pending (current))
+    return -1;
   PRINTD (DBG_TX, "set tx_busy for dev %p", dev);
   return 0;
 }
