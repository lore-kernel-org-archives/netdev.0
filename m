From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 25 Jun 2007 10:29:29 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903179988@orsmsx414.amr.corp.intel.com>
References: <467EEE92.9040702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65233 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751869AbXFYR3d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 13:29:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467EEE92.9040702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> > +	/* If we're multiqueue, make sure the number of incoming bands
> > +	 * matches the number of queues on the device we're 
> associating with.
> > +	 */
> > +	if (tb[TCA_PRIO_MQ - 1])
> > +		q->mq = *(unsigned char *)RTA_DATA(tb[TCA_PRIO_MQ - 1]);
> > +
> > +	if (q->mq && (qopt->bands != sch->dev->egress_subqueue_count))
> > +		return -EINVAL;
> 
> 
> A nice thing you could do for the user here is use 
> egress_subqueue_count as default when qopt->bands == 0 (and 
> change tc prio to accept 0 in case it doesn't).

prio only allows a minimum of 2 bands right now.  I see what you're
suggesting though; let me think about this.  I do like this suggestion.

Thanks,
-PJ Waskiewicz
