From: Fabio Checconi <fchecconi@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 3 Mar 2011 16:07:44 +0100
Message-ID: <20110303150744.GB29685@gandalf.sssup.it>
References: <20110228171738.2cc8c9a0@nehalam>
 <20110302020610.GD1005@gandalf.sssup.it>
 <1299064667.2920.4.camel@edumazet-laptop>
 <20110302081108.689571d8@nehalam>
 <1299082728.2920.18.camel@edumazet-laptop>
 <1299087087.2920.27.camel@edumazet-laptop>
 <20110303081940.GA29685@gandalf.sssup.it>
 <1299140868.2456.35.camel@edumazet-laptop>
 <1299148820.2983.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	Paolo Valente <paolo.valente@unimore.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms01.sssup.it ([193.205.80.99]:41895 "EHLO sssup.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751887Ab1CCPGB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 10:06:01 -0500
Content-Disposition: inline
In-Reply-To: <1299148820.2983.56.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, Mar 03, 2011 11:40:20AM +0100
>
> Le jeudi 03 mars 2011 =E0 09:27 +0100, Eric Dumazet a =E9crit :
>=20
> > I am going to test an updated version, thanks for all these hints !
> >=20
>=20
> Same problem in qfq_qlen_notify()
>=20
> Should use :
>=20
> struct qfq_sched *q =3D qdisc_priv(sch);
>=20

Absolutely right, as you're right about qfq_drop().  I'll be able to ta=
ke
a look when I'm back from work this evening.

A question on the data below:

> After a stress (and no more trafic) I still have some packets in
> backlog:
>=20
> (8 packets here)
>=20
=2E..
> class qfq 11:10 root weight 1600 maxpkt 2048=20
>  Sent 200 bytes 1 pkt (dropped 18181, overlimits 0 requeues 0)=20
>  rate 0bit 0pps backlog 200b 0p requeues 0=20

Any other reason, apart from a bug in QFQ, why there could be 200b and
0p of backlog?  A packet count out of sync could explain also why you
were experiencing problems with pfifo in presence of drops...

Thanks for your help, fixes, and testing,
fabio
