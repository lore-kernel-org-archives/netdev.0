From: David Miller <davem@davemloft.net>
Subject: Re: GRO/GSO hiding PMTU?
Date: Thu, 10 Feb 2011 23:07:12 -0800 (PST)
Message-ID: <20110210.230712.183040908.davem@davemloft.net>
References: <20110210235022.GA25293@gondor.apana.org.au>
	<20110210.222216.104050992.davem@davemloft.net>
	<20110211063753.GA29940@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110211063753.GA29940@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 11 Feb 2011 17:37:53 +1100

> What I wanted to do if I ever get enough time to work on this is
> to record the transport header length in a gso_hlen field so we
> can fix this properly.
> 
> We currently have a useless gso_segs field that only has one or
> two users that don't even need it.  We could easily get rid of it
> and use that space for gso_hlen instead.
> 
> The gso_hlen field only needs to be filled in at the few spots
> that generate GSO packets, i.e.,
> 
> 1) TCP
> 2) Virt backends like tun.c
> 3) GRO

Yep, that's good idea.

And even if we needed to add one more u32 to skb_shared_info()
that's still sort-of "free" because of SLAB slack space.

I'll look into doing this.

Thanks!
