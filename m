From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 3/3] decrement static keys on real destroy time
Date: Fri, 20 Apr 2012 16:39:00 -0300
Message-ID: <4F91BB54.8030703@parallels.com>
References: <1334875758-20939-1-git-send-email-glommer@parallels.com> <1334875758-20939-4-git-send-email-glommer@parallels.com> <4F911289.1050403@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F911289.1050403-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/20/2012 04:38 AM, KAMEZAWA Hiroyuki wrote:
>>   			mem_cgroup_get(memcg);
>> >  -			sk->sk_cgrp = sk->sk_prot->proto_cgroup(memcg);
>> >  +			sk->sk_cgrp = cg_proto;
>> >    		}
> 
> 
> Is this correct ? cg_proto->active can be true before all jump_labels are
> patched, then we can loose accounting. That will cause underflow of
> res_countner.
> 
> cg_proto->active should be set after jump_label modification.
> Then, things will work, I guess.
> 
> Thanks,
> -Kame
> 

Kame,

You are right.

The first update needs to be done after the jump label activation as
well. I got myself confused with the two flags =(

I will repost with this fixed once I get into agreement with Tejun and
Li about the lockless ->destroy()
