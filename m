From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Thu, 19 Aug 2004 12:11:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819101159.GC3921@sunbeam.de.gnumonks.org>
References: <20040818091352.GB6507@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xsILJLaVOAbiPmXa"
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        David Miller <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
Content-Disposition: inline
In-Reply-To: <20040818091352.GB6507@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--xsILJLaVOAbiPmXa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 18, 2004 at 11:13:52AM +0200, Olaf Kirch wrote:
> Hi,
>=20
> here's a patch that keeps us from crashing on removal of ip_conntrack.
> This problem came up during IBM's testing of SLES.

Thanks for this detailed bugreport and fix.

> I'm not sure if this issue has been submitted already.

Not that I'm aware of.

> To fix this, the patch below simply drops such skbs. A different fix
> could be to change the conntrack module to flush out all unassembled
> fragments when unloaded; an alternative patch for this is attached as
> well (this one is completely untested).

Since I don't want to put any more conntrack-specific code into the core
network stack, I'd rather go for the 'alternative patch'.

I'm not sure whether it's worth the effort to combine the two, i.e. only
flush entries with skb->dst =3D=3D NULL.

But especially since module unloading is EXPERIMENTAL anyway, I think
it's ok when we completely flush the fragemnt queue.

Dave, is this fine with you?  What solution would you prefer?

> Cheers
> Olaf
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--xsILJLaVOAbiPmXa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBJHzuXaXGVTD0i/8RAoUwAJ4pt8h/EGR14G0hNFLWKBM4fLXF2ACbBj6N
z3ThhO8OwdNK1tSfWX4n/+g=
=T3Q9
-----END PGP SIGNATURE-----

--xsILJLaVOAbiPmXa--
