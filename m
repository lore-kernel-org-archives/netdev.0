From: Matthew Wilcox <willy@infradead.org>
Subject: Re: in_irq_or_nmi()
Date: Wed, 29 Mar 2017 11:12:26 -0700
Message-ID: <20170329181226.GA8256@bombadil.infradead.org>
References: <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
 <2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
 <20170327105514.1ed5b1ba@redhat.com>
 <20170327143947.4c237e54@redhat.com>
 <20170327141518.GB27285@bombadil.infradead.org>
 <20170327171500.4beef762@redhat.com>
 <20170327165817.GA28494@bombadil.infradead.org>
 <20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
 <20170329105928.609bc581@redhat.com>
 <20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Pankaj Gupta <pagupta@redhat.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 11:19:49AM +0200, Peter Zijlstra wrote:
> On Wed, Mar 29, 2017 at 10:59:28AM +0200, Jesper Dangaard Brouer wrote:
> > On Wed, 29 Mar 2017 10:12:19 +0200
> > Peter Zijlstra <peterz@infradead.org> wrote:
> > > No, that's horrible. Also, wth is this about? A memory allocator that
> > > needs in_nmi()? That sounds beyond broken.
> > 
> > It is the other way around. We want to exclude NMI and HARDIRQ from
> > using the per-cpu-pages (pcp) lists "order-0 cache" (they will
> > fall-through using the normal buddy allocator path).
> 
> Any in_nmi() code arriving at the allocator is broken. No need to fix
> the allocator.

That's demonstrably true.  You can't grab a spinlock in NMI code and
the first thing that happens if this in_irq_or_nmi() check fails is ...
        spin_lock_irqsave(&zone->lock, flags);
so this patch should just use in_irq().

(the concept of NMI code needing to allocate memory was blowing my mind
a little bit)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
