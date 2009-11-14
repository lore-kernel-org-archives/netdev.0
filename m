From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP throughput drops sharply around MTU of 180 bytes
Date: Sat, 14 Nov 2009 11:19:14 +0100
Message-ID: <4AFE8422.4000901@gmail.com>
References: <51d384e10911140028r76e1aefei3a224b5c542d82e8@mail.gmail.com>	 <4AFE6FF0.3030101@gmail.com> <4AFE748C.3050100@gmail.com> <51d384e10911140124g285621a5n54afa1bdb1b02997@mail.gmail.com> <4AFE7F15.1080504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ang Way Chuang <wcang79@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38897 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbZKNKTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 05:19:11 -0500
In-Reply-To: <4AFE7F15.1080504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Ang Way Chuang a =E9crit :
>> I assume that ip route .... advmss achieves that effect? I tried it,
>> but it doesn't work.
>>
>=20
> It should. Please provide your kernel version and what you tried exac=
tly.
>=20
>=20

Here a tcpdump of an iperf -M 120 session on current net-next-2.6 kerne=
l
iperf -M 120 -c 192.168.0.1 -m
WARNING: attempt to set TCP maximum segment size to 120, but got 536
------------------------------------------------------------
Client connecting to 192.168.0.1, TCP port 5001
TCP window size: 16.0 KByte (default)
------------------------------------------------------------
[  3] local 192.168.0.2 port 48178 connected with 192.168.0.1 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0-10.0 sec  26.4 MBytes  22.1 Mbits/sec
[  3] MSS size 108 bytes (MTU 148 bytes, unknown interface)


hints :

1) Use iperf -M 120 flag on both sides
2) disable tso/gso on sender
   ethtool -K eth0 tso off gso off

11:15:17.052202 IP 192.168.0.2.48177 > 192.168.0.1.5001: S 3914872183:3=
914872183(0) win 480 <mss 120,nop,nop,timestamp 63768988 0,nop,wscale 6=
>
11:15:17.052291 IP 192.168.0.1.5001 > 192.168.0.2.48177: S 2771326659:2=
771326659(0) ack 3914872184 win 432 <mss 120,nop,nop,timestamp 58092392=
0 63768988,nop,wscale 6>
11:15:17.052494 IP 192.168.0.2.48177 > 192.168.0.1.5001: . ack 1 win 8 =
<nop,nop,timestamp 63768988 580923920>
11:15:17.052514 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 1:25(24) ack=
 1 win 8 <nop,nop,timestamp 63768988 580923920>
11:15:17.052532 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 25:133(108) =
ack 1 win 8 <nop,nop,timestamp 63768988 580923920>
11:15:17.052534 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 133:241(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923920>
11:15:17.052537 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 241:349(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923920>
11:15:17.052612 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 25 win 7=
 <nop,nop,timestamp 580923921 63768988>
11:15:17.052621 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 349:457(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052624 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 133 win =
7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052629 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 457:565(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052631 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 349 win =
7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052635 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 565:673(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052638 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 673:781(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052711 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 565 win =
7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052715 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 781:889(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052718 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 889:997(108)=
 ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052720 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 781 win =
7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052724 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 997:1105(108=
) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052727 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 1105:1213(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052804 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 997 win =
7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052813 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 1213:1321(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052816 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 1321:1429(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052823 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 1213 win=
 7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052827 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 1429:1537(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052829 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 1537:1645(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052901 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 1429 win=
 7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052910 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 1645:1753(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052913 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 1753:1861(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052914 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 1645 win=
 7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052917 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 1861:1969(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052920 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 1969:2077(10=
8) ack 1 win 8 <nop,nop,timestamp 63768988 580923921>
11:15:17.052990 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 1861 win=
 7 <nop,nop,timestamp 580923921 63768988>
11:15:17.052996 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 2077:2185(10=
8) ack 1 win 8 <nop,nop,timestamp 63768989 580923921>
11:15:17.052999 IP 192.168.0.2.48177 > 192.168.0.1.5001: P 2185:2293(10=
8) ack 1 win 8 <nop,nop,timestamp 63768989 580923921>
11:15:17.053001 IP 192.168.0.1.5001 > 192.168.0.2.48177: . ack 2077 win=
 7 <nop,nop,timestamp 580923921 63768988>
11:15:17.053005 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 2293:2401(10=
8) ack 1 win 8 <nop,nop,timestamp 63768989 580923921>
11:15:17.053008 IP 192.168.0.2.48177 > 192.168.0.1.5001: . 2401:2509(10=
8) ack 1 win 8 <nop,nop,timestamp 63768989 580923921>


