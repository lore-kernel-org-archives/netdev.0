From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH] batman-adv: Use kasprintf
Date: Sat, 28 Jun 2014 21:49:22 +0200
Message-ID: <53AF1C42.6000108@meshcoding.com>
References: <20140628183628.GA9946@himangi-Dell> <1403982781.9064.33.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="vjD2Wg1Nt7dvMMQjnCQBjUvMB8hBJqLte"
Cc: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	"David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, julia.lawall@lip6.fr
To: Joe Perches <joe@perches.com>,
	Himangi Saraogi <himangi774@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403982781.9064.33.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--vjD2Wg1Nt7dvMMQjnCQBjUvMB8hBJqLte
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi all,

On 28/06/14 21:13, Joe Perches wrote:
> diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
> index f40cb04..d6fba94 100644
> --- a/net/batman-adv/sysfs.c
> +++ b/net/batman-adv/sysfs.c
> @@ -896,7 +896,7 @@ int batadv_throw_uevent(struct batadv_priv *bat_pri=
v, enum batadv_uev_type type,
>  {
>  	int ret =3D -ENOMEM;
>  	struct kobject *bat_kobj;
> -	char *uevent_env[4] =3D { NULL, NULL, NULL, NULL };
> +	char *uevent_env[3];


Joe, why are you shortening this? kobject_uevent_env() expect a
NULL-terminating array (that is the forth cell).

=2E..

> =20
>  	ret =3D kobject_uevent_env(bat_kobj, KOBJ_CHANGE, uevent_env);

And how is this change reducing the code space?

For what concerns the labels, we use this pattern mostly all over the
code: one single label/exit-point with the related NULL checks. Do you
think that we can improve something by changing this? (I am not talking
about the fastpath here).


Cheers,

--=20
Antonio Quartulli


--vjD2Wg1Nt7dvMMQjnCQBjUvMB8hBJqLte
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJTrxxKAAoJEJgn97Bh2u9eff8P+gI+QRwbn5OvK/Unq4MHfSM0
CXGfUubGKCFufCl3JKsNIKkWDsxZelas1tbaVeCblxVCsdajf6tDQrYkFKlSfEYA
puRcocmaawtwDiQdwYYkybXgmhwbkAhymcVz6YetsG5UXnJdMCCFKLgaV44F+k4f
h/GS/j2lXU1IVs8PrnCmSutNZ9xhKB7DymAZnU7mpO9aa4XiEUqmKJ4ycajekwrk
vWO2rRw78XT/2rMmc0Z6gNMKMFI9tz6f59bbge8q85TWlUwFEEduEPj8BrJ1qH2u
5HmP+fqv5q8UY+1wRYQIIFyUPERHPcCuWPBM4ZhGr3rXSHIRJsdEpx7CuZJq0QM3
FlYlUNTypBT1J8y/qzzZLsLz088BR4kxV6aLy09PCfl/ipxv3+PV3w/Gijm2YgvZ
7tEX517WyRcQPEwSpMoX4guwqI5eNbSLvQmqjW+hxxDa1Yhz9QrJfk2NesGsS4lU
N742tEnAIFk/oM2+YRQ3HWf/1I+oLR9w9hD+jZsNUjEjs9ACySfr2baTPdDyRx9w
bqIS4RjYpBUnWMmnixXUi+WfN7uzS7c1aqCge5hW/pp2XuPS4vWcSj9Xt7F8E5I8
0tkI0rCADyHukt3mHT5ONO4FpCbpZ29Vfye0XbX0OVBy5F2or40lhZaMLqgaLaB6
ehRoQMYDnRAIQ0KaSwKY
=g2EJ
-----END PGP SIGNATURE-----

--vjD2Wg1Nt7dvMMQjnCQBjUvMB8hBJqLte--
