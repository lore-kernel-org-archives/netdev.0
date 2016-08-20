From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH -next] net: phy: Add missing of_node_put() in
 xgmiitorgmii_probe()
Date: Sat, 20 Aug 2016 19:36:05 +0200
Message-ID: <20160820173605.GE30224@lunn.ch>
References: <1471706815-27723-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:39721 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752886AbcHTRgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 13:36:09 -0400
Content-Disposition: inline
In-Reply-To: <1471706815-27723-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 20, 2016 at 03:26:55PM +0000, Wei Yongjun wrote:
> This node pointer is returned by of_parse_phandle() with
> refcount incremented in this function. of_node_put() on it
> before exitting this function.

Hi Wei

You are only releasing on the error path. What about the successful
path?

	Andrew

> 
> This is detected by Coccinelle semantic patch.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
> ---
>  drivers/net/phy/xilinx_gmii2rgmii.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/phy/xilinx_gmii2rgmii.c b/drivers/net/phy/xilinx_gmii2rgmii.c
> index cad6e19..4f05e5e 100644
> --- a/drivers/net/phy/xilinx_gmii2rgmii.c
> +++ b/drivers/net/phy/xilinx_gmii2rgmii.c
> @@ -75,6 +75,7 @@ int xgmiitorgmii_probe(struct mdio_device *mdiodev)
>  	priv->phy_dev = of_phy_find_device(phy_node);
>  	if (!priv->phy_dev) {
>  		dev_info(dev, "Couldn't find phydev\n");
> +		of_node_put(phy_node);
>  		return -EPROBE_DEFER;
>  	}
> 
