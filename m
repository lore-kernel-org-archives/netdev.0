From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 11/16] esp: Use a synchronous crypto algorithm on
 offloading.
Date: Fri, 21 Apr 2017 13:29:34 +0800
Message-ID: <20170421052934.GA12702@gondor.apana.org.au>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
 <1492678515-14347-12-git-send-email-steffen.klassert@secunet.com>
 <20170420090617.GA8325@gondor.apana.org.au>
 <20170420091752.GH2649@secunet.com>
 <20170420095235.GA8580@gondor.apana.org.au>
 <20170420105029.GJ2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [198.176.57.175] ([198.176.57.175]:42652 "EHLO
        deadmen.hmeau.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1035396AbdDUFag (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 01:30:36 -0400
Content-Disposition: inline
In-Reply-To: <20170420105029.GJ2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 12:50:29PM +0200, Steffen Klassert wrote:
> On Thu, Apr 20, 2017 at 05:52:35PM +0800, Herbert Xu wrote:
> > On Thu, Apr 20, 2017 at 11:17:52AM +0200, Steffen Klassert wrote:
> > >
> > > I tried to use async algorithms but it lead to serveral problems.
> > > The GSO layer can't handle async returns, we'd need callbacks
> > > for all the GSO handlers. Also we need something where we can
> > > requeue packets if the driver is busy etc.
> > 
> > Why would we need to requeue? As it is if you get an EBUSY on
> > an IPsec packet it's simply dropped.
> 
> Yes we could do this, but the GSO problem remain.
> 
> We discussed this last year at netdevconf but could not come
> up with an acceptable solutuion.

Why is it a problem exactly?

> For now this is just a fallback to make hardware offloading
> possible at all, so this is slowpath anyway. Allowing async
> algorithms can (and should) be done in a second step once we
> found a not too intrusive solution.

OK, as long as nobody gets silently switched from async to sync
then it's fine with me.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
