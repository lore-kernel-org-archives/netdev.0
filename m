From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfq: fix sfq stats handling
Date: Wed, 22 Dec 2010 11:39:35 -0800 (PST)
Message-ID: <20101222.113935.104046640.davem@davemloft.net>
References: <1292998499.4317.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751081Ab0LVTjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 14:39:07 -0500
In-Reply-To: <1292998499.4317.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 22 Dec 2010 07:14:59 +0100

> David, since this one fixes a bug, could you apply it before the pending
> SFQ patch (sch_sfq: allow big packets and be fair), I'll respin this one
> if necessary.
> 
> Thanks
> 
> [PATCH net-next-2.6] sfq: fix sfq class stats handling
> 
> sfq_walk() runs without qdisc lock. By the time it selects a non empty
> hash slot and sfq_dump_class_stats() is run (with lock held), slot might
> have been freed : We then access q->slots[SFQ_EMPTY_SLOT], out of
> bounds, and crash in slot_queue_walk()
> 
> On previous kernels, bug is here but out of bounds qs[SFQ_DEPTH] and
> allot[SFQ_DEPTH] are located in struct sfq_sched_data, so no illegal
> memory access happens, only possibly wrong data reported to user.
> 
> Also, slot_dequeue_tail() should make sure slot skb chain is correctly
> terminated, or sfq_dump_class_stats() can access freed skbs.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks.
