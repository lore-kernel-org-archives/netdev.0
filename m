From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sun, 28 Mar 2010 21:11:12 +0800
Message-ID: <20100328131112.GA15984@gondor.apana.org.au>
References: <20100327.203120.98894145.davem@davemloft.net> <20100328082250.GA14053@gondor.apana.org.au> <20100328.055312.58421329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:35130 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754543Ab0C1NLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 09:11:16 -0400
Content-Disposition: inline
In-Reply-To: <20100328.055312.58421329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 28, 2010 at 05:53:12AM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 28 Mar 2010 16:22:50 +0800
>
> > My main question is how do we deal with source-address policy
> > routing in a host cache?
> 
> We don't, the same like how we don't handle fully specified
> IPSEC policies deciding upon the route.

I thought we did handle source-address policy routing for PMTU
messages at least.  I just checked ip_rt_frag_needed and it does

		if (rth->fl.fl4_dst != daddr ||
		    rth->fl.fl4_src != skeys[i] ||
		    rth->rt_dst != daddr ||
		    rth->rt_src != iph->saddr ||
		    rth->fl.oif != ikeys[k] ||
		    rth->fl.iif != 0 ||
		    dst_metric_locked(&rth->u.dst, RTAX_MTU) ||
		    !net_eq(dev_net(rth->u.dst.dev), net) ||
		    rt_is_expired(rth))
			continue;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
