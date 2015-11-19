From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/3 v2] dl2k: Implement suspend
Date: Thu, 19 Nov 2015 01:55:56 +0100
Message-ID: <20151119005556.GA4882@electric-eye.fr.zoreil.com>
References: <1447882589-11264-1-git-send-email-linux@rainbow-software.org>
 <1447882589-11264-3-git-send-email-linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1447882589-11264-3-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ondrej Zary <linux@rainbow-software.org> :
[...]
> diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
> index 9e9baa0..28a96d3 100644
> --- a/drivers/net/ethernet/dlink/dl2k.c
> +++ b/drivers/net/ethernet/dlink/dl2k.c
[...]
> @@ -1824,11 +1831,55 @@ rio_remove1 (struct pci_dev *pdev)
>  	}
>  }
>  
> +#ifdef CONFIG_PM_SLEEP
> +static int rio_suspend(struct device *device)
> +{
> +	struct net_device *dev = dev_get_drvdata(device);
> +	struct netdev_private *np = netdev_priv(dev);
> +
> +	if (!netif_running(dev))
> +		return 0;
> +
> +	netif_device_detach(dev);
> +	del_timer_sync(&np->timer);
> +	rio_hw_stop(dev);
> +
> +	return 0;
> +}
> +
> +static int rio_resume(struct device *device)
> +{
> +	struct net_device *dev = dev_get_drvdata(device);
> +	struct netdev_private *np = netdev_priv(dev);
> +
> +	if (!netif_running(dev))
> +		return 0;
> +
> +	rio_reset_ring(np);

Almost. You should give the Rx/Tx descriptor 'status' word some love.

-- 
Ueimor
