From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Tue, 17 Aug 2010 16:34:19 +0200
Message-ID: <1282055659.2448.58.camel@edumazet-laptop>
References: <alpine.DEB.1.10.1008131952470.19570@red.crap.retrofitta.se>
	 <1281953960.2524.23.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
	 <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
	 <1282024802.2487.687.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
	 <1282050920.2448.47.camel@edumazet-laptop>
	 <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:48140 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757700Ab0HQOeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 10:34:25 -0400
In-Reply-To: <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 ao=C3=BBt 2010 =C3=A0 16:09 +0200, Thomas Habets a =C3=A9cr=
it :
> On Tue, 17 Aug 2010, Eric Dumazet wrote:
> > Can you try : "ifconfig eth0 allmulti"
>=20
> That didn't help. "ifconfig eth0" and "ip l" shows that allmulti is n=
ow=20
> set, but no other difference. Can't ping router, and router gets no a=
nswer=20
> when pinging ff02::1. No message in dmesg saying allmulti isn't suppo=
rted=20
> or anything like that either.
>=20
> > If you let a "tcpdump" running with -p option, do you receive the p=
acket
> > sent to ethernet dest 33:33:ff:5c:00:02 ?
>=20
> No. Commented tcpdump output below.
>=20
> > If you can see it with tcpdump, then NIC gave the frame to us.
>=20
> Seems to be invisible unless I or tcpdump set promisc mode. But when=20
> promisc mode is set I can immediately see the 33:33:ff:5c:00:02 packe=
t=20
> (ND solicitation) and I see that Linux is answering it.
>=20
> Here's a tcpdump from the Linux host. It's slightliy trimmed to fit i=
n
> an email, but the full dump is at http://www.habets.pp.se/tmp/ipv6.pc=
ap
>=20
> $ sudo tcpdump -pnli eth0 -s0 -w ipv6.pcap ip6
> [...]
>=20
> $ tcpdump -nlr ipv6.pcap
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
>=20
> [ here I run "clear ipv6 neighbors" on the Cisco router ]
>=20
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> [ ... more repeated echo requests, no reply ... ]
>=20
> [ here i run "ip l set promisc on eth0" ]
>=20
> 2a00:800:752:1::5c:1 > ff02::1:ff5c:2: ICMP6, neighbor solicitation, =
who=20
> has 2a00:800:752:1::5c:2
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6,neighbor advertise=
ment,
> tgt is 2a00:800:752:1::5c:2
> 2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:1 > 2a00:800:752:1::5c:2: ICMP6, echo reply
>=20
> [ here I run "clear ipv6 neigbors" again ]
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request
> 2a00:800:752:1::5c:2 > 2a00:800:752:1::5c:1: ICMP6, echo request

I suspect its time to ask broadcom guys some help :)

I have same adapter here (Hewlett-Packard Company NC326m PCIe Dual Port
Adapter) and could not reproduce the problem.

Try following patch to check tg3 receives correct multicast list (its O=
K
for me, seen on dmesg output)

[17162.120238]  add mc_addr(ha->addr=3D33:33:00:00:00:01)
[17162.120270]  add mc_addr(ha->addr=3D01:00:5e:00:00:01)
[17162.120298]  add mc_addr(ha->addr=3D33:33:ff:87:96:ce)
[17162.120326]  add mc_addr(ha->addr=3D33:33:ff:5c:00:02)
[17162.120355] filters=3D80000001 00000000 00400000 40000000


But if problem remains even with "ifconfig eth0 allmulti" I suspect a
NIC firmware problem. (allmulti set to 1 all the 128 bits of filters)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bc3af78..34510f5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9317,12 +9317,14 @@ static void __tg3_set_rx_mode(struct net_device=
 *dev)
 		u32 crc;
=20
 		netdev_for_each_mc_addr(ha, dev) {
+			pr_err("add mc_addr(ha->addr=3D%pM)\n", ha->addr);
 			crc =3D calc_crc(ha->addr, ETH_ALEN);
 			bit =3D ~crc & 0x7f;
 			regidx =3D (bit & 0x60) >> 5;
 			bit &=3D 0x1f;
 			mc_filter[regidx] |=3D (1 << bit);
 		}
+		pr_err("filters=3D%08X %08x %08x %08x\n", mc_filter[0], mc_filter[1]=
, mc_filter[2], mc_filter[3]);
=20
 		tw32(MAC_HASH_REG_0, mc_filter[0]);
 		tw32(MAC_HASH_REG_1, mc_filter[1]);


