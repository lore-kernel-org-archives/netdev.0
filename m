From: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: Re: [PATCH v5 04/19] net: e100: Replace PCI pool old API
Date: Thu, 9 Mar 2017 08:01:29 +0100
Message-ID: <20170309070129.GA13741@collabora.com>
References: <20170308161957.28941-1-romain.perier@collabora.com>
 <20170308161957.28941-5-romain.perier@collabora.com>
 <1489012825.3477.51.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489012825.3477.51.camel-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 08, 2017 at 02:40:25PM -0800, Jeff Kirsher wrote:
> On Wed, 2017-03-08 at 17:19 +0100, Romain Perier wrote:
> > The PCI pool API is deprecated. This commit replaces the PCI pool old
> > API by the appropriate function with the DMA pool API.
> > 
> > Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> > Acked-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> > Tested-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
> > ---
> >  drivers/net/ethernet/intel/e100.c | 12 ++++++------
> >  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> Acked-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> My only concern is:
> - what hardware did this get tested with?  Since this affects all e100
> parts, it would be hard to believe that all the affected hardware was
> used in testing.

This was tested by compilation only(See
https://lkml.org/lkml/2017/2/8/661). However this series removes macro
definitions of the old pci_pool interface and replace call sites by what
the macra was calling.

Here are the macros that this series removes from include/pci.h:

#define pci_pool dma_pool
#define pci_pool_create(name, pdev, size, align, allocation) \
	dma_pool_create(name, &pdev->dev, size, align, allocation)
#define pci_pool_destroy(pool) dma_pool_destroy(pool)
#define pci_pool_alloc(pool, flags, handle) dma_pool_alloc(pool, flags, handle)
#define pci_pool_zalloc(pool, flags, handle) \
	dma_pool_zalloc(pool, flags, handle)
#define pci_pool_free(pool, vaddr, addr) dma_pool_free(pool, vaddr, add

So this should not affect run time.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
