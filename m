From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH v3 7/8] cgroup: Assign subsystem IDs during compile time
Date: Tue, 11 Sep 2012 23:15:02 +0200
Message-ID: <504FA9D6.4050201@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org> <1347380774-9546-8-git-send-email-wagi@monom.org> <20120911210109.GZ7677@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120911210109.GZ7677-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 09/11/2012 11:01 PM, Tejun Heo wrote:
> Hello, Daniel.
>
> I generally like this but I still think it's too big a patch.

Yes, I agree it is a bit too big.

>> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
>> index c75e3f9..6bc460c 100644
>> --- a/net/core/netprio_cgroup.c
>> +++ b/net/core/netprio_cgroup.c
>> @@ -326,9 +326,7 @@ struct cgroup_subsys net_prio_subsys = {
>>   	.create		= cgrp_create,
>>   	.destroy	= cgrp_destroy,
>>   	.attach		= net_prio_attach,
>> -#ifdef CONFIG_NETPRIO_CGROUP
>>   	.subsys_id	= net_prio_subsys_id,
>> -#endif
>>   	.base_cftypes	= ss_files,
>>   	.module		= THIS_MODULE
>>   };
>> @@ -366,10 +364,6 @@ static int __init init_cgroup_netprio(void)
>>   	ret = cgroup_load_subsys(&net_prio_subsys);
>>   	if (ret)
>>   		goto out;
>> -#ifndef CONFIG_NETPRIO_CGROUP
>> -	smp_wmb();
>> -	net_prio_subsys_id = net_prio_subsys.subsys_id;
>> -#endif
>>
>>   	register_netdevice_notifier(&netprio_device_notifier);
>>
>> @@ -386,11 +380,6 @@ static void __exit exit_cgroup_netprio(void)
>>
>>   	cgroup_unload_subsys(&net_prio_subsys);
>>
>> -#ifndef CONFIG_NETPRIO_CGROUP
>> -	net_prio_subsys_id = -1;
>> -	synchronize_rcu();
>
> For example, it's not evident the above is correct and it's burried
> with all other changes.  Can't we just assign the fixed subsys ID to
> net_prio_subsys_id in this patch?  This patch would be correct without
> any netprio changes, no?

If net_prio_subsys_id is changed to be an enum, then the compiler will 
report an error:

error: lvalue required as left operand of assignment

that was the reason why I kept this change here. I think I just don't 
get what you are trying to tell me.

> Please separate these changes and explain them.

I will do that as soon I figured out what you are telling me.

> BTW, people who use barriers of any kind without explicitly explaining
> what's going on need to be kicked hard in the ass.  :(

I looked up the commit message when the synchronze_rcu() was added. It 
was not really explaining it. I really spend a few hours starring at 
this code.

thanks for the review,
daniel
