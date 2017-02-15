From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: ethernet: cadence: Add fixed-link functionality
Date: Wed, 15 Feb 2017 23:12:49 +0100
Message-ID: <20170215221249.GB6096@lunn.ch>
References: <1487191445-5353-1-git-send-email-mdf@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        moritz.fischer@ettus.com,
        Nicolas Ferre <nicolas.ferre@microchip.com>
To: mdf@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1487191445-5353-1-git-send-email-mdf@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> @@ -3342,8 +3371,18 @@ static int macb_probe(struct platform_device *pdev)
>  		macb_get_hwaddr(bp);
>  
>  	/* Power up the PHY if there is a GPIO reset */
> -	phy_node =  of_get_next_available_child(np, NULL);
> -	if (phy_node) {
> +	phy_node = of_parse_phandle(np, "phy-handle", 0);
> +	if (!phy_node && of_phy_is_fixed_link(np)) {
> +		err = of_phy_register_fixed_link(np);

Hi Moritz

I don't see any calls to of_phy_deregister_fixed_link(), either in the
error path, or the remove code.

      Andrew
