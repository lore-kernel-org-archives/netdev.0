From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: use dev_get_by_name() instead of atm_lane_ops->get_lec() [2/3]
Date: Thu, 25 Sep 2003 12:14:04 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251614.h8PGE3kT007069@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1456  -> 1.1457 
#	       net/atm/mpc.c	1.28    -> 1.29   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/23	chas@relax.cmf.nrl.navy.mil	1.1457
# [ATM]: use dev_get_by_name() instead of atm_lane_ops->get_lec() [2/3]
# --------------------------------------------
#
diff -Nru a/net/atm/mpc.c b/net/atm/mpc.c
--- a/net/atm/mpc.c	Thu Sep 25 09:25:42 2003
+++ b/net/atm/mpc.c	Thu Sep 25 09:25:42 2003
@@ -250,11 +250,11 @@
 static struct net_device *find_lec_by_itfnum(int itf)
 {
 	struct net_device *dev;
-	if (!try_atm_lane_ops())
-		return NULL;
+	char name[IFNAMSIZ];
 
-	dev = atm_lane_ops->get_lec(itf);
-	module_put(atm_lane_ops->owner);
+	sprintf(name, "lec%d", itf);
+	dev = dev_get_by_name(name);
+	
 	return dev;
 }
 
