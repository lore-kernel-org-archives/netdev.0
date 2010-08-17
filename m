From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RPS vs. hard-irq-context netif_rx()
Date: Tue, 17 Aug 2010 16:54:37 +0200
Message-ID: <1282056877.2448.59.camel@edumazet-laptop>
References: <20100817115230.GA6510@nb-core2.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>
To: Luca Tettamanti <kronos.it@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60101 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129Ab0HQOyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 10:54:43 -0400
Received: by wyb32 with SMTP id 32so7123012wyb.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 07:54:42 -0700 (PDT)
In-Reply-To: <20100817115230.GA6510@nb-core2.darkstar.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 ao=C3=BBt 2010 =C3=A0 13:52 +0200, Luca Tettamanti a =C3=A9=
crit :
> > I got the following on a kvm instance I use for testing:
> >=20
> > [ 51.358803] WARNING: at kernel/lockdep.c:2327trace_hardirqs_on_cal=
ler+0x167/0x200()
> > [ 51.360210] Hardware name: Bochs
> > [ 51.360210] Modules linked in:
> > [ 51.360210] Pid: 1546, comm: dhclient3 Tainted: G        W 2.6.35-=
rc6-wl+ #588
> > [ 51.360210] Call Trace:
> > [ 51.360210]  <IRQ>  [<ffffffff8104e87f>] warn_slowpath_common+0x7f=
/0xc0
> > [ 51.360210]  [<ffffffff8104e8da>] warn_slowpath_null+0x1a/0x20
> > [ 51.360210]  [<ffffffff81087977>] trace_hardirqs_on_caller+0x167/0=
x200
> > [ 51.360210]  [<ffffffff81087a1d>] trace_hardirqs_on+0xd/0x10
> > [ 51.360210]  [<ffffffff81056ade>] local_bh_enable+0x9e/0x130
> > [ 51.360210]  [<ffffffff8139fa82>] netif_rx+0xc2/0x250
> > [ 51.360210]  [<ffffffff813146d7>] ei_receive+0x1b7/0x2c0
> > [ 51.360210]  [<ffffffff81314ca2>] __ei_interrupt+0x282/0x360
> > [ 51.360210]  [<ffffffff81314dce>] ei_interrupt+0xe/0x10
> > [ 51.360210]  [<ffffffff810abe85>] handle_IRQ_event+0x85/0x300
> > [ 51.360210]  [<ffffffff810aead5>] handle_level_irq+0x95/0x120
> > [ 51.360210]  [<ffffffff81005a12>] handle_irq+0x22/0x30
> > [ 51.360210]  [<ffffffff814394b3>] do_IRQ+0x73/0xf0
> [...]
> >So .. where's the bug? I'd point to CONFIG_RPS since it's newest.
>=20
> Hello,
> I just hit the same warning, with 2.6.36-rc1:
>=20
> [  228.001459] WARNING: at /home/kronos/src/linux-2.6.git/kernel/soft=
irq.c:143 local_bh_enable+0x3c/0x9a()
> [  228.004096] Hardware name: F3Sa               =20
> [  228.004175] Modules linked in: [...]
> [  228.015974] Pid: 2818, comm: irqbalance Not tainted 2.6.36-rc1 #27=
4
> [  228.015974] Call Trace:
> [  228.015974]  <IRQ>  [<ffffffff81034b32>] warn_slowpath_common+0x80=
/0x98
> [  228.015974]  [<ffffffff81034b5f>] warn_slowpath_null+0x15/0x17
> [  228.015974]  [<ffffffff8103a009>] local_bh_enable+0x3c/0x9a
> [  228.015974]  [<ffffffff8120dc16>] netif_rx+0x75/0x145
> [  228.015974]  [<ffffffff8115162f>] ? unmap_single+0x4a/0x52
> [  228.015974]  [<ffffffff811e7fcd>] atl1_intr+0x96c/0xa35
> [  228.015974]  [<ffffffff8104edf4>] ? hrtimer_wakeup+0x0/0x21
> [  228.015974]  [<ffffffff810707b2>] handle_IRQ_event+0x20/0x9a
> [  228.015974]  [<ffffffff810723ba>] handle_edge_irq+0xf5/0x141
> [  228.015974]  [<ffffffff81004d53>] handle_irq+0x83/0x8c
> [  228.015974]  [<ffffffff81004332>] do_IRQ+0x5e/0xc4
> [  228.015974]  [<ffffffff812843d3>] ret_from_intr+0x0/0xa
>=20
> CONFIG_TREE_RCU=3Dy
> CONFIG_RPS=3Dy
>=20
> I never saw the warning with 2.6.35 and earlier kernels though.

This is a known problem, related to netpoll

http://www.kerneltrap.com/mailarchive/linux-netdev/2010/8/10/6282780



