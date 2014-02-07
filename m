From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use __GFP_NORETRY for high order allocations
Date: Thu, 06 Feb 2014 22:29:32 -0800 (PST)
Message-ID: <20140206.222932.292588043950970246.davem@davemloft.net>
References: <1391712162.10160.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rientjes@google.com,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391712162.10160.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Feb 2014 10:42:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> sock_alloc_send_pskb() & sk_page_frag_refill()
> have a loop trying high order allocations to prepare
> skb with low number of fragments as this increases performance.
> 
> Problem is that under memory pressure/fragmentation, this can
> trigger OOM while the intent was only to try the high order
> allocations, then fallback to order-0 allocations.
> 
> We had various reports from unexpected regressions.
> 
> According to David, setting __GFP_NORETRY should be fine,
> as the asynchronous compaction is still enabled, and this
> will prevent OOM from kicking as in :
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: David Rientjes <rientjes@google.com>

Applied, do we want this for -stable?
