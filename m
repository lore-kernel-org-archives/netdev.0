From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on postrouting hook
Date: Tue, 17 Feb 2004 16:54:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040217155452.GA9464@sunbeam.de.gnumonks.org>
References: <402E71E2.1040508@kolumbus.fi> <Xine.LNX.4.44.0402142314580.7364-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0402142314580.7364-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Feb 15, 2004 at 01:09:23AM -0500, James Morris wrote:
> On Sat, 14 Feb 2004, Mika Penttil=E4 wrote:
>=20
> > James Morris wrote:
> >=20
> > >The proposed solution below is to copy the skb rather than clone it, t=
o=20
> > >ensure that the original and looped back packets are independent.
> > >
> >
> > This is unneeded overhead for the common case. The right fix is to make=
=20
> > sure the modifier (netfilter etc) makes the copy if needed. Actually,=
=20
> > this is what skb_ip_make_writable() is doing.
>=20
> The common case here will be only for locally generated multicast and=20
> broadcast packets.
>=20
> If the netfilter core code is modified instead, we will end up adding
> skb_ip_make_writable() to nf_hook_slow() which will be called for every=
=20
> packet with an output device which uses hardware checksums.
>=20
> Not sure which is worse, but here's a proposed patch which does this.
=20
Why can't we somehow check inside the netfilter hook if the packet is
at least multicast/broadcast (or even better: also locally generated)?

> - James
> James Morris
--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAMjlMXaXGVTD0i/8RAp0tAJ0WeghJUFB2tUxVH8xcQsIfoRog3wCeJakS
LMb3v6u1uEdlk7PWRmamgIw=
=HvN6
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
