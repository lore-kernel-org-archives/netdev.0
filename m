From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3.16]r8169:  Add support for half duplex on MDI
Date: Fri, 25 Mar 2016 16:50:48 +0100
Message-ID: <20160325155048.GA11491@lunn.ch>
References: <1458916193-32521-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56804 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246AbcCYPuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 11:50:51 -0400
Content-Disposition: inline
In-Reply-To: <1458916193-32521-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 04:29:52PM +0200, Corcodel Marian wrote:
>  This patch add support for half duplex on MDI chips.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 77c5efb..7f6fb1f 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1713,8 +1713,13 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
>  		else
>  			goto out;
>  
> -		if (duplex == DUPLEX_FULL)
> +		if (duplex == DUPLEX_FULL) {
>  			bmcr |= BMCR_FULLDPLX;
> +		} else if (duplex == DUPLEX_HALF) {
> +				bmcr |= ~BMCR_FULLDPLX;
> +		} else {
> +			goto out;
> +		 }


Hi Corcodel

What PHY is actually being used? One that is supported by
drivers/net/phy/realtek.c?

It looks like the bugs you are finding are all handling stuff which is
generic, and well tested code in drivers/net/phy/phy_device.c would do
for you, with less bugs.

Maybe you want to consider throwing away the PHY code in r8169 and
just implement an standard mdio bus, use phylib and the realtek.c phy
driver?

	Andrew
