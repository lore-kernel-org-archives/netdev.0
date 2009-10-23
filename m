From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN and ARP failure on tg3 drivers
Date: Fri, 23 Oct 2009 07:23:07 +0200
Message-ID: <4AE13DBB.9010101@gmail.com>
References: <93821.71108.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Gertjan Hofman <gertjan_hofman@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47439 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbZJWFXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 01:23:05 -0400
In-Reply-To: <93821.71108.qm@web32607.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gertjan Hofman a =E9crit :
> Dear Kernel developers,
>=20
> A couple of weeks ago we tried to migrate from a 2.6.24  kernel to a =
2.6.29 kernel and noticed our VLAN application no longer works.  The pr=
oblem is easy to replicate:
>=20
> 1. connect 2 PC's with a cross-over cable
> 2. set up a fixed IP address to both PC's  (say 192.168.0.[1,2])
> 3. create a vlan:  vconfig  add eth0 0.
> 4. set IP addresses on the VLAN devices  (say 192.168.1.[1,2])
> 5. try ping one machine from the other.
>=20
> I tried to dig into the problem by using un-patched kernel.org kernel=
s with Ubuntu .config files.  Kernels up to 2.6.26 work fine, kernels a=
fter and including 2.6.27 fail. The problem is that ARP messages are be=
ing dropped. If the ARP table is updated by hand on each machine, the c=
ommunication across the VLAN works fine.
>=20
> At first I thought the kernel VLAN code was the problem (we had an ea=
rlier issue with a regression in 2.6.24) but it looks like the problem =
is actually with the tg3 driver.  Our system uses Broadcom ethernet chi=
ps. I tried the same experiments with combination of boards that have B=
roadcom and none-Broadcom and the only time I see it fail is with the t=
g3  driver loaded.
>=20
> Snooping with WireShark shows that a ARP request from the non-Broadco=
m machine is seen and even answered, but never appears back on the netw=
ork. If the Broadcom machine orginates the ARP message, it never arrive=
s at the destination. I tried lowering the size of the MTU to 1492 as w=
ell as giving each VLAN device a different MAC. No deal.
>=20
> I tried to look at tg3 patch changes from 2.6.26 to 2.6.27 but I am n=
ot familiar enough with the Git system to extract the appropiate change=
s.  I am a bit surprised that I am not seeing any references to this on=
 the web, the combination of >2.6.27 kernels, Broadcom and VLAN cant be=
 that uncommon.
>=20
> I would be happy to provide more information and to try tests if any =
one can suggest them.
>=20
> Sincerely,
>=20
> Gertjan

Hello Gertjan

I'll take a look at this problem and try to reproduce it, but I use VLA=
N + tg3 +
 bonding without noticing a regression yet.

Only difference is I use "ip link add link" command to setup VLANS, not=
 vconfig,
a bit deprecated.

Could you try something like this setup=20


ip link set eth1 up

ip link add link eth1 vlan.103 type vlan id 103
ip addr add 192.168.20.110/24 dev vlan.103
ip link set vlan.103 up


