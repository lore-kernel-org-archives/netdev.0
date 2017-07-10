From: Robin Murphy <robin.murphy@arm.com>
Subject: Re: [PATCH/RFC] dma-mapping: Provide dummy set_dma_ops() for NO_DMA=y
Date: Mon, 10 Jul 2017 16:31:54 +0100
Message-ID: <6323dd71-0bd3-5823-3837-da84dfba46fe@arm.com>
References: <1499628825-16260-1-git-send-email-geert@linux-m68k.org>
 <20170710145641.GC7971@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Marek Szyprowski <m.szyprowski@samsung.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        "David S . Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>,
        Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170710145641.GC7971@lst.de>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/17 15:56, Christoph Hellwig wrote:
> This looks reasonable to me, I'd be happy to pick it up.  Can you send
> it as a series with the reverts?

The fact remains that the FSL driver is still doing the wrong thing
though - set_dma_ops(dev1, get_dma_ops(dev2)) is just a hack which
happens to work on platforms which don't keep other arch-internal DMA
info as well. I did start writing a patch somewhere to fix this thing to
actually do proper DMA configuration (originally in the context of not
abusing arch_setup_dma_ops()), but Arnd's fix is probably simpler.

I don't think it makes an awful lot of sense for code without a DMA API
dependency to be calling set_dma_ops() - AFAIU the only reason it's
available to drivers at all is for particular RDMA cases which know that
their "DMA" is actually done by CPU threads, and want to optimise for that.

Robin.
