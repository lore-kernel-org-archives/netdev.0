From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Fri, 24 Jul 2009 16:01:15 +0530
Message-ID: <OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com>
References: <20090720074607.32463.23013.sendpatchset@localhost.localdomain> <20090724083006.GA5698@ff.dom.local> <20090724083749.GA23521@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, Jarek Poplawski <jarkao2@gmail.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:37181 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245AbZGXKcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 06:32:23 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id n6OAWLFF023646
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 16:02:21 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6OAWLHR3977310
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 16:02:21 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n6OAWKcR026413
	for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 20:32:20 +1000
In-Reply-To: <20090724083749.GA23521@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Herbert Xu <herbert@gondor.apana.org.au> wrote on 07/24/2009 02:07:49 PM:
> On Fri, Jul 24, 2009 at 08:30:06AM +0000, Jarek Poplawski wrote:
> > On 20-07-2009 09:46, Krishna Kumar wrote:
> > > From: Krishna Kumar <krkumar2@in.ibm.com>
> > >
> > > This patch avoids calling __qdisc_run if the queue is stopped.
> > > This also lets us remove the queue_stopped check in dequeue_skb
> > > and in qdisc_restart.
> >
> > It was designed wrt. multiqueue handling mainly, were such a check
> > isn't enough at this place.
>
> Well multiqueue TX was designed so that each CPU could have its
> own queue.  While this isn't always the case due to resource
> constraints and legacy applications, we should optimise for the
> case where each CPU is using its own TX queue.
>
> Of course we should still maintain correctness should the unexpected
> occur.
>
> So while I agree with Krishna's patch in principle, someone needs to
> make sure that it still does the right thing (i.e., it doesn't
> introduce potential starvation) if one CPU transmits to someone
> else's queue.

Hi Herbert,

Assuming many CPU's share a queue, only one can xmit due to the
RUNNING bit. And after RUNNING bit is taken, no other cpu can
stop the queue. So the only change in the behavior with this
patch is that the xmit is terminated a little earlier compared
to the current code. In case of a stopped queue, the patch helps
a little bit more by removing one stopped check for each queue'd
skb, including those skbs that are added later while the current
xmit session (qdisc_run) is ongoing.

I hope I have addressed your concern?

Thanks,

- KK

