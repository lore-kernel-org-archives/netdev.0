From: Harald Welte <laforge@netfilter.org>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Fri, 5 Sep 2003 17:31:52 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030905153152.GA3623@obroa-skai.de.gnumonks.org>
References: <200309022116.41697.bdschuym@pandora.be> <20030903200426.59d0af4a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Cc: Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
	netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030903200426.59d0af4a.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 03, 2003 at 08:04:26PM -0700, David S. Miller wrote:
> On Tue, 2 Sep 2003 21:16:41 +0200
> Bart De Schuymer <bdschuym@pandora.be> wrote:
>=20
> > On Tuesday 02 September 2003 16:30, Arnaldo Carvalho de Melo wrote:
> > > The 1.786.1.54 changeset (i.e. the initial ipt_physdev.c one 8) creat=
ed
> >=20
> > Does this fix it?
>=20
> You can't use this fix.  This header and structure are used by
> userspace and "unsigned long" can be a different size in the
> kernel than it is in user space.
>=20
> Please, just remove the super-silly memcmp() optimization in
> the ipt_physdev.c code.

Dave, the respective code in ipt_physdev.c seems to be copied from
the ip_tables.c interface name match (which definitely has the same
alignment issues, btw).

The problem is that it is _not_ a simple reimplementation of memcmp(),
but a mask-compare.

People can do stuff like "-i ppp+", meaning that traffic from all
interfaces called "ppp<WHATEVER>" are matched.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/WKxnXaXGVTD0i/8RAuNfAKCihA9rrd0JcJDQzSqEChRHsGianQCgnmLd
k7bel9I7IL3TuD6rd7X4Stc=
=lQcX
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--
