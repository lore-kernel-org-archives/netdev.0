From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: rhashtable - Cap total number of entries to 2^31
Date: Thu, 27 Apr 2017 18:13:05 +0800
Message-ID: <20170427101305.GA1701@gondor.apana.org.au>
References: <20170425112356.GB11322@breakpoint.cc>
 <20170425132837.GA25657@gondor.apana.org.au>
 <20170425141749.GD11322@breakpoint.cc>
 <20170425.104822.1395000926293799711.davem@davemloft.net>
 <20170427054451.GA529@gondor.apana.org.au>
 <20170427101134.GB448@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Thomas Graf <tgraf@suug.ch>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:50228 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755315AbdD0KO1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 06:14:27 -0400
Content-Disposition: inline
In-Reply-To: <20170427101134.GB448@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 12:11:34PM +0200, Florian Westphal wrote:
>
> > +	/* Cap total entries at 2^31 to avoid nelems overflow. */
> > +	ht->max_elems = 1u << 31;
> > +	if (ht->p.max_size < ht->max_elems / 2)
> > +		ht->max_elems = ht->p.max_size * 2;
> > +
> 
> Looks like instead of adding this max_elems you could instead have fixed this via
> 
> if (!ht->p.max_size)
> 	ht->p.max_size = INT_MAX / 2;
> 
> if (ht->p.max_size > INT_MAX / 2)
> 	return -EINVAL;

No that doesn't do the same thing.  Setting max_size caps the table
size and I don't want to do that at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
