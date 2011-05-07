From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: PROBLEM: IPv6 Duplicate Address Detection with non
 RFC-conform ICMPv6 packets
Date: Sat, 07 May 2011 15:10:02 +0200
Message-ID: <1304773802.2821.1214.camel@edumazet-laptop>
References: <4DC54157.9010306@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Gervais Arthur <arthur.gervais@insa-lyon.fr>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36585 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798Ab1EGNKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 09:10:08 -0400
Received: by wwk4 with SMTP id 4so1156616wwk.1
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 06:10:06 -0700 (PDT)
In-Reply-To: <4DC54157.9010306@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 14:55 +0200, Jan Ceuleers a =C3=A9crit :
> The networking folks are on netdev
>=20
> -------- Original Message --------
> Subject: PROBLEM: IPv6 Duplicate Address Detection with non RFC-confo=
rm=20
> ICMPv6 packets
> Date: Thu, 05 May 2011 11:52:05 +0200
> From: Gervais Arthur <arthur.gervais@insa-lyon.fr>
> To: <linux-kernel@vger.kernel.org>
> CC: <arthur.gervais@insa-lyon.fr>
>=20
> [1.] One line summary of the problem:
>=20
> A specially crafted Ethernet ICMPv6 packet which is not conform to th=
e
> RFC can perform a IPv6 Duplicate Address Detection Failure.
>=20
> [2.] Full description of the problem/report:
>=20
> If a new IPv6 node joins the local area network, the new node sends a=
n
> ICMPv6 Neighbor Solicitation packet in order to check if the
> self-generated local-link IPv6 address already occupied is.
>=20
> An attacker can answer to this Neighbor Solicitation packet with an
> ICMPv6 Neighbor Advertisement packet, so that the new IPv6 node is no=
t
> able to associate the just generated IPv6 address.
> -- This problem is well known and IPv6 related.
>=20
> The new problem is that the attacker can modify the Ethernet Neighbor
> Advertisement packets, so that they are not RFC conform and so that i=
t
> is even more difficult to detect the attacker.
>=20
> If an attacker sends the following packet, duplicate address detectio=
n
> fails on Linux:
>=20
> Ethernet Layer: 	Victim MAC --> Victim MAC
> IPv6 Layer:		fe80::200:edff:feXX:XXXX --> ff02::1
> 			ICMPv6
> 			  Type 136 (Neighbor Advertisement)
> 			  Target: fe80::200:edff:feXX:XXXX
> 			ICMPv6 Option
> 			  Type 2 (Target link-layer address) Victim MAC
>=20
> Please find attached a drawing and a proof of concept.
>=20
> [3.] Keywords (i.e., modules, networking, kernel):
>=20
> Network, IPv6, Duplicate Address Detection
>=20
> [4.] Kernel version (from /proc/version):
>=20
> Latest tested:
> Linux version 2.6.35-22-generic (buildd@rothera) (gcc version 4.4.5
> (Ubuntu/Linaro 4.4.4-14ubuntu4) ) #33-Ubuntu SMP Sun Sep 19 20:34:50 =
UTC
> 2010
> (and before most probably)
>=20
> [6.] A small shell script or example program which triggers the
>        problem (if possible)
>=20
> Please find attached a python script demonstrating the problem.
>=20
> [X.] Other notes, patches, fixes, workarounds:
>=20
> The Linux Kernel should not accept incoming Ethernet packets originat=
ing
> from an internal Ethernet card (identified by the MAC address)
>=20

I fail to understand the problem.

The attacker might use any kind of source MAC address to fool 'Victim'
or 'network admins'

Why one particular address should be avoided ?



