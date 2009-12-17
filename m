From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 19:26:50 +0530
Message-ID: <OF30FBF3A7.542644C5-ON6525768F.004B51CE-6525768F.004B9690@in.ibm.com>
References: <20091217111219.9809.27432.sendpatchset@krkumar2.in.ibm.com> <20091217123153.GA31131@gondor.apana.org.au> <OF5A62ABA0.8A2B2426-ON6525768F.0044F439-6525768F.004611D6@in.ibm.com> <20091217134053.GA31964@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:57887 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935699AbZLQNpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 08:45:43 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHDjfF9001365
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:15:41 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHDjfQU3698940
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:15:41 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHDjddZ012500
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 00:45:41 +1100
In-Reply-To: <20091217134053.GA31964@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote on 12/17/2009 07:10:53 PM:

> > Since dequeue_skb finds the first skb that was cached in gso_skb,
> > handles the stopped txq and returns NULL for all subsequent skbs.
> > And qdisc_restart bails out immediately. Only the first skb will
> > get requeue'd, and no more skbs are taken out of the queue -
> > either dequeue or gso_skb, till the driver restarts the queue.
>
> But dev_requeue_skb immediately reschedules a new TX softirq
> so this will keep going until the hardware wakes up the queue.
>
> That is, we have an infinite loop consuming CPU that could otherwise
> be spent doing useful work, such as generating new packets.

Except that dev_requeue_skb is never called again till the device is
restarted and stopped. It is called once per stop, and after this,
dequeue_skb never returns a skb, hence no more requeue's.

Thanks,

- KK

