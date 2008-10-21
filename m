From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: sch_netem: Limit packet re-ordering
 functionality to tfifo qdisc.
Date: Tue, 21 Oct 2008 16:36:05 -0700 (PDT)
Message-ID: <20081021.163605.57275028.davem@davemloft.net>
References: <20081017130333.GA8297@ff.dom.local>
	<48F89D33.9090809@trash.net>
	<20081017201210.GA2527@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, shemminger@vyatta.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54930
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752141AbYJUXg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 19:36:28 -0400
In-Reply-To: <20081017201210.GA2527@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 17 Oct 2008 22:12:10 +0200

> pkt_sched: sch_netem: Limit packet re-ordering functionality to tfifo qdisc.
> 
> After introducing qdisc->ops->peek() method the only remaining user of
> qdisc->ops->requeue() is netem_enqueue() using this for packet
> re-ordering. According to Patrick McHardy: "a lot of the functionality
> of netem requires the inner tfifo anyways and rate-limiting is usually
> done on top of netem. So I would suggest so either hard-wire the tfifo
> qdisc or at least make the assumption that inner qdiscs are work-
> conserving." This patch tries the former.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

This is an interesting patch.

But the thing that strikes me is this: Why don't we just let sch_netem do
the reordering inside of itself entirely and just get rid of all of this
->requeue() business?

sch_netem is just a black box, like any other packet scheduler node in
the tree, and so it can internally do the reordering with a self managed
packet list or similar.  All of this can be hidden inside of it's ->dequeue()
with some pkt_sch watchdog timer that fires to prevent stale packets sitting
in the reorder queue forever.

Anyways, just and idea and RFC, just like this patch ;-)
