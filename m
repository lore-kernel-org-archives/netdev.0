From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] pkt_sched: gen_estimator: kill est_lock
 rwlock
Date: Mon, 07 Jun 2010 17:55:51 +0200
Message-ID: <1275926151.2545.126.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:57491 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab0FGPzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 11:55:55 -0400
Received: by wwe15 with SMTP id 15so521618wwe.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 08:55:54 -0700 (PDT)
In-Reply-To: <1275924638.2545.121.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 17:30 +0200, Eric Dumazet a =C3=A9crit :
> Le lundi 07 juin 2010 =C3=A0 22:53 +0800, Changli Gao a =C3=A9crit :
>=20
> > Hmm. I don't think it is correct.
> >=20
> > Look at this code:
> >=20
> > void xt_rateest_put(struct xt_rateest *est)
> > {
> >         mutex_lock(&xt_rateest_mutex);
> >         if (--est->refcnt =3D=3D 0) {
> >                 hlist_del(&est->list);
> >                 gen_kill_estimator(&est->bstats, &est->rstats);
> >                 kfree(est);
> >         }
> >         mutex_unlock(&xt_rateest_mutex);
> > }
> >=20
> > est will be released after gen_kill_estimator() returns. After est =
is
> > freed, there may still be some other CPUs running in the branch:
> >      if (bstats) {
> >          ....
> >      }
> >=20
>=20
> Oh well, I think I knew this from a previous attempt, but then I
> forgot :)
>=20
> I'll provide an updated patch, so that no other attempt is tried next
> yer, thanks !
>=20
>=20

=46or your information, bug is already there before my patch.

So this est_lock is a wrong protection, in the sense its so convoluted
that nobody but you and me even noticed it was buggy in the first place=
=2E

(see commit 5d944c640b4 for a first patch)



