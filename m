From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 18:38:36 +0530
Message-ID: <OF414D73BF.FAE11563-ON65257602.0047D9A4-65257602.00483330@in.ibm.com>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au> <20090729110436.GA5490@ff.dom.local> <20090729111134.GA6478@gondor.apana.org.au> <20090729112614.GB5490@ff.dom.local> <20090729123041.GA7440@gondor.apana.org.au> <20090729124734.GD5490@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([59.145.155.8]:51110 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650AbZG2NJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 09:09:38 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id n6TD6Yiu015676
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 18:36:34 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6TD9Zuf970776
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 18:39:35 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n6TD9YlS024749
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 23:09:35 +1000
In-Reply-To: <20090729124734.GD5490@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek,

Jarek Poplawski <jarkao2@gmail.com> wrote on 07/29/2009 06:17:34 PM:

> Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
>
> On Wed, Jul 29, 2009 at 08:30:41PM +0800, Herbert Xu wrote:
> > On Wed, Jul 29, 2009 at 11:26:14AM +0000, Jarek Poplawski wrote:
> > >
> > > If you mean the tx lock there should be no "real" contention: only
> > > one waiter max. qdisc lock's contention might be higher, but it's
> > > use (during contention) better: enqueue + dequeue together instead
> > > of doing it separately.
> >
> > Hmm, you will have contention if they're both transmitting a
> > single flow which must always go into a single physical queue.
> >
> > So you'll have two CPUs doing the work of a single CPU, with one
> > of them always spinning on the TX lock.
>
> Hmm.. I'd call it a little waiting, but OK let's call it contention;-)
> When tx is faster than queue operations there could be no contention
> at all. I'm not saying I must be right: IMHO it's only worth trying.

My expectation is that tx would be much longer than a few lines of
queue operation....

thanks,

- KK

