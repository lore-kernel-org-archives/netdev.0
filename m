From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: Re: [RFC, PATCH 2.6.29.1] Ethernet V2.0 Configuration Testing
 Protocol
Date: Sat, 25 Apr 2009 11:07:55 +0930
Message-ID: <20090425110755.30b6006e.ipng@69706e6720323030352d30312d31340a.nosense.org>
References: <20090423221015.48b79b04.ipng@69706e6720323030352d30312d31340a.nosense.org>
	<49F16BEE.2040902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:52434 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbZDYH0M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 03:26:12 -0400
In-Reply-To: <49F16BEE.2040902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks very much for your time.

On Fri, 24 Apr 2009 09:36:14 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Mark Smith a =E9crit :
> > Hi,
> >=20
> > I'm hoping my attached implementation of the Ethernet V2.0 Configur=
ation
> > Testing Protocol could be reviewed, with eventual goal of inclusion=
 in
> > the kernel.
> >=20
> > Ethernet V2.0 Configuration Testing Protocol (ECTP) is an old Ether=
net
> > testing protocol, specified in section 8 of the original Ethernet V=
2.0
> > specification. It provides request/reply "ping" style testing at
> > the Ethernet layer, testing of a path via a list of devices (i.e. a
> > strict source route), and identification of ECTP capable devices vi=
a
> > broadcast or multicast ECTP requests.
> >=20
<snip>=20
>=20
> Hello Mark
>=20
> I am trying to find how ETCP could be useful :)
>=20
> Could bonding use ETCP as a third way to validate a slave is operatio=
nal ?
>=20
> First way is mii-mon (link presence to next hop)
>   -> Very lazy since we can be connected to a switch that lost all co=
nnectivity to other equipments.
>=20
> Second way is arp_ping (list of 1 to 16 IP addresses)
>   -> broadcast messages.
>    If many hosts are on [V]LAN, and small arp_interval, this can gene=
rate extra trafic.
>=20
> Third way : ETCP messages sent to given MAC address ?
>   (Unicast messages, and no VLAN troubles...)

ECTP is designed exactly for that purpose - verifying
remote Ethernet node availability. The unicast ECTP message would
contain a forward message, specifying the originator's MAC address, and
a reply message. The receiver, if it is available, just forwards the
packet to the (unicast) MAC address provided in the current forward
message. For a liveness test, the MAC address in the forward message
would be that of the ECTP packet originator.

>  I presume most routers support ETCP?
>=20

Cisco IOS routers do. They also use the protocol as their Ethernet
keepalive test, altough those packets don't comply with the
specification - the packet src and destination addresses are both the
MAC address of the interface source, and they only contain a reply
message, where as the minimum compliant packet should have a forward
message and a reply message. I haven't completely worked out how that i=
s
supposed to work, as any upstream switches won't forward a packet back
out the interface the packet is received on.

> Is ectpping needing your kernel patches, or can it work with current =
kernel ?

It doesn't need the kernel patches to work. Of course, without my
patch, Linux hosts won't respond.

> If not too large, you could post its source on this list.
>=20

It's not so much that it's too large, more that I've got a few minor
things left to do it e.g. put licensing info in, put a version number
in etc. It's also generally a bit thrown together, as my focus was on
the kernel module.

I'll fix those things over the next few days, and put it up on the net.

Thanks again,
Mark.
