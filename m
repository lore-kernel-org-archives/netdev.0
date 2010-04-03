From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sat, 3 Apr 2010 11:38:57 +0800
Message-ID: <20100403033857.GA2205@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34011 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754216Ab0DCDjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 23:39:01 -0400
Content-Disposition: inline
In-Reply-To: <1270126340-30181-2-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 01, 2010 at 03:52:17PM +0300, Timo Teras wrote:
> This allows to validate the cached object before returning it.
> It also allows to destruct object properly, if the last reference
> was held in flow cache. This is also a prepartion for caching
> bundles in the flow cache.
> 
> In return for virtualizing the methods, we save on:
> - not having to regenerate the whole flow cache on policy removal:
>   each flow matching a killed policy gets refreshed as the getter
>   function notices it smartly.
> - we do not have to call flow_cache_flush from policy gc, since the
>   flow cache now properly deletes the object if it had any references
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

With repsect to removing the cache flush upon policy removal,
what takes care of the timely purging of the corresponding cache
entries if no new traffic comes through?

The concern is that if they're not purged in the absence of new
traffic, then we may hold references on all sorts of objects,
leading to consequences such as the inability to unregister net
devices.
  
>  struct flow_cache_entry {
> -	struct flow_cache_entry	*next;
> -	u16			family;
> -	u8			dir;
> -	u32			genid;
> -	struct flowi		key;
> -	void			*object;
> -	atomic_t		*object_ref;
> +	struct flow_cache_entry *	next;

Please follow the existing coding style.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
