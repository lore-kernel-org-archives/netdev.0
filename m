From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 6/9][ATM]: [fore200e] Replace MSECS() with msecs_to_jiffies()
Date: Mon, 07 Mar 2005 17:06:59 -0500
Message-ID: <200503072206.j27M6xOR020993@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks! 

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 15:15:01-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [fore200e] Replace MSECS() with msecs_to_jiffies()
#   
#   Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/fore200e.c
#   2005/03/07 15:14:43-05:00 chas@relax.cmf.nrl.navy.mil +4 -8
#   [ATM]: [fore200e] Replace MSECS() with msecs_to_jiffies()
#   
#   Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	2005-03-07 15:36:02 -05:00
+++ b/drivers/atm/fore200e.c	2005-03-07 15:36:02 -05:00
@@ -96,10 +96,6 @@
 
 #define FORE200E_NEXT_ENTRY(index, modulo)         (index = ++(index) % (modulo))
 
-
-#define MSECS(ms)  (((ms)*HZ/1000)+1)
-
-
 #if 1
 #define ASSERT(expr)     if (!(expr)) { \
 			     printk(FORE200E "assertion failed! %s[%d]: %s\n", \
@@ -246,7 +242,7 @@
 static void
 fore200e_spin(int msecs)
 {
-    unsigned long timeout = jiffies + MSECS(msecs);
+    unsigned long timeout = jiffies + msecs_to_jiffies(msecs);
     while (time_before(jiffies, timeout));
 }
 
@@ -254,7 +250,7 @@
 static int
 fore200e_poll(struct fore200e* fore200e, volatile u32* addr, u32 val, int msecs)
 {
-    unsigned long timeout = jiffies + MSECS(msecs);
+    unsigned long timeout = jiffies + msecs_to_jiffies(msecs);
     int           ok;
 
     mb();
@@ -278,7 +274,7 @@
 static int
 fore200e_io_poll(struct fore200e* fore200e, volatile u32 __iomem *addr, u32 val, int msecs)
 {
-    unsigned long timeout = jiffies + MSECS(msecs);
+    unsigned long timeout = jiffies + msecs_to_jiffies(msecs);
     int           ok;
 
     do {
@@ -2596,7 +2592,7 @@
 fore200e_monitor_getc(struct fore200e* fore200e)
 {
     struct cp_monitor __iomem * monitor = fore200e->cp_monitor;
-    unsigned long      timeout = jiffies + MSECS(50);
+    unsigned long      timeout = jiffies + msecs_to_jiffies(50);
     int                c;
 
     while (time_before(jiffies, timeout)) {
