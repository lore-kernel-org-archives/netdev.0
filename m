From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: axienet: add support for standard phy-mode binding
Date: Thu, 6 Jul 2017 15:34:55 +0200
Message-ID: <20170706133455.GB8810@lunn.ch>
References: <20170706085011.2828-1-alvaro.gamez@hazent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anirudha Sarangi <anirudh@xilinx.com>,
        John Linn <John.Linn@xilinx.com>,
        Michal Simek <michal.simek@xilinx.com>,
        =?iso-8859-1?Q?S=F6ren?= Brinkmann <soren.brinkmann@xilinx.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
To: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170706085011.2828-1-alvaro.gamez@hazent.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2017 at 10:50:11AM +0200, Alvaro Gamez Machado wrote:
> Keep supporting proprietary "xlnx,phy-type" attribute and add support for
> MII connectivity to the PHY.

Hi Alvaro

Thanks for picking this up.

> 
> Signed-off-by: Alvaro Gamez Machado <alvaro.gamez@hazent.com>
> ---
>  drivers/net/ethernet/xilinx/xilinx_axienet_main.c | 48 +++++++++++++++++------
>  1 file changed, 36 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 33c595f4691d..f669b8e69e8b 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -531,11 +531,11 @@ static void axienet_adjust_link(struct net_device *ndev)
>  	link_state = phy->speed | (phy->duplex << 1) | phy->link;
>  	if (lp->last_link != link_state) {
>  		if ((phy->speed == SPEED_10) || (phy->speed == SPEED_100)) {
> -			if (lp->phy_type == XAE_PHY_TYPE_1000BASE_X)
> +			if (lp->phy_type == PHY_INTERFACE_MODE_1000BASEX)

In my suggestion patch, i renamed it to phy_mode. That is the
convention used by other drivers. Since we are also changing what it
means, it gives the compiler a chance to error out on any instances we
didn't find and are still trying to use the old meaning.

It would be nice to document this in a device tree binding
document. Something like Documentation/devicetree/binding/net/xilinx_axienet.txt

XILINX Axi Ethernet device driver
---------------------------------

Required properties:

- compatible	: Must be one of "xlnx,axi-ethernet-1.00.a",
                  "xlnx,axi-ethernet-1.01.a", or "xlnx,axi-ethernet-2.01.a"
- reg		: Address and length of the IO space.
- interrupts    : Should be a list of two interrupt, TX and RX.

Optional properties:

- phy-mode	: See ethernet.txt
- xlnx,phy-type : Deprecated, do not use, but still accepted in preference to phy-mode.

There are other properties, but they can be added later. The important
thing is it documents this change.

Thanks
      Andrew
