From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: sch_netem: Limit packet re-ordering
	functionality to tfifo qdisc.
Date: Wed, 22 Oct 2008 05:37:46 +0000
Message-ID: <20081022053746.GA4178@ff.dom.local>
References: <20081017130333.GA8297@ff.dom.local> <48F89D33.9090809@trash.net> <20081017201210.GA2527@ami.dom.local> <20081021.163605.57275028.davem@davemloft.net> <20081021165129.422dd83f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:49345 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbYJVFhx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 01:37:53 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1257185ugf.37
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2008 22:37:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081021165129.422dd83f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 21, 2008 at 04:51:29PM -0700, Stephen Hemminger wrote:
> On Tue, 21 Oct 2008 16:36:05 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Fri, 17 Oct 2008 22:12:10 +0200
> > 
> > > pkt_sched: sch_netem: Limit packet re-ordering functionality to tfifo qdisc.
> > > 
> > > After introducing qdisc->ops->peek() method the only remaining user of
> > > qdisc->ops->requeue() is netem_enqueue() using this for packet
> > > re-ordering. According to Patrick McHardy: "a lot of the functionality
> > > of netem requires the inner tfifo anyways and rate-limiting is usually
> > > done on top of netem. So I would suggest so either hard-wire the tfifo
> > > qdisc or at least make the assumption that inner qdiscs are work-
> > > conserving." This patch tries the former.
> > > 
> > > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > 
> > This is an interesting patch.
> > 
> > But the thing that strikes me is this: Why don't we just let sch_netem do
> > the reordering inside of itself entirely and just get rid of all of this
> > ->requeue() business?

We just let for this here with sch_netem's default tfifo qdisc.

> > 
> > sch_netem is just a black box, like any other packet scheduler node in
> > the tree, and so it can internally do the reordering with a self managed
> > packet list or similar.  All of this can be hidden inside of it's ->dequeue()
> > with some pkt_sch watchdog timer that fires to prevent stale packets sitting
> > in the reorder queue forever.
> > 
> > Anyways, just and idea and RFC, just like this patch ;-)
> 
> The problem is that jamal talked me into having netem as a classful qdisc,
> instead of doing its own rate control.  People like to do use TBF as inner qdisc,
> and do reordering.

If it's only this kind of usage we could export tfifo and let use this
as a TBF's (etc.) leaf. Of course, this would require changes in those
people scripts.

Jarek P.
