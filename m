From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] sfq: fix slot_dequeue_head()
Date: Thu, 30 Dec 2010 18:49:18 +0100
Message-ID: <20101230174918.GA2018@del.dom.local>
References: <1292998499.4317.13.camel@edumazet-laptop>
 <20101222073211.GA7001@ff.dom.local>
 <1293721368.7150.307.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45973 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865Ab0L3RtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 12:49:25 -0500
Received: by bwz15 with SMTP id 15so11895435bwz.19
        for <netdev@vger.kernel.org>; Thu, 30 Dec 2010 09:49:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1293721368.7150.307.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 30, 2010 at 04:02:48PM +0100, Eric Dumazet wrote:
> Le mercredi 22 d=E9cembre 2010 ?? 07:32 +0000, Jarek Poplawski a =E9c=
rit :
> > > Also, slot_dequeue_tail() should make sure slot skb chain is corr=
ectly
> > > terminated, or sfq_dump_class_stats() can access freed skbs.
> >=20
> > ...and a good hint for code reusing ;-)
>=20
> Yes, and of course same fix is needed in slot_dequeue_head(), as furt=
her
> testing on my side made it pretty clear.
>=20
> I was adding possibility to have more packets queued in SFQ (more
> packets than max number of flows) and got unexpected crashes.
>=20
> Reverting to net-next-2.6, I still got crashes. Oops.
>=20
> [PATCH net-next-2.6] sfq: fix slot_dequeue_head()
>=20
> slot_dequeue_head() should make sure slot skb chain is correct in bot=
h
> ways, or we can crash if all possible flows are in use.

Nice scenario ;-) Of course, it's easy to guess I looked for something
like this after your previous fix and missed that :-| Btw, it looks
like slot_queue_init() could go back to sfq_init() now.

Jarek P.

>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jarek Poplawski <jarkao2@gmail.com>
> ---
>  net/sched/sch_sfq.c |    1 +
>  1 files changed, 1 insertion(+)
>=20
> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 6a2f88f..3977e56 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -292,6 +292,7 @@ static inline struct sk_buff *slot_dequeue_head(s=
truct sfq_slot *slot)
>  	struct sk_buff *skb =3D slot->skblist_next;
> =20
>  	slot->skblist_next =3D skb->next;
> +	skb->next->prev =3D (struct sk_buff *)slot;
>  	skb->next =3D skb->prev =3D NULL;
>  	return skb;
>  }
>=20
>=20
