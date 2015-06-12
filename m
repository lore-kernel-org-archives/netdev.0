From: David Miller <davem@davemloft.net>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Date: Thu, 11 Jun 2015 17:34:19 -0700 (PDT)
Message-ID: <20150611.173419.1266197335293542334.davem@davemloft.net>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kernel-team@fb.com, clm@fb.com,
	linux-mm@kvack.org, dbavatar@gmail.com, edumazet@google.com
To: shli@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752216AbbFLAeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 20:34:21 -0400
In-Reply-To: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohua Li <shli@fb.com>
Date: Thu, 11 Jun 2015 16:50:48 -0700

> We saw excessive direct memory compaction triggered by skb_page_frag_refill.
> This causes performance issues and add latency. Commit 5640f7685831e0
> introduces the order-3 allocation. According to the changelog, the order-3
> allocation isn't a must-have but to improve performance. But direct memory
> compaction has high overhead. The benefit of order-3 allocation can't
> compensate the overhead of direct memory compaction.
> 
> This patch makes the order-3 page allocation atomic. If there is no memory
> pressure and memory isn't fragmented, the alloction will still success, so we
> don't sacrifice the order-3 benefit here. If the atomic allocation fails,
> direct memory compaction will not be triggered, skb_page_frag_refill will
> fallback to order-0 immediately, hence the direct memory compaction overhead is
> avoided. In the allocation failure case, kswapd is waken up and doing
> compaction, so chances are allocation could success next time.
> 
> alloc_skb_with_frags is the same.
> 
> The mellanox driver does similar thing, if this is accepted, we must fix
> the driver too.
> 
> V3: fix the same issue in alloc_skb_with_frags as pointed out by Eric
> V2: make the changelog clearer
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Chris Mason <clm@fb.com>
> Cc: Debabrata Banerjee <dbavatar@gmail.com>
> Signed-off-by: Shaohua Li <shli@fb.com>

Applied and queued up for -stable, thanks!
