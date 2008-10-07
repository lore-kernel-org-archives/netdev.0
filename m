From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible regression in HTB
Date: Tue, 07 Oct 2008 14:03:08 +0200
Message-ID: <48EB4FFC.2020107@trash.net>
References: <20081007011551.GA28408@verge.net.au> <20081007045145.GA23883@verge.net.au> <20081007074435.GA2700@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43289 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbYJGMDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 08:03:18 -0400
In-Reply-To: <20081007074435.GA2700@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Oct 07, 2008 at 03:51:47PM +1100, Simon Horman wrote:
>> With the following patch (basically a reversal of ""pkt_sched: Always use
>> q->requeue in dev_requeue_skb()" forward ported to the current
>> net-next-2.6 tree (tcp: Respect SO_RCVLOWAT in tcp_poll()), I get some
>> rather nice numbers (IMHO).
>>
>> 10194: 666780666bits/s 666Mbits/s
>> 10197: 141154197bits/s 141Mbits/s
>> 10196: 141023090bits/s 141Mbits/s
>> -----------------------------------
>> total: 948957954bits/s 948Mbits/s
>>
>> I'm not sure what evil things this patch does to other aspects
>> of the qdisc code.
> 
> I'd like to establish this too. This patch was meant to remove some
> other problems possibly the simplest way. Maybe it's too simple.
> Anyway, it's kind of RFC, so the rest of the requeuing code is left
> unchanged, just for easy revoking like below. But first we should
> try to understand this more.

Shooting in the dark: I don't see how this change could affect
the bandwidth expect by introducing higher dequeue-latency due
using netif_schedule instead of qdisc_watchdog. Does anyone know
how device scheduling latencies compare to hrtimers?

