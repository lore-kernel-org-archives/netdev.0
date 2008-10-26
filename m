From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: tbench wrt. loopback TSO
Date: Sun, 26 Oct 2008 15:34:42 +0300
Message-ID: <20081026123442.GA31506@ioremap.net>
References: <20081015.171408.193701292.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadrack.ru ([195.178.208.66]:48855 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751944AbYJZMep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2008 08:34:45 -0400
Content-Disposition: inline
In-Reply-To: <20081015.171408.193701292.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Wed, Oct 15, 2008 at 05:14:08PM -0700, David Miller (davem@davemloft.net) wrote:
> 
> I got curious about this aspect of the investigation so I wanted
> to see it first-hand :-)
> 
> To be honest, this reported effect of disabling TSO in the loopback
> driver surprised me because:
> 
> 1) If the benchmark is doing small writes, TSO should have zero
>    effect.  The TSO logic won't kick in.

But GSO will try to create a huge packet and that overhead will not be
overweighted?

That's what I got with the current tree for 8 threads on a 4-way 32-bit
Xeons (2 physical CPUs) and 8gb of ram:
gso/tso off: 361.367
tso/gso on:  354.635

Disabled/enabled via ethtools: -k tso off/on gso off/on

> 2) If larger than MTU writes are being done, TSO should help,
>    and this is supported by other benchmarks :-)

Yes, that's where it is useful.

-- 
	Evgeniy Polyakov
