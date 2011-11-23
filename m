From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Wed, 23 Nov 2011 06:58:31 +0100
Message-ID: <1322027911.1298.4.camel@edumazet-laptop>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
	 <CABrhC0m75OHmdDD-crr=tvTiRq_hnh7WpHtLjM9TKgTa24MSOA@mail.gmail.com>
	 <1322025880.29324.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Young <jlyo@jlyo.org>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:33841 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381Ab1KWF6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 00:58:36 -0500
Received: by wwo28 with SMTP id 28so459433wwo.1
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 21:58:35 -0800 (PST)
In-Reply-To: <1322025880.29324.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 23 novembre 2011 =C3=A0 06:24 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mardi 22 novembre 2011 =C3=A0 21:06 -0500, John Heffner a =C3=A9cr=
it :
> > Offhand, I'd guess you're overflowing the TCP SYN queue.  (You can =
try
> > tuning tcp_max_syn_backlog.)
> >=20
>=20
> There is one litle thing called "netstat -s", a very useful tool,
> included in many distros :)

This is related to TIMEWAIT syndrom ?

06:47:42.090522 IP6 ::1.49374 > ::1.8009: Flags [SEW], seq 2646115915, =
win 32752, options [mss 16376,sackOK,TS val 26574090 ecr 0,nop,wscale 6=
], length 0
06:47:42.090579 IP6 ::1.8009 > ::1.49374: Flags [S.E], seq 184529170, a=
ck 2646115916, win 32728, options [mss 16376,sackOK,TS val 26574090 ecr=
 26574090,nop,wscale 6], length 0
06:47:42.090616 IP6 ::1.49374 > ::1.8009: Flags [.], ack 1, win 512, op=
tions [nop,nop,TS val 26574090 ecr 26574090], length 0
06:47:42.090718 IP6 ::1.8009 > ::1.49374: Flags [F.], seq 1, ack 1, win=
 512, options [nop,nop,TS val 26574090 ecr 26574090], length 0
06:47:42.090780 IP6 ::1.49374 > ::1.8009: Flags [F.], seq 1, ack 2, win=
 512, options [nop,nop,TS val 26574090 ecr 26574090], length 0
06:47:42.090843 IP6 ::1.8009 > ::1.49374: Flags [.], ack 2, win 512, op=
tions [nop,nop,TS val 26574090 ecr 26574090], length 0

=46irst connection went well.

Now we try to reuse tuple  (ports 49374, 8009 on loopback) while a sock=
et is in TIMEWAIT, and first
SYN packet (time 06:48:20.337335) is dropped (considered as a packet pa=
rt of previous session)

Now why the first SYN packet is dropped and not the second one, I dont =
know yet.

06:48:20.337335 IP6 ::1.49374 > ::1.8009: Flags [SEW], seq 3243722104, =
win 32752, options [mss 16376,sackOK,TS val 26612337 ecr 0,nop,wscale 6=
], length 0
06:48:21.340112 IP6 ::1.49374 > ::1.8009: Flags [SEW], seq 3243722104, =
win 32752, options [mss 16376,sackOK,TS val 26613340 ecr 0,nop,wscale 6=
], length 0
06:48:21.340162 IP6 ::1.8009 > ::1.49374: Flags [S.E], seq 797804014, a=
ck 3243722105, win 32728, options [mss 16376,sackOK,TS val 26613340 ecr=
 26613340,nop,wscale 6], length 0
06:48:21.340217 IP6 ::1.49374 > ::1.8009: Flags [.], ack 1, win 512, op=
tions [nop,nop,TS val 26613340 ecr 26613340], length 0
06:48:21.340360 IP6 ::1.8009 > ::1.49374: Flags [F.], seq 1, ack 1, win=
 512, options [nop,nop,TS val 26613340 ecr 26613340], length 0
06:48:21.340466 IP6 ::1.49374 > ::1.8009: Flags [F.], seq 1, ack 2, win=
 512, options [nop,nop,TS val 26613340 ecr 26613340], length 0
06:48:21.340541 IP6 ::1.8009 > ::1.49374: Flags [.], ack 2, win 512, op=
tions [nop,nop,TS val 26613340 ecr 26613340], length 0
