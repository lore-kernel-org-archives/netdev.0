From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [0/8] netpoll/bridge fixes
Date: Wed, 16 Jun 2010 05:03:20 +0200
Message-ID: <1276657400.19249.53.camel@edumazet-laptop>
References: <20100610145915.721a86b7@nehalam>
	 <20100610224839.GA22469@gondor.apana.org.au>
	 <20100611021142.GA24490@gondor.apana.org.au>
	 <20100615.113940.245399246.davem@davemloft.net>
	 <1276657139.19249.50.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	herbert@gondor.apana.org.au, shemminger@vyatta.com, mst@redhat.com,
	frzhang@redhat.com, netdev@vger.kernel.org, amwang@redhat.com,
	mpm@selenic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:36897 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288Ab0FPDDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 23:03:25 -0400
Received: by wwb18 with SMTP id 18so5302528wwb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 20:03:24 -0700 (PDT)
In-Reply-To: <1276657139.19249.50.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 16 juin 2010 =C3=A0 04:59 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 15 juin 2010 =C3=A0 11:39 -0700, David Miller a =C3=A9crit :
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Fri, 11 Jun 2010 12:11:42 +1000
> >=20
> > > On Fri, Jun 11, 2010 at 08:48:39AM +1000, Herbert Xu wrote:
> > >> On Thu, Jun 10, 2010 at 02:59:15PM -0700, Stephen Hemminger wrot=
e:
> > >> >
> > >> > Okay, then add a comment where in_irq is used?
> > >>=20
> > >> Actually let me put it into a wrapper.  I'll respin the patches.
> > >=20
> > > OK here is a repost.  And this time it really is 8 patches :)
> > > I've tested it lightly.
> >=20
> > All applied to net-next-2.6, thanks Herbert.
>=20

=46or this second splat, I dont know yet how to fix it, its 5 in the
morning here, I need a sleep ;)

At this point, no rcu_lock is held.

I wonder how these patches were tested, Herbert ?

[   74.431712]=20
[   74.431713] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
[   74.431717] [ INFO: suspicious rcu_dereference_check() usage. ]
[   74.431719] ---------------------------------------------------
[   74.431722] include/linux/netpoll.h:85 invoked rcu_dereference_check=
() without protection!
[   74.431725]=20
[   74.431726] other info that might help us debug this:
[   74.431727]=20
[   74.431730]=20
[   74.431730] rcu_scheduler_active =3D 1, debug_locks =3D 1
[   74.431733] no locks held by swapper/0.
[   74.431735]=20
[   74.431736] stack backtrace:
[   74.431739] Pid: 0, comm: swapper Not tainted 2.6.35-rc1-00508-gdbe3=
a24-dirty #78
[   74.431742] Call Trace:
[   74.431748]  [<c132cf0c>] ? printk+0xf/0x13
[   74.431754]  [<c1059ac6>] lockdep_rcu_dereference+0x74/0x7d
[   74.431759]  [<c1297628>] __napi_gro_receive+0x4d/0xf6
[   74.431764]  [<c12977a3>] napi_gro_receive+0x19/0x24
[   74.431775]  [<f805d83f>] bnx2x_rx_int+0x101b/0x124e [bnx2x]
[   74.431781]  [<c1050ffc>] ? async_thread+0x198/0x1de
[   74.431787]  [<c129580f>] ? net_tx_action+0x9a/0x12a
[   74.431797]  [<f805f267>] bnx2x_poll+0x5d/0x18b [bnx2x]
[   74.431801]  [<c1297360>] ? net_rx_action+0x1e4/0x21a
[   74.431805]  [<c105ccb2>] ? trace_hardirqs_on_caller+0xe2/0x11c
[   74.431810]  [<c1297218>] net_rx_action+0x9c/0x21a
[   74.431814]  [<c1039a21>] __do_softirq+0x126/0x277
[   74.431819]  [<c10398fb>] ? __do_softirq+0x0/0x277
[   74.431821]  <IRQ>  [<c1039c0d>] ? irq_exit+0x38/0x74
[   74.431828]  [<c1003d1f>] ? do_IRQ+0x87/0x9b
[   74.431833]  [<c1002d2e>] ? common_interrupt+0x2e/0x34
[   74.431838]  [<c105007b>] ? sched_clock_local+0x3f/0x11f
[   74.431843]  [<c11ba45b>] ? acpi_idle_enter_bm+0x271/0x2a0
[   74.431848]  [<c12797bd>] ? cpuidle_idle_call+0x76/0x151
[   74.431852]  [<c1001565>] ? cpu_idle+0x49/0x76
[   74.431857]  [<c1319ece>] ? rest_init+0xd6/0xdb
[   74.431861]  [<c156579f>] ? start_kernel+0x31b/0x320
[   74.431865]  [<c15650c9>] ? i386_start_kernel+0xc9/0xd0



