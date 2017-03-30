From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: in_irq_or_nmi() and RFC patch
Date: Thu, 30 Mar 2017 08:49:58 +0200
Message-ID: <20170330064958.uxih6ik5fkwvjqf6@hirez.programming.kicks-ass.net>
References: <20170327143947.4c237e54@redhat.com>
 <20170327141518.GB27285@bombadil.infradead.org>
 <20170327171500.4beef762@redhat.com>
 <20170327165817.GA28494@bombadil.infradead.org>
 <20170329081219.lto7t4fwmponokzh@hirez.programming.kicks-ass.net>
 <20170329105928.609bc581@redhat.com>
 <20170329091949.o2kozhhdnszgwvtn@hirez.programming.kicks-ass.net>
 <20170329181226.GA8256@bombadil.infradead.org>
 <20170329211144.3e362ac9@redhat.com>
 <20170329214441.08332799@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@infradead.org>, Pankaj Gupta <pagupta@redhat.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Saeed Mahameed <saeedm@mellanox.com>, linux-kernel@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20170329214441.08332799@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 09:44:41PM +0200, Jesper Dangaard Brouer wrote:
> @@ -2481,7 +2481,11 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>  
> -	if (in_interrupt()) {
> +	/*
> +	 * Exclude (hard) IRQ and NMI context from using the pcplists.
> +	 * But allow softirq context, via disabling BH.
> +	 */
> +	if (in_irq() || irqs_disabled()) {

Why do you need irqs_disabled() ? Also, your comment is stale, it still
refers to NMI context.

>  		__free_pages_ok(page, 0);
>  		return;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
