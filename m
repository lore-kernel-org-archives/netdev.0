From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sched: convert queues to single-linked
 list
Date: Mon, 19 Sep 2016 01:47:44 -0400 (EDT)
Message-ID: <20160919.014744.226583519665969413.davem@davemloft.net>
References: <1474153054-9059-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755785AbcISFrq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:47:46 -0400
In-Reply-To: <1474153054-9059-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 18 Sep 2016 00:57:29 +0200

> During Netfilter Workshop 2016 Eric Dumazet pointed out that qdisc
> schedulers use doubly-linked lists, even though single-linked list
> would be enough.
> 
> The double-linked skb lists incur one extra write on enqueue/dequeue
> operations (to change ->prev pointer of next list elem).
> 
> This series converts qdiscs to single-linked version, listhead
> maintains pointers to first (for dequeue) and last skb (for enqueue).
> 
> Most qdiscs don't queue at all and instead use a leaf qdisc (typically
> pfifo_fast) so only a few schedulers needed changes.
> 
> I briefly tested netem and htb and they seemed fine.
> 
> UDP_STREAM netperf with 64 byte packets via veth+pfifo_fast shows
> a small (~2%) improvement.

Series applied, thanks Florian.
