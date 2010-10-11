From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Tue, 12 Oct 2010 01:22:43 +0200
Message-ID: <1286839363.30423.130.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63132 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691Ab0JKXXD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 19:23:03 -0400
Received: by wwj40 with SMTP id 40so4313791wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 16:23:02 -0700 (PDT)
In-Reply-To: <1286838210.30423.128.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 01:03 +0200, Eric Dumazet a =C3=A9crit =
:
> netdev_alloc_skb() is a very wrong interface, really.
>=20
> We should remove/deprecate it.
>=20
> For multi queue devices, it makes more sense to allocate skb on local
> node of the cpu handling RX interrupts. This allow each cpu to
> manipulate its own slub/slab queues/structures without doing expensiv=
e
> cross-node business.
>=20
> For non multi queue devices, IRQ affinity should be set so that a cpu
> close to the device services interrupts. Even if not set, using
> dev_alloc_skb() is faster.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Or maybe revert :

commit b30973f877fea1a3fb84e05599890fcc082a88e5
Author: Christoph Hellwig <hch@lst.de>
Date:   Wed Dec 6 20:32:36 2006 -0800

    [PATCH] node-aware skb allocation
   =20
    Node-aware allocation of skbs for the receive path.
   =20
    Details:
   =20
      - __alloc_skb gets a new node argument and cals the node-aware
        slab functions with it.
      - netdev_alloc_skb passed the node number it gets from dev_to_nod=
e
        to it, everyone else passes -1 (any node)
   =20
    Signed-off-by: Christoph Hellwig <hch@lst.de>
    Cc: Christoph Lameter <clameter@engr.sgi.com>
    Cc: "David S. Miller" <davem@davemloft.net>
    Signed-off-by: Andrew Morton <akpm@osdl.org>


Apparently, only Christoph and Andrew signed it.



