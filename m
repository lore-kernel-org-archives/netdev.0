From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [lec] lec_push() races with vcc->proto_data
Date: Wed, 24 Mar 2004 18:12:22 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403242312.i2ONCKGG026715@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to the 2.6 and 2.4 kernels.

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1674  -> 1.1675 
#	       net/atm/lec.c	1.39    -> 1.40   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/24	chas@relax.cmf.nrl.navy.mil	1.1675
# [ATM]: [lec] lec_push() races with vcc->proto_data
# --------------------------------------------
#
diff -Nru a/net/atm/lec.c b/net/atm/lec.c
--- a/net/atm/lec.c	Wed Mar 24 15:17:37 2004
+++ b/net/atm/lec.c	Wed Mar 24 15:17:37 2004
@@ -797,8 +797,8 @@
 	vcc->pop = lec_pop;
         lec_vcc_added(dev_lec[ioc_data.dev_num]->priv, 
                       &ioc_data, vcc, vcc->push);
-        vcc->push = lec_push;
         vcc->proto_data = dev_lec[ioc_data.dev_num];
+        vcc->push = lec_push;
         return 0;
 }
 
