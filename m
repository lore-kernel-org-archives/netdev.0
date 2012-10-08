From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] GRO scalability
Date: Mon, 08 Oct 2012 09:40:55 -0700
Message-ID: <50730217.6020206@hp.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop> <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com> <1348769294.5093.1566.camel@edumazet-glaptop> <1348769990.5093.1584.camel@edumazet-glaptop> <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com> <1348841041.5093.2477.camel@edumazet-glaptop> <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com> <1349448747.21172.113.camel@edumazet-glaptop>  <506F23F6.1060704@hp.com> <1349463634.21172.152.camel@edumazet-glaptop>  <506F368F.3070403@hp.com> <1349467578.21172.178.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:15613 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045Ab2JHQk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 12:40:59 -0400
In-Reply-To: <1349467578.21172.178.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2012 01:06 PM, Eric Dumazet wrote:
> On Fri, 2012-10-05 at 12:35 -0700, Rick Jones wrote:
>
>> Just how much code path is there between NAPI and the socket?? (And I
>> guess just how much combining are you hoping for?)
>>
>
> When GRO correctly works, you can save about 30% of cpu cycles, it
> depends...
>
> Doubling MAX_SKB_FRAGS (allowing 32+1 MSS per GRO skb instead of 16+1)
> gives an improvement as well...

OK, but how much of that 30% come from where?  Each coalesced segment is 
saving the cycles between NAPI and the socket.  Each avoided ACK is 
saving the cycles from TCP to the bottom of the driver and a (share of) 
transmit completion.


> I took this 1ms delay, but I never said it was a fixed value ;)
>
> Also remember one thing, this is the _max_ delay in case your napi
> handler is flooded. This almost never happen (tm)

We can still ignore the FSI types and probably the HPC types because 
they will insist on never happens (tm) :)


>
> Not sure what you mean by shuffle. We use a hash table to locate a flow,
> but we also have a LRU list to get the packets ordered by their entry in
> the 'GRO unit'.

Whe I say shuffle I mean something along the lines of interleave.  So, 
if we have four flows, 1-4, a perfect shuffle of their segments would be 
something like:

1 2 3 4 1 2 3 4 1 2 3 4

but not well shuffled might look like

1 1 3 2 3 2 4 4 4 1 3 2

rick
