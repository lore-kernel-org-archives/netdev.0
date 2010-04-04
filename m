From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 19:31:42 +0800
Message-ID: <20100404113142.GA11124@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100404104230.GA10368@gondor.apana.org.au> <4BB86EE8.5090203@iki.fi> <20100404110014.GA10864@gondor.apana.org.au> <4BB872CF.2030202@iki.fi> <20100404112636.GA11061@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:57209 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753478Ab0DDLbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 07:31:45 -0400
Content-Disposition: inline
In-Reply-To: <20100404112636.GA11061@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 04, 2010 at 07:26:36PM +0800, Herbert Xu wrote:
> 
> Fine, move key into flow_cache_entry but the rest should still
> work, no?
> 
> struct flow_cache_object {
> 	u16			family;
> 	u8			dir;
> 	u32			genid;
> 	struct flow_cache_ops  *ops;
> };
> 
> struct flow_cache_entry {
> 	struct flow_cache_entry	*next;
> 	struct flowi key;
> 	struct flow_cache_object *obj;
> };
> 
> struct xfrm_policy {
> 	struct flow_cache_object flo;
> 	...
> };

OK this doesn't work either as we still have NULL objects for
now.  But I still think even if the ops pointer is the only
member in flow_cache_object, it looks better than returning the
nested ops pointer directly from flow_cache_lookup.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
