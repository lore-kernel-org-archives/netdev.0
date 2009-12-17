From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 18:34:40 +0530
Message-ID: <OF3CFC3E46.A2924517-ON6525768F.00461897-6525768F.0046CFE9@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au> <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com> <20091217124254.GB8654@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([122.248.162.1]:42029 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbZLQMxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 07:53:31 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHCrTvJ007139
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 18:23:29 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHCrTR22343106
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 18:23:29 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHCrSJs016280
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 23:53:29 +1100
In-Reply-To: <20091217124254.GB8654@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote on 12/17/2009 06:12:54 PM:
>
> On Thu, Dec 17, 2009 at 05:57:15PM +0530, Krishna Kumar2 wrote:
> > the first resched. I also think the resched in requeue is probably
> > not required, since the device will call netif_tx_wake_queue anyway.
>
> IIRC there were mentioned some possibly broken drivers around these
> changes. So it would require a little bit of reviewing...

Yes, that was the reason I dropped that patch before submitting. I
was not sure of that optimization since I didn't check that all,
esp antique drivers, would resched correctly, but that was only a
minor optimization (avoiding one call of resched per stop).

However, the qdisc_restart/dev_dequeue path is clean since the stopped
txq case is handled very early, and no actual dequeue/requeue/resched
happens till the device restarts the txq.

Thanks,

- KK

