From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next 2/2] gre: add GSO support
Date: Fri, 14 Sep 2012 10:12:06 -0700
Message-ID: <CANP3RGckqqPnmfLjfqxOKuxJEkvzN9-5v+BqVZ_9GuYyo+EDHw@mail.gmail.com>
References: <1347607533.8555.269.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50831 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245Ab2INRMH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 13:12:07 -0400
Received: by iahk25 with SMTP id k25so3216478iah.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 10:12:06 -0700 (PDT)
In-Reply-To: <1347607533.8555.269.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks!

So I'm guessing it should be easy to add support like this to IPIP and
SIT now as well
(not sure if they're missing, but I'd assume so)?

On Fri, Sep 14, 2012 at 12:25 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Add GSO support to GRE tunnels.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  net/ipv4/ip_gre.c |   12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index b062a98..f233c1d 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -745,6 +745,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_b=
uff *skb, struct net_device *dev
>         __be32 dst;
>         int    mtu;
>
> +       if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL &&
> +           skb_checksum_help(skb))
> +               goto tx_error;
> +
>         if (dev->type =3D=3D ARPHRD_ETHER)
>                 IPCB(skb)->flags =3D 0;
>
> @@ -1296,6 +1300,11 @@ static void ipgre_dev_free(struct net_device *=
dev)
>         free_netdev(dev);
>  }
>
> +#define GRE_FEATURES (NETIF_F_SG |             \
> +                     NETIF_F_FRAGLIST |        \
> +                     NETIF_F_HIGHDMA |         \
> +                     NETIF_F_HW_CSUM)
> +
>  static void ipgre_tunnel_setup(struct net_device *dev)
>  {
>         dev->netdev_ops         =3D &ipgre_netdev_ops;
> @@ -1309,6 +1318,9 @@ static void ipgre_tunnel_setup(struct net_devic=
e *dev)
>         dev->addr_len           =3D 4;
>         dev->features           |=3D NETIF_F_NETNS_LOCAL;
>         dev->priv_flags         &=3D ~IFF_XMIT_DST_RELEASE;
> +
> +       dev->features           |=3D GRE_FEATURES;
> +       dev->hw_features        |=3D GRE_FEATURES;
>  }
>
>  static int ipgre_tunnel_init(struct net_device *dev)
>
>
>
