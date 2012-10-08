From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: gro: selective flush of packets
Date: Mon, 08 Oct 2012 19:10:15 +0200
Message-ID: <1349716215.21172.3484.camel@edumazet-glaptop>
References: <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>
	 <20121006041155.GA27134@gondor.apana.org.au>
	 <1349500126.4883.4.camel@edumazet-laptop>
	 <20121006051407.GA27390@gondor.apana.org.au>
	 <1349504541.21172.183.camel@edumazet-glaptop>
	 <1349506825.21172.241.camel@edumazet-glaptop>
	 <20121006105618.GA28591@gondor.apana.org.au>
	 <1349546929.21172.1598.camel@edumazet-glaptop>
	 <20121007003208.GA31839@gondor.apana.org.au>
	 <1349587787.21172.1908.camel@edumazet-glaptop>
	 <1349681967.21172.2866.camel@edumazet-glaptop>  <50730273.4000408@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57707 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab2JHRKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 13:10:20 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2182676bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 10:10:19 -0700 (PDT)
In-Reply-To: <50730273.4000408@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 09:42 -0700, Rick Jones wrote:

> > By the way, one of the beauty of GRO is it helps under load to aggregate
> > packets and reduce cpu load. People wanting very low latencies should
> > probably not use GRO, and if they use it or not, receiving a full 64
> > packets batch on a particular NIC makes latencies very unpredictable.
> >
> > So if we consumed all budget in a napi->poll() handler, its because we
> > are under load and we dont really want to cancel GRO aggregation.
> 
> Is that actually absolute, or does it depend on GRO aggregation actually 
> aggregating?  In your opening message you talked about how with though 
> flows GRO is defeated but its overhead remains.
> 

Sorry, I dont understand the question.

We consume all budget when 64 packets are fetched from NIC.

This has nothing to do with GRO, but NAPI behavior.

Sure, if these packets are UDP messages and cross GRO stack for nothing,
its pure overhead.

Current situation is :

You receive a burst of packets, with one (or few) TCP message(s), and
other frames are UDP only.

This TCP message is held in GRO queue, and stay here as long as we dont
receive another packet for the same flow, or the burst ends.

Note that I dont really care of these few TCP messages right now,
but when/if we use a hash table and allow XXX packets in GRO stack,
things are different ;)
