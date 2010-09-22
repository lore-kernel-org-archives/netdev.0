From: Christoph Lameter <cl@linux.com>
Subject: Re: igmp: Staggered igmp report intervals for unsolicited igmp
 reports
Date: Wed, 22 Sep 2010 16:26:43 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009221618390.32661@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <alpine.DEB.2.00.1009221400010.32661@router.home> <OFF06BBC88.0B6755D5-ON882577A6.0068F4F8-882577A6.006B31FB@us.ibm.com> <alpine.DEB.2.00.1009221448460.32661@router.home>
 <OFAB7DE0DE.BD125180-ON882577A6.006F6717-882577A6.00713062@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Bob Arendt <rda@rincon.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.prem.mail.ac4.yahoo.com ([76.13.13.41]:28836 "HELO
	smtp102.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752170Ab0IVV0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 17:26:46 -0400
In-Reply-To: <OFAB7DE0DE.BD125180-ON882577A6.006F6717-882577A6.00713062@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Sep 2010, David Stevens wrote:

> > The protocol does not specificy the intervals during unsolicited igmp
> > sends. It only specifies the intervals as a result of a igmp query.
>
> RFC 3376:
> "  To cover the possibility of the State-Change Report being missed by
>    one or more multicast routers, it is retransmitted [Robustness
>    Variable] - 1 more times, at intervals chosen at random from the
>    range (0, [Unsolicited Report Interval])."
> and
> "8.11. Unsolicited Report Interval
>
>    The Unsolicited Report Interval is the time between repetitions of a
>    host's initial report of membership in a group.  Default: 1 second."


Hmmm looks like I looked at the earlier RFC 2236 3) (was not really
interested in IGMP v3, IGMPv2 is run).

   When a host joins a multicast group, it should immediately transmit
   an unsolicited Version 2 Membership Report for that group, in case it
   is the first member of that group on the network.  To cover the
   possibility of the initial Membership Report being lost or damaged,
   it is recommended that it be repeated once or twice after short
   delays [Unsolicited Report Interval].  (A simple way to accomplish
   this is to send the initial Version 2 Membership Report and then act
   as if a Group-Specific Query was received for that group, and set a
   timer appropriately).

The new Unsolicited Report Interval is promising. We need to support that?

> > The device is ready. Its just the multicast group that has not been
> > established yet.
>         Well, if you know that's going to happen with your device, then
> again, why not queue them on start up until you have indication that
> the group has been established, or delay in the driver.
>         You're changing IGMP for all device types to fix a problem in
> only one.
>
> > There also cannot be any storm since any unsolicited igmp report by any
> > system will stop the unsolicited igmp reports by any other system.
>
>         Not if they are simultaneous, which is exactly when it is a
> problem. :-)

But then they are not simulateneous since there is a fuzz factor.

> > These are *unsolicited* igmp reports. There is *no* querier supplied
> data
> > yet. The first querier supplied data (or any other unsolicited igmp
> > report) will immediately stop the unsolicited reports and then will
> > continue to respond in randomized intervals based on the data that the
> > querier has supplied.
>
>         There are initial values, which are currently constants, but it'd
> be (more) reasonable to turn those into per-interface tunables or
> per-interface initial values with IB interfaces using larger values.
>
> IGMP_Unsolicited_Report_Count (default 2)
> IGMP_Unsolicited_Report_Interval (default 10secs which is 10x larger,as
>         you want, than the RFC suggests).

Ahhh... Interesting..... 1 second now? That is much better and would avoid
long drawn out joins due to the long delays.


