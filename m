From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/2] CARP implementation. HA master's failover.
Date: Thu, 15 Jul 2004 19:55:36 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089906936.6114.904.camel@uganda>
References: <1089898303.6114.859.camel@uganda>
	 <1089898595.6114.866.camel@uganda>
	 <1089902654.1029.23.camel@jzny.localdomain>
	 <1089905244.6114.887.camel@uganda>
Reply-To: johnpol@2ka.mipt.ru
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-O+AOsa057WIIMHb6aivy"
Cc: netdev@oss.sgi.com, netfilter-failover@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1089905244.6114.887.camel@uganda>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-O+AOsa057WIIMHb6aivy
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-07-15 at 19:27, Evgeniy Polyakov wrote:
> On Thu, 2004-07-15 at 18:44, jamal wrote:
> > Evgeniy,
> >=20
> > Why do you need to put this stuff in the kernel?
> > This should be implemented just the same way as VRRP was - in user
> > space.
>=20
> Hmm...
> Just because i think it works better being implemented in the kernel? :)
> I don't think it is a good answer thought.
>=20
> It is faster, it is more flexible, it has access to kernel space...

Just an addition[from private e-mail]:

> would it be possible to do load balancing at the network level with a=20
> userland only implementation?=20
>=20
> OpenBSD's CARP does load balancing through Source Hashing (SH), which
UCARP=20
> lacks support for.

Userspace can't in principle.
Current kernel implementation can't too, but it can. In principle.

But better implementation should use both carp and ct_sync and some load
balancing code, which should link ct_sync and carp.
OpenBSD has one disadvantage in this regard: it is not modular, so their
carp hooks live in if_ether.c.
In Linux we just need to use connection tracking.
ct_sync makes not exactly it but close to the idea.

> > BTW, is there a spec for this protocol or its one of those things where
> > you have to follow Yodas advice?
>=20
> Exactly :)
> Here are all links I found:
> http://www.countersiege.com/doc/pfsync-carp/
> http://www.openbsd.org/cgi-bin/man.cgi?query=3Dcarp&apropos=3D0&sektion=
=3D0&manpath=3DOpenBSD+Current&arch=3Di386&format=3Dhtml#SEE+ALSO
> http://www.openbsd.org/lyrics.html
> VRRP2 spec.
> http://www.openbsd.org/cgi-bin/cvsweb/src/sys/netinet/ip_carp.c
>=20
>=20
> I do want this to be in the mainline kernel, but actually I even don't
> think anyone will apply it.
> It is too special stuff for generic kernel, it has reserved 112 vrrp
> protocol number and so on...
> So if developers decide not to include or even not to discuss this cruft
> I will not beat myself by my heels. :)
>=20
> It just works as expected, it is reliable and simple.
> And it does it's work, so HA people would like it.
>=20
> > cheers,
> > jamal
--=20
	Evgeniy Polaykov ( s0mbre )

Crash is better than data corruption. -- Art Grabowski

--=-O+AOsa057WIIMHb6aivy
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA9qj3IKTPhE+8wY0RAmHfAJ42utg9iVc1Xda9ORYQwm2cPSPNagCdEmDZ
XazOtvHSPIDn8+XEzMEbfqw=
=Ul2U
-----END PGP SIGNATURE-----

--=-O+AOsa057WIIMHb6aivy--
