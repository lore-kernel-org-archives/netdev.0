From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [lanai] get rid of MOD_INC/MOD_DEC (from shemminger@osdl.org)
Date: Sun, 21 Sep 2003 10:46:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211446.h8LEkJkT023754@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1436  -> 1.1437 
#	 drivers/atm/lanai.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/09	chas@relax.cmf.nrl.navy.mil	1.1437
# [ATM]: [lanai] get rid of MOD_INC/MOD_DEC (from shemminger@osdl.org)
# --------------------------------------------
#
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	Sun Sep 21 09:36:46 2003
+++ b/drivers/atm/lanai.c	Sun Sep 21 09:36:46 2003
@@ -2242,7 +2242,6 @@
 		printk(KERN_ERR DEV_LABEL ": can't allocate interrupt\n");
 		goto error_vcctable;
 	}
-	MOD_INC_USE_COUNT;		/* At this point we can't fail */
 	mb();				/* Make sure that all that made it */
 	intr_enable(lanai, INT_ALL & ~(INT_PING | INT_WAKE));
 	/* 3.11: initialize loop mode (i.e. turn looping off) */
@@ -2312,7 +2311,6 @@
 	service_buffer_deallocate(lanai);
 	iounmap((void *) lanai->base);
 	kfree(lanai);
-	MOD_DEC_USE_COUNT;
 }
 
 /* close a vcc */
@@ -2686,7 +2684,8 @@
 	.phy_put	= NULL,
 	.phy_get	= NULL,
 	.change_qos	= lanai_change_qos,
-	.proc_read	= lanai_proc_read
+	.proc_read	= lanai_proc_read,
+	.owner		= THIS_MODULE
 };
 
 /* initialize one probed card */
