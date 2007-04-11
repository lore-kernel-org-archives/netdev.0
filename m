From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: [UPDATED] Multiqueue network device support implementation.
Date: Wed, 11 Apr 2007 19:03:29 +0200
Message-ID: <461D14E1.6020100@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902A1A535@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57287 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbXDKRDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 13:03:38 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902A1A535@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>Packets will only be dequeued from a band if the associated 
>>subqueue is active, which moves the decision from prio to the 
>>driver, no?
>>What policy does e1000 use for scheduling its internal queues?
>>
> 
> 
> E1000 is handed the skb's from PRIO to whichever queue the PRIO flows
> dictate (based on band2queue mapping, tc filters, or TOS to
> skb->priority filtering).  Once the skb hits the e1000, the internal
> policy is round-robin on the hardware queues to dequeue and transmit on
> the wire.  I agree the NIC does influence the decision of which band an
> skb will be dequeued from based on available descriptors, etc., but
> that's one of the goals of multiqueue: don't allow another traffic flow
> in one queue stop or impact another separate flow.


Yes, I'm not saying its wrong, but it will surprise users that put a
prio qdisc on a multiqueue device without knowing anything about the
multiqueue capabilities and suddenly don't have strict priority
anymore. If it changes the behaviour, it should be explicitly enabled
by the user in the prio qdisc configuration. This would also allow
to move the band2queue mapping policy to userspace.

> Once NICs start using hardware-based priority scheduling (wireless?), we
> can use a round-robin type qdisc in the kernel to dequeue, and let the
> hardware directly decide how important one flow is over another.


You bring up a good point, it would be good to hear the opinion from
one of the wireless people on this since they have their own multiqueue
scheduler in the wireless-dev tree.

