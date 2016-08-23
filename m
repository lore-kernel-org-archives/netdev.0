From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 18:33:04 +0100
Message-ID: <1471973584.13300.161.camel@decadent.org.uk>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
         <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
         <1471962096.14381.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-VDbTbAPA/J9Jkvv4FV0U"
Cc: Avijit Kanti Das <avijitnsec@codeaurora.org>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Luis Henriques <luis.henriques@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471962096.14381.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VDbTbAPA/J9Jkvv4FV0U
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-08-23 at 07:21 -0700, Eric Dumazet wrote:
> On Tue, 2016-08-23 at 14:41 +0100, Luis Henriques wrote:
> >=20
> > > > From: Avijit Kanti Das <avijitnsec@codeaurora.org>
> >=20
> > memset() the structure ethtool_wolinfo that has padded bytes
> > but the padded bytes have not been zeroed out.
> >=20
> > Change-Id: If3fd2d872a1b1ab9521d937b86a29fc468a8bbfe
> > > > Signed-off-by: Avijit Kanti Das <avijitnsec@codeaurora.org>
> > ---
> > =C2=A0net/core/ethtool.c | 4 +++-
> > =C2=A01 file changed, 3 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 977489820eb9..6bf6362e8114 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> > @@ -1435,11 +1435,13 @@ static int ethtool_reset(struct net_device *dev=
, char __user *useraddr)
> > =C2=A0
> > =C2=A0static int ethtool_get_wol(struct net_device *dev, char __user *u=
seraddr)
> > =C2=A0{
> > -	struct ethtool_wolinfo wol =3D { .cmd =3D ETHTOOL_GWOL };
> > +	struct ethtool_wolinfo wol;
> > =C2=A0
> > =C2=A0	if (!dev->ethtool_ops->get_wol)
> > =C2=A0		return -EOPNOTSUPP;
> > =C2=A0
> > +	memset(&wol, 0, sizeof(struct ethtool_wolinfo));
> > +	wol.cmd =3D ETHTOOL_GWOL;
> > =C2=A0	dev->ethtool_ops->get_wol(dev, &wol);
> > =C2=A0
> > =C2=A0	if (copy_to_user(useraddr, &wol, sizeof(wol)))
>=20
> This would suggest a compiler bug to me.

Unfortunately the C standard does not guarantee that padding bytes are
initialised (at least not for automatic storage).

[...]
> If we can not rely on such constructs, we have hundreds of similar
> patches to submit.
[...]

Many such patches have been applied and can be found with:

=C2=A0 =C2=A0 git log --author=3Dkangjielu@gmail.com

Ben.

--=20
Ben Hutchings
The program is absolutely right; therefore, the computer must be wrong.
--=-VDbTbAPA/J9Jkvv4FV0U
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJXvIjQAAoJEOe/yOyVhhEJtfUQALXIYMWb+2bvIxm5Qxq+NOoD
R2R43GwWmBifdwzS8JPBpV5BoANZ2+KQzU2eeDrezfTbCI0/THcmJeUpO8FvfRgi
/Fj783ViOkVvcjjQ1BdtT9BTJqx2Lp2rI4Cjeo5hgOhBZU0uP2L8/lu23Z6Lbt+P
KQHXaoQnOXZi0F0kX2XmgDbSEtiOilDGlZmboBsDBpP/8hFcYf0Slt/U8XHx0HLv
L/hRxc/Xoo8WbAKgMNHJhNmuMVf2msZg2aYR+R/Rqvt2HaepGqwS7SxriJuDR0/Y
+QZj1fOBzP45n2aXRNTntb4FtcTk5yY0Oy4SFGv48w0pQb4RZAWIvd9D/It0WwvS
fxNQoKG1ZOXHC4LpYwW+9wzNPoDBIh3w5RCK/8k6D9SC5LmurEb+gIWHDLNfbMr5
QfKvM2g8cQxcUnD45h5BYEOuhOcHmhLNDR4atcqVtsrCB5AzcjWCetwZZkhCerjH
pPg0XXvuGHo+fXXzLYZZJBcblXeEuY2qkXeG2RjjLJyVt4mv0AIvBolDBISo7Pbf
+5xvGBW3LqV3/dDO3UABB2ugsgK+0PzHE2FfvV6M+R0I8OVlTPW9tahWB1M9kWRQ
xCbrzkGZCr7sa10kpDKAcyWieOm+NRHGp8nM/1rGKvIDuDiWWaGan4pj+j3bJC7f
FHOpT55LJh8UF9GIlJuN
=DgJM
-----END PGP SIGNATURE-----

--=-VDbTbAPA/J9Jkvv4FV0U--
