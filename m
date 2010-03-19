From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen node allocation
Date: Fri, 19 Mar 2010 10:28:53 +0100
Message-ID: <1268990933.3048.15.camel@edumazet-laptop>
References: <19363.14702.909265.380669@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robert Olsson <robert@herjulf.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:62664 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab0CSJ25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 05:28:57 -0400
Received: by bwz1 with SMTP id 1so2780246bwz.21
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 02:28:55 -0700 (PDT)
In-Reply-To: <19363.14702.909265.380669@gargle.gargle.HOWL>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 mars 2010 =C3=A0 09:44 +0100, Robert Olsson a =C3=A9crit=
 :
>=20
> Hi,
> Here is patch to manipulate packet node allocation and implicitly=20
> how packets are DMA'd etc.
>=20
> The flag NODE_ALLOC enables the function and numa_node_id();
> when enabled it can also be explicitly controlled via a new=20
> node parameter
>=20
> Tested this with 10 Intel 82599 ports w. TYAN S7025 E5520 CPU's.
> Was able to TX/DMA ~80 Gbit/s to Ethernet wires.
>=20
> Cheers
> 					--ro
>=20

I cannot understand how this can help.

__netdev_alloc_skb() is supposed to already take into account NUMA
properties :

int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;

If this doesnt work, we should correct core stack, not only pktgen :)

Are you allocating memory in the node where pktgen CPU is running or th=
e
node close to the NIC ?


Thanks


