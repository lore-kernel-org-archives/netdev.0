From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Date: Mon, 11 Apr 2016 09:53:54 -0700
Message-ID: <1460393634.6473.560.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	 <20160407161715.52635cac@redhat.com> <20160411085819.GE21128@suse.de>
	 <20160411142639.1c5e520b@redhat.com>
	 <20160411130826.GB32073@techsingularity.net>
	 <20160411181907.15fdb8b9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mel Gorman <mgorman@techsingularity.net>, James Bottomley
	 <James.Bottomley@HansenPartnership.com>, "netdev@vger.kernel.org"
	 <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>,
	lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Mel Gorman
	 <mgorman@suse.de>, Tom Herbert <tom@herbertland.com>,
	lsf-pc@lists.linux-foundation.org, Alexei Starovoitov
	 <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160411181907.15fdb8b9@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-11 at 18:19 +0200, Jesper Dangaard Brouer wrote:

> Drivers also do tricks where they fallback to smaller order pages. E.g.
> lookup function mlx4_alloc_pages().  I've tried to simulate that
> function here:
> https://github.com/netoptimizer/prototype-kernel/blob/91d323fc53/kernel/mm/bench/page_bench01.c#L69

We use order-0 pages on mlx4 at Google, as order-3 pages are very
dangerous for some kind of attacks...

An out of order TCP packet can hold an order-3 pages, while claiming to
use 1.5 KBvia skb->truesize.

order-0 only pages allow the page recycle trick used by Intel driver,
and we hardly see any page allocations in typical workloads.

While order-3 pages are 'nice' for friendly datacenter kind of traffic,
they also are a higher risk on hosts connected to the wild Internet.

Maybe I should upstream this patch ;)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
