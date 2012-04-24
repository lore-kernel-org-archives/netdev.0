From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: speedup skb_splice_bits()
Date: Mon, 23 Apr 2012 23:02:05 -0400 (EDT)
Message-ID: <20120423.230205.418261556142199877.davem@davemloft.net>
References: <1335133576.2395.409.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, axboe@kernel.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756459Ab2DXDCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 23:02:13 -0400
In-Reply-To: <1335133576.2395.409.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Apr 2012 00:26:16 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 35f3d14db (pipe: add support for shrinking and growing pipes)
> added a slowdown for splice(socket -> pipe), as we might grow the spd
> used in skb_splice_bits() for each skb we process in splice() syscall.
> 
> Its not needed since skb lengths are capped. The default on-stack arrays
> are more than enough.
> 
> Use MAX_SKB_FRAGS instead of PIPE_DEF_BUFFERS to describe the reasonable
> limit per skb.
> 
> Add coalescing support to help splicing of GRO skbs built from linear
> skbs (linked into frag_list)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jens Axboe <axboe@kernel.dk>
> Cc: Tom Herbert <therbert@google.com>

Applied thanks.

I'm going to cleanup spd_fill_page() to return a bool.
