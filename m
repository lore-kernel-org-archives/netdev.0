From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [nicstar] use kernel min/max (by "Randy.Dunlap" <rddunlap@osdl.org>)
Date: Wed, 24 Mar 2004 18:12:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403242312.i2ONCu6E026729@ginger.cmf.nrl.navy.mil>
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
#	           ChangeSet	1.1673  -> 1.1674 
#	drivers/atm/nicstar.c	1.21    -> 1.22   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/03/24	chas@relax.cmf.nrl.navy.mil	1.1674
# [ATM]: [nicstar] use kernel min/max (by "Randy.Dunlap" <rddunlap@osdl.org>)
# --------------------------------------------
#
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	Wed Mar 24 15:17:23 2004
+++ b/drivers/atm/nicstar.c	Wed Mar 24 15:17:23 2004
@@ -112,9 +112,6 @@
 
 /* Macros *********************************************************************/
 
-#define MAX(a,b) ((a) > (b) ? (a) : (b))
-#define MIN(a,b) ((a) < (b) ? (a) : (b))
-
 #define CMD_BUSY(card) (readl((card)->membase + STAT) & NS_STAT_CMDBZ)
 
 #define NS_DELAY mdelay(1)
@@ -2483,7 +2480,7 @@
             for (j = 1; j < NS_SKB(iovb)->iovcnt; j++)
             {
                lb = (struct sk_buff *) iov->iov_base;
-               tocopy = MIN(remaining, iov->iov_len);
+               tocopy = min_t(int, remaining, iov->iov_len);
                memcpy(hb->tail, lb->data, tocopy);
                skb_put(hb, tocopy);
                iov++;
