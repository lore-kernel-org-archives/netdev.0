From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: Re: [PATCH v2] WAN: Adding support for Infineon PEF2256 E1 chipset
 (FALC56)
Date: Fri, 1 Nov 2013 21:06:25 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1311012057090.2407@gmail.com>
References: <201311011501.rA1F1suj007279@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Grant Likely <grant.likely@linaro.org>,
	Krzysztof Halasa <khc@pm.waw.pl>, devicetree@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	jerome.chantelauze.ext@c-s.fr
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <201311011501.rA1F1suj007279@localhost.localdomain>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 1 Nov 2013, Christophe Leroy wrote:

> diff -urN a/drivers/net/wan/pef2256.c b/drivers/net/wan/pef2256.c
[..]
> +static int pef2256_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
> +	struct pef2256_dev_priv *priv = dev_to_hdlc(ndev)->priv;
> +
> +
> +	device_remove_file(priv->dev, &dev_attr_regs);
> +	device_remove_file(priv->dev, &dev_attr_Tx_TS);
> +	device_remove_file(priv->dev, &dev_attr_Rx_TS);
> +	device_remove_file(priv->dev, &dev_attr_mode);
> +
> +	unregister_hdlc_device(priv->netdev);
> +
> +	free_netdev(priv->netdev);
> +
> +	iounmap(priv->base_addr);
> +
> +	kfree(priv);
> +
> +	dev_set_drvdata(&pdev->dev, NULL);

dev_set_drvdata is not necessary. driver core clears the driver data to NULL
after device_release or on probe failure.

//govind
