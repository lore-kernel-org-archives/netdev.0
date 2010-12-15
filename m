From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 17:55:20 +0100
Message-ID: <1292432120.3427.366.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>
	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45581 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab0LOQz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 11:55:26 -0500
Received: by wyb28 with SMTP id 28so1653544wyb.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 08:55:25 -0800 (PST)
In-Reply-To: <4D08F025.5030603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 d=C3=A9cembre 2010 =C3=A0 17:43 +0100, Patrick McHardy a=
 =C3=A9crit :

> Now we could remove the allot increase in sfq_dequeue for
> the case that the flow becomes inactive. It is incorrect
> anyways.

Hmm, we increase the allot for the next slot, not for the slot now
empty.


        /* Is the slot empty? */
        if (q->qs[a].qlen =3D=3D 0) {
                q->ht[q->hash[a]] =3D SFQ_DEPTH;
                a =3D q->next[a]; // a =3D next slot index
                if (a =3D=3D old_a) {
                        q->tail =3D SFQ_DEPTH;
                        return skb;
                }
                q->next[q->tail] =3D a;
                q->allot[a] +=3D q->quantum;
// HERE, q->allot[a] is for next slot, we give it its quantum for being
activated

        } else if ((q->allot[a] -=3D qdisc_pkt_len(skb)) <=3D 0) {

Maybe we should rename (a / old_a) by (a / next_a) to avoid confusion :=
)

I was thinking in allowing more packets per SFQ (but keep the 126 activ=
e
flows limit), what do you think ?



