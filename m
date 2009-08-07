From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Fri, 7 Aug 2009 08:26:04 +0530
Message-ID: <OF41857EFE.FD813620-ON6525760B.000F5D7C-6525760B.00101EC7@in.ibm.com>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain> <20090806.134126.58668200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:44821 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756341AbZHGC6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 22:58:45 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id n772wi9v032209
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 08:28:44 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n772wi4M1892516
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 08:28:44 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n772whD8016046
	for <netdev@vger.kernel.org>; Fri, 7 Aug 2009 08:28:44 +0530
In-Reply-To: <20090806.134126.58668200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

David Miller <davem@davemloft.net> wrote on 08/07/2009 02:11:26 AM:

> >  static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc
*q)
> >  {
> >     q->gso_skb = skb;
> >     q->qstats.requeues++;
> > +   q->q.qlen++;   /* it's still part of the queue */
> >     __netif_schedule(q);
> >
> >     return 0;
>
> I'm dubious about this new qlen accounting scheme, does it handle
> the non-bypass case properly?  Can you explain how it works
> exactly?

Adding one to qlen will handle non-bypass correctly. On the next
non-bypass (or a bypass) xmit, dequeue_skb will remove gso_skb and
decrement the counter. If no more xmits are done, qdisc_reset will
also fix it. I got this idea by extending one of Jarek's patches:

commit 61c9eaf90081cbe6dc4f389e0056bff76eca19ec
Author: Jarek Poplawski <jarkao2@gmail.com>
Date:   Wed Nov 5 16:02:34 2008 -0800
    pkt_sched: Fix qdisc len in qdisc_peek_dequeued()

Thanks,

- KK

