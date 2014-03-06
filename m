From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Aw: Re: Link-local source IPv6 address in unicast Neighbor
 Solicitation towards global destination
Date: Thu, 6 Mar 2014 10:18:23 +0100
Message-ID: <trinity-e0e97e3d-2c6a-4f81-bd27-f7151a67b303-1394097503168@3capp-gmx-bs05>
References: <trinity-07b36174-6d20-4edd-b2f3-553cf69a5ac7-1394028029667@3capp-gmx-bs51>,
 <20140306070250.GC26307@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:53972 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbaCFJS2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 04:18:28 -0500
In-Reply-To: <20140306070250.GC26307@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,
thanks, checking that would be good.

Another point here (probably a bit academic): without link-local addres=
s on the interface (just the global one), the unicast NS for NUD is not=
 sent at all.

The neighbor cache entry is in DELAY state for some time, unicast NS is=
 not sent, then the entry is moved to FAILED rather quickly.

best regards, Simon


> Gesendet: Donnerstag, 06. M=C3=A4rz 2014 um 08:02 Uhr
> Von: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
> An: "Simon Schneider" <simon-schneider@gmx.net>
> Cc: netdev@vger.kernel.org
> Betreff: Re: Link-local source IPv6 address in unicast Neighbor Solic=
itation towards global destination
>
> Hi Simon!
>=20
> On Wed, Mar 05, 2014 at 03:00:29PM +0100, Simon Schneider wrote:
> > I noticed something I don't quite understand in a very basic scenar=
io.
> >=20
> > Two machines connected to each other, say A and B.
> >=20
> > Both have their automatically configured link-local IPv6 addresses =
on the interface, plus one global IPv6 interface address.
> >=20
> > A pings the global address of B.
> >=20
> > What happens:
> > 1) Address resolution from A to B. B creates a neighbor cache entry=
 for A's address in STALE state. Since B sends Neighbor Advertisement b=
ack to A, the entry moves to DELAY and the delay_first_probe_time timer=
 (5s) is started.
> >=20
> > 2) After successful resolution, echo request / reply are exchanged.
> >=20
> > 3) After delay_first_probe_time at B expires, B transmits a unicast=
 Neighbor Solicitation to A's global address (reachability check).=20
> >=20
> > All good so far.
> >=20
> > However, although the destination address of the NS has global scop=
e, B uses its link-local address as source.
> >=20
> > I don't think this is correct. According to the source address sele=
ction rules in RFC3484, chapter 5, Rule 2 should match and B's global i=
nterface address should be used as source.
>=20
> Plain RFC3484 cannot be used to select source address for NS, as we
> must be sure to select an IPv6 address belonging to the interface and
> RFC3484 does not gurantee that (Rule 2 would filter out link-local ad=
dress
> in case of global scope while only Rule 5 later would prefer to selec=
t
> an address belonging to the interface). It would be possible to try R=
=46C3484
> source selection, check if the address belongs to the interface and f=
allback
> to LL address in case it does not. I'll test if it improves things.
>=20
> > In this simple example, it leads to a sequence of further reachabil=
ity checks for the link-local addresses of A and B. I don't think these=
 are necessary and they could be avoided if B had used its global inter=
face address as source in the first NS.
> >=20
> > Observed under kernel version 3.11.
> >=20
> > Is this a bug or do I miss something?
>=20
> Always using link-local address in this scenario is in my opinion tot=
ally
> valid but maybe not the best choice.
>=20
> Greetings,
>=20
>   Hannes
>=20
>
