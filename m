From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Thu, 1 Jun 2017 14:23:50 +0200
Message-ID: <20170601122350.GA9282@lunn.ch>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60972 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdFAMXw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 08:23:52 -0400
Content-Disposition: inline
In-Reply-To: <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 11:26:36AM +0100, Russell King wrote:
> genphy_restart_aneg() can only restart autonegotiation on clause 22
> PHYs.  Add a phy_restart_aneg() function which selects between the
> clause 22 and clause 45 restart functionality depending on the PHY
> type.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---
>  drivers/net/phy/phy.c | 23 +++++++++++++++++++++--
>  include/linux/phy.h   |  1 +
>  2 files changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 82ab8fb82587..25b24789a409 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -149,6 +149,25 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
>  	return 0;
>  }
>  
> +/**
> + * phy_restart_aneg - restart auto-negotiation
> + * @phydev: target phy_device struct
> + *
> + * Restart the autonegotiation on @phydev.  Returns >= 0 on success or
> + * negative errno on error.
> + */
> +int phy_restart_aneg(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	if (phydev->is_c45)
> +		ret = genphy_c45_restart_aneg(phydev);
> +	else
> +		ret = genphy_restart_aneg(phydev);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(phy_restart_aneg);

Hi Russell

Isn't the same sort of thing needed in phy_aneg_done()?

Thanks
	Andrew
