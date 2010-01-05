From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH] via-velocity: add netpoll functionality for the benefit
 of netconsole
Date: Tue, 5 Jan 2010 07:28:00 +0100
Message-ID: <20100105072800.13dba6d2@marrow.netinsight.se>
References: <4B423440.6060807@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?St=E9phane?= Berthelot <sberthelot@emisfr.com>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:12994 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752068Ab0AEG2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 01:28:09 -0500
In-Reply-To: <4B423440.6060807@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Does the patch still work with the new NAPI support in the driver? Some
comments below:

On Mon, 04 Jan 2010 19:32:32 +0100
Jan Ceuleers <jan.ceuleers@computer.org> wrote:

> +static void velocity_poll_controller(struct net_device *dev)
> +{
> +	disable_irq(dev->irq);
> +	velocity_intr(dev->irq, dev);
> +	enable_irq(dev->irq);
> +}

This should probably have an

#ifdef CONFIG_NET_POLL_CONTROLLER
...
#endif

around it since

> @@ -2628,6 +2642,9 @@ static const struct net_device_ops velocity_netdev_ops = {
>  	.ndo_vlan_rx_add_vid	= velocity_vlan_rx_add_vid,
>  	.ndo_vlan_rx_kill_vid	= velocity_vlan_rx_kill_vid,
>  	.ndo_vlan_rx_register	= velocity_vlan_rx_register,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller	= velocity_poll_controller,
> +#endif

This one has it (to avoid a warning when building without it).

// Simon
