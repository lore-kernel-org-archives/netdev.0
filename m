From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] mlx4_en: Setting RSS hash result to skb->rxhash field
Date: Wed, 04 May 2011 18:46:26 +0200
Message-ID: <1304527586.32152.5.camel@edumazet-laptop>
References: <4DC156AF.4050807@mellanox.co.il>
	 <1304520260.3203.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63009 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab1EDQqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 12:46:33 -0400
Received: by wwa36 with SMTP id 36so1439613wwa.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2011 09:46:31 -0700 (PDT)
In-Reply-To: <1304520260.3203.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 04 mai 2011 =C3=A0 15:44 +0100, Ben Hutchings a =C3=A9crit =
:
> On Wed, 2011-05-04 at 16:37 +0300, Yevgeny Petrilin wrote:
> > Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> > ---
> >  drivers/net/mlx4/en_rx.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> >=20
> > diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
> > index 62dd21b..bb4d66a 100644
> > --- a/drivers/net/mlx4/en_rx.c
> > +++ b/drivers/net/mlx4/en_rx.c
> > @@ -610,6 +610,8 @@ int mlx4_en_process_rx_cq(struct net_device *de=
v, struct mlx4_en_cq *cq, int bud
> >  					gro_skb->data_len =3D length;
> >  					gro_skb->truesize +=3D length;
> >  					gro_skb->ip_summed =3D CHECKSUM_UNNECESSARY;
> > +					gro_skb->rxhash =3D be32_to_cpu(cqe->immed_rss_invalid) << 24=
;
> > +					skb_record_rx_queue(gro_skb, cq->ring);
>=20
> An 8-bit hash is almost useless.  It's entirely useless if you then
> shift it into the top bits of rxhash.
>=20

Agreed. This is very bad.

Yevgeny probably did this shift because get_rps_cpu()
does :

tcpu =3D map->cpus[((u64) skb->rxhash * map->len) >> 32];

(If rxhash is not a pure random u32 distribution, then high order bits
are more important than low order bits)



