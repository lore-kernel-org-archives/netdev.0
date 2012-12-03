From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 3/3] net: cpsw: implement ioctl for MII
Date: Mon, 3 Dec 2012 22:34:27 +0530
Message-ID: <50BCDB9B.80307@ti.com>
References: <1354542569-6165-1-git-send-email-jlu@pengutronix.de> <1354542569-6165-3-git-send-email-jlu@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Jan Luebbe <jlu@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:38627 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab2LCRG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 12:06:56 -0500
In-Reply-To: <1354542569-6165-3-git-send-email-jlu@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/3/2012 7:19 PM, Jan Luebbe wrote:
> This allows using tools like mii-diag on CPSW.
>
> Signed-off-by: Jan Luebbe <jlu@pengutronix.de>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   15 +++++++++++++++
>   1 file changed, 15 insertions(+)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 8de3e92..f476c03 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -629,6 +629,20 @@ static void cpsw_ndo_change_rx_flags(struct net_device *ndev, int flags)
>   		dev_err(&ndev->dev, "multicast traffic cannot be filtered!\n");
>   }
>   
> +static int cpsw_ndo_do_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phy = priv->slaves[0].phy;
> +
> +	if (!netif_running(ndev))
> +		return -EINVAL;
> +
> +	if (!phy)
> +		return -ENODEV;
> +
> +	return phy_mii_ioctl(phy, rq, cmd);
> +}
> +
>   static void cpsw_ndo_tx_timeout(struct net_device *ndev)
>   {
>   	struct cpsw_priv *priv = netdev_priv(ndev);
> @@ -670,6 +684,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
>   	.ndo_start_xmit		= cpsw_ndo_start_xmit,
>   	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
>   	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl		= cpsw_ndo_do_ioctl,
>   	.ndo_change_mtu		= eth_change_mtu,
>   	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
>   	.ndo_get_stats		= cpsw_ndo_get_stats,

Already ndo_do_ioctl is already implemented. Can you rebase the patch 
with latest git repo
and resubmit the patch

Regards
Mugunthan V N
