From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: fix unbalanced clk disable on driver unbind
Date: Fri, 6 Mar 2015 01:22:09 +0000
Message-ID: <BY2PR03MB3779D6C22F6089A410E3331F51C0@BY2PR03MB377.namprd03.prod.outlook.com>
References: <1425564569-12184-1-git-send-email-stefan@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Stefan Agner <stefan@agner.ch>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425564569-12184-1-git-send-email-stefan@agner.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Agner <stefan@agner.ch> Sent: Thursday, March 05, 2015 10:09 PM
> To: davem@davemloft.net
> Cc: Duan Fugang-B38611; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; stefan@agner.ch
> Subject: [PATCH] net: fec: fix unbalanced clk disable on driver unbind
> 
> When the driver is removed (e.g. using unbind through sysfs), the clocks
> get disabled twice, once on fec_enet_close and once on fec_drv_remove.
> Since the clocks are enabled only once, this leads to a warning:
> 
> WARNING: CPU: 0 PID: 402 at drivers/clk/clk.c:992
> clk_core_disable+0x64/0x68()
> 
> Remove the call to fec_enet_clk_enable in fec_drv_remove to balance the
> clock enable/disable calls again. This has been introduce by e8fcfcd5684a
> ("net: fec: optimize the clock management to save power").
> 
> Signed-off-by: Stefan Agner <stefan@agner.ch>
> ---
>  drivers/net/ethernet/freescale/fec_main.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 9bb6220..5fbdf72 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3383,7 +3383,6 @@ fec_drv_remove(struct platform_device *pdev)
>  		regulator_disable(fep->reg_phy);
>  	if (fep->ptp_clock)
>  		ptp_clock_unregister(fep->ptp_clock);
> -	fec_enet_clk_enable(ndev, false);
>  	of_node_put(fep->phy_node);
>  	free_netdev(ndev);
> 
> --
> 2.3.0

Acked-by: Fugang Duan <B38611@freescale.com>
