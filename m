From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.4] backport neighbour cache redesign
Date: Mon, 4 Oct 2004 22:15:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004201525.GF27499@sunbeam.de.gnumonks.org>
References: <20040930154753.GD1860@sunbeam.de.gnumonks.org> <20041004121759.26798f1d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="McOwgVabxjWRBDh+"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041004121759.26798f1d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--McOwgVabxjWRBDh+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 04, 2004 at 12:17:59PM -0700, David S. Miller wrote:
>=20
> Ok I started playing with this, here is what I have currently.
> Changes:
=20
> 2) Missing symbol exports for the new interfaces modules can use,
>    namely:
> 	neigh_lookup_nodev
> 	neigh_seq_start
> 	neigh_seq_next
> 	neigh_seq_stop

oh, sorry.  I just linked atm,decnet and ipv6 static so far :(

> 3) Delete instead of "#if 0" out the now totally unused code
>    inside of net/atm/clip.c

oops, that slipped through. embarrassing.

> We need to test and verify this patch a lot before I can toss
> such a big thing over to Marcelo, but I definitely intend to
> send this to him.

sure, I am well aware of that.  If it helps, at least the IPv4 part will
see some serious deployment after it has passed the Astaro QA :)

I'll keep you posted about that.

One additional note:

If we go back to the initial reason for all those modifications, it was
deployment in large networks.  The gc_thresh3 default of 1k is very
small, even if you have only 4 interfaces with /24, you will already max
out this default.

Now that the hash distribution is better, and the table resized
dynamically, we scale better with large neighbour caches.

I was thinking of registering with some notifiers and tuning gc_thresh3
automatically to be at least as large as the theoretical number of
immediate neigbhours.  At least for multiple /24 and /16 I think this is
still reasonable.

As soon as we go further up (/8 or ipv6) the limit basically becomes
'unlimited', since we won't be able to receive 2^24 arp-causing packets
per second anyway.

Or be even less conservative and say: there is no limit for neighbour
cache entries?  You mentioned that *BSD didn't have a limit, IIRC.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--McOwgVabxjWRBDh+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBYa9dXaXGVTD0i/8RAqk9AKCl8+z1EtZ21fZMea4QYSi/fZmjsgCgjVJ0
NuYUNyG4d28O8sIlgLAYsso=
=LV6w
-----END PGP SIGNATURE-----

--McOwgVabxjWRBDh+--
