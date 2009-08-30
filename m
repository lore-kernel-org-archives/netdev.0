From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
Date: Sun, 30 Aug 2009 14:16:13 +0530
Message-ID: <OFCC154671.89248E03-ON65257622.002DFE20-65257622.00302D56@in.ibm.com>
References: <20090830062344.6380.16713.sendpatchset@localhost.localdomain> <4A9A223D.1060406@gmail.com> <4A9A2E79.5030808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:46786 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbZH3IqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:46:22 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7U8kM1g017012
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 14:16:22 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7U8kMQ42101442
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 14:16:22 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7U8kLOs001785
	for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 18:46:22 +1000
In-Reply-To: <4A9A2E79.5030808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Jarek Poplawski <jarkao2@gmail.com>
> >> pfifo_fast_enqueue has this check:
> >>         if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
> >>
> >> which allows each band to enqueue upto tx_queue_len skbs for a
> >> total of 3*tx_queue_len skbs. I am not sure if this was the
> >> intention of limiting in qdisc.
> >
> > Yes I noticed that and said to myself :
> > This was to let high priority packets have their own limit,
> > independent on fact that low priority packets filled their queue.
>
>
> Good point, but then logically it could be something like:
>   if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len / 3)
>
> Of course, there is a backward compatibility question, plus
> an sch_prio consistency question.

Jarek, what is the consistency problem?

Thanks,

- KK

