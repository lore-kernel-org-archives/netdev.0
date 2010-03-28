From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Sun, 28 Mar 2010 10:50:06 +0200
Message-ID: <877how25kx.fsf@basil.nowhere.org>
References: <1269561751.2891.8.camel@ilion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39671 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911Ab0C1IuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 04:50:08 -0400
In-Reply-To: <1269561751.2891.8.camel@ilion> (Glen Turner's message of "Fri, 26 Mar 2010 10:32:31 +1030")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glen Turner <gdt@gdt.id.au> writes:

> In IPv6 routers do not fragment packets, so there is no work
> around. Transactional servers which use UDP over IPv6 encounter
> exponential backoffs within the application and the client
> abandons the transaction. There is no way for the server to
> know that the packet was lost due to Path MTU Discovery and
> to immediately re-transmit it (without an exponential penalty)
> so that the MTU can be probed again.

You can still turn path mtu discovery off and Linux will
fragment based on the known path MTU (I believe when
the too big fragment gets a icmp back the pmtu gets updated)

However you might lose a few packets in the process until the path MTU
is known, but at least it will stay cached (unless you thrash the
routing cache)

In theory one could probably add some hack in the the kernel UDP code
to hold one packet and retransmit it immediately with fragments when
the ICMP comes in. However that would be quite far in behaviour from
traditional UDP and be considered very ugly. It could also mess up
congestion avoidance schemes done by the application. 

Still might be preferable over rewriting zillions of applications?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
