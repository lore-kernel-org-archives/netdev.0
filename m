From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: fix marvell phy status reading
Date: Tue, 30 May 2017 18:06:25 +0200
Message-ID: <20170530160625.GJ22758@lunn.ch>
References: <E1dFixz-00062r-0n@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Russell King <rmk+kernel@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58394 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751057AbdE3QGc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 12:06:32 -0400
Content-Disposition: inline
In-Reply-To: <E1dFixz-00062r-0n@rmk-PC.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 04:21:51PM +0100, Russell King wrote:
> The Marvell driver incorrectly provides phydev->lp_advertising as the
> logical and of the link partner's advert and our advert.  This is
> incorrect - this field is supposed to store the link parter's unmodified
> advertisment.
> 
> This allows ethtool to report the correct link partner auto-negotiation
> status.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---
>  drivers/net/phy/marvell.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
> index e38f84291258..f93a7a46feb7 100644
> --- a/drivers/net/phy/marvell.c
> +++ b/drivers/net/phy/marvell.c
> @@ -1119,8 +1119,6 @@ static int marvell_read_status_page(struct phy_device *phydev, int page)
>  		if (adv < 0)
>  			return adv;
>  
> -		lpa &= adv;
> -
>  		if (status & MII_M1011_PHY_STATUS_FULLDUPLEX)
>  			phydev->duplex = DUPLEX_FULL;
>  		else

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

It appears that lxt.c has a similar issue. It however is not setting
phydev->lp_advertising, but it is using the masked values when setting
phydev->pause and phydev->asym_pause which i don't think it should do.
I can create a patch for that.

    Andrew
