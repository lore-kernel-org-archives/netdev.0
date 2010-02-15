From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Mon, 15 Feb 2010 08:18:49 +0800
Message-ID: <20100215001849.GB15437@gondor.apana.org.au>
References: <20100214144415.GA8115@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39593 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755247Ab0BOAS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 19:18:57 -0500
Content-Disposition: inline
In-Reply-To: <20100214144415.GA8115@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 14, 2010 at 04:44:15PM +0200, Alexey Dobriyan wrote:
> Consider using ipcomp with tunnel mode:
> 
> 	pfkey_add -> xfrm_state_init -> x->type->init_state() == ipcomp4_init_state
> 
> 1. If ipcomp_tunnel_attach() fails, xfrm_state private data (x->data) are freed
>    first time (synchronously), but stale pointer is left.
> 2. xfrm_state_init() failed, all right, we're going to do error unwind
>    but this time asynchronously and we're going to double free x->data
>    asynchronously.

Sorry, I don't see the async path, where is it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
