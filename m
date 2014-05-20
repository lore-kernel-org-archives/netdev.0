From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Subject: Re: [PATCH] net: davinci_emac: fix oops caused by uninitialized ndev->dev
Date: Tue, 20 May 2014 22:16:43 +0530
Message-ID: <CA+V-a8uPmzru5OmVcgBCxXeO2ZFKMJabB0Z0i8Kp_BdFGOK-Qw@mail.gmail.com>
References: <1400580697-24994-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Kevin Hilman <khilman@linaro.org>,
	Linux DaVinci Mailing List
	<davinci-linux-open-source@linux.davincidsp.com>,
	Linux netdev Mailing List <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:43388 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbaETQrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 12:47:14 -0400
Received: by mail-wi0-f179.google.com with SMTP id bs8so1308588wib.0
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 09:47:13 -0700 (PDT)
In-Reply-To: <1400580697-24994-1-git-send-email-nsekhar@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 20, 2014 at 3:41 PM, Sekhar Nori <nsekhar@ti.com> wrote:
> Commit e194312854edc22a2faf1931b3c0608fe20cb969 (drivers: net:
> davinci_cpdma: Convert kzalloc() to devm_kzalloc()) triggered
> a bug in emac_probe() wherein dev member of net_device is used
> for devres allocations even before it is initialized.
>
> This patch fixes that by using the struct device in platform_device
> instead.
>
> While at it, use &pdev->dev consistently for console messages instead
> of using ndev->dev for just one case and remove an unnecessary line
> continuation.
>
> Reported-by: Kevin Hilman <khilman@linaro.org>
> Helped-by: George Cherian <george.cherian@ti.com>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>

Tested-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Regards,
--Prabhakar Lad

> ---
> This patch fixes a bug in linux-next so it can wait for
> v3.16
>
>  drivers/net/ethernet/ti/davinci_emac.c |    6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
> index e76eae5..f32d730 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1865,7 +1865,6 @@ static int davinci_emac_probe(struct platform_device *pdev)
>         struct emac_priv *priv;
>         unsigned long hw_ram_addr;
>         struct emac_platform_data *pdata;
> -       struct device *emac_dev;
>         struct cpdma_params dma_params;
>         struct clk *emac_clk;
>         unsigned long emac_bus_frequency;
> @@ -1911,7 +1910,6 @@ static int davinci_emac_probe(struct platform_device *pdev)
>         priv->coal_intvl = 0;
>         priv->bus_freq_mhz = (u32)(emac_bus_frequency / 1000000);
>
> -       emac_dev = &ndev->dev;
>         /* Get EMAC platform data */
>         res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>         priv->emac_base_phys = res->start + pdata->ctrl_reg_offset;
> @@ -1930,7 +1928,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
>                 hw_ram_addr = (u32 __force)res->start + pdata->ctrl_ram_offset;
>
>         memset(&dma_params, 0, sizeof(dma_params));
> -       dma_params.dev                  = emac_dev;
> +       dma_params.dev                  = &pdev->dev;
>         dma_params.dmaregs              = priv->emac_base;
>         dma_params.rxthresh             = priv->emac_base + 0x120;
>         dma_params.rxfree               = priv->emac_base + 0x140;
> @@ -1994,7 +1992,7 @@ static int davinci_emac_probe(struct platform_device *pdev)
>
>
>         if (netif_msg_probe(priv)) {
> -               dev_notice(emac_dev, "DaVinci EMAC Probe found device "\
> +               dev_notice(&pdev->dev, "DaVinci EMAC Probe found device "
>                            "(regs: %p, irq: %d)\n",
>                            (void *)priv->emac_base_phys, ndev->irq);
>         }
> --
> 1.7.10.1
>
