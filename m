From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: cpsw: Add support for wake-on-lan for cpsw
Date: Mon, 19 Aug 2013 22:56:49 +0400
Message-ID: <52126A71.5050306@cogentembedded.com>
References: <1376907191-25491-1-git-send-email-ujhelyi.m@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ujhelyi.m@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376907191-25491-1-git-send-email-ujhelyi.m@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/19/2013 02:13 PM, ujhelyi.m@gmail.com wrote:

> From: Matus Ujhelyi <ujhelyi.m@gmail.com>

> Signed-off-by: Matus Ujhelyi <ujhelyi.m@gmail.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   25 +++++++++++++++++++++++++
>   1 file changed, 25 insertions(+)

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 22a7a43..f59302e 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1416,6 +1416,29 @@ static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
>   		return -EOPNOTSUPP;
>   }
>
> +static void
> +cpsw_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	int slave_no = cpsw_slave_index(priv);

    Empty line wouldn't hurt here, after declaration.

> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +	if (priv->slaves[slave_no].phy)
> +		phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
> +
> +}
> +
> +static int
> +cpsw_set_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	int slave_no = cpsw_slave_index(priv);

    Here too...

> +	if (priv->slaves[slave_no].phy)
> +		return phy_ethtool_set_wol(priv->slaves[slave_no].phy, wol);
> +	else
> +		return -EOPNOTSUPP;
> +}
> +
>   static const struct ethtool_ops cpsw_ethtool_ops = {
>   	.get_drvinfo	= cpsw_get_drvinfo,
>   	.get_msglevel	= cpsw_get_msglevel,

WBR, Sergei
