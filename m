From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 18:42:30 +0800
Message-ID: <20100404104230.GA10368@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56554 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753364Ab0DDKmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 06:42:33 -0400
Content-Disposition: inline
In-Reply-To: <1270126340-30181-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 03:52:17PM +0300, Timo Teras wrote:
>
> -extern void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family,
> -			       u8 dir, flow_resolve_t resolver);
> +struct flow_cache_entry_ops {
> +	struct flow_cache_entry_ops ** (*get)(struct flow_cache_entry_ops **);
> +	int (*check)(struct flow_cache_entry_ops **);
> +	void (*delete)(struct flow_cache_entry_ops **);
> +};
> +
> +typedef struct flow_cache_entry_ops **(*flow_resolve_t)(
> +		struct net *net, struct flowi *key, u16 family,
> +		u8 dir, struct flow_cache_entry_ops **old_ops, void *ctx);

OK this bit really bugs me.

When I first looked at it, my reaction was why on earth are we
returning an ops pointer? Only after some digging around do I see
the fact that this ops pointer is in fact embedded in xfrm_policy.

How about embedding flow_cache_entry in xfrm_policy instead? Returning
flow_cache_entry * would make a lot more sense than a nested pointer
to flow_cache_entry_ops.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
