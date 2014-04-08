From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Tue, 08 Apr 2014 09:48:40 -0700
Message-ID: <53442868.3090701@candelatech.com>
References: <20140407075347.GA26461@gondor.apana.org.au> <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au> <1396879662.12330.63.camel@edumazet-glaptop2.roam.corp.google.com> <20140407142334.GA28814@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49152 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890AbaDHQsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 12:48:50 -0400
In-Reply-To: <20140407142334.GA28814@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/07/2014 07:23 AM, Herbert Xu wrote:
> On Mon, Apr 07, 2014 at 07:07:42AM -0700, Eric Dumazet wrote:
>>
>> I suppose its a net-next material ?
> 
> Oh yes absolutely.
> 
>> Memory allocations (one incoming message -> ~4096 duplications) probably
>> should use GFP_KERNEL. This might need a change from rcu to simple mutex
>> for macvlan_broadcast() scan of all macvlans.
> 
> Good point.  However, as this change will be non-trivial we can
> do this as a follow-up.
> 
>> cond_resched() could help macvlan_process_broadcast() to not hog cpu.
>>
>> Anyway, 4.000 incoming messages are duplicated into 16.000.000 messages,
>> it takes half a minute to process on a single cpu. You might need
>> multiple workqueue to split the load on all online cpus ;)
> 
> You're welcome to add further improvements :)

At least for ARPs, maybe we could inspect the packet and only
deliver to interfaces configured with the MAC that is being
ARPed for (or ones that are in promisc)?

This would need to be a configurable optimization probably,
since perhaps someone depends on the current behaviour....

Thanks,
Ben

> 
> Thanks,
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
