From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: prevent user-space compilation errors
Date: Wed, 11 Feb 2004 09:25:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402111425.i1BEPtRr005772@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, "Peter" <huisheng@angelfire.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

the script used by redhat to generate glibc-kernheaders doesnt
seem to handle #ifdef __KERNEL__/#else/#endif properly. it seems
to remove the #ifdef/#else and leaves a dangling #endif.

this patch simplifies things a bit.  please apply to 2.6 and 2.4.

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1315  -> 1.1316 
#	include/linux/sonet.h	1.1     -> 1.2    
#	include/linux/atmdev.h	1.12    -> 1.13   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/10	chas@relax.cmf.nrl.navy.mil	1.1316
# [ATM]: prevent userspace compilation errors with glibc-kernheaders
# --------------------------------------------
#
diff -Nru a/include/linux/atmdev.h b/include/linux/atmdev.h
--- a/include/linux/atmdev.h	Tue Feb 10 16:13:55 2004
+++ b/include/linux/atmdev.h	Tue Feb 10 16:13:55 2004
@@ -199,9 +199,7 @@
     "SESSION",	"HASSAP",	"BOUND",	"CLOSE"
 
 
-#ifndef __KERNEL__
-#undef __AAL_STAT_ITEMS
-#else
+#ifdef __KERNEL__
 
 #include <linux/sched.h> /* wait_queue_head_t */
 #include <linux/time.h> /* struct timeval */
diff -Nru a/include/linux/sonet.h b/include/linux/sonet.h
--- a/include/linux/sonet.h	Tue Feb 10 16:13:55 2004
+++ b/include/linux/sonet.h	Tue Feb 10 16:13:55 2004
@@ -56,9 +56,7 @@
 #define SONET_FRSENSE_SIZE 6		/* C1[3],H1[3] (0xff for unknown) */
 
 
-#ifndef __KERNEL__
-#undef __SONET_ITEMS
-#else
+#ifdef __KERNEL__
 
 #include <asm/atomic.h>
 
