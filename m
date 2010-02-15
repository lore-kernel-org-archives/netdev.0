From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipcomp: double free at ipcomp_destroy()
Date: Mon, 15 Feb 2010 16:08:46 +0800
Message-ID: <20100215080846.GA18446@gondor.apana.org.au>
References: <20100214144415.GA8115@x200> <20100215001849.GB15437@gondor.apana.org.au> <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47517 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755356Ab0BOIIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 03:08:53 -0500
Content-Disposition: inline
In-Reply-To: <b6fcc0a1002142332r1542e04ex250fa238e4a3231a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2010 at 09:32:33AM +0200, Alexey Dobriyan wrote:
>
> pfkey_add
> pfkey_msg2xfrm_state
> xfrm_init_state         [fails]
> xfrm_state_put
> __xfrm_state_destroy    [puts xfrm_state into GC list, schedule work]
> xfrm_state_gc_task
> xfrm_state_gc_destroy
> x->type->destructor

Doh, I was looking at the buggy xfrm_state_clone path (which
incidently needs to be fixed to use xfrm_state_put).

How about just getting rid of the ipcomp_destroy call in ipcomp's
init_state functions? Calling the destructor twice is a bit iffy
even if we can make it work by setting various things to NULL and
testing for it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
