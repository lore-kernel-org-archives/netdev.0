From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 08/14] net: axienet: Removed checkpatch errors/warnings
Date: Wed, 12 Feb 2014 16:31:34 -0800
Message-ID: <1392251494.2214.11.camel@joe-AO722>
References: <cover.1392220536.git.michal.simek@xilinx.com>
	 <75b669c0a947effe74b291093abfa8c71f83736a.1392220536.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Srikanth Thokala <sthokal@xilinx.com>,
	Srikanth Thokala <srikanth.thokala@xilinx.com>,
	Michal Simek <monstr@monstr.eu>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <75b669c0a947effe74b291093abfa8c71f83736a.1392220536.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-02-12 at 16:55 +0100, Michal Simek wrote:
> From: Srikanth Thokala <srikanth.thokala@xilinx.com>

trivia:

> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c

> +			netdev_err(lp->ndev,
> +				"axienet_device_reset DMA reset timeout!\n");

could you please align multi-line arguments to the
appropriate open parenthesis?

			netdev_err(lp->ndev,
				   "axienet_device_reset DMA reset timeout!\n");

or maybe:

			netdev_err(lp->ndev, "%s: "DMA reset timeout!\n",
				   __func__);

> @@ -484,8 +484,8 @@ static void axienet_device_reset(struct net_device *ndev)
>  	}
> 
>  	if (axienet_dma_bd_init(ndev)) {
> -		dev_err(&ndev->dev, "axienet_device_reset descriptor "
> -			"allocation failed\n");
> +		netdev_err(ndev,
> +			"axienet_device_reset descriptor allocation failed\n");

etc, et al.

> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c b/drivers/net/ethernet/xilinx/xilinx_axienet_mdio.c
[]
> @@ -161,19 +161,19 @@ int axienet_mdio_setup(struct axienet_local *lp, struct device_node *np)
> 
>  	np1 = of_find_node_by_name(NULL, "cpu");
>  	if (!np1) {
> -		printk(KERN_WARNING "%s(): Could not find CPU device node.",
> -		       __func__);
> -		printk(KERN_WARNING "Setting MDIO clock divisor to "
> -		       "default %d\n", DEFAULT_CLOCK_DIVISOR);
> +		netdev_warn(lp->ndev, "Could not find CPU device node.");

missing trailing "\n" to terminate message.

> +		netdev_warn(lp->ndev,
> +			 "Could not find clock ethernet controller property.");

here too. (and alignment)
