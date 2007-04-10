From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: [UPDATED] Multiqueue network device support implementation.
Date: Tue, 10 Apr 2007 11:04:57 +0200
Message-ID: <461B5339.50700@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329029E42C6@orsmsx414.amr.corp.intel.com>
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
Received: from stinky.trash.net ([213.144.137.162]:55413 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966127AbXDJJFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 05:05:33 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329029E42C6@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
> Thanks Pat for the initial feedback.  I can post a set of patches to
> e1000 using the new API; I'll try to get them out asap (need to apply to
> this kernel tree).


Thanks.

> However, the PRIO qdisc still uses the priority in
> the bands for dequeueing priority, and will feed the queues on the NIC.
> The e1000, and any other multiqueue NIC, will schedule Tx based on how
> the PRIO qdisc feeds the queues.  So the only priority here is the
> dequeuing priority from the kernel.  The e1000 will use the new API for
> starting/stopping the individual queues based on the descriptors
> available, much like it does today for the global queue.


Packets will only be dequeued from a band if the associated subqueue
is active, which moves the decision from prio to the driver, no?
What policy does e1000 use for scheduling its internal queues?

