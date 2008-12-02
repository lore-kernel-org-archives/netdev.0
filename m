From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 09:00:31 +0100
Message-ID: <20081202080031.GE13998@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:54417 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750977AbYLBH7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 02:59:42 -0500
Content-Disposition: inline
In-Reply-To: <20081201084902.GA19904@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 04:49:02PM +0800, Herbert Xu wrote:
> On Mon, Dec 01, 2008 at 08:16:14AM +0100, Steffen Klassert wrote:
> > This is a first throw to try to parallelize the expensive part of xfrm by
> > using a generic parallelization/serialization method. This method uses the
> > remote softirq invocation infrastructure for parallelization and serialization.
> > With this method data objects can be processed in parallel, starting 
> > at some given point. After doing some expensive operations in parallel, 
> > it is possible to serialize again. The parallelized data objects return after
> > serialization in the order as they were before the parallelization. 
> > In the case of xfrm, this makes it possible to run the expensive part in
> > parallel without getting packet reordering.
> 
> I still think that you're much better off doing this in the
> crypto layer.  As it stands the only reason why this is attractive
> is because crypto is slow.
> 
> Pretty soon processors will start providing crypto support natively
> so this will no longer be the case.  I'd rather see this stuff
> contained in a small area instead of having it spread all over the
> place as this may become obsolete any day now.
> 

Now, that most of the crypto changes of this patchset are obsolete by
shash, 'spreading all over the place' is probaply not a reason any more
not to keep it in the network layer.
