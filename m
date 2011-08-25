From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] tcp : how many times a frame can possibly be
 retransmitted ?
Date: Thu, 25 Aug 2011 11:40:54 +0200
Message-ID: <1314265254.2387.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314202918.2296.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1108250142030.11551@melkinpaasi.cs.helsinki.fi>
	 <1314226834.6797.5.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1108251150050.12780@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Jerry Chu <hkchu@google.com>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39714 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320Ab1HYJkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 05:40:53 -0400
Received: by wyg24 with SMTP id 24so1508166wyg.19
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 02:40:51 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1108251150050.12780@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 25 ao=C3=BBt 2011 =C3=A0 11:56 +0300, Ilpo J=C3=A4rvinen a =C3=
=A9crit :

> So you think that this is not true: ?
>=20
>         /* NOTE: clamping at TCP_RTO_MIN is not required, current alg=
o
>          * guarantees that rto is higher.
>          */
>=20
> ...it would still be smaller than 1sec though, but certainly not goin=
g to=20
> cause flooding either. Default tcp_rto_min should be 200ms so it's=20
> 5pkts+5ICMP sent, received and processed per second. Which doesn't so=
und=20
> that bad CPU load?!?
>=20

Unless you have 100.000 active sessions maybe ?

Some years ago, I helped people running servers with more than 1.000.00=
0
long living active sessions, and a temporary network disruption was
already very critical at that time, with old kernels (At that time, IP
route cache could blow away and consume too much ram or cpu time, thing=
s
are now under control)

I guess they would not try a new kernel :(

> It is unclear to me how tp->rttvar could become smaller than=20
> tcp_rto_min().

I believe this part is fine Ilpo.

As long as we handle few tcp sessions, its fine to send 5 messages per
session per second.
