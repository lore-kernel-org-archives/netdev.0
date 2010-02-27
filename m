From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 1/2] mq: support for bonding
Date: Sat, 27 Feb 2010 17:29:14 +0100
Message-ID: <1267288154.9082.23.camel@edumazet-laptop>
References: <310461267277260@webmail48.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:37992 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968550Ab0B0Qbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 11:31:51 -0500
Received: by bwz1 with SMTP id 1so324238bwz.21
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2010 08:31:49 -0800 (PST)
In-Reply-To: <310461267277260@webmail48.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 27 f=C3=A9vrier 2010 =C3=A0 16:27 +0300, "Oleg A. Arkhangelsk=
y" a
=C3=A9crit :
>=20
> Make bonding driver multiqueue aware.
>=20

I wish it could be true :)

> Signed-off-by: Oleg A. Arkhangelsky <sysoleg@yandex.ru>=20
>=20
> ---
>=20
>  drivers/net/bonding/bond_main.c |    5 +++--
>  drivers/net/bonding/bonding.h   |    1 +
>  2 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 430c022..ea4ff33 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4928,8 +4928,9 @@ int bond_create(struct net *net, const char *na=
me)
> =20
>  	rtnl_lock();
> =20
> -	bond_dev =3D alloc_netdev(sizeof(struct bonding), name ? name : "",
> -				bond_setup);
> +	bond_dev =3D alloc_netdev_mq(sizeof(struct bonding), name ? name : =
"",
> +				bond_setup,
> +				min_t(u32, BOND_MAX_TX_QUEUES, num_online_cpus()));
>  	if (!bond_dev) {
>  		pr_err("%s: eek! can't alloc netdev!\n", name);
>  		res =3D -ENOMEM;
> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bond=
ing.h
> index 257a7a4..4a6cfb4 100644
> --- a/drivers/net/bonding/bonding.h
> +++ b/drivers/net/bonding/bonding.h
> @@ -29,6 +29,7 @@
>  #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
> =20
>  #define BOND_MAX_ARP_TARGETS	16
> +#define BOND_MAX_TX_QUEUES	8=20
> =20
>  #define IS_UP(dev)					   \
>  	      ((((dev)->flags & IFF_UP) =3D=3D IFF_UP)	&& \
>=20
> ---
>=20

Hi Oleg

1) Could you explain why this arbitrary value (8) was chosen ?

My dev machine has 16 cpus, and my network card has 16 queues per NIC

2) This multi queue support is not a real one, since bond driver is
currently using a per device central lock (bond->lock and
bond->curr_slave_lock).
Every xmit has to get this lock(s) and performance is not optimal.



