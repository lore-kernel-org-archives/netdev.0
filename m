From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 04/18] net: mvpp2: move the mii configuration in
 the ndo_open path
Date: Wed, 26 Jul 2017 18:11:11 +0200
Message-ID: <20170726161111.GG12049@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-5-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40963 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750918AbdGZQLS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:11:18 -0400
Content-Disposition: inline
In-Reply-To: <20170724134848.19330-5-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 03:48:34PM +0200, Antoine Tenart wrote:
> This moves the mii configuration in the ndo_open path, to allow handling
> different mii configurations later and to switch between these
> configurations at runtime.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 6ffff929b22a..9d204ffb9b89 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -5862,6 +5862,7 @@ static void mvpp2_start_dev(struct mvpp2_port *port)
>  	/* Enable interrupts on all CPUs */
>  	mvpp2_interrupts_enable(port);
>  
> +	mvpp2_port_mii_set(port);

Hi Antoine

You probably should take a look at mvpp2_port_mii_set() and have it
handle all PHY_INTERFACE_MODE_RGMII variants.

       Andrew
