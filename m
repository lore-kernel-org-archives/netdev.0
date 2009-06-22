From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of	queueing an
 extra skb.
Date: Mon, 22 Jun 2009 19:11:35 +0530
Message-ID: <OF0CA43795.2C22F3BA-ON652575DD.004AA623-652575DD.004B3809@in.ibm.com>
References: <200905292346.04815.rusty@rustcorp.com.au> <200906181647.51045.rusty@rustcorp.com.au> <20090618073422.GA4087@gondor.apana.org.au> <200906191307.20360.rusty@rustcorp.com.au> <20090619043613.GA15163@gondor.apana.org.au> <OF1B3705AA.30E31D1D-ON652575DD.001F2CCD-652575DD.001FAE94@in.ibm.com> <20090622073417.GA21698@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([59.145.155.8]:39603 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbZFVNlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 09:41:46 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n5MCoKWR013143
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 18:20:20 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5MDfgIP2007114
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 19:11:42 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n5MDff4g010919
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 23:41:42 +1000
In-Reply-To: <20090622073417.GA21698@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Herbert. I thought lesser processing is required for those skbs
queued at
the driver (avoid qdisc_restart, and repeated calls to dequeue_skb where
skb from
the cached 'gso_skb' is checked if send'able and put back till the queue is
re-enabled)
and hence some gains is possible. So far, my testing of queueing in the
driver shows
good results for some test cases and bad results for others, hence my
question on
the topic as I am not able to figure out why some cases test worse.

- KK

Herbert Xu <herbert@gondor.apana.org.au> wrote on 06/22/2009 01:04:17 PM:

> Herbert Xu <herbert@gondor.apana.org.au>
> 06/22/2009 01:04 PM
>
> To
>
> Krishna Kumar2/India/IBM@IBMIN
>
> cc
>
> David Miller <davem@davemloft.net>, Matt Carlson <mcarlson@broadcom.com>,

> netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
> virtualization@lists.linux-foundation.org
>
> Subject
>
> Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of queueing an
extra skb.
>
> On Mon, Jun 22, 2009 at 11:16:03AM +0530, Krishna Kumar2 wrote:
> >
> > I was curious about "queueing it in the driver" part: why is this bad?
Do
> > you
> > anticipate any performance problems, or does it break QoS, or something
> > else I
> > have missed?
>
> Queueing it in the driver is bad because it is no different than
> queueing it at the upper layer, which is what will happen when
> you return TX_BUSY.
>
> Because we've ripped out the qdisc requeueing logic (which is
> horribly complex and only existed because of TX_BUSY), it means
> that higher priority packets cannot preempt a packet that is queued
> in this way.
>
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

