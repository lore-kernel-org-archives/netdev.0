From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Mon, 1 Dec 2008 16:49:02 +0800
Message-ID: <20081201084902.GA19904@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57909 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750833AbYLAItG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 03:49:06 -0500
Content-Disposition: inline
In-Reply-To: <20081201071614.GP476@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 08:16:14AM +0100, Steffen Klassert wrote:
> This is a first throw to try to parallelize the expensive part of xfrm by
> using a generic parallelization/serialization method. This method uses the
> remote softirq invocation infrastructure for parallelization and serialization.
> With this method data objects can be processed in parallel, starting 
> at some given point. After doing some expensive operations in parallel, 
> it is possible to serialize again. The parallelized data objects return after
> serialization in the order as they were before the parallelization. 
> In the case of xfrm, this makes it possible to run the expensive part in
> parallel without getting packet reordering.

I still think that you're much better off doing this in the
crypto layer.  As it stands the only reason why this is attractive
is because crypto is slow.

Pretty soon processors will start providing crypto support natively
so this will no longer be the case.  I'd rather see this stuff
contained in a small area instead of having it spread all over the
place as this may become obsolete any day now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
