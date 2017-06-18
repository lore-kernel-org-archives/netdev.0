From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 42/44] powerpc/cell: use the dma_supported method for ops
 switching
Date: Sun, 18 Jun 2017 00:13:44 -0700
Message-ID: <20170618071344.GB18526@infradead.org>
References: <20170616181059.19206-1-hch@lst.de>
 <20170616181059.19206-43-hch@lst.de>
 <1497732627.2897.128.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-hexagon-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1497732627.2897.128.camel@kernel.crashing.org>
Sender: linux-hexagon-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 18, 2017 at 06:50:27AM +1000, Benjamin Herrenschmidt wrote:
> What is your rationale here ? (I have missed patch 0 it seems).

Less code duplication, more modular dma_map_ops insteance.

> dma_supported() was supposed to be pretty much a "const" function
> simply informing whether a given setup is possible. Having it perform
> an actual switch of ops seems to be pushing it...

dma_supported() is already gone from the public DMA API as it doesn't
make sense to be called separately from set_dma_mask.  It will be
entirely gone in the next series after this one.

> What if a driver wants to test various dma masks and then pick one ?
> 
> Where does the API documents that if a driver calls dma_supported() it
> then *must* set the corresponding mask and use that ?

Where is the API document for _any_ of the dma routines? (A: work in
progress by me, but I need to clean up the mess of arch hooks before
it can make any sense)

> I don't like a function that is a "boolean query" like this one to have
> such a major side effect.
> 
> >From an API standpoint, dma_set_mask() is when the mask is established,
> and thus when the ops switch should happen.

And that's exactly what happens at the driver API level.  It just turns
out the dma_capable method is they way better place to actually
implement it, as the ->set_dma_mask method requires lots of code
duplication while not offering any actual benefit over ->dma_capable.
And because of that it's gone after this series.

In theory we could rename ->dma_capable now, but it would require a
_lot_ of churn.  Give me another merge window or two and we should
be down to be about 2 handful of dma_map_ops instance, at which point
we could do all this gratious renaming a lot more easily :)
