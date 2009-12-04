From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix "waiting for %s to become free" hang
Date: Fri, 04 Dec 2009 12:40:58 +0100
Message-ID: <4B18F54A.8000106@gmail.com>
References: <20091204112734.24535.86096.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51141 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701AbZLDLlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 06:41:01 -0500
In-Reply-To: <20091204112734.24535.86096.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar a =E9crit :
> From: Krishna Kumar <krkumar2@in.ibm.com>
>=20
> (From code-walkthrough, and untested)
>=20
> Fix "waiting for %s to become free" hang. dev has an
> extra hold (by ip6mr_reg_vif) which was not dropped
> before calling unregister_netdevice.
>=20
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  net/ipv6/ip6mr.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff -ruNp org/net/ipv6/ip6mr.c new/net/ipv6/ip6mr.c
> --- org/net/ipv6/ip6mr.c	2009-12-04 16:08:07.000000000 +0530
> +++ new/net/ipv6/ip6mr.c	2009-12-04 16:09:56.000000000 +0530
> @@ -648,8 +648,8 @@ static int mif6_add(struct net *net, str
>  			return -ENOBUFS;
>  		err =3D dev_set_allmulti(dev, 1);
>  		if (err) {
> -			unregister_netdevice(dev);
>  			dev_put(dev);
> +			unregister_netdevice(dev);
>  			return err;
>  		}
>  		break;

This changes nothing, since we hold rtnl at this point.

unregister_netdevice() only queues the device (net_set_todo()) in a lis=
t.

And we process this list later, when renl_unlock() is finally called.

