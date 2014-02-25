From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] xfrm: Correctly parse netlink msg from 32bits
 ip command on 64bits host
Date: Tue, 25 Feb 2014 17:15:47 +0000
Message-ID: <1393348547.14067.18.camel@deadeye.wl.decadent.org.uk>
References: <1392801176-2656-1-git-send-email-fan.du@windriver.com>
	 <20140220095934.GF32371@secunet.com> <530C3B07.3090406@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Zc6df1+AZTk6v9oV+lkL"
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38834 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753296AbaBYRQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 12:16:01 -0500
In-Reply-To: <530C3B07.3090406@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Zc6df1+AZTk6v9oV+lkL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-25 at 14:41 +0800, Fan Du wrote:
>=20
> On 2014=E5=B9=B402=E6=9C=8820=E6=97=A5 17:59, Steffen Klassert wrote:
> > For now I think we should just refuse to do anything if someone tries
> > to configure ipsec with 32 bit tools on a 64 bit machine.
>=20
> I'm fine with your point, and it would be a good choice to inform user ab=
out
> this behavior other than just creating non-working SA and SP for user.
>=20
>=20
>  From 873812ec0fe8738f476de58a217e58ec47665180 Mon Sep 17 00:00:00 2001
> From: Fan Du <fan.du@windriver.com>
> Date: Tue, 25 Feb 2014 14:34:41 +0800
> Subject: [PATCH net-next] xfrm: Do not parse 32bits compiled xfrm netlink=
 msg on
>   64bits host
>=20
> structure like xfrm_usersa_info or xfrm_userpolicy_info has different siz=
eof
> when compiled as 32bits and 64bits due to not appending pack attribute in
> their definition. This will result in broken SA and SP information when u=
ser
> trying to configure them through netlink interface.
>=20
> Before forging a compatibility layer like we have it for system calls to =
map
> this correct. Inform user land about this situation instead of keeping si=
lent,
> then the upper test scripts could behave accordingly.
>=20
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   net/xfrm/xfrm_user.c |    4 ++++
>   1 file changed, 4 insertions(+)
>=20
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index 1ae3ec7..0249712 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -2347,6 +2347,10 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, =
struct nlmsghdr *nlh)
>   	const struct xfrm_link *link;
>   	int type, err;
>=20
> +#ifdef CONFIG_COMPAT
> +	if (is_compat_task())
> +		return -EPERM;

I think this needs a log message, as it is not at all obvious that EPERM
means you ran a binary from the 'wrong' architecture.

Ben.

> +#endif
>   	type =3D nlh->nlmsg_type;
>   	if (type > XFRM_MSG_MAX)
>   		return -EINVAL;

--=20
Ben Hutchings
Everything should be made as simple as possible, but not simpler.
                                                           - Albert Einstei=
n

--=-Zc6df1+AZTk6v9oV+lkL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwzPw+e/yOyVhhEJAQrX8Q//XzqUgVohd4Avqz/0W6bwUtc/UoDCkzxV
OZc/eZ4l/v/vt++wh7m16tAahA34QyyaHGjVFslG4DyCr0SdgBNw7SVWDdvpY3Ee
pjcF/B+5irlb3g32zeA/qfpHwdxl1wbIQFTt+vbOuWFI2zTZloqcNS6PuLStJuoo
90xktjDGQ1QfXb2ZaSkxK6lZhoIC4YhEGBosplQz17CSYubUykjeRCeK1Wngpt0F
wuHXYDiS+2NMuMudC8jC/4W+mBDUoVxp5bKIgY+iXiM+F0JRLnvec/w6aOqUiqKq
iz2JfF03bd8W4zQJ2HBBz4DXhFraAg7byK9TYCWkBAi2dv8xC3g0b6Fjf8CNSf+D
yBMbV5woyIaC28xsv8N8qdtpDFRO6aYhBFRoK3MARoPY7muZG1pa6GWcmAS/pMCB
cdAMWsHxd/lfx80GleZ/NuoBbCetrnqz6C0Xu6VHwe5UIxEVWT6fjDod+ryxCsaU
8V0E7zAaWYqj5eQOi3mMR1yi9qtYy8Jm8dyhOc8/x51cNYB00sCHsvrkOLvEnFDZ
GTc6pIcrUOMgfQbVaHjU5VfZ+voxi+dvTNZqSW4sMxKfK509dT5PXoqcC6avzeHi
9rZYAKqtHbNoQj9rybq414IyPsE9ffJ7PAn2doU+Wsl+MFVF7xuTg/29x8lsOmSO
0OKOIWMdbX4=
=k7vu
-----END PGP SIGNATURE-----

--=-Zc6df1+AZTk6v9oV+lkL--
