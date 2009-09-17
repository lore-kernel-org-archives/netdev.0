From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netlink API for bonding ?
Date: Thu, 17 Sep 2009 14:51:20 -0700
Message-ID: <20090917145120.5a3bb04b@nehalam>
References: <4A9C33EA.7080008@free.fr>
	<20090831150000.4bcd1481@nehalam>
	<4AB2ADBE.1060402@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>
To: Nicolas de =?UTF-8?B?UGVzbG/DvGFu?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42096 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbZIQVvX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 17:51:23 -0400
In-Reply-To: <4AB2ADBE.1060402@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Sep 2009 23:44:30 +0200
Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:

> Stephen Hemminger wrote:
> > On Mon, 31 Aug 2009 22:34:50 +0200
> > Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:
> >=20
> >> Stephen,
> >>
> >> Can you please describe the netlink API you plan to implement for =
bonding ?
> >>
> >> Both Jiri Pirko and I plan to add some advanced active slave selec=
tion rules,=20
> >> for more-than-two-slaves bonding configuration.
> >>
> >> Jay suggested that such advanced features be implemented in user s=
pace, using=20
> >> netlink to notify a daemon when slaves come up or fall down. I agr=
ee with Jay,=20
> >> but don't want to design something without having first a view at =
your proposed=20
> >> API for bonding.
> >>
> >> Do you plan to have some notification to user space, or only the a=
bility to read=20
> >> and set bonding configuration using netlink ?
> >>
> >> Thanks,
> >>
> >> 	Nicolas.
> >=20
> > No paper spec, but was looking to add interface similar to vlan and=
 macvlan.
> > Just use (and extend if needed) existing rtnl_link_ops.
> >=20
> >=20
> > Was not planning on adding a notification interface, thats good ide=
a but
> > really not what I was looking at.
>=20
> What kind of notification system would you suggest to notify userland=
 that a=20
> given bond device just lose the current active slave ?

=46irst why should user land care?  Unless all slaves are gone maybe it
should just be transparent.

Use existing link ops mechanism (see vlan and macvlan). You may need
to add new operations, but these should be generic enough so that bondi=
ng and bridging
have same operations.=20

     .newlink =3D> create bond device
     .dellink =3D> remove bond device
     .newport =3D> add slave
     .delport =3D> remove slave

Also, dellink should always work (even if slaves are present).


The terminology slave is not widely used outside of bonding, and so pro=
bably
shouldn't be buried in the API.
