From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next v2 4/5] net-next: ethernet: mediatek: add
 device_node of GMAC pointing into the netdev instance
Date: Wed, 22 Mar 2017 19:18:46 +0100
Message-ID: <20170322181846.GN30655@lunn.ch>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
 <1490088910-19405-5-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org,
        matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1490088910-19405-5-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 21, 2017 at 05:35:09PM +0800, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
> From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> 
> the patch adds the setup of the corresponding device node of GMAC into the
> netdev instance which could allow other modules such as DSA to find the
> instance through the node in dt-bindings using of_find_net_device_by_node()
> call.
> 
> Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index c21ed99..84b09a4 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -2323,6 +2323,8 @@ static int mtk_add_mac(struct mtk_eth *eth, struct device_node *np)
>  	eth->netdev[id]->ethtool_ops = &mtk_ethtool_ops;
>  
>  	eth->netdev[id]->irq = eth->irq[0];
> +	eth->netdev[id]->dev.of_node = np;
> +

Humm, O.K. This is not obvious, until you look at of_dev_node_match()
in net-sysfs.c.

Most Ethernet drivers don't set netdev.dev.of_node. But they do call
SET_NETDEV_DEV(), which sets netdev.dev.parent.

of_dev_node_match() first looks at netdev.dev.parent->of_node, and if that
does not match, then looks at netdev.dev.of_node.

For the mtk Ethernet driver, the parent is not going to work, because
of the sub devices. So netdev.dev.of_node does need to be set.

Reviewed-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>

    Andrew


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
