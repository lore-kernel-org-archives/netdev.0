From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Fix lockdep warning on est_tree_lock in
 gen_estimator
Date: Thu, 2 Sep 2010 22:55:35 +0200
Message-ID: <20100902205535.GB3089@del.dom.local>
References: <20100902201257.GA3089@del.dom.local>
 <20100902.132248.229742285.davem@davemloft.net>
 <1283459521.3699.193.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:49829 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737Ab0IBUzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 16:55:42 -0400
Received: by ewy23 with SMTP id 23so660931ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 13:55:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1283459521.3699.193.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 10:32:01PM +0200, Eric Dumazet wrote:
> Le jeudi 02 septembre 2010 ?? 13:22 -0700, David Miller a =E9crit :
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Thu, 2 Sep 2010 22:12:58 +0200
> >=20
> > > This patch fixes a lockdep warning:
> > >=20
> > > [  516.287584] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > [  516.288386] [ INFO: possible irq lock inversion dependency det=
ected ]
> > > [  516.288386] 2.6.35b #7
> > > [  516.288386] --------------------------------------------------=
-------
> > > [  516.288386] swapper/0 just changed the state of lock:
> > > [  516.288386]  (&qdisc_tx_lock){+.-...}, at: [<c12eacda>] est_ti=
mer+0x62/0x1b4
> > > [  516.288386] but this lock took another, SOFTIRQ-unsafe lock in=
 the past:
> > > [  516.288386]  (est_tree_lock){+.+...}
> > > [  516.288386]=20
> > > [  516.288386] and interrupts could create inverse lock ordering =
between them.
> > > ...
> > >=20
> > > So, est_tree_lock needs BH protection because it's taken by
> > > qdisc_tx_lock, which is used both in BH and process contexts.
> > > (Full warning with this patch at netdev, 02 Sep 2010.)
> > >=20
> > > Fixes commit: ae638c47dc040b8def16d05dc6acdd527628f231
> > >=20
> > > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> >=20
> > Applied, thanks Jarek.
> >=20
> > Eric, please make an effort to run with lockdep enabled when making
> > locking changes, just for fun :-)
>=20
> Hmm... I still trying to understand the problem.
>=20
> I dont understand Jarek analysis yet.
>=20

cpu1:					cpu2:
(process)				(process)
qdisc_tx_lock				est_tree_lock
(waiting for est_tree_lock)		(bh)
					(waiting for qdisc_tx_lock)

Jarek P.
