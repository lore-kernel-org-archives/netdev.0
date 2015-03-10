From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warnings after merge of the crypto tree
Date: Tue, 10 Mar 2015 17:44:54 +1100
Message-ID: <20150310174454.7a92a3bd@canb.auug.org.au>
References: <20150310164417.540c18a4@canb.auug.org.au>
	<20150310060328.GA14997@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/5lTXcqKJHoPqxzLCkXMf2qu"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephan Mueller <smueller@chronox.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20150310060328.GA14997@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/5lTXcqKJHoPqxzLCkXMf2qu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Herbert,

On Tue, 10 Mar 2015 17:03:28 +1100 Herbert Xu <herbert@gondor.apana.org.au>=
 wrote:
>
> On Tue, Mar 10, 2015 at 04:44:17PM +1100, Stephen Rothwell wrote:
> >=20
> > After merging the crypto tree, today's (and the past few days)
> > linux-next build (powerpc allyesconfig) produced these warnings:
> >=20
> > crypto/algif_aead.c:561:2: warning: initialization from incompatible po=
inter type
> >   .sendmsg =3D aead_sendmsg,
> >   ^
> > crypto/algif_aead.c:561:2: warning: (near initialization for 'algif_aea=
d_ops.sendmsg')
> > crypto/algif_aead.c:563:2: warning: initialization from incompatible po=
inter type
> >   .recvmsg =3D aead_recvmsg,
> >   ^
> > crypto/algif_aead.c:563:2: warning: (near initialization for 'algif_aea=
d_ops.recvmsg')
> >=20
> > Introduced by commit 400c40cf78da ("crypto: algif - add AEAD support").
>=20
> This is a bit of a bummer.  What happened is that net-next has
> killed the kiocb argument to sendmsg/recvmsg.  However, this
> change is obviously not part of the crypto tree and algif_aead
> only exists in the crypto tree.
>=20
> So Stephen could you fix this by hand until one of them is merged
> upstream (just kill the first argument in aead_sendmsg/aead_recvmsg)?

No worries, I will put a merge fix patch in from tomorrow (and send you
a copy just in case).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/5lTXcqKJHoPqxzLCkXMf2qu
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU/pLqAAoJEMDTa8Ir7ZwVq0oP/27PkDBTEKnE/T8yuD8gF051
n74nVM/N94ngVA7LevnIh7vrTwqS0opD0+yvLOU2V4SpYxIUMRZYbFOfOq1ntRAi
zutVQMOvziMmmA3g6RTte6OV+5b+2yKzogwWuI4Dv9cxVt9JCLXcTK3IwP5Gs+za
gob7G6N7ZGLL7kLTCZJhfar+P0P9QYuv6/zrXejC0okCPVuxndedSB8z3Z+X5sit
XnAQJFGQV/gDX2kj+37+ge3Y8NF2DY/vpsC1dFo5rMz3bj1EfsDAO9TniY321Opg
HAau62y3KJaXn+mOS0TlqqooewnDoErOUjYVmd6LcSkizV3+VPajcPWr+xttU2fq
zmdfuBFcAzXD8WoIAfsKdgb2gXXnZAvb/kahJz5TshDKvMWdBb+GQsRzRiFIeGNa
pjjKrcAA8EDO+827yBXClukRjJkbCAC6oLabSfti+u7YTmB/tlqHK8GYmhy2aT1+
4DmDi7+u2J8azRLGk4vZH/l6jhNMJyNvJLj4BLZmuajhorUG5Jwh41ECsugeLxMl
cab7K94zNNGyumUTN3ftBgsS2w0QQYNw+N3Edo5xZeOieQJyszoexGPKM8YzTOtT
xGsIYdj1+L7lW9tVAH0TLbsbmPxLasC3GiJu8kAn6C4HjzcbVQvDJ0E1MDj8/Ssx
FG2I6KhrbsmlSFbDrvCX
=h97C
-----END PGP SIGNATURE-----

--Sig_/5lTXcqKJHoPqxzLCkXMf2qu--
