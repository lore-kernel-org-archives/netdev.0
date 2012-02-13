From: alekcejk@googlemail.com
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Mon, 13 Feb 2012 23:16:55 +0200
Message-ID: <3724891.xPvvFc3DxN@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <1329164293.2523.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59092 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755923Ab2BMVRL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 16:17:11 -0500
Received: by bkcjm19 with SMTP id jm19so4908946bkc.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 13:17:10 -0800 (PST)
In-Reply-To: <1329164293.2523.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=9F=D0=BE=D0=BD=D0=B5=D0=B4=D0=B5=D0=BB=D1=8C=D0=BD=D0=B8=D0=BA =
13 =D1=84=D0=B5=D0=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 21:18:13 =D0=B2=D1=8B=
 =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> Le lundi 13 f=C3=A9vrier 2012 =C3=A0 22:04 +0200, alekcejk@googlemail=
=2Ecom a
>=20
> =C3=A9crit :
> > Hi,
> >=20
> > I noticed that with 3.2.x kernels download speed from some internet=
 resources
> > became about half of speed that was with previous kernels (3.1 and =
older).
> > I tested Fedora 15 kernels 2.6.41.10 =3D 3.1.10 and 2.6.42.3 =3D 3.=
2.3
> > (many times rebooted for testing with first and second kernels).
> > See bug https://bugzilla.redhat.com/show_bug.cgi?id=3D789659
> >=20
> > lsmod:
> > Module                  Size  Used by
> > nvidia              10778232  40
> > i2c_core               28123  1 nvidia
> > 8139too                32490  0
> > mii                    13311  1 8139too
> >=20
> > dmesg:
> > 8139too: 8139too Fast Ethernet driver 0.9.28
> > 8139too 0000:01:02.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
> > 8139too 0000:01:02.0: eth0: RealTek RTL8139 at , IRQ 22
> > 8139too 0000:01:02.0: eth0: link up, 100Mbps, full-duplex, lpa 0x41=
E1
> >=20
> > For testing I selected fastest for me download mirrors of FreeBSD a=
nd Ubuntu,
> > also I tested download speed from site speedtest.tele2.net.
> >=20
> > For these sites download speed with 3.1 kernels (and older) is abou=
t 11 MB/s
> > but with 3.2.x kernels - limited 5.5 MB/s and for some sites still =
approximately
> > the same as with 3.1 kernels (see bug mentioned above).
>=20
> MB/s means MBytes or Mbits ?

MB means MegaBytes. This should explain it:

=46reeBSD-8.2-RELEASE-i386-dvd1.iso.xz size 2066424512 bytes (1.9 G) do=
wnloaded with both kernels:

kernel 3.1.10:  saved in 3m 31s 9,32 Megabytes/second - average speed, =
11,1 Megabytes/second maximum
kernel 3.2.3: saved in 5m 56s 5,54 Megabytes/second - average speed, 5,=
64 Megabytes/s - maximum speed

>=20
> > Also I want to pay attention that limited speed stays constant - al=
ways
> > 5.5 MB/s with straight line on traffic plotter as if was network ba=
ndwidth shaping.
> > With 3.1 kernels this never happens - speed can vary in some ranges
> > but at maximum it is about 11 MB/s, no limitations such as 5.5 MB/s=
=2E
>=20
> Could you post "netstat -s" result ?

"netstat -s" just after system started and download finished

kernel 3.1.10:

Ip:
    1472431 total packets received
    0 forwarded
    0 incoming packets discarded
    1469765 incoming packets delivered
    755430 requests sent out
    1 outgoing packets dropped
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
    1 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        echo request: 1
IcmpMsg:
        OutType8: 1
Tcp:
    4 active connections openings
    0 passive connection openings
    0 failed connection attempts
    0 connection resets received
    0 connections established
    1469723 segments received
    755378 segments send out
    0 segments retransmited
    0 bad segments received.
    32997 resets sent
Udp:
    35 packets received
    0 packets to unknown port received.
    0 packet receive errors
    52 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    1 TCP sockets finished time wait in fast timer
    22 delayed acks sent
    1448 packets directly received from backlog
    1429173 packets header predicted
    1 packets header predicted and directly queued to user
    2 acknowledgments not containing data received
    18 predicted acknowledgments
    0 TCP data loss events
    1 connections reset due to unexpected data
    IPReversePathFilter: 47
IpExt:
    InNoRoutes: 218
    InMcastPkts: 2
    InBcastPkts: 46
    OutBcastPkts: 17
    InOctets: 2157119711
    OutOctets: 38981662
    InMcastOctets: 56
    InBcastOctets: 3704
    OutBcastOctets: 768




kernel 3.2.3:=20

Ip:
    1487136 total packets received
    0 forwarded
    0 incoming packets discarded
    1482687 incoming packets delivered
    769964 requests sent out
    1 outgoing packets dropped
Icmp:
    0 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
    1 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        echo request: 1
IcmpMsg:
        OutType8: 1
Tcp:
    2 active connections openings
    0 passive connection openings
    0 failed connection attempts
    0 connection resets received
    0 connections established
    1482636 segments received
    769905 segments send out
    0 segments retransmited
    0 bad segments received.
    55530 resets sent
Udp:
    42 packets received
    0 packets to unknown port received.
    0 packet receive errors
    59 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    1 TCP sockets finished time wait in fast timer
    15 delayed acks sent
    1425598 packets header predicted
    1 acknowledgments not containing data received
    9 predicted acknowledgments
    0 TCP data loss events
    IPReversePathFilter: 48
IpExt:
    InNoRoutes: 235
    InMcastPkts: 4
    InBcastPkts: 47
    OutBcastPkts: 17
    InOctets: 2143692697
    OutOctets: 39392421
    InMcastOctets: 112
    InBcastOctets: 3941
    OutBcastOctets: 768
