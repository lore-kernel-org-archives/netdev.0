From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH][NET_SCHED] sch_prio: class statistics printing enabled
Date: Wed, 31 Jan 2007 15:31:06 +0100
Message-ID: <20070131143106.GA3521@ff.dom.local>
References: <20070131075348.GA1857@ff.dom.local> <45C09E0B.6020107@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:45166 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933297AbXAaO20 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 09:28:26 -0500
Content-Disposition: inline
In-Reply-To: <45C09E0B.6020107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 02:47:55PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > This patch adds a dump_stats callback to enable
> > printing of basic statistics of prio classes.
> 
> > diff -Nurp linux-2.6.20-rc6-/net/sched/sch_prio.c linux-2.6.20-rc6/net/sched/sch_prio.c
> > --- linux-2.6.20-rc6-/net/sched/sch_prio.c	2007-01-08 20:23:58.000000000 +0100
> > +++ linux-2.6.20-rc6/net/sched/sch_prio.c	2007-01-30 20:26:31.000000000 +0100
> > @@ -372,6 +372,23 @@ static int prio_dump_class(struct Qdisc 
> >  	return 0;
> >  }
> >  
> > +static int prio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
> > +							struct gnet_dump *d)
> 
> Please align with struct Qdisc.

I'm not sure it's fully compliant to the CodingStyle
text (e.g. spaces as indentation) but I'm a polite guy.

> 
> > +{
> > +	struct prio_sched_data *q = qdisc_priv(sch);
> > +	struct Qdisc *cl_q;
> > +
> > +	if (cl - 1 > q->bands)
> > +		return -ENOENT;
> 
> This would indicate a bug in prio_walk or prio_get. errno-codes have no
> meaning for dump_stats callbacks, either rely on the correctness of
> walk/get (as other qdiscs do) or call BUG.

Sure! To much cut & paste.
 
> > +
> > +	cl_q = q->queues[cl - 1];
> > +	if (gnet_stats_copy_basic(d, &cl_q->bstats) < 0 ||
> > +	    gnet_stats_copy_queue(d, &cl_q->qstats) < 0)
> > +		return -1;
> > +
> > +	return 0;
> > +}
> 
> ACK for the rest.
 
Thanks very much - I'll resend this patch in a minute.

Regards,
Jarek P.
