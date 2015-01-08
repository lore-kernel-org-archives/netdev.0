From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH] net/at91_ether: prepare and unprepare clock
Date: Thu, 8 Jan 2015 09:13:18 +0100
Message-ID: <20150108091318.45ca2760@bbrezillon>
References: <1420671566-30784-1-git-send-email-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420671566-30784-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  7 Jan 2015 23:59:26 +0100
Alexandre Belloni <alexandre.belloni@free-electrons.com> wrote:

> The clock is enabled without being prepared, this leads to:
> 
> WARNING: CPU: 0 PID: 1 at drivers/clk/clk.c:889 __clk_enable+0x24/0xa8()
> 
> and a non working ethernet interface.
> 
> Use clk_prepare_enable() and clk_disable_unprepare() to handle the clock.
> 
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

Acked-by: Boris Brezillon <boris.brezillon@free-electrons.com>

> ---
>  drivers/net/ethernet/cadence/at91_ether.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index 55eb7f2af2b4..7ef55f5fa664 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -340,7 +340,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
>  		res = PTR_ERR(lp->pclk);
>  		goto err_free_dev;
>  	}
> -	clk_enable(lp->pclk);
> +	clk_prepare_enable(lp->pclk);
>  
>  	lp->hclk = ERR_PTR(-ENOENT);
>  	lp->tx_clk = ERR_PTR(-ENOENT);
> @@ -406,7 +406,7 @@ static int __init at91ether_probe(struct platform_device *pdev)
>  err_out_unregister_netdev:
>  	unregister_netdev(dev);
>  err_disable_clock:
> -	clk_disable(lp->pclk);
> +	clk_disable_unprepare(lp->pclk);
>  err_free_dev:
>  	free_netdev(dev);
>  	return res;
> @@ -424,7 +424,7 @@ static int at91ether_remove(struct platform_device *pdev)
>  	kfree(lp->mii_bus->irq);
>  	mdiobus_free(lp->mii_bus);
>  	unregister_netdev(dev);
> -	clk_disable(lp->pclk);
> +	clk_disable_unprepare(lp->pclk);
>  	free_netdev(dev);
>  
>  	return 0;
> @@ -440,7 +440,7 @@ static int at91ether_suspend(struct platform_device *pdev, pm_message_t mesg)
>  		netif_stop_queue(net_dev);
>  		netif_device_detach(net_dev);
>  
> -		clk_disable(lp->pclk);
> +		clk_disable_unprepare(lp->pclk);
>  	}
>  	return 0;
>  }
> @@ -451,7 +451,7 @@ static int at91ether_resume(struct platform_device *pdev)
>  	struct macb *lp = netdev_priv(net_dev);
>  
>  	if (netif_running(net_dev)) {
> -		clk_enable(lp->pclk);
> +		clk_prepare_enable(lp->pclk);
>  
>  		netif_device_attach(net_dev);
>  		netif_start_queue(net_dev);



-- 
Boris Brezillon, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
