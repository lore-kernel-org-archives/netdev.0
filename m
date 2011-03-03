From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 03 Mar 2011 16:25:40 +0100
Message-ID: <1299165940.2983.111.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
	 <1299082728.2920.18.camel@edumazet-laptop>
	 <1299087087.2920.27.camel@edumazet-laptop>
	 <20110303081940.GA29685@gandalf.sssup.it>
	 <1299140868.2456.35.camel@edumazet-laptop>
	 <1299148820.2983.56.camel@edumazet-laptop>
	 <20110303150744.GB29685@gandalf.sssup.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	Paolo Valente <paolo.valente@unimore.it>
To: Fabio Checconi <fchecconi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:45578 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758254Ab1CCPZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 10:25:46 -0500
Received: by fxm17 with SMTP id 17so1194441fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 07:25:45 -0800 (PST)
In-Reply-To: <20110303150744.GB29685@gandalf.sssup.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 16:07 +0100, Fabio Checconi a =C3=A9crit :

> A question on the data below:
>=20
> > After a stress (and no more trafic) I still have some packets in
> > backlog:
> >=20
> > (8 packets here)
> >=20
> ...
> > class qfq 11:10 root weight 1600 maxpkt 2048=20
> >  Sent 200 bytes 1 pkt (dropped 18181, overlimits 0 requeues 0)=20
> >  rate 0bit 0pps backlog 200b 0p requeues 0=20
>=20
> Any other reason, apart from a bug in QFQ, why there could be 200b an=
d
> 0p of backlog?  A packet count out of sync could explain also why you
> were experiencing problems with pfifo in presence of drops...

My packets are all 200 bytes (from my packet generator)

qfq_dump_class_stats() probably miss one line :

scl->bstats.qlen =3D cl->qdisc->q.qlen;



