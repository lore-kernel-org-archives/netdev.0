From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
	causes kernel oops
Date: Wed, 19 Oct 2011 10:08:07 +0200
Message-ID: <20111019080807.GA25099@gondor.apana.org.au>
References: <20111018134537.GA17055@gondor.apana.org.au> <20111019.030914.218521668377472155.davem@davemloft.net> <1319008713.17914.8.camel@edumazet-laptop> <20111019.033052.851679720607111734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111019.033052.851679720607111734.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2011 at 03:30:52AM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 19 Oct 2011 09:18:33 +0200
> 
> > Seems fine (Maybe do the +15 in caller site ?), but we also have other
> > problematic cases, using alloc_skb() only...
> 
> Ok, which ones operate over these problematic GRE tunnels?

Potentially all of them since we now support Ethernet-over-GRE.

I think Eric's initial patch is probably the safest bet for rc10.
We can then work on the proper fix for the next release.

As to the latter, I've just done a grep over net and it seems that
all users of LL_ALLOCATED_SPACE fall into two cases, alloc_skb users
or sock_alloc_send_skb (including pskb) users.

For alloc_skb we could add a new helper.  While for the other
case we could either create a new helper or just add an extra
dev argument that may be NULL for those that don't care about
LL_ALLOCATED_SPACE.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
