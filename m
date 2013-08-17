From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH 1/2] sundance: add netconsole support
Date: Sat, 17 Aug 2013 11:08:02 +0400
Message-ID: <CAHj3AV=LZ=MApVNzMe345thNiLCmebKijVwneSgdV2Fra47nOQ@mail.gmail.com>
References: <1376670748-2084-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:39302 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab3HQHIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 03:08:04 -0400
Received: by mail-ea0-f182.google.com with SMTP id o10so1378139eaj.13
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 00:08:02 -0700 (PDT)
In-Reply-To: <1376670748-2084-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, please ignore these patches since they are obviously intended
for net-next.

Thanks!

On 8/16/13, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> add netconsole logging support
>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
>  drivers/net/ethernet/dlink/sundance.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
>
> diff --git a/drivers/net/ethernet/dlink/sundance.c
> b/drivers/net/ethernet/dlink/sundance.c
> index 50d9c63..2688a84 100644
> --- a/drivers/net/ethernet/dlink/sundance.c
> +++ b/drivers/net/ethernet/dlink/sundance.c
> @@ -469,6 +469,17 @@ static void sundance_reset(struct net_device *dev,
> unsigned long reset_cmd)
>  	}
>  }
>
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void sundance_poll_controller(struct net_device *dev)
> +{
> +	struct netdev_private *np = netdev_priv(dev);
> +
> +	disable_irq(np->pci_dev->irq);
> +	intr_handler(np->pci_dev->irq, dev);
> +	enable_irq(np->pci_dev->irq);
> +}
> +#endif
> +
>  static const struct net_device_ops netdev_ops = {
>  	.ndo_open		= netdev_open,
>  	.ndo_stop		= netdev_close,
> @@ -480,6 +491,9 @@ static const struct net_device_ops netdev_ops = {
>  	.ndo_change_mtu		= change_mtu,
>  	.ndo_set_mac_address 	= sundance_set_mac_addr,
>  	.ndo_validate_addr	= eth_validate_addr,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller = sundance_poll_controller,
> +#endif
>  };
>
>  static int sundance_probe1(struct pci_dev *pdev,
> --
> 1.8.0.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Regards,
Denis
