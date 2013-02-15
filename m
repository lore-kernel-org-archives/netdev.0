From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next 3/3] GRE: Add TCP segmentation offload for GRE
Date: Fri, 15 Feb 2013 03:35:11 +0100
Message-ID: <CAHXqBFJi57WA6vJsWEBrzz_-f7_iSYA8eN+Mta9-6rx9n9bfhw@mail.gmail.com>
References: <1360871101-2086-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	bhutchings@solarflare.com
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:49044 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932394Ab3BOCfj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 21:35:39 -0500
Received: by mail-ie0-f180.google.com with SMTP id bn7so4128486ieb.39
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 18:35:38 -0800 (PST)
In-Reply-To: <1360871101-2086-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/14 Pravin B Shelar <pshelar@nicira.com>:
> Following patch adds GRE protocol offload handler so that
> skb_gso_segment() can segment GRE packets.
> SKB GSO CB is added to keep track of total header length so that
> skb_segment can push entire header. e.g. in case of GRE, skb_segment
> need to push inner and outer headers to every segment.
> New NETIF_F_GRE_GSO feature is added for devices which support HW
> GRE TSO offload. Currently none of devices support it therefore GRE G=
SO
> always fall backs to software GSO.
[...]
> @@ -1044,6 +1102,14 @@ static int ipgre_tunnel_bind_dev(struct net_de=
vice *dev)
>                 mtu =3D 68;
>
>         tunnel->hlen =3D addend;
> +       if (tunnel->parms.o_flags & GRE_SEQ) {
> +               /* TCP offload with GRE SEQ is not supported. */
> +               dev->features &=3D ~NETIF_F_GSO_SOFTWARE;
> +               dev->hw_features &=3D ~NETIF_F_GSO_SOFTWARE;
> +       } else {
> +               dev->features |=3D NETIF_F_GSO_SOFTWARE;
> +               dev->hw_features |=3D NETIF_F_GSO_SOFTWARE;
> +       }

=46eature clipping belongs to ndo_fix_features. Here,
netdev_update_features() for the tunnel device should be called.

Wishing You Good Night,
Micha=C5=82 Miros=C5=82aw
