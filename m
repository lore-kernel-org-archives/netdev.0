From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH RFC 4/5] net: macb: Use devm_request_irq()
Date: Tue, 15 Oct 2013 09:46:24 +0200
Message-ID: <525CF2D0.2070504@atmel.com>
References: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com> <1381795140-10792-5-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381795140-10792-5-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/10/2013 01:58, Soren Brinkmann :
> Use the device managed interface to request the IRQ, simplifying error
> paths.
>
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>   drivers/net/ethernet/cadence/macb.c | 8 +++-----
>   1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 436aecc31732..603844b1d483 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1825,7 +1825,8 @@ static int __init macb_probe(struct platform_device *pdev)
>   	}
>
>   	dev->irq = platform_get_irq(pdev, 0);
> -	err = request_irq(dev->irq, macb_interrupt, 0, dev->name, dev);
> +	err = devm_request_irq(&pdev->dev, dev->irq, macb_interrupt, 0,
> +			dev->name, dev);
>   	if (err) {
>   		dev_err(&pdev->dev, "Unable to request IRQ %d (error %d)\n",
>   			dev->irq, err);
> @@ -1892,7 +1893,7 @@ static int __init macb_probe(struct platform_device *pdev)
>   	err = register_netdev(dev);
>   	if (err) {
>   		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> -		goto err_out_free_irq;
> +		goto err_out_disable_clocks;
>   	}
>
>   	err = macb_mii_init(bp);
> @@ -1915,8 +1916,6 @@ static int __init macb_probe(struct platform_device *pdev)
>
>   err_out_unregister_netdev:
>   	unregister_netdev(dev);
> -err_out_free_irq:
> -	free_irq(dev->irq, dev);
>   err_out_disable_clocks:
>   	clk_disable_unprepare(bp->hclk);
>   err_out_disable_pclk:
> @@ -1942,7 +1941,6 @@ static int __exit macb_remove(struct platform_device *pdev)
>   		kfree(bp->mii_bus->irq);
>   		mdiobus_free(bp->mii_bus);
>   		unregister_netdev(dev);
> -		free_irq(dev->irq, dev);
>   		clk_disable_unprepare(bp->hclk);
>   		clk_disable_unprepare(bp->pclk);
>   		free_netdev(dev);
>


-- 
Nicolas Ferre
