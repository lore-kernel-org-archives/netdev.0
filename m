From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Sat, 13 Dec 2008 17:03:22 +0300
Message-ID: <20081213140322.GA21443@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au> <1229120724.3051.61.camel@achroite> <20081212225659.GB11636@gondor.apana.org.au> <20081212231138.GA11883@gondor.apana.org.au> <20081213034356.GA14523@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:33756 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756013AbYLMODY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Dec 2008 09:03:24 -0500
Content-Disposition: inline
In-Reply-To: <20081213034356.GA14523@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 13, 2008 at 02:43:56PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > BTW this should be pretty easy to implement through a second
> > entry, e.g., napi_gro_receive_pages() that works just like its
> > LRO counter-part lro_receive_frags.  This would have its own
> > protocol hooks so it doesn't need to do anything nasty to get
> > at the packet headers.
> 
> In fact we don't even need extra hooks.  All we need to do is to
> keep one pre-allocated in the napi struct, and use that to hold
> the pages while we process it.  If it's merged (we'd modify the
> low-level skb_gro_receive to merge the pages directly rather than
> the skb), then we return the skb to use it again for the next
> packet.  If not then we just allocate a new skb.  This way none
> of the protocol-specific code needs to handle pages at all.

This sounds good!

-- 
	Evgeniy Polyakov
