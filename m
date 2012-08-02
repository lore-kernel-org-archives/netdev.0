From: Paul Walmsley <paul@pwsan.com>
Subject: Re: [PATCH 1/2] net: davinci_mdio: enable and disable clock
Date: Thu, 2 Aug 2012 14:20:34 -0600 (MDT)
Message-ID: <alpine.DEB.2.00.1208021416550.18867@utopia.booyaka.com>
References: <1343936616-29318-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	koen@dominion.thruhere.net, mugunthanvnm@ti.com,
	linux-arm-kernel@lists.infradead.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from utopia.booyaka.com ([72.9.107.138]:37076 "EHLO
	utopia.booyaka.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104Ab2HBUUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 16:20:35 -0400
In-Reply-To: <1343936616-29318-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Thu, 2 Aug 2012, Daniel Mack wrote:

> Make the driver control the device clocks. Appearantly, the Davinci
> platform probes this driver with the clock all powered up, but on OMAP,
> this isn't the case.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>

> ---
>  drivers/net/ethernet/ti/davinci_mdio.c | 16 ++++++++++++++--
>  1 file changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index cd7ee20..b4b6015 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -332,6 +332,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
>  		goto bail_out;
>  	}
>  
> +	clk_enable(data->clk);
> +

This doesn't look right.  This clock should be enabled by the
pm_runtime_get_sync() call just above this.  It shouldn't be necessary
to enable it again unless something isn't right with the integration
data. Likewise the pm_runtime_put_sync() calls should be superfluous.

What hwmod data/device tree file are you using with this?


- Paul
