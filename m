From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take13 1/3] kevent: Core files.
Date: Fri, 25 Aug 2006 11:20:08 +0400
Message-ID: <20060825072007.GE1816@2ka.mipt.ru>
References: <11563322941645@2ka.mipt.ru> <11563322971212@2ka.mipt.ru> <20060824200322.GA19533@infradead.org> <20060825054815.GC16504@2ka.mipt.ru> <20060824232024.0d230823.akpm@osdl.org> <20060825063238.GD16504@2ka.mipt.ru> <20060824235859.f8840fb2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751150AbWHYHU5@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060824235859.f8840fb2.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2006 at 11:58:59PM -0700, Andrew Morton (akpm@osdl.org) wrote:
> > > > kmalloc is really slow actually - it always shows somewhere on top 
> > > > in profiles and brings noticeble overhead
> > > 
> > > It shouldn't.  Please describe the workload and send the profiles.
> > 
> > epoll based trivial server (accept + sendfile for the same file, about
> > 4k), httperf with big amount of simulateneous connections. 3c59x NIC 
> > (with e1000 there were no ioreads and netif_rx).
> > __alloc_skb calls kmem_cache_alloc() and ___kmalloc().
> > 
> > 16158     1.3681  ioread16
> > 8073      0.6835  ioread32
> > 3485      0.2951  irq_entries_start
> > 3018      0.2555  _spin_lock
> > 2103      0.1781  tcp_v4_rcv
> > 1503      0.1273  sysenter_past_esp
> > 1492      0.1263  netif_rx
> > 1459      0.1235  skb_copy_bits
> > 1422      0.1204  _spin_lock_irqsave
> > 1145      0.0969  ip_route_input
> > 983       0.0832  kmem_cache_free
> > 964       0.0816  __alloc_skb
> > 926       0.0784  common_interrupt
> > 891       0.0754  __do_IRQ
> > 846       0.0716  _read_lock
> > 826       0.0699  __netif_rx_schedule
> > 806       0.0682  __kmalloc
> > 767       0.0649  do_tcp_sendpages
> > 747       0.0632  __copy_to_user_ll
> > 744       0.0630  pskb_expand_head
> > 
> 
> That doesn't look too bad.
> 
> What's that as a percentage of total user+system time?

With e1000 allocations take more time than actual TCP processing, so it
rised some suspicious for me (especially in bulk transfer).
Total time is about 7 times more than system one, user time is much less
than system one (about 20 times less, but test duration was not too
long, so it can vary).

I do not say it is bad, but it is noticeble and should be eliminated
if there are no requirements to have it.

-- 
	Evgeniy Polyakov
