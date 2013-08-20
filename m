From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v3] net: cpsw: Add support for wake-on-lan for
 cpsw
Date: Tue, 20 Aug 2013 17:40:59 +0400
Message-ID: <521371EB.9090103@cogentembedded.com>
References: <1376977097-25296-1-git-send-email-ujhelyi.m@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ujhelyi.m@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376977097-25296-1-git-send-email-ujhelyi.m@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 20-08-2013 9:38, ujhelyi.m@gmail.com wrote:

> From: Matus Ujhelyi <ujhelyi.m@gmail.com>

> Some phy's can be configured to enable wake on lan (e.g. at803x or marvell 88E1318S).
> There is no way how to enable wol on CPSW with such connected phys. This patch
> adds this support. It is provided by calling the phy's related code.

> Tested on board with at8030x connected phy. Wol interrupt line is
> connected to GPIO0 on am335x.

> Signed-off-by: Matus Ujhelyi <ujhelyi.m@gmail.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   24 ++++++++++++++++++++++++
>   1 file changed, 24 insertions(+)

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 0fcf212..5d673bf 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1640,6 +1640,28 @@ static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
>   		return -EOPNOTSUPP;
>   }
>
> +static void cpsw_get_wol(struct net_device *ndev, struct ethtool_wolinfo *wol)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	int slave_no = cpsw_slave_index(priv);

    You should have put an empty line here, not below.

> +	wol->supported = 0;
> +	wol->wolopts = 0;
> +
> +	if (priv->slaves[slave_no].phy)
> +		phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
> +}

WBR, Sergei
