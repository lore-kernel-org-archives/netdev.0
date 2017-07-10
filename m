From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] dpaa_eth: use correct device for DMA mapping API
Date: Mon, 10 Jul 2017 17:37:43 +0200
Message-ID: <CAMuHMdV+z-_s5XiQAJAz0nqPcUMZBVB3fEDmnOD9+iGVQ+635Q@mail.gmail.com>
References: <20170710151447.2814348-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Madalin Bucur <madalin.bucur@nxp.com>,
        Christoph Hellwig <hch@lst.de>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Robin Murphy <robin.murphy@arm.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Camelia Groza <camelia.groza@nxp.com>,
        Claudiu Manoil <claudiu.manoil@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170710151447.2814348-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Arnd,

On Mon, Jul 10, 2017 at 5:14 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> Geert Uytterhoeven ran into a build error without CONFIG_HAS_DMA,
> as a result of the driver calling set_dma_ops(). While we can
> fix the build error in the dma-mapping implementation, there is
> another problem in this driver:
>
> The configuration for the DMA is done by the platform code,
> looking up information about the system from the device tree.
> This copies the information only in an incomplete way, setting
> the dma_map_ops and forcing a specific mask, but ignoring all
> settings regarding IOMMU, coherence etc.
>
> A better way to avoid the problem is to only ever pass a device
> into the dma_mapping implementation that has been setup by the
> platform code. In this case, that is the parent device, so we
> can get that pointer at probe time. Fortunately, we already have
> a pointer in the device specific structure for that, so we only
> need to modify that.

Thank you, that looks like a much better solution!

> Fixes: fb52728a9294 ("dpaa_eth: reuse the dma_ops provided by the FMan MAC device")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

> Not tested, please see if this works before applying!

Indeed, please test first.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
