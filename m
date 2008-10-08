From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 11:10:56 +1100
Message-ID: <20081008001054.GK12021@verge.net.au>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au> <20081007122052.GA4328@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>, Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45127 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbYJHAK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 20:10:57 -0400
Content-Disposition: inline
In-Reply-To: <20081007122052.GA4328@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 12:20:52PM +0000, Jarek Poplawski wrote:
> On Tue, Oct 07, 2008 at 03:51:47PM +1100, Simon Horman wrote:
> > On Tue, Oct 07, 2008 at 12:15:52PM +1100, Simon Horman wrote:
> > > Hi Dave, Hi Jarek,
> > > 
> > > I know that you guys were/are playing around a lot in here, but
> > > unfortunately I think that "pkt_sched: Always use q->requeue in
> > > dev_requeue_skb()" (f0876520b0b721bedafd9cec3b1b0624ae566eee) has
> > > introduced a performance regression for HTB.
> 
> Since this looks to me as possibly theoretical problem I added
> Martin and Patrick to Cc.
> 
> > > 
> > > My tc rules are below, but in a nutshell I have 3 leaf classes.
> > > One with a rate of 500Mbit/s and the other two with 100Mbit/s.
> > > The ceiling for all classes is 1Gb/s and that is also both
> > > the rate and ceiling for the parent class.
> > > 
> > >                           [ rate=1Gbit/s ]
> > >                           [ ceil=1Gbit/s ]
> > >                                  |
> > >             +--------------------+--------------------+
> > >             |                    |                    |
> > >      [ rate=500Mbit/s ]   [ rate=100Mbit/s ]   [ rate=100Mbit/s ]
> > >      [ ceil=  1Gbit/s ]   [ ceil=100Mbit/s ]   [ ceil=  1Gbit/s ]
> 
> ?!       [ ceil=  1Gbit/s ]   [ ceil=1Gbit/s ]     [ ceil=  1Gbit/s ]

Sorry, you are correct. ceil=1Gbit/s for all leaf-nodes is correct.
ceil=100Mbit/s was a cut and paste error.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

