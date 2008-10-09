From: Jarod Neuner <j.neuner@networkharbor.com>
Subject: Re: IGMP sent to Foreign VLAN
Date: Thu, 9 Oct 2008 11:18:49 -0500
Message-ID: <1223569129.24688.159.camel@deepthought.nh.local>
References: <1223322707.24688.46.camel@deepthought.nh.local>
	 <20081007.160702.189194318.davem@davemloft.net>
	 <48EBF677.1060602@trash.net>
	 <1223508896.24688.95.camel@deepthought.nh.local>
	 <48EDF9A4.2090908@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-150-216-245-Illinois.hfc.comcastbusiness.net ([75.150.216.245]:61905
	"EHLO mx.networkharbor.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753080AbYJIQSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 12:18:52 -0400
In-Reply-To: <48EDF9A4.2090908@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-09 at 07:31 -0500, Patrick McHardy wrote:
> Jarod Neuner wrote:
> > My original thought was to do something like this in net/core/dev.c
> > using a method similar to handle_bridge or handle_macvlen.  So, if the
> > packet doesn't get handled by the ptype_base list and IFF_ALLVLAN is
> > set, then strip the header and let the packet through.  The sticky point
> > would be whether or not this policy should be enabled by default, as it
> > seems to be in other network stacks.
> 
> I don't think we should change the default, it would probably
> catch some people by surprise. It might not be handled properly
> by packet filtering rules etc.

On the other hand, I was surprised that VLAN packets were being dropped
altogether.  Net admins tend to assign a link to a particular VLAN with
little regard to the VLAN configuration of the hosts on that link.  I'm
thinking of two general situations:

1) If the kernel is resident on an application device (PC, Multimedia
Device, SOHO Router, etc.), and a packet for a particular VLAN reaches
the network interface with a correct MAC and a correct IP, then they
were probably delivered correctly, whether that host is configured with
that VLAN ID or even if the VLAN module is loaded.

2) If the kernel is configured to route incoming VLAN packets, and a
packet arrives with an unconfigured VLAN ID, then it seems perfectly
reasonable to route it as if it had no VLAN tag.

I'm sure someone has a setup that expects that foreign VLANs will be
dropped - but I suspect far more are generally indifferent to the
policy.  There might even be a handful that will be pleasantly surprised
when IGMP snooping suddenly starts to work.

> > Most switches treat VLAN 1 as the "Default" or "Administration" VLAN.
> > It might make sense to map VLAN 1 to the incoming interface, and then
> > use that as a catch all.  Then again, that might be a terrible idea as
> > well. =)
> 
> I prefer 0xfff because its not used for anything else so far.
> Especially the administrative VLAN (even if only by convention)
> doesn't seem by a good idea because its pretty likely you
> would treat it differently from unknown VLANs wrt. filtering.

Agreed.

> So .. would you be interested in implementing this properly?
> I think its a good change and I could help you if needed or
> take care of some parts like the drivers myself.

I've got quite a bit on my plate at the moment, but I will give it a
shot.  I'll try to come up with some of the IFF_ALLVLAN functionality
over the next few days and get back to you.

