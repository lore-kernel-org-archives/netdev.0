From: Ben Greear <greearb@candelatech.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Wed, 03 Jan 2007 17:02:03 -0800
Message-ID: <459C520B.3010406@candelatech.com>
References: <E1H2GVF-0008GJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, jarkao2@o2.pl,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40009 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932227AbXADBDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 20:03:17 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1H2GVF-0008GJ-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> David Stevens <dlstevens@us.ibm.com> wrote:
>> Ben,
>>        Here's a patch that I think will fix it, assuming the receive is 
>> on the
>> same device as the initialization. Can you try this out?
> 
> Hi David:
> 
> Your patch makes sense on its own but I don't see the direct connection
> to the soft lock-up.  Sure it prevents the code path in question from
> triggering.  However, if we don't understand why it's locking up in the
> first place then this may just be hiding it rather than fixing it.
> 
> In particular, a soft lockup means that we're doing so much work in
> the softirq handlers that processes are not getting run.  So what is
> it exactly here that's causing us to get stuck in the softirq handlers?
> Is it because we're somehow getting stuck in a net rx loop?

I'm not sure if it helps..but I did notice that 'ip' was using 99% of the
CPU on the system.  Could this be because it was spinning trying to acquire
the read-lock?  When I ran 'ifconfig -a', that process hung, and at that point
the system was rebooted.  Before I ran ifconfig, 'top' and 'ls' and similar
apps were responding fine, and I was logged in over ssh from the US to Australia, so
it's basic networking was functioning.

What if the race is that the read-lock is only half initialized, so that
it doesn't trigger the uninitialized-lock-use debug message, but still screws
up and will not ever let the reader acquire the lock?

Thanks,
Ben

> 
> Cheers,


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

