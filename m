From: Harald Welte <laforge@netfilter.org>
Subject: Re: port-based filtering of ESP packets with in-kernel IPsec?
Date: Wed, 30 Jul 2003 16:24:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730142411.GD4553@sunbeam.de.gnumonks.org>
References: <1059540296.16545.305.camel@k7.localnet>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="kvUQC+jR9YzypDnK"
Cc: netfilter@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org
Content-Disposition: inline
In-Reply-To: <1059540296.16545.305.camel@k7.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--kvUQC+jR9YzypDnK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 29, 2003 at 11:44:57PM -0500, Rick Kennell wrote:
> I asked about this last week in the general netfilter list, but it
> appears that most folks are still using FreeS/WAN for IPsec.

yes, most people will use a stable kernel rather than a development one
;)

> I'm using the in-kernel IPsec and want to be able to filter ESP packets
> based on protocol or port number.  These values are encapsulated in the
> ESP payload and are unavailable to netfilter.  If I were using
> FreeS/WAN, I could use standard netfilter techniques on the ipsec0
> device.  With the in-kernel IPsec, there's no extra pseudo-device with
> which to examine unencapsulated ESP packets.

true.

> It looks too me like netfilter sees the packet as ESP in all chains in
> all tables.  (I'd be delighted to be corrected.)

I haven't investigated the new in-kernel ESP implementation that far,
but your observation sounds reasonable (although I don't say this is the
desired behaviour).

> Since ESP packets that reach the mangle INPUT chain are destined for a
> local process, why not unencapsulate them just before that point? =20

Because NF_IP_LOCAL_IN (like all other hooks) are in the layer 3 stack,
and decapsulating ESP is inside a layer 4 protocol - thus it happens
after the ip stack has handed it over to the esp4 protocol engine.

> It might still be nice to have an indication that this was once an ESP
> packet for filtering, but that could be done by setting a mark in the
> mangle PREROUTING chain.

no. My preferred solution was something like adding a netfilter hook to
the xfrm4 engine, exactly after decapsulation / decryption of one layer,
i.e.  after xfrm_type.input was called.=20

iptables could then register the INPUT chain (or probably even a
seperate POSTXFRM chain) in order to filter on the respective packets.

> I realize that this would probably require some heavy lifting in the
> network layer to accomplish this nesting of functionality.

yes, this is why this should be discussed on the netdev list (Cc'ed).

I think this needs to be sorted out before 2.6.0-final will be released.

Any comments are appreciated.

> Am I missing something obvious?

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--kvUQC+jR9YzypDnK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/J9ULXaXGVTD0i/8RApDKAJ9Khp7Ne+MXX8f1gKyXpIwDUWegdgCfYY6g
xKhlDsfWItUGVBtroYz8EOs=
=qqO8
-----END PGP SIGNATURE-----

--kvUQC+jR9YzypDnK--
