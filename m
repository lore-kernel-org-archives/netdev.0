From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Wed, 24 Sep 2008 08:28:10 +0000
Message-ID: <20080924082810.GB4838@ff.dom.local>
References: <20080920.223538.130375517.davem@davemloft.net> <20080920.225033.261544815.davem@davemloft.net> <20080921063821.GA8677@gondor.apana.org.au> <20080921.000301.198672963.davem@davemloft.net> <20080923062333.GA26595@gondor.apana.org.au> <20080924071521.GA4838@ff.dom.local> <20080924080427.GB7391@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net, alexander.h.duyck@intel.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:20215 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbYIXI2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 04:28:16 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2478153fkq.5
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 01:28:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080924080427.GB7391@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2008 at 04:04:27PM +0800, Herbert Xu wrote:
> On Wed, Sep 24, 2008 at 07:15:21AM +0000, Jarek Poplawski wrote:
> >
> > > Then each qdisc can decide which child to recursively dequeue
> > > based on that token (or ignore it for non-prio qdiscs such as
> > > HTB).
> > 
> > I don't think HTB could be considered as a non-prio qdisc.
> 
> It is non-prio in the sense that it has other criteria for deciding
> which child qdisc to enqueue into.
> 
> > As matter of fact I can't figure out this idea of a prio at the root
> > or leaf either. Could you explain in which point do you expect the
> > gain? If it's about the locks, what kind of synchronization would be
> > used to assure packets from lower prio queues (or qdiscs?)  aren't
> > sent to free tx queues, while higher prio wait on stopped ones?
> 
> It's very simple really.  For a non-leaf prio you determine which
> child qdisc to enqueue into using the priority.  For a leaf prio
> you determine which software queue to enqueue into based on the
> priority.

OK, it's too simple then. Could you make this more complex and
show me the gain.

> To put it another way, what I'm saying is that instead of duplicating
> the qdiscs as we do now for pfifo_fast, we should make the leaf
> qdiscs duplicate its software queues to match the hardware queues
> it's feeding into.

It looks like sch_multiq, but you probably mean something else...

Cheers,
Jarek P.
