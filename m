From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Thu, 08 Nov 2012 08:36:02 -0700
Message-ID: <509BD162.1000205@hp.com>
References: <509184D9.8030103@hp.com> <5093940B.6020207@parallels.com>  <5093E09A.6000004@hp.com> <1351899276.2703.35.camel@bwh-desktop.uk.solarflarecom.com> <50988BAE.6020602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:30109 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab2KHPgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2012 10:36:08 -0500
In-Reply-To: <50988BAE.6020602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/05/2012 09:01 PM, Brian Haley wrote:
>>>>> +    rcu_read_lock();
>>>>> +    dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
>>>>> +    if (dev)
>>>>> +        strcpy(devname, dev->name);
>>>>
>>>> This still races with the device name change, potentially providing
>>>> a name which never existed in the system, doesn't it?
>>>
>>> My only argument here is that SIOCGIFNAME has had this same code
>>> forever, and
>>> noone has ever complained about that returning a garbled name.  Even
>>> dev_get_by_name() only holds an rcu lock when doing a strncmp().
>>>
>>> We'd need to audit the whole kernel to catch all the places where we
>>> potentially
>>> look at dev->name while it could change.  Is it really worth it?
>>
>> A net device name can't be changed while the device is up, or while
>> another task holds the RTNL lock.  I think that covers almost all uses.
>> I don't know whether it's worth going out to look for exceptions, but we
>> might as well fix the cases we know about.
>
> So do you think we can fix these corner cases later and get the API
> right first?

Hi Dave,

I noticed this isn't in patchwork anymore.  Is it possible to get this 
in and then work on the other issue in a separate patch since it's not 
just this code that has this problem?

Of course I'm still not convinced that extra check is necessary (but 
I'll do it to make others happy) because if you do a setsockopt("eth0"), 
all you care is that a getsockopt() returns "eth0" - if it returns 
anything else, eth0_renamed, eth0_foo, etc you'll notice it's not the 
same and take action.  And the fact that the name can't change when UP 
means the odds are small it can happen anyways.

Thanks,

-Brian
