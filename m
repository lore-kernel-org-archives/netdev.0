From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: Introduce skb_orphan_try()
Date: Sun, 18 Apr 2010 02:46:01 -0700 (PDT)
Message-ID: <20100418.024601.85853662.davem@davemloft.net>
References: <1271364375.16881.3099.camel@edumazet-laptop>
	<20100415.143321.200497785.davem@davemloft.net>
	<1271456302.16881.4559.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54082
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755938Ab0DRJp4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Apr 2010 05:45:56 -0400
In-Reply-To: <1271456302.16881.4559.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 17 Apr 2010 00:18:22 +0200

> Le jeudi 15 avril 2010 =E0 14:33 -0700, David Miller a =E9crit :
>=20
>> If it's not legal to skb_orphan() here then it would not be legal fo=
r
>> the drivers to unconditionally skb_orphan(), which they do.
>>=20
>> So either your test is unnecessary, or we have a big existing proble=
m
>> :-)
>=20
> I cooked following patch, introducing skb_orphan_try() helper, to
> document all known exceptions.

Looks good, applied, thanks Eric.

That timestamping issue, I bet there is some simple solution hiding
in the bushes for that one?

Hmmm, something like... there is a less transient piece of state
(perhaps in the socket) and the skb has a pointer to that piece of
state.  Then the driver writes into this pointed-to place rather
into some member of the skb itself.

Then all of these problems with referencing the skb metadata across
being passed to ->ndo_start_xmit() could go away I think.

> I have a possible followup for this patch :
>=20
> Orphaning skbs earlier could also make dev_kfree_skb_irq() faster.
> Instead of queing skb into completion_queue and triggering
> NET_TX_SOFTIRQ, we would directly free an orphaned skb ?

Sounds great.  But I don't see dev_kfree_skb_irq() as much of a
performance priority, since all sane modern drivers free skbs from
softirq context (via NAPI).
