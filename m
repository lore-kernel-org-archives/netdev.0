From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Tue, 4 Aug 2009 12:15:13 +0530
Message-ID: <OF97F71814.07EC9697-ON65257608.00157164-65257608.00251952@in.ibm.com>
References: <20090728155055.2266.41649.sendpatchset@localhost.localdomain> <OF4A7A6701.1BD183E8-ON65257604.0024A9E1-65257606.0030A90D@in.ibm.com> <20090803.202935.221338243.davem@davemloft.net> <20090804034910.GA30871@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:57564 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932248AbZHDGpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 02:45:35 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id n746jTKU016331
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 12:15:29 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n746jTSI299054
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 12:15:29 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n746jSW4029824
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:45:28 +1000
In-Reply-To: <20090804034910.GA30871@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

Herbert Xu <herbert@gondor.apana.org.au> wrote on 08/04/2009 09:19:10 AM:
> On Mon, Aug 03, 2009 at 08:29:35PM -0700, David Miller wrote:
> >
> > Although PFIFO is not work-conserving, isn't it important to retain
> > ordering?  What if higher priority packets are in the queue when we
> > enqueue?  This new bypass will send the wrong packet, won't it?
>
> The bypass only kicks in if the queue length is zero.
>
> > I'm beginning to think, if we want to make the default case go as fast
> > as possible, we should just bypass everything altogether.  The entire
> > qdisc layer, all of it.
>
> Can you be more specific? AFAICS he's already bypassing the qdisc
> layer when it can be done safely.
>
> > Special casing something that essentially is unused, is in a way
> > a waste of time.  If this bypass could be applied to some of the
> > complicated qdiscs, then it'd be worthwhile, but just for the
> > default which effectively makes it do nothing, I don't see that
> > value in it.
>
> I agree with this sentiment.  Essentially what this bypass does
> is to eliminate the enqueue + qdisc_restart + dequeue in the
> cases where it is safe.  So its value is entirely dependent on
> the cost of the code that is eliminated, which may not be that
> large for the default qdisc.
>
> Krishna, those netperf tests that you performed, were they done
> with a single TX queue or multiple TX queues? If the latter did
> you tune the system so that each netperf was bound to a single
> core which had its own dedicated TX queue?

I ran on a Chelsio multiple TX queue card but I ran the default
netperf without any tuning (irqbalance, irq binding, cpu binding
of netperf/netserver, sysctl, etc). Do you want me to try with a
specific tuning also?

thanks,

- KK

