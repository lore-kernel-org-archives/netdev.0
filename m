From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 10:06:57 +0800
Message-ID: <20100404020657.GA8520@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au> <4BB7A2B8.4040405@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58284 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752242Ab0DDCHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 22:07:00 -0400
Content-Disposition: inline
In-Reply-To: <4BB7A2B8.4040405@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 03, 2010 at 11:19:04PM +0300, Timo Ter=E4s wrote:
>
> If someone is then removing a net driver, we still execute
> flush on the 'device down' hook, and all stale bundles
> get flushed.

Not if the bundle belongs to a policy recently deleted.

> But yes, this means that xfrm_policy struct can now be held
> allocated up to ten extra minutes. But it's only memory that
> it's holding, not any extra refs. And it's still reclaimable
> by the GC.

You also hold down the bundle xdst's along with it, which can
hold netdev references preventing modules from being unloaded.

> If this feels troublesome, we could add asynchronous flush
> request that would be called on policy removal. Or even stick
> to the synchronous one.

How about change xfrm_flush_bundles to flush bundles from the
cache instead of xfrm_policy?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
