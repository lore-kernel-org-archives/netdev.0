From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Thu, 15 Jul 2004 20:59:17 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089910757.6114.965.camel@uganda>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>  <1089906936.6114.904.camel@uganda>
	 <1089908900.1027.77.camel@jzny.localdomain>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-c6beA3+FFR3nBPyCcawT"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1089908900.1027.77.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-c6beA3+FFR3nBPyCcawT
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-07-15 at 20:28, jamal wrote:
> On Thu, 2004-07-15 at 11:55, Evgeniy Polyakov wrote:
>=20
>=20
> > > OpenBSD's CARP does load balancing through Source Hashing (SH), which
> > UCARP=20
> > > lacks support for.
> >=20
> > Userspace can't in principle.
> > Current kernel implementation can't too, but it can. In principle.
>=20
> Easy with current traffic control extensions. We need an action written
> for this. User space dameon controls it.

Load balancing between different computers?
How nodes will know about each other using only tc extension?
Kernel traps packet, send info about it to userspace, it decides drop it
or not... Not very fast path.
Or you may hardcode parameters for packets to be sent through current
machine in it's rules, and userspace will decide only _when_ apply all
those rules. But if we want to change things we have following chain:
driver <-0-> stack <-1-> tc <-2-> userspace carp <-3-> stack <-4-> other
machine.
With kernel implementation we may avoid 2 and 3.

And the bigggest advantage of the CARP is that it may touch kernel bits.
For any situation that may occure in HA world and will require touching
kernel space we always need some inkernel agent and some state
machine/protocol to connect it to userspace...
CARP already may this.

>=20
> cheers,
> jamal
--=20
	Evgeniy Polaykov ( s0mbre )

Crash is better than data corruption. -- Art Grabowski

--=-c6beA3+FFR3nBPyCcawT
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA9rflIKTPhE+8wY0RAvxyAJ4s54HrUETsdr9DnLAQhbTb9xbJ6gCePj6T
yi2OQh4jNy2XwD7OkCmjtAE=
=JBey
-----END PGP SIGNATURE-----

--=-c6beA3+FFR3nBPyCcawT--
