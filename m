From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Mon, 9 Feb 2009 16:03:54 +1100
Message-ID: <20090209050354.GA3548@gondor.apana.org.au>
References: <20090206.030716.136181382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43199 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750696AbZBIFEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 00:04:09 -0500
Content-Disposition: inline
In-Reply-To: <20090206.030716.136181382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> But some apps might start breaking since this would now
> charge the socket and we could hit the limits whereas
> before we wouldn't.

Yes we should definitely test this carefully.

However, I think it is the right thing to do since we shouldn't
leave holes where the user can allocate kernel memory that is
uncapped.

In fact, a number of spots in IPv6 already use sock_kmalloc
for these objects anyway (e.g., ipv6_dup_options in exthdrs.c)
so there is no fundamental reason why this limit can't be imposed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
