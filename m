From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] GRO scalability
Date: Fri, 05 Oct 2012 12:35:43 -0700
Message-ID: <506F368F.3070403@hp.com>
References: <1348750130.5093.1227.camel@edumazet-glaptop> <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com> <1348769294.5093.1566.camel@edumazet-glaptop> <1348769990.5093.1584.camel@edumazet-glaptop> <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com> <1348841041.5093.2477.camel@edumazet-glaptop> <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com> <1349448747.21172.113.camel@edumazet-glaptop>  <506F23F6.1060704@hp.com> <1349463634.21172.152.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:42002 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab2JETfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 15:35:48 -0400
In-Reply-To: <1349463634.21172.152.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2012 12:00 PM, Eric Dumazet wrote:
> On Fri, 2012-10-05 at 11:16 -0700, Rick Jones wrote:
>
> Some remarks :
>
> 1) I use some 40Gbe links, thats probably why I try to improve things ;)

Path length before workarounds :)

> 2) benefit of GRO can be huge, and not only for the ACK avoidance
>     (other tricks could be done for ACK avoidance in the stack)

Just how much code path is there between NAPI and the socket?? (And I 
guess just how much combining are you hoping for?)

> 3) High speeds probably need multiqueue device, and each queue has its
> own GRO unit.
>
>    For example on a 40Gbe, 8 queues -> 5Gbps per queue (about 400k
> packets/sec)
>
> Lets say we allow no more than 1ms of delay in GRO,

OK.  That means we can ignore HPC and FSI because they wouldn't tolerate 
that kind of added delay anyway.  I'm not sure if that also then 
eliminates the networked storage types.

> this means we could have about 400 packets in the GRO queue (assuming
> 1500 bytes packets)

How many flows are you going to have entering via that queue?  And just 
how well "shuffled" will the segments of those flows be?  That is what 
it all comes down to right?  How many (active) flows and how well 
shuffled they are.  If the flows aren't well shuffled, you can get away 
with a smallish coalescing context.  If they are perfectly shuffled and 
greater in number than your delay allowance you get right back to square 
with all the overhead of GRO attempts with none of the benefit.

If the flow count is < 400 to allow a decent shot at a non-zero 
combining rate on well shuffled flows with the 400 packet limit, then 
that means each flow is >= 12.5 Mbit/s on average at 5 Gbit/s 
aggregated.  And I think you then get two segments per flow aggregated 
at a time.  Is that consistent with what you expect to be the 
characteristics of the flows entering via that queue?

rick jones
