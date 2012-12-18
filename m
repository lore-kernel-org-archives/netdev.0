From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] build: unbreak linkage of m_xt.so
Date: Tue, 18 Dec 2012 13:47:58 -0500
Message-ID: <201212181348.00379.vapier@gentoo.org>
References: <alpine.LNX.2.01.1212160119060.7193@nerf07.vanv.qr> <1355617968-26138-1-git-send-email-jengelh@inai.de> <20121218092130.1d3f4239@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6460055.t50IdOxJmL";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@inai.de>, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, urykhy@gmail.com,
	shemonc@gmail.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121218092130.1d3f4239@nehalam.linuxnetplumber.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart6460055.t50IdOxJmL
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Tuesday 18 December 2012 12:21:30 Stephen Hemminger wrote:
> On Sun, 16 Dec 2012 01:32:48 +0100 Jan Engelhardt wrote:
> > Commit v3.7.0~10 caused the variable new PKG_CONFIG variable never
> > to be present at the time of calling make, leading to tc/m_xt.so
> > not linked with -lxtables (result from pkg-config xtables --libs),
> > that in turn leading to
> >=20
> > tc: symbol lookup error: /usr/lib64/tc//m_xt.so: undefined symbol:
> > xtables_init_all
> >=20
> > Fixing that.
> >=20
> > --- a/configure
> > +++ b/configure
> > @@ -4,7 +4,6 @@
> >  INCLUDE=3D${1:-"$PWD/include"}
> >  : ${PKG_CONFIG:=3Dpkg-config}
> >  : ${CC=3Dgcc}
> > -echo "PKG_CONFIG:=3D${PKG_CONFIG}" >>Config
> >=20
> >  # Make a temp directory in build tree.
> >  TMPDIR=3D$(mktemp -d config.XXXXXX)
> > @@ -224,6 +223,7 @@ rm -f $TMPDIR/ipsettest.c $TMPDIR/ipsettest
> >  }
> > =20
> >  echo "# Generated config based on" $INCLUDE >Config
> > +echo "PKG_CONFIG:=3D${PKG_CONFIG}" >>Config
> >  echo "TC schedulers"
>=20
> Ok, manually did the diff (conflicted with other previous changes).

this patch is no longer necessary one you merged my:
	configure: move toolchain init to a function

it's actually undesirable to apply this after that since it makes the confi=
gure=20
script less clear again ...

sorry if my commit message wasn't obvious.
=2Dmike

--nextPart6460055.t50IdOxJmL
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ0LpgAAoJEEFjO5/oN/WB1IAQAL1PR8tSYOCBHvmLTWWVby2T
gNnBpsbRUjgu0oc6LwDOf1DuTZp4PqjD6/0dVa1MwGSchQWcsgII3op0t8ApBYZU
Jv1vvL8Uu383PMOv8YUa8uNQSlj6J1WxU/1xmP10dD2I46Huf15pRPtjbH1wcx3m
Z1/TYika3qIaaV0/Xq/btOJBe3oYmkO3OIwgqrSxGKN/beFKEpO/RUKozLke8O3w
euPGoUEvE4eQPf/KW38F+ebD+fIZbsRiWKzqUDEBptIRHti9qxcFML8mCT/9hWjN
vafKdWT/EBlMhOWOaB7OOPZG1jBYxp+q3Ur3fynhRDzYziRgoekD9kwr4byd/t86
ZIKm+16sthFAQQBwTZ7Gfjj0y275+3kxEMjvYran3pHowakcO10NTRjezJBIGjVE
N8hFfU25NC/TraOrT+4NkfHLo0SOs1dQlUItrrURmnfBhZFtfBMrSfGKMzE6CVq8
Y6WDvAJepceMDaC4ZY4UR0pWHYbIM573pG9s/TdnwiX5Bjx9DlCVYaNOrUyE+2IN
ErjVwRkN/wuHOKcATRLwqOGPjWnki7F+DevyD8K7JL5YHDiPhi8xfIa3JdTuUw1X
YTrocW6wWaC+BXNgv4sb++yvy+MvxeWrlzOVL2sxOTcVNGQlKCsdF/JPdiXxvuCN
jHE4Jx5HLuIi9YmoT+K0
=u2bt
-----END PGP SIGNATURE-----

--nextPart6460055.t50IdOxJmL--
