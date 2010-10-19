From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [patch 1/1] phy/marvell: fix 88e1121 support
Date: Tue, 19 Oct 2010 06:52:14 -0400
Message-ID: <4CBD785E.8040704@ti.com>
References: <20101018214401.053486146@rtp-net.org> <20101018214414.375368957@rtp-net.org> <4CBCC3FC.2030506@ti.com> <20101018222947.418028323@rtp-net.org> <20101018223056.716357140@rtp-net.org>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Arnaud Patard <arnaud.patard@rtp-net.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47901 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467Ab0JSKw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 06:52:29 -0400
In-Reply-To: <20101018223056.716357140@rtp-net.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaud,

On 10/18/2010 06:29 PM, Arnaud Patard wrote:
> Commit c477d0447db08068a497e7beb892b2b2a7bff64b added support for RGMII
> rx/tx delays except that it ends up clearing rx/tx delays bit for modes
> differents that RGMII*ID. Due to this, ethernet is not working anymore
> on my guruplug server +. This patch is fixing that.
> 
> Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
> Index: linux-2.6/drivers/net/phy/marvell.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/phy/marvell.c	2010-10-18 22:46:09.000000000 +0200
> +++ linux-2.6/drivers/net/phy/marvell.c	2010-10-19 00:20:22.000000000 +0200
> @@ -196,20 +196,27 @@
>  			MII_88E1121_PHY_MSCR_PAGE);
>  	if (err < 0)
>  		return err;
> -	mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
> -		MII_88E1121_PHY_MSCR_DELAY_MASK;
>  
> -	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
> -		mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
> -			 MII_88E1121_PHY_MSCR_TX_DELAY);
> -	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
> -		mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
> -	else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
> -		mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
> +	if ((phydev->interface == PHY_INTERFACE_MODE_RGMII) ||
> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) ||
> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID) ||
> +	    (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)) {
>  
> -	err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
> -	if (err < 0)
> -		return err;
> +		mscr = phy_read(phydev, MII_88E1121_PHY_MSCR_REG) &
> +			MII_88E1121_PHY_MSCR_DELAY_MASK;
> +
> +		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
> +			mscr |= (MII_88E1121_PHY_MSCR_RX_DELAY |
> +				 MII_88E1121_PHY_MSCR_TX_DELAY);
> +		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
> +			mscr |= MII_88E1121_PHY_MSCR_RX_DELAY;
> +		else if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID)
> +			mscr |= MII_88E1121_PHY_MSCR_TX_DELAY;
> +
> +		err = phy_write(phydev, MII_88E1121_PHY_MSCR_REG, mscr);
> +		if (err < 0)
> +			return err;
> +	}
>  
>  	phy_write(phydev, MII_88E1121_PHY_PAGE, oldpage);

That looks more correct.  Just out of curiosity, what is the interface
mode on your platform?

Thanks
Cyril.
