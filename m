From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
 reports
Date: Thu, 23 Sep 2010 12:37:28 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009231230100.2962@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home> <20100922215052.GK11157@obsidianresearch.com>
 <alpine.DEB.2.00.1009231026510.32567@router.home> <20100923172603.GM11157@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100923172603.GM11157-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2010, Jason Gunthorpe wrote:

> On Thu, Sep 23, 2010 at 10:32:17AM -0500, Christoph Lameter wrote:
>
> > > Is the issue you are dropping IGMP packets because the 224.0.0.2 join
> > > hasn't finished? Ideally you'd wait for the SA to reply before sending
> > > a IGMP, but a simpler solution might just be to use the broadcast MLID
> > > for packets addressed to a MGID that has not yet got a MLID. This
> > > would bebe similar to the ethernet behaviour of flooding.
> >
> > IGMP reports are sent on the multicast group not on 224.0.0.2. 224.0.0.2
> > is only used when leaving a multicast group.
>
> Hm, that is quite different than in IGMPv3.. How does this work at all
> in IB? A message to the multicast group isn't going to make it to any
> routers unless the routers use some other means to join the IB MGID.

IPoIB creates a infiniband multicast group via the IB calls for a IP
multicast group. Then IGMP comes into play and the kernel sends the IP
based igmp report. This igmp report must be received by an outside router
(on an IP network) in order to for traffic to get forwarded into the IB
fabric. You can end up with a IB multicast configuration that is all fine
but with loss of the unsolicited packets due to fabric reconfiguration not
being complete yet. The larger the fabric the worse the situation.

If all unsolicited igmp reports are lost then the router will
only start forwarding the mc group after the reporting intervals
(which could be in the range of minutes) when it triggers igmp reports
through a general igmp query. Until that time the MC group looks dead. And
people and software may conclude that the **** network is broken.

This is a general issue for any network where configurations for MC
forwarding is needed and where initial igmp reports may get lost. A
staggering of time intervals would be a general solution to that issue.



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
