From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6] macvlan: do a proper cleanup in macvlan_common_newlink()
Date: Mon, 24 May 2010 20:56:32 +0200
Message-ID: <4BFACBE0.4020109@trash.net>
References: <20100524155857.GO2810@psychotron.lab.eng.brq.redhat.com> <20100524170224.GA2816@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36353 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755124Ab0EXS4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 14:56:33 -0400
In-Reply-To: <20100524170224.GA2816@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Mon, May 24, 2010 at 05:58:58PM CEST, jpirko@
> Subject: [PATCH net-2.6] macvlan: do proper cleanup in macvlan_common_newlink() V2
> 
> Fixes possible memory leak.

Looks good, thanks.

> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Acked-by: Patrick McHardy <kaber@trash.net>

> ---
>  drivers/net/macvlan.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 4e238af..87e8d4c 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -634,11 +634,18 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>  
>  	err = register_netdevice(dev);
>  	if (err < 0)
> -		return err;
> +		goto destroy_port;
>  
>  	list_add_tail(&vlan->list, &port->vlans);
>  	netif_stacked_transfer_operstate(lowerdev, dev);
> +
>  	return 0;
> +
> +destroy_port:
> +	if (list_empty(&port->vlans))
> +		macvlan_port_destroy(lowerdev);
> +
> +	return err;
>  }
>  EXPORT_SYMBOL_GPL(macvlan_common_newlink);
>  

