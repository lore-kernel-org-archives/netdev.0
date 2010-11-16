From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-2.6 PATCH] ipv6: fix missing in6_ifa_put in addrconf
Date: Tue, 16 Nov 2010 07:37:34 +0100
Message-ID: <1289889454.3364.122.camel@edumazet-laptop>
References: <20101116062921.31164.70903.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47980 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab0KPGhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 01:37:43 -0500
Received: by wyb28 with SMTP id 28so348721wyb.19
        for <netdev@vger.kernel.org>; Mon, 15 Nov 2010 22:37:42 -0800 (PST)
In-Reply-To: <20101116062921.31164.70903.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 novembre 2010 =C3=A0 22:29 -0800, John Fastabend a =C3=A9cr=
it :
> Fix ref count bug introduced by
>=20
> commit 2de795707294972f6c34bae9de713e502c431296
> Author: Lorenzo Colitti <lorenzo@google.com>
> Date:   Wed Oct 27 18:16:49 2010 +0000
>=20
> ipv6: addrconf: don't remove address state on ifdown if the address
> is being kept
>=20
>=20
> Fix logic so that addrconf_ifdown() decrements the inet6_ifaddr
> refcnt correctly with in6_ifa_put().
>=20
> Reported-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>=20
>  net/ipv6/addrconf.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index b41ce0f..aaa3ca4 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2754,13 +2754,13 @@ static int addrconf_ifdown(struct net_device =
*dev, int how)
>  			ifa->state =3D INET6_IFADDR_STATE_DEAD;
>  			spin_unlock_bh(&ifa->state_lock);
> =20
> -			if (state =3D=3D INET6_IFADDR_STATE_DEAD) {
> -				in6_ifa_put(ifa);
> -			} else {
> +			if (state !=3D INET6_IFADDR_STATE_DEAD) {
>  				__ipv6_ifa_notify(RTM_DELADDR, ifa);
>  				atomic_notifier_call_chain(&inet6addr_chain,
>  							   NETDEV_DOWN, ifa);
>  			}
> +
> +			in6_ifa_put(ifa);
>  			write_lock_bh(&idev->lock);
>  		}
>  	}
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks again John


