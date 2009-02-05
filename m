From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Fri, 6 Feb 2009 10:43:18 +1100
Message-ID: <20090205234318.GA1929@gondor.apana.org.au>
References: <20090126.213112.197185044.davem@davemloft.net> <20090127075356.GA6255@alice> <20090128093507.GA15956@gondor.apana.org.au> <20090129.174954.263448549.davem@davemloft.net> <20090205130149.GA28152@gondor.apana.org.au> <20090205143143.GA18734@alice> <adafxisjzel.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Sesterhenn <snakebyte@gmx.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54297 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756438AbZBEXnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 18:43:31 -0500
Content-Disposition: inline
In-Reply-To: <adafxisjzel.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2009 at 02:24:02PM -0800, Roland Dreier wrote:
>
> >From a quick scan of the code, it looks as if optlen is never sanity
> checked in the case of setsockopt(IPV6_FLOWLABEL_MGR), and
> ipv6_flowlabel_opt() calls into fl_create() with whatever value
> userspace passes in, which then pretty much does kmalloc(optlen).
> So if icmpv6fuzz passes some big random value, it can cause this failure.
> 
> I don't know what the appropriate limit should be, so no patch, sorry.

Well it is legal (though unlikely) to pass very long options.
So the real fix would be to avoid copying the control message
at all and modify all the code involved to read user pointers
directly.  Someone with a lot of patience is required for this :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
