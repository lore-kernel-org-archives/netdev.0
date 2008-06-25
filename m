From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] net: Add the CPU id to skb->queue_mapping's upper 8 bits
Date: Wed, 25 Jun 2008 11:31:01 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329054E55AF@orsmsx414.amr.corp.intel.com>
References: <20080624232545.11654.65805.stgit@localhost.localdomain> <20080624.163742.224488012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:23779 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752424AbYFYSbP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 14:31:15 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080624.163742.224488012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Well:
>
>1) All of this multiqueue stuff is going away with my changes in
>   net-tx-2.6

Do you have a guestimate of which kernel you'll be targeting these
changes?  I'm very interested in this schedule.

>2) This CPU number is going to be wrong half of the time.
>
>For #2, when TCP is processing ACKs, it sends packets out from
>whichever CPU the ACK landed on.
>
>So you could end up retargetting the RX flow back and forth between
>cpus.  The cpu that sends the packet into the device layer is far
>from the cpu that should be used to target the RX flow at.
>
>So this idea is pretty seriously flawed and the infrastructure it's
>using is going away anyways.

The whole point is to identify the flow and redirect your Rx filtering
to the CPU it came from.  So if you did this properly, the ACKs would be
landing on the CPU that originally opened the TCP flow.  I don't follow
why the scheduler would move the process if the Rx traffic is returning
to that core.

I also understand the infrastructure is going away.  But without knowing
when things are being changed, we can't be expected to delay sending in
patches to this area of the kernel if there is something we see a
potential benefit for.  We have seen benefit in our labs of keeping
flows on dedicated CPUs and Tx/Rx queue pairs.  I think the concept is
also sensible.  But if my method of getting it working in the kernel is
flawed, then that's fine.  Is there an alternative we can use, or is
this something we can influence the new Tx flow design with?

>It also adds all sorts of arbitray limitations (256 queues and cpus? I
>already have systems coming to me with more than 256 cpus)

I was trying to fit this into existing infrastructure to support the
more common case, which is probably 4-64 CPUs.  Plus I'm not aware of
any NICs out there that support upwards of 256 Tx queues in the physical
function, but I guess I wouldn't be surprised if there are some on the
market.

-PJ Waskiewicz
