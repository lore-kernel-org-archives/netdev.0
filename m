From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 03 Mar 2011 16:39:34 +0100
Message-ID: <1299166774.2983.113.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
	 <1299082728.2920.18.camel@edumazet-laptop>
	 <1299087087.2920.27.camel@edumazet-laptop>
	 <20110303081940.GA29685@gandalf.sssup.it>
	 <1299140868.2456.35.camel@edumazet-laptop>
	 <1299148820.2983.56.camel@edumazet-laptop>
	 <20110303150744.GB29685@gandalf.sssup.it>
	 <1299165940.2983.111.camel@edumazet-laptop>
	 <1299166292.2983.112.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	Paolo Valente <paolo.valente@unimore.it>
To: Fabio Checconi <fchecconi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54585 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758341Ab1CCPjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 10:39:40 -0500
Received: by bwz15 with SMTP id 15so1250102bwz.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 07:39:38 -0800 (PST)
In-Reply-To: <1299166292.2983.112.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 16:31 +0100, Eric Dumazet a =C3=A9crit :
> Le jeudi 03 mars 2011 =C3=A0 16:25 +0100, Eric Dumazet a =C3=A9crit :
>=20
> > qfq_dump_class_stats() probably miss one line :
> >=20
> > scl->bstats.qlen =3D cl->qdisc->q.qlen;
> >=20
> >=20
>=20
> Hmm,=20
>=20
> cl->qdisc->qstats.qlen =3D cl->qdisc->q.qlen;
>=20
> It should be better ;)
>=20
>=20

Indeed, 'packet count' is now correct in qfq classes

# tc -s -d qdisc show dev dummy0
qdisc cbq 1: root refcnt 2 rate 1000Mbit cell 8b (bounded,isolated) pri=
o no-transmit/8 weight 1000Mbit allot 1514b=20
level 2 ewma 5 avpkt 1000b maxidle 0us=20
 Sent 800 bytes 4 pkt (dropped 0, overlimits 83 requeues 0)=20
 backlog 0b 86p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
qdisc qfq 11: parent 1:11=20
 Sent 800 bytes 4 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 360bit 0pps backlog 0b 86p requeues 0=20
qdisc pfifo 8001: parent 11:1 limit 30p
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 2400b 12p requeues 0=20
qdisc pfifo 8002: parent 11:2 limit 30p
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 2000b 10p requeues 0=20
qdisc pfifo 8003: parent 11:3 limit 30p
 Sent 200 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 3400b 17p requeues 0=20
qdisc pfifo 8004: parent 11:4 limit 30p
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 1200b 6p requeues 0=20
qdisc pfifo 8005: parent 11:5 limit 30p
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 2400b 12p requeues 0=20
qdisc pfifo 8006: parent 11:6 limit 30p
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 1400b 7p requeues 0=20
qdisc pfifo 8007: parent 11:7 limit 30p
 Sent 400 bytes 2 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 1400b 7p requeues 0=20
qdisc pfifo 8008: parent 11:8 limit 30p
 Sent 200 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 3000b 15p requeues 0=20


