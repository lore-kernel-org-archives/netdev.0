From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [CORE] Stack changes to add multiqueue hardware support API
Date: Thu, 28 Jun 2007 14:11:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329031F07E6@orsmsx414.amr.corp.intel.com>
References: <46840DF5.7010204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32020 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759344AbXF1VLK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2007 17:11:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46840DF5.7010204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Patrick McHardy [mailto:kaber@trash.net] 
> Sent: Thursday, June 28, 2007 12:37 PM
> To: Jeff Garzik
> Cc: Waskiewicz Jr, Peter P; davem@davemloft.net; 
> netdev@vger.kernel.org; Kok, Auke-jan H; hadi@cyberus.ca
> Subject: Re: [PATCH 2/3] NET: [CORE] Stack changes to add 
> multiqueue hardware support API
> 
> Jeff Garzik wrote:
> > Patrick McHardy wrote:
> > 
> >> Yes, but there are users that don't go through qdiscs, 
> like netpoll, 
> >> Having them check the QDISC_RUNNING bit seems ugly.
> > 
> > 
> > Is netpoll the only such user?
> 
> I'm not sure, I just remembered that one :)
> 
> Looking at Peter's multiqueue patch, which should include all 
> hard_start_xmit users (I'm not seeing sch_teql though, 
> Peter?) the only other one is pktgen.

Ugh.  That is another netif_queue_stopped() that needs
netif_subqueue_stopped().  I can send an updated patch for the core to
fix this based from your patches Patrick.

> 
> > netpoll tends to be a special case in every sense of the 
> word, and I 
> > wish it was less so :/
> 
> Indeed.

So what do we do about netpoll then wrt netif_(sub)queue_stopped() being
removed from qdisc_restart()?  The fallout of having netpoll() cause a
queue to stop (queue 0 only) is the skb sent will be requeued, since the
driver will return NETIF_TX_BUSY if this actually happens.  But this is
a corner case, and we won't lose packets; we'll just have increased
latency on that queue.  Should I worry about this or just move forward
with the sch_teql.c change and repost the core patch?

Thanks,
-PJ Waskiewicz
