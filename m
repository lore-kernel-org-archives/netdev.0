From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 18:58:33 +0530
Message-ID: <OFCE4875A4.35085550-ON65257602.0046AC85-65257602.004A0678@in.ibm.com>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728071247.GA25611@gondor.apana.org.au> <20090728.125919.146001472.davem@davemloft.net> <20090729004428.GA765@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:37299 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755483AbZG2N25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2009 09:28:57 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id n6TDStpS002452
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 18:58:55 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6TDStZm974852
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 18:58:55 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n6TDStG7010089
	for <netdev@vger.kernel.org>; Wed, 29 Jul 2009 23:28:55 +1000
In-Reply-To: <20090729004428.GA765@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

Herbert Xu <herbert@gondor.apana.org.au> wrote on 07/29/2009 06:14:28 AM:
>
> Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
>
> On Tue, Jul 28, 2009 at 12:59:19PM -0700, David Miller wrote:
> >
> > The premise is that there'd be only one.  The qdisc lock.
> >
> > If the traffic is distributed, flow wise, the driver XMIT
> > lock would spread due to multiqueue.
>
> Suppose that we have a single large flow going through that has
> filled up the hardware queue and is now backlogged in the qdisc
> with qdisc_run on CPU A.   Now some other flow comes along and
> sends a packet on CPU B.
>
> So now CPU A and B will both be processing packets for the first
> flow causing loads of lock contention.
>
> But worse yet, we have introduced packet reordering.  So are you
> convinced now :)

I am probably misunderstanding you, but ... For different flows, is
this an issue? The same TCP connection will always use a single TXQ,
even if it runs on different CPUs since dev_pick_tx will select the
same txq, so how will reordering happen?

thanks,

- KK

(I am off tomorrow, but will be around for the next 3 hours)

