From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] af_unix: Guard against other == sk in
 unix_dgram_sendmsg
Date: Fri, 12 Feb 2016 19:54:07 +0000
Message-ID: <1455306847.2801.45.camel@decadent.org.uk>
References: <56B4BF9D.9070609@pmhahn.de> <56BC90E7.7040007@pmhahn.de>
	 <87fuwzkzr5.fsf@doppelsaurus.mobileactivedefense.com>
	 <1455210224.2801.21.camel@decadent.org.uk>
	 <87r3gjjgbu.fsf@doppelsaurus.mobileactivedefense.com>
	 <87egcjcd5j.fsf@doppelsaurus.mobileactivedefense.com>
	 <87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
	 <56BDA3A8.6070807@pmhahn.de>
	 <8760xuvz5w.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-eucIeXcnmD6Dq4e2R1Us"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Karolin Seeger <kseeger@samba.org>,
	Jason Baron <jbaron@akamai.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arvid Requate <requate@univention.de>,
	Stefan Gohmann <gohmann@univention.de>, netdev@vger.kernel.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Philipp Hahn <pmhahn@pmhahn.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8760xuvz5w.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-eucIeXcnmD6Dq4e2R1Us
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-02-12 at 13:25 +0000, Rainer Weikusat wrote:
> Philipp Hahn <pmhahn@pmhahn.de> writes:
>=20
> > Hello Rainer,
> >=20
> > Am 11.02.2016 um 20:37 schrieb Rainer Weikusat:
> > > The unix_dgram_sendmsg routine use the following test
> > >=20
> > > if (unlikely(unix_peer(other) !=3D sk && unix_recvq_full(other))) {
>=20
> [...]
>=20
> > > This isn't correct as the> specified address could have been bound to
> > > the sending socket itself
>=20
> [...]
>=20
> > After applying that patch at least my machine running the samba test no
> > longer crashes.
>=20
> There's a possible gotcha in there: Send-to-self used to be limited by
> the queue limit. But the rationale for that (IIRC) was that someone
> could keep using newly created sockets to queue ever more data to a
> single, unrelated receiver. I don't think this should apply when
> receiving and sending sockets are identical. But that's just my
> opinion. The other option would be to avoid the unix_state_double_lock
> for sk =3D=3D other.

Given that unix_state_double_lock() already handles sk =3D=3D other, I'm
not sure why you think it needs to be avoided.

> I'd be willing to change this accordingly if someone
> thinks the queue limit should apply to send-to-self.

If we don't check the queue limit here, does anything else prevent the
queue growing to the point it's a DoS?

Ben.

--=20
Ben Hutchings
I say we take off; nuke the site from orbit.  It's the only way to be sure.
--=-eucIeXcnmD6Dq4e2R1Us
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVr44X+e/yOyVhhEJAQpfZw//fJstdZ6Bm90Ap3XM/KuXyBxoSjOiApYX
8rIqs06wHj66MbZrexLYuZQh49iu7tYQUhAzlT4nIggLIjDnZxHN5L1dKH7DiZw7
iiIVUX7kneoHwhG3DmuGFm/BRpVEbdiSkE93dBDMWCHi+L24sd57V/0E2sj1ToxJ
GFGq8YFVMFC1PlZqpswztel3CRTOJGdL1RDG8qkujx1txLijP3jnSs5bVyHTYJLJ
KkuOtpqtKk3aMPzCPTl2YYq/OXq19uR8TPA+rBKbCHjO6YL990UgmtZKgtptiMw1
6uveFhDsHwesy/D1P2/D7XLgsOnqgEndquFTxoEByneY+e+54Nl/tmNw8Vat0JdE
2/6M9v7QuvX1d5KdWF8aMwE724lo1pIKZaSRZKNNKnU+avIxpvF4uZfEfys01knt
IsS2cm+kObW+e24rp5tYJcyeKvk+m+fyx0v+osBxs7BQmMZduFWOY/gmihLaxjhN
jMlhQ/vceCgQcayqrhDQwW3mD+Sep10qfeS/RfsashQ+Qs5CmP7Bvj30zwF6gee/
jO1mUdvlq3e8cLQAsjyUMYkc0spxZkC9H7+13Z/nqap4m64sRD02TMmHzicph+2U
DrYyjukI2aERyV6RN+ufA7hOsylnAMRC9t5C+IysPq5CrRDNO2oITFHJf/jZu0ta
ETFDhI/lCWE=
=ocG0
-----END PGP SIGNATURE-----

--=-eucIeXcnmD6Dq4e2R1Us--
