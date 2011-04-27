From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 18:48:47 +0200
Message-ID: <1303922928.3166.96.camel@edumazet-laptop>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	 <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
	 <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
	 <201104271157.49386.carsten@wolffcarsten.de>
	 <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>, netdev@vger.kernel.org,
	Zimmermann Alexander <zimmermann@nets.rwth-aachen.de>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:56028 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab1D0Qsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 12:48:53 -0400
Received: by wwa36 with SMTP id 36so2107896wwa.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 09:48:51 -0700 (PDT)
In-Reply-To: <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 avril 2011 =C3=A0 18:22 +0200, Dominik Kaspar a =C3=A9cr=
it :
> Hi Carsten,
>=20
> Thanks for your feedback. I made some new tests with the same setup o=
f
> packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
> (400 KB/s, 100 ms). In the first experiments, which showed a step-wis=
e
> adaptation to reordering, SACK, DSACK, and Timestamps were all
> enabled. In the experiments, I individually disabled these three
> mechanisms and saw the following:
>=20
> - Disabling timestamps causes TCP to never adjust to reordering at al=
l.
> - Disabling SACK allows TCP to adapt very rapidly ("perfect" aggregat=
ion!).
> - Disabling DSACK has no obvious impact (still a step-wise throughput=
).
>=20
> Is there an explanation for why turning off SACK can be beneficial in
> the presence of packet reordering? That sounds pretty
> counter-intuitive to me... I thought SACK=3D1 always performs better
> than SACK=3D0. The results are also illustrated in the following plot=
=2E
> For each setting, there are three runs, which all exhibit a similar
> behavior:
>=20
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-02-sack.png
>=20

SACK is a win in a normal environnement, with few reorders, but some
percents of losses ;)

Given the limit of 3 blocks in SACK option, and your pretty asymetric
paths (10ms and 100ms), SACK is useless and consume 12 bytes per
frame...

You really should add traces to every tp->reordering changes done in ou=
r
TCP stack, its a 20 minutes patch, and would help you to understand
where/when its increased/decreased.




