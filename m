From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] ethtool: changes of emac_regs structure accordingly
 within driver emac_regs structure.
Date: Mon, 01 Jun 2015 19:11:26 +0100
Message-ID: <1433182286.6319.183.camel@decadent.org.uk>
References: <20150521190917.6971eb09@fr-ThinkPad-W520>
	 <20150601163057.01717aef@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DvkuUkFTroKW5XUzSQ0/"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Ivan Mikhaylov <ivan@ru.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33939 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751474AbbFASLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:11:37 -0400
In-Reply-To: <20150601163057.01717aef@fr-ThinkPad-W520>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DvkuUkFTroKW5XUzSQ0/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-06-01 at 16:30 +0400, Ivan Mikhaylov wrote:
> On Mon, 1 June 2015 12:57 +0400
> Ben Hutchings <ben@decadent.org.uk> wrote:
>=20
> >On Thu, 2015-05-21 at 19:09 +0400, Ivan Mikhaylov wrote:
> >> In ibm_emac.c in ethtool size of emac structure which passing through
> >> to driver is nailed down and not correlating with current emac_regs
> >> structure.
> >>=20
> >> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>
> >[...]
> >
> >This is not backward-compatible.  It ought to be possible to mix and
> >match old and new ethtool and driver, except for the EMAC4SYNC case
> >which has been broken up until now.
> >
> >Using the new definition of struct emac_regs, I think the driver and
> >ethtool need to agree that the MAC register dump sizes are:
> >
> >EMAC:      offsetof(struct emac_regs, u1)
> >EMAC4:     offsetof(struct emac_regs, u1.emac4) + sizeof(p->u1.emac4)
> >EMAC4SYNC: offsetof(struct emac_regs, u1.emac4sync) +
> >sizeof(p->u1.emac4sync)
> >
> >Ben.
> >
> >--=20
> >Ben Hutchings
> >Reality is just a crutch for people who can't handle science fiction.
>=20
> Actually it is backward-compatible because we don't care about size
> which is coming from driver side, only what we doing is map of driver
> structure to ethtool structure and results will be same
> for emac and emac4.
>=20
>  struct emac_regs *p =3D (struct emac_regs *)(hdr + 1);

The following registers won't be printed correctly.

> Also size which you mentioned (112 emac, 116 emac4) can be different
> from what you saying cause this managed by dts files where we can set
> something like 0x100 or 0x80 for this memory area and we will still
> have problem in representing MII area if this size wasn't set right
> in dts.

Yes, I understand that.  However, the in-tree device trees consistently
use those as the resource sizes so I think ethtool used to work properly
for the machines supported by those.  Increasing the size of the MAC
register dump is a regression for them.

Ben.

> Ethtool will be work in same way even if we have emac or emac4.
>=20
> Thank you for respond!
>=20

--=20
Ben Hutchings
Power corrupts.  Absolute power is kind of neat.
                           - John Lehman, Secretary of the US Navy 1981-198=
7

--=-DvkuUkFTroKW5XUzSQ0/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWygUue/yOyVhhEJAQp6Sg/+ORRzCXIvs+XFQQ/HqAORxYvXG2Mye+j6
viE9hro75XmJPuPko6TjFklnnifx33cu5UbI6Hng8UJFSoqhNlXarz4w4PJSDYSV
tg7rE3o91ievt/hK/xYcwb2cAxRjnu8Mt/ZnwCyuQVS0KA6cWuLh6Lh5Jyy5u37E
s494qw/gGNqfLjXEcyVT+YN1FJggmqnxbgjOS1PaEJkNTR8dpxePWwctsamawwiQ
J5YvVw9WCEwcKUDmZhMUxdW85UAnEy9549x7K/WaZjrQjcW7dEx6mEQ5a6kD/HRm
qsTBcmgqUoj0KiXBvbos+TUDhbVcbO9EY2rpFGKNPaKJcZQ1ETD1bF2GpZeIMlBD
GRtsnzLqSJEzjwq85dMAJrKN+PW6M02FXnn9IL01LOMlgDvvbzpS2Yr7gxzTSWEq
ML+s8I6g6MtochZZchzxBE9bzhP2jTyHie3BHO3fLjK6BYtSDbFH2Xb5ZotWUcJw
3o/q9PFpmKV9DrDmf1lR3drcBXa3KGyR6XZJ+P/Sfe3Gzz4iFOmVH6T6n7W2nrKQ
nmH7zYhM0AOFjiVCT022E3IZgAJCHBLHDPBYKCkPFkmq0CQlznAP8di+wcONfOc9
4hIWd+K43g0Qvrzz2rk1tXQjtWyMUP7ssuEDKxJpPqRDi1pf0uzsflBPRkfY1dqI
7avyJbn7hjI=
=WYzD
-----END PGP SIGNATURE-----

--=-DvkuUkFTroKW5XUzSQ0/--
