From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Fri, 22 Jun 2007 11:00:12 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903178F0B@orsmsx414.amr.corp.intel.com>
References: <467B0E12.6030200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:59628 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756299AbXFVSAO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 14:00:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <467B0E12.6030200@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >  #include <linux/module.h>
> > @@ -40,9 +42,13 @@
> >  struct prio_sched_data
> >  {
> >  	int bands;
> > +#ifdef CONFIG_NET_SCH_RR
> > +	int curband; /* for round-robin */
> > +#endif
> >  	struct tcf_proto *filter_list;
> >  	u8  prio2band[TC_PRIO_MAX+1];
> >  	struct Qdisc *queues[TCQ_PRIO_BANDS];
> > +	u16 band2queue[TC_PRIO_MAX + 1];
> >   
> 
> Why is this still here? Its a 1:1 mapping.

Thought about this more last night and this morning.  As far as I can
tell, I still need this.  If the qdisc gets loaded with multiqueue
turned on, I can just use the value of band to assign
skb->queue_mapping.  But if the qdisc is loaded without multiqueue
support, then I need to assign a value of zero to queue_mapping, or not
assign it at all (it will be zero'd out before the call to ->enqueue()
in dev_queue_xmit()).  But I'd rather not have a conditional in the
hotpath checking if the qdisc is multiqueue; I'd rather have the array
to match the bands so I can just do an assignment.

What do you think?

Thanks,
-PJ
