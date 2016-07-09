From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: make challenge acks less predictable
Date: Sat, 09 Jul 2016 10:16:00 +0200
Message-ID: <1468052160.30694.51.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467995586.30694.34.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zhiyun Qian <zhiyunq@cs.ucr.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Yuchung Cheng <ycheng@google.com>
To: Yue Cao <ycao009@ucr.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36426 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948AbcGIIQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 04:16:05 -0400
Received: by mail-wm0-f41.google.com with SMTP id f126so36681069wma.1
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 01:16:03 -0700 (PDT)
In-Reply-To: <CAPzkZjz1R_T8q75LXLBc91j7YrngxdPc-o2Hpz+4YYyoWLantA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 17:27 -0700, Yue Cao wrote:
> Hi Eric,=20
>=20
>=20
> Thank you for the email. After rethinking the suggested patch, our
> side-channel attack might still work.
>=20
>=20
> The main idea behind the patch is to change challenge_count lifetime
> from 1s to a random value in the range [0.5s, 1.5s), which creates a
> time synchronization issue at the attacker's end.=20
>=20
>=20
> In our modified attack,=20
> 1. Instead of sending several packets throughout the 1s duration,
> attacker sends fewer packets in a short period (e.g. 0.1s, or even
> shorter). It is likely that this short period will be included in one
> challenge_count lifetime at the server=E2=80=99s end.
> 2. If this short period covers two challenge_counts=E2=80=99 lifetime=
 or some
> rare case that attacker is not sure, attacker can repeat sending same
> packets after a short period (e.g. 1.5s) to confirm it.=20
> 3. These packets should include one or more spoofed packets and 1005(=
a
> value bigger than 1001) packets to exhaust such side channel.=20
>=20
>=20
> In summary, if the attacker receives less than 1000 packets from the
> server, it must be a good guess. If the attacker receives more than
> 1000 packets from the server, this short period covers two
> challenge_counts=E2=80=99 lifetime and the attacker has to repeat sen=
ding same
> packets after a short duration. If the attacker receives exactly 1000
> packets from the server, it is most likely a wrong guess. However, th=
e
> attacker would better repeat sending packets to confirm it since thes=
e
> 1000 packets may be sent from two continuous challenge_counts=E2=80=99
> lifetime(though it=E2=80=99s a rare case).

OK so all we need is to vary the 1000 value a bit so that attacker can
not predict it, as Linus first did.

I will send a V2, thanks a lot !
