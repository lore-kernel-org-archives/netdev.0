From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [idt77252] get rid of MOD_INC/MOD_DEC
Date: Sun, 21 Sep 2003 10:45:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309211445.h8LEjbkT023734@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1438  -> 1.1439 
#	drivers/atm/idt77252.c	1.25    -> 1.26   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/09	chas@relax.cmf.nrl.navy.mil	1.1439
# [ATM]: [idt77252] get rid of MOD_INC/MOD_DEC
# --------------------------------------------
#
diff -Nru a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c	Sun Sep 21 09:36:42 2003
+++ b/drivers/atm/idt77252.c	Sun Sep 21 09:36:42 2003
@@ -149,7 +149,8 @@
 	.phy_put	= idt77252_phy_put,
 	.phy_get	= idt77252_phy_get,
 	.change_qos	= idt77252_change_qos,
-	.proc_read	= idt77252_proc_read
+	.proc_read	= idt77252_proc_read,
+	.owner		= THIS_MODULE
 };
 
 static struct idt77252_dev *idt77252_chain = NULL;
@@ -2542,7 +2543,6 @@
 	}
 
 	set_bit(ATM_VF_READY, &vcc->flags);
-	MOD_INC_USE_COUNT;
 
 	up(&card->mutex);
 	return 0;
@@ -2629,7 +2629,6 @@
 		free_scq(card, vc->scq);
 	}
 
-	MOD_DEC_USE_COUNT;
 	up(&card->mutex);
 }
 
