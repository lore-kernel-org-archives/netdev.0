From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Sun, 19 Dec 2010 16:43:53 +0100
Message-ID: <1292773433.18869.153.camel@edumazet-laptop>
References: <4D0DEDF9.7020102@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45363 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271Ab0LSPoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Dec 2010 10:44:01 -0500
Received: by wwa36 with SMTP id 36so2198138wwa.1
        for <netdev@vger.kernel.org>; Sun, 19 Dec 2010 07:44:00 -0800 (PST)
In-Reply-To: <4D0DEDF9.7020102@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 19 d=C3=A9cembre 2010 =C3=A0 12:35 +0100, Pawe=C5=82 Stasze=
wski a =C3=A9crit :
> Hi all
>=20
> I have panic with kernel 2.6.37-rc6-git2 when use iproute2=20
> mirred/redirect action
>=20
>=20
> host1 (kernel 2.6.36.2)
> netperf client -> eth3 (82598EB 10-Gigabit AT CX4) - directly connect=
ed=20
> to eth2 of host2
> ethtool -k eth3
> Offload parameters for eth3:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: off
> tx-vlan-offload: off
> ntuple-filters: off
> receive-hashing: off
>=20
> ethtool -i eth3
> driver: ixgbe
> version: 2.0.84-k2
> firmware-version: 1.12-2
> bus-info: 0000:03:00.1
>=20
>=20
> host2 (kernel-2.6.37-rc6-git2)
> netserver -> eth2 (82598EB 10-Gigabit AT CX4) - directly connected to=
=20
> eth3 of host1
>=20
> ethtool -k eth2
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> rx-vlan-offload: on
> tx-vlan-offload: on
> ntuple-filters: off
> receive-hashing: off
>=20
> ethtool -i eth2
> driver: ixgbe
> version: 2.0.84-k2
> firmware-version: 1.12-2
> bus-info: 0000:03:00.0
>=20
>=20
>=20
> Normally without ifb and redirect netperf show:
> TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.0.2=20
> (192.168.0.2) port 0 AF_INET
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>=20
>   87380  16384  16384    10.00    9042.14
>=20
>=20
> Steps to reproduce panic:
> ip link set dev ifb0 up
>=20
> tc qdisc add dev eth2 ingress
>=20
> tc filter add dev eth2 parent ffff: protocol ip prio 10 u32 \
> match ip src 0.0.0.0/0 flowid 1:1 \
> action mirred egress redirect dev ifb0
>=20
>=20
> After this when i start netperf on host1 I have panic (screenshot in=20
> attached image).

Unfortunately, we miss the start of panic messages. Could you try to ge=
t
them ?



