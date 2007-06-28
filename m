From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Thu, 28 Jun 2007 12:21:29 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>
References: <46840941.5040407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13045 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760857AbXF1TVb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 15:21:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46840941.5040407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Absolutely not. First of all, its perfectly valid to use 
> non-multiqueue qdiscs on multiqueue devices. Secondly, its 
> only the root qdisc that has to know about multiqueue since 
> that one controls the child qdiscs.
> 
> Think about it, it makes absolutely no sense to have the 
> child qdisc even know about multiqueue. Changing my example 
> to have a multiqueue qdisc as child:
> 
> root qdisc: 2 band prio multiqueue
> child qdisc of band 0: 2 band prio multiqueue
> 
> When the root qdisc decides to dequeue band0, it checks 
> whether subqueue 0 is active and dequeues the child qdisc. If 
> the child qdisc is indeed another multiqueue qdisc as you 
> suggest, if might decide to dequeue its own band 1 and checks 
> that subqueue state. So where should the packet finally end 
> up? And what if one of both subqueues is inactive?
> 
> The only reasonable thing it can do is not care about 
> multiqueue and just dequeue as usual. In fact I think it 
> should be an error to configure multiqueue on a non-root qdisc.

Ack.  This is a thought process that trips me up from time to time...I
see child qdisc, and think that's the last qdisc to dequeue and send to
the device, not the first one to dequeue.  So please disregard my
comments before; I totally agree with you.  Great catch here; I really
like the prio_classify() cleanup.

As always, many thanks for your feedback and help Patrick.

-PJ
