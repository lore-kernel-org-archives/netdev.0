From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Linux 2.6.37-rc1 (net/sched: cls_cgroup)
Date: Wed, 3 Nov 2010 18:31:05 -0500
Message-ID: <20101103233105.GA26124@gondor.apana.org.au>
References: <AANLkTimr3rW67HxgOUyReEW8dmmSsd4b7-Ns57mXzS1w@mail.gmail.com> <20101103142156.73c2d3c9.randy.dunlap@oracle.com> <1288821677.2718.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ben Blum <bblum@andrew.cmu.edu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:53190 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635Ab0KCXb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 19:31:56 -0400
Content-Disposition: inline
In-Reply-To: <1288821677.2718.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 03, 2010 at 11:01:17PM +0100, Eric Dumazet wrote:
>
> commits 8e039d84b323c450 
> (cgroups: net_cls as module)
> 
> followed by commit f845172531f
> (cls_cgroup: Store classid in struct sock)

Indeed, it looks like the tree I worked on didn't have the first
patch applied for some reason.

Anyway, this patch should fix the problem.  Thanks Eric!

cls_cgroup: Fix crash on module unload

Somewhere along the lines net_cls_subsys_id became a macro when
cls_cgroup is built as a module.  Not only did it make cls_cgroup
completely useless, it also causes it to crash on module unload.

This patch fixes this by removing that macro.

Thanks to Eric Dumazet for diagnosing this problem.

Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 37dff78..d49c40f 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -34,8 +34,6 @@ struct cgroup_subsys net_cls_subsys = {
 	.populate	= cgrp_populate,
 #ifdef CONFIG_NET_CLS_CGROUP
 	.subsys_id	= net_cls_subsys_id,
-#else
-#define net_cls_subsys_id net_cls_subsys.subsys_id
 #endif
 	.module		= THIS_MODULE,
 };

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
