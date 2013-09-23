From: Vinod Koul <vinod.koul@intel.com>
Subject: Re: [alsa-devel] [PATCH 43/51] DMA-API: dma: edma.c: no need to
 explicitly initialize DMA masks
Date: Mon, 23 Sep 2013 15:55:33 +0530
Message-ID: <20130923102533.GI17188@intel.com>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMnRj-0007sg-1Z@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-ide@vger.kernel.org,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, e1000-devel@lists.sourceforge.net,
 b43-dev@lists.infradead.org, linux-media@vger.kernel.org,
 devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-tegra@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, linux-crypto@vger.kernel.org,
 uclinux-dist-devel@blackfin.uclinux.org, linuxppc-dev@lists.ozlabs.org
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <E1VMnRj-0007sg-1Z@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 20, 2013 at 12:15:39AM +0100, Russell King wrote:
> register_platform_device_full() can setup the DMA mask provided the
> appropriate member is set in struct platform_device_info.  So lets
> make that be the case.  This avoids a direct reference to the DMA
> masks by this driver.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Acked-by: Vinod Koul <vinod.koul@intel.com>

This also brings me question that should we force the driver to use the
dma_set_mask_and_coherent() API or they have below flexiblity too?

~Vinod

> ---
>  drivers/dma/edma.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/dma/edma.c b/drivers/dma/edma.c
> index ff50ff4..7f9fe30 100644
> --- a/drivers/dma/edma.c
> +++ b/drivers/dma/edma.c
> @@ -702,11 +702,13 @@ static struct platform_device *pdev0, *pdev1;
>  static const struct platform_device_info edma_dev_info0 = {
>  	.name = "edma-dma-engine",
>  	.id = 0,
> +	.dma_mask = DMA_BIT_MASK(32),
>  };
>  
>  static const struct platform_device_info edma_dev_info1 = {
>  	.name = "edma-dma-engine",
>  	.id = 1,
> +	.dma_mask = DMA_BIT_MASK(32),
>  };


>  
>  static int edma_init(void)
> @@ -720,8 +722,6 @@ static int edma_init(void)
>  			ret = PTR_ERR(pdev0);
>  			goto out;
>  		}
> -		pdev0->dev.dma_mask = &pdev0->dev.coherent_dma_mask;
> -		pdev0->dev.coherent_dma_mask = DMA_BIT_MASK(32);
>  	}
>  
>  	if (EDMA_CTLRS == 2) {
> @@ -731,8 +731,6 @@ static int edma_init(void)
>  			platform_device_unregister(pdev0);
>  			ret = PTR_ERR(pdev1);
>  		}
> -		pdev1->dev.dma_mask = &pdev1->dev.coherent_dma_mask;
> -		pdev1->dev.coherent_dma_mask = DMA_BIT_MASK(32);
>  	}
>  
>  out:
> -- 
> 1.7.4.4
> 
> _______________________________________________
> Alsa-devel mailing list
> Alsa-devel@alsa-project.org
> http://mailman.alsa-project.org/mailman/listinfo/alsa-devel

-- 
