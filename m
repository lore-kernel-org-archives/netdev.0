From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bond interface arp, vlan and trunk / network question
Date: Mon, 20 Apr 2009 17:01:52 -0700
Message-ID: <22462.1240272112@death.nxdomain.ibm.com>
References: <1ef444010904201050g72651387se3feca3fbd68ce30@mail.gmail.com> <49ECBBF0.80202@cosmosbay.com> <30257.1240252651@death.nxdomain.ibm.com> <1ef444010904201300r43268672sb74277f4a0242236@mail.gmail.com> <7609.1240259780@death.nxdomain.ibm.com> <1ef444010904201403s5d583750i1ce3a5da6c6f4059@mail.gmail.com> <13606.1240262581@death.nxdomain.ibm.com> <1ef444010904201439i60f9e918j760d94eeca428ece@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: stefan novak <lms.brubaker@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:42626 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752389AbZDUABs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 20:01:48 -0400
In-reply-to: <1ef444010904201439i60f9e918j760d94eeca428ece@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

stefan novak <lms.brubaker@gmail.com> wrote:

>ip route get 172.21.0.254
>172.21.0.254 dev bond0.600  src 172.21.0.1
>    cache  mtu 1500 advmss 1460 hoplimit 64
>
>ifconfig -a :
>bond0     Link encap:Ethernet  HWaddr 00:30:48:94:7D:1A
>          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>          RX packets:62221072 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:1152153 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:4037489679 (3.7 GiB)  TX bytes:124861822 (119.0 MiB=
)
>
>bond0.200 Link encap:Ethernet  HWaddr 00:30:48:94:7D:1A
>          inet addr:172.22.0.1  Bcast:172.22.0.255  Mask:255.255.255.0
>          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>          RX packets:5 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:250 (250.0 b)  TX bytes:252 (252.0 b)
>
>bond0.500 Link encap:Ethernet  HWaddr 00:30:48:94:7D:1A
>          inet addr:172.20.0.1  Bcast:172.20.0.255  Mask:255.255.255.0
>          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>          RX packets:26448 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:33570 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:6278388 (5.9 MiB)  TX bytes:6429404 (6.1 MiB)
>
>bond0.600 Link encap:Ethernet  HWaddr 00:30:48:94:7D:1A
>          inet addr:172.21.0.1  Bcast:172.21.0.255  Mask:255.255.255.0
>          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>          RX packets:1911 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:8665 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:98604 (96.2 KiB)  TX bytes:1208395 (1.1 MiB)
>
>eth0      Link encap:Ethernet  HWaddr 00:30:48:94:7D:1A
>          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
>          RX packets:881723 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:1074651 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:1000
>          RX bytes:108550619 (103.5 MiB)  TX bytes:115574099 (110.2 Mi=
B)
>          Memory:f8220000-f8240000
>
>eth1      Link encap:Ethernet  HWaddr 00:30:48:94:7D:1A
>          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
>          RX packets:61339352 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:77510 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:1000
>          RX bytes:3928939240 (3.6 GiB)  TX bytes:9290795 (8.8 MiB)
>          Memory:f8260000-f8280000
>
>lo        Link encap:Local Loopback
>          inet addr:127.0.0.1  Mask:255.0.0.0
>          UP LOOPBACK RUNNING  MTU:16436  Metric:1
>          RX packets:105468 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:105468 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:7016087 (6.6 MiB)  TX bytes:7016087 (6.6 MiB)

	This looks pretty much as expected.

[...]
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0There's no "self test" or anything like t=
hat, if that's what you
>> mean. =C2=A0If the ARPs work (make the round trip) the link is up, i=
f they
>> don't, the link is down. =C2=A0That's subject to some details relate=
d to
>> arp_validate, but is basically it.
>
>Ok. my interfaces are now up with arp_validate set to 0/none.
>Everything works as expected, thank you.
>But with arp_validate set to all the interfaces are always down. :(
>I think that i have to use the all option because i have many servers
>in that vlan?

	Well, you'll probably want to run with arp_validate, otherwise
the probe traffic can fool the arp monitor into thinking the path is up
when it isn't.

	But...

	I know what your problem with arp_validate is, though, and it's
something I've been working on as time permits (and forgot to mention
previously).  Basically, the VLAN receive path assigns the VLAN device
to the received packet before doing receive processing on it, so the
"slave" identity is lost before the bonding ARP receive function looks
at it, so it never counts the ARP (for validate purposes).

	I've been chewing on the least bad way to fix this, mostly
trying to figure out if its possible to resolve without adding a hook
into bonding that basically replaces and extends skb_bond_should_drop
(which does work, it's just not very elegant).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

