From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Wed, 11 Aug 2010 23:16:32 -0700 (PDT)
Message-ID: <20100811.231632.59670387.davem@davemloft.net>
References: <20100811110330.GA6440@gondor.apana.org.au>
	<20100811112706.GA6772@gondor.apana.org.au>
	<20100811153736.GA31577@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54522
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754658Ab0HLGQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 02:16:15 -0400
In-Reply-To: <20100811153736.GA31577@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Wed, 11 Aug 2010 11:37:36 -0400

> On Wed, Aug 11, 2010 at 07:27:06AM -0400, Herbert Xu wrote:
>> On Wed, Aug 11, 2010 at 07:03:30AM -0400, Herbert Xu wrote:
>> >
>> > To use rcu_read_lock safely we'd also need to add do synchronize_rcu
>> > in addition of synchronize_rcu_bh, right Paul?
>> > 
>> > Of course as we were doing this unsafely prior to my patch anyway
>> > I'm also fine with just reverting it.
>> 
>> Actually, we could just disable IRQs for stable.  How about this
>> patch (untested)?
>> 
>> netpoll: Disable IRQ around RCU dereference in netpoll_rx
>> 
>> We cannot use rcu_dereference_bh safely in netpoll_rx as we may
>> be called with IRQs disabled.  We could however simply disable
>> IRQs as that too causes BH to be disabled and is safe in either
>> case.
>> 
>> Thanks to John Linville for discovering this bug and providing
>> a patch.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> This also seems to work for me.

I'll queue up this variant for -stable.

And we'll go with making use of Paul's new RCU irqsoff interface
approach for Linus's tree.

Thanks.
