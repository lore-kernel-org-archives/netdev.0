From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 5/9] net: sh-eth: Remove SH_ETH_HAS_TSU and use tsu
 of sh_eth_cpu_data instead
Date: Tue, 07 May 2013 18:59:56 +0400
Message-ID: <518916EC.6000000@cogentembedded.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1367903875-32606-5-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:57878 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756066Ab3EGO76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 10:59:58 -0400
Received: by mail-lb0-f170.google.com with SMTP id t11so843177lbd.1
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 07:59:57 -0700 (PDT)
In-Reply-To: <1367903875-32606-5-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07-05-2013 9:17, Nobuhiro Iwamatsu wrote:

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---
> V3:
>    no change.
> V2:
>    no change.
>   drivers/net/ethernet/renesas/sh_eth.c |   22 ++++++++++------------
>   1 file changed, 10 insertions(+), 12 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 944b2df..667c908 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c

[...]

> @@ -2591,16 +2585,11 @@ static const u16 *sh_eth_get_register_offset(int register_type)
>   	return reg_offset;
>   }
>
> -static const struct net_device_ops sh_eth_netdev_ops = {
> +static struct net_device_ops sh_eth_netdev_ops = {
>   	.ndo_open		= sh_eth_open,
>   	.ndo_stop		= sh_eth_close,
>   	.ndo_start_xmit		= sh_eth_start_xmit,
>   	.ndo_get_stats		= sh_eth_get_stats,
> -#if defined(SH_ETH_HAS_TSU)
> -	.ndo_set_rx_mode	= sh_eth_set_multicast_list,
> -	.ndo_vlan_rx_add_vid	= sh_eth_vlan_rx_add_vid,
> -	.ndo_vlan_rx_kill_vid	= sh_eth_vlan_rx_kill_vid,
> -#endif
>   	.ndo_tx_timeout		= sh_eth_tx_timeout,
>   	.ndo_do_ioctl		= sh_eth_do_ioctl,
>   	.ndo_validate_addr	= eth_validate_addr,
> @@ -2681,6 +2670,15 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>   	sh_eth_set_default_cpu_data(mdp->cd);
>
>   	/* set function */
> +	if (mdp->cd->tsu) {
> +		sh_eth_netdev_ops.ndo_set_rx_mode
> +			= sh_eth_set_multicast_list;
> +		sh_eth_netdev_ops.ndo_vlan_rx_add_vid
> +			= sh_eth_vlan_rx_add_vid;
> +		sh_eth_netdev_ops.ndo_vlan_rx_kill_vid
> +			= sh_eth_vlan_rx_kill_vid;
> +	}
> +

     Alternatively, you could use two 'struct net_device_ops' instances, 
one with TSU-specific methods installed and one without. That would work 
with any combination of Ether devices having and not having TSU (though 
such combinations don't seem to exist in practice).

>   	ndev->netdev_ops = &sh_eth_netdev_ops;
>   	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
>   	ndev->watchdog_timeo = TX_TIMEOUT

WBR, Sergei
