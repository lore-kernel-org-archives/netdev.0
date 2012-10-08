From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] net: gro: selective flush of packets
Date: Mon, 08 Oct 2012 09:42:27 -0700
Message-ID: <50730273.4000408@hp.com>
References: <1348841041.5093.2477.camel@edumazet-glaptop> <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com> <1349448747.21172.113.camel@edumazet-glaptop> <20121006041155.GA27134@gondor.apana.org.au> <1349500126.4883.4.camel@edumazet-laptop> <20121006051407.GA27390@gondor.apana.org.au> <1349504541.21172.183.camel@edumazet-glaptop> <1349506825.21172.241.camel@edumazet-glaptop> <20121006105618.GA28591@gondor.apana.org.au> <1349546929.21172.1598.camel@edumazet-glaptop> <20121007003208.GA31839@gondor.apana.org.au> <1349587787.21172.1908.camel@edumazet-glaptop> <1349681967.21172.2866.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:43120 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823Ab2JHQm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 12:42:28 -0400
In-Reply-To: <1349681967.21172.2866.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2012 12:39 AM, Eric Dumazet wrote:
> On Sun, 2012-10-07 at 07:29 +0200, Eric Dumazet wrote:
>> 	On Sun, 2012-10-07 at 08:32 +0800, Herbert Xu wrote:
>
>>> Why don't we just always flush everything?
>>
>
>> This is what I tried first, but it lowered performance on several
>> typical workloads.
>>
>> Using this simple heuristic increases performance.
>>
>>
>
> By the way, one of the beauty of GRO is it helps under load to aggregate
> packets and reduce cpu load. People wanting very low latencies should
> probably not use GRO, and if they use it or not, receiving a full 64
> packets batch on a particular NIC makes latencies very unpredictable.
>
> So if we consumed all budget in a napi->poll() handler, its because we
> are under load and we dont really want to cancel GRO aggregation.

Is that actually absolute, or does it depend on GRO aggregation actually 
aggregating?  In your opening message you talked about how with though 
flows GRO is defeated but its overhead remains.

rick jones
