From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [eni] correct way to prevent module unload (from shemminger@osdl.org)
Date: Sun, 21 Sep 2003 10:44:37 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211444.h8LEiakT023723@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.  --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1441  -> 1.1442 
#	   drivers/atm/eni.c	1.25    -> 1.26   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/16	chas@relax.cmf.nrl.navy.mil	1.1442
# [ATM]: [eni] correct way to prevent module unload (from shemminger@osdl.org)
# --------------------------------------------
#
diff -Nru a/drivers/atm/eni.c b/drivers/atm/eni.c
--- a/drivers/atm/eni.c	Sun Sep 21 09:36:35 2003
+++ b/drivers/atm/eni.c	Sun Sep 21 09:36:35 2003
@@ -2269,8 +2269,6 @@
 
 	DPRINTK("eni_init_one\n");
 
-	MOD_INC_USE_COUNT; /* @@@ we don't support unloading yet */
-
 	if (pci_enable_device(pci_dev)) {
 		error = -EIO;
 		goto out0;
@@ -2304,7 +2302,6 @@
 out1:
 	kfree(eni_dev);
 out0:
-	MOD_DEC_USE_COUNT; /* @@@ we don't support unloading yet */
 	return error;
 }
 
@@ -2348,16 +2345,7 @@
 }
 
 
-static void __exit eni_cleanup(void)
-{
-	/*
-	 * Well, there's no way to get rid of the driver yet, so we don't
-	 * have to clean up, right ? :-)
-	 */
-}
-
-
 module_init(eni_init);
-module_exit(eni_cleanup);
+/* @@@ since exit routine not defined, this module can not be unloaded */
 
 MODULE_LICENSE("GPL");
