From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 16:50:52 +0800
Message-ID: <20081202085052.GA30301@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net> <20081201111501.GA20650@gondor.apana.org.au> <20081202075804.GD13998@secunet.com> <20081202081948.GA30063@gondor.apana.org.au> <20081202084419.GF13998@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34420 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751584AbYLBIu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 03:50:59 -0500
Content-Disposition: inline
In-Reply-To: <20081202084419.GF13998@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 09:44:19AM +0100, Steffen Klassert wrote:
>
> > Maybe I'm missing somthing, but all you're doing is paralleising
> > based on xfrm_state objects.  You can already do that trivially
> > in the crypto layer with no network-specific knowledge at all
> > because each xfrm_state allocates its own tfm objects.
> 
> No, it's not just parallelizing based on xfrm_states. We are running
> in parallel even within the same state. That's why I'm getting a 
> bandwith up to 900Mbit/s when sending one tcp stream. Parallelizing
> based on state would not help that much if you are sending just one
> stream.

I understand.  What I meant was maintaining ordering within an
xfrm_state.  Since each xfrm_state has its own tfms, all you have
to do is round-robin within each crypto tfm while maintaining
ordering to achieve the same result.

> > This achieves exactly the same thing as your current patch-set
> > plus:
> > 
> > 1) The uesr no longer has to make a system-wide choice of whether
> > to enable this, instead the control is per-SA through the usual
> > algorithm selection mechanism which means that this no longer
> > conflicts with async crypto;
> > 
> > 2) There is no change to the xfrm code;
> > 
> > 3) The same mechanism can benefit other crypto users such as
> > disk encryption.
> 
> The padata stuff is generic, so it can be used even for disk
> encryption or for anything else that should run in parallel but
> needs a certain order at a given point.

What about the first issue?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
