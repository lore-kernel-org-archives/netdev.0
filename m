From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] net_sched: sch_sfq: better struct layouts
Date: Mon, 20 Dec 2010 23:55:40 +0100
Message-ID: <20101220225540.GA2052@del.dom.local>
References: <4D08E6C2.804@trash.net>
 <1292430424.3427.350.camel@edumazet-laptop>
 <1292431256.3427.358.camel@edumazet-laptop>
 <4D08F025.5030603@trash.net>
 <1292432120.3427.366.camel@edumazet-laptop>
 <4D08F4F4.3050501@trash.net>
 <1292504932.2883.110.camel@edumazet-laptop>
 <1292604766.2906.51.camel@edumazet-laptop>
 <20101219212234.GA2323@del.dom.local>
 <1292864525.2800.189.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:35985 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757660Ab0LTWzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 17:55:46 -0500
Received: by bwz16 with SMTP id 16so3903149bwz.4
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 14:55:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292864525.2800.189.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 20, 2010 at 06:02:05PM +0100, Eric Dumazet wrote:
> Le dimanche 19 d=E9cembre 2010 ?? 22:22 +0100, Jarek Poplawski a =E9c=
rit :
>=20
> > I think open coding sk_buff_head is a wrong idea. Otherwise, this
> > patch looks OK to me, only a few cosmetic suggestions below.
> >=20
>=20
> I completely agree with you but this should be temporary, because Dav=
id
> really wants to use list_head for skbs, I believe this will be done ;=
)
>=20
> I chose to name the list skblist to make clear where we want to plug =
a
> real list_head once done.
>=20
> Also, not using sk_buff_head saves at least 8 bytes per slot.

Alas I dumped my 486sx already :-/

> > > -	sfq_index	max_depth;	/* Maximal depth */
> > > +	sfq_index	max_depth;	/* depth of longest slot */
> >=20
> > depth and/or length? (One dimension should be enough.)
>=20
> maybe cur_depth ? Its not the maximal possible depth, but depth of
> longest slot, or current max depth...

Hmm... or max_depth? I meant the comment only, sorry ;-)

> > > -	/* If selected queue has length q->limit, this means that
> > > -	 * all another queues are empty and that we do simple tail drop=
,
> >=20
> > No reason to remove this line.
>=20
> Well, the reason we drop this packet is not because other queues are
> empty, but because we reach max depth for this queue. (I have the ide=
a
> to extend SFQ to allow more packets to be queued, still with a 127 li=
mit
> per queue, and 127 flows). With 10Gbs links, a global limit of 127
> packets is short.

Right, but does this line say something else? Of course, you can find
it out by yourself too, but this comment makes reading a bit faster.

> > If you really have to do this, all these: __skb_queue_tail(),
> > __skb_dequeue(), skb_queue_head_init(), skb_peek() etc. used here
> > should stay as (local) inline functions to remain readability.
> >=20
>=20
> OK done, thanks a lot for reviewing and very useful comments !

Thanks for using them!
Jarek P.
