From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bridging + load balancing bonding
Date: Thu, 22 Oct 2009 19:53:50 +0200
Message-ID: <4AE09C2E.6020702@gmail.com>
References: <20091022122339.GA20148@spaans.fox.local> <4AE07D3C.3040702@gmail.com> <347.1256232960@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jasper Spaans <spaans@fox-it.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47089 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100AbZJVRxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 13:53:50 -0400
In-Reply-To: <347.1256232960@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh a =C3=A9crit :

> 	By "packets from one flow" do you really mean that packets from
> a given "flow" (TCP connection, UDP "stream", etc) are not always
> delivered to the same bonding port?  I.e., that two packets from the
> same "flow" will be delivered to different ports?  I'm not sure how
> that's possible unless the source MAC in the packets changes during t=
he
> course of the flow.
>=20
> 	Or is your problem really that the balance algorithm on the
> bonding send side doesn't match the algorithm used on the other side =
of
> the IDS machines coming the other direction (and, thus, packets for a
> given flow going in one direction end up at a different IDS than the
> packets going the other direction)?
>=20

Yes this is probably Jasper problem : catch both direction on same IDS =
target

Say you have machine A with MAC address MAC_A
and machine B with MAC address MAC_B
(I suspect asymetric routing on A or B is out of the question :) )

A tcp / udp/ whatever protocol flow is running between these two machin=
es

When machine A sends a frame to machine B, Jasper machine
receives a copy of this frame, with eth->src =3D MAC_A and eth->dst =3D=
 MAC_B

With current xor algo, we perform a hash on (bond->dev_addr[5] ^ MAC_B[=
5])  -> IDS X

When machine B sends a frame to machine A, Jasper machine
receives a copy of this frame, with eth->src =3D MAC_B and eth->dst =3D=
 MAC_A

With current xor algo, we peform a hash on (bond->dev_addr[5] ^ MAC_A[5=
])  -> possibly other IDS Y


With his fix, algo is a commutative hash (MAC_A[5] ^ MAC_B[5]) =3D=3D  =
(MAC_B[5] ^ MAC_A[5])



I suspect multicast/broadcast trafic should be sent to both IDS, so bon=
ding might be inappropriate anyway...

an iptables solution might be more powerfull
