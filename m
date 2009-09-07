From: Patrick McHardy <kaber@trash.net>
Subject: Re: net_sched 00/07: classful multiqueue dummy scheduler
Date: Mon, 07 Sep 2009 15:29:51 +0200
Message-ID: <4AA50ACF.9010400@trash.net>
References: <20090904164111.27300.29929.sendpatchset@x2.localnet>	<4AA14377.9020200@trash.net> <20090907.015039.154939751.davem@davemloft.net> <4AA503E4.2060504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34083 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbZIGN3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 09:29:51 -0400
In-Reply-To: <4AA503E4.2060504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> David Miller a =E9crit :
>> I gave these patches a very basic bashing with NIU, and it
>> seems to work from what I've tried.
>>
>> I know that Jarek has expressed some questions about the callback
>> scheme used by the new mq classful qdisc, as well as some other
>> issues, but we can refine this using followon patches.
>>
>> For now I'm pushing this out so that it gets wider testing.
>>
>> Thanks everyone!
>=20
> Very interesting :)
>=20
> Had very litle time to test this, but got problems very fast, if rate=
 estimator configured.

I didn't test that, but I'll look into it.

> qdisc mq 1: root
>  Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 177925Kbit 49pps backlog 0b 0p requeues 0
> qdisc pfifo 8001: parent 1:1 limit 1000p
>  Sent 528702 bytes 3491 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 25400bit 21pps backlog 0b 0p requeues 0
>=20
> <<<crash>>>

Did you capture the crash?

> (On another term I had a "ping -i 0.1 192.168.20.120" that gave :
>=20
> 2009/08/07 14:53:42.498 64 bytes from 192.168.20.120: icmp_seq=3D1982=
 ttl=3D64 time=3D0.126 ms
> 2009/08/07 14:53:42.598 64 bytes from 192.168.20.120: icmp_seq=3D1983=
 ttl=3D64 time=3D0.118 ms
> 2009/08/07 14:53:42.698 64 bytes from 192.168.20.120: icmp_seq=3D1984=
 ttl=3D64 time=3D0.114 ms
> 2009/08/07 14:53:42.798 64 bytes from 192.168.20.120: icmp_seq=3D1985=
 ttl=3D64 time=3D0.123 ms
> 2009/08/07 14:53:42.898 64 bytes from 192.168.20.120: icmp_seq=3D1986=
 ttl=3D64 time=3D0.126 ms
> 2009/08/07 14:53:42.998 64 bytes from 192.168.20.120: icmp_seq=3D1987=
 ttl=3D64 time=3D0.119 ms
> 2009/08/07 14:53:43.098 64 bytes from 192.168.20.120: icmp_seq=3D1988=
 ttl=3D64 time=3D0.122 ms
> 2009/08/07 14:53:43.198 64 bytes from 192.168.20.120: icmp_seq=3D1989=
 ttl=3D64 time=3D0.119 ms
> 2009/08/07 14:53:43.298 64 bytes from 192.168.20.120: icmp_seq=3D1990=
 ttl=3D64 time=3D0.117 ms
> 2009/08/07 14:53:43.398 64 bytes from 192.168.20.120: icmp_seq=3D1991=
 ttl=3D64 time=3D0.117 ms
> ping: sendmsg: No buffer space available

Was this also with rate estimators? No buffer space available
indicates that some class/qdisc isn't dequeued or the packets
are leaking, so the output of tc -s -d qdisc show ... might be
helpful.

