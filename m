From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: Re: [RESEND PATCH net 09/10] net: ethernet: mediatek: use
 devm_mdiobus_alloc instead of mdiobus_alloc inside mtk_mdio_init
Date: Thu, 25 Aug 2016 15:39:08 +0200
Message-ID: <84142b03-2100-1d56-8f5e-1d39b1748a25@phrozen.org>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
 <1472121901-15629-10-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472121901-15629-10-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Sean,

small nitpick inline

On 25/08/2016 12:45, Sean Wang wrote:
> a lot of parts in the driver uses devm_* APIs to gain benefits from the
> device resource management, so devm_mdiobus_alloc is also used instead
> of mdiobus_alloc to have more elegant code flow.
> 
> Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 13 +------------
>  1 file changed, 1 insertion(+), 12 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index e3baa63..05d85da 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -304,7 +304,7 @@ static int mtk_mdio_init(struct mtk_eth *eth)
>  		goto err_put_node;
>  	}
>  
> -	eth->mii_bus = mdiobus_alloc();
> +	eth->mii_bus = devm_mdiobus_alloc(eth->dev);
>  	if (!eth->mii_bus) {
>  		err = -ENOMEM;
>  		goto err_put_node;
> @@ -318,18 +318,9 @@ static int mtk_mdio_init(struct mtk_eth *eth)
>  
>  	snprintf(eth->mii_bus->id, MII_BUS_ID_SIZE, "%s", mii_np->name);
>  	err = of_mdiobus_register(eth->mii_bus, mii_np);
> -	if (err)
> -		goto err_free_bus;
> -	of_node_put(mii_np);
> -
> -	return 0;
> -
> -err_free_bus:
> -	mdiobus_free(eth->mii_bus);
>  
>  err_put_node:
>  	of_node_put(mii_np);
> -	eth->mii_bus = NULL;
>  	return err;

you might want to rename err to ret. that would make it more readable.
right now it looks like the code always flows through the error path.

	John

>  }
>  
> @@ -339,8 +330,6 @@ static void mtk_mdio_cleanup(struct mtk_eth *eth)
>  		return;
>  
>  	mdiobus_unregister(eth->mii_bus);
> -	of_node_put(eth->mii_bus->dev.of_node);
> -	mdiobus_free(eth->mii_bus);
>  }
>  
>  static inline void mtk_irq_disable(struct mtk_eth *eth, u32 mask)
> 
