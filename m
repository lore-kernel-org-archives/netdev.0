From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 08/17] net: Do not coalesce skbs belonging to
 PFMEMALLOC sockets
Date: Wed, 20 Jun 2012 15:51:52 +0200
Message-ID: <1340200312.4604.1008.camel@edumazet-glaptop>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
	 <1340192652-31658-9-git-send-email-mgorman@suse.de>
	 <1340193892.4604.865.camel@edumazet-glaptop>
	 <20120620133656.GH4011@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>,  Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>,  Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>,  Eric B Munson <emunson@mgebm.net>, Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
To: Mel Gorman <mgorman@suse.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20120620133656.GH4011@suse.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-20 at 14:36 +0100, Mel Gorman wrote:
> The intention was to avoid any coalescing in the input path due to avoid
> packets that "were held back due to TCP_CORK or attempt at coalescing
> tiny packet". I recognise that it is clumsy and will take the approach
> instead of having __tcp_push_pending_frames() use sk_gfp_atomic() in the
> output path.

But coalescing in input path needs no additional memory allocation, it
can actually free some memory.

And it avoids most of the time the infamous "tcp collapses" that needed
extra memory allocations to group tcp payload on single pages.


If you want tcp output path being safer, you should disable TSO/GSO
because some drivers have special handling for skbs that cannot be
mapped because of various hardware limitations.

(for example, tg3 and its tg3_tso_bug() or tigon3_dma_hwbug_workaround()
functions)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
