From: Stephen Hemminger <shemminger@osdl.org>
Subject: Stackable devices.
Date: Wed, 2 Aug 2006 10:37:28 -0700
Message-ID: <20060802103728.0b2fa46b@dxpl.pdx.osdl.net>
References: <44CA34D0.1070507@candelatech.com>
	<20060801170329.GG29208@tuxdriver.com>
	<44CF8D8A.5080101@candelatech.com>
	<200608021102.20604.Christophe.Devriese@eurid.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28131 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750922AbWHBRhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 13:37:41 -0400
To: Christophe Devriese <Christophe.Devriese@eurid.eu>
In-Reply-To: <200608021102.20604.Christophe.Devriese@eurid.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2 Aug 2006 11:02:20 +0200
Christophe Devriese <Christophe.Devriese@eurid.eu> wrote:

> On Tuesday 01 August 2006 19:21, you wrote:
> > John W. Linville wrote:
> > >>>I'm just not sure that cleverness is worth the headache, especia=
lly
> > >>>since the most clever things usually only work by accident...
> > >>
> > >>Or, work by solid, modular design and small tweaks!
> > >
> > > Point taken. =C2=A0But stashing little hacks in the networking co=
re for
> > > specific virtual drivers isn't totally modular either. =C2=A0And =
even if
> > > it were, "modular design" probably belongs on the list of "things
> > > that can be taken too far", like "everything in userland", "never
> > > use ioctl", and "microkernels are superior". :-)
> >
> > To be honest, I'm not over-joyed to see bridging hooks included
> > in the VLAN code..but if that is what it takes to get bridging
> > and VLANs to play well and be flexible, I think it is a fair price.
> >
> > It certainly wouldn't hurt to have someone take a holistic view of =
the
> > various L2 device interactions. =C2=A0Just documenting current func=
tionality
> > on, say, the netdev wiki would be a good first step.
>=20
> Ultimate flexibility could be provided by making the netif_rx routine=
 (and the=20
> others, including vlan etc), a "virtual" routine.
>=20
> That way a list of "filters" could be defined that allow any processi=
ng to be=20
> done on the packet before it is handed of to the linux kernel's highe=
r=20
> layers, including not delivering it on that interface, or delivering =
it on=20
> another interface.
>=20
> This would allow very complex implementations including stuff like a=20
> high-level l2 bridge, with vlan support, and a number of protocols li=
ke rstp,=20
> pvst+, ... with relatively simple code, that could be isolated from t=
he main=20
> kernel.
>=20
> Would anyone be interested in signing off on such a patch ? (which ba=
sically=20
> creates netif_rx and vlan_acc_netif_rx lists in the net_device struct=
ure, and=20
> then modify bridging and bonding drivers to just use this)=20

I have thought about this, but you end up reinventing System V streams.
The problem is for simple up/down call, the stacking model works fine b=
ut
once you add flow-control and multiplexing issues the problem becomes c=
omplex.
It is hard to think of a good general solution where the performance wo=
uldn't
end up sucking.

--=20
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
