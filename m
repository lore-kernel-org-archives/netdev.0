From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH/RFC] dma-mapping: Provide dummy set_dma_ops() for NO_DMA=y
Date: Mon, 10 Jul 2017 09:55:27 +0200
Message-ID: <CAK8P3a0ac_Bb5OCQFCwvo20NPdR_DdpFdRXVefF3XHjzkMkDNw@mail.gmail.com>
References: <1499628825-16260-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Christoph Hellwig <hch@lst.de>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        "David S . Miller" <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499628825-16260-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 9, 2017 at 9:33 PM, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> Adding a dummy for set_dma_ops() allows to compile (sub)drivers that
> don't actually use the DMA API, but propagate DMA ops configuration to a
> second driver that may or may not use the DMA API.  Of course the second
> driver does have to depend on HAS_DMA if it uses the DMA API.
>
> An example is commit 5567e989198b5a8d ("fsl/fman: propagate dma_ops").
>
> This allows to revert commit 85688d9adf685572 ("fsl/fman: add dependency
> on HAS_DMA").
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

I can't think of any correct use case for this new helper. IMO a device
driver should never set the dma_map_ops for any device, and we should
instead for the fman driver correctly.

       Arnd
