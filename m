From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: release idev when ip6_neigh_lookup failed in
 icmp6_dst_alloc
Date: Fri, 13 Jan 2012 10:48:41 +0100
Message-ID: <1326448121.2272.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326443626-19580-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:36609 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752686Ab2AMJsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 04:48:46 -0500
Received: by lago2 with SMTP id o2so164027lag.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 01:48:44 -0800 (PST)
In-Reply-To: <1326443626-19580-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 13 janvier 2012 =C3=A0 16:33 +0800, roy.qing.li@gmail.com a
=C3=A9crit :
> From: RongQing.Li <roy.qing.li@gmail.com>
>=20
> release idev when ip6_neigh_lookup failed in icmp6_dst_alloc
>=20
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
> ---
>  net/ipv6/route.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 07361df..8c2e3ab 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -1091,6 +1091,7 @@ struct dst_entry *icmp6_dst_alloc(struct net_de=
vice *dev,
>  	else {
>  		neigh =3D ip6_neigh_lookup(&rt->dst, &fl6->daddr);
>  		if (IS_ERR(neigh)) {
> +			in6_dev_put(idev);
>  			dst_free(&rt->dst);
>  			return ERR_CAST(neigh);
>  		}

Good catch, thanks.

Bug added in commit b43faac6906 (ipv6: If neigh lookup fails during
icmp6 dst allocation, propagate error.),=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
