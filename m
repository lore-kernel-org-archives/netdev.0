From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] net: introduce support for lazy initialization of secret keys
Date: Thu, 26 Sep 2013 05:03:06 +0200
Message-ID: <20130926030306.GA30364@order.stressinduktion.org>
References: <20130925213403.GF4904@order.stressinduktion.org> <1380148946.3165.166.camel@edumazet-glaptop> <20130926025024.GC30920@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	fw@strlen.de, edumazet@google.com, davem@davemloft.net,
	ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51761 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283Ab3IZDDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 23:03:07 -0400
Content-Disposition: inline
In-Reply-To: <20130926025024.GC30920@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 26, 2013 at 04:50:24AM +0200, Hannes Frederic Sowa wrote:
>  static inline unsigned int inet6_ehashfn(struct net *net,
>  				const struct in6_addr *laddr, const u16 lport,
>  				const struct in6_addr *faddr, const __be16 fport)
>  {
> -	u32 ports = (((u32)lport) << 16) | (__force u32)fport;
> +	u32 ports;
> +
> +	net_get_random_once(&inet6_ehash_secret, sizeof(inet6_ehash_secret));

I was too quick with sending, this is broken. I cannot call this in a
static inline. Sorry for the noise.
