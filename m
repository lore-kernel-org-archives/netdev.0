From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [fore200e] make use tasklet configurable (2 of 2)
Date: Fri, 23 Apr 2004 20:30:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404240030.i3O0UbEI005507@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

fore200e 0.3e part 2 of 2 for 2.6 kernels

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1810  -> 1.1811 
#	 drivers/atm/Kconfig	1.10    -> 1.11   
#	drivers/atm/fore200e.c	1.25    -> 1.26   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/04/16	chas@relax.cmf.nrl.navy.mil	1.1811
# [ATM]: [fore200e] make use tasklet configurable
# --------------------------------------------
#
diff -Nru a/drivers/atm/Kconfig b/drivers/atm/Kconfig
--- a/drivers/atm/Kconfig	Fri Apr 16 14:52:03 2004
+++ b/drivers/atm/Kconfig	Fri Apr 16 14:52:03 2004
@@ -385,6 +385,15 @@
 	  not have to supply an alternative one. They just say Y to "Use
 	  default SBA-200E firmware", above.
 
+config ATM_FORE200E_USE_TASKLET
+	bool "Defer interrupt work to a tasklet"
+	depends on (PCI || SBUS) && (ATM_FORE200E_PCA || ATM_FORE200E_SBA)
+	default n
+	help
+	  This defers work to be done by the interrupt handler to a
+	  tasklet instead of hanlding everything at interrupt time.  This
+	  may improve the responsive of the host.
+
 config ATM_FORE200E_TX_RETRY
 	int "Maximum number of tx retries"
 	depends on (PCI || SBUS) && (ATM_FORE200E_PCA || ATM_FORE200E_SBA)
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	Fri Apr 16 14:52:03 2004
+++ b/drivers/atm/fore200e.c	Fri Apr 16 14:52:03 2004
@@ -55,7 +55,7 @@
 #include <asm/pgtable.h>
 #endif
 
-#if 0 /* defer interrupt work to a tasklet */
+#if defined(CONFIG_ATM_FORE200E_USE_TASKLET) /* defer interrupt work to a tasklet */
 #define FORE200E_USE_TASKLET
 #endif
 
@@ -1354,6 +1354,7 @@
 }
 
 
+#ifndef FORE200E_USE_TASKLET
 static void
 fore200e_irq(struct fore200e* fore200e)
 {
@@ -1367,6 +1368,7 @@
     fore200e_tx_irq(fore200e);
     spin_unlock_irqrestore(&fore200e->q_lock, flags);
 }
+#endif
 
 
 static irqreturn_t
