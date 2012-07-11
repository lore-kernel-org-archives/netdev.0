From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 03/16] tcp: Maintain dynamic metrics in local cache.
Date: Tue, 10 Jul 2012 17:44:46 -0700
Message-ID: <1341967486.13724.9.camel@joe2Laptop>
References: <20120710.080714.2272376193166978850.davem@davemloft.net>
	 <1341939724.6118.145.camel@joe2Laptop>
	 <20120710.172908.745359979722998717.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58407 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755413Ab2GKAos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 20:44:48 -0400
In-Reply-To: <20120710.172908.745359979722998717.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-07-10 at 17:29 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 10 Jul 2012 10:02:04 -0700
> 
> > Maybe something like this is a bit more legible?
> > {
> > 	if (a->family != b->family)
> > 		return false;
> > 
> > 	if (a->family == AF_INET)
> > 		return a->addr.a4 == b->addr.a4;
> > 
> > 	return ipv6_addr_equal((const struct in6_addr *)&a->addr.a6,
> > 			       (const struct in6_addr *)&b->addr.a6);
> > }
> 
> My version was meant to be fast rather than legible :-)

Fast to write you mean? ;)

I'd guess the one above is faster to execute.

If it's not, the code in ipv6_addr_equal
should be reverted. commit fed85383ac34d82
("[IPV6]: Use XOR and OR rather than mutiple ands for ipv6 address comparisons")

cheers, Joe
