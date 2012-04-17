From: David Lamparter <equinox@diac24.net>
Subject: Re: Netlink, route monitoring, RTM_DELROUTE not issued for ppp peer
 address. Bug or feature?
Date: Tue, 17 Apr 2012 10:24:53 +0200
Message-ID: <20120417082453.GI3324248@jupiter.n2.diac24.net>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
 <023e01cd197d$a9faba40$fdf02ec0$@no>
 <3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
 <20120416081954.1bb994db@nehalam.linuxnetplumber.net>
 <9c375f4b88835bcde92bf3ba8f3434cc@visp.net.lb>
 <2f6d1271c8c6811acbbc5b2603c72115.squirrel@nlc.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3eH4Qcq5fItR5cpy"
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@vyatta.com>,
	eric.dumazet@gmail.com, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: Stian Skjelstad <stian@nixia.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:43651 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185Ab2DQIY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 04:24:58 -0400
Content-Disposition: inline
In-Reply-To: <2f6d1271c8c6811acbbc5b2603c72115.squirrel@nlc.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3eH4Qcq5fItR5cpy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 16, 2012 at 10:21:46PM +0200, Stian Skjelstad wrote:
> > It looks like "correct" behavior should not harm existing programs that
> > much (just there will be netlink message to delete route that are
> > already deleted by program, e.g. quagga), but looking to code,
> > implementing this feature will make significant overhead and in some
> > cases it can be harmful.
> > For example if full view BGP interface dropped, it is hundreds of
> > thousands netlink messages. So seems better i will listen to
> > address/link changes also and keep routing table in memory.
> > So better seems to keep as is.

Yes, this concern is quite real, I'd very much like to avoid processing
400000 DELROUTE messages that add exactly 0 additional meaning since it
can be inferred from the interface going down.

> If I understand correct, the "missing" RTM_DELROUTE messages actually
> comes from something similar to "ip route flush dev eth0".
>=20
> If the amount of traffic is a worry, couldn't there be a RTM_FLUSHROUTE or
> a special RTM_DELROUTE message that tells that all routes for a given
> device is removed?

The interface-down message has exactly these semantics. I don't know
if/where this is documented, but adding a new message seems superfluous
to me, especially at this point where compatibility is a concern.
(The ip route flush command deletes routes individually btw.)

-David

--3eH4Qcq5fItR5cpy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iF4EAREIAAYFAk+NKNUACgkQCy20tTec6eM1ZQD/YLoyOvFfB2oFQVxoF2Xgi+5n
XEptIfjAA95JEKmRfPkA/3AL/uljYQPmAxMjQJTYtqhfiLam8gtpWJS7VKmrkxAq
=ibrd
-----END PGP SIGNATURE-----

--3eH4Qcq5fItR5cpy--
