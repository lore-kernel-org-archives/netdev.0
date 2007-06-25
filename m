From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 25 Jun 2007 14:53:04 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903179DB2@orsmsx414.amr.corp.intel.com>
References: <467E6090.6070703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40224 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752767AbXFYVxV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 17:53:21 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467E6090.6070703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > @@ -70,14 +72,28 @@ prio_classify(struct sk_buff *skb, struct Qdisc 
> > *sch, int *qerr)  #endif
> >  			if (TC_H_MAJ(band))
> >  				band = 0;
> > +			if (q->mq)
> > +				skb->queue_mapping = 
> > +						
> q->prio2band[band&TC_PRIO_MAX];
> > +			else
> > +				skb->queue_mapping = 0;
> 
> 
> Might look cleaner if you have one central point where 
> queue_mapping is set and the band is returned.

I've taken a stab at this.  I can have one return point, but I'll still
have multiple assignments of skb->queue_mapping due to the different
branches for which queue to select in the qdisc.  I suppose we can do a
rewrite of prio_classify(), but to me that seems beyond the scope of the
multiqueue patches themselves.  What do you think?

Thanks,
-PJ
