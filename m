From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Don't dev_hold(dev) in ip6_mc_find_dev_rcu.
Date: Fri, 16 Mar 2012 07:15:53 -0700
Message-ID: <1331907353.2420.1.camel@edumazet-laptop>
References: <1331888054-21072-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:39316 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852Ab2CPOP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 10:15:57 -0400
Received: by pbcun15 with SMTP id un15so209242pbc.19
        for <netdev@vger.kernel.org>; Fri, 16 Mar 2012 07:15:56 -0700 (PDT)
In-Reply-To: <1331888054-21072-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 mars 2012 =C3=A0 16:54 +0800, roy.qing.li@gmail.com a =C3=
=A9crit :
> From: RongQing.Li <roy.qing.li@gmail.com>
>=20
> ip6_mc_find_dev_rcu() is called with rcu_read_lock(), so don't
> need to dev_hold().
> With dev_hold(), not corresponding dev_put(), will lead to leak.
>=20
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
> ---
>  net/ipv6/mcast.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index b853f06..16c33e3 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -257,7 +257,6 @@ static struct inet6_dev *ip6_mc_find_dev_rcu(stru=
ct net *net,
> =20
>  		if (rt) {
>  			dev =3D rt->dst.dev;
> -			dev_hold(dev);
>  			dst_release(&rt->dst);
>  		}
>  	} else

Nice catch, bug introduced in 96b52e61be1 (ipv6: mcast: RCU conversions=
)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
