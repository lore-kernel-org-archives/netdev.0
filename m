From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] replace current->state = x with set_current_state(x) in drivers/atm/* [2.6.0-test1]
Date: Tue, 29 Jul 2003 13:42:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307291745.h6THjIsG028329@ginger.cmf.nrl.navy.mil>
References: <200307252042.35832.bellucda@tiscali.it>
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bellucda@tiscali.it
In-reply-to: Your message of "Fri, 25 Jul 2003 20:42:35 +0200."
             <200307252042.35832.bellucda@tiscali.it>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave, please apply this to the 2.6 tree.

In message <200307252042.35832.bellucda@tiscali.it>,Daniele Bellucci writes:
>Hi Chas, 
>ACME told me to post my patches to you ....
>
>please tell'me if correct.


[atm]: use set_current_state(x) (from bellucda@tiscali.it)

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1598  -> 1.1599 
#	drivers/atm/firestream.c	1.18    -> 1.19   
#	drivers/atm/atmtcp.c	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/29	chas@relax.cmf.nrl.navy.mil	1.1599
# use set_current_state(x) (from bellucda@tiscali.it)
# --------------------------------------------
#
diff -Nru a/drivers/atm/atmtcp.c b/drivers/atm/atmtcp.c
--- a/drivers/atm/atmtcp.c	Tue Jul 29 13:41:18 2003
+++ b/drivers/atm/atmtcp.c	Tue Jul 29 13:41:18 2003
@@ -77,7 +77,7 @@
 		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule();
 	}
-	current->state = TASK_RUNNING;
+	set_current_state(TASK_RUNNING);
 	remove_wait_queue(vcc->sk->sk_sleep, &wait);
 	return error;
 }
diff -Nru a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c	Tue Jul 29 13:41:18 2003
+++ b/drivers/atm/firestream.c	Tue Jul 29 13:41:18 2003
@@ -1722,7 +1722,7 @@
 		}
 
 		/* Try again after 10ms. */
-		current->state = TASK_UNINTERRUPTIBLE;
+		set_current_state(TASK_UNINTERRUPTIBLE);
 		schedule_timeout ((HZ+99)/100);
 	}
 
