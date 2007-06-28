From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 12:04:17 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F0614@orsmsx414.amr.corp.intel.com>
References: <4683EC23.2050705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38279 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753731AbXF1TET convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:04:19 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4683EC23.2050705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> > +#ifdef CONFIG_NET_SCH_MULTIQUEUE
> > +			if (q->mq)
> > +				skb->queue_mapping = 
> > +						
> q->prio2band[band&TC_PRIO_MAX];
> > +			else
> > +				skb->queue_mapping = 0;
> > +#endif
> 
> 
> Setting it to zero here is wrong, consider:
> 
> root qdisc: prio multiqueue
> child qdisc: prio non-multiqueue
> 
> The top-level qdisc will set it, the child qdisc will unset it again.
> When multiqueue is inactive it should not touch it.
> 
> I'll fix that as well.

But the child can't assume the device is multiqueue if the child is
non-multiqueue.  This is the same issue with IP forwarding, where if you
forward through a multiqueue device to a non-mq device, you don't know
if the destination device is multiqueue.  So the last qdisc to actually
dequeue into a device should have control what the queue mapping is.  If
a user had a multiqueue qdisc as root, and configured a child qdisc as
non-mq, that is a configuration error if the underlying device is indeed
multiqueue IMO.

-PJ
