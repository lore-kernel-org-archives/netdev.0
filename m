From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/5] sh_eth: Simplify MDIO bus initialization and release
Date: Thu, 20 Mar 2014 19:31:13 +0400
Message-ID: <532B09C1.5030201@cogentembedded.com>
References: <1395324035-22918-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com> <1395324035-22918-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, Ben Dooks <ben.dooks@codethink.co.uk>
To: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>,
	netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1395324035-22918-4-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20-03-2014 18:00, Laurent Pinchart wrote:

> The network device passed to the sh_mdio_init and sh_mdio_release
> functions is only used to access the sh_eth_private instance. Pass it
> directly to those functions.

    The changelog is incomplete now. You added significant changes but forgot 
to document them.

> Signed-off-by: Laurent Pinchart <laurent.pinchart+renesas@ideasonboard.com>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c | 30 +++++++++++-------------------
>   1 file changed, 11 insertions(+), 19 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 443f14f..e9224f2 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2583,29 +2583,24 @@ static void sh_eth_tsu_init(struct sh_eth_private *mdp)
[...]
> -static int sh_mdio_init(struct net_device *ndev, int id,
> +static int sh_mdio_init(struct sh_eth_private *mdp,
>   			struct sh_eth_plat_data *pd)
>   {
>   	int ret, i;
>   	struct bb_info *bitbang;
> -	struct sh_eth_private *mdp = netdev_priv(ndev);
> +	struct platform_device *pdev = mdp->pdev;
>   	struct device *dev = &mdp->pdev->dev;

	struct device *dev = &pdev->dev;

> @@ -2635,7 +2630,7 @@ static int sh_mdio_init(struct net_device *ndev, int id,
>   	mdp->mii_bus->name = "sh_mii";
>   	mdp->mii_bus->parent = dev;
>   	snprintf(mdp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
> -		 mdp->pdev->name, id);
> +		 pdev->name, pdev->id);
>
>   	/* PHY IRQ */
>   	mdp->mii_bus->irq = devm_kzalloc(dev, sizeof(int) * PHY_MAX_ADDR,

WBR, Sergei

