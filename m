From: Daniel Walker <dwalker@mvista.com>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sat, 20 Sep 2008 11:52:31 -0700
Message-ID: <1221936751.1343.226.camel@localhost.localdomain>
References: <20080919.234824.223177211.davem@davemloft.net>
	 <1221924561.1343.121.camel@localhost.localdomain>
	 <20080920084512.58f7fb08@infradead.org>
	 <1221926529.1343.140.camel@localhost.localdomain>
	 <20080920091918.0ffaef8c@infradead.org>
	 <1221932404.1343.196.camel@localhost.localdomain>
	 <20080920110952.05da49ab@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:38735 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796AbYITSwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 14:52:37 -0400
In-Reply-To: <20080920110952.05da49ab@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-09-20 at 11:09 -0700, Arjan van de Ven wrote:


> > 
> > Dave didn't supply the users of his code, or what kind of improvement
> > was seen, or the case in which it would be needed. I think Dave knowns
> > his subsystem, but the code on the surface looks like an end run
> > around some other problem area..
> 
> it's very fundamental, and has been talked about at various conferences
> as well.

At least you understand that not everyone goes to conferences..

> the basic problem is that the submitter of the IO (be it block or net)
> creates a ton of metadata state on submit, and ideally the completion
> processing happens on the same CPU, for two reasons
> 1) to use the state in the cache
> 2) for the case where you touch userland data/structures, we assume the
> scheduler kept affinity
> 
> it's a Moses-to-the-Mountain problem, except we have four Moses' but
> only one Mountain. 
> 
> Or in CS terms: we move the work to the CPU where the userland is
> rather than moving the userland to the IRQ CPU, since there is usually
> only one IRQ but many userlands and many cpu cores.

There must be some kind of trade off here .. There's a fairly good
performance gain from have the softirq asserted and run on the same cpu
since it runs in interrupt context right after the interrupt.

If you move the softirq to another cpu then you have to re-assert and
either wait for ksoftirqd to handle it or wait for an interrupt on the
new cpu .. Neither is very predictable..

All that vs. bouncing data around the caches.. To what degree has all
that been handled or thought about?

Daniel

