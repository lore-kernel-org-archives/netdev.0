From: Simon Horman <simon@horms.net>
Subject: Re: bonding: flow control regression [was Re: bridging: flow
 control regression]
Date: Sat, 6 Nov 2010 18:25:37 +0900
Message-ID: <20101106092535.GD5128@verge.net.au>
References: <20101101122920.GB10052@verge.net.au>
 <1288616372.2660.101.camel@edumazet-laptop>
 <20101102020625.GA22724@verge.net.au>
 <1288673622.2660.147.camel@edumazet-laptop>
 <20101102070308.GA19924@verge.net.au>
 <1288683057.2660.154.camel@edumazet-laptop>
 <20101102084646.GA23774@verge.net.au>
 <1288690185.2832.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:47088 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574Ab0KFJZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 05:25:57 -0400
Content-Disposition: inline
In-Reply-To: <1288690185.2832.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 02, 2010 at 10:29:45AM +0100, Eric Dumazet wrote:
> Le mardi 02 novembre 2010 =C3=A0 17:46 +0900, Simon Horman a =C3=A9cr=
it :
>=20
> > Thanks Eric, that seems to resolve the problem that I was seeing.
> >=20
> > With your patch I see:
> >=20
> > No bonding
> >=20
> > # netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
> > UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET =
to 172.17.60.216 (172.17.60.216) port 0 AF_INET
> > Socket  Message  Elapsed      Messages                   CPU      S=
ervice
> > Size    Size     Time         Okay Errors   Throughput   Util     D=
emand
> > bytes   bytes    secs            #      #   10^6bits/sec % SU     u=
s/KB
> >=20
> > 116736    1472   30.00     2438413      0      957.2     8.52     1=
=2E458=20
> > 129024           30.00     2438413             957.2     -1.00    -=
1.000
> >=20
> > With bonding (one slave, the interface used in the test above)
> >=20
> > netperf -c -4 -t UDP_STREAM -H 172.17.60.216 -l 30 -- -m 1472
> > UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET =
to 172.17.60.216 (172.17.60.216) port 0 AF_INET
> > Socket  Message  Elapsed      Messages                   CPU      S=
ervice
> > Size    Size     Time         Okay Errors   Throughput   Util     D=
emand
> > bytes   bytes    secs            #      #   10^6bits/sec % SU     u=
s/KB
> >=20
> > 116736    1472   30.00     2438390      0      957.1     8.97     1=
=2E535=20
> > 129024           30.00     2438390             957.1     -1.00    -=
1.000
> >=20
>=20
>=20
> Sure the patch helps when not too many flows are involved, but this i=
s a
> hack.
>=20
> Say the device queue is 1000 packets, and you run a workload with 200=
0
> sockets, it wont work...
>=20
> Or device queue is 1000 packets, one flow, and socket send queue size
> allows for more than 1000 packets to be 'in flight' (echo 2000000
> >/proc/sys/net/core/wmem_default) , it wont work too with bonding, on=
ly
> with devices with a qdisc sitting in the first device met after the
> socket.

True, thanks for pointing that out.

The scenario that I am actually interested in is virtualisation.
And I believe that your patch helps the vhostnet case (I don't see
flow control problems with bonding + virtio without vhostnet). However,
I am unsure if there are also some easy work-arounds to degrade
flow control in the vhostnet case too.

