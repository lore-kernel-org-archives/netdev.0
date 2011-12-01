From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 2/2] netem: add cell concept to simulate
 special MAC behavior
Date: Thu, 01 Dec 2011 10:01:48 +0100
Message-ID: <1322730108.2335.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1322691627-20551-1-git-send-email-hagen@jauu.net>
	 <1322691627-20551-2-git-send-email-hagen@jauu.net>
	 <1322710225.2577.1.camel@edumazet-laptop>
	 <cfd2e2c26063da002d8afe76991ff0c1@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64395 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab1LAJBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:01:53 -0500
Received: by vbbfc26 with SMTP id fc26so1207618vbb.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 01:01:52 -0800 (PST)
In-Reply-To: <cfd2e2c26063da002d8afe76991ff0c1@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 09:25 +0100, Hagen Paul Pfeifer a=
 =C3=A9crit :
> On Thu, 01 Dec 2011 04:30:25 +0100, Eric Dumazet wrote:
>=20
> > Thats a multiply instead of a divide. On many cpus thats a lot fast=
er.
> >
> > Think about a super packet (TSO) of 65000 bytes and cell_size=3D64
>=20
> I've never imagined that I am going to say the following: you are wro=
ng,
> Eric! (ok, maybe you are right ;-)
>=20
> TSO and Netem is a no-go. With netem you are strongly advised to disa=
ble
> offloading. I mean TSO will result in _one_ delay of several minutes,
> followed by a burst of packets. Instead of packets spaced by several
> seconds (with the rate of 1000byte/s) - which is what you wan't.
>=20
> To sum up: skb->len is _never_ larger as the MTU for (normal, correct=
)
> network emulation setups with netem. This was the assumption why I
> preferred the iterative solution over the div/mod solution.
>=20
> Did I miss something?
>=20

Yes :)

I want to be able to use netem on a 10Gigabit link, and simulate a 5ms
delay. I already will hit the shared qdisc bottleneck, dont force me to
use small packets !

We did cleanups in net/sched to properly handle large packets as well.
(SFQ for example is OK)

Really, reciprocal divide is the way to go, its faster anyway on modern
cpus than your loop.
