From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator order-0 optimizations merged
Date: Wed, 22 Mar 2017 23:40:04 +0000
Message-ID: <20170322234004.kffsce4owewgpqnm@techsingularity.net>
References: <58b48b1f.F/jo2/WiSxvvGm/z%akpm@linux-foundation.org>
 <20170301144845.783f8cad@redhat.com>
 <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Saeed Mahameed <saeedm@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 22, 2017 at 07:39:17PM +0200, Tariq Toukan wrote:
> > > > This modification may slow allocations from IRQ context slightly
> > > > but the
> > > > main gain from the per-cpu allocator is that it scales better for
> > > > allocations from multiple contexts.  There is an implicit
> > > > assumption that
> > > > intensive allocations from IRQ contexts on multiple CPUs from a single
> > > > NUMA node are rare
> Hi Mel, Jesper, and all.
> 
> This assumption contradicts regular multi-stream traffic that is naturally
> handled
> over close numa cores.  I compared iperf TCP multistream (8 streams)
> over CX4 (mlx5 driver) with kernels v4.10 (before this series) vs
> kernel v4.11-rc1 (with this series).
> I disabled the page-cache (recycle) mechanism to stress the page allocator,
> and see a drastic degradation in BW, from 47.5 G in v4.10 to 31.4 G in
> v4.11-rc1 (34% drop).
> I noticed queued_spin_lock_slowpath occupies 62.87% of CPU time.

Can you get the stack trace for the spin lock slowpath to confirm it's
from IRQ context?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
