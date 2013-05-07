From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: Using skb->mark outside netfilter
Date: Tue, 7 May 2013 15:23:26 +0200
Message-ID: <20130507132326.GB2729@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
 <20130506184817.GA2729@open-mesh.com>
 <5188FBD2.5090200@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="kXdP64Ggrk/fb43R"
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht2.myhostedexchange.com ([69.50.2.38]:6474 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758062Ab3EGNZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 09:25:09 -0400
Content-Disposition: inline
In-Reply-To: <5188FBD2.5090200@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--kXdP64Ggrk/fb43R
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jamal,

On Tue, May 07, 2013 at 06:04:18 -0700, Jamal Hadi Salim wrote:
> On 13-05-06 02:48 PM, Antonio Quartulli wrote:
>=20
> >
> > Now to extend this mechanism network-wide (remember that the use case i=
s a Layer2
> > mesh network set up with batman-adv) I'm going to introduce a mechanism=
 in
> > batman-adv itself which is supposed to read and write the skb->mark fie=
ld
> > so that the value contained when the packet is leaving one end can be r=
estored
> > later on the other end of the intra-mesh communication (only if it matc=
hes a pre
> > configured one).
> > This would allow the remote node to perform the same filtering
> > operation as if the packet was locally generated.
> >
>=20
> Nice idea.
> How do you encode the mark in the batman header?

The mark is not really encoded in the batman header.

Each node is configured with a mark value (the values have to be the same on
everynode in order to make the mechanism work correctly), then batman-adv w=
ill
advertise to the rest of the mesh which host is sending marked packets.

Receiving nodes will then restore the mark in the skb each time it is comin=
g from
one of those advertised hosts.

A future feature may consists in carrying the mark directly into the header=
 so
that batman-adv itself does not have to take care about the meaning of such
value but will just carry it (we still have to think about it...it is just =
an
idea now)

> >
> > To clarify the idea, here you have an ascii art representing a possible=
 setup
> > and how the mark will be read and set:
>=20
> Looks sane to me.
>=20

Thanks a lot!
I will use it :)


Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--kXdP64Ggrk/fb43R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRiQBOAAoJEADl0hg6qKeOzqMP/RTSL2MKdf/nmCl5z2u3rzLH
OK4zNzNayg80yUowj4FVyYBo6c2Q+I3WL2QRHqnpx8hJcGCgO7+FPzKOagM4PYfR
sGQ//M1uUFHx4LdDq8INO3531PjYZWGe75q8DfRQXSH+8aOIMiHJeeSDouMqehxf
YGeT0uwsee1WNmcysaM6/vBuHfOdOCGlj1Siq7ex6RA8VBRpV0XEyQihuE7RkG2i
SXzwVT8Kn7lDh3pnS4Efr1IecBhus6vWlaNbEmTC4ga1hs7A2XM7LFib4ZKCAhbh
9/P0q9pMWIL93HQNgFWQaJ7jJu7w94AKz63O2C5ND5eZM+jkWVCs0GEuaW0rCt2B
h+aq4yTX3JrkL5S26HFjjXr1LsBMfNmg+pgfYUEeJceH1tSlt5pc6LhF2ZHRuF9M
PN1F3unoYQu0ebaUTWuRB4pYV8F4GFlnQwMRhxTkEMD+9bGJ7czaER+F0ip63VGr
vCJaez0D3bzMCgcoUwz+KXOnHVFPT0IzWzLpfL3LJPFU/5XKlXhE4Z8XAfqsOioc
Tg0p/xzoul1ZFnaXFz2MI+DlrluqaNiHrDogT07VqQy4wiSUFymyrJ5EZmOFOzwj
oHoJvET0yVb8iKIZGNuKXTifVdY5rUcYJXECw3Q/dro4W/2VeGu/sr5fvjYcZ720
mGUPxq2rfxYminZOAjMw
=+mPn
-----END PGP SIGNATURE-----

--kXdP64Ggrk/fb43R--
