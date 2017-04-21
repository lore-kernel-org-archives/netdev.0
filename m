From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 11/16] esp: Use a synchronous crypto algorithm on
 offloading.
Date: Fri, 21 Apr 2017 10:33:17 +0200
Message-ID: <20170421083317.GN2649@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
 <1492678515-14347-12-git-send-email-steffen.klassert@secunet.com>
 <20170420090617.GA8325@gondor.apana.org.au>
 <20170420091752.GH2649@secunet.com>
 <20170420095235.GA8580@gondor.apana.org.au>
 <20170420105029.GJ2649@secunet.com>
 <20170421052934.GA12702@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:53112 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1036636AbdDUIkz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Apr 2017 04:40:55 -0400
Content-Disposition: inline
In-Reply-To: <20170421052934.GA12702@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 01:29:34PM +0800, Herbert Xu wrote:
> On Thu, Apr 20, 2017 at 12:50:29PM +0200, Steffen Klassert wrote:
> > On Thu, Apr 20, 2017 at 05:52:35PM +0800, Herbert Xu wrote:
> > > On Thu, Apr 20, 2017 at 11:17:52AM +0200, Steffen Klassert wrote:
> > > >
> > > > I tried to use async algorithms but it lead to serveral problems.
> > > > The GSO layer can't handle async returns, we'd need callbacks
> > > > for all the GSO handlers. Also we need something where we can
> > > > requeue packets if the driver is busy etc.
> > > 
> > > Why would we need to requeue? As it is if you get an EBUSY on
> > > an IPsec packet it's simply dropped.
> > 
> > Yes we could do this, but the GSO problem remain.
> > 
> > We discussed this last year at netdevconf but could not come
> > up with an acceptable solutuion.
> 
> Why is it a problem exactly?

My solution for this added some extra code to the generic networking
path, this was seen as too intrusive for this very special usecase.

I still think we can get this to work, but it needs some extra care.

> 
> > For now this is just a fallback to make hardware offloading
> > possible at all, so this is slowpath anyway. Allowing async
> > algorithms can (and should) be done in a second step once we
> > found a not too intrusive solution.
> 
> OK, as long as nobody gets silently switched from async to sync
> then it's fine with me.

The user has to explicitely ask for a offloaded state, so
we don't hide anything here. In this case the user wants
to use the crypto engine of the NIC, we just need a software
fallback to catch some corner cases where the NIC can't
do the crypto operation.
