From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP fast retransmit issues
Date: Wed, 26 Jul 2017 16:50:59 +0200
Message-ID: <20170726145059.GE1737@1wt.eu>
References: <200d9a12e9f2f5791d4c5ce2d47a1239@vsen.dk>
 <1501069756.12695.11.camel@edumazet-glaptop3.roam.corp.google.com>
 <a025f5b2ed6e1f287f68b6bb5137a988@vsen.dk>
 <1501075881.12695.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170726134242.GB1737@1wt.eu>
 <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Klavs Klavsen <kl@vsen.dk>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:34245 "EHLO 1wt.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751452AbdGZOvC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 10:51:02 -0400
Content-Disposition: inline
In-Reply-To: <1501079532.12695.17.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 07:32:12AM -0700, Eric Dumazet wrote:
> On Wed, 2017-07-26 at 15:42 +0200, Willy Tarreau wrote:
> > On Wed, Jul 26, 2017 at 06:31:21AM -0700, Eric Dumazet wrote:
> > > On Wed, 2017-07-26 at 14:18 +0200, Klavs Klavsen wrote:
> > > > the 192.168.32.44 is a Centos 7 box.
> > > 
> > > Could you grab a capture on this box, to see if the bogus packets are
> > > sent by it, or later mangled by a middle box ?
> > 
> > Given the huge difference between the window and the ranges of the
> > values in the SACK field, I'm pretty sure there's a firewall doing
> > some sequence numbers randomization in the middle, not aware of SACK
> > and not converting these ones. I've had to disable such broken
> > features more than once in field after similar observations! Probably
> > that the Mac doesn't advertise SACK support and doesn't experience the
> > problem.
> 
> We need to check RFC if such invalid SACK blocks should be ignored (DUP
> ACK would be processed and trigger fast retransmit anyway), or strongly
> validated (as I suspect we currently do), leading to a total freeze.

RFC2883 #4.3 talks about interaction with PAWS and only suggests that
since the sequence numbers can wrap the sender should be aware that a
reported segment can in fact relate to a value within the prior seq
number space before cycling, but that they don't expect any side effect.
So that more or less means to me "you should consider that some of these
segments might be old, meaningless and should be ignored". But as you
can see the recommendation lacks a bit of strength given that no issue
was expected in such a situation.

Willy
