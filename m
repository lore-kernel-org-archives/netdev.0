From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] [PATCH] ATM - remove unnecessary GFP_ATOMIC allocation
Date: Fri, 05 Sep 2003 08:52:22 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309051252.h85CqKSa005300@ginger.cmf.nrl.navy.mil>
References: <20030905115308.GA96209@compsoc.man.ac.uk>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, John Levon <levon@movementarian.org>
Reply-To: chas3@users.sourceforge.net
In-reply-to: Your message of "Fri, 05 Sep 2003 12:53:08 BST."
             <20030905115308.GA96209@compsoc.man.ac.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030905115308.GA96209@compsoc.man.ac.uk>,John Levon writes:
>There's no reason to allocate with GFP_ATOMIC in __alloc_atm_dev(). It has one
>callsite that is not under a spin lock (quick audit of drivers calling
>atm_dev_register() too).

it used to be under a spinlock (the infamous atm global spinlock).  that's
no longer the case so it doesnt need to be ATOMIC anymore.  i probably 
missed it when i fixed the spinlock.

dave, please apply to 2.6 (and 2.4) --thanks

[ATM]: remove unnecessary GFP_ATOMIC allocation (from levon@movementarian.org)

diff -Naurp -X dontdiff linux-cvs/net/atm/resources.c linux-fixes/net/atm/resources.c
--- linux-cvs/net/atm/resources.c	2003-07-09 14:19:52.000000000 +0100
+++ linux-fixes/net/atm/resources.c	2003-09-05 13:14:08.000000000 +0100
@@ -30,7 +30,7 @@
 {
 	struct atm_dev *dev;
 
-	dev = kmalloc(sizeof(*dev), GFP_ATOMIC);
+	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
 	if (!dev)
 		return NULL;
 	memset(dev, 0, sizeof(*dev));
