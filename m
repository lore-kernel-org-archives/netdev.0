From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 1/3] net: dsa: Use devm_ prefixed allocations
Date: Wed, 30 Sep 2015 23:28:33 +0200
Message-ID: <20150930212833.GF20219@lunn.ch>
References: <560B9B74.3080905@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38182 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbbI3V2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 17:28:37 -0400
Content-Disposition: inline
In-Reply-To: <560B9B74.3080905@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil

I tested all three patches on a board with three switches.

1) Normal boot
2) Bad address set for the 3rd switch so that it was not found, so
   causing the probe to fail.

No regressions observed. 

Tested-by: Andrew Lunn <andrew@lunn.ch>

As Florian said, this is going in the right direction for modular DSA,
but still quite a way to go...

    Thanks
	Andrew

On Wed, Sep 30, 2015 at 10:21:08AM +0200, Neil Armstrong wrote:
> To simplify and prevent memory leakage when unbinding, use
> the devm_ memory allocation calls.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  net/dsa/dsa.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index c59fa5d..98f94c2 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -305,7 +305,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
>  	if (ret < 0)
>  		goto out;
> 
> -	ds->slave_mii_bus = mdiobus_alloc();
> +	ds->slave_mii_bus = devm_mdiobus_alloc(parent);
>  	if (ds->slave_mii_bus == NULL) {
>  		ret = -ENOMEM;
>  		goto out;
> @@ -400,7 +400,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  	/*
>  	 * Allocate and initialise switch state.
>  	 */
> -	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
> +	ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);
>  	if (ds == NULL)
>  		return ERR_PTR(-ENOMEM);
> 
> @@ -883,7 +883,7 @@ static int dsa_probe(struct platform_device *pdev)
>  		goto out;
>  	}
> 
> -	dst = kzalloc(sizeof(*dst), GFP_KERNEL);
> +	dst = devm_kzalloc(&pdev->dev, sizeof(*dst), GFP_KERNEL);
>  	if (dst == NULL) {
>  		dev_put(dev);
>  		ret = -ENOMEM;
> -- 
> 1.9.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
