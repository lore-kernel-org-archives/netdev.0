From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net] net: sched: Don't free f before it is allocated in
 route4_change
Date: Thu, 24 Oct 2013 16:59:36 +0200
Message-ID: <20131024145936.GB15936@cpaasch-mac>
References: <1382626250-15676-1-git-send-email-christoph.paasch@uclouvain.be>
 <1382626473.7572.58.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Jing Wang <windsdaemon@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:41649 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754998Ab3JXO7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 10:59:44 -0400
Content-Disposition: inline
In-Reply-To: <1382626473.7572.58.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/10/13 - 07:54:33, Eric Dumazet wrote:
> On Thu, 2013-10-24 at 16:50 +0200, Christoph Paasch wrote:
> > f is set to *arg in route4_change at the beginning, which points to a
> > route4_filter in the hash-table (gotten through route4_get, called by
> > tc_ctl_filter). If the alloc of head fails, we should not goto errout,
> > because this will free f and thus freed memory will be referenced by
> > the hash-table.
> > Only later the pointer f will change to an allocated route4_filter.
> > 
> > This patch returns err if the allocation of head fails as f has not yet
> > been allocated inside route4_change.
> > 
> > Seems the code has been like this since Linus's original git-commit.
> > 
> > Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> > ---
> >  net/sched/cls_route.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> > index 37da567..f17c67f 100644
> > --- a/net/sched/cls_route.c
> > +++ b/net/sched/cls_route.c
> > @@ -470,7 +470,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
> >  	if (head == NULL) {
> >  		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
> >  		if (head == NULL)
> > -			goto errout;
> > +			return err;
> >  
> >  		tcf_tree_lock(tp);
> >  		tp->root = head;
> 
> I see no bug here, you missed the "goto reinsert;"

Ups - sorry...
