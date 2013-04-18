From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 6/8] net: sh-eth: Add irq configureation flags in sh_eth_cpu_data
Date: Thu, 18 Apr 2013 18:57:27 +0400
Message-ID: <517009D7.7080700@cogentembedded.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <1366279869-23387-6-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:44227 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966221Ab3DRO6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:58:37 -0400
Received: by mail-lb0-f180.google.com with SMTP id t11so2780517lbi.39
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:58:35 -0700 (PDT)
In-Reply-To: <1366279869-23387-6-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:

> sh-eth is supporting some SH and shmobile CPU. CPU with two or more networked
> devices is in these, these specify IRQF_SHARED as IRQ configureation flags.
> This changes to set IRQ configureation flags using in sh_eth_cpu_data.

> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[...]

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index af8c225..a4e337f 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
> @@ -1920,14 +1923,7 @@ static int sh_eth_open(struct net_device *ndev)
>   	pm_runtime_get_sync(&mdp->pdev->dev);
>
>   	ret = request_irq(ndev->irq, sh_eth_interrupt,
> -#if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
> -	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
> -	defined(CONFIG_CPU_SUBTYPE_SH7757)
> -				IRQF_SHARED,
> -#else
> -				0,
> -#endif

    Isn't it simpler to always pass IRQF_SHARED?

> -				ndev->name, ndev);
> +				mdp->cd->irq_flags, ndev->name, ndev);
>   	if (ret) {
>   		dev_err(&ndev->dev, "Can not assign IRQ number\n");
>   		return ret;
> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> index f86ea96..0772ec1 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.h
> +++ b/drivers/net/ethernet/renesas/sh_eth.h
> @@ -463,6 +463,7 @@ struct sh_eth_cpu_data {
>   	unsigned long tx_error_check;
>
>   	/* hardware features */
> +	unsigned long irq_flags; /* IRQ configuration flags */

    Comment should have been indented with tabs like the others.

>   	unsigned no_psr:1;		/* EtherC DO NOT have PSR */
>   	unsigned apr:1;			/* EtherC have APR */
>   	unsigned mpr:1;			/* EtherC have MPR */
> @@ -508,6 +509,7 @@ struct sh_eth_private {
>   	int duplex;
>   	int port;		/* for TSU */
>   	int vlan_num_ids;	/* for VLAN tag filter */
> +	unsigned long irq_flags; /* IRQ configuration flags */

    You don't seem to use this...

WBR, Sergei
