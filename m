From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Tue, 12 Nov 2013 02:58:06 +0800
Message-ID: <20131111185806.GC12462@gondor.apana.org.au>
References: <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
 <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108032359.GA14132@gondor.apana.org.au>
 <1383884517.9412.172.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108042425.GA14577@gondor.apana.org.au>
 <1383885600.9412.187.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108044335.GA14787@gondor.apana.org.au>
 <1383887329.9412.207.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131108052120.GA15001@gondor.apana.org.au>
 <1383889212.9412.219.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:41495 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753520Ab3KKS6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 13:58:12 -0500
Content-Disposition: inline
In-Reply-To: <1383889212.9412.219.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 09:40:12PM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 13:21 +0800, Herbert Xu wrote:
> 
> > My point is that even if you did that GRO with your frag_list
> > patch should still be a win because the stack prior to the qdisc
> > gets run once instead of two or three times.
> > 
> 
> OK, lets me repeat again.
> 
> 64KB packet receive/aggregation time is more than 540 us on 1Gbps link.

I presume you're still talking about the case where we're CPU-
bound on receive.  In that case I totally agree that you need to
impose a limit on the NAPI/GRO run so that we don't keep doing GRO
forever.

However, the limit should be based on time and not an arbitrary
number such as MAX_SKB_FRAGS.  IOW relying on not having a frag_list
to provide a bound to GRO is just wrong.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
