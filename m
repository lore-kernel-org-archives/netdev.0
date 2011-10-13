From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: more accurate skb truesize
Date: Thu, 13 Oct 2011 16:05:52 -0400 (EDT)
Message-ID: <20111013.160552.102035093902771886.davem@davemloft.net>
References: <1318525877.2393.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1318525990.2745.33.camel@bwh-desktop>
	<1318526934.2393.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	ak@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754083Ab1JMUF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 16:05:58 -0400
In-Reply-To: <1318526934.2393.49.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 19:28:54 +0200

> [PATCH V2 net-next] net: more accurate skb truesize
> 
> skb truesize currently accounts for sk_buff struct and part of skb head.
> kmalloc() roundings are also ignored.
> 
> Considering that skb_shared_info is larger than sk_buff, its time to
> take it into account for better memory accounting.
> 
> This patch introduces SKB_TRUESIZE(X) macro to centralize various
> assumptions into a single place.
> 
> At skb alloc phase, we put skb_shared_info struct at the exact end of
> skb head, to allow a better use of memory (lowering number of
> reallocations), since kmalloc() gives us power-of-two memory blocks.
> 
> Unless SLUB/SLUB debug is active, both skb->head and skb_shared_info are
> aligned to cache lines, as before.
> 
> Note: This patch might trigger performance regressions because of
> misconfigured protocol stacks, hitting per socket or global memory
> limits that were previously not reached. But its a necessary step for a
> more accurate memory accounting.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
