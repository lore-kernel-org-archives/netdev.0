From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] GRO scalability
Date: Mon, 08 Oct 2012 11:21:19 -0700
Message-ID: <5073199F.6040408@hp.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop> <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com> <1348769294.5093.1566.camel@edumazet-glaptop> <1348769990.5093.1584.camel@edumazet-glaptop> <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com> <1348841041.5093.2477.camel@edumazet-glaptop> <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com> <1349448747.21172.113.camel@edumazet-glaptop>  <506F23F6.1060704@hp.com> <1349463634.21172.152.camel@edumazet-glaptop>  <506F368F.3070403@hp.com> <1349467578.21172.178.camel@edumazet-glaptop>  <50730217.6020206@hp.com> <1349715561.21172.3463.camel@edumazet-glaptop>  <5073121B.2070300@hp.com> <1349718955.21172.3534.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:2395 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752102Ab2JHSVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 14:21:23 -0400
In-Reply-To: <1349718955.21172.3534.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/2012 10:55 AM, Eric Dumazet wrote:
> On Mon, 2012-10-08 at 10:49 -0700, Rick Jones wrote:
>
>> So, with my term shuffle better defined, let's circle back to your
>> proposal to try to GRO-service a very much larger group of flows, with a
>> "flush queued packets older than N packets" heuristic as part of the
>> latency minimization.  If N were 2 there - half the number of flows, the
>> "perfect" shuffle" doesn't get aggregated at all right? N would have to
>> be 4 or the number of concurrent flows.   What I'm trying to get at is
>> just to how many concurrent flows you are trying to get GRO to scale,
>> and whether at that level you have asymptotically approached having a
>> hash/retained state that is, basically, a duplicate of what is happening
>> in TCP.
>>
>
> I didnt said "flush queued packets older than N packets" but instead
> suggested to use a time limit, eventually a sysctl.

Did I then mis-interpret:

> 2) Use a LRU list to eventually be able to 'flush' too old packets,
>    even if the napi never completes. Each time we process a new packet,
>    being a GRO candidate or not, we increment a napi->sequence, and we
>    flush the oldest packet in gro_lru_list if its own sequence is too
>    old.

in your initial RFC email?  Because I took that as flushing a given 
packet if N packets have come through since that packet was queued to 
await coalescing.

rick
