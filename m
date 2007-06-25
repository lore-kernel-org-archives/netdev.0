From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 25 Jun 2007 15:07:51 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903179DE1@orsmsx414.amr.corp.intel.com>
References: <46803A9E.40705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13488 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbXFYWIC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 18:08:02 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46803A9E.40705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Thats not necessary. I just though you could add one exit point:
> 
> 
> ...
> out:
>     skb->queue_mapping = q->mq ? band : 0;
>     return q->queues[band];
> }
> 
> But if that doesn't work don't bother ..

Unfortunately it won't, given how band might be used like this to select
the queue:

return q->queues[q->prio2band[band&TC_PRIO_MAX]];

I'll keep this in mind though, and if it can be done cleanly, I'll
submit a patch.

Thanks Patrick,
-PJ
