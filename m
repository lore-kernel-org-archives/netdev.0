From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [v2 PATCH 2/6] rhashtable: Introduce max_size/min_size
Date: Wed, 18 Mar 2015 16:51:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB039DA@AcuExch.aculab.com>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YY9qm-0005mA-Jy@gondolin.me.apana.org.au>
 <20150318105528.GO17829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: 'Thomas Graf' <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:64980 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933166AbbCRQxJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 12:53:09 -0400
In-Reply-To: <20150318105528.GO17829@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf
> On 03/18/15 at 08:01pm, Herbert Xu wrote:
> > @@ -935,6 +938,7 @@ int rhashtable_init(struct rhashtable *ht, struct rhashtable_params *params)
> >
> >  	params->min_shift = max_t(size_t, params->min_shift,
> >  				  ilog2(HASH_MIN_SIZE));
> > +	params->min_size = max(params->min_size, HASH_MIN_SIZE);
> >
> >  	if (params->nelem_hint)
> >  		size = rounded_hashtable_size(params);
> 
> The only change I would add on top is to ensure that min_size
> and max_size are a power of two as otherwise the table size
> used will end up being greater or smaller than specified.

I'd just make sure that 'something sensible' happens if they aren't.

You don't really want to error the table creation if some sysctl (etc)
that control the sizes isn't a power of 2.

	David
