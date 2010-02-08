From: Patrick McHardy <kaber@trash.net>
Subject: Re: VLAN egress performance
Date: Mon, 08 Feb 2010 14:13:25 +0100
Message-ID: <4B700DF5.1080406@trash.net>
References: <87wrynrk37.fsf@isengard.friendlyfire.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Mattias_R=F6nnblom?= <hofors@lysator.liu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab0BHNN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 08:13:28 -0500
In-Reply-To: <87wrynrk37.fsf@isengard.friendlyfire.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mattias R=F6nnblom wrote:
> Hi.
>=20
> I'm running Linux on PC w/ a Core i7 CPU and two Intel 82598 NICs, an=
d
> I see some anomalies when it comes to egress VLAN performance. I
> thought maybe someone on this list was interested in my results.
>=20
> I'm running the stock Ubuntu 2.6.31 kernel, but with a newer ixgbe
> driver (2.0.44.14).
>=20
> The benchmark is IP forwarding with unidirectional UDP flows @ 64 byt=
e
> packets, and I get:
>=20
> Ingress VLAN  Egress VLAN  Packet Rate    CPU utilization (all cores)
> No            No           5.0 Mpacket/s  ~70%
> Yes           No           5.0 Mpacket/s  ~75%
> No            Yes          1.4 Mpacket/s  ~26%
> Yes           Yes          1.3 Mpacket/s  ~26%
>=20
> "VLAN" here mean I've put a VLAN device on top of the real ixgbe
> device.
>=20
> As you can see, if the egress i/f is a VLAN i/f, the performance is
> reduced to less than a third. And in the case of egress VLAN, the
> systems basically only uses one HW thread (with a softirqd process
> taking up all the time).
>=20
> Enabling lockdep, it looks like execution is serialized to a large
> extent by contention around the "vlan_netdev_xmit_lock_key" lock.
>=20
> I call this anomaly because I was surprised to see it (as oppose to
> other performance degradations/scalability issues in the area of
> multicore and IP traffic handling performance).

2.6.32 contains VLAN multiqueue support and should scale better.
