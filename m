From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/8] net: sh-eth: Remove duplicate sh_eth_set_duplex()
Date: Thu, 18 Apr 2013 18:12:35 +0400
Message-ID: <516FFF53.6010701@cogentembedded.com>
References: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1366268510-8121-3-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:47896 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965122Ab3DRONp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:13:45 -0400
Received: by mail-la0-f42.google.com with SMTP id fn20so2599488lab.15
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:13:44 -0700 (PDT)
In-Reply-To: <1366268510-8121-3-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-04-2013 11:01, Nobuhiro Iwamatsu wrote:

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

    Step in the right direction.

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 313d6ef..5c4e82c 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -341,9 +341,11 @@ static void sh_eth_select_mii(struct net_device *ndev)
>   }
>   #endif
>
> -/* There is CPU dependent code */
> -#if defined(CONFIG_ARCH_R8A7779)
> -#define SH_ETH_RESET_DEFAULT	1
> +#if defined(CONFIG_CPU_SUBTYPE_SH7619) || \
> +	defined(CONFIG_CPU_SUBTYPE_SH7710) || \
> +	defined(CONFIG_CPU_SUBTYPE_SH7712)
> +#  define sh_eth_set_duplex NULL

    I don't think this is neeeded at all.

> +#else
>   static void sh_eth_set_duplex(struct net_device *ndev)
>   {
>   	struct sh_eth_private *mdp = netdev_priv(ndev);
> @@ -353,7 +355,11 @@ static void sh_eth_set_duplex(struct net_device *ndev)
>   	else		/* Half */
>   		sh_eth_write(ndev, sh_eth_read(ndev, ECMR) & ~ECMR_DM, ECMR);
>   }
> +#endif
>
> +/* There is CPU dependent code */
> +#if defined(CONFIG_ARCH_R8A7779)
> +#define SH_ETH_RESET_DEFAULT	1
>   static void sh_eth_set_rate(struct net_device *ndev)
>   {
>   	struct sh_eth_private *mdp = netdev_priv(ndev);
[...]
> @@ -834,6 +791,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>   #elif defined(CONFIG_CPU_SUBTYPE_SH7619)
>   #define SH_ETH_RESET_DEFAULT	1
>   static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
> +	.set_duplex = sh_eth_set_duplex,

    Please, align = like in other initializers.
    Wait, is this change legitimate at all? You mean NULL will be set here?
But why bother doing this, when 0s will be set to all fields without
explicit initializer?

>   	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
>
>   	.apr		= 1,
> @@ -845,6 +803,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
>   #define SH_ETH_RESET_DEFAULT	1
>   #define SH_ETH_HAS_TSU	1
>   static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
> +	.set_duplex = sh_eth_set_duplex,

    Same coments here.

WBR, Sergei
