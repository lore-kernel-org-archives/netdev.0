From: Christoph Lameter <cl@linux.com>
Subject: Re: igmp: Allow mininum interval specification for igmp timers.
Date: Mon, 27 Sep 2010 15:20:54 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009271503420.14117@router.home>
References: <alpine.DEB.2.00.1009221354410.32661@router.home> <20100923.213823.137834706.davem@davemloft.net> <OF4BA8F9C2.467056E9-ON882577AB.005F4832-882577AB.00612DD6@us.ibm.com> <20100927.105444.214208865.davem@davemloft.net>
 <OFC4EC0538.26831D99-ON882577AB.006B8055-882577AB.006D75FF@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	rda@rincon.com
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.prem.mail.ac4.yahoo.com ([76.13.13.40]:20733 "HELO
	smtp101.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757228Ab0I0UU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 16:20:58 -0400
In-Reply-To: <OFC4EC0538.26831D99-ON882577AB.006B8055-882577AB.006D75FF@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Sep 2010, David Stevens wrote:

> > With bad luck this thing times out way too fast because the total of
> > all of the randomized intervals can end up being very small, and I
> > think we should fix that independently of the other issues hit by the
> > IB folks.
>
>         I think I'm caught up on the discussion now. For IGMPv3, we
> would send all the reports always in < 2 secs, and the average would
> be < 1 sec, so I'm not sure any sort of tweaks we do to enforce a
> minimum randomized interval are compatible with IGMPv3 and still
> solve IB's problem.

Ok thanks for the effort but so far I do not see you having caught up. I'd
rather avoid responding to the misleading statements you made in other
replies and just respond to where you missed the boat here.

>         As I said before, I think per protocol, back-to-back is both
> allowed and not a problem, even if both subsequent randomized reports
> come out to 0 time. But if we wanted to enforce a minimum interval
> of, say, X, then I think the better way to do that is to set the
> timer to X + rand(Interval-X) and not a table of fixed intervals

The second patch sets the intervals to X .. X + Rand (interval) and not to
a table of fixed intervals as you state here. I have pointed this out
before.

> as in the original patch. For v2, X=1 or 2 sec and Interval=10
> might work well, but for v3, the entire interval is 1 sec and I
> think I saw that the set-up time for the fabric may be on the
> order of 1 sec.

Again there is no knowledge about V2 or V3 without a query and this is
during the period when no querier is known yet. You stated elsewhere that
I can assume V3 by default? So 1 sec?

>         I also don't think that we want those kinds of delays on
> Ethernet. A program may join and send lots of traffic in 1 sec,
> and if the immediate join is lost, one of the quickly-following
> <1 sec duplicate reports will make it recover and work. Delaying
> the minimum would guarantee it wouldn't work until that minimum
> and drop all that traffic if the immediate report is lost, then.

There can be any number of reasons that a short outage could prevent the
packets from going through. A buffer overrun (that you mentioned
elsewhere) usually causes lots of packets to be lost. Buffer overrun
scenarios usually mean that all igmp queries are lost.

>         Really, of course, I think the solution belongs in IB, but
> if we did anything in IGMP, I'd prefer it were a per-interface
> tunable that defaults as in the RFC. Since you can change the
> interval and # of reports through a querier now, exporting the
> default values of (10,2) for v2 and (1,2) for v3 to instead be
> per-interface tunables and then bumped as needed for IB would
> allow tweaking without running a querier. But a querier that's
> using default values would also override that and cause the
> problem all over again. Queuing in the driver until the MAC
> address is usable solves it generally.

There is no solution on the IB layer since there is no notification when
the fabric reconfiguration necessary for an multicast group is complete.

The querier is of not use since (for the gazillionth of times) this is an
unsolicited IGMP report. If there is a querier then the unsolicited igmp
reports would not be used but the timeout indicated by the querier would
be used.


