From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: Re: Fw: [Kernel-janitors] net/atm/clip.c: check kmem_cache_create() #1
Date: Wed, 04 Feb 2004 14:04:17 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402041904.i14J4GRr017777@ginger.cmf.nrl.navy.mil>
References: <rddunlap@osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: Message from "Randy.Dunlap" <rddunlap@osdl.org>
   of "Wed, 28 Jan 2004 09:18:03 PST." <20040128091803.1da4cf1c.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

randy, i think it should probably return -ENOMEM instead of -1.

dave, please apply the following to both the 2.6 and 2.4 trees.

thanks!

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1548  -> 1.1549 
#	      net/atm/clip.c	1.29    -> 1.30   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/02/04	chas@relax.cmf.nrl.navy.mil	1.1549
# [ATM]: [clip] check return code from kmem_cache_create (by "Randy.Dunlap" <rddunlap@osdl.org>)
# --------------------------------------------
#
diff -Nru a/net/atm/clip.c b/net/atm/clip.c
--- a/net/atm/clip.c	Wed Feb  4 13:24:23 2004
+++ b/net/atm/clip.c	Wed Feb  4 13:24:23 2004
@@ -1021,6 +1021,9 @@
 	clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
 	    clip_tbl.entry_size, 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
 
+	if (!clip_tbl.kmem_cachep)
+		return -ENOMEM;
+
 	/* so neigh_ifdown() doesn't complain */
 	clip_tbl.proxy_timer.data = 0;
 	clip_tbl.proxy_timer.function = 0;



In message <20040128091803.1da4cf1c.rddunlap@osdl.org>,"Randy.Dunlap" writes:
>
>Hi Chas-
>
>What do you think of this patch?
>
>ISTM that the result of kmem_cache_create() should be checked,
>and this patch looks OK to me for a loadable module (it will
>fail loading).  But when this code is in the kernel image,
>will the rest of the code that depends on this kmem_cache_create()
>be OK, or will it try to use the kmem_cachep even though it
>is NULL?
>
>Thanks,
>~Randy
>~~~~~~~~~~~~~~~~~~~~~~~
>
>
>Begin forwarded message:
>
>Date: Sun, 25 Jan 2004 15:07:41 +0100
>From: <WHarms@bfs.de>(Walter Harms)
>To: <kernel-janitors@lists.osdl.org>
>Subject: [Kernel-janitors] net/atm/clip.c: check kmem_cache_create() #1
>
>
>
>
>--- net/atm/clip.c.org  2004-01-24 12:22:02.691771888 +0100
>+++ net/atm/clip.c      2004-01-24 12:27:57.074897464 +0100
>@@ -1026,6 +1026,9 @@
>        clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
>            clip_tbl.entry_size, 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
> 
>+       if (!clip_tbl.kmem_cachep)
>+               return -1;
>+
>        /* so neigh_ifdown() doesn't complain */
>        clip_tbl.proxy_timer.data = 0;
>        clip_tbl.proxy_timer.function = 0;
>_______________________________________________
>Kernel-janitors mailing list
>Kernel-janitors@lists.osdl.org
>http://lists.osdl.org/mailman/listinfo/kernel-janitors
>
>
>--
>~Randy
>kernel-janitors project:  http://janitor.kernelnewbies.org/
>
