From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Tue, 12 Oct 2010 07:16:00 +0200
Message-ID: <1286860560.30423.186.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
	 <1286839363.30423.130.camel@edumazet-laptop>
	 <AANLkTi=NvnPov_=KQJz2uXt1R-ep4oahDF0J=3HwhGzG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54573 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab0JLFQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 01:16:22 -0400
Received: by wye20 with SMTP id 20so1066761wye.19
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:16:20 -0700 (PDT)
In-Reply-To: <AANLkTi=NvnPov_=KQJz2uXt1R-ep4oahDF0J=3HwhGzG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 octobre 2010 =C3=A0 22:03 -0700, Tom Herbert a =C3=A9crit :
> On Mon, Oct 11, 2010 at 4:22 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mardi 12 octobre 2010 =C3=A0 01:03 +0200, Eric Dumazet a =C3=A9c=
rit :
> >> netdev_alloc_skb() is a very wrong interface, really.
> >>
> >> We should remove/deprecate it.
> >>
> >> For multi queue devices, it makes more sense to allocate skb on lo=
cal
> >> node of the cpu handling RX interrupts. This allow each cpu to
> >> manipulate its own slub/slab queues/structures without doing expen=
sive
> >> cross-node business.
> >>
> >> For non multi queue devices, IRQ affinity should be set so that a =
cpu
> >> close to the device services interrupts. Even if not set, using
> >> dev_alloc_skb() is faster.
> >>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >
> > Or maybe revert :
> >
> > commit b30973f877fea1a3fb84e05599890fcc082a88e5
> > Author: Christoph Hellwig <hch@lst.de>
> > Date:   Wed Dec 6 20:32:36 2006 -0800
> >
>=20
> I second this revert.  Node aware allocation by device's node makes
> little sense on a multi-queue device and leads to mediocre
> performance.

Yes, I said this several time in the past, I believe time has come to
get rid of it.

I posted a patch some minutes ago, so you can review it and ack it ;)

Thanks !


