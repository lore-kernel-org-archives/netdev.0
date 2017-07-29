From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next 0/6] tcp: remove prequeue and header prediction
Date: Sat, 29 Jul 2017 15:22:44 -0700 (PDT)
Message-ID: <20170729.152244.43564304647234406.davem@davemloft.net>
References: <20170727233117.29695-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
        edumazet@google.com, soheil@google.com, weiwan@google.com,
        brakmo@fb.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42866 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752355AbdG2WWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 18:22:45 -0400
In-Reply-To: <20170727233117.29695-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 28 Jul 2017 01:31:11 +0200

> This RFC removes tcp prequeueing and header prediction support.
> 
> After a hallway discussion with Eric Dumazet some
> maybe-not-so-useful-anymore TCP stack features came up, HP and
> Prequeue among these.
> 
> So this RFC proposes to axe both.
> 
> In brief, TCP prequeue assumes a single-process-blocking-read
> design, which is not that common anymore, and the most frequently
> used high-performance networking program that does this is netperf :)
> 
> With more commong (e)poll designs, prequeue doesn't work.
> 
> The idea behind prequeueing isn't so bad in itself; it moves
> part of tcp processing -- including ack processing (including
> retransmit queue processing) into process context.
> However, removing it would not just avoid some code, for most
> programs it elimiates dead code.
> 
> As processing then always occurs in BH context, it would allow us
> to experiment e.g. with bulk-freeing of skb heads when a packet acks
> data on the retransmit queue.
> 
> Header prediction is also less useful nowadays.
> For packet trains, GRO will aggregate packets so we do not get
> a per-packet benefit.
> Header prediction will also break down with light packet loss due to SACK.
> 
> So, In short: What do others think?

I have no objections to any of this. :)
