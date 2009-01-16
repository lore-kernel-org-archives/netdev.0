From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] PS3: gelic: convert to net_device_ops
Date: Thu, 15 Jan 2009 22:07:08 -0800
Message-ID: <20090115220708.6a246ff1@extreme>
References: <20090116134050.0B5B.40F06B3A@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	Geoff Levand <geoffrey.levand@am.sony.com>
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54060 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725AbZAPGHK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2009 01:07:10 -0500
In-Reply-To: <20090116134050.0B5B.40F06B3A@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Jan 2009 13:57:15 +0900
Masakazu Mokuno <mokuno@sm.sony.co.jp> wrote:

> Convert the gelic driver to net_device_ops
> 
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> ---
>  drivers/net/ps3_gelic_net.c |   23 +++++++++++++----------
>  1 file changed, 13 insertions(+), 10 deletions(-)
> 
> --- a/drivers/net/ps3_gelic_net.c
> +++ b/drivers/net/ps3_gelic_net.c
> @@ -1403,6 +1403,18 @@ void gelic_net_tx_timeout(struct net_dev
>  		atomic_dec(&card->tx_timeout_task_counter);
>  }
>  
> +static const struct net_device_ops gelic_netdevice_ops = {
> +	.ndo_open = gelic_net_open,
> +	.ndo_stop = gelic_net_stop,
> +	.ndo_start_xmit = gelic_net_xmit,
> +	.ndo_set_multicast_list = gelic_net_set_multi,
> +	.ndo_change_mtu = gelic_net_change_mtu,
> +	.ndo_tx_timeout = gelic_net_tx_timeout,
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.ndo_poll_controller = gelic_net_poll_controller,
> +#endif
>

You probably want to add:
	.ndo_change_mtu		= eth_change_mtu,
	.ndo_set_mac_address 	= eth_mac_addr,
	.ndo_validate_addr	= eth_validate_addr,
