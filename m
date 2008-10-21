From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] pkt_sched: sch_netem: Limit packet re-ordering
 functionality to tfifo qdisc.
Date: Tue, 21 Oct 2008 16:51:29 -0700
Message-ID: <20081021165129.422dd83f@extreme>
References: <20081017130333.GA8297@ff.dom.local>
	<48F89D33.9090809@trash.net>
	<20081017201210.GA2527@ami.dom.local>
	<20081021.163605.57275028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, kaber@trash.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56898 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751957AbYJUXvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 19:51:32 -0400
In-Reply-To: <20081021.163605.57275028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Oct 2008 16:36:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 17 Oct 2008 22:12:10 +0200
> 
> > pkt_sched: sch_netem: Limit packet re-ordering functionality to tfifo qdisc.
> > 
> > After introducing qdisc->ops->peek() method the only remaining user of
> > qdisc->ops->requeue() is netem_enqueue() using this for packet
> > re-ordering. According to Patrick McHardy: "a lot of the functionality
> > of netem requires the inner tfifo anyways and rate-limiting is usually
> > done on top of netem. So I would suggest so either hard-wire the tfifo
> > qdisc or at least make the assumption that inner qdiscs are work-
> > conserving." This patch tries the former.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> This is an interesting patch.
> 
> But the thing that strikes me is this: Why don't we just let sch_netem do
> the reordering inside of itself entirely and just get rid of all of this
> ->requeue() business?
> 
> sch_netem is just a black box, like any other packet scheduler node in
> the tree, and so it can internally do the reordering with a self managed
> packet list or similar.  All of this can be hidden inside of it's ->dequeue()
> with some pkt_sch watchdog timer that fires to prevent stale packets sitting
> in the reorder queue forever.
> 
> Anyways, just and idea and RFC, just like this patch ;-)

The problem is that jamal talked me into having netem as a classful qdisc,
instead of doing its own rate control.  People like to do use TBF as inner qdisc,
and do reordering.
