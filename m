From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet time delays on multi-core systems
Date: Fri, 01 Oct 2010 14:59:26 +0200
Message-ID: <1285937966.2641.117.camel@edumazet-laptop>
References: <20100929191851.GC86786@beaver.vrungel.ru>
	 <1285796721.5211.156.camel@edumazet-laptop>
	 <20100930062419.GD86786@beaver.vrungel.ru>
	 <1285828432.5211.812.camel@edumazet-laptop>
	 <20100930122321.GA1575@beaver.vrungel.ru>
	 <1285850669.2615.426.camel@edumazet-laptop>
	 <20100930173732.GB4094@beaver.vrungel.ru>
	 <1285869782.2615.920.camel@edumazet-laptop>
	 <20100930181556.GC4094@beaver.vrungel.ru>
	 <1285872765.2615.1008.camel@edumazet-laptop>
	 <20101001101650.GD4094@beaver.vrungel.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexey Vlasov <renton@renton.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53558 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932466Ab0JAM7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 08:59:33 -0400
In-Reply-To: <20101001101650.GD4094@beaver.vrungel.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 01 octobre 2010 =C3=A0 14:16 +0400, Alexey Vlasov a =C3=A9c=
rit :

> I have also found that:
> 1. rx overruns is increasing.
> 2. rx_queue_drop_packet_count is increasing.

So you flood machine with packets, its not an idle one ?

I thought you were doing experiments with light trafic.


> # ethtool -S eth0 | grep drop
>      tx_dropped: 0
>      rx_queue_drop_packet_count: 1260743751
>      dropped_smbus: 0
>      rx_queue_0_drops: 0
>      rx_queue_1_drops: 0
>      rx_queue_2_drops: 0
>      rx_queue_3_drops: 0
>=20


ethtool -S eth0   (full output, not small parts)


> 3. By sending SYN-packets by hping, RST packet doesn't send, but I do=
n't know may=20
> be it is just some feature in 2.6.32.
> newbox # hping -c 1 -S -p 80 111.111.111.111
> HPING 111.111.111.111 (eth0 111.111.111.111): S set, 40 headers + 0 d=
ata bytes
> len=3D46 ip=3D111.111.111.111 ttl=3D58 DF id=3D11471 sport=3D80 flags=
=3DSA seq=3D0 win=3D65535 rtt=3D99.0 ms
>=20
> --- 111.111.111.111 hping statistic ---
> 1 packets tramitted, 1 packets received, 0% packet loss
> round-trip min/avg/max =3D 99.0/99.0/99.0 ms
>=20
> 13:59:07.439528 IP newbox.2777 > 111.111.111.111.80: S 345595033:3455=
95033(0) win 512
> 13:59:07.439626 IP 111.111.111.111.80 > newbox.2777: S 1178827395:117=
8827395(0) ack 345595034 win 65535 <mss 1460>
> 13:59:10.439368 IP 111.111.111.111.80 > newbox.2777: S 1178827395:117=
8827395(0) ack 345595034 win 65535 <mss 1460>
> 13:59:16.439313 IP 111.111.111.111.80 > newbox.2777: S 1178827395:117=
8827395(0) ack 345595034 win 65535 <mss 1460>
> 13:59:28.439206 IP 111.111.111.111.80 > newbox.2777: S 1178827395:117=
8827395(0) ack 345595034 win 65535 <mss 1460>
>=20
> As a result I got doubles:

Are you playing with trafic shaping ?

tc -s -d qdisc



> DUP! len=3D46 ip=3D111.111.111.111 ttl=3D58 DF id=3D27454 sport=3D80 =
flags=3DSA seq=3D0 win=3D65535 rtt=3D3137.8 ms
>=20
> Example of another TCP-session from 2.6.28 kernel:
> oldbox # hping -c 1 -S -p 80 111.111.111.111
> HPING 111.111.111.111 (eth0 111.111.111.111): S set, 40 headers + 0 d=
ata bytes
> len=3D46 ip=3D111.111.111.111 ttl=3D58 DF id=3D53180 sport=3D80 flags=
=3DSA seq=3D0 win=3D65535 rtt=3D2.9 ms
>=20
> --- 111.111.111.111 hping statistic ---
> 1 packets tramitted, 1 packets received, 0% packet loss
> round-trip min/avg/max =3D 2.9/2.9/2.9 ms
>=20
> 14:01:45.225136 IP oldbox.2776 > 111.111.111.111.80: S 1983626200:198=
3626200(0) win 512
> 14:01:45.225288 IP 111.111.111.111.80 > oldbox.2776: S 3796385036:379=
6385036(0) ack 1983626201 win 65535 <mss 1460>
> 14:01:45.227990 IP oldbox.2776 > 111.111.111.111.80: R 1983626201:198=
3626201(0) win 0
>=20


