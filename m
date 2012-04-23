From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive for
 TCP
Date: Mon, 23 Apr 2012 15:16:42 -0700
Message-ID: <4F95D4CA.7020005@hp.com>
References: <1335173934.3293.84.camel@edumazet-glaptop> <4F958DFD.7010207@hp.com> <1335201795.5205.35.camel@edumazet-glaptop> <20120423.160149.1515408777176168288.davem@davemloft.net> <1335213446.5205.65.camel@edumazet-glaptop>  <4F95C22D.3010908@hp.com> <1335216631.5205.71.camel@edumazet-glaptop>  <4F95CECF.6030901@hp.com> <1335218707.5205.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, ncardwell@google.com, maze@google.com,
	ycheng@google.com, ilpo.jarvinen@helsinki.fi
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:33286 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab2DWWQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 18:16:44 -0400
In-Reply-To: <1335218707.5205.87.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2012 03:05 PM, Eric Dumazet wrote:
> On Mon, 2012-04-23 at 14:51 -0700, Rick Jones wrote:
>> On 04/23/2012 02:30 PM, Eric Dumazet wrote:
>
>>> Yet, in the small time it takes to perform this operation, softirq can
>>> queue up to 300 packets coming from the other side.
>>
>> There is more to it than just queue-up 16 KB right?
>
> At full rate, we send 825.000 packets per second, and should receive
> 412.000 ACKS per second if receiver is standard TCP.
>
> The ACK are not smooth, because receiver also have a huge backlog issue
> and can send train of ACKS. (I have seen backlogs on receiver using more
> than 500 us to be  processed)
>
> If the copyin(16KB) from user to kernel takes some us (preempt,
> irqs...), its pretty easy to catch an ACK train in this window.

Is it at all possible to have the copies happen without the connection 
being locked?  If indeed it is possible to be held-off with the 
connection locked for the better part of 3/4 of a millisecond, just what 
will that do to 40 or 100 GbE?  If you've been seeing queues of 300 ACKs 
at 10 GbE that would be 3000 at 100 GbE, and assuming those are all in a 
2048 byte buffer thats 6MB just of ACKs.  I suppose 100GbE does mean 
non-trivial quantities of buffering anyway but that does still seem 
rather high.

rick
thank goodness for GRO's ACK stretching as an ACK avoidance heuristic I 
guess...
