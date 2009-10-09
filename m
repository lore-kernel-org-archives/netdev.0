From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Fri, 9 Oct 2009 09:40:39 +0000
Message-ID: <20091009094039.GA8067@ff.dom.local>
References: <4ACD9255.4020008@gmail.com> <20091008090344.GA7409@ff.dom.local> <20091009085107.GA7711@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f227.google.com ([209.85.220.227]:60092 "EHLO
	mail-fx0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760561AbZJIJlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 05:41:21 -0400
Received: by fxm27 with SMTP id 27so6237429fxm.17
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2009 02:40:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091009085107.GA7711@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2009 at 08:51:07AM +0000, Jarek Poplawski wrote:
> On Thu, Oct 08, 2009 at 09:03:44AM +0000, Jarek Poplawski wrote:
> > On Thu, Oct 08, 2009 at 09:18:45AM +0200, Eric Dumazet wrote:
> ...
> > > Just wondering if it could hurt some people.
> > > 
> > > Anyway, should we change bnx2/tg3 drivers so that single queue devices
> > > have same default qdisc/class than before ?
> > > 
> > > eg :
> > > 
> > > diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> > > index 08cddb6..7cac205 100644
> > > --- a/drivers/net/bnx2.c
> > > +++ b/drivers/net/bnx2.c
> > > @@ -6152,6 +6152,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
> > >  
> > >  	bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
> > >  	bp->dev->real_num_tx_queues = bp->num_tx_rings;
> > > +	bp->dev->num_tx_queues = bp->dev->real_num_tx_queues;
> > >  
> > >  	bp->num_rx_rings = bp->irq_nvecs;
> > >  }
> > 
> > It doesn't look consistent to me wrt. the comment in netdevice.h on
> > num_tx_queues. But it seems we should rather use more often
> > real_num_tx_queue in schedulers code like dumps and maybe more
> > (like e.g. sch_multiq does).
> 
> So, according to my current understanding, we should probably let
> drivers to reset the tx_queues allocation with a new num_tx_queues
> in a place like this (ndo_open).

Actually, it should be only for the first ndo_open.

Jarek P.
