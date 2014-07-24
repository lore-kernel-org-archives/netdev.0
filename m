From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [net-next 01/10] net: Rename ndo_add_vxlan_port to ndo_add_udp_tunnel_port.
Date: Thu, 24 Jul 2014 09:40:50 +0300
Message-ID: <CAJZOPZ+5M1ufs26dN68ZU+2g6cZ5zkzNH03JLwLg+5o50B9=KQ@mail.gmail.com>
References: <1406024393-6778-1-git-send-email-azhou@nicira.com>
	<1406024393-6778-2-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andy Zhou <azhou@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:45528 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbaGXGkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 02:40:51 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so2738719qge.10
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 23:40:50 -0700 (PDT)
In-Reply-To: <1406024393-6778-2-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2014 at 1:19 PM, Andy Zhou <azhou@nicira.com> wrote:
>
> Rename ndo_add_vxlan_port() API provided by net_device_ops to
> ndo_add_udp_tunnel_port(). Generalized the API in preparation for
> up coming NICs and device drivers that may support offloading more
> UDP tunnels protocols besides VxLAN.  There is no behavioral changes
> with this patch.
>


[..]

>
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -650,9 +650,11 @@ static void vxlan_notify_add_rx_port(struct vxlan_sock *vs)
>
>         rcu_read_lock();
>         for_each_netdev_rcu(net, dev) {
> -               if (dev->netdev_ops->ndo_add_vxlan_port)
> -                       dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
> -                                                           port);
> +               if (!dev->netdev_ops->ndo_add_udp_tunnel_port)
> +                       continue;
> +
> +               dev->netdev_ops->ndo_add_udp_tunnel_port(dev, sa_family, port,
> +                                                        UDP_TUNNEL_TYPE_VXLAN);
>         }
>         rcu_read_unlock();
>  }



Such changes should be done in a manner which is as minimal as
possible and not introduce further cleanups
or style modifications, here the existing code say

if(ndo X is supported by dev Y)
   call it

Please stick to this and just replace the ndo name in this patch


>
> @@ -668,9 +670,10 @@ static void vxlan_notify_del_rx_port(struct vxlan_sock *vs)
>
>         rcu_read_lock();
>         for_each_netdev_rcu(net, dev) {
> -               if (dev->netdev_ops->ndo_del_vxlan_port)
> -                       dev->netdev_ops->ndo_del_vxlan_port(dev, sa_family,
> -                                                           port);
> +               if (!dev->netdev_ops->ndo_del_udp_tunnel_port)
> +                       continue;
> +               dev->netdev_ops->ndo_del_udp_tunnel_port(dev, sa_family, port,
> +                                                        UDP_TUNNEL_TYPE_VXLAN);
>         }
>         rcu_read_unlock();
>

same here
