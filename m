From: Li Zefan <lizf.kern@gmail.com>
Subject: Re: Linux 2.6.37-rc1 (net/sched: cls_cgroup)
Date: Thu, 04 Nov 2010 09:46:07 +0800
Message-ID: <4CD2105F.6090900@gmail.com>
References: <AANLkTimr3rW67HxgOUyReEW8dmmSsd4b7-Ns57mXzS1w@mail.gmail.com> <20101103142156.73c2d3c9.randy.dunlap@oracle.com> <1288821677.2718.27.camel@edumazet-laptop> <20101103233105.GA26124@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Thomas Graf <tgraf@suug.ch>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ben Blum <bblum@andrew.cmu.edu>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101103233105.GA26124@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> commits 8e039d84b323c450 
>> (cgroups: net_cls as module)
>>
>> followed by commit f845172531f
>> (cls_cgroup: Store classid in struct sock)
> 
> Indeed, it looks like the tree I worked on didn't have the first
> patch applied for some reason.
> 

The first patch was merged in .34, and the second one .35, and
from the changelog and the diff, seems you did know cls_cgroup
can be a module. ;)

> Anyway, this patch should fix the problem.  Thanks Eric!
> 
> cls_cgroup: Fix crash on module unload
> 
> Somewhere along the lines net_cls_subsys_id became a macro when
> cls_cgroup is built as a module.  Not only did it make cls_cgroup
> completely useless, it also causes it to crash on module unload.
> 
> This patch fixes this by removing that macro.
> 
> Thanks to Eric Dumazet for diagnosing this problem.
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 

Reviewed-by: Li Zefan <lizf@cn.fujitsu.com>

> diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
> index 37dff78..d49c40f 100644
> --- a/net/sched/cls_cgroup.c
> +++ b/net/sched/cls_cgroup.c
> @@ -34,8 +34,6 @@ struct cgroup_subsys net_cls_subsys = {
>  	.populate	= cgrp_populate,
>  #ifdef CONFIG_NET_CLS_CGROUP
>  	.subsys_id	= net_cls_subsys_id,
> -#else
> -#define net_cls_subsys_id net_cls_subsys.subsys_id
>  #endif
>  	.module		= THIS_MODULE,
>  };
> 
> Cheers,
