From: Jason Wang <jasowang@redhat.com>
Subject: Re: TUN problems (regression?)
Date: Fri, 21 Dec 2012 11:32:43 +0800
Message-ID: <50D3D85B.1070605@redhat.com>
References: <4151394.nMo40zlg68@sifl> <1356046697.21834.3606.camel@edumazet-glaptop> <20121220155001.538bbdb0@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Paul Moore <pmoore@redhat.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750875Ab2LUDcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 22:32:48 -0500
In-Reply-To: <20121220155001.538bbdb0@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2012 07:50 AM, Stephen Hemminger wrote:
> On Thu, 20 Dec 2012 15:38:17 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> On Thu, 2012-12-20 at 18:16 -0500, Paul Moore wrote:
>>> [CC'ing netdev in case this is a known problem I just missed ...]
>>>
>>> Hi Jason,
>>>
>>> I started doing some more testing with the multiqueue TUN changes and I ran 
>>> into a problem when running tunctl: running it once w/o arguments works as 
>>> expected, but running it a second time results in failure and a 
>>> kmem_cache_sanity_check() failure.  The problem appears to be very repeatable 
>>> on my test VM and happens independent of the LSM/SELinux fixup patches.
>>>
>>> Have you seen this before?
>>>
>> Obviously code in tun_flow_init() is wrong...
>>
>> static int tun_flow_init(struct tun_struct *tun)
>> {
>>         int i;
>>
>>         tun->flow_cache = kmem_cache_create("tun_flow_cache",
>>                                             sizeof(struct tun_flow_entry), 0, 0,
>>                                             NULL);
>>         if (!tun->flow_cache)
>>                 return -ENOMEM;
>> ...
>> }
>>
>>
>> I have no idea why we would need a kmem_cache per tun_struct,
>> and why we even need a kmem_cache.
> Normally flow malloc/free should be good enough.
> It might make sense to use private kmem_cache if doing hlist_nulls.
>
>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Should be at least a global cache, I thought I can get some speed-up by
using kmem_cache.

Acked-by: Jason Wang <jasowang@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
