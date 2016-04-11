From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFT 2/2] macb: kill PHY reset code
Date: Mon, 11 Apr 2016 04:28:02 +0200
Message-ID: <20160411022802.GB4307@lunn.ch>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2811962.eGX2i5RJbZ@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 09, 2016 at 01:25:03AM +0300, Sergei Shtylyov wrote:
> With  the 'phylib' now  being aware of  the "reset-gpios" PHY node property,
> there should be no need to frob the PHY reset in this  driver anymore...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
>  drivers/net/ethernet/cadence/macb.c |   17 -----------------
>  drivers/net/ethernet/cadence/macb.h |    1 -
>  2 files changed, 18 deletions(-)
> 
> Index: net-next/drivers/net/ethernet/cadence/macb.c
> ===================================================================
> --- net-next.orig/drivers/net/ethernet/cadence/macb.c
> +++ net-next/drivers/net/ethernet/cadence/macb.c
> @@ -2884,7 +2884,6 @@ static int macb_probe(struct platform_de
>  					      = macb_clk_init;
>  	int (*init)(struct platform_device *) = macb_init;
>  	struct device_node *np = pdev->dev.of_node;
> -	struct device_node *phy_node;
>  	const struct macb_config *macb_config = NULL;
>  	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
>  	unsigned int queue_mask, num_queues;
> @@ -2977,18 +2976,6 @@ static int macb_probe(struct platform_de
>  	else
>  		macb_get_hwaddr(bp);
>  
> -	/* Power up the PHY if there is a GPIO reset */
> -	phy_node =  of_get_next_available_child(np, NULL);
> -	if (phy_node) {
> -		int gpio = of_get_named_gpio(phy_node, "reset-gpios", 0);
> -
> -		if (gpio_is_valid(gpio)) {
> -			bp->reset_gpio = gpio_to_desc(gpio);
> -			gpiod_direction_output(bp->reset_gpio, 1);

Hi Sergei

The code you are deleting would of ignored the flags in the gpio
property, i.e. active low. The new code in the previous patch does
however take the flags into account. Did you check if there are any
device trees which have flags, which were never used, but are now
going to be used and thus break...

      Andrew
