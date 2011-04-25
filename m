From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Mon, 25 Apr 2011 17:38:35 +0200
Message-ID: <1303745915.2747.151.camel@edumazet-laptop>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	 <1303730701.2747.110.camel@edumazet-laptop>
	 <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56136 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154Ab1DYPio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 11:38:44 -0400
Received: by wya21 with SMTP id 21so1611401wya.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 08:38:43 -0700 (PDT)
In-Reply-To: <BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 avril 2011 =C3=A0 16:35 +0200, Dominik Kaspar a =C3=A9crit =
:
> Hi Eric and Carsten,
>=20
> Thanks a lot for your quick replies. I don't have a tcpdump of this
> experiment, but here is the tcp_probe log that the plot is based on
> (I'll run a new test using tcpdump if you think that's more useful):
>=20
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-00.log
>=20
> I have also noticed what Carsten mentions, the tcp_reordering value i=
s
> essential for this whole behavior. When I start an experiment and
> increase sysctl.net.ipv4.tcp_reordering during the running connection=
,
> the TCP throughput immediately jumps close to the aggregate of both
> paths. Without intervention, as in this experiment, tcp_reordering
> starts out as 3 and then makes small oscillations between 3 and 12 fo=
r
> more than 2 minutes. At about second 141, TCP somehow finds a new
> highest reordering value (23) and at the same time, the throughput
> jumps up "to the next level". The value of 23 is then used all the wa=
y
> until second 603, when the reordering value becomes 32 and the
> throughput again jumps up a level.
>=20
> I understand that tp->reordering is increased when reordering is
> detected, but what causes tp->reordering to sometimes be decreased
> back to 3? Also, why does a decrease back to 3 not make the whole
> procedure start all over again? For example, at second 1013.64,
> tp->reordering falls from 127 down to 3. A second later (1014.93) it
> then suddenly increases from 3 up to 32 without considering any
> numbers in between. Why it is now suddenly so fast? At the very
> beginning, it took 600 seconds to grow from 3 to 32 and afterward it
> just takes a second...?
>=20
> For the experiments, all default TCP options were used, meaning that
> SACK, DSACK, Timestamps, were all enabled. Not sure how to turn on/of=
f
> TSO... so that is probably enabled, too. Path emulation is done with
> tc/netem at the receiver interfaces (eth1, eth2) with this script:
>=20

Since you have at sender a rule to spoof destination address of packets=
,
you should make sure you dont send "super packets (up to 64Kbytes)",
because it would stress the multipath more than you wanted to. This way=
,
you send only normal packets (1500 MTU).

ethtool -K eth0 tso off
ethtool -K eth0 gso off

I am pretty sure it should help your (atypic) workload.

> http://home.simula.no/~kaspar/static/netem.sh
>=20
> Greetings,
> Dominik


