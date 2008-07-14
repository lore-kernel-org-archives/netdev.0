From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 11/39]: netdev: Move next_sched into struct
	netdev_queue.
Date: Mon, 14 Jul 2008 12:27:33 +0000
Message-ID: <20080714122733.GA4573@ff.dom.local>
References: <20080703.000333.199735542.davem@davemloft.net> <20080714114913.GA4504@ff.dom.local> <20080714.050011.186100773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vinay-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	krkumar2-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Matheos.Worku-UdXhSnd/wVw@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080714.050011.186100773.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 14, 2008 at 05:00:11AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon, 14 Jul 2008 11:49:13 +0000
> 
> > On 03-07-2008 09:03, David Miller wrote:
> > > We schedule queues, not the device, for output queue
> > > processing in BH.
> > > 
> > ...
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 8e38948..c5e3532 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -1323,13 +1323,14 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
> > >  void __netif_schedule(struct net_device *dev)
> > >  {
> > >  	if (!test_and_set_bit(__LINK_STATE_SCHED, &dev->state)) {
> > 
> > Isn't this bit supposed to be set/tested per queue as well, or do I
> > miss something?
> 
> That shoule not happen until my later patches which switch that all
> over.
> 
> See patch 5/13 which I posted on Thursday, Jul 10.  That's when the
> transition from "global queue state + per-queue state" into "only
> per-queue state" happens.
> 
> Until that point, we have to keep the existing quasi-multi-queue
> semantics in order to not break drivers etc.

I've just wondered how this 1-13/13 step can work without this...

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
