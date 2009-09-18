From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netlink API for bonding ?
Date: Thu, 17 Sep 2009 21:00:24 -0700
Message-ID: <20090917210024.7b8c4787@s6510>
References: <4A9C33EA.7080008@free.fr>
	<20090831150000.4bcd1481@nehalam>
	<4AB2ADBE.1060402@free.fr>
	<20090917145120.5a3bb04b@nehalam>
	<4AB2B3EF.50307@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>
To: Nicolas de =?UTF-8?B?UGVzbG/DvGFu?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58014 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbZIREA1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2009 00:00:27 -0400
In-Reply-To: <4AB2B3EF.50307@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Sep 2009 00:10:55 +0200
Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:

> Stephen Hemminger wrote:
> > On Thu, 17 Sep 2009 23:44:30 +0200
> > Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:
> >=20
> >> Stephen Hemminger wrote:
> >>> On Mon, 31 Aug 2009 22:34:50 +0200
> >>> Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:
> >>>
> >>>> Stephen,
> >>>>
> >>>> Can you please describe the netlink API you plan to implement fo=
r bonding ?
> >>>>
> >>>> Both Jiri Pirko and I plan to add some advanced active slave sel=
ection rules,=20
> >>>> for more-than-two-slaves bonding configuration.
> >>>>
> >>>> Jay suggested that such advanced features be implemented in user=
 space, using=20
> >>>> netlink to notify a daemon when slaves come up or fall down. I a=
gree with Jay,=20
> >>>> but don't want to design something without having first a view a=
t your proposed=20
> >>>> API for bonding.
> >>>>
> >>>> Do you plan to have some notification to user space, or only the=
 ability to read=20
> >>>> and set bonding configuration using netlink ?
> >>>>
> >>>> Thanks,
> >>>>
> >>>> 	Nicolas.
> >>> No paper spec, but was looking to add interface similar to vlan a=
nd macvlan.
> >>> Just use (and extend if needed) existing rtnl_link_ops.
> >>>
> >>>
> >>> Was not planning on adding a notification interface, thats good i=
dea but
> >>> really not what I was looking at.
> >> What kind of notification system would you suggest to notify userl=
and that a=20
> >> given bond device just lose the current active slave ?
> >=20
> > First why should user land care?  Unless all slaves are gone maybe =
it
> > should just be transparent.
>=20
> Because we try to design a notification from kernel to userland when =
current=20
> active slave fail, to give an opportunity to userland to decide which=
 non-failed=20
> slave should become the new active one. This is in order to try and m=
ove complex=20
> decisions to userland, only keeping very simple "two slaves" decision=
s into the=20
> kernel.
>=20
> Think of it as the bonding counter part of moving STP to userland for=
 bridge.=20
> Userland should be able to decide which slave should be the active on=
e for the=20
> same reasons userland is able to decide which bridge port should be f=
orwarding=20
> and which should be blocked.
>=20
> I assume that we cannot just try to make the current bridge userland=20
> notification system more generic. May be I'm wrong. May be the abilit=
y to notify=20
> port failure, port coming back and BPDU for bridge is a superset of w=
hat we need=20
> to notify port failure and port coming back for bonding.
>=20
> > Use existing link ops mechanism (see vlan and macvlan). You may nee=
d
> > to add new operations, but these should be generic enough so that b=
onding and bridging
> > have same operations.=20
> >=20
> >      .newlink =3D> create bond device
> >      .dellink =3D> remove bond device
> >      .newport =3D> add slave
> >      .delport =3D> remove slave
> >=20
> > Also, dellink should always work (even if slaves are present).
>=20
> This sounds perfect for setup, but might not be good the elect the "b=
est" port=20
> (active slave). Also, I assume a new RTNETLINK operation needs to be =
added for=20
> that. I thought that this was what you were working on. Do I miss som=
ething ?=20
> Does brctl use RTNETLINK for port setup ? Or do you plan to use iprou=
te2 to=20
> replace brctl in the futur ?

I got to busy to get past making bonding amenable to using newlink/deli=
nk.
One common way to handle changes is to send another NEWXXX message with
different parameters (TLV values).

> > The terminology slave is not widely used outside of bonding, and so=
 probably
> > shouldn't be buried in the API.
>=20
> Yes, you are definitely right with this point.
>=20
> 	Nicolas.

