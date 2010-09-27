From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: igmp: Allow mininum interval specification for igmp timers.
Date: Mon, 27 Sep 2010 11:16:51 -0700
Message-ID: <OFB62F550A.B0782081-ON882577AB.0062DE1F-882577AB.00646E27@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home>	<20100923.213823.137834706.davem@davemloft.net>
	<OF4BA8F9C2.467056E9-ON882577AB.005F4832-882577AB.00612DD6@us.ibm.com> <20100927.105444.214208865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100927.105444.214208865.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org wrote on 09/27/2010 10:54:44 AM:

> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> To: David Stevens/Beaverton/IBM@IBMUS
> Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org
> Date: 09/27/2010 10:54 AM
> Subject: Re: igmp: Allow mininum interval specification for igmp timers.
> Sent by: netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Date: Mon, 27 Sep 2010 10:41:20 -0700
> 
> >         I don't know if you saw the more extended discussion we
> > had on this or not, but I think while this would help for IB,
> > it's not appropriate in general. These can in fact be "0" per
> > RFC which is worst case for IB if there is a delay for being
> > able to use the group, and the newer IGMPv3 standard has shortened
> > the max interval from 10sec in v2 to 1 sec.
> 
> I did see the extended discussion, and it was interesting :-)
> 
> But that mainly focused on the second patch, which I appropriately
> marked as needing changes in patchwork.

        OK, I'm not sure I've seen them all; haven't caught up on
e-mail yet.

> This patch on the other hand is attacking a different problem,
> namely avoiding the worst cases caused by the randomization we
> do for the timer.

        I think the multiples are to allow for drops and the
randomization is to prevent storms. As far as IGMP is concerned,
it's perfectly fine to send them back-to-back, since drops are
not necessarily time periods of network outage (as with IB) but
rather transient queue overflows where even the short delay of
a "0" timer but still having protocol and packet transmit delay
would be fine.
 
> With bad luck this thing times out way too fast because the total of
> all of the randomized intervals can end up being very small, and I
> think we should fix that independently of the other issues hit by the
> IB folks.
> 
> Don't you agree?

        If you mean enforcing a minimum spacing higher than a "0" timer,
I don't know that it's an issue for other network types. According to
IGMPv3, all of them (3 total) on average would be sent in 1 sec, but
it also isn't fatal to drop all of them. To the extent that 1 sec is
"small," it is intentional.
        I'll try digging out the particular patch and comment. I'm not
sure many of these tweaks would necessarily hurt other network types
but I think the current code also isn't a problem for anything but IB,
and that issue can be fixed within IB.

                                                                +-DLS


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
