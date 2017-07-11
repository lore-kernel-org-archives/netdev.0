From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH/RFC] dma-mapping: Provide dummy set_dma_ops() for
        NO_DMA=y
Date: Tue, 11 Jul 2017 16:02:59 +0200
Message-ID: <20170711140259.GA12334@lst.de>
References: <1499628825-16260-1-git-send-email-geert@linux-m68k.org> <20170710145641.GC7971@lst.de> <6323dd71-0bd3-5823-3837-da84dfba46fe@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Robin Murphy <robin.murphy@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6323dd71-0bd3-5823-3837-da84dfba46fe@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 10, 2017 at 04:31:54PM +0100, Robin Murphy wrote:
> On 10/07/17 15:56, Christoph Hellwig wrote:
> > This looks reasonable to me, I'd be happy to pick it up.  Can you send
> > it as a series with the reverts?
> 
> The fact remains that the FSL driver is still doing the wrong thing
> though - set_dma_ops(dev1, get_dma_ops(dev2)) is just a hack which
> happens to work on platforms which don't keep other arch-internal DMA
> info as well. I did start writing a patch somewhere to fix this thing to
> actually do proper DMA configuration (originally in the context of not
> abusing arch_setup_dma_ops()), but Arnd's fix is probably simpler.
> 
> I don't think it makes an awful lot of sense for code without a DMA API
> dependency to be calling set_dma_ops() - AFAIU the only reason it's
> available to drivers at all is for particular RDMA cases which know that
> their "DMA" is actually done by CPU threads, and want to optimise for that.

Even that code should require the DMA API.  So yes, maybe we should
fix the code to propagate the settings by another means.
