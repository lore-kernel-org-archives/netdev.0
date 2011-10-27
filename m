From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: add calxeda xgmac ethernet driver
Date: Wed, 26 Oct 2011 20:35:52 -0700
Message-ID: <1319686552.21924.47.camel@Joe-Laptop>
References: <1319684206-473-1-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Rob Herring <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:34757 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752451Ab1J0Dfx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 23:35:53 -0400
In-Reply-To: <1319684206-473-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-26 at 21:56 -0500, Rob Herring wrote:
> Add support for the XGMAC 10Gb ethernet device in the Calxeda Highbank
> SOC.

Hi Rob, just trivia:

Most of the logging dev_<level> messages
should be netdev_<level>

Adding #define pr_fmt KBUILD_MODNAME ": " fmt
before any #include would be useful to prefix
the module name to pr_<level> output.

> +static int desc_get_tx_status(struct xgmac_extra_stats *x,
> +			      struct xgmac_dma_desc *p, void __iomem *ioaddr)
> +{
[]
> +	if (status & TXDESC_JABBER_TIMEOUT) {
> +		pr_debug("\tjabber_timeout error\n");
> +		x->tx_jabber++;
> +	}

Adding pr_fmt, the output would become:
calxeda_xgmac: 	jabber_timeout error

[]
> +static void xgmac_rx_refill(struct xgmac_priv *priv)

> +		dev_dbg(priv->device, "rx ring: head %d, tail %d\n",
> +			priv->rx_head, priv->rx_tail);

	netdev_dbg(priv->dev, "rx ring: head %d, tail %d\n",
		   etc...)
[]
> +static int xgmac_open(struct net_device *dev)
> +{
[]
> +	if (!is_valid_ether_addr(dev->dev_addr)) {
> +		random_ether_addr(dev->dev_addr);
> +		dev_dbg(priv->device, "generated random MAC address %pM\n",
> +			dev->dev_addr);

		netdev_dbg(dev, "generated random MAC address %pM\n",
			   dev->dev_addr);

etc...

cheers, Joe
