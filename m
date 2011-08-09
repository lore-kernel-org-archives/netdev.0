From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net_sched: prio: use qdisc_dequeue_peeked
Date: Tue, 9 Aug 2011 15:45:32 +0200
Message-ID: <20110809134532.GA28510@Chamillionaire.breakpoint.cc>
References: <1312891483-30034-1-git-send-email-fw@strlen.de>
 <1312894585.2371.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:36402 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820Ab1HINpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 09:45:33 -0400
Content-Disposition: inline
In-Reply-To: <1312894585.2371.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >  Eric, does this look correct to you?
> >  I am not sure if sfq needs fixing instead of this patch here.
> > 
> > diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> > index 2a318f2..b5d56a2 100644
> > --- a/net/sched/sch_prio.c
> > +++ b/net/sched/sch_prio.c
> > @@ -112,7 +112,7 @@ static struct sk_buff *prio_dequeue(struct Qdisc *sch)
> >  
> >  	for (prio = 0; prio < q->bands; prio++) {
> >  		struct Qdisc *qdisc = q->queues[prio];
> > -		struct sk_buff *skb = qdisc->dequeue(qdisc);
> > +		struct sk_buff *skb = qdisc_dequeue_peeked(qdisc);
> >  		if (skb) {
> >  			qdisc_bstats_update(sch, skb);
> >  			sch->q.qlen--;
> 
> 
> Hi Florian
> 
> Are you sure this patch is still needed, after commit 
> e1738bd9cecc5c867b0e2996470c1ff20f66ba79
> (sch_sfq: fix sfq_enqueue())

Yes, I double checked.  This patch is applied, also
I see HFSC complaints even without that code path touched by
"sch_sfq: fix sfq_enqueue" being hit.
