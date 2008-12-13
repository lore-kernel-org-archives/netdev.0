From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Sat, 13 Dec 2008 14:43:56 +1100
Message-ID: <20081213034356.GA14523@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au> <1229120724.3051.61.camel@achroite> <20081212225659.GB11636@gondor.apana.org.au> <20081212231138.GA11883@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56296 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751702AbYLMDoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 22:44:01 -0500
Content-Disposition: inline
In-Reply-To: <20081212231138.GA11883@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 10:11:38AM +1100, Herbert Xu wrote:
>
> BTW this should be pretty easy to implement through a second
> entry, e.g., napi_gro_receive_pages() that works just like its
> LRO counter-part lro_receive_frags.  This would have its own
> protocol hooks so it doesn't need to do anything nasty to get
> at the packet headers.

In fact we don't even need extra hooks.  All we need to do is to
keep one pre-allocated in the napi struct, and use that to hold
the pages while we process it.  If it's merged (we'd modify the
low-level skb_gro_receive to merge the pages directly rather than
the skb), then we return the skb to use it again for the next
packet.  If not then we just allocate a new skb.  This way none
of the protocol-specific code needs to handle pages at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
