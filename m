From: Andrei Popa <ierdnah@gmail.com>
Subject: Re: 2.6.35.11 bridge drops fragmented packets
Date: Thu, 11 Aug 2011 16:44:34 +0300
Message-ID: <1313070275.814.2.camel@ierdnac-hp>
References: <1313066585.14145.18.camel@ierdnac-hp>
	 <1313069946.3261.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: ierdnah@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55044 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab1HKNqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 09:46:08 -0400
Received: by fxh19 with SMTP id 19so1670847fxh.19
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 06:46:06 -0700 (PDT)
In-Reply-To: <1313069946.3261.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-08-11 at 15:39 +0200, Eric Dumazet wrote:=20
> Le jeudi 11 ao=FBt 2011 =E0 15:43 +0300, Andrei Popa a =E9crit :
> > Hello,
> >=20
> > We've got a problem with kernel 2.6.35.11 as it does not forward
> > fragmented packets on a bridge.
> > I've seen this thread
> > http://lkml.indiana.edu/hypermail/linux/kernel/0604.0/0201.html and=
 I
> > thought to email you.
> >=20
> > The command "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables"
> > fixes the problem.
> >=20
> > The config from the kernel is attached.
> > The network configuration is as follows:
> > cisco, interace in mode trunk with allowed vlan 1501,299 -> linux -=
>
> > cisco, interface in mode trunk with allowed vlan 1501
> >=20
> > The MTU on cisco and on linux interfaces is set to 1500.
> > Packets with size 1500 and no fragments are forwarded succesfully,
> > packets with size 1500 and fragments are not forwaded.
> > On linux it's a bond comprised of eth1.1501 and eth0.1501.
> > root@shaper_b2b_bucuresti:~# brctl show
> > bridge name     bridge id               STP enabled     interfaces
> > br1501          8000.0015170ae7b8       no              eth0.1501
> >                                                         eth1.1501
> > I cand see the fragmented packets arriving on eth0 and eth0.1501 bu=
t I
> > don't see them leaving on eth1 or eth1.1501.
> >=20
> > Andrei
> >=20
>=20
> Could you give us output of 'netstat -s' to check if IP defrag drops
> some packets ?
root@shaper_b2b_bucuresti:~# echo 1
> /proc/sys/net/bridge/bridge-nf-call-iptables

On a server behind the shaper:

nl2 ~ # ping -s 65000 lg.telia.net
PING juniperlg1-sn4.m-sp.skanova.net (81.228.10.74) 65000(65028) bytes
of data.
^C
--- juniperlg1-sn4.m-sp.skanova.net ping statistics ---
9 packets transmitted, 0 received, 100% packet loss, time 8021ms

nl2 ~ #=20


root@shaper_b2b_bucuresti:~# netstat -s
Ip:
    12783151 total packets received
    10960 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    2738144 incoming packets delivered
    2224918 requests sent out
    20 dropped because of missing route
    2380122 fragments dropped after timeout
    1502102174 reassemblies required
    662730406 packets reassembled ok
    3060985 packet reassembles failed
    5 fragments received ok
    10 fragments created
Icmp:
    352 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 327
        echo requests: 9
        echo replies: 16
    340 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 304
        echo request: 27
        echo replies: 9
IcmpMsg:
        InType0: 16
        InType3: 327
        InType8: 9
        OutType0: 9
        OutType3: 304
        OutType8: 27
Tcp:
    193 active connections openings
    14926 passive connection openings
    8 failed connection attempts
    17 connection resets received
    2 connections established
    1603905 segments received
    1248972 segments send out
    1140 segments retransmited
    0 bad segments received.
    19 resets sent
Udp:
    991041 packets received
    2 packets to unknown port received.
    0 packet receive errors
    991110 packets sent
UdpLite:
TcpExt:
    8 resets received for embryonic SYN_RECV sockets
    16113 delayed acks sent
    1 delayed acks further delayed because of locked socket
    Quick ack mode was activated 46 times
    27639 packets directly queued to recvmsg prequeue.
    1894178 bytes directly in process context from backlog
    18824 bytes directly received in process context from prequeue
    380110 packet headers predicted
    1356 packets header predicted and directly queued to user
    160586 acknowledgments not containing data payload received
    730360 predicted acknowledgments
    10 times recovered from packet loss by selective acknowledgements
    Detected reordering 7 times using time stamp
    4 congestion windows fully recovered without slow start
    9 congestion windows partially recovered using Hoe heuristic
    4 congestion windows recovered without slow start by DSACK
    16 fast retransmits
    7 forward retransmits
    21 retransmits in slow start
    229 other TCP timeouts
    46 DSACKs sent for old packets
    24 DSACKs received
    13 connections reset due to early user close
    4 connections aborted due to timeout
    TCPDSACKIgnoredOld: 12
    TCPDSACKIgnoredNoUndo: 3
    TCPSackMerged: 2
    TCPSackShiftFallback: 30
IpExt:
    InMcastPkts: 12981
    InBcastPkts: 129863
    InOctets: 1509979125
    OutOctets: 551230551
    InMcastOctets: 363468
    InBcastOctets: 8832164




