From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.4)
Date: Tue, 11 Jan 2011 15:48:06 -0800
Message-ID: <20110111154806.6525e210@s6510>
References: <20110104162930.6fa672e3@nehalam>
	<1294208375.3420.46.camel@edumazet-laptop>
	<20110105091718.02f8a00f@nehalam>
	<1294248332.10633.25.camel@edumazet-laptop>
	<20110105112104.64ad3c86@nehalam>
	<1294286850.2723.65.camel@edumazet-laptop>
	<20110106205549.0de56de1@nehalam>
	<1294667210.3491.7.camel@edumazet-laptop>
	<20110110154414.53f33916@nehalam>
	<1294704031.4148.2.camel@edumazet-laptop>
	<20110110171047.0796b6fb@nehalam>
	<1294726715.4148.8.camel@edumazet-laptop>
	<1294727650.4148.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38346 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199Ab1AKXsK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 18:48:10 -0500
In-Reply-To: <1294727650.4148.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jan 2011 07:34:10 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 11 janvier 2011 =E0 07:18 +0100, Eric Dumazet a =E9crit :
> > Le lundi 10 janvier 2011 =E0 17:10 -0800, Stephen Hemminger a =E9cr=
it :
> > > OK, put that in.
> >=20
> > Thanks !
> >=20
> > > >=20
> > > > Here we missed :
> > > >=20
> > > > 		q->tab =3D ntab;
> > > >=20
> >=20
> > We also need to change=20
> >=20
> > .peek       =3D   qdisc_peek_head,
> >=20
> > to
> >=20
> > .peek =3D choke_peek_head,
> >=20
> > static struct sk_buff *choke_peek_head(struct Qdisc *sch)
> > {
> > 	struct choke_sched_data *q =3D qdisc_priv(sch);
> >=20
> > 	return (q->head !=3D q->tail) ? q->tab[q->head] : NULL;
> > }
> >=20
> >=20
>=20
>=20
> And to correctly work with CBQ (at least...), we need to update=20
> sch->q.qlen =3D choke_len(q) - q->holes;
> in dequeue() and enqueue()
>=20
> Here is the version I successfully tested, with 30000 packets in
> queue :)
>=20
> qdisc choke 11: parent 1:11 limit 70000b min 10000b max 30000b ewma 1=
 Plog 16 Scell_log 11
>  Sent 62099201 bytes 112920 pkt (dropped 367712, overlimits 282668 re=
queues 0)=20
>  rate 21344Kbit 4851pps backlog 39877589b 30001p requeues 0=20
>   marked 0 early 282668 pdrop 0 other 0

Maybe we should take over one of the red counters for the probabilistic=
 match drop.

