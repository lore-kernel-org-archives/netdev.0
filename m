From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 07/13] net: mvpp2: improve the link management
 function
Date: Thu, 24 Aug 2017 16:06:25 +0200
Message-ID: <20170824140625.GH8022@lunn.ch>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
 <20170824083823.16826-8-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kishon@ti.com, jason@lakedaemon.net,
        sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170824083823.16826-8-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 10:38:17AM +0200, Antoine Tenart wrote:
> When the link status changes, the phylib calls the link_event function
> in the mvpp2 driver. Before this patch only the egress/ingress transmit
> was enabled/disabled. This patch adds more functionality to the link
> status management code by enabling/disabling the port per-cpu
> interrupts, and the port itself. The queues are now stopped as well, and
> the netif carrier helpers are called.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index ebcc89b8f792..99847fec1c5a 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -5753,14 +5753,24 @@ static void mvpp2_link_event(struct net_device *dev)
>  		port->link = phydev->link;
>  
>  		if (phydev->link) {
> +			mvpp2_interrupts_enable(port);
> +			mvpp2_port_enable(port);
> +
>  			mvpp2_egress_enable(port);
>  			mvpp2_ingress_enable(port);
> +			netif_carrier_on(dev);

Hi Antoine

Have you seen cases where it is required to change the carrier state?
The phy state machine should be doing this. e.g. when autoneg has
completed, force link configuration, the link goes down etc.

	   Andrew
