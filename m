From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 72/84] netfilter: xtables: inclusion of xt_TEE
Date: Mon, 10 May 2010 22:52:59 +0200
Message-ID: <1273524779.2590.236.camel@edumazet-laptop>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
	 <1273522735-24672-73-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:34562 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321Ab0EJUxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:53:18 -0400
In-Reply-To: <1273522735-24672-73-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 mai 2010 =C3=A0 22:18 +0200, kaber@trash.net a =C3=A9crit :
> From: Jan Engelhardt <jengelh@medozas.de>
>=20
> xt_TEE can be used to clone and reroute a packet. This can for
> example be used to copy traffic at a router for logging purposes
> to another dedicated machine.
>=20
> References: http://www.gossamer-threads.com/lists/iptables/devel/6878=
1
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---

> +static bool tee_tg_route_oif(struct flowi *f, struct net *net,
> +			     const struct xt_tee_tginfo *info)
> +{
> +	const struct net_device *dev;
> +
> +	if (*info->oif !=3D '\0')
> +		return true;
> +	dev =3D dev_get_by_name(net, info->oif);
> +	if (dev =3D=3D NULL)
> +		return false;
> +	f->oif =3D dev->ifindex;
> +	return true;
> +}
> +

This leaks a refcount on device.

But I see patch 76/84 replaces the whole thing, so this is probably
harmless.




