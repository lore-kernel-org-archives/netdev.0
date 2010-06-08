From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
Date: Tue, 08 Jun 2010 06:58:11 +0200
Message-ID: <1275973091.2775.51.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
	 <1275931108.2545.168.camel@edumazet-laptop>
	 <AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:57793 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370Ab0FHE6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:58:16 -0400
Received: by wwb28 with SMTP id 28so194734wwb.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 21:58:15 -0700 (PDT)
In-Reply-To: <AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 09:00 +0800, Changli Gao a =C3=A9crit :

> and I think gen_replace_estimator is expected to be an atomic operati=
on.
>=20
> And gen_estimator_active() is also assumed to be called with RTNL loc=
ked.
>=20

My patch fixes a bug of new/kill operators, regardless of RTNL being
held or not. Its should be small enough to be included in linux-2.6.35.

If what you say is right, all gen_replace_estimator() /
gen_estimator_active() callers should still holds RTNL.
I didnt change this part.
If you believe one caller doesnt hold RTNL, please submit another patch=
=2E

Then, in net-next-2.6, we can probably cleanup this to remove RTNL
requirement if possible for gen_replace_estimator() /
gen_estimator_active()

Yes, it sounds a bit difficult (three patches instead of a single one),
but this is the how things should be done, step by step.


