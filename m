From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: Using skb->mark outside netfilter
Date: Tue, 7 May 2013 16:17:40 +0200
Message-ID: <20130507141740.GC2729@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
 <20130506184817.GA2729@open-mesh.com>
 <5188FBD2.5090200@mojatatu.com>
 <20130507132326.GB2729@open-mesh.com>
 <518901DC.2050100@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="8X7/QrJGcKSMr1RN"
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht2.myhostedexchange.com ([69.50.2.38]:43720 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752412Ab3EGOTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 10:19:24 -0400
Content-Disposition: inline
In-Reply-To: <518901DC.2050100@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--8X7/QrJGcKSMr1RN
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 07, 2013 at 06:30:04 -0700, Jamal Hadi Salim wrote:
> On 13-05-07 09:23 AM, Antonio Quartulli wrote:
>=20
> > The mark is not really encoded in the batman header.
> >
> > Each node is configured with a mark value (the values have to be the sa=
me on
> > everynode in order to make the mechanism work correctly), then batman-a=
dv will
> > advertise to the rest of the mesh which host is sending marked packets.
> >
> [..]
> > Receiving nodes will then restore the mark in the skb each time it is c=
oming from
> > one of those advertised hosts.
> >
>=20
> I see - so some control "protocol" will be used to advertise the mark
> and which host will use such a mark? Or are you saying some admin is
> going around and configuring 100 batman nodes? ;->

The mark is locally configured. So no control protocol that advertised it.
It will be a new config option of batman-adv, like others that it already h=
as.

What you are talking about is a common config problem in a mesh network:
whenever you have to change something you have to do it on each and every
node..we can't do anything about that :) Everybody uses is own solution for=
 this.

However the mark is only important locally, because no matter what mark a n=
ode
will use, the important part is that batman-adv and tc are using the same (=
on
the same node).


By the way we will have soon a userspace daemon (namely "alfred") which can=
 be
used to spread "external" information over the mesh and this mark may be on=
e of
them (if we really wanted to coordinate it, but it is not necessary as I
explained before).


>=20
> Note: I have no freaking clue in regards to batman or its usage.
>=20

no problem :)

> > A future feature may consists in carrying the mark directly into the he=
ader so
> > that batman-adv itself does not have to take care about the meaning of =
such
> > value but will just carry it (we still have to think about it...it is j=
ust an
> > idea now)
> >
>=20
> I think that may be more interesting because it may allow you to use
> many different marks with many different meanings. It doesnt disqualify
> a control protocol advertising the mark.
>=20

Yeah that would really be interesting.
Maybe we will implement it as soon as more uses cases will pop up. Actually=
 this
simple distributed access control is the only purpose we have in mind at the
moment :)

Thank you very much for your valuable feedbacks!

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--8X7/QrJGcKSMr1RN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRiQ0EAAoJEADl0hg6qKeO75sP/RYRe1aWxVntU1BPRjcHj6Ir
ILo4Kz+fF4cJ3YJv8jqmTv5/HPDUXb3be5FOEOgtnjbbdznAH8c4hBNS2/g+S7MC
uiMFE77ox22j1Kceg/6LdT1vi0y9+gxq+4xiFzla3Zp8T5B4ZC4x8fUwtIuWbHIB
xApFcP5pHI046l7xsRSrI74mLcMy/TciA987e/kaQOGVsQzIQ6i8Q87/XI87Z8dw
uzrtewo5DB4zf9iGrSV4QPIESlehL8d9UbQ+Nlwr6SSDHBlKm2QOKgCze+Snrms7
7qKdA6kYEB50fY5UHmScHyBm2k/2pDOslKx5gmn60n233NwdOdx7NsmEu2qglxfI
aILibqJM9AsMqkA2jMSKm1f4354SwIWkpRXZIeMiKs0rJINLHDiaabd/rGUBC+rT
sDM5qeWC1+LWeu6eb9milMQb9jsu6EZBeIlPVCf8GVzxZEbgWEZrYSWMb+0tQoEj
EW+TbpnOv9mBxoGkAqkqqGDDcpXFCUl6tRquZLp7cayQMIK0dqW7zT48f5qZg6Fo
Vjefqt4lzm9PwOFjtxuEcRLhVihs9KcjGKPpidoR4xjUGSmdOffCymJxgwfqgtFg
9Etu37jaq9nPIU4wmgLpaC/1dWA/6+3Bb+RTMYrQlANB/qFIWuN/cNukgwC0mxB8
MeLQeFNbbqQ2dtHjRY8F
=G5C9
-----END PGP SIGNATURE-----

--8X7/QrJGcKSMr1RN--
