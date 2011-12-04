From: Chris Adams <cmadams@hiwaay.net>
Subject: Re: r8169 performance?
Date: Sun, 4 Dec 2011 16:02:55 -0600
Message-ID: <20111204220255.GB32098@hiwaay.net>
References: <20111204211007.GA32098@hiwaay.net> <1323035402.2762.189.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fly.hiwaay.net ([216.180.54.1]:49734 "EHLO fly.hiwaay.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987Ab1LDWC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 17:02:56 -0500
Content-Disposition: inline
In-Reply-To: <1323035402.2762.189.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once upon a time, Eric Dumazet <eric.dumazet@gmail.com> said:
> Le dimanche 04 d=E9cembre 2011 =E0 15:10 -0600, Chris Adams a =E9crit=
 :
> > I have a system with an on-board RealTek gigabit network interface =
that
> > is giving me poor performance.  I'm using a simple test, running "n=
c -l"
> > on one system and "dd if=3D/dev/zero | nc" on another.  I see about=
 280
> > Mbps transmit and 511 Mbps receive.
>=20
> Do you mean that if this problematic NIC is the receiver, it receives
> 280Mbps, and if it is the sender, speed is 511 Mbps ?

No, the other way around (the problem NIC transmits at 280Mbps and
receives at 511Mbps).

> Could you check counters ? =20

Is there anything specific to look at?  I'm not seeing anything that
looks like a problem to me (for example, the "144 dropped because of
missing route" all appear to be from during boot; that number isn't
changing).

> netstat -s

Ip:
    818382 total packets received
    0 forwarded
    0 incoming packets discarded
    818382 incoming packets delivered
    1190521 requests sent out
    144 dropped because of missing route
Icmp:
    2 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 1
        echo requests: 1
    1 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        echo replies: 1
IcmpMsg:
        InType3: 1
        InType8: 1
        OutType0: 1
Tcp:
    11 active connections openings
    15 passive connection openings
    5 failed connection attempts
    1 connection resets received
    5 connections established
    821140 segments received
    1193282 segments send out
    7 segments retransmited
    0 bad segments received.
    11 resets sent
Udp:
    318 packets received
    0 packets to unknown port received.
    0 packet receive errors
    318 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    4 TCP sockets finished time wait in fast timer
    23 delayed acks sent
    7 packets directly queued to recvmsg prequeue.
    410916 packets header predicted
    105061 acknowledgments not containing data received
    304005 predicted acknowledgments
    0 TCP data loss events
    2 retransmits in slow start
    6 other TCP timeouts
    TCPSackShiftFallback: 1
    TCPBacklogDrop: 75
IpExt:
    InMcastPkts: 21
    InBcastPkts: 43
    InOctets: 1653475944
    OutOctets: 1201322384
    InMcastOctets: 672
    InBcastOctets: 7813

> ethtool -S ethX

NIC statistics:
     tx_packets: 1192416
     rx_packets: 1522908
     tx_errors: 0
     rx_errors: 0
     rx_missed: 0
     align_errors: 0
     tx_single_collisions: 0
     tx_multi_collisions: 0
     unicast: 1522391
     broadcast: 474
     multicast: 43
     tx_aborted: 0
     tx_underrun: 0

> cat /proc/net/softnet_stat

000c8dc9 00000000 00000000 00000000 00000000 00000000 00000000 00000000=
 00000000 00000000

--=20
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
