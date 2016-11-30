From: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 16:35:18 +0000
Message-ID: <1480523716.3563.144.camel@infinera.com>
References: <1480495831.3563.135.camel@infinera.com>
         <20161130135257.GC18716@lunn.ch> <1480516241.3563.142.camel@infinera.com>
         <20161130152503.GE21645@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0045.outbound.protection.outlook.com ([104.47.38.45]:19264
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755114AbcK3QfY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 11:35:24 -0500
In-Reply-To: <20161130152503.GE21645@lunn.ch>
Content-Language: en-US
Content-ID: <7CC96F9586E9FD4C88B217BF1BBC9C5C@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 16:25 +0100, Andrew Lunn wrote:
> On Wed, Nov 30, 2016 at 02:30:43PM +0000, Joakim Tjernlund wrote:
> > On Wed, 2016-11-30 at 14:52 +0100, Andrew Lunn wrote:
> > > On Wed, Nov 30, 2016 at 08:50:34AM +0000, Joakim Tjernlund wrote:
> > > > I am trying to wrap my head around these two "devices" and have a h=
ard time telling them apart.
> > > > We are looking att adding a faily large switch(over PCIe) to our bo=
ard and from what I can tell
> > > > switchdev is the new way to do it but DSA is still there. Is it pos=
sible to just list
> > > > how they differ?
> > >=20
> > > Hi Joakim
> >=20
> > Hi Andrew, thanks for answering
> >=20
> > >=20
> > > If the interface you use to send frames from the host to the switch i=
s
> > > PCIe, you probably want to use switchdev directly.
> >=20
> > OK, we will have a few ethernet I/F's connected too but I these should =
be used
> > as normal interfaces just interfacing a switch.
>=20
> That does not make much sense.
>=20
> Maybe time to backtrack a bit. The Linux concept for switch/router
> chips is that they are just hardware accelerators for what Linux can
> already do in software. Each port of the switch is just a normal Linux
> interface.=A0=A0ip link show will list each port. ip addr add can be used
> to add an IP address to the interface.=A0=A0You want to switch frames
> between two ports: Create a linux bridge and put the interfaces into
> it. Via switchdev you get a call into the hardware to accelerate
> this. If the hardware cannot accelerate it, it is done in software as
> normal.=A0=A0Want to combine two ports into a trunk: Add a team interface
> and make the port interfaces slaves of the team interface. Via
> switchdev, you ask the hardware to accelerate this. If it cannot, it
> is done in software.
>=20
> So back your connecting a few host interfaces to the switch. This is
> logically putting a cable between two interfaces on the same host. You
> are making a loopback. Why do that? Sure it is possible, but it is an
> odd architecture.

This is an embedded system with several boards in a subrack.
Each board has eth I/F connected to a switch to communicate with each other=
.
One of the board will also house the actual switch device and manage the sw=
itch.
Then the normal app just communicates over the physical eth I/F like any ot=
her board
in the system. There is a "manage switch app" which brings the switch up an=
d partition
phys VLANs etc. (each phys I/F would be a a separate domain so no loop)

I guess I could skip the phys I/F and have the switch app create a virtual =
eth0 I/F over PCIe
instead to save eth MACS but the above is safer should there be some proble=
ms/limitations in
swicthdev plus switchdev does not exist in u-boot so it would be a lot of e=
ffort to
get a working eth I/F inside u-boot.
I can still can still create a bridge I/F etc. should I need to.
Does the above make sense to you ?
=20
>=20
> > And switchdev can do all this over PCIe instead? Can you have a
> > switch tree in switchdev too?
>=20
> Mellonex says so, but i don't think they have actually implemented it.

Not impl. any of DSAs features? What can you do with a Mellonex switch then=
?

 Jocke=
