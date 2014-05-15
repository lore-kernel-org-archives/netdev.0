From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip_tunnel: Initialize the fallback device properly
Date: Thu, 15 May 2014 06:22:07 -0700
Message-ID: <1400160127.7973.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140515074311.GB32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48026 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825AbaEONWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 09:22:11 -0400
Received: by mail-pa0-f52.google.com with SMTP id fa1so1074442pad.25
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 06:22:10 -0700 (PDT)
In-Reply-To: <20140515074311.GB32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 09:43 +0200, Steffen Klassert wrote:
> We need to initialize the fallback device to have a correct mtu
> set on this device. Otherwise the mtu is set to null and the device
> is unusable.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/ipv4/ip_tunnel.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index b3f8597..25b8997 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -882,6 +882,7 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
>  	 */
>  	if (!IS_ERR(itn->fb_tunnel_dev)) {
>  		itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
> +		itn->fb_tunnel_dev->mtu = ip_tunnel_bind_dev(itn->fb_tunnel_dev);
>  		ip_tunnel_add(itn, netdev_priv(itn->fb_tunnel_dev));
>  	}
>  	rtnl_unlock();

Hi Steffen.

It would be nice if you also added the reference of the commit
adding the bug ;)

Thanks !
