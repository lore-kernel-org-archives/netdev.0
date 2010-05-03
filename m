From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 03 May 2010 07:41:07 +0200
Message-ID: <1272865267.2173.180.camel@edumazet-laptop>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
	 <5702.1272822394@localhost>  <1272865137.2173.179.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1272865137.2173.179.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 mai 2010 =C3=A0 07:38 +0200, Eric Dumazet a =C3=A9crit :
> Le dimanche 02 mai 2010 =C3=A0 13:46 -0400, Valdis.Kletnieks@vt.edu a=
 =C3=A9crit :
> > On Wed, 28 Apr 2010 16:53:32 PDT, akpm@linux-foundation.org said:
> > > The mm-of-the-moment snapshot 2010-04-28-16-53 has been uploaded =
to
> > >=20
> > >    http://userweb.kernel.org/~akpm/mmotm/
> >=20
> > I thought we swatted all these, hit another one...
> >=20
> > [    9.131490] ctnetlink v0.93: registering with nfnetlink.
> > [    9.131535]
> > [    9.131535] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [    9.131704] [ INFO: suspicious rcu_dereference_check() usage. ]
> > [    9.131794] ---------------------------------------------------
> > [    9.131883] net/netfilter/nf_conntrack_ecache.c:88 invoked rcu_d=
ereference_check() without protection!
> > [    9.131977]
> > [    9.131977] other info that might help us debug this:
> > [    9.131978]
> > [    9.132218]
> > [    9.132219] rcu_scheduler_active =3D 1, debug_locks =3D 0
> > [    9.132434] 1 lock held by swapper/1:
> > [    9.132519]  #0:  (nf_ct_ecache_mutex){+.+...}, at: [<ffffffff81=
48922d>] nf_conntrack_register_notifier+0x1a/0x75
> > [    9.132938]
> > [    9.132939] stack backtrace:
> > [    9.133129] Pid: 1, comm: swapper Tainted: G        W   2.6.34-r=
c5-mmotm0428 #1
> > [    9.133220] Call Trace:
> > [    9.133319]  [<ffffffff81064832>] lockdep_rcu_dereference+0xaa/0=
xb2
> > [    9.133410]  [<ffffffff81489250>] nf_conntrack_register_notifier=
+0x3d/0x75
> > [    9.133521]  [<ffffffff81b5a157>] ctnetlink_init+0x71/0xd5
> > [    9.133627]  [<ffffffff81b5a0e6>] ? ctnetlink_init+0x0/0xd5
> > [    9.133735]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
> > [    9.133843]  [<ffffffff81b2e68a>] kernel_init+0x144/0x1ce
> > [    9.133949]  [<ffffffff81003414>] kernel_thread_helper+0x4/0x10
> > [    9.134060]  [<ffffffff81598a40>] ? restore_args+0x0/0x30
> > [    9.134196]  [<ffffffff81b2e546>] ? kernel_init+0x0/0x1ce
> > [    9.134328]  [<ffffffff81003410>] ? kernel_thread_helper+0x0/0x1=
0
> > [    9.134530] ip_tables: (C) 2000-2006 Netfilter Core Team
> > [    9.134655] TCP bic registered
> >=20
>=20
> Thanks for the report !
>=20
> We can use rcu_dereference_protected() in those cases.
>=20
> [PATCH] net: Use rcu_dereference_protected in nf_conntrack_ecache
>=20
> Writers own nf_ct_ecache_mutex.
>=20
> Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---


Oops scratch that, I'll resend a correct version.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
