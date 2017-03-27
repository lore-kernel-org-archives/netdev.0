From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC net-next 2/3] net: phy: read whether PHY supports
 stopping clock during LPI
Date: Mon, 27 Mar 2017 22:31:40 +0200
Message-ID: <20170327203140.GG17041@lunn.ch>
References: <20170327184721.30275-1-f.fainelli@gmail.com>
 <20170327184721.30275-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        rmk+kernel@armlinux.org.uk
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35897 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751677AbdC0UcX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 16:32:23 -0400
Content-Disposition: inline
In-Reply-To: <20170327184721.30275-3-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 11:47:20AM -0700, Florian Fainelli wrote:
> In order to use phy_init_eee() correctly, in particular the clk_stop
> argument, we need to know whether the Ethernet PHY supports stopping its
> clock.
> 
> Right now, we would have to call phy_init_eee(phydev, 1), see if that
> tails, and call again with phy_init_eee(phydev, 0) to enable EEE this is
> not an acceptable API use.

Hi Florain

I'm having trouble parsing this paragraph. Should tails be fails?  I
think "This is not an acceptable API use." should be a sentence?

> 
> Update phy_init_hw() to read whether the PHY supports this, and retain
> that information in the phydev structure so we can re-use it later.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/phy_device.c | 23 ++++++++++++++++++++++-
>  include/linux/phy.h          |  2 ++
>  2 files changed, 24 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 1219eeab69d1..2755d77626f7 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -837,6 +837,21 @@ static int phy_poll_reset(struct phy_device *phydev)
>  	return 0;
>  }
>  
> +static void phy_read_clock_stop_capable(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	/* Read if the PHY supports stopping its clocks (reg 3.1) */
> +	ret = phy_read_mmd_indirect(phydev, MDIO_MMD_PCS, MDIO_STAT1,
> +			            phydev->addr);
> +	if (ret < 0)
> +		return;

It is pretty unusual to ignore a real error. It might be better to
make this an int function, and return the error.

     Andrew
