From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] sched: Fix resource limiting in pfifo_fast
Date: Sun, 30 Aug 2009 11:57:45 +0200
Message-ID: <20090830095745.GA5236@ami.dom.local>
References: <20090830062344.6380.16713.sendpatchset@localhost.localdomain>
 <4A9A223D.1060406@gmail.com>
 <4A9A2E79.5030808@gmail.com>
 <OFCC154671.89248E03-ON65257622.002DFE20-65257622.00302D56@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:33532 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763AbZH3J6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 05:58:13 -0400
Received: by fxm17 with SMTP id 17so2275131fxm.37
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 02:58:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OFCC154671.89248E03-ON65257622.002DFE20-65257622.00302D56@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 30, 2009 at 02:16:13PM +0530, Krishna Kumar2 wrote:
> > Jarek Poplawski <jarkao2@gmail.com>
> > >> pfifo_fast_enqueue has this check:
> > >>         if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
> > >>
> > >> which allows each band to enqueue upto tx_queue_len skbs for a
> > >> total of 3*tx_queue_len skbs. I am not sure if this was the
> > >> intention of limiting in qdisc.
> > >
> > > Yes I noticed that and said to myself :
> > > This was to let high priority packets have their own limit,
> > > independent on fact that low priority packets filled their queue.
> >
> >
> > Good point, but then logically it could be something like:
> >   if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len / 3)
> >
> > Of course, there is a backward compatibility question, plus
> > an sch_prio consistency question.
> 
> Jarek, what is the consistency problem?

Currently pfifo_fast and sch_prio behave similarly wrt. tx_queue_len,
don't they?

Jarek P.
