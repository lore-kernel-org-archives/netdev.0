From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: igmp: Allow mininum interval specification for igmp timers.
Date: Mon, 27 Sep 2010 10:41:20 -0700
Message-ID: <OF4BA8F9C2.467056E9-ON882577AB.005F4832-882577AB.00612DD6@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <20100923.213823.137834706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100923.213823.137834706.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote on 09/23/2010 09:38:23 PM:

> 
> > IGMP timers sometimes fire too rapidly due to randomization of the
> > intervalsfrom 0 to max_delay in igmp_start_timer().
>  ...
> > Signed-off-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
> 
> 
> This change seems reasonable to me, what do you think David?

[sorry for the delay -- I was off-line for the last few days]
Dave,
        I don't know if you saw the more extended discussion we
had on this or not, but I think while this would help for IB,
it's not appropriate in general. These can in fact be "0" per
RFC which is worst case for IB if there is a delay for being
able to use the group, and the newer IGMPv3 standard has shortened
the max interval from 10sec in v2 to 1 sec.
        Fundamentally, the problem is that the device needs to
be able to send on the group immediately for IGMP; that it
can't for IB is the problem, and I think it should be solved
in IB by either queueing packets there or delaying there as
needed before doing the joins.
        I don't think tweaking IGMP for this is appropriate at
all, but if done there, it ought to be per-interface so it
doesn't change anything for other network types which don't
have this problem. It should be randomized and not the fixed
delays to prevent storms on a mass start-up, and we also don't
want to be increasing the number of duplicates for other
network types. The default should be 2 reports in randomized
0-10 sec for each for v2, 2 in randomized 0-1 sec for v3.

                                                        +-DLS

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
