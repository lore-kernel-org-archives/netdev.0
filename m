From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
Date: Thu, 21 Jun 2012 18:43:29 +0200
Message-ID: <20120621164329.GA6195@breakpoint.cc>
References: <1340192652-31658-1-git-send-email-mgorman@suse.de>
 <1340192652-31658-11-git-send-email-mgorman@suse.de>
 <20120621163029.GB6045@breakpoint.cc>
 <1340296719.4604.5984.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>,
	Mel Gorman <mgorman@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric B Munson <emunson@mgebm.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1340296719.4604.5984.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

> > This is mostly used by nic to refil their RX skb pool. You add the
> > __GFP_MEMALLOC to the allocation to rise the change of a successfull refill
> > for the swap case.
> > A few drivers use build_skb() to create the skb. __netdev_alloc_skb()
> > shouldn't be affected since the allocation happens with GFP_ATOMIC. Looking at
> > TG3 it uses build_skb() and get_pages() / kmalloc(). Shouldn't this be some
> > considered?
> 
> Please look at net-next, this was changed recently.
> 
> In fact most RX allocations are done using netdev_alloc_frag(), because
> its called from __netdev_alloc_skb()

Argh, this is what I meant more or less. I got the flag magic wrong so I assumed
that this is only called without GFP_ATOMIC but it is not. Thanks for the
hint.

> So tg3 is not anymore the exception, but the norm.

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
