From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: Re: [PATCH 2/2] pasemi_mac: Netpoll support
Date: Wed, 26 Mar 2008 15:41:01 +0300
Message-ID: <47EA445D.9090509@ru.mvista.com>
References: <20080326015625.GA23103@lixom.net> <20080326015801.GC23103@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linuxppc-dev@ozlabs.org,
	pasemi-linux@ozlabs.org, netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:1110 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753935AbYCZMnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:43:07 -0400
In-Reply-To: <20080326015801.GC23103@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Olof Johansson wrote:
> Add netpoll support to allow use of netconsole.
> 
> Signed-off-by: Nate Case <ncase@xes-inc.com>
> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
> index abb1dc4..6030ffe 100644
> --- a/drivers/net/pasemi_mac.c
> +++ b/drivers/net/pasemi_mac.c
> @@ -1648,6 +1648,26 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
>  	return pkts;
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/*
> + * Polling 'interrupt' - used by things like netconsole to send skbs
> + * without having to re-enable interrupts. It's not called while
> + * the interrupt routine is executing.
> + */
> +static void pasemi_mac_netpoll(struct net_device *dev)
> +{
> +	const struct pasemi_mac *mac = netdev_priv(dev);
> +
> +	disable_irq(mac->tx->chan.irq);
> +	pasemi_mac_tx_intr(mac->tx->chan.irq, mac->tx);
> +	enable_irq(mac->tx->chan.irq);
> +
> +	disable_irq(mac->rx->chan.irq);
> +	pasemi_mac_rx_intr(mac->rx->chan.irq, dev);

Shouldn't this actually be pasemi_mac_rx_intr(mac->rx->chan.irq, mac->rx)?
Thanks,
Valentine.

> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev

