From: chas williams <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: sdh should be off by default
Date: Thu, 16 Oct 2003 07:21:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310161121.h9GBLckT010649@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 --thanks

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1441  -> 1.1442 
#	    drivers/atm/he.c	1.29    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/10	chas@relax.cmf.nrl.navy.mil	1.1442
# [ATM]: sdh should be off by default
# --------------------------------------------
#
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	Wed Oct 15 14:49:01 2003
+++ b/drivers/atm/he.c	Wed Oct 15 14:49:01 2003
@@ -158,7 +158,7 @@
 static short nvcibits = -1;
 static short rx_skb_reserve = 16;
 static short irq_coalesce = 1;
-static short sdh = 1;
+static short sdh = 0;
 
 static struct atmdev_ops he_ops =
 {
@@ -1556,11 +1556,10 @@
 
 	if (sdh) {
 		/* this really should be in suni.c but for now... */
-
 		int val;
 
 		val = he_phy_get(he_dev->atm_dev, SUNI_TPOP_APM);
-		val = (val & ~SUNI_TPOP_APM_S) | ( 0x2 << SUNI_TPOP_APM_S_SHIFT);
+		val = (val & ~SUNI_TPOP_APM_S) | (SUNI_TPOP_S_SDH << SUNI_TPOP_APM_S_SHIFT);
 		he_phy_put(he_dev->atm_dev, val, SUNI_TPOP_APM);
 	}
 
