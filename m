From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler (v0.4)
Date: Tue, 11 Jan 2011 07:18:35 +0100
Message-ID: <1294726715.4148.8.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
	 <1294248332.10633.25.camel@edumazet-laptop>
	 <20110105112104.64ad3c86@nehalam>
	 <1294286850.2723.65.camel@edumazet-laptop>
	 <20110106205549.0de56de1@nehalam> <1294667210.3491.7.camel@edumazet-laptop>
	 <20110110154414.53f33916@nehalam> <1294704031.4148.2.camel@edumazet-laptop>
	 <20110110171047.0796b6fb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41531 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab1AKGSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 01:18:40 -0500
Received: by wwa36 with SMTP id 36so1416448wwa.1
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 22:18:39 -0800 (PST)
In-Reply-To: <20110110171047.0796b6fb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 janvier 2011 =C3=A0 17:10 -0800, Stephen Hemminger a =C3=A9=
crit :
> OK, put that in.

Thanks !

> >=20
> > Here we missed :
> >=20
> > 		q->tab =3D ntab;
> >=20

We also need to change=20

=2Epeek       =3D   qdisc_peek_head,

to

=2Epeek =3D choke_peek_head,

static struct sk_buff *choke_peek_head(struct Qdisc *sch)
{
	struct choke_sched_data *q =3D qdisc_priv(sch);

	return (q->head !=3D q->tail) ? q->tab[q->head] : NULL;
}



