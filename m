From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with	vhost-net
Date: Thu, 17 Dec 2009 19:40:32 +0530
Message-ID: <OF36B67DA5.E6556DDD-ON6525768F.00498720-6525768F.004CD7A8@in.ibm.com>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <OF32B8811E.870B9515-ON6525768F.003F57BD-6525768F.0040952B@in.ibm.com> <20091217131708.GC8654@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:45175 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbZLQN7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 08:59:24 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBHDxL3X006196
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:29:21 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBHDxL1W3239984
	for <netdev@vger.kernel.org>; Thu, 17 Dec 2009 19:29:21 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBHDxKLd008471
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 00:59:21 +1100
In-Reply-To: <20091217131708.GC8654@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote on 12/17/2009 06:47:09 PM:

> On Thu, Dec 17, 2009 at 05:26:37PM +0530, Krishna Kumar2 wrote:
> > Sridhar is seeing 280K requeue's, and that probably implies device
> > was stopped and wrongly restarted immediately. So the next xmit in
> > the kernel found the txq is not stopped and called the xmit handler,
> > get a BUSY, requeue, and so on. That would also explain why his BW
> > drops so much - all false starts (besides 19% of all skbs being
> > requeued). I assume that each time when we check:
> >
> >       if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
> >             ret = dev_hard_start_xmit(skb, dev, txq);
> > it passes the check and dev_hard_start_xmit is called wrongly.
> >
> > #Requeues: 283575
> > #total skbs: 1469482
> > Percentage requeued: 19.29%
>
> I haven't followed this thread, so I'm not sure what are you looking
> for, but can't these requeues/drops mean some hardware limits were
> reached? I wonder why there are compared linux-2.6.32 vs. 2.6.31.6
> with different test conditions (avg. packet sizes: 16800 vs. 64400)?

Hi Jarek,

That is a good point. I am not sure why the avg packet sizes are
so different in the bstats. Did GSO change in these two versions?

I took the numbers from Sridhar's mail before the NAPI patch. I think
having 280K requeue's in 1 min means that the driver is waking up the
queue when it should not. The NAPI patch fixes that, but he still
reported seeing requeue's.

thanks,

- KK

