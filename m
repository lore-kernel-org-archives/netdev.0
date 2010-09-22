From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
 reports
Date: Wed, 22 Sep 2010 14:58:15 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009221448460.32661@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2010, David Stevens wrote:

>         I feel your pain, but the protocol allows this to be 0 and all
> of the unsolicited reports can be lost. I don't think adding a minimum
> latency solves a general problem. Perhaps the device should queue some

The protocol does not specificy the intervals during unsolicited igmp
sends. It only specifies the intervals as a result of a igmp query.

> packets if it isn't ready quickly? A querier is what makes these
> reliable, but for the start-up in particular, I think it'd be better
> to not initiate the send on devices that have this problem until the
> device is actually ready to send-- why not put the delay in the device
> driver on initialization?

The device is ready. Its just the multicast group that has not been
established yet.

> > an igmp query but the result of a join request in the code.
>
>         These are also staggered to prevent a storm by mass reboots, e.g.,
> from a power outage, and the default groups are joined on interface
> bring-up.

There is still some staggering left (see IGMP_Unsolicited_Fuzz). I can
increase that if necessary.

There also cannot be any storm since any unsolicited igmp report by any
system will stop the unsolicited igmp reports by any other system.

> > So unsolicited reports are send for an interval of at least a minute
> > (reports are aborted if igmp reports or other info is seen).
>
>         This is outside the protocol spec, and the intervals are neither
> random nor scaled based on any network performance metric.

Where does it say that in the spec? Again this is an *unsolicited* igmp
report.

> 2) I think this would better be solved in the driver-- don't do the
>         upper initialization and group joins until the sends can actually
>         succeed.

The driver is fine. Its just the multicast path in the network that take
time to establish.

> 3) I don't think it's a good idea to make up intervals, and especially
>         non-randomized ones. The probability of getting all minimum
> intervals
>         is very low (which goes back to #1) and sending fixed intervals
> may
>         introduce a problem (packet storms) that isn't there per RFC.
> These
>         fixed intervals can also be either way too long or way too short,
>         depending on link characteristics they don't account for. Leaving
>         the intervals randomized based on querier-supplied data seems much
>         more appropriate to me.

These are *unsolicited* igmp reports. There is *no* querier supplied data
yet. The first querier supplied data (or any other unsolicited igmp
report) will immediately stop the unsolicited reports and then will
continue to respond in randomized intervals based on the data that the
querier has supplied.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
