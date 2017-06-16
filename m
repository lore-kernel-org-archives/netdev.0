From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 25/44] arm: implement ->mapping_error
Date: Fri, 16 Jun 2017 10:43:28 +0200
Message-ID: <20170616084328.GC10582@lst.de>
References: <20170608132609.32662-1-hch@lst.de> <20170608132609.32662-26-hch@lst.de> <20170608144313.GL4902@n2100.armlinux.org.uk>
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
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-ia64-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608144313.GL4902@n2100.armlinux.org.uk>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 03:43:14PM +0100, Russell King - ARM Linux wrote:
> BOn Thu, Jun 08, 2017 at 03:25:50PM +0200, Christoph Hellwig wrote:
> > +static int dmabounce_mapping_error(struct device *dev, dma_addr_t dma_addr)
> > +{
> > +	if (dev->archdata.dmabounce)
> > +		return 0;
> 
> I'm not convinced that we need this check here:
> 
>         dev->archdata.dmabounce = device_info;
>         set_dma_ops(dev, &dmabounce_ops);
> 
> There shouldn't be any chance of dev->archdata.dmabounce being NULL if
> the dmabounce_ops has been set as the current device DMA ops.  So I
> think that test can be killed.

Ok, I'll fix it up.
