From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/16] Replace smp_read_barrier_depends() with
 lockless_derefrence()
Date: Thu, 13 Nov 2014 12:07:01 -0800
Message-ID: <20141113200701.GP4460@linux.vnet.ibm.com>
References: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Cristian Stoica <cristian.stoica@freescale.com>,
        Horia Geanta <horia.geanta@freescale.com>,
        Ruchika Gupta <ruchika.gupta@freescale.com>,
        Michael Neuling <mikey@neuling.org>, Wolfram Sang <wsa@the-dreams.de>,
        "open list:CRYPTO API" <linux-crypto@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        Vinod Koul <vinod.koul@intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Kyungmin Park <kyungmin.park@samsung.com>,
        Manuel =?iso-8859-1?Q?Sch=F6lling?= <manuel.schoelling@gmx.de>,
        Dave Jiang <dave.jiang@intel.com>, Rashika <rashika.kheria@gmail.com>,
        "open list:DMA GENERIC OFFLO..." <dmaengine@vger.kernel.org>,
        "K. Y. Srinivasan"
To: Pranith Kumar <bobby.prani@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 13, 2014 at 02:24:06PM -0500, Pranith Kumar wrote:
> Recently lockless_dereference() was added which can be used in place of
> hard-coding smp_read_barrier_depends(). 
> 
> http://lkml.iu.edu/hypermail/linux/kernel/1410.3/04561.html
> 
> The following series tries to do this.
> 
> There are still some hard-coded locations which I was not sure how to replace
> with. I will send in separate patches/questions regarding them.

Thank you for taking this on!  Some questions and comments in response
to the individual patches.

							Thanx, Paul

> Pranith Kumar (16):
>   crypto: caam - Remove unnecessary smp_read_barrier_depends()
>   doc: memory-barriers.txt: Document use of lockless_dereference()
>   drivers: dma: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   dcache: Replace smp_read_barrier_depends() with lockless_dereference()
>   overlayfs: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   assoc_array: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   hyperv: Replace smp_read_barrier_depends() with lockless_dereference()
>   rcupdate: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   percpu: Replace smp_read_barrier_depends() with lockless_dereference()
>   perf: Replace smp_read_barrier_depends() with lockless_dereference()
>   seccomp: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   task_work: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   ksm: Replace smp_read_barrier_depends() with lockless_dereference()
>   slab: Replace smp_read_barrier_depends() with lockless_dereference()
>   netfilter: Replace smp_read_barrier_depends() with
>     lockless_dereference()
>   rxrpc: Replace smp_read_barrier_depends() with lockless_dereference()
> 
>  Documentation/memory-barriers.txt |  2 +-
>  drivers/crypto/caam/jr.c          |  3 ---
>  drivers/dma/ioat/dma_v2.c         |  3 +--
>  drivers/dma/ioat/dma_v3.c         |  3 +--
>  fs/dcache.c                       |  7 ++-----
>  fs/overlayfs/super.c              |  4 +---
>  include/linux/assoc_array_priv.h  | 11 +++++++----
>  include/linux/hyperv.h            |  9 ++++-----
>  include/linux/percpu-refcount.h   |  4 +---
>  include/linux/rcupdate.h          | 10 +++++-----
>  kernel/events/core.c              |  3 +--
>  kernel/events/uprobes.c           |  8 ++++----
>  kernel/seccomp.c                  |  7 +++----
>  kernel/task_work.c                |  3 +--
>  lib/assoc_array.c                 |  7 -------
>  mm/ksm.c                          |  7 +++----
>  mm/slab.h                         |  6 +++---
>  net/ipv4/netfilter/arp_tables.c   |  3 +--
>  net/ipv4/netfilter/ip_tables.c    |  3 +--
>  net/ipv6/netfilter/ip6_tables.c   |  3 +--
>  net/rxrpc/ar-ack.c                | 22 +++++++++-------------
>  security/keys/keyring.c           |  6 ------
>  22 files changed, 50 insertions(+), 84 deletions(-)
> 
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
