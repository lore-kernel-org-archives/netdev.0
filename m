From: jamal <hadi@cyberus.ca>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
	Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 08:54:30 -0400
Message-ID: <1183121670.5188.16.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>
	 <46840AF5.4020209@trash.net>
	 <20070628.212032.108743475.davem@davemloft.net>
	 <1183117415.5156.61.camel@localhost>  <4684F41B.9080309@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:57653 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbXF2Mye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 08:54:34 -0400
Received: by wx-out-0506.google.com with SMTP id h31so828082wxd
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 05:54:34 -0700 (PDT)
In-Reply-To: <4684F41B.9080309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-29-06 at 13:59 +0200, Patrick McHardy wrote:

> I'm guessing that that wouldn't allow to do unicast filtering for
> the guests on the real device without hacking the bridge code for
> this special case. 

For ingress (i guess you could say for egress as well): we can do it as
well today with tc filtering on the host - it is involved but is part of
provisioning for a guest IMO.
A substantial amount of ethernet switches (ok, not the $5 ones) do
filtering at the same level.

> The difference to a real bridge is that the
> all addresses are completely known in advance, so it doesn't need
> promiscous mode for learning.

You mean the per-virtual MAC addresses are known in advance, right?
This is fine. The bridging or otherwise (like L3 etc) is for
interconnecting once you have the provisioning done. And you could build
different "broadcast domains" by having multiple bridges.

To go off on a slight tangent:
I think you have to look at the two types of NICs separately 
1) dumb ones where you may have to use the mcast filters in hardware to
pretend you have a unicast address per virtual device - those will be
really hard to simulate using a separate netdevice per MAC address.
Actually your bigger problem on those is tx MAC address selection
because that is not built into the hardware. I still think even for
these types something above netdevice (bridge, L3 routing, tc action
redirect etc) will do.
2) The new NICs being built for virtualization; those allow you to
explicitly have clean separation of IO where the only thing that is
shared between virtual devices is the wire and the bus (otherwise
each has its own registers etc) i.e the hardware is designed with this
in mind. In such a case, i think a separate netdevice per single MAC
address - possibly tied to a separate CPU should work.

cheers,
jamal

