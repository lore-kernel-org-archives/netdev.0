From: Anton Ivanov <anton.ivanov@cambridgegreys.com>
Subject: net_sched strange in 4.11
Date: Mon, 8 May 2017 08:15:15 +0100
Message-ID: <66c5c2d3-65df-8506-6934-5628e709e229@cambridgegreys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:40886 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751255AbdEHHwb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 03:52:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I was revising some of my old work for UML to prepare it for submission 
and I noticed that skb->xmit_more does not seem to be set any more.

I traced the issue as far as net/sched/sched_generic.c

try_bulk_dequeue_skb() is never invoked (the drivers I am working on are 
dql enabled so that is not the problem).

More interestingly, if I put a breakpoint and debug output into 
dequeue_skb() around line 147 - right before the bulk: tag that skb 
there is always NULL. ???

Similarly, debug in pfifo_fast_dequeue shows only NULLs being dequeued. 
Again - ???

First and foremost, I apologize for the silly question, but how can this 
work at all? I see the skbs showing up at the driver level, why are 
NULLs being returned at qdisc dequeue and where do the skbs at the 
driver level come from?

Second, where should I look to fix it?

A.
