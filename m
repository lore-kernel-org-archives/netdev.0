From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Tue, 28 Jul 2009 17:54:48 +0530
Message-ID: <OF1266BD39.19AD585C-ON65257601.0042F2E4-65257601.0044308A@in.ibm.com>
References: <20090728024813.GA23992@gondor.apana.org.au> <20090727.212107.161491585.davem@davemloft.net> <20090728064319.GA5424@ff.dom.local> <20090728080354.GA25953@gondor.apana.org.au> <20090728083713.GB5424@ff.dom.local> <20090728084451.GA26299@gondor.apana.org.au> <20090728090229.GA6593@ff.dom.local> <20090728105329.GA27453@gondor.apana.org.au> <20090728112445.GB6593@ff.dom.local> <OFD1BE2D07.6BDFA87B-ON65257601.003F8F24-65257601.00406E62@in.ibm.com> <20090728114803.GA28001@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp09.in.ibm.com ([59.145.155.9]:35962 "EHLO
	e28smtp09.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbZG1M0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 08:26:49 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id n6SCPvB1017165
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 17:55:57 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n6SCQluG880792
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 17:56:48 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n6SCQl9x000605
	for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 22:26:47 +1000
In-Reply-To: <20090728114803.GA28001@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

Herbert Xu <herbert@gondor.apana.org.au> wrote on 07/28/2009 05:18:03 PM:
>
> Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
>
> On Tue, Jul 28, 2009 at 05:13:45PM +0530, Krishna Kumar2 wrote:
> > Sure, I will test and give my findings here. I guess setting the
> > flag in qdisc_create_dflt is the right place - that will cover pfifo,
> > bfifo and pfifo_fast (instead of attach_one_default_qdisc)?
>
> No I think you want to put it in attach_one_default_qdisc.
>
> Despite its name, qdisc_create_dflt is used by non-default qdiscs
> too.

Right, thanks for pointing this out.

BTW, I am testing another patch that does "Do not enqueue skb for
default qdisc if there are no skbs already on the queue" (to avoid
enqueue followed by immediate dequeue of the same skb for most xmit
operations on default qdiscs). I am planning to use the same flag
for both. I hope there is nothing wrong with that idea (excuse me
if this has already been discussed on the list but I haven't been
following for almost a year).

Thanks,

- KK

