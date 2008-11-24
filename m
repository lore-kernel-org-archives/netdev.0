From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Mon, 24 Nov 2008 15:47:20 -0800 (PST)
Message-ID: <20081124.154720.219944704.davem@davemloft.net>
References: <20081124125150.GB16755@ff.dom.local>
	<492AA96C.6000807@trash.net>
	<20081124134516.GD16755@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753810AbYKXXrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:47:20 -0500
In-Reply-To: <20081124134516.GD16755@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 24 Nov 2008 13:45:16 +0000

> On Mon, Nov 24, 2008 at 02:17:32PM +0100, Patrick McHardy wrote:
> > Jarek Poplawski wrote:
> >> On Mon, Nov 24, 2008 at 01:38:48PM +0100, Patrick McHardy wrote:
> >> ...
> >>> TBF with an inner DRR is fine. The other way around is broken
> >>> in the sense that the behaviour is undefined.
> >>
> >> IMHO, this other way (e.g. a class with TBF per user), should work too.
> >
> > The behaviour undefined, so what does "work too" mean in this context?
> >
> > The main question is: what should be done with the class when it
> > throttles?
> >
> > You suggest moving it to the end of the active list. Should its deficit
> > be recharged in that case? Possible no because it didn't send packets -
> > but then again it might have handed out *some* packets (less than the
> > deficit) before it started throttling. Both ways would introduce
> > unfairness.
> >
> > What could be done without harming the algorithm is to treat throttled
> > classes as inactive until they become unthrottled again, meaning they
> > would be added to the end of the active list with a full deficit. But
> > we have no indication for specific classes, unthrottling simply triggers
> > another dequeue of the root, so the implementation would get quite
> > complicated, leaving alone the fact that each TBF would potentially
> > start its own watchdog, causing excessive wakeups.
> >
> > And I don't see much use for this, what is the advantage over using
> > HTB or HFSC?
> 
> Probably no advantage, if you now these things... or for testing. But
> I like to give users a choice, at least if it's not obviously wrong.
> Of course, if you think this harms the proper configs with too much
> overhead, then there is no question we should forget about this.

Things seem to have settled, thus I have applied Patrick's version
of the fix.

But I encourage people to add the necessary framework such that
such unwanted configurations can be in fact detected at ->init()
time and thus properly warned about.

Silent packet dropping really upsets users.
