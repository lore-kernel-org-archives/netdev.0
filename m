From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 18:06:16 +0100
Message-ID: <1324659976.4540.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324651128.10184.586.camel@denise.theartistscloset.com>
	 <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324654013.10184.597.camel@denise.theartistscloset.com>
	 <1324656963.4540.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324658658.10184.613.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47451 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754384Ab1LWRGU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 12:06:20 -0500
Received: by wgbdr13 with SMTP id dr13so17731320wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 09:06:19 -0800 (PST)
In-Reply-To: <1324658658.10184.613.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 11:44 -0500, John A. Sullivan =
III a
=C3=A9crit :
> On Fri, 2011-12-23 at 17:16 +0100, Eric Dumazet wrote:
> > Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 10:26 -0500, John A. Sulli=
van III a
> > =C3=A9crit :
> >=20
> > > Yes.  This is a problem I have with netem on ingress traffic.  I =
use the
> > > filter on ffff: to redirect to ifb0 for the ingress traffic shapi=
ng.  I
> > > cannot figure out a way to redirect a second time to ifb1 for the=
 netem
> > > qdisc.  I tried putting two action mirred statements in the filte=
r but
> > > that did not work.  Unlike eth1, I cannot attach a filter further=
 down
> > > the ifb0 hfsc hierarchy because one can't redirect one ifb into a=
nother
> > > ifb.  Thus, the only way I could figure out how to do inbound net=
em was
> > > to replace the terminal qdisc with netem rather than SFQ.  I'd lo=
ve to
> > > be able to do that differently.  I tried attaching netem to the S=
=46Q but
> > > that failed (I assume because SFQ is classless) and I tried the o=
ther
> > > way around, attaching SFQ to netem since you mentioned netem coul=
d take
> > > a class but that did not work either.
> >=20
> > Unfortunately, netem wants to control skbs itself, in a fifo queue.
> >=20
> > To implement what you want, we would need to setup a second qdisc,
> > and when packets are dequeued from internal netem fifo, queue them =
in
> > second qdisc.
> >=20
> >=20
> >=20
> I thought I tried to do that but I must have done it incorrectly.  I
> would think something like:
>=20
> tc qdisc add dev eth1 ingress
> tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u32=
 0 0 action mirred egress redirect dev ifb0
> tc qdisc add  dev ifb0 root handle 4 netem delay 25ms 5ms distributio=
n normal loss 0.1% 30%
> tc qdisc add dev ifb0 parent 4:0 handle 1: hfsc default 20
>=20
> but I get:
> root@testswitch01:~# tc qdisc add dev ifb0 parent 4:0 handle 1: hfsc =
default 20
> RTNETLINK answers: Operation not supported
>=20
> What did I do wrong? Thanks - John
>=20

Maybe I was not clear :

netem currently uses a fifo queue, you cant change this, without
patching kernel.
