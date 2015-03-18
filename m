From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 2/6] rhashtable: Introduce max_size/min_size
Date: Wed, 18 Mar 2015 10:55:28 +0000
Message-ID: <20150318105528.GO17829@casper.infradead.org>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YY9qm-0005mA-Jy@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53939 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755424AbbCRKz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 06:55:29 -0400
Content-Disposition: inline
In-Reply-To: <E1YY9qm-0005mA-Jy@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/18/15 at 08:01pm, Herbert Xu wrote:
> @@ -935,6 +938,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
>  
>  	params->min_shift = max_t(size_t, params->min_shift,
>  				  ilog2(HASH_MIN_SIZE));
> +	params->min_size = max(params->min_size, HASH_MIN_SIZE);
>  
>  	if (params->nelem_hint)
>  		size = rounded_hashtable_size(params);

The only change I would add on top is to ensure that min_size
and max_size are a power of two as otherwise the table size
used will end up being greater or smaller than specified.
I can do that as a follow-up though.
