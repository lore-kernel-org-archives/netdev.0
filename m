From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next-2.6] veth: Fix veth_dellink method
Date: Fri, 30 Oct 2009 16:07:51 -0700
Message-ID: <m1hbtgmqew.fsf@fess.ebiederm.org>
References: <4AEA8F0F.4030100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52172 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933013AbZJ3XHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 19:07:51 -0400
In-Reply-To: <4AEA8F0F.4030100@gmail.com> (Eric Dumazet's message of "Fri\, 30 Oct 2009 08\:00\:31 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> In commit 23289a37e2b127dfc4de1313fba15bb4c9f0cd5b
> (net: add a list_head parameter to dellink() method),
> I forgot to actually use this parameter in veth_dellink.
>
> I remember feeling a bit uncomfortable about veth_close(),
> because it does :
>
> netif_carrier_off(dev);
> netif_carrier_off(priv->peer);
>
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index ffb502d..9bed694 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -450,8 +450,8 @@ static void veth_dellink(struct net_device *dev, struct list_head *head)
>  	priv = netdev_priv(dev);
>  	peer = priv->peer;
>  
> -	unregister_netdevice(dev);
> -	unregister_netdevice(peer);
> +	unregister_netdevice_queue(dev, head);
> +	unregister_netdevice_queue(peer, head);

Unless I am mistaken you need to change the list_add_tail to
list_move_tail in unregister_netdevice_queue because we will be
adding each veth device twice.

Eric
