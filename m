From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Mon, 01 Dec 2008 02:29:29 -0800 (PST)
Message-ID: <20081201.022929.253639406.davem@davemloft.net>
References: <20081201071614.GP476@secunet.com>
	<20081201084902.GA19904@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57189
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750989AbYLAK33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 05:29:29 -0500
In-Reply-To: <20081201084902.GA19904@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 1 Dec 2008 16:49:02 +0800

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

Herbert, I'm not completely convinced of this line of thinking :-)

Will crypto be faster than a routing cache lookup?  Because flow
seperation helps routing performance, significantly.

The problem is that we can't seperate within a flow, that's why we
need something like Steffen's work.

And the reconstitution of the seperated crypto operations into the
original properly ordered flow can be done most cleanly (IMHO) in the
networking layer as far as I have seen so far.
