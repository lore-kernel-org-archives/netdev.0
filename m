From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 29/51] DMA-API: ata: pata_octeon_cf: convert to use
	dma_coerce_mask_and_coherent()
Date: Wed, 30 Oct 2013 20:08:54 +0100
Message-ID: <CAMuHMdWqAL6MN5VJrpAPC1fq3QtRWZ3UUMG3+6W5vEKSEm5N9g@mail.gmail.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
	<E1VMmAk-0007iq-IU@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
	Linux MMC List <linux-mmc@vger.kernel.org>,
	Linux Fbdev development list <linux-fbdev@vger.kernel.org>,
	linux-nvme@lists.infradead.org,
	"linux-ide@vger.kernel.org" <linux-ide@vger.kernel.org>,
	driverdevel <devel@driverdev.osuosl.org>,
	linux-samsung-soc@vger.kernel.org, scsi <linux-scsi@vger.kernel.org>,
	e1000-devel@lists.sourceforge.net, Linux-Next <linux-next@vger.kernel.org>,
	b43-dev@lists.infradead.org,
	Linux Media Mailing List <linux-media@vger.kernel.org>,
	devicetree@vger.kernel.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	linux-tegra@vger.kernel.org,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.o
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <E1VMmAk-0007iq-IU@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces@lists.freedesktop.org
Errors-To: dri-devel-bounces@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 19, 2013 at 11:54 PM, Russell King
<rmk+kernel@arm.linux.org.uk> wrote:
> diff --git a/drivers/ata/pata_octeon_cf.c b/drivers/ata/pata_octeon_cf.c
> index c51bbb9..6231d43 100644
> --- a/drivers/ata/pata_octeon_cf.c
> +++ b/drivers/ata/pata_octeon_cf.c
> @@ -1014,8 +1014,9 @@ static int octeon_cf_probe(struct platform_device *pdev)
>         }
>         cf_port->c0 = ap->ioaddr.ctl_addr;
>
> -       pdev->dev.coherent_dma_mask = DMA_BIT_MASK(64);
> -       pdev->dev.dma_mask = &pdev->dev.coherent_dma_mask;
> +       rv = dma_coerce_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> +       if (rv)
> +               return ret;

return rv;

http://kisskb.ellerman.id.au/kisskb/buildresult/9959184/

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
