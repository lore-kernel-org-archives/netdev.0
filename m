From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] net: core: set qdisc pkt len before tc_classify
Date: Tue, 12 May 2015 17:16:46 +0200
Message-ID: <20150512151646.GB22387@breakpoint.cc>
References: <1431437838-5478-1-git-send-email-fw@strlen.de>
 <1431440547.566.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:40352 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753137AbbELPQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:16:48 -0400
Content-Disposition: inline
In-Reply-To: <1431440547.566.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > Fixes: d2788d34885d ("net: sched: further simplify handle_ing")
> > Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> > Signed-off-by: Florian Westphal <fw@strlen.de>
> > ---
> >  net/core/dev.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index e5f77c4..871181a 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3540,8 +3540,9 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
> >  		*pt_prev = NULL;
> >  	}
> >  
> > -	qdisc_bstats_update_cpu(cl->q, skb);
> > +	qdisc_skb_cb(skb)->pkt_len = skb->len;
> 
> 
> A qdisc might have a stab (cf qdisc_calculate_pkt_len() )

Thanks for pointing this out Eric.

I was under impression that stab was only useful for egress but in
fact tc did support ingress stab too.

Daniel will submit a v2.
