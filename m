From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [fore200e] make tasklet use configurable (2 of 2)
Date: Fri, 23 Apr 2004 17:04:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404232104.i3NL44Zx002473@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

here is the second part of the fore200e patch.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1331.3.1 -> 1.1331.3.2
#	drivers/atm/Config.in	1.8     -> 1.9    
#	drivers/atm/fore200e.c	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/04/02	chas@relax.cmf.nrl.navy.mil	1.1331.3.2
# [ATM]: [fore200e] make tasklet use configurable
# --------------------------------------------
#
diff -Nru a/drivers/atm/Config.in b/drivers/atm/Config.in
--- a/drivers/atm/Config.in	Fri Apr 16 10:44:52 2004
+++ b/drivers/atm/Config.in	Fri Apr 16 10:44:52 2004
@@ -83,6 +83,7 @@
   fi
   if [ "$CONFIG_ATM_FORE200E_PCA" = "y" -o "$CONFIG_ATM_FORE200E_SBA" = "y" ]; \
     then
+    bool '  Defer interrupt work to a tasklet' CONFIG_ATM_FORE200E_USE_TASKLET
     int  '  Maximum number of tx retries' CONFIG_ATM_FORE200E_TX_RETRY 16
     int  '  Debugging level (0-3)' CONFIG_ATM_FORE200E_DEBUG 0
     if [ "$CONFIG_ATM_FORE200E_MAYBE" = "y" ]; then
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	Fri Apr 16 10:44:52 2004
+++ b/drivers/atm/fore200e.c	Fri Apr 16 10:44:52 2004
@@ -57,7 +57,7 @@
 #include <asm/pgtable.h>
 #endif
 
-#if 0 /* defer interrupt work to a tasklet */
+#if defined(CONFIG_ATM_FORE200E_USE_TASKLET) /* defer interrupt work to a tasklet */
 #define FORE200E_USE_TASKLET
 #endif
 
@@ -1343,6 +1343,7 @@
 }
 
 
+#ifndef FORE200E_USE_TASKLET
 static void 
 fore200e_irq(struct fore200e* fore200e)
 {
@@ -1356,6 +1357,7 @@
     fore200e_tx_irq(fore200e);
     spin_unlock_irqrestore(&fore200e->q_lock, flags);
 }
+#endif
 
 
 static void
@@ -1396,6 +1398,7 @@
 }
 
 
+static void
 fore200e_rx_tasklet(unsigned long data)
 {
     struct fore200e* fore200e = (struct fore200e*) data;
