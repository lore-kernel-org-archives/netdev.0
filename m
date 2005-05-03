From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] (3/3) netem: adjust parent qlen when duplicating
Date: Tue, 3 May 2005 16:30:25 -0700
Message-ID: <20050503163025.38bb9682.davem@davemloft.net>
References: <20050503162550.30acf31a@dxpl.pdx.osdl.net>
	<42780AC1.8040409@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <42780AC1.8040409@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 04 May 2005 01:35:29 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Fix qlen underrun when doing duplication with netem. If netem is used as 
> > leaf discipline, then the parent needs to be tweaked when packets  are duplicated.
> 
> > +			/* Since one packet can generate two packets in the
> > +			 * queue, the parent's qlen accounting gets confused,
> > +			 * so fix it.
> > +			 */
> > +			qp = qdisc_lookup(sch->dev, TC_H_MAJ(sch->parent));
> > +			if (qp)
> > +				qp->q.qlen++;
> 
> This only works in a hierarchy with just one qdisc above netem, there
> could be up to seven (check_loop_fn prevents more than that). It's also
> not safe because it violates qdisc locking rules, when this code is
> executed dev->queue_lock is already taken and qdisc_lookup() grabs
> qdisc_tree_lock, but they can only be taken in the other order.

I see... I'm leaving Stephen's patch in there for now.

Perhaps we can create some kind of "propagate up" function
that will handle all of the parents in the qdisc hierarchy
above netem?
