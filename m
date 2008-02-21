From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Don't create tunnels with '%' in name.
Date: Thu, 21 Feb 2008 13:10:16 +0100
Message-ID: <47BD6A28.1030007@trash.net>
References: <47BD6907.7050303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep31-int.chello.at ([62.179.121.49]:63490 "EHLO
	viefep31-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbYBUMKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 07:10:36 -0500
In-Reply-To: <47BD6907.7050303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Four tunnel drivers (ip_gre, ipip, ip6_tunnel and sit) can
> receive a pre-defined name for a device from the userspace.
> Since these drivers call the register_netdevice() after this 
> (rtnl_lock is held), the device's name may contain a '%' 
> character.
> 
> Not sure how bad is this to have a device with a '%' in its
> name, but all the other places either use the register_netdev(),
> or explicitly call dev_alloc_name() before registering, i.e. 
> do not allow for such names.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 63f6917..6b9744f 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -274,19 +274,24 @@ static struct ip_tunnel * ipgre_tunnel_locate(struct ip_tunnel_parm *parms, int
>  	if (!dev)
>  	  return NULL;
>  
> +	if (strchr(name, '%')) {
> +		if (dev_alloc_name(dev, name) < 0)
> +			goto failed_free;
> +	}
> +


It would be nicer to replace the entire hand-made name
allocation to remove the 100 device limit.
