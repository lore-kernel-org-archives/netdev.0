From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warnings after merge of the crypto tree
Date: Wed, 11 Mar 2015 11:56:37 +1100
Message-ID: <20150311115637.46f12569@canb.auug.org.au>
References: <20150310164417.540c18a4@canb.auug.org.au>
	<20150310060328.GA14997@gondor.apana.org.au>
	<20150310174454.7a92a3bd@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/Re04sXI+LyVWRFYWx_ZxyrP"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephan Mueller <smueller@chronox.de>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150310174454.7a92a3bd@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/Re04sXI+LyVWRFYWx_ZxyrP
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 10 Mar 2015 17:44:54 +1100 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> On Tue, 10 Mar 2015 17:03:28 +1100 Herbert Xu <herbert@gondor.apana.org.a=
u> wrote:
> >
> > On Tue, Mar 10, 2015 at 04:44:17PM +1100, Stephen Rothwell wrote:
> > >=20
> > > After merging the crypto tree, today's (and the past few days)
> > > linux-next build (powerpc allyesconfig) produced these warnings:
> > >=20
> > > crypto/algif_aead.c:561:2: warning: initialization from incompatible =
pointer type
> > >   .sendmsg =3D aead_sendmsg,
> > >   ^
> > > crypto/algif_aead.c:561:2: warning: (near initialization for 'algif_a=
ead_ops.sendmsg')
> > > crypto/algif_aead.c:563:2: warning: initialization from incompatible =
pointer type
> > >   .recvmsg =3D aead_recvmsg,
> > >   ^
> > > crypto/algif_aead.c:563:2: warning: (near initialization for 'algif_a=
ead_ops.recvmsg')
> > >=20
> > > Introduced by commit 400c40cf78da ("crypto: algif - add AEAD support"=
).
> >=20
> > This is a bit of a bummer.  What happened is that net-next has
> > killed the kiocb argument to sendmsg/recvmsg.  However, this
> > change is obviously not part of the crypto tree and algif_aead
> > only exists in the crypto tree.
> >=20
> > So Stephen could you fix this by hand until one of them is merged
> > upstream (just kill the first argument in aead_sendmsg/aead_recvmsg)?
>=20
> No worries, I will put a merge fix patch in from tomorrow (and send you
> a copy just in case).

This is what I applied:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 11 Mar 2015 11:51:30 +1100
Subject: [PATCH] crypto: fix for sendmsg/recvmsg API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 crypto/algif_aead.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/crypto/algif_aead.c b/crypto/algif_aead.c
index 527d27b023ab..001d8b5ad056 100644
--- a/crypto/algif_aead.c
+++ b/crypto/algif_aead.c
@@ -163,7 +163,7 @@ static void aead_data_wakeup(struct sock *sk)
 	rcu_read_unlock();
 }
=20
-static int aead_sendmsg(struct kiocb *unused, struct socket *sock,
+static int aead_sendmsg(struct socket *sock,
 			struct msghdr *msg, size_t size)
 {
 	struct sock *sk =3D sock->sk;
@@ -348,7 +348,7 @@ unlock:
 	return err ?: size;
 }
=20
-static int aead_recvmsg(struct kiocb *unused, struct socket *sock,
+static int aead_recvmsg(struct socket *sock,
 			struct msghdr *msg, size_t ignored, int flags)
 {
 	struct sock *sk =3D sock->sk;
--=20
2.1.4


--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/Re04sXI+LyVWRFYWx_ZxyrP
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU/5LMAAoJEMDTa8Ir7ZwVxFkP/1/qEYn/XY9klhVRR9GAtzcA
oWvWDIwn5AWsjmXhAADpbqLawoFrHM9Cz6gz277Qj4xbQjrwGpdpITXhl6FSNG8u
CrnQx8GMWXKQlYRKdTNfwZEO030UnRbqpzGZ7mIs2rLqP/1di9aFOcm7OBIffiwn
6Jy4OmJAcVUI+lj+pqdM9Dxy388j/nH2hwXosAmwaWrZQHVOLFuZ0Jh1kdophA8M
A833zrC7LPbI8zlmEhc3cP9dDnFwAX8MeqxuHnBKcIBT6EgEZd9L6RZyp7eXC/W+
h2hGO/ROUnYSdY9EuFitBAXhiQUM1RKZcoGdpDQrozaQp0AmqPa7Gs3XXE5t0A2T
p5ewTiidSUsgIEDCEz76LIOjzrW/XQwuh+VIzLa4hUQ+qz2FczB4scXzabGbHHcj
vW5x8FQfkuBLBQ9k1Fqa5ceJpI4Nsenj+2JSQvWIUBxJIpHhLxzhgl/P+pg+TSWZ
SfymCeUzB9AMe9jIGya16P2IWR4napg/N47glJz+saHIJlAyk/QaZEnCxxLey/6Q
q6TsPsxbR+2c+UE10oyY2im9wAQUtWv/pLhUCeag1etABvm46YJ5PQHdez5xrE8V
d/FaNUUhKIatQ7S5NFOuV2ogl8xGpxl5svTSim6n1t98H7sjj8kmAlNv5eB0wdsE
KTHRgzZvmGndIvAVl7cz
=ZNgb
-----END PGP SIGNATURE-----

--Sig_/Re04sXI+LyVWRFYWx_ZxyrP--
