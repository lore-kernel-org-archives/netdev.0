From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: deadlocks if use htb
Date: Mon, 19 Jan 2009 07:57:33 +0000
Message-ID: <20090119075733.GA4788@ff.dom.local>
References: <1231937404.14825.4.camel@laptop> <Pine.LNX.4.64.0901141748300.17915@nacho.alt.net> <20090115065322.GA4190@ff.dom.local> <20090118.214604.221247372.davem@davemloft.net> <20090119065715.GA4197@ff.dom.local> <49742EE5.9090502@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, a.p.zijlstra@chello.nl,
	denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tglx@linutronix.de
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:17529 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbZASH5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 02:57:41 -0500
Content-Disposition: inline
In-Reply-To: <49742EE5.9090502@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2009 at 10:42:29AM +0300, Badalian Vyacheslav wrote:
> Tested 2 days (weekend is stress days for this bug, because its have
> many traffic) at 3 servers. Fly normal. For completed test need up to 7
> days, but i think (imho) this patch not break any functional and may
> safely added to stable. 100% help for me patch # 2+3.

Thank you very much, Slavon! (2+3 are of course better tested, but
I hope this #4 is more appropriate for -stable.)

Jarek P.

> > On Sun, Jan 18, 2009 at 09:46:04PM -0800, David Miller wrote:
> >   
> >> From: Jarek Poplawski <jarkao2@gmail.com>
> >> Date: Thu, 15 Jan 2009 06:53:22 +0000
> >>
> >>     
> >>> (resend testing patch #4 - for 2.6.27 or 2.6.28)
> >>>       
> >> Jarek, if you deem that this is in fact what we should
> >> submit for -stable please give me a submission with
> >> a suitable commit message and signoffs, and I will queue
> >> it up for -stable.
> >>     
> >
> > It looks like this should be needed, but I think it's better to wait
> > 2 or 3 days for "Tested-by" from Denys and/or maybe Vyacheslav yet.
> > (I hoped they would rather test some hrtimers patch, but it looks like
> > Peter was busy.)
> >
> > Thanks,
> > Jarek P.
> > -----------------> (needed only for -stables: 2.6.28 and older)
> >
> > pkt_sched: sch_htb: Fix deadlock in hrtimers triggered by HTB
> >
> > Most probably there is a (still unproven) race in hrtimers (before
> > 2.6.29 kernels), which causes a corruption of hrtimers rbtree. This
> > patch doesn't fix it, but should let HTB avoid triggering the bug.
> >
> > Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
> > Reported-by: Badalian Vyacheslav <slavon@bigtelecom.ru>
> > Reported-by: Chris Caputo <ccaputo@alt.net>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > ---
> >
> > diff -Nurp a2.6.27.7/net/sched/sch_htb.c b2.6.27.7/net/sched/sch_htb.c
> > --- a2.6.27.7/net/sched/sch_htb.c	2008-12-11 08:16:16.000000000 +0000
> > +++ b2.6.27.7/net/sched/sch_htb.c	2008-12-15 10:44:32.000000000 +0000
> > @@ -924,6 +924,7 @@ static struct sk_buff *htb_dequeue(struc
> >  		}
> >  	}
> >  	sch->qstats.overlimits++;
> > +	qdisc_watchdog_cancel(&q->watchdog);
> >  	qdisc_watchdog_schedule(&q->watchdog, next_event);
> >  fin:
> >  	return skb;
> >
> >   
> 
