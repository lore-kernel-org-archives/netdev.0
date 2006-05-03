From: Herbert Valerio Riedel <hvr@gnu.org>
Subject: Re: RFC: au1000_etc.c phylib rewrite
Date: Wed, 03 May 2006 18:34:16 +0200
Message-ID: <1146674056.31241.18.camel@localhost.localdomain>
References: <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3>
	 <1146510542.16643.10.camel@localhost.localdomain>
	 <1146510542.16643.10.camel@localhost.localdomain>
	 <5.1.0.14.2.20060501144633.025e4e20@205.166.54.3>
	 <5.1.0.14.2.20060502095256.01fd4210@205.166.54.3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-mbzD0rZ6vt078KauN4eQ"
Cc: ppopov@embeddedalley.com, sshtylyov@ru.mvista.com,
	linux-mips@linux-mips.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>,
	"Robin H. Johnson" <robbat2@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h081217049130.dyn.cm.kabsi.at ([81.217.49.130]:54941 "EHLO
	phobos.hvrlab.org") by vger.kernel.org with ESMTP id S1030243AbWECQm2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 12:42:28 -0400
To: Mark Schank <mschank@dcbnet.com>
In-Reply-To: <5.1.0.14.2.20060502095256.01fd4210@205.166.54.3>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mbzD0rZ6vt078KauN4eQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

hello *

On Tue, 2006-05-02 at 11:20 -0500, Mark Schank wrote:
> At 08:23 AM 5/2/06 +0200, Herbert Valerio Riedel wrote:
> >On Mon, 2006-05-01 at 15:09 -0500, Mark Schank wrote:
> > > The Cogent CSB655 used the Broadcom Dual Phy.  They eventually redesi=
gned
> > > the board and switched to two single Broadcom phys, but they continue=
d to
> > > control both phys through MAC0, which is the actual purpose of the=20
> > dual-phy
> > > hack.  I am a user of the CSB655, so I sort of care.
> > >
> > > Will the new PHY framework allow a second PHY for a second MAC (MAC1)=
 be
> > > controlled from the first MAC's (MAC0) mdio interface?
> >
> >should'nt be a problem (as opposed to the bosporus case... see below)...
> >I assume the phy-addresses on which the boarcom dual phy is configured
> >are the same for all Cogent CSB655 boards?
>=20
> Dual PHY configuration:
>      MAC0 - phy addr 4
>      MAC1 - phy addr 3
> Single PHY configuration:
>      MAC0 - phy addr 1
>      MAC1 - phy addr 0

while at it, does anyone happen to know what the phy-addr/MAC assignment
on the XXS1500 is?

> >does this need to be autodetected dynamically at runtime, or can we rely
> >on a compile time Kconfig-conditional to set a static phy-addr<->eth%
> >d-phy mapping for this board-specific case? Or de we really need such a
> >complex mii_probe() function to detect weird scenarios? :)
>=20
> The compile time Kconfig-conditional should be okay.  The driver need to=20
> handle the fact that the MAC1's phy is controlled by MAC0's mdio=20
> interface.  This means that MAC0 controller can not be disabled when the=20
> associated eth% device is down, otherwise you lose the ability to control=
=20
> MAC1's phy.

...or at least, the MAC associated with the particular MII bus should be
brought up if necessary before any mdio access (that's what I'm
implementing right now)

but one thing that seems strange to me; CONFIG_BCM5222_DUAL_PHY doesn't
seem to be defined anywhere; shouldn't that be at least defined in some
Kconfig file, especially if the XXS1550 board is supposed to make use of
it?=20

btw, is the CSB655 supported at all in the 2.6 linux-mips branch, I
couldn't find any mention of it in Kconfig files either?

> >using static phy addr mappings would also allow for setting
> >board-specific phy-irq assignments, which would then be handled by the
> >phylib facilities, instead of polling the status of phy with a timer;
> >(and in case we don't have any board-specific compile time setting, we
> >can still fall back to search the phy-addresses for a PHY at runtime as
> >the generic case)
>=20
> Will the phylib facilities handle the case where two phys share a single =
IRQ?

afaics from the source, it doesn't handle the case of multiplexed phy
notification irqs; although the interrupt is requested with the SA_SHIRQ
flag, the first phy-interrupt-handler to be called already returns
IRQ_HANDLED... doesn't feel right in some way ;-)

> >while at it, what about that CONFIG_MIPS_BOSPORUS special case? why
> >doesn't the 2nd MAC see any PHY? how is the 2nd MAC connected to the
> >physical world?
>=20
> I don't have first hand knowledge of this board, but I have worked with=20
> Kendin switches before.  They have a special port that allows direct=20
> connection of a MAC into the switch port without the use of a phy.  The=20
> MAC's MII is directly connected to the switch ports MII.  So instead of t=
his:
>          MAC <-> PHY <->PHY <-> Switch_Port
> You have this:
>          MAC <-> Switch_Port
>=20
> So the MAC talks to the physical world via the switch.

thx; in the meantime, I've happened to find the board schematics and the
switch data-sheet in order to understand the situation better

regards,
hvr

--=-mbzD0rZ6vt078KauN4eQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBEWNuISYHgZIg/QUIRAv10AJ9J5flzM9+vstKPnccHjW+xhroMmQCfT/YE
fJRevU7OAVXjhh40INNuMiI=
=eZj5
-----END PGP SIGNATURE-----

--=-mbzD0rZ6vt078KauN4eQ--

