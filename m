From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: 31 Dec 2004 00:02:42 -0500
Message-ID: <1104469362.1049.224.camel@jzny.localdomain>
References: <20041230122652.GM32419@postel.suug.ch>
	 <20041230123023.GO32419@postel.suug.ch>  <41D4A4D2.4000109@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D4A4D2.4000109@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-30 at 20:01, Patrick McHardy wrote:

> > +#ifdef CONFIG_NET_CLS_ACT
> > +	if (src->action) {
> > +		if (dst->action) {
> > +			struct tc_action *act;
> > +
> > +			tcf_tree_lock(tp);
> > +			act = xchg(&dst->action, src->action);
> > +			tcf_tree_unlock(tp);
> > +
> > +			tcf_action_destroy(act, TCA_ACT_UNBIND);
> > +		} else
> > +			dst->action = src->action;
> 
> This isn't right (its also wrong in the current code). If the
> CPU reorders stores and another CPU looks at dst->action at
> the wrong time it might see an inconsistent structure. 

I think an xchg around the else should fix this.

> So at
> least smp_wmb is required for the unlocked case,

or maybe this. 

>  but I think
> you should just remove it completely. I also wonder if anyone
> actually knows why we need the xchg (here and in all the other
> places), it looks totally useless.

All these were put in by Alexey and the LinuxWay(tm) took effect.
an xchg puts almost a lock and ensures an atomic swap. I dont see any
harm in leaving it as is - just needs fixing the else

cheers,
jamal
