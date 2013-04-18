From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 4/8] net: sh-eth: Remove SH_ETH_HAS_TSU and use tsu
 of sh_eth_cpu_data instead
Date: Thu, 18 Apr 2013 18:40:47 +0400
Message-ID: <517005EF.20801@cogentembedded.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1366279869-23387-4-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:37112 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966753Ab3DROl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:41:57 -0400
Received: by mail-lb0-f182.google.com with SMTP id z13so2784280lbh.13
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:41:55 -0700 (PDT)
In-Reply-To: <1366279869-23387-4-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> ---
[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 5c4e82c..7de0b0e 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -2597,16 +2591,11 @@ static const u16 *sh_eth_get_register_offset(int register_type)
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
> @@ -2687,6 +2676,15 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
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

    What if there's multiple Ether devices, only one of which has TSU? Or that 
never happens?

WBR, Sergei
