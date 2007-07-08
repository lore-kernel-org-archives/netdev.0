From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Sun, 08 Jul 2007 12:30:13 +1000
Message-ID: <1183861813.6005.227.camel@localhost.localdomain>
References: <1183215164.5165.13.camel@localhost>
	 <20070630.133357.77057070.davem@davemloft.net>
	 <1183466553.5159.51.camel@localhost>
	 <20070703.142431.49854676.davem@davemloft.net>
	 <1183515611.5174.34.camel@localhost>
	 <1183707166.6005.172.camel@localhost.localdomain>
	 <1183732755.5155.85.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:50208 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbXGHCab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Jul 2007 22:30:31 -0400
In-Reply-To: <1183732755.5155.85.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-06 at 10:39 -0400, jamal wrote:
> The first thing that crossed my mind was "if you want to select a
> destination port based on a destination MAC you are talking about a
> switch/bridge". You bring up the issue of "a huge number of virtual NICs
> if you wanted arbitrary guests" which is a real one[2].

Hi Jamal,

	I'm deeply tempted to agree with you that the answer is multiple
virtual NICs (and I've been tempted to abandon lguest's N-way transport
scheme), except that it looks like we're going to have multi-queue NICs
for other reasons.

	Otherwise I'd be tempted to say "create/destroy virtual NICs as other
guests appear/vanish from the network".  Noone does this today, but that
doesn't make it wrong.

> If i got this right, still not answering the netif_stop question posed:
> the problem you are also trying to resolve now is get rid of N
> netdevices on each guest for a usability reason; i.e have one netdevice,
> move the bridging/switching functionality/tables into the driver;
> replace the ports with queues instead of netdevices. Did i get that
> right? 

	Yep, well summarized.  I guess the question is: should the Intel guys
be representing their multi-queue NICs as multiple NICs rather than
adding the subqueue concept?

> BTW, one curve that threw me off a little is it seems most of the
> hardware that provides virtualization also provides point-to-point
> connections between different domains; i always thought that they all
> provided a point-to-point to the dom0 equivalent and let the dom0 worry
> about how things get from domainX to domainY.

Yeah, but that has obvious limitations as people care more about
inter-guest I/O: we want direct inter-guest networking...

Cheers,
Rusty.

