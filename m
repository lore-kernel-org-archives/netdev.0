From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] qfq: don't leak skb if kzalloc fails
Date: Wed, 8 Jun 2016 23:04:28 +0200
Message-ID: <20160608210428.GE29699@breakpoint.cc>
References: <1465389093-29674-1-git-send-email-fw@strlen.de>
 <1465401273.7945.18.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60613 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbcFHVEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 17:04:33 -0400
Content-Disposition: inline
In-Reply-To: <1465401273.7945.18.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2016-06-08 at 14:31 +0200, Florian Westphal wrote:
> > When we need to create a new aggregate to enqueue the skb we need
> > to kzalloc the new struct.
> > 
> > If that fails we returned ENOBUFS without freeing the skb.
> > 
> > Spotted during code review.
> > 
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  net/sched/sch_qfq.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
> > index 8d2d8d9..435b970 100644
> > --- a/net/sched/sch_qfq.c
> > +++ b/net/sched/sch_qfq.c
> > @@ -1236,7 +1236,7 @@ static int qfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> >  		err = qfq_change_agg(sch, cl, cl->agg->class_weight,
> >  				     qdisc_pkt_len(skb));
> >  		if (err)
> > -			return err;
> > +			return qdisc_drop(skb, sch);
> >  	}
> >  
> >  	err = qdisc_enqueue(skb, cl->qdisc);
> 
> Good catch, but it looks like you forgot :
> 
> 	cl->qstats.drops++;

Thanks, we have too many stats :-/

I'll send a v2, thanks!
