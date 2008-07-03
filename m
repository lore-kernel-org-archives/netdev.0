From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 13/39]: pkt_sched: Add qdisc_all_tx_empty()
Date: Thu, 03 Jul 2008 13:46:10 -0700 (PDT)
Message-ID: <20080703.134610.250208084.davem@davemloft.net>
References: <20080703.000343.16709755.davem@davemloft.net>
	<486CCFFE.7060009@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <486CCFFE.7060009-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Date: Thu, 03 Jul 2008 15:11:26 +0200

> David Miller wrote:
> > As per comments, this isn't a foolproof implementation.  This is being
> > added so that we can contain and isolate all the explicit ->tx_queue
> > references in the tree.
> > 
> > +/* Are all TX queues of the device empty?  */
> > +static inline bool qdisc_all_tx_empty(const struct net_device *dev)
> > +{
> > +	struct netdev_queue *txq = &dev->tx_queue;
> > +
> > +	/* XXX This is not correct but it is good enough for the
> > +	 * XXX one place that wants this, IRDA.  If we wanted to
> > +	 * XXX do this right, we'd need to add a qdisc op to
> > +	 * XXX probe for the queue state.
> > +	 */
> > +	return skb_queue_empty(&txq->qdisc->q);
> > +}
> 
> 
> It this comment referring to the fact that its looking at
> qdisc->q itself, while the qdisc might be using internal
> queues? If so, just using txq->qdisc->q.qlen should be
> fine since qdiscs are required to always update this value,
> even if they're not using the queue itself.

Indeed, and this is exactly what the sch_generic.c packet output path
uses as a test too.

Thanks Patrick, I'll fix this up.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
