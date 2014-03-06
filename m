From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: davinci_emac: Replace devm_request_irq with
 request_irq
Date: Thu, 06 Mar 2014 16:57:36 -0500 (EST)
Message-ID: <20140306.165736.154818699714315258.davem@davemloft.net>
References: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon@ringle.org, f.fainelli@gmail.com,
	davinci-linux-open-source@linux.davincidsp.com,
	prabhakar.csengg@gmail.com, stable@vger.kernel.org
To: christian.riesch@omicron.at
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <2ec3bb89-89db-48e8-b360-369545a2546f@mary.at.omicron.at>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christian Riesch <christian.riesch@omicron.at>
Date: Wed, 5 Mar 2014 11:25:28 +0100

> @@ -1641,7 +1640,15 @@ static int emac_dev_open(struct net_device *ndev)
>  
>  rollback:
>  
> -	dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
> +	dev_err(emac_dev, "DaVinci EMAC: request_irq() failed");
> +
> +	for (q = k; k >= 0; k--) {
> +		for (m = i; m >= res->start; m--)
> +			free_irq(m, ndev);
> +		res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k-1);
> +		m = res->end;
> +	}

This final assignment in the loop of 'm' is unused?

The inner for() loop always started with "m = i;"
