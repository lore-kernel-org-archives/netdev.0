From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 06:16:03 +0000
Message-ID: <20090616061603.GA4494@ff.dom.local>
References: <4A367E14.4040104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:54969 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbZFPGQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 02:16:07 -0400
Received: by fxm7 with SMTP id 7so391918fxm.37
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2009 23:16:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A367E14.4040104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-06-2009 19:00, Patrick McHardy wrote:
> This patch contains the final driver ndo_start_xmit() return
> value fixups. I'm pretty sure I got them all ...
...
> commit fbc7a709feec3792247fb8596ac3d91a6d2c9ecc
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Mon Jun 15 18:55:45 2009 +0200
> 
> @@ -1591,6 +1586,10 @@ static int hp100_start_xmit_bm(struct sk_buff *skb, struct net_device *dev)
>  	dev->trans_start = jiffies;
>  
>  	return 0;

	??

> +
> +drop:
> +	dev_kfree_skb(skb);
> +	return NETDEV_TX_OK;
>  }
>  
>  
...
> @@ -1759,6 +1753,11 @@ static int hp100_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  #endif
>  
>  	return 0;

	??

> +
> +drop:
> +	dev_kfree_skb(skb);
> +	return NETDEV_TX_OK;
> +
>  }
>  
>  
> diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
> index 2dd78d2..1907939 100644
> --- a/drivers/net/wan/lapbether.c
> +++ b/drivers/net/wan/lapbether.c
> @@ -149,46 +149,42 @@ static int lapbeth_data_indication(struct net_device *dev, struct sk_buff *skb)
>   */
>  static int lapbeth_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> -	int err = -ENODEV;
> +	int err;
>  
>  	/*
>  	 * Just to be *really* sure not to send anything if the interface
>  	 * is down, the ethernet device may have gone.
>  	 */
>  	if (!netif_running(dev)) {
> +		// XXX

 	/* XXX */ ??

Jarek P.
