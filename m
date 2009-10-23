From: Jasper Spaans <spaans@fox-it.com>
Subject: Re: bridging + load balancing bonding
Date: Fri, 23 Oct 2009 13:45:11 +0200
Message-ID: <20091023114511.GA537@spaans.fox.local>
References: <20091022122339.GA20148@spaans.fox.local> <4AE07D3C.3040702@gmail.com> <347.1256232960@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:22730 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751554AbZJWLpN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 07:45:13 -0400
Content-Disposition: inline
In-Reply-To: <347.1256232960@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2009 at 07:36:00PM +0200, Jay Vosburgh wrote:
> 	By "packets from one flow" do you really mean that packets from
> a given "flow" (TCP connection, UDP "stream", etc) are not always
> delivered to the same bonding port?  I.e., that two packets from the
> same "flow" will be delivered to different ports?  I'm not sure how
> that's possible unless the source MAC in the packets changes during the
> course of the flow.
> 
> 	Or is your problem really that the balance algorithm on the
> bonding send side doesn't match the algorithm used on the other side of
> the IDS machines coming the other direction (and, thus, packets for a
> given flow going in one direction end up at a different IDS than the
> packets going the other direction)?

It's the second problem: traffic in one direction ends up at another
node than traffic in the other direction, even if between the same pair of
machines.

> 	Locally generated packets do, but he's got a bridge in there, so
> the traffic they're balancing is presumably not locally generated (i.e.,
> is being forwarded by the bridge, in which case they'll still bear the
> source MAC of the originating node on the subnet).  If the packets were
> being routed instead of bridged, then, yah, they'd have the bond's
> source MAC.

And in case of routing, the destination MAC will also be modified.. so worst
case (all traffic goes to one node), no balancing will happen. This also
affects non-IDS use of load balancing, I guess.

> >So your solution might be the right fix...
> 
> 	Yes, I think he's found a legitimate bug, one that only will
> manifest when balancing bridged traffic.  I had to think for a minute if
> this change would break anything, and I'm coming up empty.  Locally
> generated or routed traffic won't see a change, and bridged traffic will
> be correctly balanced according to the "source MAC XOR destination MAC"
> forumla described in the documentation.

I'll post a patch shortly.

Jasper
-- 
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624
