From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH] net: davinci_emac:Fix translation logic for buffer descriptor
Date: Tue, 22 Mar 2011 13:11:13 +0300
Message-ID: <4D8875C1.9090004@mvista.com>
References: <1300788382-12658-1-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, davem@davemloft.net
To: Sriramakrishnan <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52765 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab1CVKMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 06:12:42 -0400
Received: by eyx24 with SMTP id 24so1751677eyx.19
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 03:12:40 -0700 (PDT)
In-Reply-To: <1300788382-12658-1-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 22-03-2011 13:06, Sriramakrishnan wrote:

> With recent changes to the driver(switch to new cpdma layer),
> the support for buffer descriptor address translation logic
> is broken. This affects platforms where the physical address of
> the descriptors as seen by the DMA engine is different from the
> physical address.

> Original Patch adding translation logic support:
> Commit: ad021ae8862209864dc8ebd3b7d3a55ce84b9ea2

> Signed-off-by: Sriramakrishnan <srk@ti.com>

    AFAIK, full name is required for signoff.

[...]

> diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
> index 082d6ea..df850fc 100644
> --- a/drivers/net/davinci_emac.c
> +++ b/drivers/net/davinci_emac.c
> @@ -1854,10 +1854,13 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
>   	dma_params.rxcp			= priv->emac_base + 0x660;
>   	dma_params.num_chan		= EMAC_MAX_TXRX_CHANNELS;
>   	dma_params.min_packet_size	= EMAC_DEF_MIN_ETHPKTSIZE;
> -	dma_params.desc_mem_phys	= hw_ram_addr;
> +	dma_params.desc_hw_addr		= hw_ram_addr;
>   	dma_params.desc_mem_size	= pdata->ctrl_ram_size;
>   	dma_params.desc_align		= 16;
>
> +	dma_params.desc_mem_phys = (pdata->no_bd_ram) ? 0 :

    Parens not needed here.

> +			((u32 __force)res->start + pdata->ctrl_ram_offset);

    Here either not necessary.

WBR, Sergei
