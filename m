From: Chris Caputo <ccaputo@alt.net>
Subject: Re: panic with 2.6.28 while doing "ip -6 route"
Date: Wed, 14 Jan 2009 06:15:38 +0000 (UTC)
Message-ID: <Pine.LNX.4.64.0901140610440.17915@nacho.alt.net>
References: <Pine.LNX.4.64.0901140204560.16420@nacho.alt.net>
	<20090114053534.GA15267@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nacho.alt.net ([208.90.169.18]:59561 "EHLO nacho.alt.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751900AbZANGWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 01:22:19 -0500
In-Reply-To: <20090114053534.GA15267@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Jan 2009, Herbert Xu wrote:
> I'm surprised that it's taken nearly 3 years for this bug to
> show itself.  It even survived a move from route.c :)
> 
> ipv6: Fix fib6_dump_table walker leak
> 
> When a fib6 table dump is prematurely ended, we won't unlink
> its walker from the list.  This causes all sorts of grief for
> other users of the list later.
> 
> Reported-by: Chris Caputo <ccaputo@alt.net>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
> index 29c7c99..52ee1dc 100644

I applied the patch, rebooted and performed about a hundred "ip -6 route | 
head" commands with the full v6 route table.  The fix works great!

Any chance of vectoring it for 2.6.28.x?

Thanks,
Chris
