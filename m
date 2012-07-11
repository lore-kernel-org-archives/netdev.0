From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 18:22:16 -0700
Message-ID: <1341969736.13724.32.camel@joe2Laptop>
References: <1341939724.6118.145.camel@joe2Laptop>
	 <20120710.172908.745359979722998717.davem@davemloft.net>
	 <1341967486.13724.9.camel@joe2Laptop>
	 <20120710.180137.2161994914932724530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46762 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752653Ab2GKBWR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:22:17 -0400
In-Reply-To: <20120710.180137.2161994914932724530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 18:01 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 10 Jul 2012 17:44:46 -0700
> 
> > I'd guess the one above is faster to execute.
> 
> It is.
> 
> > If it's not, the code in ipv6_addr_equal
> > should be reverted. commit fed85383ac34d82
> > ("[IPV6]: Use XOR and OR rather than mutiple ands for ipv6 address comparisons")
> 
> Not necessarily.
> 
> My version here is faster because we unconditionally test
> the first word, which we need to do for both the ipv4 and
> ipv6 cases.

I don't think that's correct.
Look at what I posted again.

If it's IPv4, 

	if (a->family == AF_INET)
		return a->addr.a4 == b->addr.a4;

	return ipv6_addr_equal((const struct in6_addr *)&a->addr.a6,
			       (const struct in6_addr *)&b->addr.a6);

so it's a single word test or a 4 word test.

Your code is compare/branch/continue in a loop with an
increment and test.  I find it hard to believe that's
faster.  I suppose it _could_ be faster dependent on the
data in the words though.

> The ipv6 routine optimization you mention exists in a
> world where we know we have an ipv6 address always, which
> is not the case here.

What do I miss?

Is there a case where a->family is neither
AF_INET or AF_INET6?

> If anything, we should do XOR's on the final three words,
> but we should not remove the first word optimization for
> ipv4 which is the common case.

cheers, Joe
