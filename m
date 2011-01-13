From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 13 Jan 2011 07:39:57 -0800
Message-ID: <1294933197.4114.85.camel@Joe-Laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-01-13 at 19:49 +0800, Po-Yu Chuang wrote:
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
> 
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII.  This driver has been working on some ARM/NDS32 SoC including
> Faraday A320 and Andes AG101.

A couple of trivial comments not already mentioned by others.

> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
[]
> @@ -2014,6 +2014,15 @@ config BCM63XX_ENET
>  	  This driver supports the ethernet MACs in the Broadcom 63xx
>  	  MIPS chipset family (BCM63XX).
>  
> +config FTMAC100
> +	tristate "Faraday FTMAC100 10/100 Ethernet support"
> +	depends on ARM
> +	select MII
> +	help
> +	  This driver supports the FTMAC100 Ethernet controller from
> +	  Faraday. It is used on Faraday A320, Andes AG101, AG101P
> +	  and some other ARM/NDS32 SoC's.
> +

ARM specific net drivers are for now in drivers/net/arm/
Perhaps it's better to locate these files there?

> diff --git a/drivers/net/ftmac100.c b/drivers/net/ftmac100.c
[]
> +static int ftmac100_rx_packet_error(struct ftmac100 *priv,
> +		struct ftmac100_rxdes *rxdes)
> +{
> +	struct device *dev = &priv->netdev->dev;
> +	int error = 0;
> +
> +	if (unlikely(ftmac100_rxdes_rx_error(rxdes))) {
> +		if (printk_ratelimit())
> +			dev_info(dev, "rx err\n");

There are many printk_ratelimit() tests.

It's better to use net_ratelimit() or a local ratelimit_state
so there's less possible suppression of other subsystem
messages.
