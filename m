From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ixgbe RSS not working as expected with 8021q and bridging
Date: Tue, 15 Dec 2009 20:33:53 +0100
Message-ID: <4B27E4A1.4050802@gmail.com>
References: <20091210231103.GA20231@esk.cs.usu.edu> <4B218E36.4030808@gmail.com> <20091215172119.GF20231@esk.cs.usu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eldon Koyle <esk-netdev@esk.cs.usu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49854 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933456AbZLOTeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 14:34:09 -0500
In-Reply-To: <20091215172119.GF20231@esk.cs.usu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/12/2009 18:21, Eldon Koyle a =E9crit :
> On  Dec 11  1:11+0100, Eric Dumazet wrote:
>> Le 11/12/2009 00:11, Eldon Koyle a =E9crit :
>>> We have built a firewall with two 10 Gbit interfaces (intel 82598EB=
) and
>>> are doing some testing.  A simple bridge between the two interfaces=
 acts
>>> as expected with packets being distributed fairly evenly across all=
 of
>>> the rx/tx queues.
>>>
>>> We then switched to tagged vlans on both interfaces (10 vlans each,=
 8
>>> source and 8 dest addresses per vlan) and bridged eth0.N to eth1.N,=
 and
>>> many of our queues (and CPUs) remained idle, and all of our VLAN tr=
affic
>>> went out on the same tx queue.  Are multiple transmit queues suppor=
ted
>>> with 802.1q?  How do we figure out what is causing some of our rece=
ive
>>> queues to be unused?
>>>
>>> We are using 2.6.31 (from Debian) and ixgbe-2.0.44.14 .
>>>
>>
>> You need more recent kernel (2.6.32) to get multi queue support on v=
lans, sorry.
>=20
> Excellent.  2.6.32 solved half of the problem.  Now, we are using the
> same number of rx and tx queues.  We are still seeing no packets on 3=
 of
> our 8 rx queues on each interface, though (no packets on 2, 4 or 6).
> Does the card assign queues in hardware, or is that handled by the
> kernel?
>=20

When a packet is received (ethernet -> Card), the hardware chooses a RX=
 queue using
hash function.

Then, in your forwarding setup, we (the kernel) automaticaly use same q=
ueue to transmit packet.

So if only 5 queues out of 8 receive trafic, it might be because of the=
 flows all map to only 5 queues,
but you should ask Intel people for details :)

(They usualy read netdev)
