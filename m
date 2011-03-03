From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Thu, 03 Mar 2011 11:40:20 +0100
Message-ID: <1299148820.2983.56.camel@edumazet-laptop>
References: <20110228171738.2cc8c9a0@nehalam>
	 <20110302020610.GD1005@gandalf.sssup.it>
	 <1299064667.2920.4.camel@edumazet-laptop> <20110302081108.689571d8@nehalam>
	 <1299082728.2920.18.camel@edumazet-laptop>
	 <1299087087.2920.27.camel@edumazet-laptop>
	 <20110303081940.GA29685@gandalf.sssup.it>
	 <1299140868.2456.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org,
	Paolo Valente <paolo.valente@unimore.it>
To: Fabio Checconi <fchecconi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48429 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752704Ab1CCKk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 05:40:26 -0500
Received: by fxm17 with SMTP id 17so943677fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 02:40:24 -0800 (PST)
In-Reply-To: <1299140868.2456.35.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 09:27 +0100, Eric Dumazet a =C3=A9crit :

> I am going to test an updated version, thanks for all these hints !
>=20

Same problem in qfq_qlen_notify()

Should use :

struct qfq_sched *q =3D qdisc_priv(sch);


After a stress (and no more trafic) I still have some packets in
backlog:

(8 packets here)

# tc -s -d qdisc show dev dummy0
qdisc cbq 1: root refcnt 2 rate 1000Mbit cell 8b (bounded,isolated) pri=
o no-transmit/8 weight 1000Mbit allot 1514b=20
level 2 ewma 5 avpkt 1000b maxidle 0us=20
 Sent 109916000 bytes 549580 pkt (dropped 350412, overlimits 1180608 re=
queues 0)=20
 backlog 0b 8p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
qdisc qfq 11: parent 1:11=20
 Sent 109916000 bytes 549580 pkt (dropped 350412, overlimits 0 requeues=
 0)=20
 rate 2848bit 2pps backlog 0b 8p requeues 0=20
# tc -s -d class show dev dummy0
class cbq 1:11 parent 1:1 leaf 11: rate 40000Kbit cell 128b mpu 64b (bo=
unded) prio 2/2 weight 40000Kbit allot 20000b=20
level 0 ewma 5 avpkt 1400b maxidle 0us=20
 Sent 109916000 bytes 549580 pkt (dropped 350412, overlimits 675712 req=
ueues 0)=20
 rate 1516Kbit 947pps backlog 0b 8p requeues 0=20
  borrowed 0 overactions 285254 avgidle -22 undertime -24
class cbq 1: root rate 1000Mbit cell 8b (bounded,isolated) prio no-tran=
smit/8 weight 1000Mbit allot 1514b=20
level 2 ewma 5 avpkt 1000b maxidle 0us=20
 Sent 109916000 bytes 549580 pkt (dropped 0, overlimits 0 requeues 0)=20
 backlog 0b 0p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
class cbq 1:1 parent 1: rate 1000Mbit cell 64b mpu 64b (bounded) prio 1=
/1 weight 1000Mbit allot 10000b=20
level 1 ewma 5 avpkt 1500b maxidle 0us=20
 Sent 109916000 bytes 549580 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 1516Kbit 947pps backlog 0b 0p requeues 0=20
  borrowed 0 overactions 0 avgidle 125 undertime 0
class qfq 11:10 root weight 1600 maxpkt 2048=20
 Sent 200 bytes 1 pkt (dropped 18181, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:1 root weight 100 maxpkt 1100=20
 Sent 2731200 bytes 13656 pkt (dropped 40889, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:2 root weight 200 maxpkt 1200=20
 Sent 10899800 bytes 54499 pkt (dropped 47, overlimits 0 requeues 0)=20
 rate 24bit 0pps backlog 0b 0p requeues 0=20
class qfq 11:3 root weight 300 maxpkt 1300=20
 Sent 12714400 bytes 63572 pkt (dropped 65, overlimits 0 requeues 0)=20
 rate 32bit 0pps backlog 0b 0p requeues 0=20
class qfq 11:4 root weight 400 maxpkt 1400=20
 Sent 400 bytes 2 pkt (dropped 36362, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:5 root weight 500 maxpkt 1500=20
 Sent 400 bytes 2 pkt (dropped 45452, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:6 root weight 600 maxpkt 1600=20
 Sent 800 bytes 4 pkt (dropped 27269, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:7 root weight 700 maxpkt 1700=20
 Sent 600 bytes 3 pkt (dropped 45452, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:8 root weight 800 maxpkt 1800=20
 Sent 1000 bytes 5 pkt (dropped 72722, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:9 root weight 900 maxpkt 1900=20
 Sent 1200 bytes 6 pkt (dropped 63631, overlimits 0 requeues 0)=20
 rate 0bit 0pps backlog 200b 0p requeues 0=20
class qfq 11:a root weight 1000 maxpkt 2000=20
 Sent 14535200 bytes 72676 pkt (dropped 51, overlimits 0 requeues 0)=20
 rate 32bit 0pps backlog 0b 0p requeues 0=20
class qfq 11:b root weight 1100 maxpkt 2048=20
 Sent 14531200 bytes 72656 pkt (dropped 72, overlimits 0 requeues 0)=20
 rate 32bit 0pps backlog 0b 0p requeues 0=20
class qfq 11:c root weight 1200 maxpkt 2048=20
 Sent 10905800 bytes 54529 pkt (dropped 16, overlimits 0 requeues 0)=20
 rate 24bit 0pps backlog 0b 0p requeues 0=20
class qfq 11:d root weight 1300 maxpkt 2048=20
 Sent 14538200 bytes 72691 pkt (dropped 36, overlimits 0 requeues 0)=20
 rate 32bit 0pps backlog 0b 0p requeues 0=20
class qfq 11:e root weight 1400 maxpkt 2048=20
 Sent 18162200 bytes 90811 pkt (dropped 96, overlimits 0 requeues 0)=20
 rate 40bit 0pps backlog 0b 0p requeues 0=20
class qfq 11:f root weight 1500 maxpkt 2048=20
 Sent 10895000 bytes 54475 pkt (dropped 71, overlimits 0 requeues 0)=20
 rate 24bit 0pps backlog 0b 0p requeues 0=20




