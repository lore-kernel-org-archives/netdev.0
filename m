From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp reports
Date: Wed, 22 Sep 2010 13:36:17 -0700
Message-ID: <OFAB7DE0DE.BD125180-ON882577A6.006F6717-882577A6.00713062@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
To: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009221448460.32661-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org> wrote:
> 
> On Wed, 22 Sep 2010, David Stevens wrote:
> 
> >         I feel your pain, but the protocol allows this to be 0 and all
> > of the unsolicited reports can be lost. I don't think adding a minimum
> > latency solves a general problem. Perhaps the device should queue some
> 
> The protocol does not specificy the intervals during unsolicited igmp
> sends. It only specifies the intervals as a result of a igmp query.

RFC 3376:
"  To cover the possibility of the State-Change Report being missed by
   one or more multicast routers, it is retransmitted [Robustness
   Variable] - 1 more times, at intervals chosen at random from the
   range (0, [Unsolicited Report Interval])."
and
"8.11. Unsolicited Report Interval

   The Unsolicited Report Interval is the time between repetitions of a
   host's initial report of membership in a group.  Default: 1 second."

> The device is ready. Its just the multicast group that has not been
> established yet.
        Well, if you know that's going to happen with your device, then
again, why not queue them on start up until you have indication that
the group has been established, or delay in the driver.
        You're changing IGMP for all device types to fix a problem in
only one.
 
> There also cannot be any storm since any unsolicited igmp report by any
> system will stop the unsolicited igmp reports by any other system.

        Not if they are simultaneous, which is exactly when it is a 
problem. :-)
> 
> > > So unsolicited reports are send for an interval of at least a minute
> > > (reports are aborted if igmp reports or other info is seen).
> >
> >         This is outside the protocol spec, and the intervals are 
neither
> > random nor scaled based on any network performance metric.
> 
> Where does it say that in the spec? Again this is an *unsolicited* igmp
> report.

        See quotes above.
 
> These are *unsolicited* igmp reports. There is *no* querier supplied 
data
> yet. The first querier supplied data (or any other unsolicited igmp
> report) will immediately stop the unsolicited reports and then will
> continue to respond in randomized intervals based on the data that the
> querier has supplied.

        There are initial values, which are currently constants, but it'd
be (more) reasonable to turn those into per-interface tunables or
per-interface initial values with IB interfaces using larger values.

IGMP_Unsolicited_Report_Count (default 2)
IGMP_Unsolicited_Report_Interval (default 10secs which is 10x larger,as
        you want, than the RFC suggests).

                                                                +-DLS

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
