From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2/2] fix NF_QUEUE_NR() macro
Date: Fri, 12 Aug 2005 00:40:45 +0200
Message-ID: <20050811224045.GT5353@rama.de.gnumonks.org>
References: <200508111631.24785.netdev@axxeo.de>
	<E1E3Kt5-0006jy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2/Dpz40iF3jpiHxF"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Ingo Oeser <netdev@axxeo.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1E3Kt5-0006jy-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--2/Dpz40iF3jpiHxF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 12, 2005 at 07:46:55AM +1000, Herbert Xu wrote:
> Ingo Oeser <netdev@axxeo.de> wrote:
> >=20
> > What about using a brace more:
> >=20
> >>diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> >>--- a/include/linux/netfilter.h
> >>+++ b/include/linux/netfilter.h
> >>@@ -29,7 +29,7 @@
> >> #define NF_VERDICT_QMASK 0xffff0000
> >> #define NF_VERDICT_QBITS 16
> >>=20
> >>-#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK || =
NF_QUEUE)
> >>+#define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK | N=
F_QUEUE)
> >=20
> > #define NF_QUEUE_NR(x) ((x << NF_VERDICT_QBITS) & (NF_VERDICT_QMASK | N=
F_QUEUE))
>=20
> Actually, these two versions are different.  & is higher than | so
> Harald's version is actually=20
>=20
> #define NF_QUEUE_NR(x) (((x << NF_VERDICT_QBITS) & NF_VERDICT_QMASK) | NF=
_QUEUE)
>=20
> Which is it?

the latter.  So my original patch is right (and is also confirmed to
work in tests by some users and myself), I 'just' didn't review Ingo's
alternative line (embarrassing).

We have that saying in german: "I didn't see the wood because of all the
trees".  Somehow I feel like that now...

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--2/Dpz40iF3jpiHxF
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC+9PsXaXGVTD0i/8RApIbAJ47Wi3k7ntuLBWInGQ6RFS2nklyBQCdFWFi
1PUuc1ywjIXKOKv6IQg0OlY=
=r149
-----END PGP SIGNATURE-----

--2/Dpz40iF3jpiHxF--
