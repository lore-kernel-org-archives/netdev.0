From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] af_unix: reduce high order page allocations
Date: Tue, 03 Apr 2012 16:43:52 -0400 (EDT)
Message-ID: <20120403.164352.1515177068122185516.davem@davemloft.net>
References: <20120402.215911.1929019308299701014.davem@davemloft.net>
	<1333419304.18626.5.camel@edumazet-glaptop>
	<1333466908.18626.274.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684Ab2DCUnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 16:43:55 -0400
In-Reply-To: <1333466908.18626.274.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Apr 2012 17:28:28 +0200

> unix_dgram_sendmsg() currently builds linear skbs, and this can stress
> page allocator with high order page allocations. When memory gets
> fragmented, this can eventually fail.
> 
> We can try to use order-2 allocations for skb head (SKB_MAX_ALLOC) plus
> up to 16 page fragments to lower pressure on buddy allocator.
> 
> This patch has no effect on messages of less than 16064 bytes.
> (on 64bit arches with PAGE_SIZE=4096)
> 
> For bigger messages (from 16065 to 81600 bytes), this patch brings
> reliability at the expense of performance penalty because of extra pages
> allocations.
> 
> netperf -t DG_STREAM -T 0,2 -- -m 16064 -s 200000
> ->4086040 Messages / 10s
> 
> netperf -t DG_STREAM -T 0,2 -- -m 16068 -s 200000
> ->3901747 Messages / 10s
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> v2: use SKB_MAX_ALLOC instead of SKB_MAX_ORDER(0, 0) to not slow down
>     applications using up to 16000 bytes messages.

Looks good, applied to net-next, thanks Eric!
