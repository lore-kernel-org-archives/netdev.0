From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 7/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 14:01:09 -0700
Message-ID: <20120911210109.GZ7677@google.com>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
 <1347380774-9546-8-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:49881 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab2IKVBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 17:01:14 -0400
Content-Disposition: inline
In-Reply-To: <1347380774-9546-8-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Daniel.

I generally like this but I still think it's too big a patch.

> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index c75e3f9..6bc460c 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -326,9 +326,7 @@ struct cgroup_subsys net_prio_subsys = {
>  	.create		= cgrp_create,
>  	.destroy	= cgrp_destroy,
>  	.attach		= net_prio_attach,
> -#ifdef CONFIG_NETPRIO_CGROUP
>  	.subsys_id	= net_prio_subsys_id,
> -#endif
>  	.base_cftypes	= ss_files,
>  	.module		= THIS_MODULE
>  };
> @@ -366,10 +364,6 @@ static int __init init_cgroup_netprio(void)
>  	ret = cgroup_load_subsys(&net_prio_subsys);
>  	if (ret)
>  		goto out;
> -#ifndef CONFIG_NETPRIO_CGROUP
> -	smp_wmb();
> -	net_prio_subsys_id = net_prio_subsys.subsys_id;
> -#endif
>  
>  	register_netdevice_notifier(&netprio_device_notifier);
>  
> @@ -386,11 +380,6 @@ static void __exit exit_cgroup_netprio(void)
>  
>  	cgroup_unload_subsys(&net_prio_subsys);
>  
> -#ifndef CONFIG_NETPRIO_CGROUP
> -	net_prio_subsys_id = -1;
> -	synchronize_rcu();

For example, it's not evident the above is correct and it's burried
with all other changes.  Can't we just assign the fixed subsys ID to
net_prio_subsys_id in this patch?  This patch would be correct without
any netprio changes, no?  Please separate these changes and explain
them.

BTW, people who use barriers of any kind without explicitly explaining
what's going on need to be kicked hard in the ass.  :(

Thanks.

-- 
tejun
