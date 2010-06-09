From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pkt_sched: gen_estimator: more fuel for Jarek and Changli
Date: Wed, 09 Jun 2010 09:36:04 +0200
Message-ID: <1276068964.2442.15.camel@edumazet-laptop>
References: <20100608121546.GA9392@ff.dom.local>
	 <1276000052.2475.307.camel@edumazet-laptop>
	 <20100608124052.GB9392@ff.dom.local> <4C0E9A2E.9080109@gmail.com>
	 <1276026329.2439.2.camel@edumazet-laptop>
	 <20100608202405.GA3496@del.dom.local>
	 <1276030354.2439.8.camel@edumazet-laptop>
	 <1276063997.2439.650.camel@edumazet-laptop>
	 <20100609065134.GA6679@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37146 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab0FIHgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 03:36:08 -0400
Received: by fxm8 with SMTP id 8so3376881fxm.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 00:36:06 -0700 (PDT)
In-Reply-To: <20100609065134.GA6679@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 09 juin 2010 =C3=A0 06:51 +0000, Jarek Poplawski a =C3=A9cr=
it :
> On Wed, Jun 09, 2010 at 08:13:17AM +0200, Eric Dumazet wrote:
> >=20
> > With un-modified kernel, I ran following scripts on my machine
>=20
> Why not modified with your other patch quite obviously needed by
> rateest?:
>=20

=46irst patch is obvious, but I cooked same script to trigger both bugs=
,
because you needed some evidences.

> > [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
> >=20
> > gen_kill_estimator() / gen_new_estimator() is not always called wit=
h
> > RTNL held.
>=20
> Btw, I agree with Changli that adding RTNL to rateest (if possible),
> and doing the RTNL replacement later, seems more proper.
>=20

I wont be the guy adding RTNL to netfilter, thats for sure. That would
be a step backward.=20
Sometimes, the 'obvious' fix is also a dumb one.
Do you really think I didnt had this idea too ?

xt_RATEEST is an unfortunate domain intersection (netfilter / sched).

We can solve this using a fine grained lock, instead of interesting
lockdep issues, yet to be discovered.

You can submit your patch, but I wont Ack it, I'll Nack it for all thes=
e
reasons.

Why dont we remove all locks we have 'because we can use RTNL and be
with it' ?

qdisc_mod_lock could be removed quite instantly, qdisc_base could be
protected by RTNL... And so on...



