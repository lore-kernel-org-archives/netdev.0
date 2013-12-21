From: "Bob Falken" <NetFestivalHaveFun@gmx.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Sat, 21 Dec 2013 23:35:00 +0100
Message-ID: <20131221223501.110860@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ben Greear" <greearb@candelatech.com>, netdev@vger.kernel.org
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:55597 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753252Ab3LUWfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Dec 2013 17:35:04 -0500
Received: from mailout-eu.gmx.com ([10.1.101.210]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MFOX4-1VgDOT3aNg-00EONd for
 <netdev@vger.kernel.org>; Sat, 21 Dec 2013 23:35:01 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, so at the exact time that the incoming interface for multicast pack=
et count reaches 2^32,=20
the /proc/net/ip_mr_cache stops updating.=20
after a while, one by one the multicast groups in ip_mr_cache disappere=
s, and after 227sec all of them are gone.=20


perf script net_dropmonitor:
-----------
# =3D=3D=3D=3D=3D=3D=3D=3D
# captured on: Sat Dec 21 23:27:37 2013
# =3D=3D=3D=3D=3D=3D=3D=3D
#
Starting trace (Ctrl-C to dump results)
Warning:
Processed 788648 events and lost 118 chunks!
=20
Check IO/CPU overload!
=20
Gathering kallsyms data
35200/35200
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0LOCATION =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0OF=
=46SET =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 COUNT
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0_s=
text =C2=A0 =C2=A0 =C2=A018446744071578845580 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 6
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0_s=
text =C2=A0 =C2=A0 =C2=A018446744071578843536 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0785790
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0_s=
text =C2=A0 =C2=A0 =C2=A018446744071578843530 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 1
=20
=20
=20
-------------
=20
netstat -s:
Ip:
=C2=A0 =C2=A0 622406 total packets received
=C2=A0 =C2=A0 2 with invalid addresses
=C2=A0 =C2=A0 0 forwarded
=C2=A0 =C2=A0 0 incoming packets discarded
=C2=A0 =C2=A0 599574 incoming packets delivered
=C2=A0 =C2=A0 520762 requests sent out
=C2=A0 =C2=A0 8 dropped because of missing route
Icmp:
=C2=A0 =C2=A0 19361 ICMP messages received
=C2=A0 =C2=A0 0 input ICMP message failed.
=C2=A0 =C2=A0 ICMP input histogram:
=C2=A0 =C2=A0 =C2=A0 =C2=A0 echo requests: 8415
=C2=A0 =C2=A0 =C2=A0 =C2=A0 echo replies: 10946
=C2=A0 =C2=A0 19361 ICMP messages sent
=C2=A0 =C2=A0 0 ICMP messages failed
=C2=A0 =C2=A0 ICMP output histogram:
=C2=A0 =C2=A0 =C2=A0 =C2=A0 echo request: 10946
=C2=A0 =C2=A0 =C2=A0 =C2=A0 echo replies: 8415
IcmpMsg:
=C2=A0 =C2=A0 =C2=A0 =C2=A0 InType0: 10946
=C2=A0 =C2=A0 =C2=A0 =C2=A0 InType8: 8415
=C2=A0 =C2=A0 =C2=A0 =C2=A0 OutType0: 8415
=C2=A0 =C2=A0 =C2=A0 =C2=A0 OutType8: 10946
Tcp:
=C2=A0 =C2=A0 15 active connections openings
=C2=A0 =C2=A0 15 passive connection openings
=C2=A0 =C2=A0 0 failed connection attempts
=C2=A0 =C2=A0 0 connection resets received
=C2=A0 =C2=A0 29 connections established
=C2=A0 =C2=A0 477938 segments received
=C2=A0 =C2=A0 482321 segments send out
=C2=A0 =C2=A0 4 segments retransmited
=C2=A0 =C2=A0 0 bad segments received.
=C2=A0 =C2=A0 0 resets sent
Udp:
=C2=A0 =C2=A0 586 packets received
=C2=A0 =C2=A0 0 packets to unknown port received.
=C2=A0 =C2=A0 0 packet receive errors
=C2=A0 =C2=A0 649 packets sent
UdpLite:
TcpExt:
=C2=A0 =C2=A0 15862 delayed acks sent
=C2=A0 =C2=A0 Quick ack mode was activated 1 times
=C2=A0 =C2=A0 1 packets directly queued to recvmsg prequeue.
=C2=A0 =C2=A0 390374 packet headers predicted
=C2=A0 =C2=A0 1767 acknowledgments not containing data payload received
=C2=A0 =C2=A0 58169 predicted acknowledgments
=C2=A0 =C2=A0 4 congestion windows recovered without slow start after p=
artial ack
=C2=A0 =C2=A0 4 other TCP timeouts
=C2=A0 =C2=A0 1 DSACKs sent for old packets
=C2=A0 =C2=A0 4 DSACKs received
=C2=A0 =C2=A0 TCPSackShiftFallback: 3
IpExt:
=C2=A0 =C2=A0 InNoRoutes: 1
=C2=A0 =C2=A0 InMcastPkts: 40015
=C2=A0 =C2=A0 OutMcastPkts: 18427
=C2=A0 =C2=A0 InBcastPkts: 80035
=C2=A0 =C2=A0 InOctets: 1116615859
=C2=A0 =C2=A0 OutOctets: 33742922
=C2=A0 =C2=A0 InMcastOctets: 1046924948
=C2=A0 =C2=A0 OutMcastOctets: 734556
=C2=A0 =C2=A0 InBcastOctets: 7255577
 =C2=A0
=20
---------------------=20
----- Original Message -----
=46rom: Hannes Frederic Sowa
Sent: 12/19/13 06:32 PM
To: Eric Dumazet
Subject: Re: Multicast routing stops functioning after 4G multicast pac=
kets recived.
 On Thu, Dec 19, 2013 at 09:24:18AM -0800, Eric Dumazet wrote:
> On Thu, 2013-12-19 at 17:28 +0100, Bob Falken wrote:
> > The only reason why i give information about 2.6.36.4 is that its t=
he
> > only latest kernel that was functioning properly.
> > i.e kernel >=3D 2.6.37 is not woking. so its a bisecting of the ker=
nel
> > versions to help a coder see when/where the isse was implemented in
> > the kernel.
> >=20
> > I do not need a backport patch for an old kernel, I generally only
> > need the issue looked into and get fixed so that I dont have to use=
 an
> > old kernel. :)
> >=20
> > I have no issue reproducing the issue on the recent kernels. howeve=
r i
> > have not tried the GIT kernel.
> >=20
> > I restarted the server just a moment ago. i will install and run
> > dropwatch and provide feedback in about 17hours.=20
>=20
> You said that "cat /proc/net/ip_mr_cache" gives nothing at all after
> 2^32 packets ?
>=20
> Thats a bit scary ... maybe a 32bit refcnt overflow, because of some
> imbalance...

That's my thought, too. :/

The ipmr.c rcu conversion happend in 2.6.37.=20
