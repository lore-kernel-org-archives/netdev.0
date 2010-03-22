From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen node allocation
Date: Mon, 22 Mar 2010 08:43:14 +0100
Message-ID: <1269243794.3029.0.camel@edumazet-laptop>
References: <19363.14702.909265.380669@gargle.gargle.HOWL>
	 <1268990933.3048.15.camel@edumazet-laptop>
	 <19363.32154.39665.185451@gargle.gargle.HOWL>
	 <1269006465.3048.39.camel@edumazet-laptop>
	 <19367.3346.643084.604021@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	olofh@kth.se
To: Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:33256 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab0CVHnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 03:43:18 -0400
Received: by bwz3 with SMTP id 3so5091016bwz.29
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 00:43:16 -0700 (PDT)
In-Reply-To: <19367.3346.643084.604021@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 mars 2010 =C3=A0 07:24 +0100, Robert Olsson a =C3=A9crit :
> Eric Dumazet writes:
>=20
>  > Well, you said "Tested this with 10 Intel 82599 ports w. TYAN S702=
5
>  > E5520 CPU's. Was able to TX/DMA ~80 Gbit/s to Ethernet wires."
>  >=20
>  > I am interested to know what particular setup you did to maximize
>  > throughput then, or are you saing you managed to reduce it ? :)
>=20
>=20
> Some notes from the experiment, It's getting
> complex and hairy. Anyway results from the first
> tests to give you an idea... My colleague Olof=20
> might have some comments/details
>=20
> pktgen sending on 10 * 10g interfaces.=20
>=20
> [From pktgen script]
> fn()
> {
>   i=3D$1  #ifname
>   c=3D$2  #queue / cpu core
>   n=3D$3  # numa node
>   PGDEV=3D/proc/net/pktgen/kpktgend_$c
>   pgset "add_device eth$i@$c  "
>   PGDEV=3D/proc/net/pktgen/eth$i@$c
>   pgset "node $n"
>   pgset "$COUNT"
>   pgset "flag NODE_ALLOC"
>   pgset "$CLONE_SKB"
>   pgset "$PKT_SIZE"
>   pgset "$DELAY"
>   pgset "dst 10.0.0.0"=20
> }     =20
>=20
> remove_all
> # Setup
>=20
> # TYAN S7025 with two nodes.
> # Each node has own bus with it's own TYLERSBURG bridge
> # so eth0-eth3 is closest to node0 which in turn "owns"
> # CPU-cores 0-3 in this HW setup. So we setup so=20
> # pktgen according to this. clone_skb=3D1000000.
> # Used slots are PCIe-x16 except when PCIe-x8 is indicated.
>=20
> # eth0 queue=3D0(CPU) node=3D0
> fn 0 0 0
> fn 1 1 0
> fn 2 2 0
> fn 3 3 0
> fn 4 4 1
> fn 5 5 1
> fn 6 6 1
> fn 7 7 1
> fn 8 12 1
> fn 9 13 1
>=20
> Result "manually" tuned.=20
>=20
> eth0 9617.7 M bit/s      822 k pps=20
> eth1 9619.1 M bit/s      823 k pps=20
> eth2 9619.1 M bit/s      823 k pps=20
> eth3 9619.2 M bit/s      823 k pps=20
> eth4 5995.2 M bit/s      512 k pps  <-  PCIe-x8
> eth5 5995.3 M bit/s      512 k pps  <-  PCIe-x8
> eth6 9619.2 M bit/s      823 k pps=20
> eth7 9619.2 M bit/s      823 k pps=20
> eth8 9619.1 M bit/s      823 k pps=20
> eth9 9619.0 M bit/s      823 k pps=20
>=20
> > 90 Gbit/s
>=20
> Result "manually" mistuned by switching node 0 and 1.=20
>=20
> eth0 9613.6 M bit/s      822 k pps=20
> eth1 9614.9 M bit/s      822 k pps=20
> eth2 9615.0 M bit/s      822 k pps=20
> eth3 9615.1 M bit/s      822 k pps=20
> eth4 2918.5 M bit/s      249 k pps  <-  PCIe-x8
> eth5 2918.4 M bit/s      249 k pps  <-  PCIe-x8
> eth6 8597.0 M bit/s      735 k pps=20
> eth7 8597.0 M bit/s      735 k pps=20
> eth8 8568.3 M bit/s      733 k pps=20
> eth9 8568.3 M bit/s      733 k pps=20
>=20
> A lot things is to be investgated...

Sure :)

I wonder why eth0-eth3 results are unchanged after a node flip.

Thanks for sharing


