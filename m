From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: do not enter direct reclaim from
 netlink_dump()
Date: Thu, 06 Oct 2016 20:53:55 -0400 (EDT)
Message-ID: <20161006.205355.1211690896171215733.davem@davemloft.net>
References: <1475694798.28155.215.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, gthelen@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43466 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756083AbcJGAx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 20:53:58 -0400
In-Reply-To: <1475694798.28155.215.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Oct 2016 04:13:18 +0900

> From: Eric Dumazet <edumazet@google.com>
> 
> Since linux-3.15, netlink_dump() can use up to 16384 bytes skb
> allocations.
> 
> Due to struct skb_shared_info ~320 bytes overhead, we end up using
> order-3 (on x86) page allocations, that might trigger direct reclaim and
> add stress.
> 
> The intent was really to attempt a large allocation but immediately
> fallback to a smaller one (order-1 on x86) in case of memory stress.
> 
> On recent kernels (linux-4.4), we can remove __GFP_DIRECT_RECLAIM to
> meet the goal. Old kernels would need to remove __GFP_WAIT
> 
> While we are at it, since we do an order-3 allocation, allow to use
> all the allocated bytes instead of 16384 to reduce syscalls during
> large dumps.
> 
> iproute2 already uses 32KB recvmsg() buffer sizes.
> 
> Alexei provided an initial patch downsizing to SKB_WITH_OVERHEAD(16384)
> 
> Fixes: 9063e21fb026 ("netlink: autosize skb lengthes")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Alexei Starovoitov <ast@kernel.org>
> Cc: Greg Thelen <gthelen@google.com>
> ---
> Note: This will apply to net tree when it has synced with Linus tree.

Applied.
