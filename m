From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 15:00:20 +0200
Message-ID: <4AA503E4.2060504@gmail.com>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>	<4AA14377.9020200@trash.net> <20090907.015039.154939751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52832 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbZIGNAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 09:00:22 -0400
In-Reply-To: <20090907.015039.154939751.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> I gave these patches a very basic bashing with NIU, and it
> seems to work from what I've tried.
>=20
> I know that Jarek has expressed some questions about the callback
> scheme used by the new mq classful qdisc, as well as some other
> issues, but we can refine this using followon patches.
>=20
> For now I'm pushing this out so that it gets wider testing.
>=20
> Thanks everyone!

Very interesting :)

Had very litle time to test this, but got problems very fast, if rate e=
stimator configured.

(Here, eth2 maps to tg3, that uses a num_tx_queues of 5, even on non mu=
ltiqueue device)
So its real_num_tx_queues is 1, but we can play with tc and mq

# tc qdisc replace dev eth2 handle 1: root estimator 1sec 8sec mq

# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 62414 bytes 401 pkt (dropped 0, overlimits 0 requeues 0)
 rate 5456bit 4pps backlog 0b 0p requeues 0

# tc qdisc replace dev eth2 parent 1:1 estimator 1sec 8sec pfifo
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 12984 bytes 88 pkt (dropped 0, overlimits 0 requeues 0)
 rate 4368bit 4pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 12984 bytes 88 pkt (dropped 0, overlimits 0 requeues 0)
 rate 9624bit 8pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 36781 bytes 244 pkt (dropped 0, overlimits 0 requeues 0)
 rate 34360Mbit 205872pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 36781 bytes 244 pkt (dropped 0, overlimits 0 requeues 0)
 rate 19824bit 16pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 52663 bytes 348 pkt (dropped 0, overlimits 0 requeues 0)
 rate 17457Mbit 105605pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 52663 bytes 348 pkt (dropped 0, overlimits 0 requeues 0)
 rate 22560bit 19pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 71775 bytes 473 pkt (dropped 0, overlimits 0 requeues 0)
 rate 11838Mbit 47402pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 71775 bytes 473 pkt (dropped 0, overlimits 0 requeues 0)
 rate 23880bit 20pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 94755 bytes 623 pkt (dropped 0, overlimits 0 requeues 0)
 rate 3562Mbit 18621pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 94755 bytes 623 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24440bit 20pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 112501 bytes 741 pkt (dropped 0, overlimits 0 requeues 0)
 rate 734270Kbit 9562pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 112501 bytes 741 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24632bit 20pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 127137 bytes 836 pkt (dropped 0, overlimits 0 requeues 0)
 rate 25390Mbit 4913pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 127137 bytes 836 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24960bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 150745 bytes 992 pkt (dropped 0, overlimits 0 requeues 0)
 rate 6212Mbit 1693pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 150745 bytes 992 pkt (dropped 0, overlimits 0 requeues 0)
 rate 25032bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 174008 bytes 1144 pkt (dropped 0, overlimits 0 requeues 0)
 rate 29377Mbit 674pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 174008 bytes 1144 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24904bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 185976 bytes 1224 pkt (dropped 0, overlimits 0 requeues 0)
 rate 13093Mbit 408pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 185976 bytes 1224 pkt (dropped 0, overlimits 0 requeues 0)
 rate 25288bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 232272 bytes 1530 pkt (dropped 0, overlimits 0 requeues 0)
 rate 5196Mbit 57pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 232272 bytes 1530 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24784bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 300071 bytes 1977 pkt (dropped 0, overlimits 0 requeues 0)
 rate 8988Mbit 6pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 300071 bytes 1977 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24432bit 20pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 377495 bytes 2490 pkt (dropped 0, overlimits 0 requeues 0)
 rate 20429Mbit 2pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 377495 bytes 2490 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24520bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 448070 bytes 2958 pkt (dropped 0, overlimits 0 requeues 0)
 rate 5726Mbit 4pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 448070 bytes 2958 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24576bit 20pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 519926 bytes 3435 pkt (dropped 0, overlimits 0 requeues 0)
 rate 265505Kbit 3pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 519926 bytes 3435 pkt (dropped 0, overlimits 0 requeues 0)
 rate 24920bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 522242 bytes 3449 pkt (dropped 0, overlimits 0 requeues 0)
 rate 232389Kbit 62pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 522242 bytes 3449 pkt (dropped 0, overlimits 0 requeues 0)
 rate 25304bit 21pps backlog 0b 0p requeues 0
# tc -s -d qdisc show dev eth2
qdisc mq 1: root
 Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
 rate 177925Kbit 49pps backlog 0b 0p requeues 0
qdisc pfifo 8001: parent 1:1 limit 1000p
 Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
 rate 25400bit 21pps backlog 0b 0p requeues 0

<<<crash>>>

(On another term I had a "ping -i 0.1 192.168.20.120" that gave :

2009/08/07 14:53:42.498 64 bytes from 192.168.20.120: icmp_seq=3D1982 t=
tl=3D64 time=3D0.126 ms
2009/08/07 14:53:42.598 64 bytes from 192.168.20.120: icmp_seq=3D1983 t=
tl=3D64 time=3D0.118 ms
2009/08/07 14:53:42.698 64 bytes from 192.168.20.120: icmp_seq=3D1984 t=
tl=3D64 time=3D0.114 ms
2009/08/07 14:53:42.798 64 bytes from 192.168.20.120: icmp_seq=3D1985 t=
tl=3D64 time=3D0.123 ms
2009/08/07 14:53:42.898 64 bytes from 192.168.20.120: icmp_seq=3D1986 t=
tl=3D64 time=3D0.126 ms
2009/08/07 14:53:42.998 64 bytes from 192.168.20.120: icmp_seq=3D1987 t=
tl=3D64 time=3D0.119 ms
2009/08/07 14:53:43.098 64 bytes from 192.168.20.120: icmp_seq=3D1988 t=
tl=3D64 time=3D0.122 ms
2009/08/07 14:53:43.198 64 bytes from 192.168.20.120: icmp_seq=3D1989 t=
tl=3D64 time=3D0.119 ms
2009/08/07 14:53:43.298 64 bytes from 192.168.20.120: icmp_seq=3D1990 t=
tl=3D64 time=3D0.117 ms
2009/08/07 14:53:43.398 64 bytes from 192.168.20.120: icmp_seq=3D1991 t=
tl=3D64 time=3D0.117 ms
ping: sendmsg: No buffer space available


