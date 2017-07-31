From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6] tcp: remove prequeue and header prediction
Date: Mon, 31 Jul 2017 14:38:07 -0700 (PDT)
Message-ID: <20170731.143807.1921676369334873438.davem@davemloft.net>
References: <20170730015723.25587-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751632AbdGaViI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 17:38:08 -0400
In-Reply-To: <20170730015723.25587-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 30 Jul 2017 03:57:17 +0200

> During a hallway discussion with Eric Dumazet at Netdev 1.2 in
> Tokyo some maybe-not-so-useful-anymore TCP stack features came up,
> among these header prediction and prequeueing.
> 
> In brief, TCP prequeue assumes a single-process-blocking-read design,
> which is not that common anymore. The most frequently used high-performance
> networking program that is an excellent fit for these features is netperf.
> 
> The idea behind prequeueing is to move part of tcp processing, including
> retransmit queue cleaning, to process context.
> 
> With (e)poll designs, prequeue is always skipped, so for such programs
> this is dead-code removal.
> 
> Header prediction is also less useful nowadays.
> For packet trains, GRO will do packet aggregation so we do not get the
> per-packet benefit that this had before GRO anymore.
> 
> Because of SACK, header prediction also will be ineffective once
> a connection suffers even light packet losses.
> 
> code removal aside, after this change processing always occurs in BH
> context, this allows to experiment e.g. with doing bulk freeing of
> skb heads when incoming ACKs clean packets from the retransmit queue.
> 
> There are no changes since the RFC, except in last patch (i missed
> another no-longer-used mib counter). I also edited a few commit messages.

Series applied, thanks a lot for doing this.
