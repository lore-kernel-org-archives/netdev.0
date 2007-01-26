From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Fri, 26 Jan 2007 09:27:30 -0500
Message-ID: <20070126142730.GA15916@hmsreliant.homelinux.net>
References: <20070122181528.GD21059@hmsreliant.homelinux.net> <20070123.091820.104515696.yoshfuji@linux-ipv6.org> <20070123205118.GC582@hmsreliant.homelinux.net> <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com> <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com> <20070125194500.GB8891@hmsreliant.homelinux.net> <45B910B3.5000809@hp.com> <20070125212651.GB12136@hmsreliant.homelinux.net> <45B92BA5.1050505@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4482 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030576AbXAZOcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jan 2007 09:32:08 -0500
Content-Disposition: inline
In-Reply-To: <45B92BA5.1050505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 25, 2007 at 05:13:57PM -0500, Vlad Yasevich wrote:
> Hi Neil
> 
> > 
> > I prefer to be more explicit in my order of operation, but that does seem more
> > consistent with the prevaling style.  New patch attached.
> > 
> 
> Looks good to me.
> 
> One question thought.  What causes the stack to send via Default Router instead
> of sending an NS (Section 3.2).  I see there is code to prevent sending NS from
> the optimistic address, but I see nothing that would send this packet to a default
> router.  This might be buried somewhere in the routing code, but I just can't see it.
> 
> 
I'm looking for it at the moment, but I too had assumed that redirecting the
outgoing packet to the default router would happen automatically within the
routing code as a result of not having a completed neighbor entry available.
Since I've modified ndisc_send_ns such that we will never send Neighbor
solicitations from an optimistic address, as per section 3.2, we'll never get a
completed neightbor entry while the address is optimistic.  If thats not the
case, I'd welcome some suggestions on how to implement this (given that I'm not
overly familiar with the code right now).  From what I see, I think the routing
code will select the default route when rti6_nexthop is null during route
selection, which it will be if the neighbor entry doesn't get resolved.  Not
100% sure though.  Let me know what you think.

Regards
Neil

> Thanks
> -vlad
