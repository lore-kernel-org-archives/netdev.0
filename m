From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Thu, 28 Jun 2007 16:08:43 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903220B8D@orsmsx414.amr.corp.intel.com>
References: <4684258D.7000503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jeff@garzik.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13857 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763628AbXF1XIm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 19:08:42 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4684258D.7000503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Waskiewicz Jr, Peter P wrote:
> >>
> >> Looking at Peter's multiqueue patch, which should include all 
> >> hard_start_xmit users (I'm not seeing sch_teql though,
> >> Peter?) the only other one is pktgen.
> >>     
> >
> > Ugh.  That is another netif_queue_stopped() that needs 
> > netif_subqueue_stopped().  I can send an updated patch for 
> the core to 
> > fix this based from your patches Patrick.
> >   
> 
> I still have the tree around, here's an updated version.
> 
> >
> > So what do we do about netpoll then wrt netif_(sub)queue_stopped() 
> > being removed from qdisc_restart()?  The fallout of having 
> netpoll() 
> > cause a queue to stop (queue 0 only) is the skb sent will 
> be requeued, 
> > since the driver will return NETIF_TX_BUSY if this actually 
> happens.  
> > But this is a corner case, and we won't lose packets; we'll 
> just have 
> > increased latency on that queue.  Should I worry about this or just 
> > move forward with the sch_teql.c change and repost the core patch?
> >   
> 
> 
> I don't think you need to worry about that, the subqueue 
> patch just follows the existing code.

Thanks Patrick for taking care of this.  I am totally fine with this
patch; if anyone else has feedback, please send it.  If not, I'm excited
to see if these can be considered for 2.6.23 now.  :)  Thanks everyone
for the help.

Cheers,
-PJ Waskiewicz
