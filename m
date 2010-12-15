From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 18:03:48 +0100
Message-ID: <4D08F4F4.3050501@trash.net>
References: <1292421783.3427.232.camel@edumazet-laptop>	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net> <1292432120.3427.366.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55164 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461Ab0LORDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 12:03:53 -0500
In-Reply-To: <1292432120.3427.366.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.12.2010 17:55, Eric Dumazet wrote:
> Le mercredi 15 d=E9cembre 2010 =E0 17:43 +0100, Patrick McHardy a =E9=
crit :
>=20
>> Now we could remove the allot increase in sfq_dequeue for
>> the case that the flow becomes inactive. It is incorrect
>> anyways.
>=20
> Hmm, we increase the allot for the next slot, not for the slot now
> empty.
>=20
>=20
>         /* Is the slot empty? */
>         if (q->qs[a].qlen =3D=3D 0) {
>                 q->ht[q->hash[a]] =3D SFQ_DEPTH;
>                 a =3D q->next[a]; // a =3D next slot index
>                 if (a =3D=3D old_a) {
>                         q->tail =3D SFQ_DEPTH;
>                         return skb;
>                 }
>                 q->next[q->tail] =3D a;
>                 q->allot[a] +=3D q->quantum;
> // HERE, q->allot[a] is for next slot, we give it its quantum for bei=
ng
> activated

Right, that's odd. It shouldn't be necessary anymore though since
now we initialize allot in sfq_enqueue() for all new flows and
increase allotment for all active flows once per round in sfq_dequeue()=
=2E
The above code causes a second increase for the flow following a flow
which went inactive.

>=20
>         } else if ((q->allot[a] -=3D qdisc_pkt_len(skb)) <=3D 0) {
>=20
> Maybe we should rename (a / old_a) by (a / next_a) to avoid confusion=
 :)

That might have made things more clearer :)

> I was thinking in allowing more packets per SFQ (but keep the 126 act=
ive
> flows limit), what do you think ?

I keep forgetting why this limit exists, let me try to figure
it out once more :)
