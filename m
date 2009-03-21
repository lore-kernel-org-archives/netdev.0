From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 25/77] usbnet: convert hso driver to net_device_ops
Date: Sat, 21 Mar 2009 02:08:03 -0700
Message-ID: <200903210208.03771.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.437968008@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	d.barow@option.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46400 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753342AbZCUJZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:54 -0400
In-Reply-To: <20090321053714.437968008@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

cc'd the driver's maintainer


> --- a/drivers/net/usb/hso.c	2009-03-09 08:23:41.851308905 -0700
> +++ b/drivers/net/usb/hso.c	2009-03-20 08:35:11.089026883 -0700
> @@ -2428,6 +2428,13 @@ static void hso_free_net_device(struct h
>  	kfree(hso_dev);
>  }
>  
> +static const struct net_device_ops hso_netdev_ops = {
> +	.ndo_open	= hso_net_open,
> +	.ndo_stop	= hso_net_close,
> +	.ndo_start_xmit = hso_net_start_xmit,
> +	.ndo_tx_timeout = hso_net_tx_timeout,
> +};
> +
>  /* initialize the network interface */
>  static void hso_net_init(struct net_device *net)
>  {
> @@ -2436,10 +2443,7 @@ static void hso_net_init(struct net_devi
>  	D1("sizeof hso_net is %d", (int)sizeof(*hso_net));
>  
>  	/* fill in the other fields */
> -	net->open = hso_net_open;
> -	net->stop = hso_net_close;
> -	net->hard_start_xmit = hso_net_start_xmit;
> -	net->tx_timeout = hso_net_tx_timeout;
> +	net->netdev_ops = &hso_netdev_ops;
>  	net->watchdog_timeo = HSO_NET_TX_TIMEOUT;
>  	net->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
>  	net->type = ARPHRD_NONE;
> 
> -- 
> 
> 


