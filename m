From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv4: remove all rt cache entries on UNREGISTER event
Date: Wed, 22 Dec 2010 09:32:44 +0100
Message-ID: <4D11B7AC.8000205@6wind.com>
References: <4CA208C9.1020800@6wind.com>	 <1285691629.3154.80.camel@edumazet-laptop>  <4CA21BC6.5070300@6wind.com>	 <1285692969.3154.86.camel@edumazet-laptop>  <4CA2EF9C.9040909@6wind.com>	 <1285749349.2615.27.camel@edumazet-laptop> <1285751929.2615.30.camel@edumazet-laptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57990 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab0LVIcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 03:32:53 -0500
Received: by wyb28 with SMTP id 28so4780707wyb.19
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 00:32:52 -0800 (PST)
In-Reply-To: <1285751929.2615.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What is the status of this patch? The initial problem is still here in =
2.6.37-rc5+


Regards,
Nicolas

Le 29.09.2010 11:18, Eric Dumazet a =C3=A9crit :
> I found following patch was enough to avoid route being created if
> device is down. This is still racy and needs more thinking.
>=20
>=20
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index ac6559c..1ee0b1a 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -2586,9 +2586,10 @@ static int ip_route_output_slow(struct net *ne=
t, struct rtable **rp,
>  			goto out;
> =20
>  		/* RACE: Check return value of inet_select_addr instead. */
> -		if (__in_dev_get_rtnl(dev_out) =3D=3D NULL) {
> +		if (!(dev_out->flags & IFF_UP) || __in_dev_get_rtnl(dev_out) =3D=3D=
 NULL) {
>  			dev_put(dev_out);
> -			goto out;	/* Wrong error code */
> +			err =3D -ENETUNREACH;
> +			goto out;
>  		}
> =20
>  		if (ipv4_is_local_multicast(oldflp->fl4_dst) ||
>=20
>=20
