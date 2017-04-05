From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: in_irq_or_nmi() and RFC patch
Date: Wed, 5 Apr 2017 09:53:52 +0100
Message-ID: <20170405085352.52rb3k34omndei63@techsingularity.net>
References: <20170327165817.GA28494@bombadil.infradead.org>
 <20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
 <20170329105928.609bc581@redhat.com>
 <20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
 <20170329181226.GA8256@bombadil.infradead.org>
 <20170329211144.3e362ac9@redhat.com>
 <20170329214441.08332799@redhat.com>
 <20170330130436.l37yazbxlrkvcbf3@techsingularity.net>
 <20170330170708.084bd16c@redhat.com>
 <20170403120506.y7z3cncyi65bcgen@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Matthew Wilcox <willy@infradead.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Pankaj Gupta <pagupta@redhat.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170403120506.y7z3cncyi65bcgen@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 03, 2017 at 01:05:06PM +0100, Mel Gorman wrote:
> > Started performance benchmarking:
> >  163 cycles = current state
> >  183 cycles = with BH disable + in_irq
> >  218 cycles = with BH disable + in_irq + irqs_disabled
> > 
> > Thus, the performance numbers unfortunately looks bad, once we add the
> > test for irqs_disabled().  The slowdown by replacing preempt_disable
> > with BH-disable is still a win (we saved 29 cycles before, and loose
> > 20, I was expecting regression to be only 10 cycles).
> > 
> 
> This surprises me because I'm not seeing the same severity of problems
> with irqs_disabled. Your path is slower than what's currently upstream
> but it's still far better than a revert. The softirq column in the
> middle is your patch versus a full revert which is the last columnm
> 

Any objection to resending the local_bh_enable/disable patch with the
in_interrupt() check based on this data or should I post the revert and
go back to the drawing board?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
