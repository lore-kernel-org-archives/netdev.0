From: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Wed, 30 Nov 2016 17:44:14 +0000
Message-ID: <1480527852.3563.146.camel@infinera.com>
References: <1480495831.3563.135.camel@infinera.com>
         <20161130135257.GC18716@lunn.ch> <1480516241.3563.142.camel@infinera.com>
         <20161130152503.GE21645@lunn.ch> <1480523716.3563.144.camel@infinera.com>
         <20161130165500.GH21645@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0043.outbound.protection.outlook.com ([104.47.40.43]:28257
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752789AbcK3SAf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 13:00:35 -0500
In-Reply-To: <20161130165500.GH21645@lunn.ch>
Content-Language: en-US
Content-ID: <22B2C4AC2FBA7344B429E3E32EC3A3A3@infinera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 17:55 +0100, Andrew Lunn wrote:
> > This is an embedded system with several boards in a subrack.
> > Each board has eth I/F connected to a switch to communicate with each o=
ther.
> > One of the board will also house the actual switch device and manage th=
e switch.
> > Then the normal app just communicates over the physical eth I/F like an=
y other board
> > in the system. There is a "manage switch app" which brings the switch u=
p and partition
> > phys VLANs etc. (each phys I/F would be a a separate domain so no loop)
>=20
> So you are planning on throwing away the "manage switch app", and just
> use standard linux networking commands? That is what switchdev is all
> about really, throwing away the vendor SDK for the switch, making a
> switch just a bunch on interfaces on the host which you manage as
> normal interfaces.

Something like that. I need to run routing protocols on the switch I/Fs and=
 egress
pkgs on selected switch I/Fs bypassing ARP, just like DSA does with its ven=
dor
tags.

>=20
> > I guess I could skip the phys I/F and have the switch app create a virt=
ual eth0 I/F over PCIe
>=20
> No need to create this interface. It will exist if you go the
> switchdev route.
>=20
> > > > And switchdev can do all this over PCIe instead? Can you have a
> > > > switch tree in switchdev too?
> > >=20
> > > Mellonex says so, but i don't think they have actually implemented it=
.
> >=20
> > Not impl. any of DSAs features? What can you do with a Mellonex switch =
then?
>=20
> They don't have a tree of switches, as far as i know. Just a single
> switch. But DSA does support a tree of switches, that is what the D in
> DSA means, distributed. And there are a couple of boards which have 2
> to 4 switches in a tree.

We might have a tree as well so now I really wonder: Given we write a
proper switchdev driver, can it support switchtrees without touching
switchdev infra structure? If not I guess we will attach a physical
eth I/F to the switch and use both DSA and switchdev to support both trees
and HW offload.=20

>=20
> I think this is partially down to market segments. Mellonex market is
> top of rack switches. High port count, very high bandwidth. DSA is
> more wireless access points, set top boxes, generally up to 7 ports of
> 1Gbps and a few custom embedded products which need more ports, so
> build a tree of switches.

We have on an existing board with a BCM ROBO switch with lots of ports(>24)=
,
managed over SPI. Looking at BCM DSA tag code it looks like it only support=
s
some 8 ports or so. I still have to find out if this is a limitation in BCM=
 tagging
protocol or if just not impl. in DSA yet.
