From: Gervais Arthur <arthur.gervais@insa-lyon.fr>
Subject: Re: Fwd: PROBLEM: IPv6 Duplicate Address Detection with non RFC-conform
 ICMPv6 packets
Date: Sat, 07 May 2011 15:17:26 +0200
Message-ID: <dc9a790de083b31ff85c0b9578c980e7@mail.insa-lyon.fr>
References: <4DC54157.9010306@computer.org> <1304773802.2821.1214.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Ceuleers <jan.ceuleers@computer.org>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from criges14.insa-lyon.fr ([134.214.76.242]:32932 "EHLO
	smtp.insa-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967Ab1EGNR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 09:17:28 -0400
In-Reply-To: <1304773802.2821.1214.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2011 03:10 PM, Eric Dumazet wrote:
> Le samedi 07 mai 2011 =C3=A0 14:55 +0200, Jan Ceuleers a =C3=A9crit :
>> The networking folks are on netdev
>>
>> -------- Original Message --------
>> Subject: PROBLEM: IPv6 Duplicate Address Detection with non RFC-conf=
orm
>> ICMPv6 packets
>> Date: Thu, 05 May 2011 11:52:05 +0200
>> From: Gervais Arthur<arthur.gervais@insa-lyon.fr>
>> To:<linux-kernel@vger.kernel.org>
>> CC:<arthur.gervais@insa-lyon.fr>
>>
>> [1.] One line summary of the problem:
>>
>> A specially crafted Ethernet ICMPv6 packet which is not conform to t=
he
>> RFC can perform a IPv6 Duplicate Address Detection Failure.
>>
>> [2.] Full description of the problem/report:
>>
>> If a new IPv6 node joins the local area network, the new node sends =
an
>> ICMPv6 Neighbor Solicitation packet in order to check if the
>> self-generated local-link IPv6 address already occupied is.
>>
>> An attacker can answer to this Neighbor Solicitation packet with an
>> ICMPv6 Neighbor Advertisement packet, so that the new IPv6 node is n=
ot
>> able to associate the just generated IPv6 address.
>> -- This problem is well known and IPv6 related.
>>
>> The new problem is that the attacker can modify the Ethernet Neighbo=
r
>> Advertisement packets, so that they are not RFC conform and so that =
it
>> is even more difficult to detect the attacker.
>>
>> If an attacker sends the following packet, duplicate address detecti=
on
>> fails on Linux:
>>
>> Ethernet Layer: 	Victim MAC -->  Victim MAC
>> IPv6 Layer:		fe80::200:edff:feXX:XXXX -->  ff02::1
>> 			ICMPv6
>> 			  Type 136 (Neighbor Advertisement)
>> 			  Target: fe80::200:edff:feXX:XXXX
>> 			ICMPv6 Option
>> 			  Type 2 (Target link-layer address) Victim MAC
>>
>> Please find attached a drawing and a proof of concept.
>>
>> [3.] Keywords (i.e., modules, networking, kernel):
>>
>> Network, IPv6, Duplicate Address Detection
>>
>> [4.] Kernel version (from /proc/version):
>>
>> Latest tested:
>> Linux version 2.6.35-22-generic (buildd@rothera) (gcc version 4.4.5
>> (Ubuntu/Linaro 4.4.4-14ubuntu4) ) #33-Ubuntu SMP Sun Sep 19 20:34:50
UTC
>> 2010
>> (and before most probably)
>>
>> [6.] A small shell script or example program which triggers the
>>         problem (if possible)
>>
>> Please find attached a python script demonstrating the problem.
>>
>> [X.] Other notes, patches, fixes, workarounds:
>>
>> The Linux Kernel should not accept incoming Ethernet packets
originating
>> from an internal Ethernet card (identified by the MAC address)
>>
>
> I fail to understand the problem.
>
> The attacker might use any kind of source MAC address to fool 'Victim=
'
> or 'network admins'
>
> Why one particular address should be avoided ?
>
>
>

Currently the IPv6 implementation says (from the victims view):
I send a Neighbor Solicitation for a given IPv6 address to check the=20
duplicate address detection.

If I then receive a Neighbor Advertisement packet from my MAC address,=20
to my MAC address, with ICMPv6 target option my MAC address, then the=20
requested IPv6 address must already be used and I cannot take it.

I think such a packet should never be allowed to be accepted, because=20
the victim just asked if the address is free.

If such a packet is accepted, it is even more difficult to find the=20
attacker.

