From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Sat, 13 Dec 2008 10:11:38 +1100
Message-ID: <20081212231138.GA11883@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au> <1229120724.3051.61.camel@achroite> <20081212225659.GB11636@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42075 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753745AbYLLXLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 18:11:44 -0500
Content-Disposition: inline
In-Reply-To: <20081212225659.GB11636@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 09:56:59AM +1100, Herbert Xu wrote:
>
> > The inet_lro code accepts either skbs or pages and the sfc driver takes
> > advantage of this: so long as most packets can be coalesced by LRO, it's
> > cheaper to allocate page buffers in advance and then attach them to skbs
> > during LRO.  I think you should support the use of page buffers.
> > Obviously it adds complexity but there's a real performance benefit.
> > (Alternately you could work out how to make skb allocation cheaper, and
> > everyone would be happy!)
> 
> This is something which I will look at in future.  The top priority
> right now is to get bridging to work with GRO.

BTW this should be pretty easy to implement through a second
entry, e.g., napi_gro_receive_pages() that works just like its
LRO counter-part lro_receive_frags.  This would have its own
protocol hooks so it doesn't need to do anything nasty to get
at the packet headers.

But I'd like to get the main infrastructure nailed down first
before we tack on bells and whistles like this and VLAN support.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
