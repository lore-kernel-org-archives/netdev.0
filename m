From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
Date: Tue, 8 Jun 2010 13:20:13 +0800
Message-ID: <AANLkTik6xx0cxZKezU31K4vYg4Rz0o7ndmN4D9vYSCKX@mail.gmail.com>
References: <1275921171.2545.102.camel@edumazet-laptop> <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	<1275924638.2545.121.camel@edumazet-laptop> <1275926151.2545.126.camel@edumazet-laptop>
	<1275929761.2545.159.camel@edumazet-laptop> <1275931108.2545.168.camel@edumazet-laptop>
	<AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
	<1275973091.2775.51.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:47590 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571Ab0FHFUf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 01:20:35 -0400
Received: by pvg16 with SMTP id 16so1728070pvg.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 22:20:33 -0700 (PDT)
In-Reply-To: <1275973091.2775.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 8, 2010 at 12:58 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 08 juin 2010 =E0 09:00 +0800, Changli Gao a =E9crit :
>
>> and I think gen_replace_estimator is expected to be an atomic operat=
ion.
>>
>> And gen_estimator_active() is also assumed to be called with RTNL lo=
cked.
>>
>
> My patch fixes a bug of new/kill operators, regardless of RTNL being
> held or not. Its should be small enough to be included in linux-2.6.3=
5.
>
> If what you say is right, all gen_replace_estimator() /
> gen_estimator_active() callers should still holds RTNL.
> I didnt change this part.
> If you believe one caller doesnt hold RTNL, please submit another pat=
ch.
>
> Then, in net-next-2.6, we can probably cleanup this to remove RTNL
> requirement if possible for gen_replace_estimator() /
> gen_estimator_active()
>
> Yes, it sounds a bit difficult (three patches instead of a single one=
),
> but this is the how things should be done, step by step.
>

IMO, this bug should be fixed by adding rtnl_lock to xt_RATEEST.c.
Killing rtnl should be done in separated patches. They are different
things. Your patch introduces another locks, and it is extra overhead
for other users.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
