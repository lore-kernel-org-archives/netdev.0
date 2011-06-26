From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 17:53:50 +0200
Message-ID: <1309103630.2532.42.camel@edumazet-laptop>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309100994.2532.35.camel@edumazet-laptop>
	 <1309102334.5134.31.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63716 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab1FZPx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 11:53:57 -0400
Received: by wwe5 with SMTP id 5so4110935wwe.1
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2011 08:53:56 -0700 (PDT)
In-Reply-To: <1309102334.5134.31.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 26 juin 2011 =C3=A0 11:32 -0400, jamal a =C3=A9crit :
> On Sun, 2011-06-26 at 17:09 +0200, Eric Dumazet wrote:
>=20
>=20
> > I would just remove the jiffies break, now we have a 64 packets lim=
it...
> >=20
> > if (quota >=3D work || need_resched()) {
> > 	...
> > }
>=20
> Seems reasonable to do. Some stats (on two different machines
> at least with dummy) on a system with low # of processes:
> ~80% of the time - we exit the loop because of packet quota
> ~1% for both need_resched and jiffy
> ~19% simply because there were less than quota packets
>=20
> Note: we do use a jiffy check on net_rx_action() but i suspect
> we never ever hit it.

This is because of commit 24f8b2385e03a4f.

Prior to this, we could exit very fast from this function, even after
receiving a single packet.

jiffies break is kind of lazy, IMHO ;)



