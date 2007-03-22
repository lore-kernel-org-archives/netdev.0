From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] netem: avoid excessive requeues
Date: Thu, 22 Mar 2007 14:08:16 -0700 (PDT)
Message-ID: <20070322.140816.104054993.davem@davemloft.net>
References: <20070321174231.890361963@linux-foundation.org>
	<20070321174422.767901837@linux-foundation.org>
	<4602E9CB.8030500@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbXCVVIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 17:08:16 -0400
In-Reply-To: <4602E9CB.8030500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 22 Mar 2007 21:40:43 +0100

> > --- net-2.6.22.orig/net/sched/sch_netem.c
> > +++ net-2.6.22/net/sched/sch_netem.c
> > @@ -272,6 +272,10 @@ static struct sk_buff *netem_dequeue(str
> >  	struct netem_sched_data *q = qdisc_priv(sch);
> >  	struct sk_buff *skb;
> >  
> > +	smp_mb();
> > +	if (sch->flags & TCQ_F_THROTTLED)
> > +		return NULL;
> > +
> 
> 
> Perhaps we should put this in qdisc_restart, other qdiscs have the
> same problem.

Agreed, patches welcome :)
