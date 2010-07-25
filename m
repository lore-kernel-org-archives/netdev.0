From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] pktgen: Optionally leak kernel memory
Date: Sun, 25 Jul 2010 10:27:52 +0200
Message-ID: <1280046472.2451.494.camel@edumazet-laptop>
References: <1279949024.2451.43.camel@edumazet-laptop>
	 <4C4AE80F.1040406@candelatech.com>
	 <1279980795.2451.157.camel@edumazet-laptop>
	 <20100724.213519.260107516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56004 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab0GYI14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jul 2010 04:27:56 -0400
Received: by wwj40 with SMTP id 40so5957424wwj.1
        for <netdev@vger.kernel.org>; Sun, 25 Jul 2010 01:27:55 -0700 (PDT)
In-Reply-To: <20100724.213519.260107516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 24 juillet 2010 =C3=A0 21:35 -0700, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sat, 24 Jul 2010 16:13:15 +0200
>=20
> > I am not sure David will accept the patch !
>=20
> I don't think I can apply this, sorry :-)

Absolutely.

It might be possible for pktgen to use a pool of prebuilt pages to avoi=
d
the cost of clearing pages. This wont work for skb without frags, unles=
s
we change skb_release_data() (it calls kfree(skb->head), I dont think w=
e
can trap this one...)

One better idea would be to take an extra reference on skb before givin=
g
it to transmit, and maintain a list of skbs to recycle once their
refcount hits 1 (our reference). We could avoid most of the skb
setup/freeing costs (no more memory allocations/freeing)

I'll take a look after my vacations, unless someone motivated enough
beats me of course :)

Thanks !


