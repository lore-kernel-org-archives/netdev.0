From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [he] possibly using corrupted structure (from felipewd@terra.com.br)
Date: Mon, 22 Sep 2003 10:52:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309221452.h8MEqokT005989@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to both 2.4 and 2.6.  --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1445  -> 1.1446 
#	    drivers/atm/he.c	1.24    -> 1.25   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/22	chas@relax.cmf.nrl.navy.mil	1.1446
# [ATM]: [he] possibly using corrupted structure (from felipewd@terra.com.br)
# --------------------------------------------
#
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	Mon Sep 22 10:51:28 2003
+++ b/drivers/atm/he.c	Mon Sep 22 10:51:28 2003
@@ -2864,8 +2864,10 @@
 			if (!capable(CAP_NET_ADMIN))
 				return -EPERM;
 
-			copy_from_user(&reg, (struct he_ioctl_reg *) arg,
-						sizeof(struct he_ioctl_reg));
+			if (copy_from_user(&reg, (struct he_ioctl_reg *) arg,
+						sizeof(struct he_ioctl_reg)))
+				return -EFAULT;
+			
 			spin_lock_irqsave(&he_dev->global_lock, flags);
 			switch (reg.type) {
 				case HE_REGTYPE_PCI:
@@ -2889,8 +2891,9 @@
 			}
 			spin_unlock_irqrestore(&he_dev->global_lock, flags);
 			if (err == 0)
-				copy_to_user((struct he_ioctl_reg *) arg, &reg,
-							sizeof(struct he_ioctl_reg));
+				if (copy_to_user((struct he_ioctl_reg *) arg, &reg,
+							sizeof(struct he_ioctl_reg)))
+					return -EFAULT;
 			break;
 		default:
 #ifdef CONFIG_ATM_HE_USE_SUNI
