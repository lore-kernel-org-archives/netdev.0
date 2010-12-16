From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net_sched: sch_sfq: add backlog info in
	sfq_dump_class_stats()
Date: Thu, 16 Dec 2010 13:09:34 +0000
Message-ID: <20101216130934.GA7766@ff.dom.local>
References: <20101216081621.GA7338@ff.dom.local> <1292497384.2883.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f45.google.com ([209.85.214.45]:45572 "EHLO
	mail-bw0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606Ab0LPNJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 08:09:38 -0500
Received: by bwz16 with SMTP id 16so3535328bwz.4
        for <netdev@vger.kernel.org>; Thu, 16 Dec 2010 05:09:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1292497384.2883.89.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 12:03:04PM +0100, Eric Dumazet wrote:
> Le jeudi 16 d=E9cembre 2010 ?? 08:16 +0000, Jarek Poplawski a =E9crit=
 :
> > On 2010-12-15 19:18, Eric Dumazet wrote:
> > > We currently return for each active SFQ slot the number of packet=
s in
> > > queue. We can also give number of bytes accounted for these packe=
ts.
=2E..
> > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > ---
> > >  net/sched/sch_sfq.c |    7 ++++++-
> > >  1 file changed, 6 insertions(+), 1 deletion(-)
> > >=20
> > > diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> > > index 3cf478d..cb331de 100644
> > > --- a/net/sched/sch_sfq.c
> > > +++ b/net/sched/sch_sfq.c
> > > @@ -548,8 +548,13 @@ static int sfq_dump_class_stats(struct Qdisc=
 *sch, unsigned long cl,
> > >  {
> > >  	struct sfq_sched_data *q =3D qdisc_priv(sch);
> > >  	sfq_index idx =3D q->ht[cl-1];
> > > -	struct gnet_stats_queue qs =3D { .qlen =3D q->qs[idx].qlen };
> > > +	struct sk_buff_head *list =3D &q->qs[idx];
> > > +	struct gnet_stats_queue qs =3D { .qlen =3D list->qlen };
> > >  	struct tc_sfq_xstats xstats =3D { .allot =3D q->allot[idx] };
> > > +	struct sk_buff *skb;
> > > +
> > > +	skb_queue_walk(list, skb)
> > > +		qs.backlog +=3D qdisc_pkt_len(skb);
> >=20
> > I don't think you can walk this list without the qdisc lock.
>=20
> So after checks, I confirm qdisc lock is held at this point, patch is
> valid.
>=20
> tc_fill_tclass() calls gnet_stats_start_copy_compat() (and locks
> qdisc_root_sleeping_lock()), before calling=20
>  cl_ops->dump_stats(q, cl, &d)
>=20
> Thanks !

You are right. Sorry for misleading.

Jarek P.
