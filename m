From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][3 of 7][ATM]: [he] remove dead code and unneeded zero initializers
Date: Tue, 18 Jan 2005 14:07:02 -0500
Message-ID: <200501181907.j0IJ72Du022318@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/06 13:31:00-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [he] remove dead code and unneeded zero initializers
#
#   Signed-off-by: Marcel Sebek <sebek64@post.cz>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/he.c
#   2005/01/06 13:30:43-05:00 chas@relax.cmf.nrl.navy.mil +6 -31
#   [ATM]: [he] remove dead code and unneeded zero initializers
#
#   Signed-off-by: Marcel Sebek <sebek64@post.cz>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2005-01-14 08:42:49 -05:00
+++ b/drivers/atm/he.c	2005-01-14 08:42:49 -05:00
@@ -86,44 +86,19 @@
 #undef USE_RBPL_POOL			/* if memory is tight try this */
 #define USE_TPD_POOL
 /* #undef CONFIG_ATM_HE_USE_SUNI */
-
-/* compatibility */
-
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,69)
-typedef void irqreturn_t;
-#define IRQ_NONE
-#define IRQ_HANDLED
-#define IRQ_RETVAL(x)
-#endif
-
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,4,9)
-#define __devexit_p(func)		func
-#endif
-
-#ifndef MODULE_LICENSE
-#define MODULE_LICENSE(x)
-#endif
-
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,4,3)
-#define pci_set_drvdata(pci_dev, data)	(pci_dev)->driver_data = (data)
-#define pci_get_drvdata(pci_dev)	(pci_dev)->driver_data
-#endif
+/* #undef HE_DEBUG */
 
 #include "he.h"
-
 #include "suni.h"
-
 #include <linux/atm_he.h>
 
 #define hprintk(fmt,args...)	printk(KERN_ERR DEV_LABEL "%d: " fmt, he_dev->number , ##args)
 
-#undef DEBUG
-#ifdef DEBUG
+#ifdef HE_DEBUG
 #define HPRINTK(fmt,args...)	printk(KERN_DEBUG DEV_LABEL "%d: " fmt, he_dev->number , ##args)
-#else
+#else /* !HE_DEBUG */
 #define HPRINTK(fmt,args...)	do { } while (0)
-#endif /* DEBUG */
-
+#endif /* HE_DEBUG */
 
 /* version definition */
 
@@ -147,8 +122,8 @@
 
 /* globals */
 
-static struct he_dev *he_devs = NULL;
-static int disable64 = 0;
+static struct he_dev *he_devs;
+static int disable64;
 static short nvpibits = -1;
 static short nvcibits = -1;
 static short rx_skb_reserve = 16;
