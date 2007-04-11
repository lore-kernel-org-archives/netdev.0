From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: [UPDATED] Multiqueue network device support implementation.
Date: Wed, 11 Apr 2007 09:52:50 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902A1A535@orsmsx414.amr.corp.intel.com>
References: <461B5339.50700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11177 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753368AbXDKQwx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 12:52:53 -0400
Content-class: urn:content-classes:message
In-Reply-To: <461B5339.50700@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Thanks.
> 
> > However, the PRIO qdisc still uses the priority in the bands for 
> > dequeueing priority, and will feed the queues on the NIC.
> > The e1000, and any other multiqueue NIC, will schedule Tx 
> based on how 
> > the PRIO qdisc feeds the queues.  So the only priority here is the 
> > dequeuing priority from the kernel.  The e1000 will use the new API 
> > for starting/stopping the individual queues based on the 
> descriptors 
> > available, much like it does today for the global queue.
> 
> 
> Packets will only be dequeued from a band if the associated 
> subqueue is active, which moves the decision from prio to the 
> driver, no?
> What policy does e1000 use for scheduling its internal queues?
> 

E1000 is handed the skb's from PRIO to whichever queue the PRIO flows
dictate (based on band2queue mapping, tc filters, or TOS to
skb->priority filtering).  Once the skb hits the e1000, the internal
policy is round-robin on the hardware queues to dequeue and transmit on
the wire.  I agree the NIC does influence the decision of which band an
skb will be dequeued from based on available descriptors, etc., but
that's one of the goals of multiqueue: don't allow another traffic flow
in one queue stop or impact another separate flow.

Once NICs start using hardware-based priority scheduling (wireless?), we
can use a round-robin type qdisc in the kernel to dequeue, and let the
hardware directly decide how important one flow is over another.

Hope this answers your question.

Cheers,
-PJ Waskiewicz
