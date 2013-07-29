From: Joe Perches <joe@perches.com>
Subject: Re: [patch] net_sched: stack info leak in cbq_dump_wrr()
Date: Mon, 29 Jul 2013 13:12:31 -0700
Message-ID: <1375128751.2075.58.camel@joe-AO722>
References: <20130729193651.GA12525@elgon.mountain>
	 <1375127072.2075.48.camel@joe-AO722> <20130729200114.GA29160@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:45652 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754767Ab3G2UMb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jul 2013 16:12:31 -0400
In-Reply-To: <20130729200114.GA29160@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-29 at 23:01 +0300, Dan Carpenter wrote:
> On Mon, Jul 29, 2013 at 12:44:32PM -0700, Joe Perches wrote:
> > On Mon, 2013-07-29 at 22:36 +0300, Dan Carpenter wrote:
> > > opt.__reserved isn't cleared so we leak a byte of stack information.
> > []
> > > diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> > []
> > > @@ -1469,6 +1469,7 @@ static int cbq_dump_wrr(struct sk_buff *skb, struct cbq_class *cl)
> > >  	opt.allot = cl->allot;
> > >  	opt.priority = cl->priority + 1;
> > >  	opt.cpriority = cl->cpriority + 1;
> > > +	opt.__reserved = 0;
> > >  	opt.weight = cl->weight;
> > >  	if (nla_put(skb, TCA_CBQ_WRROPT, sizeof(opt), &opt))
> > >  		goto nla_put_failure;
> > 
> > Alignment isn't guaranteed here so it'd
> > probably be better with a memset.
> > 
> 
> Hm...  Which arches would align it differently?

Hey Dan.

None so far as I know, but what difference does it make
when it's a general correctness issue?
