From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: fix signed macaddress in sysfs
Date: Mon, 04 Jun 2007 13:40:55 +0200
Message-ID: <1180957255.11026.67.camel@johannes.berg>
References: <20070603220651.GA22070@charon.n2.diac24.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-DgnVOIkgZl/ZSpy8FCBp"
Cc: linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Wu <flamingice@sourmilk.net>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: David Lamparter <lists@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46602 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753820AbXFDLlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 07:41:09 -0400
In-Reply-To: <20070603220651.GA22070@charon.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-DgnVOIkgZl/ZSpy8FCBp
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-06-04 at 00:06 +0200, David Lamparter wrote:
> Fix signedness mixup making mac addresses show up strangely
> (like 00:11:22:33:44:ffffffaa) in /sys/class/ieee80211/*/macaddress.

Huh, my mistake, patch looks good. Do we care for this in .22 still?

Acked-by: Johannes Berg <johannes@sipsolutions.net>


> Signed-off-by: David Lamparter <equinox@diac24.net>
> ---
>=20
>  net/wireless/sysfs.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/wireless/sysfs.c b/net/wireless/sysfs.c
> index 7844be4..374d16d 100644
> --- a/net/wireless/sysfs.c
> +++ b/net/wireless/sysfs.c
> @@ -33,7 +33,7 @@ static ssize_t _show_permaddr(struct device *dev,
>                               struct device_attribute *attr,
>                               char *buf)
>  {
> -       char *addr =3D dev_to_rdev(dev)->wiphy.perm_addr;
> +       unsigned char *addr =3D dev_to_rdev(dev)->wiphy.perm_addr;
> =20
>         return sprintf(buf, "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x\n",
>                        addr[0], addr[1], addr[2], addr[3], addr[4], addr[=
5]);

This probably should also use MAC_FMT/MAC_ARG, hah. Oh well, I'll fix it
up later.

johannes

--=-DgnVOIkgZl/ZSpy8FCBp
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGY/pH/ETPhpq3jKURAg93AJ9wojXQKFh9zZ5GkfmAaWfgDMTUkACfSj1e
0veaauLDU90uX8sNCAS1FnQ=
=5fEw
-----END PGP SIGNATURE-----

--=-DgnVOIkgZl/ZSpy8FCBp--

