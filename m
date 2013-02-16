From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 3/4] tunneling: Add generic UDP-Tunnel TSO.
Date: Sat, 16 Feb 2013 12:02:21 +0100
Message-ID: <CAHXqBFKEetEKjBDYjyJ8hWMBz4-H_F+Uz9HLfoaUYzcFxaQYMQ@mail.gmail.com>
References: <1360976774-1891-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	stephen@networkplumber.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f169.google.com ([209.85.210.169]:52181 "EHLO
	mail-ia0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752936Ab3BPLCm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 06:02:42 -0500
Received: by mail-ia0-f169.google.com with SMTP id j5so4078075iaf.28
        for <netdev@vger.kernel.org>; Sat, 16 Feb 2013 03:02:41 -0800 (PST)
In-Reply-To: <1360976774-1891-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/16 Pravin B Shelar <pshelar@nicira.com>:
> Adds generic tunneling TCP segment offloading support for IPv4-UDP
> based tunnels.
> GSO type is added to request this offload for a skb.
> netdev feature NETIF_F_UDP_TUNNEL is added for hardware offloaded
> udp-tunnel support. Currently no device supports this feature,
> software offload is used.
>
> This can be used by tunneling protocols like VXLAN.
>
> CC: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  include/linux/netdev_features.h |    7 ++-
>  include/linux/skbuff.h          |    2 +
>  net/ipv4/af_inet.c              |    6 ++-
>  net/ipv4/tcp.c                  |    1 +
>  net/ipv4/udp.c                  |  113 +++++++++++++++++++++++++++++=
+---------
>  net/ipv6/ip6_offload.c          |    1 +
>  net/ipv6/udp_offload.c          |   10 +++-
>  7 files changed, 109 insertions(+), 31 deletions(-)
>
> diff --git a/include/linux/netdev_features.h b/include/linux/netdev_f=
eatures.h
> index 3dd3934..6d7c474 100644
> --- a/include/linux/netdev_features.h
> +++ b/include/linux/netdev_features.h
> @@ -42,9 +42,9 @@ enum {
>         NETIF_F_TSO6_BIT,               /* ... TCPv6 segmentation */
>         NETIF_F_FSO_BIT,                /* ... FCoE segmentation */
>         NETIF_F_GSO_GRE_BIT,            /* ... GRE with TSO */
> -       /**/NETIF_F_GSO_LAST,           /* [can't be last bit, see GS=
O_MASK] */
> -       NETIF_F_GSO_RESERVED2           /* ... free (fill GSO_MASK to=
 8 bits) */
> -               =3D NETIF_F_GSO_LAST,
> +       NETIF_F_GSO_UDP_TUNNEL_BIT,     /* ... UDP TUNNEL with TSO */
> +       /**/NETIF_F_GSO_LAST =3D          /* last bit, see GSO_MASK *=
/
> +               NETIF_F_GSO_UDP_TUNNEL_BIT,
>
>         NETIF_F_FCOE_CRC_BIT,           /* FCoE CRC32 */
>         NETIF_F_SCTP_CSUM_BIT,          /* SCTP checksum offload */
> @@ -103,6 +103,7 @@ enum {
>  #define NETIF_F_RXFCS          __NETIF_F(RXFCS)
>  #define NETIF_F_RXALL          __NETIF_F(RXALL)
>  #define NETIF_F_GRE_GSO                __NETIF_F(GSO_GRE)
> +#define NETIF_F_UDP_TUNNEL     __NETIF_F(UDP_TUNNEL)

You might want to add it to NETIF_F_GSO_SOFTWARE mask since this
feature has software fallback.

Best Regards,
Micha=C5=82 Miros=C5=82aw
