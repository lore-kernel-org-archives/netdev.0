From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>
Subject: Re: Netlink API for bonding ?
Date: Fri, 18 Sep 2009 00:10:55 +0200
Message-ID: <4AB2B3EF.50307@free.fr>
References: <4A9C33EA.7080008@free.fr>	<20090831150000.4bcd1481@nehalam>	<4AB2ADBE.1060402@free.fr> <20090917145120.5a3bb04b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:42079 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbZIQWLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 18:11:01 -0400
In-Reply-To: <20090917145120.5a3bb04b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 17 Sep 2009 23:44:30 +0200
> Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:
>=20
>> Stephen Hemminger wrote:
>>> On Mon, 31 Aug 2009 22:34:50 +0200
>>> Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr> wrote:
>>>
>>>> Stephen,
>>>>
>>>> Can you please describe the netlink API you plan to implement for =
bonding ?
>>>>
>>>> Both Jiri Pirko and I plan to add some advanced active slave selec=
tion rules,=20
>>>> for more-than-two-slaves bonding configuration.
>>>>
>>>> Jay suggested that such advanced features be implemented in user s=
pace, using=20
>>>> netlink to notify a daemon when slaves come up or fall down. I agr=
ee with Jay,=20
>>>> but don't want to design something without having first a view at =
your proposed=20
>>>> API for bonding.
>>>>
>>>> Do you plan to have some notification to user space, or only the a=
bility to read=20
>>>> and set bonding configuration using netlink ?
>>>>
>>>> Thanks,
>>>>
>>>> 	Nicolas.
>>> No paper spec, but was looking to add interface similar to vlan and=
 macvlan.
>>> Just use (and extend if needed) existing rtnl_link_ops.
>>>
>>>
>>> Was not planning on adding a notification interface, thats good ide=
a but
>>> really not what I was looking at.
>> What kind of notification system would you suggest to notify userlan=
d that a=20
>> given bond device just lose the current active slave ?
>=20
> First why should user land care?  Unless all slaves are gone maybe it
> should just be transparent.

Because we try to design a notification from kernel to userland when cu=
rrent=20
active slave fail, to give an opportunity to userland to decide which n=
on-failed=20
slave should become the new active one. This is in order to try and mov=
e complex=20
decisions to userland, only keeping very simple "two slaves" decisions =
into the=20
kernel.

Think of it as the bonding counter part of moving STP to userland for b=
ridge.=20
Userland should be able to decide which slave should be the active one =
for the=20
same reasons userland is able to decide which bridge port should be for=
warding=20
and which should be blocked.

I assume that we cannot just try to make the current bridge userland=20
notification system more generic. May be I'm wrong. May be the ability =
to notify=20
port failure, port coming back and BPDU for bridge is a superset of wha=
t we need=20
to notify port failure and port coming back for bonding.

> Use existing link ops mechanism (see vlan and macvlan). You may need
> to add new operations, but these should be generic enough so that bon=
ding and bridging
> have same operations.=20
>=20
>      .newlink =3D> create bond device
>      .dellink =3D> remove bond device
>      .newport =3D> add slave
>      .delport =3D> remove slave
>=20
> Also, dellink should always work (even if slaves are present).

This sounds perfect for setup, but might not be good the elect the "bes=
t" port=20
(active slave). Also, I assume a new RTNETLINK operation needs to be ad=
ded for=20
that. I thought that this was what you were working on. Do I miss somet=
hing ?=20
Does brctl use RTNETLINK for port setup ? Or do you plan to use iproute=
2 to=20
replace brctl in the futur ?

> The terminology slave is not widely used outside of bonding, and so p=
robably
> shouldn't be buried in the API.

Yes, you are definitely right with this point.

	Nicolas.
