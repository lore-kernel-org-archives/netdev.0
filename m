From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 10:12:17 +0100
Message-ID: <20090204091217.GA21385@1wt.eu>
References: <20090204081201.GB10445@ioremap.net> <20090204085432.GA21638@1wt.eu> <20090204085907.GA19388@gondor.apana.org.au> <20090204.010146.18100191.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, zbr@ioremap.net, jarkao2@gmail.com,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2017 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075AbZBDJMr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2009 04:12:47 -0500
Content-Disposition: inline
In-Reply-To: <20090204.010146.18100191.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 04, 2009 at 01:01:46AM -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 4 Feb 2009 19:59:07 +1100
> 
> > On Wed, Feb 04, 2009 at 09:54:32AM +0100, Willy Tarreau wrote:
> > >
> > > My server is running 2.4 :-), but I observed the same issues with older
> > > 2.6 as well. I can certainly imagine that things have changed a lot since,
> > > but the initial point remains : jumbo frames are expensive to deal with,
> > > and with recent NICs and drivers, we might get close performance for
> > > little additional cost. After all, initial justification for jumbo frames
> > > was the devastating interrupt rate and all NICs coalesce interrupts now.
> > 
> > This is total crap! Jumbo frames are way better than any of the
> > hacks (such as GSO) that people have come up with to get around it.
> > The only reason we are not using it as much is because of this
> > nasty thing called the Internet.
> 
> Completely agreed.
> 
> If Jumbo frames are slower, it is NOT some fundamental issue.  It is
> rather due to some misdesign of the hardware or it's driver.

Agreed we can't use them *because* of the internet, but this
limitation has forced hardware designers to find valid alternatives.
For instance, having the ability to reach 10 Gbps with 1500 bytes
frames on myri10ge with a low CPU usage is a real achievement. This
is "only" 800 kpps after all.

And the arbitrary choice of 9k for jumbo frames was total crap too.
It's clear that no hardware designer was involved in the process.
They have to stuff 16kB of RAM on a NIC to use only 9. And we need
to allocate 3 pages for slightly more than 2. 7.5 kB would have been
better in this regard.

I still find it nice to lower CPU usage with frames larger than 1500,
but given the fact that this is rarely used (even in datacenters), I
think our efforts should concentrate on where the real users are, ie
<1500.

Regards,
Willy

