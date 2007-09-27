From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 08:46:49 -0400
Message-ID: <1190897209.4290.24.camel@localhost>
References: <20070927073446.GA14643@gondor.apana.org.au>
	 <20070927092512.GD29329@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:12419 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbXI0Mq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 08:46:56 -0400
Received: by wr-out-0506.google.com with SMTP id 36so1043087wra
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 05:46:53 -0700 (PDT)
In-Reply-To: <20070927092512.GD29329@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-27-09 at 13:25 +0400, Evgeniy Polyakov wrote:


> > +#define NAT_TAB_MASK	15
> 
> This really wants to be configurable at least via module parameter.

Would not be a bad idea, but not specific to just this one action.
Note: probably not a very big deal to have 15 there because in the fast
path that table is not being looked up; once an action is bound to a
filter, its the filter lookups that count.

> > +static struct tcf_common *tcf_nat_ht[NAT_TAB_MASK + 1];
> > +static u32 nat_idx_gen;
> > +static DEFINE_RWLOCK(nat_lock);
> 
> > +static struct tcf_hashinfo nat_hash_info = {
> > +	.htab	=	tcf_nat_ht,
> > +	.hmask	=	NAT_TAB_MASK,
> > +	.lock	=	&nat_lock,
> > +};
> 
> When I read this I swear I heard 'I want to be RCU'.
> But that is another task.

Go ahead and clean that up to use rcu. What would be really nice is to
have generic hash table scheme which uses the scheme above and then this
code (and a lot other) is converted to use it; if you stared a bit at
the code youd notice a lot of commonalities with a lot of similar
netcode (look at the ipip driver for example). The LinuxWay(tm).
I know Patrick hinted at some point he may do that (or maybe it was my
imagination;->)

cheers,
jamal

