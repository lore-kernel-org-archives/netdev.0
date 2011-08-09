From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: prio: use qdisc_dequeue_peeked
Date: Tue, 09 Aug 2011 14:56:25 +0200
Message-ID: <1312894585.2371.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1312891483-30034-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:35207 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711Ab1HIM41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 08:56:27 -0400
Received: by wwf5 with SMTP id 5so2605114wwf.1
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2011 05:56:26 -0700 (PDT)
In-Reply-To: <1312891483-30034-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 ao=C3=BBt 2011 =C3=A0 14:04 +0200, Florian Westphal a =C3=A9=
crit :
> commit 07bd8df5df4369487812bf85a237322ff3569b77
> (sch_sfq: fix peek() implementation) changed sfq to use generic
> peek helper.
>=20
> This makes HFSC complain about a non-work-conserving child qdisc, if
> prio with sfq child is used within hfsc:
>=20
> hfsc peeks into prio qdisc, which will then peek into sfq.
> returned skb is stashed in sch->gso_skb.
>=20
> Next, hfsc tries to dequeue from prio, but prio will call sfq dequeue
> directly, which may return NULL instead of previously peeked-at skb.
>=20
> Have prio call qdisc_dequeue_peeked, so sfq->dequeue() is
> not called in this case.
>=20
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  Eric, does this look correct to you?
>  I am not sure if sfq needs fixing instead of this patch here.
>=20
> diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> index 2a318f2..b5d56a2 100644
> --- a/net/sched/sch_prio.c
> +++ b/net/sched/sch_prio.c
> @@ -112,7 +112,7 @@ static struct sk_buff *prio_dequeue(struct Qdisc =
*sch)
> =20
>  	for (prio =3D 0; prio < q->bands; prio++) {
>  		struct Qdisc *qdisc =3D q->queues[prio];
> -		struct sk_buff *skb =3D qdisc->dequeue(qdisc);
> +		struct sk_buff *skb =3D qdisc_dequeue_peeked(qdisc);
>  		if (skb) {
>  			qdisc_bstats_update(sch, skb);
>  			sch->q.qlen--;


Hi Florian

Are you sure this patch is still needed, after commit=20
e1738bd9cecc5c867b0e2996470c1ff20f66ba79
(sch_sfq: fix sfq_enqueue())

I am asking before fully reviewing the code, I dont know who
should/shouldnt call qdisc_dequeue_peeked() instead of qdisc->dequeue()

Thanks !






