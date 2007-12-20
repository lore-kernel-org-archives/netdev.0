From: David Miller <davem@davemloft.net>
Subject: Re: TSO trimming question
Date: Thu, 20 Dec 2007 15:55:18 -0800 (PST)
Message-ID: <20071220.155518.42408378.davem@davemloft.net>
References: <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
	<20071220.040037.48002365.davem@davemloft.net>
	<20071220140012.GA22495@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48519
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753499AbXLTXzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 18:55:19 -0500
In-Reply-To: <20071220140012.GA22495@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 20 Dec 2007 22:00:12 +0800

> On Thu, Dec 20, 2007 at 04:00:37AM -0800, David Miller wrote:
> >
> > In the most ideal sense, tcp_window_allows() should probably
> > be changed to only return MSS multiples.
> > 
> > Unfortunately this would add an expensive modulo operation,
> > however I think it would elimiate this problem case.
> 
> Well you only have to divide in the unlikely case of us being
> limited by the receiver window.  In that case speed is probably
> not of the essence anyway.

Agreed, to some extent.

I say "to some extent" because it might be realistic, with
lots (millions) of sockets to hit this case a lot.

There are so many things that are a "don't care" performance
wise until you have a lot of stinky connections over crappy
links.
