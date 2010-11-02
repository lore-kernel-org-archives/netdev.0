From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Tue, 02 Nov 2010 10:29:45 +0100
Message-ID: <1288690185.2832.8.camel@edumazet-laptop>
References: <20101101122920.GB10052@verge.net.au>
	 <1288616372.2660.101.camel@edumazet-laptop>
	 <20101102020625.GA22724@verge.net.au>
	 <1288673622.2660.147.camel@edumazet-laptop>
	 <20101102070308.GA19924@verge.net.au>
	 <1288683057.2660.154.camel@edumazet-laptop>
	 <20101102084646.GA23774@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60386 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab0KBJ3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 05:29:50 -0400
Received: by wwe15 with SMTP id 15so7114852wwe.1
        for <netdev@vger.kernel.org>; Tue, 02 Nov 2010 02:29:49 -0700 (PDT)
In-Reply-To: <20101102084646.GA23774@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 02 novembre 2010 =C3=A0 17:46 +0900, Simon Horman a =C3=A9crit=
 :

> Thanks Eric, that seems to resolve the problem that I was seeing.
>=20
> With your patch I see:
>=20
> No bonding
>=20
> # netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to=
 172.17.60.216 (172.17.60.216) port 0 AF_INET
> Socket  Message  Elapsed      Messages                   CPU      Ser=
vice
> Size    Size     Time         Okay Errors   Throughput   Util     Dem=
and
> bytes   bytes    secs            #      #   10^6bits/sec % SU     us/=
KB
>=20
> 116736    1472   30.00     2438413      0      957.2     8.52     1.4=
58=20
> 129024           30.00     2438413             957.2     -1.00    -1.=
000
>=20
> With bonding (one slave, the interface used in the test above)
>=20
> netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
> UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to=
 172.17.60.216 (172.17.60.216) port 0 AF_INET
> Socket  Message  Elapsed      Messages                   CPU      Ser=
vice
> Size    Size     Time         Okay Errors   Throughput   Util     Dem=
and
> bytes   bytes    secs            #      #   10^6bits/sec % SU     us/=
KB
>=20
> 116736    1472   30.00     2438390      0      957.1     8.97     1.5=
35=20
> 129024           30.00     2438390             957.1     -1.00    -1.=
000
>=20


Sure the patch helps when not too many flows are involved, but this is =
a
hack.

Say the device queue is 1000 packets, and you run a workload with 2000
sockets, it wont work...

Or device queue is 1000 packets, one flow, and socket send queue size
allows for more than 1000 packets to be 'in flight' (echo 2000000
>/proc/sys/net/core/wmem_default) , it wont work too with bonding, only
with devices with a qdisc sitting in the first device met after the
socket.



