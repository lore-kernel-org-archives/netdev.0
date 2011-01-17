From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: factorize qdisc stats handling
Date: Mon, 17 Jan 2011 23:04:12 +0100
Message-ID: <1295301852.3362.16.camel@edumazet-laptop>
References: <20110106195614.20dbc402@nehalam>
	 <AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>
	 <20110107200234.3f5e7ff8@nehalam>
	 <1294478789.2709.79.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1101172243470.15896@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev <netdev@vger.kernel.org>,
	Luigi Rizzo <rizzo@iet.unipi.it>, hawk@comx.dk
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:36677 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688Ab1AQWET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 17:04:19 -0500
Received: by wwi17 with SMTP id 17so2486718wwi.1
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 14:04:17 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.1101172243470.15896@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 17 janvier 2011 =C3=A0 22:55 +0100, Jesper Dangaard Brouer a =C3=
=A9crit :
>=20
> On Sat, 8 Jan 2011, Eric Dumazet wrote:
> >> Changli Gao <xiaosuo@gmail.com> wrote:
> >>
> >>>> +       cl->bstats.packets +=3D skb_is_gso(skb)?skb_shinfo(skb)-=
>gso_segs:1;
>=20
> What about the qlen when we enqueue a GSO packet? Should we account f=
or=20
> the number of internal GSO packets, or just account a GSO packet as a=
=20
> single packet?
>=20
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 0918834..1a8c0a3 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -453,7 +453,8 @@ static int pfifo_fast_enqueue(struct sk_buff *skb=
,=20
> struct Qdisc* qdisc)
>                  struct sk_buff_head *list =3D band2list(priv, band);
>=20
>                  priv->bitmap |=3D (1 << band);
> -               qdisc->q.qlen++;
> +               /* Should the number of GSO packets be taken into acc=
ount?*/
> +               qdisc->q.qlen +=3D skb_is_gso(skb)?skb_shinfo(skb)->g=
so_segs:1;
>                  return __qdisc_enqueue_tail(skb, qdisc, list);
>          }
>=20
> Is is at all legal to modify the q.qlen this way?

nope ;)

q.qlen is really number of skbs here.



