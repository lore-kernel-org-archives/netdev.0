From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v5 net-next 01/14] gso: Remove arbitrary checks for
 unsupported GSO
Date: Mon, 16 May 2016 09:49:33 -0700
Message-ID: <CAKgT0UceFCg+uC8ehZTvxvP6gg+i+QWy72uv+7bGjUAycZQ=9g@mail.gmail.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
	<1463355755-3481375-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33921 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358AbcEPQte convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 12:49:34 -0400
Received: by mail-io0-f173.google.com with SMTP id 190so217087488iow.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 09:49:34 -0700 (PDT)
In-Reply-To: <1463355755-3481375-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 15, 2016 at 4:42 PM, Tom Herbert <tom@herbertland.com> wrot=
e:
> In several gso_segment functions there are checks of gso_type against
> a seemingly arbitrary list of SKB_GSO_* flags. This seems like an
> attempt to identify unsupported GSO types, but since the stack is
> the one that set these GSO types in the first place this seems
> unnecessary to do. If a combination isn't valid in the first
> place that stack should not allow setting it.
>
> This is a code simplication especially for add new GSO types.
>
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  net/ipv4/af_inet.c     | 18 ------------------
>  net/ipv4/gre_offload.c | 14 --------------
>  net/ipv4/tcp_offload.c | 19 -------------------
>  net/ipv4/udp_offload.c | 10 ----------
>  net/ipv6/ip6_offload.c | 18 ------------------
>  net/ipv6/udp_offload.c | 13 -------------
>  net/mpls/mpls_gso.c    |  9 ---------
>  7 files changed, 101 deletions(-)
>

<...>

> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index bbcf604..6de1e13 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -26,15 +26,6 @@ static struct sk_buff *mpls_gso_segment(struct sk_=
buff *skb,
>         netdev_features_t mpls_features;
>         __be16 mpls_protocol;
>
> -       if (unlikely(skb_shinfo(skb)->gso_type &
> -                               ~(SKB_GSO_TCPV4 |
> -                                 SKB_GSO_TCPV6 |
> -                                 SKB_GSO_UDP |
> -                                 SKB_GSO_DODGY |
> -                                 SKB_GSO_TCP_FIXEDID |
> -                                 SKB_GSO_TCP_ECN)))
> -               goto out;
> -
>         /* Setup inner SKB. */
>         mpls_protocol =3D skb->protocol;
>         skb->protocol =3D skb->inner_protocol;

So this last bit here introduces a warning:

net/mpls/mpls_gso.c: In function =E2=80=98mpls_gso_segment=E2=80=99:
net/mpls/mpls_gso.c:51:1: warning: label =E2=80=98out=E2=80=99 defined =
but not used
[-Wunused-label]
 out:
 ^

If you drop the label out from mpls_gso_segment then that should resolv=
e it.

- Alex
