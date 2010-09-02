From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pkt_sched: Fix lockdep warning on est_tree_lock in
 gen_estimator
Date: Thu, 02 Sep 2010 22:32:01 +0200
Message-ID: <1283459521.3699.193.camel@edumazet-laptop>
References: <20100902201257.GA3089@del.dom.local>
	 <20100902.132248.229742285.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58574 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757103Ab0IBUcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:32:08 -0400
Received: by wwj40 with SMTP id 40so1339204wwj.1
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 13:32:07 -0700 (PDT)
In-Reply-To: <20100902.132248.229742285.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 13:22 -0700, David Miller a =C3=A9cri=
t :
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 2 Sep 2010 22:12:58 +0200
>=20
> > This patch fixes a lockdep warning:
> >=20
> > [  516.287584] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [  516.288386] [ INFO: possible irq lock inversion dependency detec=
ted ]
> > [  516.288386] 2.6.35b #7
> > [  516.288386] ----------------------------------------------------=
-----
> > [  516.288386] swapper/0 just changed the state of lock:
> > [  516.288386]  (&qdisc_tx_lock){+.-...}, at: [<c12eacda>] est_time=
r+0x62/0x1b4
> > [  516.288386] but this lock took another, SOFTIRQ-unsafe lock in t=
he past:
> > [  516.288386]  (est_tree_lock){+.+...}
> > [  516.288386]=20
> > [  516.288386] and interrupts could create inverse lock ordering be=
tween them.
> > ...
> >=20
> > So, est_tree_lock needs BH protection because it's taken by
> > qdisc_tx_lock, which is used both in BH and process contexts.
> > (Full warning with this patch at netdev, 02 Sep 2010.)
> >=20
> > Fixes commit: ae638c47dc040b8def16d05dc6acdd527628f231
> >=20
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>=20
> Applied, thanks Jarek.
>=20
> Eric, please make an effort to run with lockdep enabled when making
> locking changes, just for fun :-)

Hmm... I still trying to understand the problem.

I dont understand Jarek analysis yet.


