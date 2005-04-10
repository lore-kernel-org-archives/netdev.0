From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/3][ATM]: [fore200e] pci doesn't use global board list; use pci_register_driver()
Date: Sun, 10 Apr 2005 11:27:10 -0400
Message-ID: <200504101527.j3AFR9Kv007592@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/04/10 10:59:57-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [fore200e] pci doesn't use global board list; use pci_register_driver()
#   
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/fore200e.c
#   2005/04/10 10:59:37-04:00 chas@relax.cmf.nrl.navy.mil +1 -3
#   [ATM]: [fore200e] pci doesn't use global board list; use pci_register_driver()
#   
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c	2005-04-10 11:21:37 -04:00
+++ b/drivers/atm/fore200e.c	2005-04-10 11:21:37 -04:00
@@ -2792,8 +2792,6 @@
 
     fore200e = pci_get_drvdata(pci_dev);
 
-    list_del(&fore200e->entry);
-
     fore200e_shutdown(fore200e);
     kfree(fore200e);
     pci_disable_device(pci_dev);
@@ -2850,7 +2848,7 @@
     }
 
 #ifdef CONFIG_ATM_FORE200E_PCA
-    if (!pci_module_init(&fore200e_pca_driver))
+    if (!pci_register_driver(&fore200e_pca_driver))
 	return 0;
 #endif
 
