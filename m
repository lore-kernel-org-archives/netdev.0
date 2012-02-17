From: John Crispin <blogic@openwrt.org>
Subject: Re: [PATCH 4/6] NET: MIPS: lantiq: convert etop to managed gpio
Date: Fri, 17 Feb 2012 13:24:16 +0100
Message-ID: <4F3E46F0.5010701@openwrt.org>
References: <1329474771-20874-1-git-send-email-blogic@openwrt.org> <1329474771-20874-5-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52527 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866Ab2BQMYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 07:24:25 -0500
In-Reply-To: <1329474771-20874-5-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>  	ltq_gbit_w32_mask(0, PX_CTL_DMDIO, LTQ_GBIT_P0_CTL);
> @@ -873,6 +870,12 @@ ltq_etop_probe(struct platform_device *pdev)
>  			err = -ENOMEM;
>  			goto err_out;
>  		}
> +		if (ltq_gpio_request(&pdev->dev, 42, 2, 1, "MDIO") ||
> +				ltq_gpio_request(&pdev->dev, 43, 2, 1, "MDC")) {
> +			dev_err(&pdev->dev, "failed to request MDIO gpios\n");
> +			err = -ENOMEM;
-EBUSY should go here instead of -ENOMEM


> +			goto err_out;
> +		}
>  	}
>  
>  	dev = alloc_etherdev_mq(sizeof(struct ltq_etop_priv), 4);
