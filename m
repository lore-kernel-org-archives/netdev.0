From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Mon, 21 Nov 2011 08:56:21 +0100
Message-ID: <20111121075621.GF20943@secunet.com>
References: <4E9E9366.1050702@cn.fujitsu.com>
 <20111019.153208.1743995025598236810.davem@davemloft.net>
 <20111108.141950.1576262997640523669.davem@davemloft.net>
 <20111108.143302.907625740390232791.davem@davemloft.net>
 <20111109120851.GA10138@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53576 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754360Ab1KUH4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Nov 2011 02:56:25 -0500
Content-Disposition: inline
In-Reply-To: <20111109120851.GA10138@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2011 at 01:08:51PM +0100, Steffen Klassert wrote:
> On Tue, Nov 08, 2011 at 02:33:02PM -0500, David Miller wrote:
> > From: David Miller <davem@davemloft.net>
> > Date: Tue, 08 Nov 2011 14:19:50 -0500 (EST)
> > 
> > > I suspect that your real problem has nothing to do with UDP or RAW,
> > > but rather the issue is that entries already in the routing cache
> > > with a NULL peer need to be refreshed with peer information created
> > > in another context.
> 
> Yes, that's the problem.
> 
> > 
> > So you want something like this patch:
> > 
> 
> Originally, I wanted to fix it with the patch below.
> 
> Given the fact that dst->obsolete is not null, this should
> do the same like your patch for output routes. During the
> tests with this patch I noticed a problem with that.
> Unfortunately I can't remember what it was...
> 
> I'll do some investigating, perhaps I can get it back to my mind.
> 
> I did some quick tests with this and with your patch and both
> seem to fix the problem at the first glance.
> 

I still don't see any problems with both of the patches.
So I assume that both patches would fix the issue. However, 
your patch is probaply less fragile as this does not depend
on a certain value of dst->obsolete.
