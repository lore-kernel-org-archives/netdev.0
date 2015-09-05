From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Handle postive return codes in phy_connect
Date: Sat, 5 Sep 2015 21:18:40 +0200
Message-ID: <20150905191840.GC6040@lunn.ch>
References: <1441476089-22108-1-git-send-email-mwelling@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Michael Welling <mwelling@ieee.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46786 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753031AbbIET0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Sep 2015 15:26:24 -0400
Content-Disposition: inline
In-Reply-To: <1441476089-22108-1-git-send-email-mwelling@ieee.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 05, 2015 at 01:01:29PM -0500, Michael Welling wrote:
> The function phy_connect_direct can possibly return a positive
> return code. Using ERR_PTR with a positive value can lead to
> deferencing of an invalid pointer.

Is this the correct fix? Would it not be better to find where the
positive return code is from and fix that?

	 Andrew

> Signed-off-by: Michael Welling <mwelling@ieee.org>
> ---
>  drivers/net/phy/phy_device.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index c0f2111..a7e14a6 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -477,6 +477,9 @@ struct phy_device *phy_connect(struct net_device *dev, const char *bus_id,
>  	phydev = to_phy_device(d);
>  
>  	rc = phy_connect_direct(dev, phydev, handler, interface);
> +	if (rc > 0)
> +		return ERR_PTR(-ENODEV);
> +
>  	if (rc)
>  		return ERR_PTR(rc);
>  
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
