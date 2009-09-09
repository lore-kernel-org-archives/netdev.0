From: DDD <Dongdong.deng@windriver.com>
Subject: Re: [PATCH 1/1] netpoll: fix race between skb_queue_len and
	skb_dequeue
Date: Wed, 09 Sep 2009 22:27:15 +0800
Message-ID: <1252506435.16528.57.camel@dengdd-desktop>
References: <1252396189.16528.19.camel@dengdd-desktop>
	 <1252430825.7145.55.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:42412 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbZIIOOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 10:14:05 -0400
In-Reply-To: <1252430825.7145.55.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-09-08 at 12:27 -0500, Matt Mackall wrote:
> On Tue, 2009-09-08 at 15:49 +0800, DDD wrote:
> > This race will break the messages order.
> > 
> > Sequence of events in the problem case:
> > 
> > Assume there is one skb "A" in skb_queue and the next action of
> > netpoll_send_skb() is: sending out "B" skb.
> > The right order of messages should be: send A first, then send B.
> > 
> > But as following orders, it will send B first, then send A.
> 
> I would say no, the order of messages A and B queued on different CPUs
> is undefined. The only issue is that we can queue a message A on CPU0,
> then causally trigger a message on CPU1 B that arrives first. But bear
> in mind that the message A >>may never arrive<< because the message is
> about a lockup that kills processing of delayed work.
> 
> Generally speaking, queueing should be a last ditch effort. We should
> instead aim to deliver all messages immediately, even if they might be
> out of order. Because out of order is better than not arriving at all.

Ah, yes, out of order is better than not arriving at all. :-)

Especially it is based on UDP, so I don't think the order of messages is
important. :-)

I take back this patch.  

Thank you very much,
Dongdong
 
