From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RESEND] [PATCH] ll_temac: Add support for ethtool
Date: Wed, 19 Oct 2011 00:29:30 +0100
Message-ID: <1318980570.23980.28.camel@deadeye>
References: <1318960501-3544-1-git-send-email-ricardo.ribalda@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, grant.likely@secretlab.ca,
	sfr@canb.auug.org.au, u.kleine-koenig@pengutronix.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318960501-3544-1-git-send-email-ricardo.ribalda@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-10-18 at 19:55 +0200, Ricardo Ribalda Delgado wrote:
> This patch enables the ethtool interface. The implementation is done
> using the libphy helper functions.

All Ethernet drivers have been moved in net-next.  This driver is now
under drivers/net/ethernet/xilinx.

> Reviewed-by: Grant Likely <grant.likely@secretlab.ca>
> Signed-off-by: Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>
> ---
>  drivers/net/ll_temac_main.c |   27 +++++++++++++++++++++++++++
>  1 files changed, 27 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
> index 728fe41..91a9804 100644
> --- a/drivers/net/ll_temac_main.c
> +++ b/drivers/net/ll_temac_main.c
> @@ -957,6 +957,32 @@ static const struct attribute_group temac_attr_group = {
>  	.attrs = temac_device_attrs,
>  };
>  
> +/* ethtool support */
> +static int temac_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	return phy_ethtool_gset(lp->phy_dev, cmd);
> +}
> +
> +static int temac_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	return phy_ethtool_sset(lp->phy_dev, cmd);
> +}
> +
> +static int temac_nway_reset(struct net_device *ndev)
> +{
> +	struct temac_local *lp = netdev_priv(ndev);
> +	return phy_start_aneg(lp->phy_dev);
> +}
> +
> +static const struct ethtool_ops temac_ethtool_ops = {
> +	.get_settings = temac_get_settings,
> +	.set_settings = temac_set_settings,
> +	.nway_reset = temac_nway_reset,
> +	.get_link = ethtool_op_get_link,
> +};
> +
>  static int __devinit temac_of_probe(struct platform_device *op)
>  {
>  	struct device_node *np;
> @@ -978,6 +1004,7 @@ static int __devinit temac_of_probe(struct platform_device *op)
>  	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
>  	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
>  	ndev->netdev_ops = &temac_netdev_ops;
> +	ndev->ethtool_ops= &temac_ethtool_ops;

Missing space before '='.

Ben.

>  #if 0
>  	ndev->features |= NETIF_F_IP_CSUM; /* Can checksum TCP/UDP over IPv4. */
>  	ndev->features |= NETIF_F_HW_CSUM; /* Can checksum all the packets. */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
