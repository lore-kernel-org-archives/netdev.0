From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 10:02:33 +0200
Message-ID: <1271318553.16881.2161.camel@edumazet-laptop>
References: <OF19A2A36F.5B268C61-ON65257703.0012EB6A-65257703.0013F81C@in.ibm.com>
	 <1271052111.2078.168.camel@edumazet-laptop>
	 <1271056697.16881.7.camel@edumazet-laptop>
	 <20100414.235256.190096561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:55385 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342Ab0DOICl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:02:41 -0400
Received: by bwz25 with SMTP id 25so1145745bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 01:02:40 -0700 (PDT)
In-Reply-To: <20100414.235256.190096561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 23:52 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 12 Apr 2010 09:18:17 +0200
>=20
> > [PATCH] net: dev_pick_tx() fix
> >=20
> > When dev_pick_tx() caches tx queue_index on a socket, we must check
> > socket dst_entry matches skb one, or risk a crash later, as reporte=
d by
> > Denys Fedorysychenko, if old packets are in flight during a route
> > change, involving devices with different number of queues.
> >=20
> > Bug introduced by commit a4ee3ce3
> > (net: Use sk_tx_queue_mapping for connected sockets)
> >=20
> > Reported-by: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> It looks like Denys is still getting crashes even with this patch
> applied.  And I also think there is some meric to some of Krishna's
> analysis.
>=20


> To me it seems to make more sense to validate the SKB's queue against
> the real actual choosen device's range.
>=20
> The socket queue index will catch up and eventually become valid
> because the dst reset will invalidate the queue setting, and we'll
> thus recompute it as needed, as Krishna stated.
>=20

???=20


> So I'm tossing this patch for now since it doesn't even aparently
> fix the bug.

I am a bit lost here David.

Denys got a crash that we cannot explain yet. He said he has no
multiqueue devices, so obviously my patch cant help him.

But this patch was fixing a real issue, I believe I pointed it twice
already...

I'll try to setup an environment to trigger this bug for real, but this
will take time, my dev machines are not multiqueue.



