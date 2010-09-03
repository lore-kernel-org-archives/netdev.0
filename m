From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] arm driver net macb
Date: Fri, 03 Sep 2010 15:41:25 +0200
Message-ID: <4C80FB05.1040706@atmel.com>
References: <4C800BAF.2090003@fnac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, jkosina@suse.cz,
	richard.cochran@omicron.at, jpirko@redhat.com, davem@davemloft.net
To: Paul Chavent <paul.chavent@fnac.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C800BAF.2090003@fnac.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02/09/2010 22:40, Paul Chavent :
> When listing processes on a system with SOFT/HARD_IRQ enabled, the name
> of the ethernet device is [irq/eth%d] (instead of [irq/eth0] for example).
> 
> This patch call the request_irq function after having initialized the
> name of the device.
> 
> Signed-off-by: Paul Chavent <paul.chavent@fnac.net>

[..]

> @@ -1214,13 +1281,23 @@
>  	err = register_netdev(dev);
>  	if (err) {
>  		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> -		goto err_out_free_irq;
> +		goto err_out_iounmap;
>  	}
>  
>  	if (macb_mii_init(bp) != 0) {
>  		goto err_out_unregister_netdev;
>  	}
>  
> +	dev->irq = platform_get_irq(pdev, 0);
> +	err = request_irq(dev->irq, macb_interrupt, IRQF_SAMPLE_RANDOM,
> +			  dev->name, dev);
> +	if (err) {
> +		printk(KERN_ERR
> +		       "%s: Unable to request IRQ %d (error %d)\n",
> +		       dev->name, dev->irq, err);
> +		goto err_out_unregister_netdev;
> +	}
> +

The string is modified in register_netdev() so why don't you deal 
with IRQ just after it? I would have placed the code snippet 
before macb_mii_init(): what do you think about this?

Best regards,
-- 
Nicolas Ferre
