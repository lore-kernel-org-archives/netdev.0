From: Harald Welte <laforge@netfilter.org>
Subject: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Mon, 30 Aug 2004 22:19:57 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040830201957.GY5824@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="I0oWFe1KborvVxk0"
Cc: netdev@oss.sgi.com, Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--I0oWFe1KborvVxk0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

Apparently a lot of people still have issues when combining MASQUERADE
and policy routing. =20

In those cases, the error path from net/ipv4/netfilter/ipt_MASQUERADE.c:

		if (rt->u.dst.dev !=3D out) {
			if (net_ratelimit())
				printk("MASQUERADE:"
				       " Route sent us somewhere else.\n");
			ip_rt_put(rt);
			return NF_DROP;
		}

is taken.

A couple of questions:

1) Why do we have this check in the first place?  What would be wrong
   with re-routing if the user requests us by configuration?

2) Why don't we include 'oif' in the routing key?  If we wanted to make
   sure that oif doesn't change, then we should tell the routing lookup
   rather than complaining afterwards, shouldn't we ?

I think the current code makes it hard (if not impossible?) for the
system adminsitrator to get it right (for no apparent reason to me).

Comments, anyone?
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--I0oWFe1KborvVxk0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBM4vtXaXGVTD0i/8RAjdSAKCCUFOPkWulwqfJqMtVHE0w6zJ5PgCeIsZ8
9YmgqQxEdALrQ9aH2g0poVg=
=5HdN
-----END PGP SIGNATURE-----

--I0oWFe1KborvVxk0--
