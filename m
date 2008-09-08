From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [rfc 1/3] ipvs: handle PARTIAL_CHECKSUM
Date: Mon, 8 Sep 2008 17:24:40 +1000
Message-ID: <20080908072439.GA27257@gondor.apana.org.au>
References: <20080908020420.313463898@vergenet.net> <20080908021535.063462678@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	Siim =?iso-8859-1?B?UMO1ZGVy?= <siim@p6drad-teel.net>,
	Julian Anastasov <ja@ssi.bg>,
	Malcolm Turnbull <malcolm@loadbalancer.org>,
	Julius Volz <juliusv@google.com>,
	Vince Busam <vbusam@google.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42595 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752031AbYIHHYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 03:24:46 -0400
Content-Disposition: inline
In-Reply-To: <20080908021535.063462678@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2008 at 12:04:21PM +1000, Simon Horman wrote:
>
>  	/* Adjust TCP checksums */
> -	if (!cp->app && (tcph->check != 0)) {
> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
> +					htonl(oldlen),
> +					htonl(skb->len - tcphoff));

I don't know what cp->app is but should we be updating the checksum
when it's set? The previous code seems to want to compute a full
checksum instead.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
