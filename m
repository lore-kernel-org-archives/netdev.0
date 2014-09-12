From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/macb: Add hardware revision information during
 probe
Date: Fri, 12 Sep 2014 18:20:52 -0400 (EDT)
Message-ID: <20140912.182052.1655150437302824636.davem@davemloft.net>
References: <1410447096-29980-1-git-send-email-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	voice.shen@atmel.com
To: alexandre.belloni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410447096-29980-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Thu, 11 Sep 2014 16:51:36 +0200

> From: Bo Shen <voice.shen@atmel.com>
> 
> Signed-off-by: Bo Shen <voice.shen@atmel.com>
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index ca5d7798b265..a3b35c146d9c 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2241,6 +2241,7 @@ static int __init macb_probe(struct platform_device *pdev)
>  
>  	netif_carrier_off(dev);
>  
> +	netdev_info(dev, "Cadence rev 0x%08x\n", macb_readl(bp, MID));
>  	netdev_info(dev, "Cadence %s at 0x%08lx irq %d (%pM)\n",
>  		    macb_is_gem(bp) ? "GEM" : "MACB", dev->base_addr,
>  		    dev->irq, dev->dev_addr);

This is really sloppy.  The "Cadence %s at ..." is what announces the device,
therefore it's out of context to print out the device revision beforehand.

Why don't you just add it to the existing printout instead?
