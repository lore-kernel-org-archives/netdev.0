From: Harald Welte <laforge@netfilter.org>
Subject: Re: [NETFILTER] fix conntrack event cache deadlock
Date: Fri, 23 Sep 2005 11:25:52 +0200
Message-ID: <20050923092552.GC731@sunbeam.de.gnumonks.org>
References: <20050922143515.GD8917@rama.de.gnumonks.org>
	<20050922.234724.110942393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fwqqG+mf3f7vyBCB"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050922.234724.110942393.davem@davemloft.net>
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


--fwqqG+mf3f7vyBCB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 22, 2005 at 11:47:24PM -0700, David S. Miller wrote:
> From: Harald Welte <laforge@netfilter.org>
> Date: Thu, 22 Sep 2005 16:35:15 +0200
>=20
> > [NETFILTER] Fix conntrack event cache deadlock/oops
>=20
> Applied.  I hope that doing the event cache call outside
> the lock is safe?  It was not depending upon that protection
> in any way was it?

no, not at all.  It was a mistake to call it within the locked section.
The call was erroneously placed there, because it fitted there without
reorganizing the code flow.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--fwqqG+mf3f7vyBCB
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDM8ogXaXGVTD0i/8RAuIzAJ93dB0ZlcPJKKiekhEZvxg2SvHBHQCeLy1y
o745AkimxZHchIdcDvDkGj0=
=W81w
-----END PGP SIGNATURE-----

--fwqqG+mf3f7vyBCB--
